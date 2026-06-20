using System;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;
using BUS;

namespace GUI.Views
{
    public partial class BackupRestoreView : UserControl
    {
        public BackupRestoreView() { InitializeComponent(); }

        private void BtnChonBackup_Click(object sender, RoutedEventArgs e)
        {
            SaveFileDialog dlg = new SaveFileDialog
            {
                Filter = "Backup files (*.bak)|*.bak",
                FileName = "QL_SHOPTHOITRANG_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".bak"
            };
            if (dlg.ShowDialog() == true) txtBackupPath.Text = dlg.FileName;
        }

        private void BtnChonRestore_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog dlg = new OpenFileDialog { Filter = "Backup files (*.bak)|*.bak" };
            if (dlg.ShowDialog() == true) txtRestorePath.Text = dlg.FileName;
        }

        private void BtnBackup_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtBackupPath.Text))
            { MessageBox.Show("Vui lòng chọn đường dẫn!"); return; }

            string msg;
            if (BackupBUS.Backup(txtBackupPath.Text, out msg))
                MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
            else
                MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
        }

        private void BtnRestore_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtRestorePath.Text))
            { MessageBox.Show("Vui lòng chọn file backup!"); return; }

            if (MessageBox.Show("Bạn có CHẮC CHẮN muốn restore?\nDữ liệu hiện tại sẽ bị GHI ĐÈ!",
                "⚠ Cảnh báo", MessageBoxButton.YesNo, MessageBoxImage.Warning) == MessageBoxResult.Yes)
            {
                string msg;
                if (BackupBUS.Restore(txtRestorePath.Text, out msg))
                    MessageBox.Show(msg, "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                else
                    MessageBox.Show(msg, "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
