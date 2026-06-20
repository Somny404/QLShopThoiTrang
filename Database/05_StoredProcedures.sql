-- ============================================================
--  PHẦN 5: STORED PROCEDURES
-- ============================================================
USE QL_SHOPTHOITRANG
GO

-- ============================================================
-- SP 1: ĐĂNG NHẬP
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_LOGIN
    @TenDN    VARCHAR(30),
    @MatKhau  VARCHAR(100),
    @KetQua   INT OUTPUT  -- 1: thành công, 0: sai MK, -1: không tồn tại, -2: bị khóa
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM TAIKHOAN WHERE TenDN = @TenDN)
    BEGIN
        SET @KetQua = -1;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE TenDN = @TenDN AND TrangThai = N'Vô hiệu')
    BEGIN
        SET @KetQua = -2;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM TAIKHOAN WHERE TenDN = @TenDN AND MatKhau = @MatKhau)
    BEGIN
        SET @KetQua = 0;
        RETURN;
    END

    -- Đăng nhập thành công, trả về thông tin
    SELECT TK.MaNV, TK.TenDN, TK.VaiTro, NV.TenNV, NV.ChucVu
    FROM TAIKHOAN TK
    JOIN NHANVIEN NV ON TK.MaNV = NV.MaNV
    WHERE TK.TenDN = @TenDN;

    SET @KetQua = 1;
END;
GO

-- ============================================================
-- SP 2: THÊM SẢN PHẨM
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_THEMSANPHAM
    @MaSP       VARCHAR(10),
    @TenSP      NVARCHAR(100),
    @GiaBan     INT,
    @SoLuongTon INT,
    @Size       NVARCHAR(5),
    @MauSac     NVARCHAR(20),
    @MaLoai     VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM SANPHAM WHERE MaSP = @MaSP)
    BEGIN
        RAISERROR(N'Mã sản phẩm đã tồn tại!', 16, 1);
        RETURN;
    END

    IF @GiaBan <= 0
    BEGIN
        RAISERROR(N'Giá bán phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM LOAISANPHAM WHERE MaLoai = @MaLoai)
    BEGIN
        RAISERROR(N'Mã loại sản phẩm không tồn tại!', 16, 1);
        RETURN;
    END

    INSERT INTO SANPHAM (MaSP, TenSP, GiaBan, SoLuongTon, Size, MauSac, MaLoai)
    VALUES (@MaSP, @TenSP, @GiaBan, @SoLuongTon, @Size, @MauSac, @MaLoai);

    PRINT N'Thêm sản phẩm thành công!';
END;
GO

-- ============================================================
-- SP 3: SỬA SẢN PHẨM
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_SUASANPHAM
    @MaSP       VARCHAR(10),
    @TenSP      NVARCHAR(100),
    @GiaBan     INT,
    @SoLuongTon INT,
    @Size       NVARCHAR(5),
    @MauSac     NVARCHAR(20),
    @MaLoai     VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM SANPHAM WHERE MaSP = @MaSP)
    BEGIN
        RAISERROR(N'Sản phẩm không tồn tại!', 16, 1);
        RETURN;
    END

    UPDATE SANPHAM
    SET TenSP      = @TenSP,
        GiaBan     = @GiaBan,
        SoLuongTon = @SoLuongTon,
        Size       = @Size,
        MauSac     = @MauSac,
        MaLoai     = @MaLoai
    WHERE MaSP = @MaSP;

    PRINT N'Cập nhật sản phẩm thành công!';
END;
GO

-- ============================================================
-- SP 4: XÓA SẢN PHẨM (kiểm tra ràng buộc)
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_XOASANPHAM
    @MaSP VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM SANPHAM WHERE MaSP = @MaSP)
    BEGIN
        RAISERROR(N'Sản phẩm không tồn tại!', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM CTHOADON WHERE MaSP = @MaSP)
    BEGIN
        RAISERROR(N'Không thể xóa sản phẩm đã có trong hóa đơn!', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM CTPHIEUNHAP WHERE MaSP = @MaSP)
    BEGIN
        RAISERROR(N'Không thể xóa sản phẩm đã có trong phiếu nhập!', 16, 1);
        RETURN;
    END

    -- Trigger TRG_LOG_XOASANPHAM sẽ tự động ghi log
    DELETE FROM SANPHAM WHERE MaSP = @MaSP;

    PRINT N'Xóa sản phẩm thành công!';
END;
GO

-- ============================================================
-- SP 5: TÌM SẢN PHẨM
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_TIMSANPHAM
    @TuKhoa NVARCHAR(100) = NULL,
    @MaLoai VARCHAR(10)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SP.MaSP, SP.TenSP, L.TenLoai, SP.GiaBan, SP.SoLuongTon,
           SP.Size, SP.MauSac, SP.MaLoai
    FROM SANPHAM SP
    JOIN LOAISANPHAM L ON SP.MaLoai = L.MaLoai
    WHERE (@TuKhoa IS NULL OR SP.TenSP LIKE N'%' + @TuKhoa + N'%'
           OR SP.MaSP LIKE '%' + @TuKhoa + '%')
      AND (@MaLoai IS NULL OR SP.MaLoai = @MaLoai)
    ORDER BY SP.MaSP;
END;
GO

-- ============================================================
-- SP 6: BÁN HÀNG (có TRANSACTION đầy đủ)
-- Mô tả: Tạo hóa đơn + chi tiết + trừ kho trong 1 transaction
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_BANHANG
    @MaHD    VARCHAR(10),
    @MaKH    VARCHAR(10),
    @MaNV    VARCHAR(10),
    @ChiTiet ChiTietHoaDonType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate: kiểm tra khách hàng
        IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
        BEGIN
            RAISERROR(N'Khách hàng không tồn tại!', 16, 1);
        END

        -- Validate: kiểm tra nhân viên
        IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE MaNV = @MaNV)
        BEGIN
            RAISERROR(N'Nhân viên không tồn tại!', 16, 1);
        END

        -- Validate: kiểm tra tồn kho đủ cho tất cả SP
        IF EXISTS (
            SELECT 1 FROM @ChiTiet ct
            JOIN SANPHAM sp ON sp.MaSP = ct.MaSP
            WHERE sp.SoLuongTon < ct.SoLuong
        )
        BEGIN
            RAISERROR(N'Không đủ hàng trong kho để bán!', 16, 1);
        END

        -- Tạo hóa đơn (TongTien = 0, trigger sẽ cập nhật)
        INSERT INTO HOADON (MaHD, NgayLap, TongTien, MaKH, MaNV)
        VALUES (@MaHD, GETDATE(), 0, @MaKH, @MaNV);

        -- Thêm chi tiết (trigger TRG_TRUTONKHO sẽ trừ kho, trigger TRG_CAPNHAT_TONGTIEN sẽ tính tổng)
        INSERT INTO CTHOADON (MaHD, MaSP, SoLuong, DonGia)
        SELECT @MaHD, MaSP, SoLuong, DonGia FROM @ChiTiet;

        COMMIT TRANSACTION;
        PRINT N'Bán hàng thành công! Mã hóa đơn: ' + @MaHD;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- SP 7: NHẬP HÀNG (có TRANSACTION đầy đủ)
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_NHAPHANG
    @MaPN    VARCHAR(10),
    @MaNV    VARCHAR(10),
    @MaNCC   VARCHAR(10),
    @ChiTiet ChiTietPhieuNhapType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE MaNV = @MaNV)
        BEGIN
            RAISERROR(N'Nhân viên không tồn tại!', 16, 1);
        END

        IF NOT EXISTS (SELECT 1 FROM NHACUNGCAP WHERE MaNCC = @MaNCC)
        BEGIN
            RAISERROR(N'Nhà cung cấp không tồn tại!', 16, 1);
        END

        -- Tính tổng tiền nhập
        DECLARE @TongTien INT;
        SELECT @TongTien = SUM(SoLuong * DonGia) FROM @ChiTiet;

        -- Tạo phiếu nhập
        INSERT INTO PHIEUNHAP (MaPN, NgayNhap, MaNV, MaNCC, TongTien)
        VALUES (@MaPN, GETDATE(), @MaNV, @MaNCC, @TongTien);

        -- Thêm chi tiết (trigger TRG_CONGTONKHO sẽ cộng kho)
        INSERT INTO CTPHIEUNHAP (MaPN, MaSP, SoLuong, DonGia)
        SELECT @MaPN, MaSP, SoLuong, DonGia FROM @ChiTiet;

        COMMIT TRANSACTION;
        PRINT N'Nhập hàng thành công! Mã phiếu: ' + @MaPN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- SP 8: THỐNG KÊ DOANH THU
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_THONGKEDOANHTHU
    @Thang INT = NULL,
    @Nam   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Nam IS NULL SET @Nam = YEAR(GETDATE());

    IF @Thang IS NOT NULL
    BEGIN
        -- Thống kê theo tháng cụ thể
        SELECT
            SP.MaSP, SP.TenSP,
            SUM(CT.SoLuong)             AS SoLuongBan,
            SUM(CT.SoLuong * CT.DonGia) AS DoanhThu
        FROM CTHOADON CT
        JOIN HOADON   HD ON CT.MaHD = HD.MaHD
        JOIN SANPHAM  SP ON CT.MaSP = SP.MaSP
        WHERE MONTH(HD.NgayLap) = @Thang AND YEAR(HD.NgayLap) = @Nam
        GROUP BY SP.MaSP, SP.TenSP
        ORDER BY DoanhThu DESC;
    END
    ELSE
    BEGIN
        -- Thống kê cả năm theo từng tháng
        SELECT
            MONTH(HD.NgayLap) AS Thang,
            COUNT(DISTINCT HD.MaHD) AS SoHoaDon,
            SUM(CT.SoLuong * CT.DonGia) AS DoanhThu
        FROM CTHOADON CT
        JOIN HOADON HD ON CT.MaHD = HD.MaHD
        WHERE YEAR(HD.NgayLap) = @Nam
        GROUP BY MONTH(HD.NgayLap)
        ORDER BY Thang;
    END
END;
GO

-- ============================================================
-- SP 9: CRUD KHÁCH HÀNG
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_KHACHHANG
    @HanhDong VARCHAR(10), -- 'THEM', 'SUA', 'XOA', 'GETALL'
    @MaKH     VARCHAR(10)  = NULL,
    @TenKH    NVARCHAR(50) = NULL,
    @DienThoai VARCHAR(15) = NULL,
    @Email    VARCHAR(50)  = NULL,
    @DiaChi   NVARCHAR(100)= NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @HanhDong = 'GETALL'
        SELECT * FROM KHACHHANG ORDER BY MaKH;

    ELSE IF @HanhDong = 'THEM'
    BEGIN
        IF EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
        BEGIN RAISERROR(N'Mã khách hàng đã tồn tại!', 16, 1); RETURN; END
        INSERT INTO KHACHHANG VALUES (@MaKH, @TenKH, @DienThoai, @Email, @DiaChi);
    END

    ELSE IF @HanhDong = 'SUA'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
        BEGIN RAISERROR(N'Khách hàng không tồn tại!', 16, 1); RETURN; END
        UPDATE KHACHHANG SET TenKH=@TenKH, DienThoai=@DienThoai, Email=@Email, DiaChi=@DiaChi
        WHERE MaKH = @MaKH;
    END

    ELSE IF @HanhDong = 'XOA'
        DELETE FROM KHACHHANG WHERE MaKH = @MaKH; -- Trigger sẽ chặn nếu có HD
END;
GO

-- ============================================================
-- SP 10: CRUD NHÂN VIÊN
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_NHANVIEN
    @HanhDong  VARCHAR(10),
    @MaNV      VARCHAR(10)  = NULL,
    @TenNV     NVARCHAR(50) = NULL,
    @GioiTinh  NVARCHAR(5)  = NULL,
    @DienThoai VARCHAR(15)  = NULL,
    @CMND      VARCHAR(12)  = NULL,
    @ChucVu    NVARCHAR(30) = NULL,
    @NgayVaoLam DATE        = NULL,
    @TrinhDo   NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @HanhDong = 'GETALL'
        SELECT * FROM NHANVIEN ORDER BY MaNV;

    ELSE IF @HanhDong = 'THEM'
    BEGIN
        IF EXISTS (SELECT 1 FROM NHANVIEN WHERE MaNV = @MaNV)
        BEGIN RAISERROR(N'Mã nhân viên đã tồn tại!', 16, 1); RETURN; END
        INSERT INTO NHANVIEN VALUES (@MaNV, @TenNV, @GioiTinh, @DienThoai, @CMND, @ChucVu, @NgayVaoLam, @TrinhDo);
    END

    ELSE IF @HanhDong = 'SUA'
    BEGIN
        UPDATE NHANVIEN SET TenNV=@TenNV, GioiTinh=@GioiTinh, DienThoai=@DienThoai,
               CMND=@CMND, ChucVu=@ChucVu, NgayVaoLam=@NgayVaoLam, TrinhDo=@TrinhDo
        WHERE MaNV = @MaNV;
    END

    ELSE IF @HanhDong = 'XOA'
    BEGIN
        IF EXISTS (SELECT 1 FROM HOADON WHERE MaNV = @MaNV)
        BEGIN RAISERROR(N'Không thể xóa nhân viên đã lập hóa đơn!', 16, 1); RETURN; END
        DELETE FROM TAIKHOAN WHERE MaNV = @MaNV;
        DELETE FROM NHANVIEN WHERE MaNV = @MaNV;
    END
END;
GO

-- ============================================================
-- SP 11: LẤY DANH SÁCH (dùng cho ComboBox, DataGrid)
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_GETALL
    @Bang VARCHAR(20) -- 'SANPHAM', 'KHACHHANG', 'NHANVIEN', 'LOAISANPHAM', 'HOADON', 'NHACUNGCAP'
AS
BEGIN
    SET NOCOUNT ON;
    IF @Bang = 'SANPHAM'
        SELECT SP.*, L.TenLoai FROM SANPHAM SP JOIN LOAISANPHAM L ON SP.MaLoai = L.MaLoai ORDER BY SP.MaSP;
    ELSE IF @Bang = 'KHACHHANG'
        SELECT * FROM KHACHHANG ORDER BY MaKH;
    ELSE IF @Bang = 'NHANVIEN'
        SELECT * FROM NHANVIEN ORDER BY MaNV;
    ELSE IF @Bang = 'LOAISANPHAM'
        SELECT * FROM LOAISANPHAM ORDER BY MaLoai;
    ELSE IF @Bang = 'HOADON'
        SELECT HD.*, KH.TenKH, NV.TenNV FROM HOADON HD
        JOIN KHACHHANG KH ON HD.MaKH = KH.MaKH
        JOIN NHANVIEN NV ON HD.MaNV = NV.MaNV ORDER BY HD.NgayLap DESC;
    ELSE IF @Bang = 'NHACUNGCAP'
        SELECT * FROM NHACUNGCAP ORDER BY MaNCC;
    ELSE IF @Bang = 'PHIEUNHAP'
        SELECT PN.*, NV.TenNV, NCC.TenNCC FROM PHIEUNHAP PN
        JOIN NHANVIEN NV ON PN.MaNV = NV.MaNV
        JOIN NHACUNGCAP NCC ON PN.MaNCC = NCC.MaNCC ORDER BY PN.NgayNhap DESC;
END;
GO

-- ============================================================
-- SP 12: LẤY CHI TIẾT HÓA ĐƠN
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_CHITIET_HOADON
    @MaHD VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CT.MaSP, SP.TenSP, CT.SoLuong, CT.DonGia, (CT.SoLuong * CT.DonGia) AS ThanhTien
    FROM CTHOADON CT JOIN SANPHAM SP ON CT.MaSP = SP.MaSP
    WHERE CT.MaHD = @MaHD;
END;
GO

-- ============================================================
-- SP 13: DASHBOARD - Lấy số liệu tổng quan
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_DASHBOARD
AS
BEGIN
    SET NOCOUNT ON;
    -- Tổng sản phẩm
    SELECT COUNT(*) AS TongSP FROM SANPHAM;
    -- Tổng khách hàng
    SELECT COUNT(*) AS TongKH FROM KHACHHANG;
    -- Doanh thu hôm nay
    SELECT ISNULL(SUM(CT.SoLuong * CT.DonGia), 0) AS DoanhThuHomNay
    FROM CTHOADON CT JOIN HOADON HD ON CT.MaHD = HD.MaHD
    WHERE CAST(HD.NgayLap AS DATE) = CAST(GETDATE() AS DATE);
    -- Tổng hóa đơn hôm nay
    SELECT COUNT(*) AS HoaDonHomNay FROM HOADON
    WHERE CAST(NgayLap AS DATE) = CAST(GETDATE() AS DATE);
    -- Sản phẩm sắp hết
    SELECT COUNT(*) AS SPSapHet FROM SANPHAM WHERE SoLuongTon <= 10;
END;
GO

PRINT N'=== TẠO 13 STORED PROCEDURES THÀNH CÔNG ===';
GO
