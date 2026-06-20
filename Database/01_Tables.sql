-- ============================================================
--  ĐỒ ÁN: QUẢN LÝ SHOP THỜI TRANG
--  Môn  : Hệ Quản Trị Cơ Sở Dữ Liệu
--  Nhóm : 8 (5 thành viên)
-- ============================================================
-- PHẦN 1: TẠO DATABASE VÀ BẢNG
-- ============================================================

CREATE DATABASE QL_SHOPTHOITRANG
GO
USE QL_SHOPTHOITRANG
GO

-- ============================================================
--  BẢNG 1: NHÀ CUNG CẤP
-- ============================================================
CREATE TABLE NHACUNGCAP (
    MaNCC     VARCHAR(10)   PRIMARY KEY,
    TenNCC    NVARCHAR(100) NOT NULL,
    DienThoai VARCHAR(15),
    DiaChi    NVARCHAR(200),
    Email     VARCHAR(50)
);

-- ============================================================
--  BẢNG 2: KHÁCH HÀNG
-- ============================================================
CREATE TABLE KHACHHANG (
    MaKH      VARCHAR(10)   PRIMARY KEY,
    TenKH     NVARCHAR(50)  NOT NULL,
    DienThoai VARCHAR(15),
    Email     VARCHAR(50),
    DiaChi    NVARCHAR(100)
);

-- ============================================================
--  BẢNG 3: NHÂN VIÊN
-- ============================================================
CREATE TABLE NHANVIEN (
    MaNV       VARCHAR(10)  PRIMARY KEY,
    TenNV      NVARCHAR(50) NOT NULL,
    GioiTinh   NVARCHAR(5)  CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    DienThoai  VARCHAR(15),
    CMND       VARCHAR(12)  UNIQUE,
    ChucVu     NVARCHAR(30),
    NgayVaoLam DATE         DEFAULT GETDATE(),
    TrinhDo    NVARCHAR(50)
);

-- ============================================================
--  BẢNG 4: LOẠI SẢN PHẨM
-- ============================================================
CREATE TABLE LOAISANPHAM (
    MaLoai  VARCHAR(10)   PRIMARY KEY,
    TenLoai NVARCHAR(50)  NOT NULL,
    MoTa    NVARCHAR(100)
);

-- ============================================================
--  BẢNG 5: SẢN PHẨM
-- ============================================================
CREATE TABLE SANPHAM (
    MaSP       VARCHAR(10)   PRIMARY KEY,
    TenSP      NVARCHAR(100) NOT NULL,
    GiaBan     INT           CHECK (GiaBan > 0),
    SoLuongTon INT           DEFAULT 0 CHECK (SoLuongTon >= 0),
    Size       NVARCHAR(5),
    MauSac     NVARCHAR(20),
    MaLoai     VARCHAR(10),
    CONSTRAINT FK_SANPHAM_LOAI FOREIGN KEY (MaLoai) REFERENCES LOAISANPHAM(MaLoai)
);

-- ============================================================
--  BẢNG 6: HÓA ĐƠN
-- ============================================================
CREATE TABLE HOADON (
    MaHD     VARCHAR(10) PRIMARY KEY,
    NgayLap  DATE        DEFAULT GETDATE(),
    TongTien INT         DEFAULT 0 CHECK (TongTien >= 0),
    MaKH     VARCHAR(10),
    MaNV     VARCHAR(10),
    CONSTRAINT FK_HD_KH FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH),
    CONSTRAINT FK_HD_NV FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);

-- ============================================================
--  BẢNG 7: CHI TIẾT HÓA ĐƠN
-- ============================================================
CREATE TABLE CTHOADON (
    MaHD      VARCHAR(10),
    MaSP      VARCHAR(10),
    SoLuong   INT CHECK (SoLuong > 0),
    DonGia    INT CHECK (DonGia > 0),
    ThanhTien AS (SoLuong * DonGia),
    CONSTRAINT PK_CTHD    PRIMARY KEY (MaHD, MaSP),
    CONSTRAINT FK_CTHD_HD FOREIGN KEY (MaHD) REFERENCES HOADON(MaHD),
    CONSTRAINT FK_CTHD_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);

-- ============================================================
--  BẢNG 8: PHIẾU NHẬP
-- ============================================================
CREATE TABLE PHIEUNHAP (
    MaPN     VARCHAR(10) PRIMARY KEY,
    NgayNhap DATE        DEFAULT GETDATE(),
    MaNV     VARCHAR(10),
    MaNCC    VARCHAR(10),
    TongTien INT         DEFAULT 0,
    CONSTRAINT FK_PN_NV  FOREIGN KEY (MaNV)  REFERENCES NHANVIEN(MaNV),
    CONSTRAINT FK_PN_NCC FOREIGN KEY (MaNCC) REFERENCES NHACUNGCAP(MaNCC)
);

-- ============================================================
--  BẢNG 9: CHI TIẾT PHIẾU NHẬP
-- ============================================================
CREATE TABLE CTPHIEUNHAP (
    MaPN    VARCHAR(10),
    MaSP    VARCHAR(10),
    SoLuong INT CHECK (SoLuong > 0),
    DonGia  INT CHECK (DonGia > 0),
    CONSTRAINT PK_CTPN    PRIMARY KEY (MaPN, MaSP),
    CONSTRAINT FK_CTPN_PN FOREIGN KEY (MaPN) REFERENCES PHIEUNHAP(MaPN),
    CONSTRAINT FK_CTPN_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);

-- ============================================================
--  BẢNG 10: TÀI KHOẢN (có phân quyền Role)
-- ============================================================
CREATE TABLE TAIKHOAN (
    MaNV      VARCHAR(10)  PRIMARY KEY,
    TenDN     VARCHAR(30)  UNIQUE NOT NULL,
    MatKhau   VARCHAR(100) NOT NULL,
    VaiTro    NVARCHAR(20) DEFAULT N'Employee' CHECK (VaiTro IN (N'Admin', N'Employee')),
    TrangThai NVARCHAR(20) DEFAULT N'Hoạt động',
    CONSTRAINT FK_TK_NV FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);

-- ============================================================
--  BẢNG 11: LOG TÀI KHOẢN
-- ============================================================
CREATE TABLE LOG_TAIKHOAN (
    MaLog        INT          IDENTITY(1,1) PRIMARY KEY,
    MaNV         VARCHAR(10),
    TenDN        VARCHAR(30),
    TrangThaiCu  NVARCHAR(20),
    TrangThaiMoi NVARCHAR(20),
    ThoiGian     DATETIME     DEFAULT GETDATE(),
    GhiChu       NVARCHAR(200)
);

-- ============================================================
--  BẢNG 12: LOG SẢN PHẨM (ghi log khi xóa)
-- ============================================================
CREATE TABLE LOG_SANPHAM (
    MaLog      INT           IDENTITY(1,1) PRIMARY KEY,
    MaSP       VARCHAR(10),
    TenSP      NVARCHAR(100),
    GiaBan     INT,
    SoLuongTon INT,
    MaLoai     VARCHAR(10),
    NgayXoa    DATETIME      DEFAULT GETDATE(),
    NguoiXoa   NVARCHAR(50)
);
GO

-- ============================================================
--  TABLE TYPE cho Transaction bán hàng / nhập hàng
-- ============================================================
CREATE TYPE dbo.ChiTietHoaDonType AS TABLE (
    MaSP    VARCHAR(10),
    SoLuong INT,
    DonGia  INT
);
GO

CREATE TYPE dbo.ChiTietPhieuNhapType AS TABLE (
    MaSP    VARCHAR(10),
    SoLuong INT,
    DonGia  INT
);
GO

-- ============================================================
--  INDEXES
-- ============================================================
CREATE INDEX IX_SANPHAM_MALOAI   ON SANPHAM(MaLoai);
CREATE INDEX IX_HOADON_NGAYLAP   ON HOADON(NgayLap);
CREATE INDEX IX_HOADON_MAKH      ON HOADON(MaKH);
CREATE INDEX IX_HOADON_MANV      ON HOADON(MaNV);
CREATE INDEX IX_CTHOADON_MASP    ON CTHOADON(MaSP);
CREATE INDEX IX_PHIEUNHAP_MANV   ON PHIEUNHAP(MaNV);
CREATE INDEX IX_PHIEUNHAP_MANCC  ON PHIEUNHAP(MaNCC);
GO

-- ============================================================
--  DỮ LIỆU MẪU
-- ============================================================

INSERT INTO NHACUNGCAP VALUES
('NCC01', N'Công ty May Việt Tiến',   '02838456789', N'12 Lý Thường Kiệt, Q.5, TP.HCM',   'viettien@mail.com'),
('NCC02', N'Công ty Thời Trang Canifa','02839876543', N'45 Nguyễn Trãi, Q.1, TP.HCM',       'canifa@mail.com'),
('NCC03', N'Xưởng May Đông Xuân',      '02438765432', N'Chợ Đông Xuân, Hoàn Kiếm, Hà Nội', 'dongxuan@mail.com');

INSERT INTO LOAISANPHAM VALUES
('L01', N'Áo',       N'Các loại áo thời trang'),
('L02', N'Quần',     N'Các loại quần'),
('L03', N'Váy',      N'Váy nữ các kiểu'),
('L04', N'Phụ kiện', N'Thắt lưng, nón, túi xách');

INSERT INTO SANPHAM VALUES
('SP01', N'Áo thun nam',       150000, 50,  'M',  N'Trắng',    'L01'),
('SP02', N'Áo sơ mi nữ',      220000, 30,  'L',  N'Xanh',     'L01'),
('SP03', N'Quần jean nam',     350000, 40,  '32', N'Xanh đậm', 'L02'),
('SP04', N'Váy công sở',       450000, 20,  'M',  N'Đen',      'L03'),
('SP05', N'Nón thời trang',     90000, 100, NULL, N'Đỏ',       'L04'),
('SP06', N'Áo khoác dù',      280000, 35,  'L',  N'Đen',      'L01'),
('SP07', N'Quần tây nữ',      320000, 25,  'M',  N'Xám',      'L02'),
('SP08', N'Váy maxi',          550000, 15,  'L',  N'Hồng',     'L03'),
('SP09', N'Túi xách thời trang',390000, 8, NULL,  N'Nâu',      'L04'),
('SP10', N'Thắt lưng da',      180000, 45,  NULL, N'Đen',      'L04');

INSERT INTO KHACHHANG VALUES
('KH01', N'Trần Văn Hùng',       '0912345678', 'hung.tv@gmail.com',   N'Long An'),
('KH02', N'Phạm Thị Mai',        '0923456789', 'mai.pt@gmail.com',    N'Đồng Nai'),
('KH03', N'Hoàng Đức Anh',       '0976348981', 'anh.hd@gmail.com',    N'TP HCM'),
('KH04', N'Đặng Minh Châu',      '0923477868', 'chau.dm@gmail.com',   N'Daklak'),
('KH05', N'Bùi Thanh Tùng',      '0977483924', 'tung.bt@gmail.com',   N'Đà Lạt'),
('KH06', N'Ngô Quỳnh Như',       '0938765432', 'nhu.nq@gmail.com',    N'Bình Dương'),
('KH07', N'Lý Hải Đăng',         '0967891234', 'dang.lh@gmail.com',   N'Cần Thơ'),
('KH08', N'Đinh Xuân Bách',      '0951237890', 'bach.dx@gmail.com',   N'Hà Nội'),
('KH09', N'Lê Minh Châu',        '0981223344', 'chau.lm@gmail.com',   N'Nghệ An'),
('KH10', N'Vũ Hà Phương',        '0911223355', 'phuong.vh@gmail.com', N'Thanh Hóa'),
('KH11', N'Nguyễn Thanh Hùng',   '0922334455', 'hung.nt@gmail.com',   N'Hà Tĩnh'),
('KH12', N'Phan Đình Phùng',     '0933445566', 'phung.pd@gmail.com',  N'Quảng Bình'),
('KH13', N'Hồ Quang Hiếu',       '0944556677', 'hieu.hq@gmail.com',   N'Quảng Trị'),
('KH14', N'Trịnh Công Sơn',      '0955667788', 'son.tc@gmail.com',    N'Huế'),
('KH15', N'Lý Nhã Kỳ',           '0966778899', 'ky.ln@gmail.com',     N'Đà Nẵng'),
('KH16', N'Đoàn Văn Hậu',        '0977889900', 'hau.dv@gmail.com',    N'Quảng Nam'),
('KH17', N'Trần Đình Trọng',     '0988990011', 'trong.td@gmail.com',  N'Quảng Ngãi'),
('KH18', N'Nguyễn Quang Hải',    '0999001122', 'hai.nq@gmail.com',    N'Bình Định');

INSERT INTO NHANVIEN VALUES
('NV01', N'Nguyễn Trường Sơn',   N'Nam', '0987654321', '123456789001', N'Quản lý',            '2022-01-10', N'Đại học'),
('NV02', N'Lương Vân Nam',       N'Nam', '0976543210', '123456789002', N'Nhân viên bán hàng', '2022-02-15', N'Đại học'),
('NV03', N'Võ Công Tài',         N'Nam', '0911345640', '123456789003', N'Nhân viên bán hàng', '2023-03-20', N'Đại học'),
('NV04', N'Lê Minh Thành',       N'Nam', '0926786220', '123456789004', N'Nhân viên kho',      '2023-04-18', N'Cao đẳng'),
('NV05', N'Trương Triệu Quang',  N'Nam', '0966383930', '123456789005', N'Nhân viên tư vấn',   '2023-05-22', N'Đại học');

INSERT INTO TAIKHOAN VALUES
('NV01', 'admin',    '123456', N'Admin',    N'Hoạt động'),
('NV02', 'namlv',    '123456', N'Employee', N'Hoạt động'),
('NV03', 'taivc',    '123456', N'Employee', N'Hoạt động'),
('NV04', 'thanhlm',  '123456', N'Employee', N'Hoạt động'),
('NV05', 'quangtt',  '123456', N'Employee', N'Hoạt động');

INSERT INTO HOADON (MaHD, NgayLap, TongTien, MaKH, MaNV) VALUES
('HD01', '2025-01-10', 390000,  'KH01', 'NV02'),
('HD02', '2025-01-12', 450000,  'KH02', 'NV02'),
('HD03', '2025-01-15', 750000,  'KH03', 'NV02'),
('HD04', '2025-02-12', 500000,  'KH04', 'NV02'),
('HD05', '2025-02-22', 290000,  'KH05', 'NV02'),
('HD06', '2025-03-05', 830000,  'KH01', 'NV03'),
('HD07', '2025-03-18', 1100000, 'KH03', 'NV02'),
('HD08', '2025-04-02', 640000,  'KH02', 'NV05');

INSERT INTO CTHOADON (MaHD, MaSP, SoLuong, DonGia) VALUES
('HD01', 'SP01', 2, 150000),
('HD01', 'SP05', 1,  90000),
('HD02', 'SP04', 1, 450000),
('HD03', 'SP03', 2, 350000),
('HD03', 'SP05', 1,  50000),
('HD04', 'SP02', 1, 220000),
('HD04', 'SP06', 1, 280000),
('HD05', 'SP05', 2,  90000),
('HD05', 'SP10', 1, 110000),
('HD06', 'SP06', 2, 280000),
('HD06', 'SP07', 1, 270000),
('HD07', 'SP08', 2, 550000),
('HD08', 'SP09', 1, 390000),
('HD08', 'SP10', 1, 180000),
('HD08', 'SP05', 1,  70000);

INSERT INTO PHIEUNHAP VALUES
('PN01', '2025-01-05', 'NV01', 'NCC01', 11400000),
('PN02', '2025-01-08', 'NV02', 'NCC02', 18000000),
('PN03', '2025-01-12', 'NV03', 'NCC01', 17800000),
('PN04', '2025-01-15', 'NV04', 'NCC03', 13400000),
('PN05', '2025-01-18', 'NV05', 'NCC02', 8250000);

INSERT INTO CTPHIEUNHAP VALUES
('PN01', 'SP01',  50, 120000),
('PN01', 'SP02',  30, 180000),
('PN02', 'SP03',  40, 300000),
('PN02', 'SP05', 100,  60000),
('PN03', 'SP01',  60, 130000),
('PN03', 'SP04',  25, 400000),
('PN04', 'SP02',  35, 200000),
('PN04', 'SP03',  20, 320000),
('PN05', 'SP05', 150,  55000);
GO

PRINT N'=== TẠO BẢNG VÀ DỮ LIỆU MẪU THÀNH CÔNG ===';
GO
