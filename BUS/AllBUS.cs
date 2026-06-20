using System;
using System.Data;
using System.Collections.Generic;
using DAL;
using DTO;

namespace BUS
{
    /// <summary>
    /// BUS Tài khoản - xử lý logic đăng nhập
    /// </summary>
    public class TaiKhoanBUS
    {
        public static DataTable DangNhap(string tenDN, string matKhau, out string thongBao)
        {
            // Validate đầu vào
            if (string.IsNullOrWhiteSpace(tenDN))
            {
                thongBao = "Vui lòng nhập tên đăng nhập!";
                return null;
            }
            if (string.IsNullOrWhiteSpace(matKhau))
            {
                thongBao = "Vui lòng nhập mật khẩu!";
                return null;
            }

            int ketQua;
            DataTable dt = TaiKhoanDAL.DangNhap(tenDN, matKhau, out ketQua);

            switch (ketQua)
            {
                case 1:  thongBao = "Đăng nhập thành công!"; return dt;
                case 0:  thongBao = "Sai mật khẩu!"; return null;
                case -1: thongBao = "Tài khoản không tồn tại!"; return null;
                case -2: thongBao = "Tài khoản đã bị khóa!"; return null;
                default: thongBao = "Lỗi không xác định!"; return null;
            }
        }
    }

    /// <summary>
    /// BUS Sản phẩm
    /// </summary>
    public class SanPhamBUS
    {
        public static DataTable GetAll() => SanPhamDAL.GetAll();
        public static DataTable GetLoaiSanPham() => SanPhamDAL.GetLoaiSanPham();
        public static DataTable TimKiem(string tuKhoa, string maLoai) => SanPhamDAL.TimKiem(tuKhoa, maLoai);

        public static bool Them(SanPhamDTO sp, out string thongBao)
        {
            if (string.IsNullOrWhiteSpace(sp.MaSP)) { thongBao = "Mã SP không được rỗng!"; return false; }
            if (string.IsNullOrWhiteSpace(sp.TenSP)) { thongBao = "Tên SP không được rỗng!"; return false; }
            if (sp.GiaBan <= 0) { thongBao = "Giá bán phải > 0!"; return false; }
            if (sp.SoLuongTon < 0) { thongBao = "Số lượng tồn không được âm!"; return false; }

            try
            {
                SanPhamDAL.Them(sp.MaSP, sp.TenSP, sp.GiaBan, sp.SoLuongTon, sp.Size, sp.MauSac, sp.MaLoai);
                thongBao = "Thêm sản phẩm thành công!";
                return true;
            }
            catch (Exception ex)
            {
                thongBao = ex.Message;
                return false;
            }
        }

        public static bool Sua(SanPhamDTO sp, out string thongBao)
        {
            if (string.IsNullOrWhiteSpace(sp.MaSP)) { thongBao = "Mã SP không được rỗng!"; return false; }
            if (sp.GiaBan <= 0) { thongBao = "Giá bán phải > 0!"; return false; }

            try
            {
                SanPhamDAL.Sua(sp.MaSP, sp.TenSP, sp.GiaBan, sp.SoLuongTon, sp.Size, sp.MauSac, sp.MaLoai);
                thongBao = "Cập nhật sản phẩm thành công!";
                return true;
            }
            catch (Exception ex) { thongBao = ex.Message; return false; }
        }

        public static bool Xoa(string maSP, out string thongBao)
        {
            try
            {
                SanPhamDAL.Xoa(maSP);
                thongBao = "Xóa sản phẩm thành công!";
                return true;
            }
            catch (Exception ex) { thongBao = ex.Message; return false; }
        }
    }

    /// <summary>
    /// BUS Khách hàng
    /// </summary>
    public class KhachHangBUS
    {
        public static DataTable GetAll() => KhachHangDAL.GetAll();

        public static bool Them(KhachHangDTO kh, out string msg)
        {
            if (string.IsNullOrWhiteSpace(kh.MaKH)) { msg = "Mã KH không được rỗng!"; return false; }
            if (string.IsNullOrWhiteSpace(kh.TenKH)) { msg = "Tên KH không được rỗng!"; return false; }
            try { KhachHangDAL.Them(kh); msg = "Thêm khách hàng thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        public static bool Sua(KhachHangDTO kh, out string msg)
        {
            try { KhachHangDAL.Sua(kh); msg = "Cập nhật thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        public static bool Xoa(string maKH, out string msg)
        {
            try { KhachHangDAL.Xoa(maKH); msg = "Xóa thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }
    }

    /// <summary>
    /// BUS Nhân viên
    /// </summary>
    public class NhanVienBUS
    {
        public static DataTable GetAll() => NhanVienDAL.GetAll();

        public static bool Them(NhanVienDTO nv, out string msg)
        {
            if (string.IsNullOrWhiteSpace(nv.MaNV)) { msg = "Mã NV không được rỗng!"; return false; }
            if (string.IsNullOrWhiteSpace(nv.TenNV)) { msg = "Tên NV không được rỗng!"; return false; }
            try { NhanVienDAL.Them(nv); msg = "Thêm nhân viên thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        public static bool Sua(NhanVienDTO nv, out string msg)
        {
            try { NhanVienDAL.Sua(nv); msg = "Cập nhật thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        public static bool Xoa(string maNV, out string msg)
        {
            try { NhanVienDAL.Xoa(maNV); msg = "Xóa thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }
    }

    /// <summary>
    /// BUS Hóa đơn - Bán hàng
    /// </summary>
    public class HoaDonBUS
    {
        public static DataTable GetAll() => HoaDonDAL.GetAll();
        public static DataTable GetChiTiet(string maHD) => HoaDonDAL.GetChiTiet(maHD);

        public static bool BanHang(string maHD, string maKH, string maNV,
                                    List<CTHoaDonDTO> chiTiet, out string msg)
        {
            if (string.IsNullOrWhiteSpace(maHD)) { msg = "Mã HD không được rỗng!"; return false; }
            if (string.IsNullOrWhiteSpace(maKH)) { msg = "Vui lòng chọn khách hàng!"; return false; }
            if (chiTiet == null || chiTiet.Count == 0) { msg = "Chưa có sản phẩm nào!"; return false; }

            try
            {
                HoaDonDAL.BanHang(maHD, maKH, maNV, chiTiet);
                msg = "Bán hàng thành công! Mã HD: " + maHD;
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }
    }

    /// <summary>
    /// BUS Nhập hàng
    /// </summary>
    public class NhapHangBUS
    {
        public static DataTable GetAll() => NhapHangDAL.GetAll();
        public static DataTable GetNhaCungCap() => NhapHangDAL.GetNhaCungCap();

        public static bool NhapHang(string maPN, string maNV, string maNCC,
                                     List<CTPhieuNhapDTO> chiTiet, out string msg)
        {
            if (chiTiet == null || chiTiet.Count == 0) { msg = "Chưa có sản phẩm nào!"; return false; }
            try
            {
                NhapHangDAL.NhapHang(maPN, maNV, maNCC, chiTiet);
                msg = "Nhập hàng thành công!";
                return true;
            }
            catch (Exception ex) { msg = ex.Message; return false; }
        }
    }

    /// <summary>
    /// BUS Thống kê
    /// </summary>
    public class ThongKeBUS
    {
        public static DataTable ThongKeDoanhThu(int? thang, int? nam) => ThongKeDAL.ThongKeDoanhThu(thang, nam);
        public static DataTable[] GetDashboard() => ThongKeDAL.GetDashboard();
        public static DataTable TopSanPhamBanChay(int topN) => ThongKeDAL.TopSanPhamBanChay(topN);
        public static DataTable SanPhamSapHet(int nguong) => ThongKeDAL.SanPhamSapHet(nguong);
    }

    /// <summary>
    /// BUS Backup/Restore
    /// </summary>
    public class BackupBUS
    {
        public static bool Backup(string path, out string msg)
        {
            try { BackupDAL.Backup(path); msg = "Backup thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }

        public static bool Restore(string path, out string msg)
        {
            try { BackupDAL.Restore(path); msg = "Restore thành công!"; return true; }
            catch (Exception ex) { msg = ex.Message; return false; }
        }
    }
}
