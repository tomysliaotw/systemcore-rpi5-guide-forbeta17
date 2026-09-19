# SystemCore Pi 5B — Beta 14 Builder

Build a Raspberry Pi 5B-compatible SystemCore Beta 14 image from Limelight’s upstream SystemCore release.

This builder uses `patch-image.py` because Beta 14 has a different partition layout from Beta 10. In particular, Beta 14 does not include `rootfs_b`, so the old `build-image.sh` should not be used.

## Requirements

- Raspberry Pi 5 Model B
- 16 GB or larger SD card; 32 GB recommended
- Ubuntu/Debian Linux host or WSL2
- `sudo` access
- At least 15 GB free disk space
- Internet access for the initial image download

Install required tools:

```bash
sudo apt update
sudo apt install -y unzip wget python3

## Build

From the repository directory:

```bash
cd ~/systemcore/systemcore-rpi5-guide
sudo bash build-image-beta14.sh
