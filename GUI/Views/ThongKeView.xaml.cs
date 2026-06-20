using System;
using System.Windows;
using System.Windows.Controls;
using BUS;

namespace GUI.Views
{
    public partial class ThongKeView : UserControl
    {
        public ThongKeView() { InitializeComponent(); }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            txtNam.Text = DateTime.Now.Year.ToString();
            cboThang.SelectedIndex = 0;
        }

        private void BtnThongKe_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                int? thang = null;
                if (cboThang.SelectedIndex > 0)
                    thang = cboThang.SelectedIndex;

                int nam = int.TryParse(txtNam.Text, out int n) ? n : DateTime.Now.Year;
                dgThongKe.ItemsSource = ThongKeBUS.ThongKeDoanhThu(thang, nam).DefaultView;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }

        private void BtnTopBanChay_Click(object sender, RoutedEventArgs e)
        {
            dgThongKe.ItemsSource = ThongKeBUS.TopSanPhamBanChay(10).DefaultView;
        }

        private void BtnSPSapHet_Click(object sender, RoutedEventArgs e)
        {
            dgThongKe.ItemsSource = ThongKeBUS.SanPhamSapHet(10).DefaultView;
        }
    }
}
