using System;
using System.Data;

namespace GUI.Helpers
{
    /// <summary>
    /// Quản lý thông tin phiên đăng nhập hiện tại
    /// </summary>
    public static class SessionManager
    {
        public static string MaNV { get; set; }
        public static string TenDN { get; set; }
        public static string TenNV { get; set; }
        public static string VaiTro { get; set; }  // "Admin" hoặc "Employee"
        public static string ChucVu { get; set; }

        public static bool IsAdmin => VaiTro == "Admin";

        public static void SetSession(DataRow row)
        {
            MaNV   = row["MaNV"].ToString();
            TenDN  = row["TenDN"].ToString();
            TenNV  = row["TenNV"].ToString();
            VaiTro = row["VaiTro"].ToString();
            ChucVu = row["ChucVu"].ToString();
        }

        public static void ClearSession()
        {
            MaNV = TenDN = TenNV = VaiTro = ChucVu = null;
        }
    }
}
