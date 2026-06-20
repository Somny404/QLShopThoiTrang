using System;

namespace DTO
{
    public class KhachHangDTO
    {
        public string MaKH { get; set; }
        public string TenKH { get; set; }
        public string DienThoai { get; set; }
        public string Email { get; set; }
        public string DiaChi { get; set; }

        public KhachHangDTO() { }
        public KhachHangDTO(string maKH, string tenKH, string dienThoai, string email, string diaChi)
        {
            MaKH = maKH; TenKH = tenKH; DienThoai = dienThoai; Email = email; DiaChi = diaChi;
        }
    }

    public class NhanVienDTO
    {
        public string MaNV { get; set; }
        public string TenNV { get; set; }
        public string GioiTinh { get; set; }
        public string DienThoai { get; set; }
        public string CMND { get; set; }
        public string ChucVu { get; set; }
        public DateTime? NgayVaoLam { get; set; }
        public string TrinhDo { get; set; }

        public NhanVienDTO() { }
    }

    public class LoaiSanPhamDTO
    {
        public string MaLoai { get; set; }
        public string TenLoai { get; set; }
        public string MoTa { get; set; }
    }

    public class TaiKhoanDTO
    {
        public string MaNV { get; set; }
        public string TenDN { get; set; }
        public string MatKhau { get; set; }
        public string VaiTro { get; set; }
        public string TrangThai { get; set; }
        public string TenNV { get; set; }    // Từ JOIN
        public string ChucVu { get; set; }   // Từ JOIN
    }

    public class HoaDonDTO
    {
        public string MaHD { get; set; }
        public DateTime NgayLap { get; set; }
        public int TongTien { get; set; }
        public string MaKH { get; set; }
        public string MaNV { get; set; }
        public string TenKH { get; set; }    // Từ JOIN
        public string TenNV { get; set; }    // Từ JOIN
    }

    public class CTHoaDonDTO
    {
        public string MaHD { get; set; }
        public string MaSP { get; set; }
        public string TenSP { get; set; }
        public int SoLuong { get; set; }
        public int DonGia { get; set; }
        public int ThanhTien => SoLuong * DonGia;
    }

    public class PhieuNhapDTO
    {
        public string MaPN { get; set; }
        public DateTime NgayNhap { get; set; }
        public string MaNV { get; set; }
        public string MaNCC { get; set; }
        public int TongTien { get; set; }
        public string TenNV { get; set; }
        public string TenNCC { get; set; }
    }

    public class CTPhieuNhapDTO
    {
        public string MaPN { get; set; }
        public string MaSP { get; set; }
        public string TenSP { get; set; }
        public int SoLuong { get; set; }
        public int DonGia { get; set; }
        public int ThanhTien => SoLuong * DonGia;
    }

    public class NhaCungCapDTO
    {
        public string MaNCC { get; set; }
        public string TenNCC { get; set; }
        public string DienThoai { get; set; }
        public string DiaChi { get; set; }
        public string Email { get; set; }
    }

    public class ThongKeDTO
    {
        public int Thang { get; set; }
        public int Nam { get; set; }
        public int SoHoaDon { get; set; }
        public int DoanhThu { get; set; }
        public string MaSP { get; set; }
        public string TenSP { get; set; }
        public int SoLuongBan { get; set; }
    }
}
