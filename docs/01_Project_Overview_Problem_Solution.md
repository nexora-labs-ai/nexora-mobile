# Tổng quan dự án, Vấn đề & Giải pháp

## 1. Tóm tắt (Executive Summary)

**AI Group Event & Expense Planner** là nền tảng AI-powered giúp nhóm bạn, team hoặc tổ chức lên kế hoạch sự kiện/chuyến đi, quản lý ngân sách, theo dõi chi tiêu nhóm, chia tiền thông minh và nhận gợi ý địa điểm/quán ăn từ AI.

Hệ thống kết hợp đồng thời:
- **AI Event Planning** – Tự động generate lịch trình, timeline, ước tính ngân sách.
- **AI Recommendation Engine** – Gợi ý quán ăn / địa điểm dựa trên mood, thời tiết, budget và lịch sử nhóm.
- **Expense Splitter** – Ghi nhận, phân chia chi tiêu, chia đều hoặc tùy chỉnh.
- **Debt Simplification** – Thuật toán tối giản công nợ giảm thiểu số lượt chuyển khoản.
- **Realtime Collaboration** – Cộng tác đồng thời qua WebSocket.
- **AI Budget Assistant** – Phân tích nguy cơ vượt chi, gợi ý tối ưu ngân sách.
- **Conversational AI Assistant** – Chat trực tiếp với AI để hỗ trợ planning và tra cứu chi tiêu.

Mục tiêu xây dựng một "AI Copilot" giúp việc tổ chức và quản lý hoạt động nhóm trở nên dễ dàng, minh bạch và thông minh hơn.

---

## 2. Vấn đề (Problem Space)

### 2.1. Đối tượng người dùng mục tiêu

| Nhóm | Use case điển hình |
|---|---|
| Nhóm bạn | Du lịch, sinh nhật, ăn uống |
| Sinh viên | Thuê phòng, đi chơi nhóm |
| Team startup / remote | Workshop, hackathon, team building |
| Tổ chức sự kiện | Sự kiện nội bộ, company trip |
| Gia đình | Kỳ nghỉ, mua sắm chung |

### 2.2. Nỗi đau của người dùng (Pain Points)

#### Expense Management
- Không nhớ ai đã trả khoản nào khi cả nhóm cùng chi tiêu.
- Tính toán thủ công phức tạp, dễ sai lệch.
- Thiếu sổ cái chung dẫn đến tranh cãi và mất minh bạch.
- Ngại nhắc bạn bè trả nợ, gây tâm lý e ngại.

#### Event Planning
- Mất nhiều giờ research địa điểm, quán ăn, lịch trình.
- Khó ước tính ngân sách trước khi đi.
- Không có công cụ tổng hợp thông tin – ý kiến nhóm bị phân tán trên nhiều kênh chat.

#### Group Coordination
- Thông tin bị loãng trong chat (Zalo, Messenger).
- Thiếu nơi tập trung toàn bộ kế hoạch + chi tiêu của nhóm.
- Không đồng bộ khi nhiều người cùng chỉnh sửa lịch trình.
- Bỏ phiếu, vote địa điểm phải làm thủ công qua poll chat.

### 2.3. Các giải pháp hiện tại và hạn chế

| Giải pháp hiện tại | Hạn chế |
|---|---|
| Excel / Google Sheets | Không mobile-friendly, không real-time, không có AI |
| App chat (Zalo, Messenger) | Tin nhắn trôi, không tổng hợp được công nợ |
| Splitwise | Chỉ split expense, không có AI planning/recommendation |
| Tính tay & ghi sổ | Chậm, dễ sai, không tối giản hóa được giao dịch |

---

## 3. Giải pháp đề xuất (The Solution)

### 3.1. Giá trị cốt lõi

Tạo ra một **Group Workspace** tập trung duy nhất cho mỗi sự kiện/chuyến đi, nơi AI hỗ trợ toàn bộ vòng đời từ lên kế hoạch đến thanh toán công nợ.

### 3.2. Tính năng cốt lõi (Core Features)

#### Group Workspace
Mỗi chuyến đi / workshop / hackathon / event có một workspace riêng:
- Invite members, phân quyền vai trò.
- Shared activity feed, real-time notifications.
- Group settings (budget mục tiêu, currency, thông tin sự kiện).

#### AI Event Planner
AI generate lịch trình hoàn chỉnh dựa trên input của nhóm:
- **Input**: "Trip Đà Nẵng 3 ngày, 6 người, budget 5 triệu/người."
- **Output**: Suggested itinerary, places to visit, meal suggestions, budget breakdown.

#### AI Restaurant Recommendation Engine
Recommend quán ăn / địa điểm dựa trên:
- Mood, thời tiết, budget, group size, location hiện tại.
- Lịch sử ưu tiên của nhóm (taste history).
- **Ví dụ**: "Nhóm 5 người, trời mưa, 150k/người" → gợi ý Lẩu, BBQ indoor, Cafe boardgame.

#### Fund & Expense Splitter (Quản lý Quỹ & Chi tiêu)
- **Quản lý Quỹ nhóm (Group Fund)**: Hỗ trợ chức năng nộp quỹ chung do Thủ quỹ (Treasurer) quản lý.
- **Tùy chọn Nguồn chi (Funding Source)**: Cho phép chọn trả từ Quỹ nhóm (trừ vào số dư quỹ) hoặc ứng từ Tiền túi cá nhân.
- **Phân bổ linh hoạt (Split Method)**: Chia đều (Equal) hoặc chia tùy chỉnh (Custom / % / Exact).
- Hỗ trợ multi-payer (nhiều người cùng ứng tiền trả một bill).

#### Debt Simplification & Account Balancing
Cân bằng tài khoản với công thức: `Balance = (Tiền đóng Quỹ + Tiền ứng riêng) - Tiền đã tiêu hao`.
- Phân định rõ ai là người được nhận lại tiền (Balance > 0) và ai phải đóng thêm (Balance < 0).
- Thuật toán tối giản số lượng giao dịch (Debt Simplification).
- **Ví dụ trước**: A nợ B 200k, B nợ C 200k.
- **Ví dụ sau**: A chuyển thẳng 200k cho C (hoặc gom về Thủ quỹ xử lý).

#### Realtime Collaboration
- Live update khi có expense mới, itinerary thay đổi.
- Voting system cho địa điểm / hoạt động.
- Group comments, notifications.

#### AI Budget Assistant
- Phân tích overspending risk theo category.
- Estimate total cost dựa trên lịch trình hiện tại.
- Gợi ý tiết kiệm: *"Ăn uống đang vượt ngân sách 25%."*

#### AI Smart Assistant (Chat)
- Chat trực tiếp với AI để hỏi/yêu cầu:
  - *"Tìm quán ăn gần khách sạn dưới 200k."*
  - *"Tối ưu lịch trình ngày 2."*
  - *"Giảm budget xuống còn 3 triệu/người."*

### 3.3. MVP Scope

| Priority | Tính năng |
|---|---|
| **P0** | Auth, Group Workspace, Expense Splitting, Debt Simplification, Realtime updates |
| **P1** | AI Restaurant Recommendation, AI Itinerary Generation, Voting System |
| **P2** | AI Budget Assistant, AI Smart Chat, Activity Logs, File Upload |

### 3.4. Future Enhancements

- **AI cá nhân hóa**: AI memory lưu trữ preference lâu dài cho từng user.
- **Voice assistant**: Thêm chi tiêu bằng giọng nói.
- **Payment integration**: Tích hợp cổng thanh toán, QR settlement.
- **Travel booking**: Book khách sạn, vé trực tiếp từ app.
- **Calendar sync**: Đồng bộ lịch trình với Google Calendar.
- **Analytics dashboard**: Biểu đồ chi tiêu theo category, thành viên, thời gian.
- **Multi-currency**: Tự động convert tỷ giá khi đi nước ngoài.
