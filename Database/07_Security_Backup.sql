-- ============================================================
--  PHẦN 7: SECURITY & BACKUP/RESTORE
-- ============================================================
USE QL_SHOPTHOITRANG
GO

-- ============================================================
-- PHÂN QUYỀN - TẠO ROLE
-- ============================================================

-- Tạo Role Admin
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Role_Admin')
    CREATE ROLE Role_Admin;
GO

-- Tạo Role Employee
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Role_Employee')
    CREATE ROLE Role_Employee;
GO

-- === QUYỀN CHO ADMIN (toàn quyền) ===
GRANT SELECT, INSERT, UPDATE, DELETE ON SANPHAM      TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON KHACHHANG    TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON NHANVIEN     TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON HOADON       TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON CTHOADON     TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PHIEUNHAP    TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON CTPHIEUNHAP  TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON TAIKHOAN     TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON LOAISANPHAM  TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON NHACUNGCAP   TO Role_Admin;
GRANT SELECT ON LOG_TAIKHOAN TO Role_Admin;
GRANT SELECT ON LOG_SANPHAM  TO Role_Admin;
GRANT EXECUTE TO Role_Admin;
GO

-- === QUYỀN CHO EMPLOYEE (hạn chế) ===
GRANT SELECT, INSERT, UPDATE ON SANPHAM     TO Role_Employee;
GRANT SELECT, INSERT, UPDATE ON KHACHHANG   TO Role_Employee;
GRANT SELECT ON NHANVIEN                    TO Role_Employee;
GRANT SELECT, INSERT ON HOADON             TO Role_Employee;
GRANT SELECT, INSERT ON CTHOADON           TO Role_Employee;
GRANT SELECT ON LOAISANPHAM                TO Role_Employee;
GRANT SELECT ON NHACUNGCAP                 TO Role_Employee;

-- Employee KHÔNG ĐƯỢC:
DENY DELETE ON SANPHAM    TO Role_Employee;  -- Không xóa sản phẩm
DENY DELETE ON NHANVIEN   TO Role_Employee;  -- Không xóa nhân viên
DENY DELETE ON KHACHHANG  TO Role_Employee;  -- Không xóa khách hàng

-- Employee được chạy các SP cần thiết
GRANT EXECUTE ON PROC_LOGIN           TO Role_Employee;
GRANT EXECUTE ON PROC_TIMSANPHAM      TO Role_Employee;
GRANT EXECUTE ON PROC_BANHANG         TO Role_Employee;
GRANT EXECUTE ON PROC_GETALL          TO Role_Employee;
GRANT EXECUTE ON PROC_CHITIET_HOADON  TO Role_Employee;
GRANT EXECUTE ON PROC_DASHBOARD       TO Role_Employee;
GRANT EXECUTE ON PROC_KHACHHANG       TO Role_Employee;
GRANT EXECUTE ON PROC_THONGKEDOANHTHU TO Role_Employee;
GO

-- ============================================================
-- BACKUP DATABASE
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_BACKUP_DATABASE
    @DuongDan NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(1000);
    SET @SQL = N'BACKUP DATABASE QL_SHOPTHOITRANG TO DISK = N''' + @DuongDan + N''' WITH FORMAT, INIT, NAME = N''QL_SHOPTHOITRANG Backup''';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT N'Backup database thành công! File: ' + @DuongDan;
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- RESTORE DATABASE
-- ============================================================
CREATE OR ALTER PROCEDURE PROC_RESTORE_DATABASE
    @DuongDan NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(1000);
    SET @SQL = N'USE master; ALTER DATABASE QL_SHOPTHOITRANG SET SINGLE_USER WITH ROLLBACK IMMEDIATE; RESTORE DATABASE QL_SHOPTHOITRANG FROM DISK = N''' + @DuongDan + N''' WITH REPLACE; ALTER DATABASE QL_SHOPTHOITRANG SET MULTI_USER;';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT N'Restore database thành công từ file: ' + @DuongDan;
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END;
GO

PRINT N'=== TẠO SECURITY & BACKUP/RESTORE THÀNH CÔNG ===';
GO
