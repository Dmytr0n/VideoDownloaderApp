using System;
using System.IO;
using System.Diagnostics;
using System.Windows.Forms;
using System.Threading.Tasks;


namespace videodownloader
{
    public partial class Form1 : Form
    {
        private readonly string ytDlpPath = Path.Combine(Application.StartupPath, "yt-dlp.exe");
        private readonly string ffmpegPath = Path.Combine(Application.StartupPath, "ffmpeg.exe");


        public Form1()
        {
            InitializeComponent();
            this.Icon = new System.Drawing.Icon(Path.Combine(Application.StartupPath, "icon.ico"));
            this.Text = "VideoDownloader";
            // Фіксувати розмір форми
            this.FormBorderStyle = FormBorderStyle.FixedDialog; // Фіксований діалог
            this.MaximizeBox = false;  // Вимкнути кнопку максимізації
            this.MinimizeBox = false;  // Вимкнути кнопку мінімізації (за бажанням)
            // Директорія для завантажень за замовчуванням
            guna2TextBox2.Text = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + @"\Downloads";
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            DownloadVideo();
        }

        private async void DownloadVideo()
        {
            string videoUrl = guna2TextBox1.Text;

            if (string.IsNullOrWhiteSpace(videoUrl))
            {
                MessageBox.Show("URL cannot be empty.", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string saveDirectory = guna2TextBox2.Text;

            if (string.IsNullOrWhiteSpace(saveDirectory) || !Directory.Exists(saveDirectory))
            {
                MessageBox.Show("Invalid directory. Using the current directory.", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Перевірка наявності утиліт
            if (!File.Exists(ytDlpPath))
            {
                MessageBox.Show($"yt-dlp.exe not found at {ytDlpPath}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (!File.Exists(ffmpegPath))
            {
                MessageBox.Show($"ffmpeg.exe not found at {ffmpegPath}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // Лог-файл
            string logFilePath = Path.Combine(saveDirectory, "download_log.txt");
            File.WriteAllText(logFilePath, string.Empty);

            try
            {
                using (StreamWriter logWriter = new StreamWriter(logFilePath, true))
                {
                    logWriter.WriteLine($"[{DateTime.Now}] Starting download...");

                    // Запускаємо процес асинхронно
                    await Task.Run(() =>
                    {
                        var process = new Process
                        {
                            StartInfo = new ProcessStartInfo
                            {
                                FileName = ytDlpPath, // Шлях до yt-dlp.exe
                                Arguments = $"-f bestvideo[height<=720]+bestaudio[ext=m4a]/bestaudio[ext=webm] --merge-output-format mp4 --ffmpeg-location \"{ffmpegPath}\" {videoUrl} -o \"{Path.Combine(saveDirectory, "%(title)s.%(ext)s")}\"",
                                RedirectStandardOutput = true,
                                RedirectStandardError = true,
                                UseShellExecute = false,
                                CreateNoWindow = true
                            }
                        };

                        process.OutputDataReceived += (sender, e) =>
                        {
                            if (!string.IsNullOrWhiteSpace(e.Data))
                            {
                                logWriter.WriteLine($"[OUTPUT] {e.Data}");
                                logWriter.Flush();
                            }
                        };

                        process.ErrorDataReceived += (sender, e) =>
                        {
                            if (!string.IsNullOrWhiteSpace(e.Data))
                            {
                                logWriter.WriteLine($"[ERROR] {e.Data}");
                                logWriter.Flush();
                            }
                        };

                        process.Start();
                        process.BeginOutputReadLine();
                        process.BeginErrorReadLine();

                        process.WaitForExit();

                        logWriter.WriteLine($"[{DateTime.Now}] Download process exited with code {process.ExitCode}.");
                    });

                    MessageBox.Show("Download complete!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }


        private void guna2Button2_Click(object sender, EventArgs e)
        {
            changeDirectory();
        }
        private void changeDirectory()
        {
            // Створюємо новий об'єкт FolderBrowserDialog
            FolderBrowserDialog folderBrowserDialog = new FolderBrowserDialog();

            // Якщо користувач вибирає папку і натискає "OK"
            if (folderBrowserDialog.ShowDialog() == DialogResult.OK)
            {
                // Виводимо шлях до вибраної папки в TextBox
                guna2TextBox2.Text = folderBrowserDialog.SelectedPath;
            }
        }
    }
}
