# Yêu cầu phi chức năng (Non-Functional Requirements)

## 1. Hiệu năng (Performance)

- **API response time**: 95% các REST API phải phản hồi dưới 200ms (không tính AI endpoints).
- **AI endpoints**: Các endpoint gọi OpenAI/LangChain chấp nhận response time tối đa 10 giây; stream response cho chat assistant.
- **WebSocket**: Latency event realtime (expense created, vote updated...) không vượt quá 500ms từ server đến tất cả client trong nhóm.
- **Queue processing (BullMQ)**: Job AI planning / recommendation được xử lý xong trong vòng 30 giây sau khi enqueue.
- **Concurrency**: Hệ thống hỗ trợ tối thiểu 1.000 user hoạt động đồng thời ở phiên bản MVP.
- **Database**: Các truy vấn tính toán số dư nhóm, lấy danh sách expense, recommendation history phải được index và tối ưu để trả về dưới 100ms.

---

## 2. Bảo mật (Security)

- **Authentication**: JWT (Access Token ngắn hạn + Refresh Token dài hạn). Mật khẩu băm bằng **bcrypt / Argon2**.
- **Authorization**: Kiểm tra quyền tại application layer theo Group Role (Owner/Member) và System Role (User/Admin). User chỉ được đọc/ghi dữ liệu của nhóm mà mình tham gia.
- **OAuth2**: Luồng Google OAuth2 chuẩn Authorization Code Flow. Không lưu OAuth token của user trên client.
- **Transport Security**: Toàn bộ giao tiếp qua HTTPS/WSS. Cấm HTTP thuần.
- **Input Validation**: Validate và sanitize toàn bộ input ở DTO layer (NestJS class-validator). Chống SQL Injection (Prisma ORM parameterized queries), XSS, CSRF.
- **AI Prompt Injection**: Sanitize user input trước khi đưa vào prompt LLM. Không truyền dữ liệu nhạy cảm (token, password) vào context AI.
- **Rate Limiting**: 
  - Endpoint auth (login/register): 10 request/phút/IP.
  - AI endpoints (chat, recommendation): 30 request/phút/user.
  - API chung: 200 request/phút/user.
- **API Key bảo mật**: OpenAI API key, Google Maps API key chỉ lưu trong environment variable phía server, không expose ra client.

---

## 3. Khả năng mở rộng (Scalability)

- **Horizontal Scaling**: Backend NestJS stateless, không lưu session trong process. Scale out bằng cách thêm instance qua Load Balancer.
- **Redis**: Dùng cho caching số dư nhóm, session store, BullMQ job queue. Cấu hình Redis Cluster khi scale.
- **BullMQ Workers**: AI planning và recommendation chạy trên worker pool riêng, tách biệt với API server để không block request chính.
- **Database**: Schema thiết kế chuẩn với đầy đủ index. Sẵn sàng cho read replica khi traffic tăng cao.
- **WebSocket**: Socket.IO với Redis Adapter để broadcast event đến tất cả instance khi chạy multi-node.

---

## 4. Độ tin cậy (Reliability & Availability)

- **Uptime mục tiêu**: 99.9% (cho phép ~8.7 giờ downtime/năm).
- **Database backup**: Tự động sao lưu hàng ngày, lưu 7 ngày gần nhất.
- **AI fallback**: Khi OpenAI API không khả dụng hoặc timeout, trả về lỗi rõ ràng và cho phép retry. Không để crash toàn bộ request.
- **Queue retry**: BullMQ tự động retry job thất bại tối đa 3 lần với exponential backoff.
- **Error tracking**: Tích hợp Sentry để bắt lỗi tự động trên production.

---

## 5. Tính khả dụng (Usability)

- **Mobile-First**: Giao diện tối ưu cho trình duyệt di động vì người dùng thường sử dụng khi đang đi chơi, ăn uống, di chuyển.
- **Real-time UX**: Khi thành viên thêm expense hoặc cập nhật itinerary, các thành viên khác thấy ngay không cần F5.
- **AI response streaming**: Chat với AI Assistant hiển thị text theo dạng streaming (typewriter effect) để không phải chờ toàn bộ response.
- **Offline grace**: Hiển thị thông báo rõ ràng khi mất kết nối, không crash app.

---

## 6. Khả năng bảo trì (Maintainability)

- **Clean Architecture**: Phân tách rõ ràng Controller → Service → Repository. AI logic tập trung trong `ai/` module, không rải rác khắp codebase.
- **Module độc lập**: Mỗi feature (auth, groups, expenses, itinerary, recommendations, ai-assistant) là một NestJS module riêng biệt.
- **Logging**: Structured logging (JSON format) toàn bộ request/response và AI interactions. Log lưu file trên production.
- **Environment config**: Dùng `@nestjs/config` + `.env` cho tất cả cấu hình. Không hardcode credential.
- **Testing**: Unit test cho Service layer (đặc biệt thuật toán Debt Simplification và Recommendation Scoring). Integration test cho API endpoints.

---

## 7. AI-specific Requirements

- **Prompt versioning**: Mỗi prompt template (itinerary generation, restaurant recommendation, budget analysis) được version và lưu trong codebase để rollback dễ dàng.
- **Token budget**: Mỗi AI call giới hạn token đầu vào để kiểm soát chi phí. Truncate context nếu cần.
- **Cost monitoring**: Theo dõi tổng token consumed / cost mỗi ngày qua OpenAI usage API.
- **Recommendation quality**: Kết quả recommendation phải kèm theo scoring breakdown (budget_fit, preference_match, weather_relevance...) để UI có thể hiển thị lý do gợi ý.
