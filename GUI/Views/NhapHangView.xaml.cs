using System;
using System.Collections.Generic;
using System.Data;
using System.Windows;
using System.Windows.Controls;
using BUS;
using DTO;
using GUI.Helpers;

namespace GUI.Views
{
    public partial class NhapHangView : UserControl
    {
        private List<CTPhieuNhapDTO> danhSach = new List<CTPhieuNhapDTO>();

        public NhapHangView() { InitializeComponent(); }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            cboNCC.ItemsSource = NhapHangBUS.GetNhaCungCap().DefaultView;
            cboSanPham.ItemsSource = SanPhamBUS.GetAll().DefaultView;
            LoadLichSu();
            TaoMaPN();
        }

        private void TaoMaPN() => txtMaPN.Text = "PN" + DateTime.Now.ToString("yyMMddHHmm");

        private void LoadLichSu() => dgLichSu.ItemsSource = NhapHangBUS.GetAll().DefaultView;

        private void BtnThemSP_Click(object sender, RoutedEventArgs e)
        {
            if (cboSanPham.SelectedValue == null) { MessageBox.Show("Chọn sản phẩm!"); return; }
            if (!int.TryParse(txtSoLuong.Text, out int sl) || sl <= 0) { MessageBox.Show("Số lượng không hợp lệ!"); return; }
            if (!int.TryParse(txtDonGia.Text, out int dg) || dg <= 0) { MessageBox.Show("Đơn giá không hợp lệ!"); return; }

            var row = (cboSanPham.SelectedItem as DataRowView);
            danhSach.Add(new CTPhieuNhapDTO
            {
                MaSP = row["MaSP"].ToString(), TenSP = row["TenSP"].ToString(),
                SoLuong = sl, DonGia = dg
            });
            CapNhatDS();
        }

        private void BtnXoaSP_Click(object sender, RoutedEventArgs e)
        {
            if (dgChiTiet.SelectedIndex >= 0) { danhSach.RemoveAt(dgChiTiet.SelectedIndex); CapNhatDS(); }
        }

        private void CapNhatDS()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MaSP"); dt.Columns.Add("TenSP");
            dt.Columns.Add("SoLuong", typeof(int)); dt.Columns.Add("DonGia", typeof(int));
            dt.Columns.Add("ThanhTien", typeof(int));
            foreach (var ct in danhSach)
                dt.Rows.Add(ct.MaSP, ct.TenSP, ct.SoLuong, ct.DonGia, ct.ThanhTien);
            dgChiTiet.ItemsSource = dt.DefaultView;
        }

        private void BtnLuuPhieu_Click(object sender, RoutedEventArgs e)
        {
            string msg;
            if (NhapHangBUS.NhapHang(txtMaPN.Text.Trim(), SessionManager.MaNV,
                cboNCC.SelectedValue?.ToString(), danhSach, out msg))
            {
                MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                BtnPhieuMoi_Click(null, null); LoadLichSu();
            }
            else MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
        }

        private void BtnPhieuMoi_Click(object sender, RoutedEventArgs e)
        {
            danhSach.Clear(); CapNhatDS(); TaoMaPN();
            cboNCC.SelectedIndex = -1; txtSoLuong.Text = "1"; txtDonGia.Text = "";
        }
    }
}
