import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../app/bindings/injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../../domain/entities/recommendation_entity.dart';
import 'recommendations_event.dart';
import 'recommendations_state.dart';

@injectable
class RecommendationsBloc extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc(this._repository) : super(RecommendationsInitial()) {
    on<LoadRecommendations>(_onLoad);
    on<GenerateRecommendations>(_onGenerate);
    on<ToggleLikeRecommendation>(_onToggleLike);
    on<RecommendationsGeneratedReceived>(_onRecommendationsGeneratedReceived);
    on<RecommendationGeneratingReceived>(_onRecommendationGeneratingReceived);
    on<RecommendationLikeUpdated>(_onRecommendationLikeUpdated);
    on<ClearRecommendationError>(_onClearError);
    on<DeleteRecommendationsByBatch>(_onDeleteByBatch);
  }

  final RecommendationsRepository _repository;
  StreamSubscription<List<RecommendationEntity>>? _generatedSub;
  StreamSubscription<bool>? _generatingSub;
  StreamSubscription<Map<String, dynamic>>? _likeSub;

  Future<void> _onLoad(LoadRecommendations event, Emitter<RecommendationsState> emit) async {
    emit(RecommendationsLoading());
    
    _generatedSub ??= _repository.onRecommendationsGenerated.listen((recs) {
      add(RecommendationsGeneratedReceived(recs));
    });

    _generatingSub ??= _repository.onRecommendationGenerating.listen((isGenerating) {
      add(RecommendationGeneratingReceived(isGenerating));
    });

    _likeSub ??= _repository.onRecommendationLiked.listen((data) {
      add(RecommendationLikeUpdated(
        data['recommendationId'] as String,
        data['userId'] as String,
        data['action'] as String,
      ));
    });

    final result = await _repository.getGroupRecommendations(event.groupId);
    result.fold(
      (failure) => emit(RecommendationsError(failure.message)),
      (recommendations) => emit(RecommendationsLoaded(recommendations)),
    );
  }

  Future<void> _onGenerate(GenerateRecommendations event, Emitter<RecommendationsState> emit) async {
    if (state is RecommendationsLoaded) {
      emit((state as RecommendationsLoaded).copyWith(isGenerating: true, clearError: true));
    }
    final result = await _repository.generateRecommendations(event.groupId, event.type);
    result.fold(
      (failure) {
        if (state is RecommendationsLoaded) {
          emit((state as RecommendationsLoaded).copyWith(
            isGenerating: false,
            errorMessage: failure.message,
          ));
        }
      },
      (_) {
        // Will be handled by the stream RecommendationsGeneratedReceived
      },
    );
  }

  Future<void> _onToggleLike(ToggleLikeRecommendation event, Emitter<RecommendationsState> emit) async {
    if (state is RecommendationsLoaded) {
      final currentState = state as RecommendationsLoaded;
      final recs = currentState.recommendations.toList();
      final index = recs.indexWhere((r) => r.id == event.recommendationId);
      
      if (index != -1) {
        final rec = recs[index];
        final isCurrentlyLiked = rec.isLiked;
        
        // Optimistic UI Update
        recs[index] = rec.copyWith(
          isLiked: !isCurrentlyLiked,
          likeCount: isCurrentlyLiked ? rec.likeCount - 1 : rec.likeCount + 1,
        );
        emit(currentState.copyWith(recommendations: recs));

        if (isCurrentlyLiked) {
          await _repository.unlikeRecommendation(event.groupId, event.recommendationId);
        } else {
          await _repository.likeRecommendation(event.groupId, event.recommendationId);
        }
      }
    }
  }

  Future<void> _onDeleteByBatch(DeleteRecommendationsByBatch event, Emitter<RecommendationsState> emit) async {
    if (state is RecommendationsLoaded) {
      final currentState = state as RecommendationsLoaded;
      // Optimistic delete
      final newRecs = currentState.recommendations.where((r) => r.metadata?['batchId'] != event.batchId).toList();
      emit(currentState.copyWith(recommendations: newRecs));
      
      final result = await _repository.deleteRecommendationsByBatch(event.groupId, event.batchId);
      result.fold(
        (failure) {
          // If fail, we don't rollback for now, just show error
          emit(currentState.copyWith(errorMessage: failure.message));
        },
        (_) {},
      );
    }
  }

  void _onRecommendationsGeneratedReceived(RecommendationsGeneratedReceived event, Emitter<RecommendationsState> emit) {
    if (state is RecommendationsLoaded) {
      final currentState = state as RecommendationsLoaded;
      
      // Merge new recommendations at the top
      final newRecs = [...event.recommendations, ...currentState.recommendations];
      // Deduplicate by ID
      final Map<String, dynamic> seen = {};
      final deduped = newRecs.where((r) {
        if (seen.containsKey(r.id)) return false;
        seen[r.id] = true;
        return true;
      }).toList();

      emit(RecommendationsLoaded(deduped, isGenerating: false));
    } else {
      emit(RecommendationsLoaded(event.recommendations));
    }
  }

  void _onRecommendationGeneratingReceived(RecommendationGeneratingReceived event, Emitter<RecommendationsState> emit) {
    if (state is RecommendationsLoaded) {
      emit((state as RecommendationsLoaded).copyWith(
        isGenerating: event.isGenerating, 
        clearError: true,
      ));
    }
  }

  void _onRecommendationLikeUpdated(RecommendationLikeUpdated event, Emitter<RecommendationsState> emit) {
    if (state is RecommendationsLoaded) {
      final currentState = state as RecommendationsLoaded;
      final recs = currentState.recommendations.toList();
      final index = recs.indexWhere((r) => r.id == event.recommendationId);

      // Check current user
      final authState = sl<AuthCubit>().state;
      String? currentUserId;
      if (authState is AuthAuthenticated) {
        currentUserId = authState.user.id;
      }

      // If the event is from the current user, we already updated optimistically
      if (currentUserId == event.userId) return;

      if (index != -1) {
        final rec = recs[index];
        final newLikeCount = event.action == 'like' ? rec.likeCount + 1 : rec.likeCount - 1;
        recs[index] = rec.copyWith(likeCount: newLikeCount < 0 ? 0 : newLikeCount);
        emit(currentState.copyWith(recommendations: recs));
      }
    }
  }

  void _onClearError(ClearRecommendationError event, Emitter<RecommendationsState> emit) {
    if (state is RecommendationsLoaded) {
      emit((state as RecommendationsLoaded).copyWith(clearError: true));
    }
  }

  @override
  Future<void> close() {
    _generatedSub?.cancel();
    _generatingSub?.cancel();
    _likeSub?.cancel();
    return super.close();
  }
}
