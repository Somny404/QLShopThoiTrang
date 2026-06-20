using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace DAL
{
    /// <summary>
    /// Lớp trung tâm quản lý kết nối và thực thi SQL Server
    /// Sử dụng ADO.NET: SqlConnection, SqlCommand, SqlDataAdapter
    /// </summary>
    public class DatabaseHelper
    {
        // Connection string lấy từ App.config
        private static string connectionString = ConfigurationManager.ConnectionStrings["QLShopThoiTrang"].ConnectionString;

        /// <summary>
        /// Tạo kết nối mới tới SQL Server
        /// </summary>
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(connectionString);
        }

        /// <summary>
        /// Thực thi SELECT query hoặc Stored Procedure, trả về DataTable
        /// </summary>
        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null,
                                              CommandType cmdType = CommandType.StoredProcedure)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.CommandType = cmdType;
                    if (parameters != null)
                        cmd.Parameters.AddRange(parameters);

                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                }
            }
            return dt;
        }

        /// <summary>
        /// Thực thi INSERT, UPDATE, DELETE - trả về số dòng bị ảnh hưởng
        /// </summary>
        public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null,
                                           CommandType cmdType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.CommandType = cmdType;
                    if (parameters != null)
                        cmd.Parameters.AddRange(parameters);

                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Thực thi query trả về 1 giá trị duy nhất (COUNT, SUM, ...)
        /// </summary>
        public static object ExecuteScalar(string query, SqlParameter[] parameters = null,
                                            CommandType cmdType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.CommandType = cmdType;
                    if (parameters != null)
                        cmd.Parameters.AddRange(parameters);

                    return cmd.ExecuteScalar();
                }
            }
        }
    }
}
