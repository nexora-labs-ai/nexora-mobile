# Nexora Mobile 📱

> **AI Group Event & Expense Planner** – Ứng dụng Flutter giúp nhóm bạn lên kế hoạch sự kiện, quản lý chi tiêu nhóm, chia tiền thông minh và nhận gợi ý địa điểm từ AI.

---

## Mục lục

- [Tổng quan dự án](#tổng-quan-dự-án)
- [Tech Stack](#tech-stack)
- [Kiến trúc](#kiến-trúc)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Cài đặt & Chạy dự án](#cài-đặt--chạy-dự-án)
- [Environments / Flavors](#environments--flavors)
- [Code Generation](#code-generation)
- [Chạy Tests](#chạy-tests)
- [Quy tắc kiến trúc](#quy-tắc-kiến-trúc)
- [Luồng request mẫu](#luồng-request-mẫu)
- [Chiến lược Offline-first](#chiến-lược-offline-first)
- [Realtime & AI Chat](#realtime--ai-chat)
- [Contributing](#contributing)

---

## Tổng quan dự án

Nexora là nền tảng **AI-powered** hỗ trợ nhóm bạn, team và tổ chức trong toàn bộ vòng đời sự kiện:

| Tính năng | Mô tả |
|---|---|
| 🗺️ **AI Event Planner** | Tự động generate lịch trình, ước tính ngân sách từ một prompt |
| 💸 **Expense Splitter** | Ghi nhận & phân chia chi tiêu nhóm, hỗ trợ nhiều phương thức chia |
| 🧮 **Debt Simplification** | Thuật toán tối giản công nợ, giảm thiểu số lượt chuyển khoản |
| 🤖 **AI Budget Assistant** | Phân tích nguy cơ vượt chi, gợi ý tối ưu ngân sách |
| 💬 **Conversational AI** | Chat trực tiếp với AI để tra cứu chi tiêu và lên kế hoạch |
| 🔔 **Realtime Sync** | Cộng tác đồng thời qua WebSocket, thông báo tức thì |
| 📍 **AI Recommendations** | Gợi ý quán ăn/địa điểm dựa trên mood, ngân sách và lịch sử nhóm |

---

## Tech Stack

| Lĩnh vực | Thư viện |
|---|---|
| **Framework** | Flutter 3.38+ / Dart 3.10+ |
| **State Management** | `flutter_bloc` 8 · `bloc` 8 |
| **Navigation** | `go_router` 13 |
| **HTTP Client** | `dio` 5 |
| **Code Generation** | `freezed` · `json_serializable` · `injectable` |
| **Local Database** | `hive_flutter` |
| **Secure Storage** | `flutter_secure_storage` |
| **Push Notifications** | `firebase_messaging` |
| **Realtime** | `socket_io_client` |
| **DI Container** | `get_it` · `injectable` |
| **Functional** | `dartz` (Either/Option) |
| **Testing** | `bloc_test` · `mocktail` |

---

## Kiến trúc

Dự án áp dụng **Clean Architecture** kết hợp **Feature-First** (Vertical Slice):

```
Presentation  ──►  Domain  ──►  Data  ──►  Remote/Local
     │                │
   Cubit/Bloc       UseCase
     │                │
   Widget        Repository (interface)
```

**Nguyên tắc cốt lõi:**
- Domain layer là **pure Dart** – không phụ thuộc Flutter, Dio, Hive
- Mỗi feature sở hữu toàn bộ `presentation / domain / data` của nó
- Dependency chỉ đi **từ ngoài vào trong** (Presentation → Domain ← Data)
- Tất cả lỗi qua layer boundaries được chuyển thành typed `Failure` (không throw exception)

---

## Cấu trúc thư mục

```
lib/
│
├── main.dart                          # Entry point (thin, gọi bootstrap)
├── nexora_mobile.dart                 # Barrel exports cho core types
│
├── app/
│   ├── app.dart                       # NexoraApp (MaterialApp.router)
│   ├── bootstrap/bootstrap.dart       # Init: Hive → Firebase → DI → runApp
│   ├── bindings/
│   │   ├── injection_container.dart   # GetIt setup với @InjectableInit
│   │   └── injection_container.config.dart  # Generated bởi injectable_generator
│   └── router/
│       ├── app_router.dart            # GoRouter + ShellRoute (bottom nav)
│       └── route_names.dart           # Hằng số tên route
│
├── core/                              # Infrastructure dùng chung toàn app
│   ├── base/
│   │   ├── base_usecase.dart          # Interface UseCase<T, P> + NoParams
│   │   └── base_cubit.dart            # BaseCubit với logging + safeEmit
│   ├── constants/app_constants.dart   # PageSize, TTL, socket events, currencies
│   ├── environment/app_env.dart       # Flavors: dev / staging / prod
│   ├── errors/
│   │   ├── failure.dart               # Sealed Failure hierarchy
│   │   ├── exceptions.dart            # Data-layer exceptions
│   │   └── dio_error_mapper.dart      # DioException → Failure converter
│   ├── interceptors/
│   │   ├── auth_interceptor.dart      # Bearer token + silent refresh
│   │   ├── retry_interceptor.dart     # Exponential back-off retry
│   │   └── logging_interceptor.dart   # Redacted request/response log
│   ├── logger/app_logger.dart         # Logger wrapper (off in prod)
│   ├── network/
│   │   ├── dio_client.dart            # Dio singleton với interceptors
│   │   └── api_endpoints.dart         # Tất cả endpoint strings
│   ├── notification/fcm_service.dart  # Firebase Messaging setup
│   ├── router/auth_guard.dart         # GoRouter redirect guard
│   ├── socket/
│   │   ├── socket_service.dart        # Socket.IO connection lifecycle
│   │   └── event_dispatcher.dart      # Typed stream channels per event
│   ├── storage/
│   │   ├── secure_storage.dart        # FlutterSecureStorage wrapper (tokens)
│   │   └── hive_storage.dart          # Hive wrapper (prefs + JSON cache)
│   └── theme/
│       ├── app_theme.dart             # Light & dark ThemeData
│       ├── app_colors.dart            # Brand color palette
│       └── app_text_styles.dart       # Typography scale (Inter)
│
├── shared/                            # UI & domain components tái sử dụng
│   ├── components/error_view.dart     # ErrorView + EmptyView
│   ├── enums/app_enums.dart           # LoadingStatus, SplitMethod, Category…
│   ├── validators/form_validators.dart # Pure validation functions
│   └── widgets/
│       ├── app_button.dart            # Nút CTA với loading/outlined variants
│       ├── app_text_field.dart        # Input field nhất quán
│       └── splash_screen.dart         # Splash + auth routing logic
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/           # auth_remote_datasource · auth_local_datasource
    │   │   ├── mappers/auth_mapper.dart
    │   │   ├── models/                # user_model · auth_token_model (+ .g.dart)
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/              # UserEntity · AuthTokenEntity
    │   │   ├── repositories/auth_repository.dart  (interface)
    │   │   └── usecases/              # LoginUseCase · RegisterUseCase · LogoutUseCase
    │   └── presentation/
    │       ├── cubit/                 # AuthCubit · AuthState (sealed)
    │       └── pages/                 # LoginPage · RegisterPage
    │
    ├── expenses/
    │   ├── data/
    │   │   ├── datasources/           # expense_remote · expense_local (Hive cache)
    │   │   ├── mappers/expense_mapper.dart
    │   │   ├── models/expense_model.dart (+ .g.dart)
    │   │   └── repositories/expense_repository_impl.dart  ← cache-first strategy
    │   ├── domain/
    │   │   ├── entities/              # ExpenseEntity · ExpenseSplitEntity
    │   │   ├── repositories/expense_repository.dart
    │   │   └── usecases/              # GetExpenses · CreateExpense · DeleteExpense
    │   └── presentation/
    │       ├── cubit/                 # ExpenseCubit · ExpenseState · pagination
    │       ├── pages/                 # ExpenseListPage · CreateExpensePage
    │       └── widgets/expense_card.dart
    │
    ├── groups/
    │   ├── data/repositories/group_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/              # GroupEntity · GroupMemberEntity
    │   │   ├── repositories/group_repository.dart
    │   │   └── usecases/              # GetGroups · GetGroupDetail · CreateGroup
    │   └── presentation/
    │       ├── cubit/                 # GroupCubit · GroupState
    │       ├── pages/                 # GroupListPage · GroupDetailPage · CreateGroupPage
    │       └── widgets/group_card.dart
    │
    ├── chat/                          # AI Chat – dùng Bloc (streaming)
    │   ├── data/repositories/chat_repository_impl.dart  ← Socket.IO streaming
    │   ├── domain/
    │   │   ├── entities/              # MessageEntity · ChatSessionEntity
    │   │   └── repositories/chat_repository.dart
    │   └── presentation/
    │       ├── bloc/                  # ChatBloc · ChatEvent · ChatState
    │       ├── pages/chat_page.dart
    │       └── widgets/               # ChatBubble · ChatInput · TypingIndicator
    │
    ├── dashboard/presentation/pages/dashboard_page.dart
    ├── notifications/presentation/pages/notifications_page.dart
    └── profile/presentation/pages/profile_page.dart
```

---

## Yêu cầu môi trường

| Công cụ | Phiên bản tối thiểu |
|---|---|
| Flutter | `3.16+` (khuyến nghị `3.38+`) |
| Dart | `3.3+` |
| Android Studio / VS Code | Bất kỳ phiên bản hỗ trợ Flutter |
| Android SDK | API 21+ (Android 5.0) |
| Xcode | 15+ (chỉ macOS, cho iOS build) |
| Java | JDK 17+ |
| Node.js | 18+ (để chạy backend API) |

### Kiểm tra môi trường

```bash
flutter doctor -v
```

---

## Cài đặt & Chạy dự án

### 1. Clone repository

```bash
git clone https://github.com/your-org/nexora-mobile.git
cd nexora-mobile
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Generate code

Bắt buộc sau khi clone hoặc thay đổi model/DI:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Hoặc watch mode (tự động re-generate khi file thay đổi):

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 4. Cấu hình Firebase

```bash
# Cài FlutterFire CLI nếu chưa có
dart pub global activate flutterfire_cli

# Cấu hình Firebase cho project
flutterfire configure --project=nexora-dev
```

Đặt file `google-services.json` vào `android/app/` và `GoogleService-Info.plist` vào `ios/Runner/`.

### 5. Chạy ứng dụng

#### Android

```bash
# Development (kết nối Android emulator hoặc thiết bị thật)
flutter run --dart-define=FLAVOR=development

# Chỉ định device cụ thể
flutter run -d emulator-5554 --dart-define=FLAVOR=development
```

#### iOS (yêu cầu macOS + Xcode)

```bash
flutter run -d iPhone --dart-define=FLAVOR=development
```

#### Xem danh sách thiết bị

```bash
flutter devices
```

> **Lưu ý:** `flutter run` không hỗ trợ Windows Desktop hoặc Web theo mặc định vì project được cấu hình cho mobile. Hãy dùng Android emulator hoặc thiết bị thật.

---

## Environments / Flavors

Dự án có 3 environment, chọn qua compile-time constant `FLAVOR`:

| Flavor | BASE_URL mặc định | SSL Pinning | Logging |
|---|---|---|---|
| `development` | `http://10.0.2.2:3000/api/v1` | ❌ | ✅ |
| `staging` | `https://api-staging.nexora.app/api/v1` | ✅ | ✅ |
| `production` | `https://api.nexora.app/api/v1` | ✅ | ❌ |

### Ghi đè URL khi chạy

```bash
# Chạy với backend local trên IP mạng LAN
flutter run \
  --dart-define=FLAVOR=development \
  --dart-define=BASE_URL=http://192.168.1.100:3000/api/v1 \
  --dart-define=SOCKET_URL=http://192.168.1.100:3000
```

> `10.0.2.2` là địa chỉ trỏ về `localhost` máy host khi dùng Android Emulator.  
> Nếu dùng thiết bị thật, thay bằng IP LAN của máy chạy backend.

### Build release

```bash
# Staging APK
flutter build apk \
  --release \
  --dart-define=FLAVOR=staging \
  --dart-define=BASE_URL=https://api-staging.nexora.app/api/v1

# Production App Bundle (Google Play)
flutter build appbundle \
  --release \
  --dart-define=FLAVOR=production
```

---

## Code Generation

Dự án dùng `build_runner` cho 3 mục đích:

| Package | Mục đích | File output |
|---|---|---|
| `json_serializable` | Parse/serialize JSON models | `*.g.dart` |
| `freezed` | Immutable classes + sealed unions | `*.freezed.dart` |
| `injectable_generator` | Wiring DI container | `injection_container.config.dart` |

```bash
# Build một lần
flutter pub run build_runner build --delete-conflicting-outputs

# Clean + rebuild toàn bộ
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (dev)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## Chạy Tests

```bash
# Toàn bộ test suite
flutter test

# Chỉ một file test
flutter test test/features/auth/presentation/auth_cubit_test.dart

# Với coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Cấu trúc tests

```
test/
├── features/
│   ├── auth/
│   │   └── presentation/auth_cubit_test.dart         # Unit test AuthCubit
│   └── expenses/
│       └── domain/get_expenses_usecase_test.dart      # Unit test UseCase
└── (widget/, integration/ – bổ sung theo roadmap)
```

### Mục tiêu coverage

| Layer | Target |
|---|---|
| Use Cases | 80%+ |
| Repositories | 70%+ |
| Cubits / Blocs | 80%+ |
| Shared Widgets | 60%+ |

---

## Quy tắc kiến trúc

### ✅ Dependency được phép

```
LoginPage → AuthCubit → LoginUseCase → AuthRepository → AuthRemoteDatasource → Dio
```

### ❌ Dependency bị cấm

```
Page → Repository         (bỏ qua UseCase)
Page → Dio                (gọi thẳng HTTP)
Cubit → Datasource        (bỏ qua Repository)
Entity → Flutter Widget   (domain biết UI)
Entity → Dio              (domain biết network)
Repository → Bloc         (data biết state)
```

### Quy tắc đặt tên

```dart
// ✅ Rõ ràng, mô tả đúng vai trò
ExpensePage           // trang
ExpenseCubit          // state management
ExpenseState          // trạng thái (sealed)
ExpenseRepository     // hợp đồng data layer (interface)
ExpenseDatasource     // nguồn dữ liệu cụ thể
ExpenseEntity         // domain object (pure Dart)
ExpenseModel          // transport object (JSON)
CreateExpenseUseCase  // business action

// ❌ Tên chung chung – tránh dùng
ExpenseManager
ExpenseHelper
ExpenseService
GlobalExpenseController
```

---

## Luồng request mẫu

Ví dụ: **Người dùng thêm một khoản chi tiêu mới**

```
CreateExpensePage
  │  onPressed → cubit.createExpense(params)
  ▼
ExpenseCubit
  │  safeEmit(ExpenseCreating())
  │  await _createExpenseUseCase(params)
  ▼
CreateExpenseUseCase
  │  return _repository.createExpense(...)
  ▼
ExpenseRepositoryImpl
  │  await _remote.createExpense(groupId, data)
  │  await _local.clearCache(groupId)        ← invalidate cache
  ▼
ExpenseRemoteDatasourceImpl
  │  _dioClient.dio.post('/groups/:id/expenses', data)
  │  ┌──────────────────────────────────────────────┐
  │  │ AuthInterceptor    → Bearer token injected   │
  │  │ RetryInterceptor   → retry nếu timeout       │
  │  │ LoggingInterceptor → log request/response    │
  │  └──────────────────────────────────────────────┘
  ▼
Backend API → HTTP 201 { expense_model }
  ▼
ExpenseRepositoryImpl
  │  Right(ExpenseMapper.toEntity(model))
  ▼
ExpenseCubit
  │  safeEmit(ExpenseCreated(expense))
  │  loadExpenses(groupId)                   ← refresh list
  ▼
CreateExpensePage
     BlocListener: ExpenseCreated → context.pop()
```

---

## Chiến lược Offline-first

`ExpenseRepositoryImpl` áp dụng **cache-first + remote fallback**:

```
getExpenses() được gọi
        │
        ▼
  Gọi Remote API
        │
  ┌─────┴─────┐
  │ Thành công │  → Cập nhật Hive cache → Return data
  └─────┬─────┘
        │ Thất bại (no internet / timeout)
        ▼
  Đọc từ Hive cache
        │
  ┌─────┴──────────┐
  │ Cache có data  │  → Return cached data (hiển thị badge "offline")
  │ Cache trống    │  → Return NetworkFailure → UI hiện ErrorView + Retry
  └────────────────┘
```

**Write operations** (create/update/delete):
- Gọi remote trước
- Nếu thành công → invalidate cache
- Nếu thất bại → trả về `Failure` (không dùng optimistic write cho dữ liệu tài chính)

---

## Realtime & AI Chat

### Socket.IO flow

```
SocketService.connect()          ← singleton, kết nối sau login
        │
        ▼
EventDispatcher.on('event_name') ← typed broadcast stream
        │
        ▼
ChatBloc / ExpenseCubit          ← subscribe và cập nhật state
```

### AI Chat Streaming

```
User gửi tin nhắn
        │
ChatBloc.add(ChatMessageSent)
        │  Optimistic: thêm user bubble + streaming placeholder
        │
ChatRepositoryImpl.streamMessage()
        │  emit socket → 'ai:stream_message'
        │  listen      ← 'ai:stream_chunk_$sessionId'
        │
Server streams chunks về
        │
ChatBloc.add(ChatMessageStreamReceived(chunk))
        │  → append chunk vào streaming bubble
        │
ChatBloc.add(ChatMessageStreamCompleted)
        │  → isStreaming = false, finalize message id
        ▼
ChatPage renders tin nhắn hoàn chỉnh
```

---

## Contributing

### Quy trình thêm feature mới

1. Tạo thư mục `lib/features/<feature_name>/{domain,data,presentation}/`
2. Định nghĩa **Entity** (pure Dart, không dependency ngoài)
3. Viết interface **Repository**
4. Implement **UseCase(s)**
5. Viết **Model + Mapper + Datasource + RepositoryImpl**
6. Tạo **Cubit/Bloc + State**
7. Build **Page(s) + Widget(s)**
8. Đăng ký route trong [app_router.dart](lib/app/router/app_router.dart)
9. Chạy `build_runner` nếu có model mới
10. Viết unit tests cho UseCase và Cubit

### Checklist trước khi commit

- [ ] `flutter analyze` không có warning/error
- [ ] `flutter test` pass toàn bộ
- [ ] Không import `dio`/`hive` trong domain layer
- [ ] Không import Flutter widget trong domain/data layer
- [ ] Tên file và class theo convention
- [ ] `build_runner` đã chạy nếu thay đổi model hoặc DI registration
