-- ============================================================
--  PHẦN 4: TRIGGERS (6 triggers)
-- ============================================================
USE QL_SHOPTHOITRANG
GO

-- ============================================================
-- TRIGGER 1: Tự động trừ tồn kho khi bán hàng
-- Xử lý đúng khi INSERT nhiều dòng cùng lúc
-- ============================================================
CREATE OR ALTER TRIGGER TRG_TRUTONKHO_KHIBAN
ON CTHOADON
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tồn kho đủ cho TẤT CẢ sản phẩm trong đơn
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SANPHAM sp ON sp.MaSP = i.MaSP
        WHERE sp.SoLuongTon < i.SoLuong
    )
    BEGIN
        RAISERROR(N'Không đủ hàng trong kho! Giao dịch bị hủy.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Trừ số lượng tồn kho
    UPDATE SANPHAM
    SET SoLuongTon = SoLuongTon - i.SoLuong
    FROM SANPHAM sp
    JOIN inserted i ON sp.MaSP = i.MaSP;

    PRINT N'[TRIGGER] Tồn kho đã được trừ sau khi bán hàng.';
END;
GO

-- ============================================================
-- TRIGGER 2: Tự động cộng tồn kho khi nhập hàng
-- ============================================================
CREATE OR ALTER TRIGGER TRG_CONGTONKHO_KHINHAP
ON CTPHIEUNHAP
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE SANPHAM
    SET SoLuongTon = SoLuongTon + i.SoLuong
    FROM SANPHAM sp
    JOIN inserted i ON sp.MaSP = i.MaSP;

    PRINT N'[TRIGGER] Tồn kho đã được cộng sau khi nhập hàng.';
END;
GO

-- ============================================================
-- TRIGGER 3: Ngăn xóa khách hàng đã có hóa đơn
-- ============================================================
CREATE OR ALTER TRIGGER TRG_NGANXOA_KHACHHANG
ON KHACHHANG
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN HOADON hd ON hd.MaKH = d.MaKH
    )
    BEGIN
        RAISERROR(N'Không thể xóa khách hàng đã có hóa đơn!', 16, 1);
        RETURN;
    END

    DELETE FROM KHACHHANG
    WHERE MaKH IN (SELECT MaKH FROM deleted);

    PRINT N'[TRIGGER] Xóa khách hàng thành công.';
END;
GO

-- ============================================================
-- TRIGGER 4: Tự động cập nhật TongTien hóa đơn
-- ============================================================
CREATE OR ALTER TRIGGER TRG_CAPNHAT_TONGTIEN
ON CTHOADON
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy danh sách MaHD bị ảnh hưởng
    DECLARE @AffectedHD TABLE (MaHD VARCHAR(10));
    INSERT INTO @AffectedHD
    SELECT MaHD FROM inserted
    UNION
    SELECT MaHD FROM deleted;

    -- Cập nhật tổng tiền
    UPDATE HOADON
    SET TongTien = ISNULL((
        SELECT SUM(ct.SoLuong * ct.DonGia)
        FROM CTHOADON ct
        WHERE ct.MaHD = HOADON.MaHD
    ), 0)
    WHERE MaHD IN (SELECT MaHD FROM @AffectedHD);

    PRINT N'[TRIGGER] TongTien hóa đơn đã được cập nhật.';
END;
GO

-- ============================================================
-- TRIGGER 5: Ghi log khi trạng thái tài khoản thay đổi
-- ============================================================
CREATE OR ALTER TRIGGER TRG_LOG_TAIKHOAN
ON TAIKHOAN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThai)
    BEGIN
        INSERT INTO LOG_TAIKHOAN (MaNV, TenDN, TrangThaiCu, TrangThaiMoi, GhiChu)
        SELECT
            i.MaNV,
            i.TenDN,
            d.TrangThai,
            i.TrangThai,
            CASE
                WHEN i.TrangThai = N'Vô hiệu'  THEN N'Tài khoản bị khóa'
                WHEN i.TrangThai = N'Hoạt động' THEN N'Tài khoản được mở lại'
                ELSE N'Thay đổi trạng thái'
            END
        FROM inserted i
        JOIN deleted  d ON d.MaNV = i.MaNV;

        PRINT N'[TRIGGER] Đã ghi log thay đổi tài khoản.';
    END
END;
GO

-- ============================================================
-- TRIGGER 6: Ghi log khi xóa sản phẩm
-- ============================================================
CREATE OR ALTER TRIGGER TRG_LOG_XOASANPHAM
ON SANPHAM
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO LOG_SANPHAM (MaSP, TenSP, GiaBan, SoLuongTon, MaLoai, NguoiXoa)
    SELECT
        d.MaSP,
        d.TenSP,
        d.GiaBan,
        d.SoLuongTon,
        d.MaLoai,
        SYSTEM_USER
    FROM deleted d;

    PRINT N'[TRIGGER] Đã ghi log sản phẩm bị xóa.';
END;
GO

PRINT N'=== TẠO 6 TRIGGERS THÀNH CÔNG ===';
GO
