# 📋 ĐỒ ÁN: QUẢN LÝ SHOP THỜI TRANG
## Môn: Hệ Quản Trị Cơ Sở Dữ Liệu — Nhóm 8

---

## 🛠 Công nghệ sử dụng

| Thành phần | Công nghệ |
|------------|-----------|
| Frontend | WPF App (.NET Framework 4.7.2) |
| Ngôn ngữ | C#, XAML |
| Database | Microsoft SQL Server |
| Data Access | ADO.NET (SqlConnection, SqlCommand, SqlDataAdapter) |
| Kiến trúc | 3-Layer (GUI → BUS → DAL → DTO) |

---

## 📁 Cấu trúc Project

```
QLShopThoiTrang/
├── QLShopThoiTrang.sln          ← Solution file
├── GUI/                          ← Giao diện WPF
│   ├── Views/                    ← Các màn hình
│   ├── Helpers/                  ← Session Manager
│   ├── Resources/                ← Theme, Styles
│   └── App.config                ← Connection string
├── BUS/                          ← Business Logic Layer
├── DAL/                          ← Data Access Layer (ADO.NET)
├── DTO/                          ← Data Transfer Objects
├── Database/                     ← Các file SQL
│   ├── 01_Tables.sql             ← Bảng + Dữ liệu mẫu
│   ├── 02_Views.sql              ← 5 Views
│   ├── 03_Functions.sql          ← Scalar + Table-Valued Functions
│   ├── 04_Triggers.sql           ← 6 Triggers
│   ├── 05_StoredProcedures.sql   ← 13 Stored Procedures
│   ├── 06_Cursors.sql            ← 5 Cursors
│   └── 07_Security_Backup.sql   ← Phân quyền + Backup/Restore
└── README.md
```

---

## 🚀 Hướng dẫn cài đặt và chạy

### Bước 1: Tạo Database

1. Mở **SQL Server Management Studio (SSMS)**
2. Kết nối tới server `localhost`
3. Chạy các file SQL **theo đúng thứ tự**:
   - `01_Tables.sql` → Tạo bảng + dữ liệu mẫu
   - `02_Views.sql` → Tạo 5 Views
   - `03_Functions.sql` → Tạo Functions
   - `04_Triggers.sql` → Tạo 6 Triggers
   - `05_StoredProcedures.sql` → Tạo 13 Stored Procedures
   - `06_Cursors.sql` → Tạo 5 Cursors
   - `07_Security_Backup.sql` → Phân quyền + Backup/Restore

### Bước 2: Cấu hình Connection String

Mở file `GUI/App.config`, kiểm tra connection string:

```xml
<add name="QLShopThoiTrang"
     connectionString="Server=localhost;Database=QL_SHOPTHOITRANG;Integrated Security=True;"
     providerName="System.Data.SqlClient"/>
```

- Nếu dùng **SQL Server Express**: đổi `Server=localhost` thành `Server=.\SQLEXPRESS`
- Nếu dùng **SQL Authentication**: đổi thành `Server=localhost;Database=QL_SHOPTHOITRANG;User Id=sa;Password=yourpass;`

### Bước 3: Mở Solution trong Visual Studio

1. Mở file `QLShopThoiTrang.sln` bằng **Visual Studio 2019/2022**
2. Set **GUI** làm **Startup Project** (chuột phải → Set as Startup Project)
3. Build solution (Ctrl+Shift+B)
4. Chạy (F5)

### Bước 4: Đăng nhập

| Tài khoản | Mật khẩu | Vai trò |
|-----------|----------|---------|
| `admin`   | `123456` | Admin — Nguyễn Trường Sơn |
| `namlv`   | `123456` | Employee — Lương Vân Nam |
| `taivc`   | `123456` | Employee — Võ Công Tài |
| `thanhlm`   | `123456` | Employee — Lê Minh Thành |
| `quangtt`   | `123456` | Employee — Trương Triệu Quang |

---

## 📊 Tổng hợp T-SQL

| Thành phần | Số lượng | Chi tiết |
|------------|----------|----------|
| Tables | 12 | NHACUNGCAP, KHACHHANG, NHANVIEN, LOAISANPHAM, SANPHAM, HOADON, CTHOADON, PHIEUNHAP, CTPHIEUNHAP, TAIKHOAN, LOG_TAIKHOAN, LOG_SANPHAM |
| Views | 5 | Chi tiết HD, Doanh thu tháng, SP bán chạy, Tồn kho, Nhập hàng |
| Functions | 6 | 4 Scalar + 2 Table-Valued |
| Stored Procedures | 13 | Login, CRUD SP, Bán hàng, Nhập hàng, Thống kê, Dashboard... |
| Triggers | 6 | Trừ/cộng kho, chặn xóa KH, auto tổng tiền, log tài khoản, log xóa SP |
| Cursors | 5 | Cảnh báo tồn kho, cuối ngày, nhập hàng NV, in HD, sale hàng tồn |
| Indexes | 7 | Trên các cột FK và cột thường query |
| Table Types | 2 | ChiTietHoaDonType, ChiTietPhieuNhapType |
| Transactions | 2 | PROC_BANHANG, PROC_NHAPHANG (BEGIN TRAN/COMMIT/ROLLBACK) |

---

## 🔐 Phân quyền

| Chức năng | Admin | Employee |
|-----------|-------|----------|
| Dashboard | ✅ | ✅ |
| Quản lý sản phẩm (Thêm/Sửa) | ✅ | ✅ |
| Xóa sản phẩm | ✅ | ❌ |
| Quản lý khách hàng | ✅ | ✅ |
| Quản lý nhân viên | ✅ | ❌ |
| Bán hàng | ✅ | ✅ |
| Nhập hàng | ✅ | ✅ |
| Thống kê | ✅ | ❌ |
| Backup/Restore | ✅ | ❌ |

---

## 📺 Các màn hình

1. **Login** — Đăng nhập hệ thống
2. **Dashboard** — Tổng quan (tổng SP, KH, doanh thu, SP sắp hết)
3. **Quản lý sản phẩm** — CRUD + tìm kiếm + filter theo loại
4. **Quản lý khách hàng** — CRUD đầy đủ
5. **Quản lý nhân viên** — CRUD (chỉ Admin)
6. **Bán hàng (POS)** — Chọn SP → thêm giỏ → thanh toán (có Transaction)
7. **Nhập hàng** — Tạo phiếu nhập từ NCC (có Transaction)
8. **Thống kê** — Doanh thu tháng, top SP, SP sắp hết
9. **Backup/Restore** — Sao lưu & khôi phục DB (chỉ Admin)
