using System;
using System.Data;
using System.Windows;
using System.Windows.Controls;
using BUS;

namespace GUI.Views
{
    public partial class DashboardView : UserControl
    {
        public DashboardView()
        {
            InitializeComponent();
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                // Load dashboard stats
                DataTable[] stats = ThongKeBUS.GetDashboard();
                if (stats[0].Rows.Count > 0) lblTongSP.Text = stats[0].Rows[0][0].ToString();
                if (stats[1].Rows.Count > 0) lblTongKH.Text = stats[1].Rows[0][0].ToString();
                if (stats[3].Rows.Count > 0) lblHDHomNay.Text = stats[3].Rows[0][0].ToString();
                if (stats[4].Rows.Count > 0) lblSPSapHet.Text = stats[4].Rows[0][0].ToString();

                // Load top sản phẩm bán chạy
                dgTopSP.ItemsSource = ThongKeBUS.TopSanPhamBanChay(5).DefaultView;

                // Load sản phẩm sắp hết
                dgSPSapHet.ItemsSource = ThongKeBUS.SanPhamSapHet(10).DefaultView;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải Dashboard: " + ex.Message, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
