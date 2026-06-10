# AI Group Event & Expense Planner

## 1. Overview

AI Group Event & Expense Planner là nền tảng hỗ trợ nhóm bạn, team hoặc tổ chức:

- Lên kế hoạch sự kiện/chuyến đi
- Quản lý ngân sách
- Theo dõi chi tiêu nhóm
- Chia tiền thông minh
- Nhận gợi ý địa điểm/quán ăn bằng AI
- Tối ưu lịch trình và công nợ

Hệ thống kết hợp:

- AI Event Planning
- AI Recommendation System
- Expense Splitter
- Realtime Collaboration
- Budget Analytics

Mục tiêu là tạo ra một “AI Copilot” giúp việc tổ chức và quản lý hoạt động nhóm trở nên dễ dàng, minh bạch và thông minh hơn.

---

# 2. Problem Statement

## 2.1 Pain Points

Khi tổ chức:

- du lịch nhóm
- workshop
- hackathon
- ăn uống
- sinh nhật
- hoạt động team building

người dùng thường gặp các vấn đề:

### Expense Management
- Không nhớ ai đã trả khoản nào
- Tính tiền thủ công dễ sai
- Khó theo dõi công nợ
- Ngại nhắc trả tiền

### Event Planning
- Khó lên lịch trình
- Khó estimate budget
- Không biết chọn quán/địa điểm nào phù hợp
- Mất nhiều thời gian research

### Group Coordination
- Chat bị loãng
- Không có nơi tập trung thông tin
- Thiếu minh bạch
- Khó đồng bộ thay đổi

---

# 3. Proposed Solution

Hệ thống sử dụng AI để:

- Gợi ý lịch trình
- Recommend quán ăn/địa điểm
- Estimate ngân sách
- Theo dõi chi tiêu
- Tối ưu công nợ
- Hỗ trợ collaboration realtime

Toàn bộ flow được gom về một workspace chung cho từng nhóm/sự kiện.

---

# 4. Core Features

# 4.1 Group Workspace

Mỗi:
- chuyến đi
- workshop
- hackathon
- event

sẽ có một workspace riêng.

## Features
- Invite members
- Roles & permissions
- Shared activity feed
- Group settings

---

# 4.2 AI Event Planner

AI hỗ trợ tạo:
- lịch trình
- timeline
- budget estimation
- activity suggestions

## Example

### Input
Trip Đà Nẵng 3 ngày cho 6 người budget 5 triệu/người.

### AI Output
- Suggested itinerary
- Places to visit
- Meal suggestions
- Budget breakdown

---

# 4.3 AI Restaurant Recommendation Engine

AI recommend quán ăn theo:

- mood
- weather
- budget
- taste history
- group size
- current location

## Example

### Input
Nhóm 5 người, trời mưa, budget 150k/người.

### AI Suggestion
- Lẩu
- BBQ indoor
- Cafe boardgame

---

# 4.4 Fund & Expense Splitter

## Features
- **Group Fund Management**: Thu quỹ nhóm do Thủ quỹ (Treasurer) quản lý.
- **Funding Sources**: Lựa chọn trả bằng Quỹ nhóm hoặc Ứng tiền túi cá nhân.
- **Add Expenses**: Thêm chi tiêu với đa dạng loại tiền.
- **Split Methods**: Chia đều (Equal), chia theo % hoặc nhập số tiền tùy chỉnh.
- **Multi-payer support**: Nhiều người cùng trả chung một hóa đơn.

---

# 4.5 Debt Simplification & Account Balancing

Hệ thống tự động cân bằng tài khoản dựa trên công thức `Balance = (Tiền nộp quỹ + Tiền ứng riêng) - (Tiền tiêu hao)`.
Thuật toán tối giản số lượng giao dịch cần thanh toán để quyết định xem ai cần chuyển cho ai.

## Example

### Before
- A owes B: 200k
- B owes C: 200k

### Optimized
- A pays C directly (Hoặc hệ thống gom về cho Thủ quỹ xử lý)

---

# 4.6 Realtime Collaboration

## Features
- Live expense updates
- Realtime itinerary editing
- Voting system
- Group comments
- Notifications

---

# 4.7 AI Budget Assistant

AI phân tích:
- overspending risk
- category spending
- estimated total cost
- saving suggestions

## Example
“Ăn uống đang vượt ngân sách 25%.”

---

# 4.8 AI Smart Assistant

Người dùng có thể chat với AI:

## Example Prompts
- “Tìm quán ăn gần khách sạn dưới 200k”
- “Tối ưu lịch trình ngày 2”
- “Giảm budget xuống còn 3 triệu/người”

---

# 5. System Architecture

## Backend
- Node.js
- NestJS
- TypeScript

## Database
- PostgreSQL

## Cache & Realtime
- Redis
- WebSocket

## Queue
- BullMQ

## AI
- OpenAI API
- LangChain

## Maps & Location
- Google Maps API

## Storage
- AWS S3

## Deployment
- Docker
- Nginx
- CI/CD

---

# 6. AI Components

# 6.1 Recommendation Engine

AI phân tích:
- user preferences
- weather
- budget
- history
- mood

để recommend địa điểm phù hợp.

---

# 6.2 Planning Engine

AI generate:
- itinerary
- activity flow
- budget planning

---

# 6.3 Budget Intelligence

AI:
- predict total spending
- detect overspending
- suggest optimizations

---

# 6.4 Conversational Assistant

LLM-powered assistant hỗ trợ:
- planning
- expense insights
- recommendations

---

# 7. Realtime Features

## Supported Realtime Events
- Expense created
- Expense updated
- Member joined
- Vote updated
- Itinerary edited
- Notifications

---

# 8. Algorithms

# 8.1 Debt Simplification Algorithm

Mục tiêu:
- giảm số lượng transactions
- tối ưu debt settlement

## Techniques
- Graph balancing
- Greedy optimization

---

# 8.2 Recommendation Scoring

Scoring dựa trên:
- preference match
- weather relevance
- budget fit
- popularity
- distance

---

# 9. MVP Scope

## MVP Features
- Authentication
- Group workspace
- Expense splitting
- Debt simplification
- AI restaurant recommendation
- AI itinerary generation
- Realtime updates

---

# 10. Future Enhancements

## AI Features
- Personalized recommendations
- AI memory
- Voice assistant
- Smart scheduling

## Product Features
- Payment integration
- QR settlement
- Travel booking
- Calendar sync
- Analytics dashboard

---

# 11. Target Users

- Friend groups
- Travelers
- Students
- Startup teams
- Event organizers
- Hackathon teams
- Remote teams

---

# 12. Business Value

## Benefits
- Reduce planning time
- Improve transparency
- Simplify group payments
- Better budget management
- Personalized recommendations

---

# 13. Why This Project Is Strong

Dự án combine nhiều domain thực tế:

| Domain | Included |
|---|---|
| AI | Yes |
| Fintech | Yes |
| Realtime | Yes |
| Recommendation System | Yes |
| Collaboration | Yes |
| Maps & Location | Yes |
| Algorithms | Yes |
| SaaS Thinking | Yes |

---

# 14. Suggested Project Names

- GroupFlow AI
- PlanPal AI
- SyncTrip
- EventPilot
- GatherAI
- BudgetBuddy AI
- TripMind AI

---

# 15. Conclusion

AI Group Event & Expense Planner không chỉ là một expense splitter đơn giản mà là một nền tảng AI-powered collaboration dành cho các hoạt động nhóm.

Hệ thống giải quyết đồng thời:
- planning
- recommendation
- budgeting
- expense tracking
- collaboration

Đây là một project có tính thực tế cao, phù hợp để:
- portfolio backend Node.js
- hackathon
- startup MVP
- AI-integrated SaaS platform
