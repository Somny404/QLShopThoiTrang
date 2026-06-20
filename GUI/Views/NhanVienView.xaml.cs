using System;
using System.Data;
using System.Windows;
using System.Windows.Controls;
using BUS;
using DTO;

namespace GUI.Views
{
    public partial class NhanVienView : UserControl
    {
        public NhanVienView() { InitializeComponent(); }
        private void UserControl_Loaded(object sender, RoutedEventArgs e) => LoadData();
        private void LoadData() => dgNhanVien.ItemsSource = NhanVienBUS.GetAll().DefaultView;

        private void BtnThem_Click(object sender, RoutedEventArgs e)
        {
            string msg;
            if (NhanVienBUS.Them(GetForm(), out msg))
            { MessageBox.Show(msg); LoadData(); ClearForm(); }
            else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void BtnSua_Click(object sender, RoutedEventArgs e)
        {
            string msg;
            if (NhanVienBUS.Sua(GetForm(), out msg)) { MessageBox.Show(msg); LoadData(); }
            else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void BtnXoa_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtMaNV.Text)) return;
            if (MessageBox.Show("Xác nhận xóa?", "Xóa", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            {
                string msg;
                if (NhanVienBUS.Xoa(txtMaNV.Text.Trim(), out msg))
                { MessageBox.Show(msg); LoadData(); ClearForm(); }
                else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }

        private void BtnLamMoi_Click(object sender, RoutedEventArgs e) { ClearForm(); LoadData(); }

        private void DgNhanVien_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgNhanVien.SelectedItem is DataRowView r)
            {
                txtMaNV.Text = r["MaNV"].ToString();
                txtTenNV.Text = r["TenNV"].ToString();
                cboGioiTinh.Text = r["GioiTinh"].ToString();
                txtDienThoai.Text = r["DienThoai"].ToString();
                txtCMND.Text = r["CMND"].ToString();
                txtChucVu.Text = r["ChucVu"].ToString();
                if (r["NgayVaoLam"] != DBNull.Value)
                    dpNgayVaoLam.SelectedDate = Convert.ToDateTime(r["NgayVaoLam"]);
                txtTrinhDo.Text = r["TrinhDo"].ToString();
            }
        }

        private NhanVienDTO GetForm() => new NhanVienDTO
        {
            MaNV = txtMaNV.Text.Trim(), TenNV = txtTenNV.Text.Trim(),
            GioiTinh = (cboGioiTinh.SelectedItem as ComboBoxItem)?.Content?.ToString(),
            DienThoai = txtDienThoai.Text.Trim(), CMND = txtCMND.Text.Trim(),
            ChucVu = txtChucVu.Text.Trim(), NgayVaoLam = dpNgayVaoLam.SelectedDate,
            TrinhDo = txtTrinhDo.Text.Trim()
        };

        private void ClearForm()
        {
            txtMaNV.Text = txtTenNV.Text = txtDienThoai.Text = txtCMND.Text = "";
            txtChucVu.Text = txtTrinhDo.Text = "";
            cboGioiTinh.SelectedIndex = -1; dpNgayVaoLam.SelectedDate = null;
        }
    }
}
