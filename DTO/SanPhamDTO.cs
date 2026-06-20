using System;

namespace DTO
{
    /// <summary>
    /// DTO Sản phẩm - ánh xạ bảng SANPHAM
    /// </summary>
    public class SanPhamDTO
    {
        public string MaSP { get; set; }
        public string TenSP { get; set; }
        public int GiaBan { get; set; }
        public int SoLuongTon { get; set; }
        public string Size { get; set; }
        public string MauSac { get; set; }
        public string MaLoai { get; set; }
        public string TenLoai { get; set; } // Từ JOIN

        public SanPhamDTO() { }

        public SanPhamDTO(string maSP, string tenSP, int giaBan, int soLuongTon,
                          string size, string mauSac, string maLoai)
        {
            MaSP = maSP; TenSP = tenSP; GiaBan = giaBan;
            SoLuongTon = soLuongTon; Size = size; MauSac = mauSac; MaLoai = maLoai;
        }
    }
}
