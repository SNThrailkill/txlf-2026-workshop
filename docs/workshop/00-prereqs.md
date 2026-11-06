# 00 — Prerequisites

**Goal:** confirm this machine can build *and* seal a bootc image.

```bash
git clone https://github.com/SNThrailkill/Bootc-Fedora
cd Bootc-Fedora
./build.py doctor
```

## ✓ You should see

```
container manager: podman (podman version 5.x.y)
free disk: 42.3 GiB
/dev/fuse: present
Content builds: ready
Sealed images: ready
```

The two lines that matter are the last two: **`Content builds: ready`** and
**`Sealed images: ready`**. The free-disk number is a warning threshold (below
20 GiB you will run out mid-seal). `doctor` also prints a line about keys not
being present — that is expected for now; step 02 generates them.

## If stuck

* `container manager: not found` — install podman; the whole workshop assumes it.
* `/dev/fuse: missing` — sealed builds compute the composefs digest through fuse.
  On a container host pass the device through; on a VM check the fuse module.
* Nothing else to install yet: qemu + OVMF arrive with step 05, cosign with
  step 07.
