using System.Windows;
using System.Windows.Controls;
using GUI.Helpers;

namespace GUI.Views
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            SetupUI();
            LoadView("Dashboard"); // Mặc định hiển thị Dashboard
        }

        private void SetupUI()
        {
            // Hiển thị thông tin user
            lblUser.Text = "👋 " + SessionManager.TenNV;
            lblRole.Text = SessionManager.VaiTro == "Admin" ? "🔑 Quản trị viên" : "👤 Nhân viên";

            // Phân quyền UI: Employee không thấy một số chức năng
            if (!SessionManager.IsAdmin)
            {
                btnBackup.Visibility = Visibility.Collapsed;
                btnNhanVien.Visibility = Visibility.Collapsed;
                btnThongKe.Visibility = Visibility.Collapsed;
            }
        }

        private void BtnMenu_Click(object sender, RoutedEventArgs e)
        {
            Button btn = sender as Button;
            string tag = btn.Tag.ToString();
            LoadView(tag);
        }

        private void LoadView(string viewName)
        {
            UserControl view = null;

            switch (viewName)
            {
                case "Dashboard": view = new DashboardView(); break;
                case "SanPham":   view = new SanPhamView(); break;
                case "KhachHang": view = new KhachHangView(); break;
                case "NhanVien":  view = new NhanVienView(); break;
                case "HoaDon":    view = new HoaDonView(); break;
                case "NhapHang":  view = new NhapHangView(); break;
                case "ThongKe":   view = new ThongKeView(); break;
                case "Backup":    view = new BackupRestoreView(); break;
            }

            if (view != null)
                ContentArea.Content = view;
        }

        private void BtnLogout_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("Bạn có muốn đăng xuất?", "Xác nhận",
                MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
            {
                SessionManager.ClearSession();
                LoginWindow loginWindow = new LoginWindow();
                loginWindow.Show();
                this.Close();
            }
        }
    }
}
