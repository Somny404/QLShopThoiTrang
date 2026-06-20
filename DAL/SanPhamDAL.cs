using System;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    /// <summary>
    /// DAL Sản phẩm - gọi các Stored Procedure CRUD sản phẩm
    /// </summary>
    public class SanPhamDAL
    {
        public static DataTable GetAll()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "SANPHAM") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }

        public static DataTable TimKiem(string tuKhoa, string maLoai)
        {
            SqlParameter[] pars = new SqlParameter[]
            {
                new SqlParameter("@TuKhoa", (object)tuKhoa ?? DBNull.Value),
                new SqlParameter("@MaLoai", (object)maLoai ?? DBNull.Value)
            };
            return DatabaseHelper.ExecuteQuery("PROC_TIMSANPHAM", pars);
        }

        public static int Them(string maSP, string tenSP, int giaBan, int soLuongTon,
                                string size, string mauSac, string maLoai)
        {
            SqlParameter[] pars = new SqlParameter[]
            {
                new SqlParameter("@MaSP", maSP),
                new SqlParameter("@TenSP", tenSP),
                new SqlParameter("@GiaBan", giaBan),
                new SqlParameter("@SoLuongTon", soLuongTon),
                new SqlParameter("@Size", (object)size ?? DBNull.Value),
                new SqlParameter("@MauSac", (object)mauSac ?? DBNull.Value),
                new SqlParameter("@MaLoai", maLoai)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_THEMSANPHAM", pars);
        }

        public static int Sua(string maSP, string tenSP, int giaBan, int soLuongTon,
                               string size, string mauSac, string maLoai)
        {
            SqlParameter[] pars = new SqlParameter[]
            {
                new SqlParameter("@MaSP", maSP),
                new SqlParameter("@TenSP", tenSP),
                new SqlParameter("@GiaBan", giaBan),
                new SqlParameter("@SoLuongTon", soLuongTon),
                new SqlParameter("@Size", (object)size ?? DBNull.Value),
                new SqlParameter("@MauSac", (object)mauSac ?? DBNull.Value),
                new SqlParameter("@MaLoai", maLoai)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_SUASANPHAM", pars);
        }

        public static int Xoa(string maSP)
        {
            SqlParameter[] pars = { new SqlParameter("@MaSP", maSP) };
            return DatabaseHelper.ExecuteNonQuery("PROC_XOASANPHAM", pars);
        }

        public static DataTable GetLoaiSanPham()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "LOAISANPHAM") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }
    }
}
