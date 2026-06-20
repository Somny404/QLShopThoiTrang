-- ============================================================
--  PHẦN 3: FUNCTIONS (Scalar + Table-Valued)
-- ============================================================
USE QL_SHOPTHOITRANG
GO

-- ============================================================
-- SCALAR FUNCTION 1: Tính tổng tiền một hóa đơn
-- ============================================================
CREATE OR ALTER FUNCTION FN_TINHTONG_HOADON (@MaHD VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @Tong INT;
    SELECT @Tong = SUM(SoLuong * DonGia)
    FROM CTHOADON
    WHERE MaHD = @MaHD;
    RETURN ISNULL(@Tong, 0);
END;
GO

-- ============================================================
-- SCALAR FUNCTION 2: Tính doanh thu theo tháng/năm
-- ============================================================
CREATE OR ALTER FUNCTION FN_DOANHTHU_THANG (@Thang INT, @Nam INT)
RETURNS INT
AS
BEGIN
    DECLARE @DoanhThu INT;
    SELECT @DoanhThu = SUM(CT.SoLuong * CT.DonGia)
    FROM CTHOADON CT
    JOIN HOADON HD ON CT.MaHD = HD.MaHD
    WHERE MONTH(HD.NgayLap) = @Thang
      AND YEAR(HD.NgayLap)  = @Nam;
    RETURN ISNULL(@DoanhThu, 0);
END;
GO

-- ============================================================
-- SCALAR FUNCTION 3: Đếm sản phẩm theo loại
-- ============================================================
CREATE OR ALTER FUNCTION FN_DEMSANPHAM_THELOAI (@MaLoai VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;
    SELECT @SoLuong = COUNT(*)
    FROM SANPHAM
    WHERE MaLoai = @MaLoai;
    RETURN ISNULL(@SoLuong, 0);
END;
GO

-- ============================================================
-- SCALAR FUNCTION 4: Tổng chi tiêu của khách hàng
-- ============================================================
CREATE OR ALTER FUNCTION FN_TONGCHI_KHACHHANG (@MaKH VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @Tong INT;
    SELECT @Tong = SUM(CT.SoLuong * CT.DonGia)
    FROM HOADON HD
    JOIN CTHOADON CT ON HD.MaHD = CT.MaHD
    WHERE HD.MaKH = @MaKH;
    RETURN ISNULL(@Tong, 0);
END;
GO

-- ============================================================
-- TABLE-VALUED FUNCTION 1: Top N sản phẩm bán chạy
-- ============================================================
CREATE OR ALTER FUNCTION FN_TOP_SANPHAM_BANCHAY (@TopN INT)
RETURNS TABLE
AS
RETURN (
    SELECT TOP (@TopN)
        SP.MaSP,
        SP.TenSP,
        L.TenLoai,
        SUM(CT.SoLuong)             AS TongBan,
        SUM(CT.SoLuong * CT.DonGia) AS DoanhThu
    FROM SANPHAM     SP
    JOIN CTHOADON    CT ON SP.MaSP   = CT.MaSP
    JOIN LOAISANPHAM L  ON SP.MaLoai = L.MaLoai
    GROUP BY SP.MaSP, SP.TenSP, L.TenLoai
    ORDER BY TongBan DESC
);
GO

-- ============================================================
-- TABLE-VALUED FUNCTION 2: Sản phẩm sắp hết hàng
-- ============================================================
CREATE OR ALTER FUNCTION FN_SANPHAM_SAPHETHANG (@NguongTon INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        SP.MaSP,
        SP.TenSP,
        L.TenLoai,
        SP.SoLuongTon,
        SP.GiaBan,
        CASE
            WHEN SP.SoLuongTon = 0 THEN N'Hết hàng'
            ELSE N'Sắp hết'
        END AS TrangThai
    FROM SANPHAM     SP
    JOIN LOAISANPHAM L ON SP.MaLoai = L.MaLoai
    WHERE SP.SoLuongTon <= @NguongTon
);
GO

-- Kiểm tra Functions
SELECT dbo.FN_TINHTONG_HOADON('HD01')       AS TongHD01;
SELECT dbo.FN_DOANHTHU_THANG(1, 2025)       AS DoanhThuT1;
SELECT dbo.FN_DEMSANPHAM_THELOAI('L01')     AS SoSPLoaiAo;
SELECT dbo.FN_TONGCHI_KHACHHANG('KH01')     AS TongChiKH01;
SELECT * FROM dbo.FN_TOP_SANPHAM_BANCHAY(5);
SELECT * FROM dbo.FN_SANPHAM_SAPHETHANG(10);
GO

PRINT N'=== TẠO FUNCTIONS THÀNH CÔNG ===';
GO
