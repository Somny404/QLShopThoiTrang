-- ============================================================
--  PHẦN 6: CURSORS (5 cursors - mỗi thành viên 1 cursor)
-- ============================================================
USE QL_SHOPTHOITRANG
GO

-- ============================================================
-- CURSOR 1: Cảnh báo sản phẩm tồn kho thấp
-- Duyệt từng SP, in cảnh báo nếu tồn kho <= ngưỡng
-- ============================================================
CREATE OR ALTER PROCEDURE SP_CURSOR_CANHBAO_TONKHO
    @Nguong INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MaSP VARCHAR(10), @TenSP NVARCHAR(100),
            @TonKho INT, @TenLoai NVARCHAR(50);
    DECLARE @KetQua TABLE (MaSP VARCHAR(10), TenSP NVARCHAR(100),
            TenLoai NVARCHAR(50), TonKho INT, MucCanh NVARCHAR(20));

    DECLARE cur_TonKho CURSOR FOR
    SELECT SP.MaSP, SP.TenSP, SP.SoLuongTon, L.TenLoai
    FROM SANPHAM SP
    JOIN LOAISANPHAM L ON SP.MaLoai = L.MaLoai
    ORDER BY SP.SoLuongTon ASC;

    OPEN cur_TonKho;
    FETCH NEXT FROM cur_TonKho INTO @MaSP, @TenSP, @TonKho, @TenLoai;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @TonKho <= @Nguong
        BEGIN
            INSERT INTO @KetQua VALUES (
                @MaSP, @TenSP, @TenLoai, @TonKho,
                CASE WHEN @TonKho = 0 THEN N'HẾT HÀNG'
                     ELSE N'SẮP HẾT' END
            );
            PRINT N'⚠ CẢNH BÁO: ' + @TenSP + N' - Tồn: ' + CAST(@TonKho AS NVARCHAR);
        END

        FETCH NEXT FROM cur_TonKho INTO @MaSP, @TenSP, @TonKho, @TenLoai;
    END

    CLOSE cur_TonKho;
    DEALLOCATE cur_TonKho;

    -- Trả về bảng kết quả
    SELECT * FROM @KetQua;
END;
GO

-- ============================================================
-- CURSOR 2: Thống kê hóa đơn cuối ngày
-- Duyệt từng HD trong ngày, tổng hợp báo cáo
-- ============================================================
CREATE OR ALTER PROCEDURE SP_CURSOR_THONGKE_CUOINGAY
    @NgayThongKe DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @NgayThongKe IS NULL SET @NgayThongKe = CAST(GETDATE() AS DATE);

    DECLARE @MaHD VARCHAR(10), @TongTien INT, @TenKH NVARCHAR(50);
    DECLARE @TongDoanhThu INT = 0, @SoHD INT = 0;

    DECLARE cur_CuoiNgay CURSOR FOR
    SELECT HD.MaHD, HD.TongTien, KH.TenKH
    FROM HOADON HD
    JOIN KHACHHANG KH ON HD.MaKH = KH.MaKH
    WHERE CAST(HD.NgayLap AS DATE) = @NgayThongKe;

    OPEN cur_CuoiNgay;
    FETCH NEXT FROM cur_CuoiNgay INTO @MaHD, @TongTien, @TenKH;

    PRINT N'====== BÁO CÁO CUỐI NGÀY: ' + CAST(@NgayThongKe AS NVARCHAR) + N' ======';

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SoHD = @SoHD + 1;
        SET @TongDoanhThu = @TongDoanhThu + ISNULL(@TongTien, 0);
        
        PRINT N'HD: ' + @MaHD + N' | KH: ' + @TenKH 
              + N' | Tổng: ' + CAST(@TongTien AS NVARCHAR) + N' VNĐ';

        FETCH NEXT FROM cur_CuoiNgay INTO @MaHD, @TongTien, @TenKH;
    END

    CLOSE cur_CuoiNgay;
    DEALLOCATE cur_CuoiNgay;

    PRINT N'============================================';
    PRINT N'Tổng số hóa đơn: ' + CAST(@SoHD AS NVARCHAR);
    PRINT N'Tổng doanh thu  : ' + CAST(@TongDoanhThu AS NVARCHAR) + N' VNĐ';

    -- Trả về kết quả
    SELECT @NgayThongKe AS NgayThongKe, @SoHD AS SoHoaDon, @TongDoanhThu AS TongDoanhThu;
END;
GO

-- ============================================================
-- CURSOR 3: Thống kê nhập hàng theo nhân viên
-- Duyệt từng NV, đếm số phiếu nhập và tổng giá trị
-- ============================================================
CREATE OR ALTER PROCEDURE SP_CURSOR_THONGKE_NHAPHANG_NV
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaNV VARCHAR(10), @TenNV NVARCHAR(50);
    DECLARE @SoPhieu INT, @TongGiaTri INT;
    DECLARE @KetQua TABLE (MaNV VARCHAR(10), TenNV NVARCHAR(50),
            SoPhieuNhap INT, TongGiaTriNhap INT);

    DECLARE cur_NhapHang CURSOR FOR
    SELECT MaNV, TenNV FROM NHANVIEN;

    OPEN cur_NhapHang;
    FETCH NEXT FROM cur_NhapHang INTO @MaNV, @TenNV;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @SoPhieu = COUNT(*) FROM PHIEUNHAP WHERE MaNV = @MaNV;
        SELECT @TongGiaTri = ISNULL(SUM(CT.SoLuong * CT.DonGia), 0)
        FROM PHIEUNHAP PN JOIN CTPHIEUNHAP CT ON PN.MaPN = CT.MaPN
        WHERE PN.MaNV = @MaNV;

        IF @SoPhieu > 0
        BEGIN
            INSERT INTO @KetQua VALUES (@MaNV, @TenNV, @SoPhieu, @TongGiaTri);
            PRINT N'NV ' + @TenNV + N': ' + CAST(@SoPhieu AS NVARCHAR) 
                  + N' phiếu, trị giá ' + CAST(@TongGiaTri AS NVARCHAR) + N' VNĐ';
        END

        FETCH NEXT FROM cur_NhapHang INTO @MaNV, @TenNV;
    END

    CLOSE cur_NhapHang;
    DEALLOCATE cur_NhapHang;

    SELECT * FROM @KetQua ORDER BY TongGiaTriNhap DESC;
END;
GO

-- ============================================================
-- CURSOR 4: In chi tiết từng hóa đơn
-- Duyệt tất cả HD, in từng dòng chi tiết
-- ============================================================
CREATE OR ALTER PROCEDURE SP_CURSOR_IN_HOADON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaHD VARCHAR(10), @NgayLap DATE, @TongTien INT, @TenKH NVARCHAR(50);

    DECLARE cur_HoaDon CURSOR FOR
    SELECT HD.MaHD, HD.NgayLap, HD.TongTien, KH.TenKH
    FROM HOADON HD JOIN KHACHHANG KH ON HD.MaKH = KH.MaKH
    ORDER BY HD.NgayLap DESC;

    OPEN cur_HoaDon;
    FETCH NEXT FROM cur_HoaDon INTO @MaHD, @NgayLap, @TongTien, @TenKH;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT N'═══════════════════════════════════════';
        PRINT N'Hóa đơn : ' + @MaHD;
        PRINT N'Ngày lập: ' + CAST(@NgayLap AS NVARCHAR);
        PRINT N'Khách   : ' + @TenKH;
        PRINT N'Tổng tiền: ' + CAST(ISNULL(@TongTien,0) AS NVARCHAR) + N' VNĐ';
        PRINT N'Chi tiết:';

        -- In chi tiết của hóa đơn này
        SELECT SP.TenSP, CT.SoLuong, CT.DonGia, (CT.SoLuong*CT.DonGia) AS ThanhTien
        FROM CTHOADON CT JOIN SANPHAM SP ON CT.MaSP = SP.MaSP
        WHERE CT.MaHD = @MaHD;

        FETCH NEXT FROM cur_HoaDon INTO @MaHD, @NgayLap, @TongTien, @TenKH;
    END

    CLOSE cur_HoaDon;
    DEALLOCATE cur_HoaDon;
END;
GO

-- ============================================================
-- CURSOR 5: Tự động giảm giá sản phẩm tồn kho lâu
-- Duyệt SP có tồn > 30, giảm 10% giá bán
-- ============================================================
CREATE OR ALTER PROCEDURE SP_CURSOR_SALE_HANGTON
    @NguongTon INT = 30,
    @PhanTramGiam DECIMAL(5,2) = 10.0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaSP VARCHAR(10), @TenSP NVARCHAR(100),
            @TonKho INT, @GiaBan INT, @GiaMoi INT;
    DECLARE @SoSPGiam INT = 0;

    DECLARE cur_Sale CURSOR FOR
    SELECT MaSP, TenSP, SoLuongTon, GiaBan
    FROM SANPHAM
    WHERE SoLuongTon > @NguongTon AND GiaBan > 10000;

    OPEN cur_Sale;
    FETCH NEXT FROM cur_Sale INTO @MaSP, @TenSP, @TonKho, @GiaBan;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @GiaMoi = CAST(@GiaBan * (100 - @PhanTramGiam) / 100 AS INT);
        
        UPDATE SANPHAM SET GiaBan = @GiaMoi WHERE MaSP = @MaSP;
        SET @SoSPGiam = @SoSPGiam + 1;

        PRINT N'✓ Giảm giá: ' + @TenSP 
              + N' | Giá cũ: ' + CAST(@GiaBan AS NVARCHAR)
              + N' → Giá mới: ' + CAST(@GiaMoi AS NVARCHAR);

        FETCH NEXT FROM cur_Sale INTO @MaSP, @TenSP, @TonKho, @GiaBan;
    END

    CLOSE cur_Sale;
    DEALLOCATE cur_Sale;

    PRINT N'Tổng số SP được giảm giá: ' + CAST(@SoSPGiam AS NVARCHAR);
END;
GO

-- Test cursors
EXEC SP_CURSOR_CANHBAO_TONKHO @Nguong = 20;
GO
EXEC SP_CURSOR_THONGKE_CUOINGAY @NgayThongKe = '2025-01-10';
GO

PRINT N'=== TẠO 5 CURSORS THÀNH CÔNG ===';
GO
