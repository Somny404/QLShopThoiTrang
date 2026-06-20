using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using DTO;

namespace DAL
{
    public class KhachHangDAL
    {
        public static DataTable GetAll()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "KHACHHANG") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }

        public static int Them(KhachHangDTO kh)
        {
            SqlParameter[] pars = {
                new SqlParameter("@HanhDong", "THEM"),
                new SqlParameter("@MaKH", kh.MaKH),
                new SqlParameter("@TenKH", kh.TenKH),
                new SqlParameter("@DienThoai", (object)kh.DienThoai ?? DBNull.Value),
                new SqlParameter("@Email", (object)kh.Email ?? DBNull.Value),
                new SqlParameter("@DiaChi", (object)kh.DiaChi ?? DBNull.Value)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_KHACHHANG", pars);
        }

        public static int Sua(KhachHangDTO kh)
        {
            SqlParameter[] pars = {
                new SqlParameter("@HanhDong", "SUA"),
                new SqlParameter("@MaKH", kh.MaKH),
                new SqlParameter("@TenKH", kh.TenKH),
                new SqlParameter("@DienThoai", (object)kh.DienThoai ?? DBNull.Value),
                new SqlParameter("@Email", (object)kh.Email ?? DBNull.Value),
                new SqlParameter("@DiaChi", (object)kh.DiaChi ?? DBNull.Value)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_KHACHHANG", pars);
        }

        public static int Xoa(string maKH)
        {
            SqlParameter[] pars = {
                new SqlParameter("@HanhDong", "XOA"),
                new SqlParameter("@MaKH", maKH)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_KHACHHANG", pars);
        }
    }

    public class NhanVienDAL
    {
        public static DataTable GetAll()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "NHANVIEN") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }

        public static int Them(NhanVienDTO nv)
        {
            SqlParameter[] pars = {
                new SqlParameter("@HanhDong", "THEM"),
                new SqlParameter("@MaNV", nv.MaNV),
                new SqlParameter("@TenNV", nv.TenNV),
                new SqlParameter("@GioiTinh", (object)nv.GioiTinh ?? DBNull.Value),
                new SqlParameter("@DienThoai", (object)nv.DienThoai ?? DBNull.Value),
                new SqlParameter("@CMND", (object)nv.CMND ?? DBNull.Value),
                new SqlParameter("@ChucVu", (object)nv.ChucVu ?? DBNull.Value),
                new SqlParameter("@NgayVaoLam", (object)nv.NgayVaoLam ?? DBNull.Value),
                new SqlParameter("@TrinhDo", (object)nv.TrinhDo ?? DBNull.Value)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_NHANVIEN", pars);
        }

        public static int Sua(NhanVienDTO nv)
        {
            SqlParameter[] pars = {
                new SqlParameter("@HanhDong", "SUA"),
                new SqlParameter("@MaNV", nv.MaNV),
                new SqlParameter("@TenNV", nv.TenNV),
                new SqlParameter("@GioiTinh", (object)nv.GioiTinh ?? DBNull.Value),
                new SqlParameter("@DienThoai", (object)nv.DienThoai ?? DBNull.Value),
                new SqlParameter("@CMND", (object)nv.CMND ?? DBNull.Value),
                new SqlParameter("@ChucVu", (object)nv.ChucVu ?? DBNull.Value),
                new SqlParameter("@NgayVaoLam", (object)nv.NgayVaoLam ?? DBNull.Value),
                new SqlParameter("@TrinhDo", (object)nv.TrinhDo ?? DBNull.Value)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_NHANVIEN", pars);
        }

        public static int Xoa(string maNV)
        {
            SqlParameter[] pars = {
                new SqlParameter("@HanhDong", "XOA"),
                new SqlParameter("@MaNV", maNV)
            };
            return DatabaseHelper.ExecuteNonQuery("PROC_NHANVIEN", pars);
        }
    }

    public class HoaDonDAL
    {
        public static DataTable GetAll()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "HOADON") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }

        public static DataTable GetChiTiet(string maHD)
        {
            SqlParameter[] pars = { new SqlParameter("@MaHD", maHD) };
            return DatabaseHelper.ExecuteQuery("PROC_CHITIET_HOADON", pars);
        }

        /// <summary>
        /// Bán hàng sử dụng Table-Valued Parameter + Transaction trong SP
        /// </summary>
        public static bool BanHang(string maHD, string maKH, string maNV, List<CTHoaDonDTO> chiTiet)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("PROC_BANHANG", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MaHD", maHD);
                    cmd.Parameters.AddWithValue("@MaKH", maKH);
                    cmd.Parameters.AddWithValue("@MaNV", maNV);

                    // Tạo DataTable cho Table-Valued Parameter
                    DataTable dtChiTiet = new DataTable();
                    dtChiTiet.Columns.Add("MaSP", typeof(string));
                    dtChiTiet.Columns.Add("SoLuong", typeof(int));
                    dtChiTiet.Columns.Add("DonGia", typeof(int));

                    foreach (var ct in chiTiet)
                        dtChiTiet.Rows.Add(ct.MaSP, ct.SoLuong, ct.DonGia);

                    SqlParameter tvp = cmd.Parameters.AddWithValue("@ChiTiet", dtChiTiet);
                    tvp.SqlDbType = SqlDbType.Structured;
                    tvp.TypeName = "dbo.ChiTietHoaDonType";

                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
        }
    }

    public class NhapHangDAL
    {
        public static DataTable GetAll()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "PHIEUNHAP") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }

        public static DataTable GetNhaCungCap()
        {
            SqlParameter[] pars = { new SqlParameter("@Bang", "NHACUNGCAP") };
            return DatabaseHelper.ExecuteQuery("PROC_GETALL", pars);
        }

        public static bool NhapHang(string maPN, string maNV, string maNCC, List<CTPhieuNhapDTO> chiTiet)
        {
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("PROC_NHAPHANG", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MaPN", maPN);
                    cmd.Parameters.AddWithValue("@MaNV", maNV);
                    cmd.Parameters.AddWithValue("@MaNCC", maNCC);

                    DataTable dtChiTiet = new DataTable();
                    dtChiTiet.Columns.Add("MaSP", typeof(string));
                    dtChiTiet.Columns.Add("SoLuong", typeof(int));
                    dtChiTiet.Columns.Add("DonGia", typeof(int));

                    foreach (var ct in chiTiet)
                        dtChiTiet.Rows.Add(ct.MaSP, ct.SoLuong, ct.DonGia);

                    SqlParameter tvp = cmd.Parameters.AddWithValue("@ChiTiet", dtChiTiet);
                    tvp.SqlDbType = SqlDbType.Structured;
                    tvp.TypeName = "dbo.ChiTietPhieuNhapType";

                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
        }
    }

    public class ThongKeDAL
    {
        public static DataTable ThongKeDoanhThu(int? thang, int? nam)
        {
            SqlParameter[] pars = {
                new SqlParameter("@Thang", (object)thang ?? DBNull.Value),
                new SqlParameter("@Nam", (object)nam ?? DBNull.Value)
            };
            return DatabaseHelper.ExecuteQuery("PROC_THONGKEDOANHTHU", pars);
        }

        public static DataTable[] GetDashboard()
        {
            DataTable[] results = new DataTable[5];
            using (SqlConnection conn = DatabaseHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("PROC_DASHBOARD", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        for (int i = 0; i < 5; i++)
                        {
                            results[i] = new DataTable();
                            results[i].Load(reader);
                        }
                    }
                }
            }
            return results;
        }

        public static DataTable TopSanPhamBanChay(int topN)
        {
            return DatabaseHelper.ExecuteQuery(
                "SELECT * FROM dbo.FN_TOP_SANPHAM_BANCHAY(@TopN)",
                new SqlParameter[] { new SqlParameter("@TopN", topN) },
                CommandType.Text);
        }

        public static DataTable SanPhamSapHet(int nguong)
        {
            return DatabaseHelper.ExecuteQuery(
                "SELECT * FROM dbo.FN_SANPHAM_SAPHETHANG(@NguongTon)",
                new SqlParameter[] { new SqlParameter("@NguongTon", nguong) },
                CommandType.Text);
        }
    }

    public class BackupDAL
    {
        public static void Backup(string duongDan)
        {
            SqlParameter[] pars = { new SqlParameter("@DuongDan", duongDan) };
            DatabaseHelper.ExecuteNonQuery("PROC_BACKUP_DATABASE", pars);
        }

        public static void Restore(string duongDan)
        {
            SqlParameter[] pars = { new SqlParameter("@DuongDan", duongDan) };
            DatabaseHelper.ExecuteNonQuery("PROC_RESTORE_DATABASE", pars);
        }
    }
}
