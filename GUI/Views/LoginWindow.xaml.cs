using System;
using System.Data;
using System.Windows;
using BUS;
using GUI.Helpers;

namespace GUI.Views
{
    public partial class LoginWindow : Window
    {
        public LoginWindow()
        {
            InitializeComponent();
            txtTenDN.Focus();
        }

        private void BtnLogin_Click(object sender, RoutedEventArgs e)
        {
            string tenDN = txtTenDN.Text.Trim();
            string matKhau = txtMatKhau.Password;
            string thongBao;

            DataTable dt = TaiKhoanBUS.DangNhap(tenDN, matKhau, out thongBao);

            if (dt != null && dt.Rows.Count > 0)
            {
                // Lưu session
                SessionManager.SetSession(dt.Rows[0]);

                // Mở MainWindow
                MainWindow mainWindow = new MainWindow();
                mainWindow.Show();
                this.Close();
            }
            else
            {
                lblError.Text = thongBao;
                lblError.Visibility = Visibility.Visible;
            }
        }
    }
}
