using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using BUS;
using DTO;
using GUI.Helpers;

namespace GUI.Views
{
    public partial class HoaDonView : UserControl
    {
        // Giỏ hàng lưu trong memory
        private List<CTHoaDonDTO> gioHang = new List<CTHoaDonDTO>();
        private DataTable dtSanPham;

        public HoaDonView() { InitializeComponent(); }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            LoadSanPham();
            LoadKhachHang();
            LoadLichSu();
            TaoMaHD();
        }

        private void LoadSanPham()
        {
            dtSanPham = SanPhamBUS.GetAll();
            dgSanPham.ItemsSource = dtSanPham.DefaultView;
        }

        private void LoadKhachHang()
        {
            cboKhachHang.ItemsSource = KhachHangBUS.GetAll().DefaultView;
        }

        private void LoadLichSu()
        {
            dgLichSu.ItemsSource = HoaDonBUS.GetAll().DefaultView;
        }

        private void TaoMaHD()
        {
            // Tạo mã HD tự động: HD + timestamp
            txtMaHD.Text = "HD" + DateTime.Now.ToString("yyMMddHHmm");
        }

        private void TxtTimSP_TextChanged(object sender, TextChangedEventArgs e)
        {
            string kw = txtTimSP.Text.Trim();
            if (string.IsNullOrEmpty(kw))
                dgSanPham.ItemsSource = dtSanPham.DefaultView;
            else
                dgSanPham.ItemsSource = SanPhamBUS.TimKiem(kw, null).DefaultView;
        }

        private void BtnThemVaoDon_Click(object sender, RoutedEventArgs e)
        {
            if (dgSanPham.SelectedItem is DataRowView row)
            {
                string maSP = row["MaSP"].ToString();
                string tenSP = row["TenSP"].ToString();
                int giaBan = Convert.ToInt32(row["GiaBan"]);
                int tonKho = Convert.ToInt32(row["SoLuongTon"]);

                if (!int.TryParse(txtSoLuong.Text, out int soLuong) || soLuong <= 0)
                {
                    MessageBox.Show("Số lượng không hợp lệ!"); return;
                }

                if (soLuong > tonKho)
                {
                    MessageBox.Show($"Tồn kho không đủ! Còn: {tonKho}"); return;
                }

                // Kiểm tra đã có trong giỏ chưa
                var existing = gioHang.FirstOrDefault(x => x.MaSP == maSP);
                if (existing != null)
                    existing.SoLuong += soLuong;
                else
                    gioHang.Add(new CTHoaDonDTO
                    {
                        MaSP = maSP, TenSP = tenSP,
                        SoLuong = soLuong, DonGia = giaBan
                    });

                CapNhatGioHang();
            }
        }

        private void BtnXoaKhoiDon_Click(object sender, RoutedEventArgs e)
        {
            if (dgGioHang.SelectedIndex >= 0 && dgGioHang.SelectedIndex < gioHang.Count)
            {
                gioHang.RemoveAt(dgGioHang.SelectedIndex);
                CapNhatGioHang();
            }
        }

        private void CapNhatGioHang()
        {
            // Tạo DataTable để hiển thị
            DataTable dt = new DataTable();
            dt.Columns.Add("MaSP"); dt.Columns.Add("TenSP");
            dt.Columns.Add("SoLuong", typeof(int));
            dt.Columns.Add("DonGia", typeof(int));
            dt.Columns.Add("ThanhTien", typeof(int));

            int tong = 0;
            foreach (var ct in gioHang)
            {
                dt.Rows.Add(ct.MaSP, ct.TenSP, ct.SoLuong, ct.DonGia, ct.ThanhTien);
                tong += ct.ThanhTien;
            }

            dgGioHang.ItemsSource = dt.DefaultView;
            lblTongTien.Text = string.Format("{0:N0} VNĐ", tong);
        }

        private void BtnThanhToan_Click(object sender, RoutedEventArgs e)
        {
            string maHD = txtMaHD.Text.Trim();
            string maKH = cboKhachHang.SelectedValue?.ToString();
            string maNV = SessionManager.MaNV;

            string msg;
            if (HoaDonBUS.BanHang(maHD, maKH, maNV, gioHang, out msg))
            {
                MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                BtnDonMoi_Click(null, null);
                LoadSanPham(); // Refresh tồn kho
                LoadLichSu();
            }
            else
                MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
        }

        private void BtnDonMoi_Click(object sender, RoutedEventArgs e)
        {
            gioHang.Clear();
            CapNhatGioHang();
            TaoMaHD();
            cboKhachHang.SelectedIndex = -1;
            txtSoLuong.Text = "1";
        }
    }
}
