# Prisma Schema & REST API

## 1. Prisma Schema

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────

enum SystemRole {
  USER
  ADMIN
}

enum UserStatus {
  ACTIVE
  INACTIVE
  BANNED
}

enum GroupRole {
  OWNER
  MEMBER
}

enum EventType {
  TRIP
  WORKSHOP
  PARTY
  HACKATHON
  OTHER
}

enum InvitationStatus {
  PENDING
  ACCEPTED
  EXPIRED
}

enum RecommendationType {
  RESTAURANT
  ACTIVITY
  ACCOMMODATION
}

enum VoteType {
  UP
  DOWN
}

enum PollStatus {
  OPEN
  CLOSED
}

enum ItineraryItemCategory {
  MEAL
  TRANSPORT
  ACTIVITY
  ACCOMMODATION
  OTHER
}

enum ActionType {
  CREATE
  UPDATE
  DELETE
}

enum FundingSource {
  GROUP_FUND
  PERSONAL
}

enum EntityType {
  EXPENSE
  MEMBER
  SETTLEMENT
  ITINERARY
  ITINERARY_ITEM
  RECOMMENDATION
  POLL
}

enum ChatRole {
  USER
  ASSISTANT
}

// ─────────────────────────────────────────────
// AUTH & USER
// ─────────────────────────────────────────────

model User {
  id            String      @id @default(uuid())
  email         String      @unique
  emailVerified DateTime?
  systemRole    SystemRole  @default(USER)
  status        UserStatus  @default(ACTIVE)
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt

  profile            UserProfile?
  settings           UserSettings?
  accounts           UserAccount[]
  sessions           Session[]
  groupMembers       GroupMember[]
  groupInvitations   GroupInvitation[]   @relation("InvitedBy")
  expensesPaid       Expense[]           @relation("PaidBy")
  expenseSplits      ExpenseSplit[]
  settlementsMade    Settlement[]        @relation("SettlementFrom")
  settlementsReceived Settlement[]       @relation("SettlementTo")
  recommendationVotes RecommendationVote[]
  pollVotes          PollVote[]
  itineraryItems     ItineraryItem[]
  aiChatSessions     AiChatSession[]
  notifications      Notification[]
  activityLogs       ActivityLog[]
}

model UserProfile {
  id          String  @id @default(uuid())
  displayName String
  avatarUrl   String?
  phoneNumber String?

  user        User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId      String  @unique
}

model UserAccount {
  id                String  @id @default(uuid())
  provider          String  // "LOCAL" | "GOOGLE" | "FACEBOOK"
  providerAccountId String
  passwordHash      String?
  accessToken       String?
  refreshToken      String?
  expiresAt         Int?

  user              User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId            String

  @@unique([provider, providerAccountId])
}

model Session {
  id           String   @id @default(uuid())
  sessionToken String   @unique
  expires      DateTime

  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId       String
}

model UserSettings {
  id                      String  @id @default(uuid())
  notificationPreferences Json?
  defaultCurrency         String  @default("VND")

  user                    User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId                  String  @unique
}

// ─────────────────────────────────────────────
// GROUP WORKSPACE
// ─────────────────────────────────────────────

model Group {
  id             String     @id @default(uuid())
  name           String
  description    String?
  coverImageUrl  String?
  eventType      EventType  @default(OTHER)
  eventDateStart DateTime?
  eventDateEnd   DateTime?
  targetBudget   Int?       // stored as smallest currency unit (e.g. VND)
  fundBalance    Int        @default(0) // actual money collected
  currency       String     @default("VND")
  createdBy      String
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt

  members         GroupMember[]
  invitations     GroupInvitation[]
  expenses        Expense[]
  settlements     Settlement[]
  balances        Balance[]
  itineraries     Itinerary[]
  recommendations Recommendation[]
  polls           Poll[]
  aiChatSessions  AiChatSession[]
  activityLogs    ActivityLog[]
}

model GroupMember {
  id       String    @id @default(uuid())
  role     GroupRole @default(MEMBER)
  joinedAt DateTime  @default(now())

  user     User      @relation(fields: [userId], references: [id])
  userId   String
  group    Group     @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId  String

  @@unique([userId, groupId])
}

model GroupInvitation {
  id           String           @id @default(uuid())
  invitedEmail String
  status       InvitationStatus @default(PENDING)
  token        String           @unique
  expiresAt    DateTime

  group        Group            @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId      String
  invitedBy    User             @relation("InvitedBy", fields: [invitedById], references: [id])
  invitedById  String
  createdAt    DateTime         @default(now())
}

// ─────────────────────────────────────────────
// EXPENSE & DEBT
// ─────────────────────────────────────────────

model Category {
  id       String    @id @default(uuid())
  name     String    @unique
  icon     String?
  color    String?
  expenses Expense[]
}

model Expense {
  id            String        @id @default(uuid())
  title         String
  description   String?
  amount        Int           // smallest currency unit
  currency      String        @default("VND")
  fundingSource FundingSource @default(PERSONAL)
  expenseDate   DateTime      @default(now())
  receiptUrl    String?
  deletedAt     DateTime?     // soft delete

  group       Group     @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId     String
  paidBy      User      @relation("PaidBy", fields: [paidById], references: [id])
  paidById    String
  category    Category? @relation(fields: [categoryId], references: [id])
  categoryId  String?

  splits      ExpenseSplit[]
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
}

model ExpenseSplit {
  id         String   @id @default(uuid())
  amountOwed Int      // smallest currency unit
  isSettled  Boolean  @default(false)

  expense    Expense  @relation(fields: [expenseId], references: [id], onDelete: Cascade)
  expenseId  String
  user       User     @relation(fields: [userId], references: [id])
  userId     String
}

model Settlement {
  id         String   @id @default(uuid())
  amount     Int      // smallest currency unit
  note       String?
  settledAt  DateTime @default(now())
  createdAt  DateTime @default(now())

  group      Group    @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId    String
  fromUser   User     @relation("SettlementFrom", fields: [fromUserId], references: [id])
  fromUserId String
  toUser     User     @relation("SettlementTo", fields: [toUserId], references: [id])
  toUserId   String
}

model Balance {
  netBalance Int      // can be negative

  group      Group    @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId    String
  user       User     @relation(fields: [userId], references: [id])
  userId     String
  updatedAt  DateTime @updatedAt

  @@id([groupId, userId])
}

// ─────────────────────────────────────────────
// ITINERARY
// ─────────────────────────────────────────────

model Itinerary {
  id             String   @id @default(uuid())
  title          String
  description    String?
  generatedByAi  Boolean  @default(false)
  aiPromptUsed   String?
  createdBy      String
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt

  group          Group    @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId        String
  items          ItineraryItem[]
}

model ItineraryItem {
  id              String                @id @default(uuid())
  dayNumber       Int
  startTime       String?               // "08:00"
  endTime         String?               // "10:00"
  title           String
  description     String?
  locationName    String?
  locationAddress String?
  locationLat     Float?
  locationLng     Float?
  placeId         String?               // Google Maps Place ID
  category        ItineraryItemCategory @default(ACTIVITY)
  estimatedCost   Int?                  // smallest currency unit
  orderIndex      Int                   @default(0)
  deletedAt       DateTime?             // soft delete
  createdAt       DateTime              @default(now())
  updatedAt       DateTime              @updatedAt

  itinerary       Itinerary             @relation(fields: [itineraryId], references: [id], onDelete: Cascade)
  itineraryId     String
  createdByUser   User                  @relation(fields: [createdBy], references: [id])
  createdBy       String
}

// ─────────────────────────────────────────────
// AI RECOMMENDATIONS
// ─────────────────────────────────────────────

model Recommendation {
  id                    String             @id @default(uuid())
  type                  RecommendationType
  name                  String
  description           String?
  locationAddress       String?
  locationLat           Float?
  locationLng           Float?
  placeId               String?
  priceRange            String?            // "50k-150k/người"
  tags                  Json?              // ["lẩu", "indoor", "nhóm đông"]
  aiReason              String?
  scoreBudgetFit        Float?
  scorePreferenceMatch  Float?
  scoreWeatherRelevance Float?
  scorePopularity       Float?
  totalScore            Float?
  generatedAt           DateTime           @default(now())
  createdAt             DateTime           @default(now())

  group                 Group              @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId               String
  votes                 RecommendationVote[]
}

model RecommendationVote {
  id               String         @id @default(uuid())
  vote             VoteType
  createdAt        DateTime       @default(now())

  recommendation   Recommendation @relation(fields: [recommendationId], references: [id], onDelete: Cascade)
  recommendationId String
  user             User           @relation(fields: [userId], references: [id])
  userId           String

  @@unique([recommendationId, userId])
}

// ─────────────────────────────────────────────
// VOTING & POLLS
// ─────────────────────────────────────────────

model Poll {
  id        String     @id @default(uuid())
  question  String
  status    PollStatus @default(OPEN)
  endsAt    DateTime?
  createdBy String
  createdAt DateTime   @default(now())

  group     Group      @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId   String
  options   PollOption[]
}

model PollOption {
  id                   String          @id @default(uuid())
  text                 String
  linkedRecommendation String?         // optional link to recommendation id

  poll                 Poll            @relation(fields: [pollId], references: [id], onDelete: Cascade)
  pollId               String
  votes                PollVote[]
}

model PollVote {
  id           String     @id @default(uuid())
  createdAt    DateTime   @default(now())

  option       PollOption @relation(fields: [optionId], references: [id], onDelete: Cascade)
  optionId     String
  user         User       @relation(fields: [userId], references: [id])
  userId       String

  @@unique([optionId, userId])
}

// ─────────────────────────────────────────────
// AI CHAT ASSISTANT
// ─────────────────────────────────────────────

model AiChatSession {
  id        String   @id @default(uuid())
  title     String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId    String
  group     Group?   @relation(fields: [groupId], references: [id], onDelete: SetNull)
  groupId   String?

  messages  AiChatMessage[]
}

model AiChatMessage {
  id         String       @id @default(uuid())
  role       ChatRole
  content    String
  tokenCount Int?
  createdAt  DateTime     @default(now())

  session    AiChatSession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  sessionId  String
}

// ─────────────────────────────────────────────
// SYSTEM & AUDIT
// ─────────────────────────────────────────────

model ActivityLog {
  id         String     @id @default(uuid())
  actionType ActionType
  entityType EntityType
  entityId   String
  oldData    Json?
  newData    Json?
  createdAt  DateTime   @default(now())

  group      Group      @relation(fields: [groupId], references: [id], onDelete: Cascade)
  groupId    String
  user       User       @relation(fields: [userId], references: [id])
  userId     String
}

model Notification {
  id        String   @id @default(uuid())
  type      String
  title     String
  message   String
  payload   Json?
  isRead    Boolean  @default(false)
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId    String
}
```

---

## 2. REST API Endpoints

### 2.1. Authentication

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| POST | `/api/auth/register` | Đăng ký tài khoản Local | ❌ |
| POST | `/api/auth/login` | Đăng nhập Email/Password | ❌ |
| GET | `/api/auth/google` | Redirect sang Google OAuth2 | ❌ |
| GET | `/api/auth/google/callback` | Callback từ Google | ❌ |
| POST | `/api/auth/refresh` | Refresh Access Token | ❌ |
| POST | `/api/auth/logout` | Đăng xuất, xóa session | ✅ |

### 2.2. Users & Profiles

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/users/me` | Lấy thông tin user hiện tại (+ profile) | ✅ |
| PUT | `/api/users/me/profile` | Cập nhật UserProfile | ✅ |
| PUT | `/api/users/me/settings` | Cập nhật UserSettings | ✅ |
| GET | `/api/users/me/notifications` | Lấy danh sách thông báo | ✅ |
| PATCH | `/api/users/me/notifications/:id/read` | Đánh dấu thông báo đã đọc | ✅ |

### 2.3. Groups

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/groups` | Danh sách nhóm của user | ✅ |
| POST | `/api/groups` | Tạo nhóm mới | ✅ |
| GET | `/api/groups/:groupId` | Chi tiết nhóm | Member |
| PUT | `/api/groups/:groupId` | Cập nhật thông tin nhóm | Owner |
| DELETE | `/api/groups/:groupId` | Xóa nhóm | Owner |

### 2.4. Members

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| POST | `/api/groups/:groupId/invitations` | Mời thành viên qua email | Owner |
| GET | `/api/groups/:groupId/invitations` | Danh sách lời mời đang mở | Owner |
| POST | `/api/invitations/:token/accept` | Chấp nhận lời mời | User |
| DELETE | `/api/groups/:groupId/members/:userId` | Xóa thành viên | Owner |
| PATCH | `/api/groups/:groupId/members/:userId/transfer-ownership` | Chuyển quyền Owner | Owner |
| DELETE | `/api/groups/:groupId/members/me` | Rời khỏi nhóm | Member |

### 2.5. Expenses

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/groups/:groupId/expenses` | Danh sách chi tiêu (có filter/pagination) | Member |
| POST | `/api/groups/:groupId/expenses` | Thêm khoản chi | Member |
| GET | `/api/groups/:groupId/expenses/:expenseId` | Chi tiết khoản chi | Member |
| PUT | `/api/groups/:groupId/expenses/:expenseId` | Sửa khoản chi | Owner of expense |
| DELETE | `/api/groups/:groupId/expenses/:expenseId` | Xóa khoản chi (soft delete) | Owner of expense |
| GET | `/api/categories` | Danh sách category chi tiêu | ✅ |

### 2.6. Settlements & Balances

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/groups/:groupId/balances` | Số dư ròng của từng thành viên | Member |
| GET | `/api/groups/:groupId/settlement-suggestions` | Gợi ý thanh toán tối giản | Member |
| POST | `/api/groups/:groupId/settlements` | Ghi nhận đã thanh toán nợ | Member |
| GET | `/api/groups/:groupId/settlements` | Lịch sử thanh toán | Member |

### 2.7. Itinerary

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/groups/:groupId/itineraries` | Danh sách lịch trình | Member |
| POST | `/api/groups/:groupId/itineraries` | Tạo lịch trình thủ công | Member |
| GET | `/api/groups/:groupId/itineraries/:itineraryId` | Chi tiết lịch trình | Member |
| PUT | `/api/groups/:groupId/itineraries/:itineraryId` | Cập nhật lịch trình | Member |
| DELETE | `/api/groups/:groupId/itineraries/:itineraryId` | Xóa lịch trình | Owner |
| POST | `/api/groups/:groupId/itineraries/:itineraryId/items` | Thêm activity | Member |
| PUT | `/api/groups/:groupId/itineraries/:itineraryId/items/:itemId` | Sửa activity | Creator |
| DELETE | `/api/groups/:groupId/itineraries/:itineraryId/items/:itemId` | Xóa activity | Creator |

### 2.8. AI – Event Planning

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| POST | `/api/groups/:groupId/ai/generate-itinerary` | AI generate lịch trình từ prompt | Member |
| GET | `/api/groups/:groupId/ai/itinerary-jobs/:jobId` | Kiểm tra trạng thái job AI | Member |
| POST | `/api/groups/:groupId/ai/budget-analysis` | AI phân tích ngân sách nhóm | Member |

**Body ví dụ `generate-itinerary`:**
```json
{
  "prompt": "Trip Đà Nẵng 3 ngày cho 6 người, budget 5 triệu/người",
  "numberOfDays": 3,
  "groupSize": 6,
  "budgetPerPerson": 5000000
}
```

### 2.9. AI – Recommendations

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| POST | `/api/groups/:groupId/ai/recommendations` | AI gợi ý địa điểm / quán ăn | Member |
| GET | `/api/groups/:groupId/recommendations` | Lấy danh sách gợi ý đã generate | Member |
| POST | `/api/groups/:groupId/recommendations/:recommendationId/vote` | Vote cho gợi ý | Member |
| DELETE | `/api/groups/:groupId/recommendations/:recommendationId/vote` | Hủy vote | Member |

**Body ví dụ `ai/recommendations`:**
```json
{
  "type": "RESTAURANT",
  "groupSize": 5,
  "budgetPerPerson": 150000,
  "mood": "rainy",
  "location": { "lat": 16.047, "lng": 108.206 }
}
```

### 2.10. Polls & Voting

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/groups/:groupId/polls` | Danh sách poll | Member |
| POST | `/api/groups/:groupId/polls` | Tạo poll | Member |
| GET | `/api/groups/:groupId/polls/:pollId` | Chi tiết poll + kết quả | Member |
| PATCH | `/api/groups/:groupId/polls/:pollId/close` | Đóng poll | Owner |
| POST | `/api/groups/:groupId/polls/:pollId/vote` | Vote cho một option | Member |

### 2.11. AI Chat Assistant

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/ai/chat/sessions` | Danh sách phiên chat | ✅ |
| POST | `/api/ai/chat/sessions` | Tạo phiên chat mới | ✅ |
| GET | `/api/ai/chat/sessions/:sessionId/messages` | Lịch sử tin nhắn | ✅ |
| POST | `/api/ai/chat/sessions/:sessionId/messages` | Gửi tin nhắn, nhận trả lời (stream) | ✅ |

### 2.12. Activity Logs

| Method | Endpoint | Mô tả | Auth |
|---|---|---|---|
| GET | `/api/groups/:groupId/activity` | Lịch sử hoạt động nhóm (paginated) | Member |

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum SystemRole {
  USER
  ADMIN
}

model User {
  id            String      @id @default(uuid())
  email         String      @unique
  emailVerified DateTime?
  systemRole    SystemRole  @default(USER)
  status        String      @default("ACTIVE") // ACTIVE, INACTIVE, BANNED
  createdAt     DateTime    @default(now())
  updatedAt     DateTime  @updatedAt

  // Quan hệ 1-1
  profile       UserProfile?
  settings      UserSettings?
  
  // Quan hệ 1-N (Auth)
  accounts      UserAccount[]
  sessions      Session[]

  // Quan hệ 1-N (Nghiệp vụ)
  groupMembers  GroupMember[]
  expensesPaid  Expense[]      @relation("PaidBy")
  expenseSplits ExpenseSplit[]
  settlementsMade Settlement[]   @relation("SettlementFrom")
  settlementsRcvd Settlement[]   @relation("SettlementTo")
}

model UserProfile {
  id          String   @id @default(uuid())
  displayName String
  avatarUrl   String?
  phoneNumber String?
  
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId      String   @unique
}

model UserAccount {
  id                String   @id @default(uuid())
  provider          String   // "LOCAL", "GOOGLE", "FACEBOOK", v.v.
  providerAccountId String   // ID trả về từ Google/Facebook (nếu có)
  passwordHash      String?  // Dành cho provider="LOCAL"
  accessToken       String?
  refreshToken      String?
  expiresAt         Int?

  user              User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId            String

  @@unique([provider, providerAccountId])
}

model Session {
  id           String   @id @default(uuid())
  sessionToken String   @unique
  expires      DateTime

  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId       String
}

model UserSettings {
  id                      String  @id @default(uuid())
  notificationPreferences Json?
  defaultCurrency         String  @default("VND")

  user                    User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId                  String  @unique
}

model Group {
  id          String        @id @default(uuid())
  name        String
  description String?
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt

  members     GroupMember[]
  expenses    Expense[]
  settlements Settlement[]
}

model GroupMember {
  id       String     @id @default(uuid())
  role     GroupRole  @default(MEMBER)
  joinedAt DateTime   @default(now())

  user     User     @relation(fields: [userId], references: [id])
  userId   String
  group    Group    @relation(fields: [groupId], references: [id])
  groupId  String

  @@unique([userId, groupId])
}

enum GroupRole {
  OWNER
  MEMBER
}

model Expense {
  id          String         @id @default(uuid())
  title       String
  amount      Float
  date        DateTime       @default(now())
  
  group       Group          @relation(fields: [groupId], references: [id])
  groupId     String
  paidBy      User           @relation("PaidBy", fields: [paidById], references: [id])
  paidById    String
  
  splits      ExpenseSplit[]
}

model ExpenseSplit {
  id        String   @id @default(uuid())
  amount    Float
  
  expense   Expense  @relation(fields: [expenseId], references: [id])
  expenseId String
  user      User     @relation(fields: [userId], references: [id])
  userId    String
}

model Settlement {
  id         String   @id @default(uuid())
  amount     Float
  date       DateTime @default(now())
  
  group      Group    @relation(fields: [groupId], references: [id])
  groupId    String
  fromUser   User     @relation("SettlementFrom", fields: [fromUserId], references: [id])
  fromUserId String
  toUser     User     @relation("SettlementTo", fields: [toUserId], references: [id])
  toUserId   String
}
```

## 2. REST API Endpoints Chi tiết

### 2.1. Authentication & OAuth2
- `POST /api/auth/register`: Đăng ký tài khoản (Local).
- `POST /api/auth/login`: Đăng nhập bằng Email/Password.
- `GET /api/auth/google`: Redirect sang trang đăng nhập Google (OAuth2).
- `GET /api/auth/google/callback`: Nhận thông tin từ Google, tạo/cập nhật `UserAccount` và trả về Session/JWT.
- `POST /api/auth/logout`: Xóa session.
- `POST /api/auth/refresh`: Refresh token.

### 2.2. Users & Profiles
- `GET /api/users/me`: Lấy thông tin user hiện tại (bao gồm cả Profile).
- `PUT /api/users/me/profile`: Cập nhật UserProfile.
- `PUT /api/users/me/settings`: Cập nhật UserSettings.

### 2.3. Groups (Nhóm)
- `GET /api/groups`: Lấy danh sách nhóm của user hiện tại.
- `POST /api/groups`: Tạo nhóm mới.
- `GET /api/groups/:groupId`: Lấy chi tiết nhóm (thành viên, tổng quan).
- `PUT /api/groups/:groupId`: Cập nhật thông tin nhóm.
- `DELETE /api/groups/:groupId`: Xóa nhóm.

### 2.4. Members (Thành viên)
- `POST /api/groups/:groupId/members`: Thêm thành viên vào nhóm (Invite).
- `DELETE /api/groups/:groupId/members/:userId`: Xóa thành viên khỏi nhóm.

### 2.5. Expenses (Chi tiêu)
- `GET /api/groups/:groupId/expenses`: Lấy danh sách chi tiêu trong nhóm.
- `POST /api/groups/:groupId/expenses`: Thêm khoản chi tiêu mới.
- `PUT /api/groups/:groupId/expenses/:expenseId`: Sửa khoản chi tiêu.
- `DELETE /api/groups/:groupId/expenses/:expenseId`: Xóa khoản chi tiêu.

### 2.6. Settlements & Balances (Thanh toán & Công nợ)
- `GET /api/groups/:groupId/balances`: Xem số dư tổng hợp của từng người trong nhóm.
- `GET /api/groups/:groupId/settlement-suggestions`: Trả về gợi ý thanh toán tối giản nhất.
- `POST /api/groups/:groupId/settlements`: Ghi nhận đã thanh toán nợ.
