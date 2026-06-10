# Thiết kế cơ sở dữ liệu (Database & ERD)

## 1. Danh sách các bảng (Tables)

### 1.1. Core & Authentication
Thông tin người dùng tách thành nhiều bảng để tối ưu bảo mật và hỗ trợ multi-provider OAuth2.

- **`users`**: Định danh người dùng trên hệ thống (`id`, `email`, `email_verified`, `system_role` [USER/ADMIN], `status` [ACTIVE/INACTIVE/BANNED], `created_at`, `updated_at`).
- **`user_accounts`**: Thông tin xác thực theo từng provider (`id`, `user_id`, `provider` [LOCAL/GOOGLE/FACEBOOK], `provider_account_id`, `password_hash`, `access_token`, `refresh_token`, `expires_at`).
- **`user_profiles`**: Thông tin cá nhân để hiển thị (`id`, `user_id`, `display_name`, `avatar_url`, `phone_number`).
- **`sessions`**: Quản lý phiên đăng nhập (`id`, `session_token`, `user_id`, `expires_at`).
- **`user_settings`**: Tùy chọn cá nhân (`id`, `user_id`, `notification_preferences` [JSON], `default_currency`).

### 1.2. Quản lý nhóm (Group Workspace)

- **`groups`**: Thông tin workspace nhóm (`id`, `name`, `description`, `cover_image_url`, `event_type` [TRIP/WORKSHOP/PARTY/HACKATHON/OTHER], `event_date_start`, `event_date_end`, `target_budget`, `fund_balance`, `currency`, `created_by`, `created_at`, `updated_at`).
- **`group_members`**: Liên kết User – Group kèm vai trò (`id`, `group_id`, `user_id`, `group_role` [OWNER/MEMBER], `joined_at`).
- **`group_invitations`**: Lời mời vào nhóm (`id`, `group_id`, `invited_email`, `status` [PENDING/ACCEPTED/EXPIRED], `token`, `expires_at`, `created_by`).

### 1.3. Chi tiêu (Expense)

- **`expenses`**: Ghi nhận khoản chi (`id`, `group_id`, `paid_by_user_id`, `title`, `description`, `amount`, `currency`, `funding_source` [GROUP_FUND/PERSONAL], `category_id`, `expense_date`, `receipt_url`, `created_at`, `updated_at`).
- **`expense_splits`**: Phân bổ số tiền cho từng thành viên (`id`, `expense_id`, `user_id`, `amount_owed`, `is_settled`).
- **`categories`**: Danh mục chi tiêu (`id`, `name`, `icon`, `color`). Ví dụ: Ăn uống, Di chuyển, Lưu trú, Giải trí.
- **`settlements`**: Lịch sử thanh toán công nợ (`id`, `group_id`, `from_user_id`, `to_user_id`, `amount`, `note`, `settled_at`, `created_at`).
- **`balances`**: Cache số dư ròng để tăng tốc dashboard (`group_id`, `user_id`, `net_balance`, `updated_at`).

### 1.4. Lịch trình & Sự kiện (Itinerary)

- **`itineraries`**: Lịch trình tổng của nhóm (`id`, `group_id`, `title`, `description`, `generated_by_ai` [boolean], `ai_prompt_used`, `created_by`, `created_at`, `updated_at`).
- **`itinerary_items`**: Từng hoạt động trong lịch trình (`id`, `itinerary_id`, `day_number`, `start_time`, `end_time`, `title`, `description`, `location_name`, `location_address`, `location_lat`, `location_lng`, `place_id` [Google Maps], `category` [MEAL/TRANSPORT/ACTIVITY/ACCOMMODATION/OTHER], `estimated_cost`, `order_index`, `created_by`, `created_at`, `updated_at`).

### 1.5. AI Recommendations

- **`recommendations`**: Danh sách gợi ý địa điểm / quán ăn từ AI (`id`, `group_id`, `type` [RESTAURANT/ACTIVITY/ACCOMMODATION], `name`, `description`, `location_address`, `location_lat`, `location_lng`, `place_id`, `price_range`, `tags` [JSON array], `ai_reason`, `score_budget_fit`, `score_preference_match`, `score_weather_relevance`, `score_popularity`, `total_score`, `generated_at`, `created_at`).
- **`recommendation_votes`**: Vote của thành viên cho từng gợi ý (`id`, `recommendation_id`, `user_id`, `vote` [UP/DOWN], `created_at`).

### 1.6. Voting & Polls

- **`polls`**: Poll vote thủ công trong nhóm (`id`, `group_id`, `question`, `status` [OPEN/CLOSED], `ends_at`, `created_by`, `created_at`).
- **`poll_options`**: Lựa chọn trong poll (`id`, `poll_id`, `text`, `linked_recommendation_id`).
- **`poll_votes`**: Vote của thành viên (`id`, `poll_option_id`, `user_id`, `created_at`).

### 1.7. AI Chat Assistant

- **`ai_chat_sessions`**: Phiên chat với AI (`id`, `user_id`, `group_id` [nullable – chat cá nhân hoặc trong ngữ cảnh nhóm], `title`, `created_at`, `updated_at`).
- **`ai_chat_messages`**: Tin nhắn trong phiên chat (`id`, `session_id`, `role` [USER/ASSISTANT], `content`, `token_count`, `created_at`).

### 1.8. Hệ thống & Audit

- **`activity_logs`**: Lưu vết mọi hành động (`id`, `group_id`, `user_id`, `action_type` [CREATE/UPDATE/DELETE], `entity_type` [EXPENSE/MEMBER/SETTLEMENT/ITINERARY/RECOMMENDATION], `entity_id`, `old_data` [JSON], `new_data` [JSON], `created_at`).
- **`notifications`**: Thông báo in-app (`id`, `user_id`, `type`, `title`, `message`, `payload` [JSON], `is_read`, `created_at`).

---

## 2. Mô hình thực thể liên kết (ERD Overview)

### Auth & User
- 1 `User` → 1 `UserProfile`, 1 `UserSettings`.
- 1 `User` → nhiều `UserAccounts` (Local password + Google + Facebook...).
- 1 `User` → nhiều `Sessions` (đăng nhập nhiều thiết bị).

### Group & Membership
- 1 `User` → nhiều `GroupMembers` (tham gia nhiều nhóm).
- 1 `Group` → nhiều `GroupMembers`, nhiều `GroupInvitations`.

### Expense & Debt
- 1 `Group` → nhiều `Expenses`, nhiều `Settlements`.
- 1 `Expense` → 1 `User` trả tiền (`paid_by_user_id`) → nhiều `ExpenseSplits` (nhiều người chịu).
- 1 `Settlement` = from_user trả tiền cho to_user trong phạm vi Group.
- `Balances` là cache delta, cập nhật mỗi khi có Expense hoặc Settlement mới.

### Itinerary
- 1 `Group` → nhiều `Itineraries` (có thể có nhiều phác thảo lịch trình).
- 1 `Itinerary` → nhiều `ItineraryItems` (sắp xếp theo day + order_index).
- `ItineraryItem` có thể liên kết với `Recommendation` (địa điểm AI gợi ý).

### AI Recommendation & Voting
- 1 `Group` → nhiều `Recommendations` (theo từng lần gọi AI).
- 1 `Recommendation` → nhiều `RecommendationVotes` (thành viên vote).
- 1 `Group` → nhiều `Polls` → nhiều `PollOptions` → nhiều `PollVotes`.

### AI Chat
- 1 `User` → nhiều `AiChatSessions` (chat cá nhân hoặc trong context nhóm).
- 1 `AiChatSession` → nhiều `AiChatMessages` (lịch sử hội thoại).

---

## 3. Lưu ý thiết kế quan trọng

- **Tiền tệ**: Lưu `amount` dưới dạng **integer (smallest currency unit)** – ví dụ VND nguyên, Cents cho USD – để tránh floating-point error khi tính toán công nợ. Frontend format lại khi hiển thị.
- **Soft delete**: Expense và ItineraryItem hỗ trợ soft delete (`deleted_at`) thay vì xóa vật lý để giữ nguyên audit trail.
- **place_id**: Dùng Google Maps Place ID làm định danh duy nhất cho địa điểm, tránh trùng lặp khi nhiều user gợi ý cùng một nơi.
- **JSON fields**: `tags`, `old_data`, `new_data`, `notification_preferences`, `payload` dùng PostgreSQL `jsonb` để flexible mà vẫn có thể index và query.
