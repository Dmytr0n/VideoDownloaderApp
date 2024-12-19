# Video Downloader

**Video Downloader** is a Windows application that enables you to download videos from the web with ease. Built with support for `yt-dlp` and `ffmpeg`, this tool ensures fast and seamless downloading while maintaining high quality.

---

## **Current Version**
The latest available version is **1.0.0**.

[Download Video Downloader v1.0.0](https://github.com/your-username/your-repo/releases/tag/v1.0.0)

---

## **Features**
- **Download videos in MP4 format** with merged audio and video tracks.
- Support for **high-quality audio** extraction using `yt-dlp`.
- Automatically utilizes **FFmpeg** for video processing and format conversion.
- Easy-to-use graphical interface for selecting video URLs and output directories.
- Real-time logging for download progress and error handling.

---

## **Installation**

1. Download the installer for version **1.0.0** from the [Releases](https://github.com/your-username/your-repo/releases) section.
2. Run the `.msi` file and follow the on-screen instructions.
3. After installation, launch the application from the desktop shortcut or Start Menu.

---

## **How to Use**

1. Open the application.
2. Paste the video URL into the **URL Input Field**.
3. Select the desired download folder (default: `Downloads`).
4. Click the **Download** button to start downloading the video.
5. Check the status in the log window to monitor progress.

---

## **Requirements**

- **Operating System**: Windows 10 or higher
- **Dependencies**: Bundled with the installer:
  - `yt-dlp`
  - `ffmpeg`

---

## **Technical Details**

- **Framework**: .NET Framework (Windows Forms Application)
- **Dependencies**:
  - `yt-dlp` is used for extracting video and audio streams.
  - `FFmpeg` handles audio and video merging and format conversions.
- **Log File**:
  - All download operations are logged in a file named `download_log.txt` in the output directory.

---

## **FAQ**

### 1. What happens if `yt-dlp` or `ffmpeg` is missing?
The application will display an error message if either utility is missing. Ensure they are installed in the specified directories (`yt-dlp` and `ffmpeg` paths are bundled in the installer).

### 2. Can I download videos in formats other than MP4?
The application is optimized for MP4 by default. You can modify `yt-dlp` arguments in the source code if needed.

---

## **Screenshots**

### Main Interface:
![Main Interface](https://github.com/your-username/your-repo/blob/main/screenshots/main-interface.png)

---

## **Known Issues**

1. **Invalid URL Handling**: Ensure the URL is correctly formatted and points to a supported platform.
2. **Permission Errors**: Run the application with administrator privileges if you encounter permission-related issues.

---

## **Contributing**

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch for your feature or bugfix: `git checkout -b feature-name`.
3. Commit and push your changes.
4. Open a pull request with a detailed description of your changes.

---

## **License**

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). See the `LICENSE` file for more details.

---

## **Acknowledgments**

Special thanks to:
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) for enabling robust video downloading.
- [FFmpeg](https://ffmpeg.org/) for advanced video processing.

---

## **Contact**

For questions or feedback, feel free to open an [issue](https://github.com/your-username/your-repo/issues) or contact me at **[your-email@example.com](mailto:your-email@example.com)**.
