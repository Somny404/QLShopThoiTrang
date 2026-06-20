-- ============================================================
--  PHẦN 2: VIEWS (5 Views - mỗi thành viên 1 view)
-- ============================================================
USE QL_SHOPTHOITRANG
GO

-- ============================================================
-- VIEW 1: Chi tiết hóa đơn đầy đủ thông tin
-- Mô tả: Kết hợp thông tin hóa đơn, khách hàng, nhân viên,
--         sản phẩm và chi tiết để xem tổng quan đơn hàng
-- ============================================================
CREATE OR ALTER VIEW VW_CHITIETHOADON AS
SELECT
    HD.MaHD,
    HD.NgayLap,
    KH.MaKH,
    KH.TenKH,
    KH.DienThoai AS SDT_KhachHang,
    NV.MaNV,
    NV.TenNV     AS NhanVienBan,
    SP.MaSP,
    SP.TenSP,
    L.TenLoai,
    CT.SoLuong,
    CT.DonGia,
    CT.SoLuong * CT.DonGia AS ThanhTien
FROM HOADON    HD
JOIN KHACHHANG KH ON HD.MaKH = KH.MaKH
JOIN NHANVIEN  NV ON HD.MaNV = NV.MaNV
JOIN CTHOADON  CT ON HD.MaHD = CT.MaHD
JOIN SANPHAM   SP ON CT.MaSP = SP.MaSP
JOIN LOAISANPHAM L ON SP.MaLoai = L.MaLoai;
GO

-- ============================================================
-- VIEW 2: Doanh thu theo tháng
-- Mô tả: Tổng hợp doanh thu bán hàng theo từng tháng/năm
-- ============================================================
CREATE OR ALTER VIEW VW_DOANHTHU_THANG AS
SELECT
    YEAR(HD.NgayLap)  AS Nam,
    MONTH(HD.NgayLap) AS Thang,
    COUNT(DISTINCT HD.MaHD) AS SoHoaDon,
    SUM(CT.SoLuong)         AS TongSoLuong,
    SUM(CT.SoLuong * CT.DonGia) AS DoanhThu
FROM HOADON   HD
JOIN CTHOADON CT ON HD.MaHD = CT.MaHD
GROUP BY YEAR(HD.NgayLap), MONTH(HD.NgayLap);
GO

-- ============================================================
-- VIEW 3: Sản phẩm bán chạy
-- Mô tả: Thống kê tổng số lượng bán và doanh thu của từng SP
-- ============================================================
CREATE OR ALTER VIEW VW_SANPHAM_BANCHAY AS
SELECT
    SP.MaSP,
    SP.TenSP,
    L.TenLoai,
    SP.GiaBan,
    ISNULL(SUM(CT.SoLuong), 0)             AS TongSoLuongBan,
    ISNULL(SUM(CT.SoLuong * CT.DonGia), 0) AS TongDoanhThu
FROM SANPHAM     SP
LEFT JOIN CTHOADON  CT ON SP.MaSP = CT.MaSP
JOIN LOAISANPHAM L  ON SP.MaLoai = L.MaLoai
GROUP BY SP.MaSP, SP.TenSP, L.TenLoai, SP.GiaBan;
GO

-- ============================================================
-- VIEW 4: Tổng hợp tồn kho sản phẩm
-- Mô tả: Hiển thị trạng thái kho của toàn bộ sản phẩm
-- ============================================================
CREATE OR ALTER VIEW VW_TONKHO_SANPHAM AS
SELECT
    SP.MaSP,
    SP.TenSP,
    L.TenLoai,
    SP.Size,
    SP.MauSac,
    SP.GiaBan,
    SP.SoLuongTon,
    SP.SoLuongTon * SP.GiaBan AS GiaTriTonKho,
    CASE
        WHEN SP.SoLuongTon = 0   THEN N'Hết hàng'
        WHEN SP.SoLuongTon <= 10 THEN N'Sắp hết'
        WHEN SP.SoLuongTon <= 30 THEN N'Bình thường'
        ELSE                          N'Còn nhiều'
    END AS TrangThaiKho
FROM SANPHAM     SP
JOIN LOAISANPHAM L ON SP.MaLoai = L.MaLoai;
GO

-- ============================================================
-- VIEW 5: Thống kê nhập hàng
-- Mô tả: Tổng hợp thông tin nhập hàng từ nhà cung cấp
-- ============================================================
CREATE OR ALTER VIEW VW_THONGKE_NHAPHANG AS
SELECT
    PN.MaPN,
    PN.NgayNhap,
    NV.TenNV      AS NhanVienNhap,
    NCC.TenNCC    AS NhaCungCap,
    SP.MaSP,
    SP.TenSP,
    CT.SoLuong,
    CT.DonGia,
    CT.SoLuong * CT.DonGia AS ThanhTien
FROM PHIEUNHAP   PN
JOIN NHANVIEN    NV  ON PN.MaNV  = NV.MaNV
JOIN NHACUNGCAP  NCC ON PN.MaNCC = NCC.MaNCC
JOIN CTPHIEUNHAP CT  ON PN.MaPN  = CT.MaPN
JOIN SANPHAM     SP  ON CT.MaSP  = SP.MaSP;
GO

-- Kiểm tra views
SELECT * FROM VW_CHITIETHOADON;
SELECT * FROM VW_DOANHTHU_THANG;
SELECT * FROM VW_SANPHAM_BANCHAY;
SELECT * FROM VW_TONKHO_SANPHAM;
SELECT * FROM VW_THONGKE_NHAPHANG;
GO

PRINT N'=== TẠO 5 VIEWS THÀNH CÔNG ===';
GO
