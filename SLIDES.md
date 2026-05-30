---
marp: true
theme: default
paginate: true
backgroundColor: #ffffff
---

<!-- Slide 1 -->
# 📱 Đồ án Lập trình Mobile: Todo App
**Ứng dụng Quản lý Công việc Cá nhân Đa nền tảng**

- **Sinh viên thực hiện:** [Tên của bạn]
- **Mã sinh viên:** [MSSV của bạn]
- **Môn học:** Lập trình Mobile
- **Giảng viên hướng dẫn:** [Tên giảng viên]

---

<!-- Slide 2 -->
## 🎯 Lý do chọn đề tài & Mục tiêu

**Vấn đề:** 
- Nhu cầu ghi chú và quản lý công việc hàng ngày ngày càng cao.
- Cần một công cụ đồng bộ dữ liệu tức thời trên nhiều thiết bị.

**Mục tiêu dự án:**
- Xây dựng ứng dụng quản lý công việc đa nền tảng (Android/iOS).
- Giao diện thân thiện, dễ sử dụng (UI/UX tối ưu).
- Lưu trữ dữ liệu an toàn và đồng bộ thời gian thực (Real-time).

---

<!-- Slide 3 -->
## 🌟 Các tính năng chính

1. **Xác thực người dùng (Authentication):** Đăng nhập, đăng ký tài khoản an toàn.
2. **Quản lý Công việc (CRUD):** 
   - Thêm, xem, sửa, xóa công việc.
   - Đánh dấu hoàn thành.
3. **Phân loại & Chi tiết:** 
   - Gắn cờ mức độ ưu tiên (Low, Medium, High).
   - Thêm Tags và Ngày đến hạn (Due Date).
4. **Bảng Thống kê (Dashboard):** Theo dõi tiến độ hoàn thành công việc trực quan.
5. **Real-time Sync:** Dữ liệu tự động cập nhật ngay lập tức trên mọi thiết bị.

---

<!-- Slide 4 -->
## 💻 Demo Ứng dụng

> *(Mở máy ảo hoặc cắm thiết bị thật để demo trực tiếp)*

- Luồng đăng nhập / Đăng ký.
- Trải nghiệm thêm mới một công việc với các thông tin chi tiết.
- Tính năng sửa/xóa và vuốt (Swipe) để đánh dấu hoàn thành.
- Xem bảng thống kê cá nhân.
- Demo tính năng đồng bộ thời gian thực (nếu có 2 thiết bị).

---

<!-- Slide 5 -->
## ⚙️ Kiến trúc & Công nghệ (Tech Stack)

**1. Frontend: Flutter / Dart**
- Xây dựng UI/UX mượt mà, hỗ trợ compile ra cả Android và iOS từ một mã nguồn.
- Cấu trúc thư mục chuẩn (MVC/MVVM cơ bản): Tách biệt `screens`, `widgets`, `models`, `services`.

**2. Backend (BaaS): Firebase**
- **Firebase Authentication:** Quản lý định danh người dùng.
- **Cloud Firestore:** Cơ sở dữ liệu NoSQL lưu trữ dữ liệu ứng dụng.

---

<!-- Slide 6 -->
## 🗄️ Cấu trúc Cơ sở dữ liệu (Firestore)

**Mô hình NoSQL tối ưu hóa cho truy vấn bảo mật:**
Dữ liệu không lưu chung mà được tách biệt theo từng user.

`users / {uid} / todos / {todoId}`

- **Tốc độ:** Truy vấn nhanh, giới hạn scope trong collection của chính user.
- **Bảo mật:** Dễ dàng áp dụng Firestore Security Rules, user nào chỉ được đọc/ghi dữ liệu của chính user đó.

---

<!-- Slide 7 -->
## 🚀 Điểm nhấn Kỹ thuật

- **Sử dụng StreamBuilder:** 
  - Thay vì `FutureBuilder` tải dữ liệu 1 lần, ứng dụng lắng nghe `snapshots()` từ Firestore. 
  - UI tự động vẽ lại (rebuild) ngay khi có thay đổi trên database mà không cần refresh.
- **Xử lý Bất đồng bộ (Async/Await):** 
  - Giao tiếp mượt mà với Firebase, không gây nghẽn UI thread.
- **Tách biệt Logic:** 
  - Các thao tác với database được cô lập trong `TodoService` (`lib/services/todo_service.dart`), giúp tái sử dụng code dễ dàng.

---

<!-- Slide 8 -->
## 🔮 Hướng phát triển tương lai (Future Works)

1. **Push Notifications (FCM):**
   - Nhắc nhở người dùng khi sắp đến hạn (`dueDate`) của một công việc.
2. **Chế độ Ngoại tuyến (Offline Mode):**
   - Lưu cache sâu hơn với SQLite hoặc Hive để thao tác không cần mạng, tự đồng bộ khi có mạng.
3. **Tính năng Nhóm (Collaboration):**
   - Cho phép chia sẻ To-do list với người khác.
4. **Tích hợp AI:**
   - Gợi ý chia nhỏ các công việc lớn thành các bước nhỏ hơn.

---

<!-- Slide 9 -->
## ❓ Q&A

**Cảm ơn Thầy/Cô và các bạn đã lắng nghe!**

*Mọi người có câu hỏi nào cho nhóm/mình không ạ?*
