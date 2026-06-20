using System;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    /// <summary>
    /// DAL Tài khoản - xử lý đăng nhập
    /// </summary>
    public class TaiKhoanDAL
    {
        /// <summary>
        /// Đăng nhập: gọi PROC_LOGIN
        /// Trả về DataTable chứa thông tin user nếu thành công, null nếu thất bại
        /// ketQua: 1=OK, 0=sai MK, -1=không tồn tại, -2=bị khóa
        /// </summary>
        public static DataTable DangNhap(string tenDN, string matKhau, out int ketQua)
        {
            SqlParameter[] pars = new SqlParameter[]
            {
                new SqlParameter("@TenDN", tenDN),
                new SqlParameter("@MatKhau", matKhau),
                new SqlParameter("@KetQua", SqlDbType.Int) { Direction = ParameterDirection.Output }
            };

            DataTable dt = DatabaseHelper.ExecuteQuery("PROC_LOGIN", pars);
            ketQua = (int)pars[2].Value;
            return ketQua == 1 ? dt : null;
        }
    }
}
