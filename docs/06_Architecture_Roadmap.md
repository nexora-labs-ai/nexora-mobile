# Kiến trúc, Roadmap & Thách thức kỹ thuật

## 1. Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Node.js, NestJS, TypeScript |
| **Database** | PostgreSQL (via Prisma ORM) |
| **Cache & Session** | Redis |
| **Queue** | BullMQ (chạy trên Redis) |
| **Realtime** | Socket.IO + Redis Adapter |
| **AI** | OpenAI API (GPT-4o), LangChain |
| **Maps & Location** | Google Maps Places API |
| **Storage** | AWS S3 (avatar, receipt, cover image) |
| **Deployment** | Docker, Nginx, CI/CD (GitHub Actions) |
| **Monitoring** | Sentry, structured logging |

---

## 2. Backend Architecture (NestJS)

Hệ thống được thiết kế theo **Clean Architecture** và **Module-driven development** của NestJS.

```text
src/
├── modules/
│   ├── auth/               # Xác thực: Local, Google OAuth2, JWT
│   ├── users/              # User profile, settings, notifications
│   ├── groups/             # Group workspace, membership, invitations
│   ├── expenses/           # Chi tiêu, chia tiền, categories
│   ├── settlements/        # Thanh toán nợ, balances, debt simplification
│   ├── itinerary/          # Lịch trình, itinerary items
│   ├── recommendations/    # AI gợi ý địa điểm, voting
│   ├── polls/              # Tạo poll, vote
│   ├── ai/
│   │   ├── planning/       # AI generate itinerary (BullMQ job)
│   │   ├── recommendation/ # AI scoring & recommendation engine
│   │   ├── budget/         # AI budget analysis
│   │   └── chat/           # Conversational AI assistant (streaming)
│   └── notifications/      # Thông báo in-app, push notification
├── common/
│   ├── decorators/         # @CurrentUser, @GroupRole, @Roles
│   ├── filters/            # Global exception filter (chuẩn hóa error response)
│   ├── guards/             # JwtAuthGuard, GroupRoleGuard
│   ├── interceptors/       # ResponseInterceptor (chuẩn hóa success response)
│   └── pipes/              # ValidationPipe, ParseUUIDPipe
├── config/                 # NestJS ConfigModule: DB, JWT, OAuth, OpenAI, Redis, S3
├── database/               # PrismaService, migrations, seed
├── queue/                  # BullMQ queues: ai-planning, ai-recommendation, notifications
├── realtime/               # Socket.IO gateway, room management, event emitters
├── app.module.ts
└── main.ts
```

**Mô tả trách nhiệm:**

- **`modules/`**: Mỗi module encapsulate toàn bộ Controller, Service và DTO của một domain nghiệp vụ.
- **`modules/ai/`**: Tách riêng toàn bộ AI logic để dễ swap provider (OpenAI → Gemini) mà không ảnh hưởng phần còn lại.
- **`queue/`**: AI planning và recommendation chạy async qua BullMQ để không block API request chính.
- **`realtime/`**: Socket.IO Gateway xử lý WebSocket events (expense_created, vote_updated, itinerary_updated...).
- **`common/`**: Cross-cutting concerns tập trung, giữ Controller/Service tập trung vào business logic.

---

## 3. AI Components

### 3.1. Planning Engine (AI Itinerary Generation)
- **Trigger**: User gọi `POST /ai/generate-itinerary` → tạo BullMQ job.
- **Flow**: Job worker gọi LangChain → OpenAI GPT-4o với structured output → parse JSON → lưu vào `itineraries` + `itinerary_items`.
- **Response**: API trả `jobId` ngay lập tức. Client polling `GET /ai/itinerary-jobs/:jobId` hoặc nhận WebSocket event `itinerary_generated`.

### 3.2. Recommendation Engine (AI Restaurant / Activity)
- **Scoring**: Mỗi gợi ý được AI đánh giá theo 4 tiêu chí: `budget_fit`, `preference_match`, `weather_relevance`, `popularity`.
- **Context**: AI nhận context gồm group size, budget, mood, location, lịch sử vote của nhóm.
- **Dedup**: Dùng `place_id` (Google Maps) làm định danh tránh recommend trùng địa điểm.

### 3.3. Budget Intelligence
- Phân tích tổng chi tiêu hiện tại so với `target_budget` của group.
- Detect category nào đang vượt ngân sách.
- Generate insight text: *"Ăn uống chiếm 60% ngân sách (vượt kế hoạch 25%)."*

### 3.4. Conversational Assistant
- LangChain ConversationChain với memory (lưu trong `ai_chat_messages`).
- Context injection: khi chat trong ngữ cảnh nhóm, AI nhận summary về expenses, lịch trình hiện tại.
- Streaming response qua SSE hoặc WebSocket.

---

## 4. Realtime Architecture

```text
Client ──WebSocket──► Socket.IO Gateway
                           │
                    Redis Pub/Sub (adapter)
                           │
               ┌───────────┴───────────┐
           Instance 1             Instance 2
```

**Events hỗ trợ:**

| Event | Trigger |
|---|---|
| `expense:created` | Thêm chi tiêu mới |
| `expense:updated` | Sửa chi tiêu |
| `balance:updated` | Sau mỗi expense / settlement |
| `itinerary:updated` | Sửa lịch trình |
| `recommendation:new` | AI generate gợi ý xong |
| `vote:updated` | Thành viên vote |
| `poll:closed` | Poll kết thúc |
| `notification:new` | Thông báo mới |
| `member:joined` | Thành viên mới tham gia |

---

## 5. Frontend Architecture (React / Next.js)

```text
src/
├── app/                    # Next.js App Router
│   ├── (auth)/             # Login, Register
│   ├── dashboard/          # Tổng quan nhóm + số dư
│   ├── groups/
│   │   ├── [groupId]/
│   │   │   ├── expenses/   # Danh sách + thêm chi tiêu
│   │   │   ├── balances/   # Công nợ + settlement
│   │   │   ├── itinerary/  # Lịch trình
│   │   │   ├── recommend/  # AI gợi ý + vote
│   │   │   └── settings/   # Cài đặt nhóm
│   └── ai-chat/            # AI Smart Assistant
├── features/               # Logic + UI theo từng domain
│   ├── auth/
│   ├── groups/
│   ├── expenses/
│   ├── itinerary/
│   ├── recommendations/
│   └── ai-chat/
├── components/             # Shared UI components (Button, Modal, Card...)
├── hooks/                  # useAuth, useWebSocket, useGroupBalance
├── services/               # Axios client, API functions
├── store/                  # Zustand global state
└── utils/                  # formatCurrency, formatDate, debtSimplification
```

---

## 6. Algorithms

### 6.1. Debt Simplification
**Bài toán**: Giảm thiểu số giao dịch chuyển khoản giữa N người.

**Kỹ thuật**: Greedy Algorithm trên Directed Graph:
1. Tính net balance của mỗi thành viên (tổng đã trả − tổng phải trả).
2. Tách danh sách người "dư" (creditors) và "thiếu" (debtors).
3. Greedy: lấy người dư nhiều nhất và người thiếu nhiều nhất, khớp giao dịch, repeat.

**Kết quả**: Từ O(N²) giao dịch xuống còn tối đa N-1 giao dịch.

### 6.2. Recommendation Scoring
```
total_score = 0.35 × budget_fit
            + 0.30 × preference_match
            + 0.20 × weather_relevance
            + 0.15 × popularity
```

---

## 7. MVP Scope

| Priority | Tính năng |
|---|---|
| **P0 – Blocker** | Auth (Local), Group Workspace, Expense + Equal Split, Debt Simplification, Realtime balance update |
| **P1 – Core** | Google OAuth2, Custom Split, Settlement recording, AI Restaurant Recommendation, AI Itinerary Generation, Voting |
| **P2 – Enhanced** | AI Budget Assistant, AI Chat, Activity Logs, File Upload (receipt, avatar) |

---

## 8. Development Roadmap

### Phase 1: Core Foundation (3 tuần) — P0
- Khởi tạo NestJS + Prisma + PostgreSQL + Redis.
- Auth Local (register/login/JWT/refresh).
- Group CRUD + thành viên + lời mời qua email.
- Expense + Equal/Custom Split.
- Debt Simplification algorithm.
- WebSocket realtime: balance update.

### Phase 2: AI Features (3 tuần) — P1
- Google OAuth2.
- BullMQ job queue cho AI processing.
- AI Restaurant Recommendation Engine (LangChain + OpenAI).
- AI Itinerary Generation.
- Voting system (RecommendationVote + Poll).
- Settlement recording.
- Redis caching cho balances.

### Phase 3: Intelligence & Collaboration (3 tuần) — P2
- AI Budget Assistant.
- AI Conversational Chat (streaming).
- Activity Logs + Notifications.
- File Upload (AWS S3): avatar, receipt, group cover.
- Google Maps integration cho ItineraryItem.

### Phase 4: Polish & Production (2 tuần)
- Docker + Nginx setup.
- CI/CD pipeline (GitHub Actions).
- Sentry error tracking.
- Rate limiting + security hardening.
- Performance testing + optimization.

---

## 9. Technical Challenges

| Thách thức | Hướng giải quyết |
|---|---|
| **Sai số tiền tệ** | Lưu integer (VND nguyên, Cents), không dùng Float. Frontend format hiển thị. |
| **AI Latency** | Xử lý async qua BullMQ, client nhận kết quả qua WebSocket event. |
| **Debt algorithm phức tạp** | UI giải thích rõ lý do giao dịch: "A trả thẳng C vì tối ưu hóa nợ dây chuyền". |
| **Balance consistency** | Cập nhật `balances` cache delta mỗi khi có expense/settlement thay vì recalculate toàn bộ. |
| **Multi-instance WebSocket** | Socket.IO Redis Adapter để broadcast event qua tất cả backend instances. |
| **Prompt injection** | Sanitize user input trước khi đưa vào LLM context. Không truyền dữ liệu nhạy cảm. |
| **AI cost control** | Token budget per request, daily cost monitoring qua OpenAI usage API. |

---

## 10. Future Enhancements

- **Microservices**: Tách Notification service và AI service thành microservice độc lập.
- **Multi-currency**: Auto convert tỷ giá khi đi nước ngoài.
- **OCR Receipt Scanning**: Chụp hóa đơn, AI tự nhận diện món và chia tiền.
- **Payment Integration**: QR code thanh toán, tích hợp cổng thanh toán nội địa.
- **Offline PWA**: Ghi chi tiêu offline, tự sync khi có mạng trở lại.
- **Analytics Dashboard**: Biểu đồ chi tiêu theo category, thành viên, thời gian.
- **AI Memory**: Lưu long-term preference của nhóm để recommendation ngày càng chính xác hơn.

Hệ thống Backend được thiết kế theo framework NestJS, tuân thủ Clean Architecture và Module-driven development.

```text
src/
├── modules/          # Chứa các feature module (users, groups, expenses, auth, settlements)
│   ├── expenses/
│   │   ├── dto/      # Data Transfer Objects (Validation rules)
│   │   ├── expenses.controller.ts
│   │   ├── expenses.service.ts
│   │   ├── expenses.module.ts
├── common/           # Chứa các component dùng chung toàn hệ thống
│   ├── decorators/   # Custom decorators (vd: @CurrentUser)
│   ├── filters/      # Global Exception filters (Xử lý lỗi tập trung)
│   ├── guards/       # Auth/Role Guards (JWT Guard, Group Role Guard)
│   ├── interceptors/ # Response interceptors (Chuẩn hóa cấu trúc API response)
├── config/           # Cấu hình hệ thống (Environment, JWT secret, OAuth keys)
├── database/         # Prisma service, schema, migrations và seed data
├── app.module.ts     # Root module
└── main.ts           # Entry point
```

**Mô tả trách nhiệm:**
- **`modules/`**: Phân tách logic theo domain nghiệp vụ. Mỗi module độc lập, quản lý Controller và Service riêng.
- **`common/`**: Xử lý cross-cutting concerns (xác thực, logging, định dạng lỗi) để giữ cho Controller và Service luôn tập trung vào business logic.
- **`database/`**: Quản lý Prisma Client, đảm bảo khởi tạo duy nhất một instance kết nối DB xuyên suốt ứng dụng.

---

## 13. Frontend Architecture (React / Next.js)

Giao diện (Client) sử dụng React với cấu trúc phân chia theo Feature-Sliced Design (hoặc biến thể dựa trên tính năng).

```text
src/
├── pages/            # (Hoặc app/ nếu dùng Next App Router) - Định tuyến các màn hình
├── features/         # Logic và UI đặc thù cho từng tính năng (auth, expenses, groups)
│   ├── groups/
│   │   ├── components/  # GroupCard, GroupList
│   │   ├── hooks/       # useGroupDetails, useCreateGroup
│   │   ├── api/         # Các hàm gọi API liên quan tới group
├── components/       # UI Components chung (Button, Modal, Input, Layout)
├── hooks/            # Custom hooks dùng chung (useAuth, useTheme)
├── services/         # Axios config, Interceptors, Base API client
├── store/            # Global state management (Zustand hoặc Redux)
└── utils/            # Helper functions (formatCurrency, formatDate)
```

**Mô tả trách nhiệm:**
- **`features/`**: Gom nhóm code theo tính năng (domain) thay vì loại file. Giúp code dễ scale, dễ maintain và tránh tình trạng phình to thư mục chung.
- **`pages/`**: Nơi import và ghép các features lại thành một màn hình định tuyến hoàn chỉnh.
- **`components/`**: Các "dumb component" tái sử dụng, chỉ nhận props và render UI.

---

## 14. Screens & UI Flow

Danh sách các màn hình (Screens) chính và luồng trải nghiệm:

### 1. Login / Register
- **Mục đích**: Người dùng đăng nhập/đăng ký hoặc xác thực qua Google.
- **Thành phần UI**: Email/Password Form, Nút "Login with Google", Liên kết Quên mật khẩu.
- **API sử dụng**: `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/google`.

### 2. Dashboard (Home)
- **Mục đích**: Hiển thị tổng quan các nhóm đang tham gia và tổng dư nợ ròng của user.
- **Thành phần UI**: Danh sách Group (GroupCard), Tổng tiền đang nợ / Tổng tiền người khác nợ, Thông báo mới nhất. Nút "Tạo nhóm mới".
- **API sử dụng**: `GET /api/groups`, `GET /api/users/me/balances`.

### 3. Group Detail Page
- **Mục đích**: Không gian làm việc chính của một nhóm chi tiêu.
- **Thành phần UI**: 
  - Header (Tên nhóm, Tổng chi tiêu, Thành viên).
  - Tab 1: Danh sách chi tiêu (Expenses List).
  - Tab 2: Công nợ tổng hợp (Balances - Ai nợ ai).
  - Nút FAB (Floating Action Button): "Thêm chi tiêu".
- **API sử dụng**: `GET /api/groups/:groupId`, `GET /api/groups/:groupId/expenses`, `GET /api/groups/:groupId/balances`.

### 4. Create / Edit Expense Modal
- **Mục đích**: Thêm mới hoặc sửa một khoản chi.
- **Thành phần UI**: Input Tên khoản chi, Input Số tiền, Dropdown chọn người trả tiền, Danh sách chọn cách chia (Chia đều / Nhập số tiền tùy chỉnh).
- **API sử dụng**: `POST /api/groups/:groupId/expenses`, `PUT /api/groups/:groupId/expenses/:expenseId`.

### 5. Settings / Profile
- **Mục đích**: Quản lý thông tin cá nhân và thiết lập ứng dụng.
- **Thành phần UI**: Form cập nhật tên hiển thị, Avatar, Đổi mật khẩu, Cài đặt nhận thông báo.
- **API sử dụng**: `GET /api/users/me`, `PUT /api/users/me/profile`.

---

## 15. MVP Scope

Phạm vi của phiên bản Minimum Viable Product (MVP), ưu tiên các tính năng mang lại giá trị cốt lõi.

- **[P0] Bắt buộc (Blocker nếu thiếu)**:
  - Xác thực cơ bản (Local Email/Password).
  - Tạo nhóm và thêm thành viên (qua email).
  - Thêm khoản chi tiêu và chia đều (Equal Split).
  - Xem danh sách chi tiêu trong nhóm.
  - Tính toán và hiển thị công nợ cơ bản (Ai nợ ai tổng cộng).

- **[P1] Quan trọng (Cần thiết cho trải nghiệm hoàn thiện)**:
  - Đăng nhập bằng Google (OAuth2).
  - Chia tiền tùy chỉnh (Custom Split Amount).
  - Ghi nhận thanh toán thủ công (Record Settlement) để xóa nợ.
  - Thuật toán gợi ý tối giản hóa công nợ (Debt Simplification).

- **[P2] Có thì tốt (Nice to have)**:
  - Cập nhật Avatar nhóm và cá nhân.
  - Lịch sử hoạt động nhóm (Activity Logs).

---

## 16. Future Enhancements

Những tính năng có thể mở rộng sau khi hoàn thành MVP:
- **Hỗ trợ đa tiền tệ (Multi-currency)**: Tự động chuyển đổi tỷ giá khi đi du lịch nước ngoài.
- **Push Notification & Email Alerts**: Tự động nhắc nợ hoặc gửi thông báo khi có khoản chi mới.
- **Quét hóa đơn AI (OCR)**: Chụp ảnh hóa đơn nhà hàng, tự động nhận diện món ăn để chia tiền chính xác cho từng người.
- **Phân tích biểu đồ (Analytics)**: Biểu đồ thống kê chi tiêu theo Category (Ví dụ: Ăn uống, Di chuyển).
- **Export Data**: Xuất báo cáo công nợ ra file Excel/PDF.

---

## 17. Technical Challenges

Dự án có nhiều bài toán kỹ thuật thực tế rất đáng học hỏi:
- **Algorithm (Thuật toán)**: Giải quyết bài toán tối giản hóa công nợ bằng đồ thị có hướng (Directed Graph) sử dụng Greedy Algorithm để giảm thiểu số lượt chuyển khoản.
- **Caching**: Ứng dụng Redis để cache danh sách chi tiêu và công nợ nhóm, giúp dashboard tải siêu nhanh.
- **WebSocket**: Cập nhật Real-time. Khi một người thêm khoản chi mới, ứng dụng của các thành viên khác sẽ nảy số dư lập tức mà không cần F5.
- **File Upload**: Tích hợp cloud storage (AWS S3, Cloudinary) để xử lý ảnh avatar, cover nhóm và bill.
- **Event Driven**: Dùng Event Emitter hoặc Message Queue (RabbitMQ) xử lý logic nền (Ví dụ: Bắn event `ExpenseCreated` -> Worker nền sẽ tính toán lại số dư và đẩy thông báo).
- **Cron Job**: Lập lịch tự động gửi email "Tổng kết công nợ hàng tuần" vào thứ 2.
- **Rate Limiting**: Áp dụng giới hạn request để bảo vệ API đăng nhập/đăng ký khỏi Brute-force attack.

---

## 18. Development Roadmap

Lộ trình phát triển chia thành 3 phase:

### Phase 1: Core Foundation (MVP P0)
- **Chức năng**: Khởi tạo kiến trúc DB, Prisma, NestJS, React. Triển khai Auth Local, Tạo nhóm, Thêm chi tiêu (chia đều), Tính số dư.
- **Thời gian dự kiến**: 3 Tuần.
- **Độ ưu tiên**: **Cao (High)**.

### Phase 2: Advanced Mechanics & OAuth (MVP P1)
- **Chức năng**: Tích hợp Google OAuth2, Chế độ chia tiền Custom, Thuật toán tối giản công nợ, Ghi nhận Settlement, Redis Caching.
- **Thời gian dự kiến**: 3 Tuần.
- **Độ ưu tiên**: **Cao (High)**.

### Phase 3: Real-time & Polish (MVP P2 & Post-MVP)
- **Chức năng**: Tích hợp WebSocket, Activity Logs, Upload file S3, Lập lịch Cron Job và tối ưu hóa UI/UX.
- **Thời gian dự kiến**: 4 Tuần.
- **Độ ưu tiên**: **Trung bình (Medium)**.

---

## 19. Risks & Improvements

### Rủi ro thiết kế (Design Risks)
- **Sai số dữ liệu tài chính**: Xử lý số thập phân ở Frontend, Backend và DB có thể dẫn đến lệch kết quả (Ví dụ 100/3).
  - *Hướng giải quyết*: Chuẩn hóa lưu trữ dưới dạng số nguyên (smallest currency unit - ví dụ Cents/VND nguyên) tại DB. Hệ thống chỉ xử lý số nguyên, Frontend format lại khi hiển thị.
- **Thuật toán nợ phức tạp**: Tối giản nợ có thể cho ra kết quả khó hiểu (A nợ B, nhưng hệ thống lại bảo A chuyển tiền cho C).
  - *Hướng giải quyết*: Giao diện cần bổ sung phần giải thích rõ ràng "Vì sao bạn nên thanh toán cho người này" để tạo sự tin tưởng.

### Điểm nghẽn hiệu năng (Bottlenecks)
- **Tính toán Balance liên tục**: Khi một nhóm có hàng trăm khoản chi, việc phải duyệt lại toàn bộ `expenses` và `splits` mỗi lần user xem nhóm sẽ gây quá tải Database.
  - *Hướng giải quyết*: Sử dụng bảng Materialized View cho Balance hoặc lưu Cache trong Redis. Mỗi khi có expense mới, chỉ update delta (+/-) vào Cache thay vì quét lại toàn bộ.

### Hướng cải tiến trong tương lai
- **Kiến trúc Microservices**: Khi mở rộng quy mô, có thể bóc tách dịch vụ Notification (Thông báo) và Report (Báo cáo) thành các service chạy độc lập để không làm chậm Core API.
- **Offline First (PWA)**: Hỗ trợ người dùng ghi nhận khoản chi ngay cả khi mất kết nối mạng (thường gặp khi đi phượt rừng núi), tự động đồng bộ (sync) lên server khi có mạng trở lại thông qua Service Worker.
