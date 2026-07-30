import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'category_state.dart';

@lazySingleton
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._getCategoriesUseCase) : super(const CategoryInitial());

  final GetCategoriesUseCase _getCategoriesUseCase;

  Future<void> loadCategories() async {
    if (state is CategoryLoaded) return;

    emit(const CategoryLoading());
    final result = await _getCategoriesUseCase(const NoParams());

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }
}
