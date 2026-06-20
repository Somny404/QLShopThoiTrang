using System;
using System.Data;
using System.Windows;
using System.Windows.Controls;
using BUS;
using DTO;
using GUI.Helpers;

namespace GUI.Views
{
    public partial class SanPhamView : UserControl
    {
        public SanPhamView()
        {
            InitializeComponent();
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            LoadData();
            LoadLoaiSP();

            // Phân quyền: Employee không được xóa
            if (!SessionManager.IsAdmin)
                btnXoa.Visibility = Visibility.Collapsed;
        }

        private void LoadData()
        {
            dgSanPham.ItemsSource = SanPhamBUS.GetAll().DefaultView;
        }

        private void LoadLoaiSP()
        {
            cboLoai.ItemsSource = SanPhamBUS.GetLoaiSanPham().DefaultView;
        }

        private void BtnThem_Click(object sender, RoutedEventArgs e)
        {
            SanPhamDTO sp = GetFormData();
            string msg;
            if (SanPhamBUS.Them(sp, out msg))
            {
                MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                LoadData();
                ClearForm();
            }
            else
                MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void BtnSua_Click(object sender, RoutedEventArgs e)
        {
            SanPhamDTO sp = GetFormData();
            string msg;
            if (SanPhamBUS.Sua(sp, out msg))
            {
                MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                LoadData();
            }
            else
                MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void BtnXoa_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtMaSP.Text)) return;
            if (MessageBox.Show("Bạn có chắc muốn xóa?", "Xác nhận", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            {
                string msg;
                if (SanPhamBUS.Xoa(txtMaSP.Text.Trim(), out msg))
                {
                    MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                    LoadData();
                    ClearForm();
                }
                else
                    MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }

        private void BtnLamMoi_Click(object sender, RoutedEventArgs e)
        {
            ClearForm();
            LoadData();
        }

        private void TxtTimKiem_TextChanged(object sender, TextChangedEventArgs e)
        {
            string tuKhoa = txtTimKiem.Text.Trim();
            if (string.IsNullOrEmpty(tuKhoa))
                LoadData();
            else
                dgSanPham.ItemsSource = SanPhamBUS.TimKiem(tuKhoa, null).DefaultView;
        }

        private void DgSanPham_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgSanPham.SelectedItem is DataRowView row)
            {
                txtMaSP.Text = row["MaSP"].ToString();
                txtTenSP.Text = row["TenSP"].ToString();
                txtGiaBan.Text = row["GiaBan"].ToString();
                txtSoLuongTon.Text = row["SoLuongTon"].ToString();
                txtSize.Text = row["Size"].ToString();
                txtMauSac.Text = row["MauSac"].ToString();
                cboLoai.SelectedValue = row["MaLoai"].ToString();
            }
        }

        private SanPhamDTO GetFormData()
        {
            return new SanPhamDTO
            {
                MaSP = txtMaSP.Text.Trim(),
                TenSP = txtTenSP.Text.Trim(),
                GiaBan = int.TryParse(txtGiaBan.Text, out int g) ? g : 0,
                SoLuongTon = int.TryParse(txtSoLuongTon.Text, out int s) ? s : 0,
                Size = txtSize.Text.Trim(),
                MauSac = txtMauSac.Text.Trim(),
                MaLoai = cboLoai.SelectedValue?.ToString() ?? ""
            };
        }

        private void ClearForm()
        {
            txtMaSP.Text = txtTenSP.Text = txtGiaBan.Text = "";
            txtSoLuongTon.Text = txtSize.Text = txtMauSac.Text = txtTimKiem.Text = "";
            cboLoai.SelectedIndex = -1;
        }
    }
}
