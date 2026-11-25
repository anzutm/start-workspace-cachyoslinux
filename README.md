# Start Workspace — CachyOS / KDE Plasma

Kumpulan skrip Bash untuk membuka (`start-workspace`) dan menghentikan (`stop-workspace`) seluruh aplikasi workspace harian secara otomatis di **CachyOS** dengan **KDE Plasma 6 (Wayland)**, lengkap dengan penempatan jendela otomatis ke Virtual Desktop 1–3 menggunakan **KWin Scripting** via `qdbus6`.

## Fitur

- **Idempoten saat dijalankan**: mengecek proses aktif dengan `pgrep -f` sehingga aplikasi yang sudah terbuka tidak diluncurkan ulang.
- **Penempatan jendela Wayland-native**: menggunakan KWin Scripting (`org.kde.kwin.Scripting`) untuk memindahkan jendela ke Virtual Desktop 1, 2, atau 3 berdasarkan `resourceClass` / `resourceName`, lalu mengembalikan fokus ke Desktop 1.
- **Penutupan bertahap (graceful & force)**: `stop-workspace` menutup jendela secara halus melalui `c.closeWindow()` di KWin terlebih dahulu, lalu membersihkan proses background yang tersisa (atau memaksa dengan `-f`/`--force`).
- **Notifikasi desktop**: mengirim status melalui `notify-send` saat selesai membuka atau menutup workspace.

## Pembagian Virtual Desktop

Pastikan KDE Plasma memiliki minimal **3 Virtual Desktop** agar seluruh aturan penempatan berjalan optimal.

| Desktop | Kategori | Aplikasi di `start-workspace` |
| :--- | :--- | :--- |
| **Desktop 1** | Coding & Notes | Antigravity IDE (`glass-dock-widget`), Ptyxis Terminal, GNOME Text Editor (`Cachyos Gnome Command.md`), Nautilus / Dolphin |
| **Desktop 2** | Entertainment & Web | Chromium Browser, AniBase (`AniBase v1.5.5`) |
| **Desktop 3** | System, Utilities & Gaming | Twintail Launcher (Flatpak `app.twintaillauncher.ttl`), Omen Space (`omen-gui`) |

> **Catatan:** `stop-workspace` juga mendukung penutupan target tambahan seperti Brave Browser (`brave-browser`), Wuthering Waves (`client-win64-shipping.exe`), dan Resources Monitor (`org.gnome.Resources` / `resources`).

## Prasyarat

- **OS / Desktop**: CachyOS (atau distro Linux lain) dengan KDE Plasma 6 (Wayland)
- **Utilitas sistem**:
  - `bash`, `pgrep` / `pkill` (`procps-ng`)
  - `qdbus6` (`qt6-tools`) untuk KWin Scripting dan kontrol Virtual Desktop
  - `notify-send` (`libnotify`, opsional untuk notifikasi)
  - `flatpak` (opsional, untuk Twintail Launcher)

## Instalasi

Clone repositori ini lalu pastikan kedua skrip memiliki izin eksekusi:

```bash
git clone https://github.com/anzutm/start-workspace-cachyoslinux.git
cd start-workspace-cachyoslinux
chmod +x start-workspace stop-workspace
```

(Opsional) Buat symlink ke `~/.local/bin` agar bisa dipanggil langsung dari mana saja:

```bash
mkdir -p ~/.local/bin
ln -sf "$(pwd)/start-workspace" ~/.local/bin/start-workspace
ln -sf "$(pwd)/stop-workspace" ~/.local/bin/stop-workspace
```

## Penggunaan

### Membuka Workspace

```bash
./start-workspace
```

Atau jika sudah di-symlink ke `~/.local/bin`:

```bash
start-workspace
```

### Menghentikan Workspace

```bash
./stop-workspace [OPSI]
```

Opsi yang tersedia:

| Opsi | Keterangan |
| :--- | :--- |
| `-a`, `--all` | Tutup juga jendela terminal Ptyxis |
| `-f`, `--force` | Paksa tutup proses jika tidak merespons (`pkill -9 -f`) |
| `-h`, `--help` | Tampilkan pesan bantuan |

Contoh:

```bash
# Tutup semua aplikasi workspace, biarkan Ptyxis tetap terbuka
./stop-workspace

# Tutup semua aplikasi termasuk Ptyxis
./stop-workspace --all

# Paksa hentikan semua proses workspace termasuk Ptyxis
./stop-workspace -a -f
```

## Kustomisasi

Sesuaikan path proyek dan daftar aplikasi langsung di dalam skrip:

- **[`start-workspace`](start-workspace)**: ubah argumen `launch_if_not_running` (seperti path workspace IDE, catatan `.md`, atau binary lokal) serta objek `rules` pada fungsi `organize_windows()` untuk mengatur pemetaan `resourceClass` / `resourceName` ke indeks desktop (`0` = Desktop 1, `1` = Desktop 2, `2` = Desktop 3).
- **[`stop-workspace`](stop-workspace)**: sesuaikan array `targets` di skrip KWin serta pemanggilan `close_proc` agar sesuai dengan aplikasi yang ingin dihentikan.
