# Ma trận phân quyền (Permission Matrix)

## 1. Vai trò hệ thống (System Roles)

| Role | Mô tả |
|---|---|
| **Guest** | Người dùng chưa đăng nhập. Chỉ truy cập được trang public. |
| **User** | Người dùng đã đăng nhập. Có thể tạo nhóm và tham gia nhóm. |
| **Admin** | Quản trị viên hệ thống. Quản lý user, không truy cập dữ liệu nội bộ nhóm. |

## 2. Vai trò trong nhóm (Group Roles)

| Role | Mô tả |
|---|---|
| **Owner** | Người tạo nhóm. Toàn quyền quản lý nhóm, thành viên và nội dung. |
| **Member** | Thành viên trong nhóm. Có thể đóng góp nội dung theo giới hạn quy định. |

## 3. Bảng phân quyền chi tiết

### 3.1. Tài khoản & Hồ sơ

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Đăng nhập / Đăng ký | ✅ | ❌ | ❌ | ❌ | ❌ |
| Xem profile cá nhân | ❌ | ✅ | ✅ | ✅ | ✅ |
| Cập nhật profile / avatar | ❌ | ✅ | ✅ | ✅ | ✅ |
| Đăng xuất | ❌ | ✅ | ✅ | ✅ | ✅ |
| Thay đổi cài đặt thông báo | ❌ | ✅ | ✅ | ✅ | ✅ |

### 3.2. Quản lý nhóm (Group Workspace)

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Tạo nhóm mới | ❌ | ✅ | N/A | N/A | ✅ |
| Xem danh sách nhóm của mình | ❌ | ✅ | ✅ | ✅ | ✅ |
| Xem chi tiết nhóm | ❌ | ❌ | ✅ | ✅ | ✅ |
| Chỉnh sửa thông tin nhóm | ❌ | ❌ | ❌ | ✅ | ✅ |
| Quản lý Quỹ nhóm (Thu/chi từ quỹ) | ❌ | ❌ | ❌ | ✅ | ❌ |
| Xóa nhóm | ❌ | ❌ | ❌ | ✅ | ✅ |

### 3.3. Quản lý thành viên (Members)

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Mời thành viên mới | ❌ | ❌ | ❌ | ✅ | ✅ |
| Chấp nhận lời mời | ❌ | ✅ | N/A | N/A | N/A |
| Xóa thành viên | ❌ | ❌ | ❌ | ✅ | ✅ |
| Rời khỏi nhóm | ❌ | ❌ | ✅ | ❌ (cần nhường quyền Owner trước) | N/A |
| Nhường quyền Owner | ❌ | ❌ | ❌ | ✅ | ❌ |

### 3.4. Quản lý chi tiêu (Expense)

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Xem danh sách chi tiêu | ❌ | ❌ | ✅ | ✅ | ✅ |
| Tạo khoản chi tiêu mới | ❌ | ❌ | ✅ | ✅ | ✅ |
| Sửa chi tiêu (do chính mình tạo) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Sửa chi tiêu của người khác | ❌ | ❌ | ❌ | ❌ | ❌ |
| Xóa chi tiêu (do chính mình tạo) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Xóa chi tiêu của người khác | ❌ | ❌ | ❌ | ❌ | ❌ |

### 3.5. Thanh toán & Công nợ

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Xem tổng kết công nợ | ❌ | ❌ | ✅ | ✅ | ✅ |
| Xem gợi ý tối giản công nợ | ❌ | ❌ | ✅ | ✅ | ✅ |
| Ghi nhận thanh toán nợ (Settlement) | ❌ | ❌ | ✅ | ✅ | ✅ |

### 3.6. Lịch trình & Sự kiện (Itinerary)

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Xem lịch trình nhóm | ❌ | ❌ | ✅ | ✅ | ✅ |
| Thêm / sửa activity trong lịch trình | ❌ | ❌ | ✅ | ✅ | ✅ |
| Xóa activity (do mình tạo) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Xóa mọi activity | ❌ | ❌ | ❌ | ✅ | ✅ |
| Yêu cầu AI generate lịch trình | ❌ | ❌ | ❌ | ✅ | ❌ |
| Áp dụng lịch trình từ AI | ❌ | ❌ | ❌ | ✅ | ❌ |

### 3.7. Voting & Gợi ý địa điểm

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Xem danh sách gợi ý (Recommendation) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Yêu cầu AI recommend địa điểm | ❌ | ❌ | ✅ | ✅ | ❌ |
| Vote cho một gợi ý | ❌ | ❌ | ✅ | ✅ | ❌ |
| Tạo poll vote thủ công | ❌ | ❌ | ✅ | ✅ | ❌ |
| Đóng / kết thúc poll | ❌ | ❌ | ❌ | ✅ | ✅ |

### 3.8. AI Assistant (Chat)

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Chat với AI Smart Assistant | ❌ | ✅ | ✅ | ✅ | ✅ |
| Xem lịch sử chat AI | ❌ | ✅ | ✅ | ✅ | ✅ |
| AI Budget Analysis cho nhóm | ❌ | ❌ | ✅ | ✅ | ❌ |

### 3.9. Lịch sử hoạt động & Thông báo

| Hành động | Guest | User | Member | Owner | Admin |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Xem Activity Feed của nhóm | ❌ | ❌ | ✅ | ✅ | ✅ |
| Nhận thông báo realtime | ❌ | ✅ | ✅ | ✅ | ✅ |
| Đánh dấu thông báo đã đọc | ❌ | ✅ | ✅ | ✅ | ✅ |
