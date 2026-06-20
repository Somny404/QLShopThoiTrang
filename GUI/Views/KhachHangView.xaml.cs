using System;
using System.Data;
using System.Windows;
using System.Windows.Controls;
using BUS;
using DTO;

namespace GUI.Views
{
    public partial class KhachHangView : UserControl
    {
        public KhachHangView() { InitializeComponent(); }

        private void UserControl_Loaded(object sender, RoutedEventArgs e) => LoadData();

        private void LoadData() => dgKhachHang.ItemsSource = KhachHangBUS.GetAll().DefaultView;

        private void BtnThem_Click(object sender, RoutedEventArgs e)
        {
            string msg;
            if (KhachHangBUS.Them(GetForm(), out msg))
            { MessageBox.Show(msg); LoadData(); ClearForm(); }
            else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void BtnSua_Click(object sender, RoutedEventArgs e)
        {
            string msg;
            if (KhachHangBUS.Sua(GetForm(), out msg))
            { MessageBox.Show(msg); LoadData(); }
            else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void BtnXoa_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtMaKH.Text)) return;
            if (MessageBox.Show("Xác nhận xóa?", "Xóa", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            {
                string msg;
                if (KhachHangBUS.Xoa(txtMaKH.Text.Trim(), out msg))
                { MessageBox.Show(msg); LoadData(); ClearForm(); }
                else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }

        private void BtnLamMoi_Click(object sender, RoutedEventArgs e) { ClearForm(); LoadData(); }

        private void DgKhachHang_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgKhachHang.SelectedItem is DataRowView r)
            {
                txtMaKH.Text = r["MaKH"].ToString();
                txtTenKH.Text = r["TenKH"].ToString();
                txtDienThoai.Text = r["DienThoai"].ToString();
                txtEmail.Text = r["Email"].ToString();
                txtDiaChi.Text = r["DiaChi"].ToString();
            }
        }

        private KhachHangDTO GetForm() => new KhachHangDTO(
            txtMaKH.Text.Trim(), txtTenKH.Text.Trim(), txtDienThoai.Text.Trim(),
            txtEmail.Text.Trim(), txtDiaChi.Text.Trim());

        private void ClearForm()
        { txtMaKH.Text = txtTenKH.Text = txtDienThoai.Text = txtEmail.Text = txtDiaChi.Text = ""; }
    }
}
