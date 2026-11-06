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
keys: not present; run ./build.py keygen --demo (writes target/keys)
Content builds: ready
Sealed images: ready
```

The two lines that matter are the last two: **`Content builds: ready`** and
**`Sealed images: ready`**. The free-disk number is a warning threshold (below
20 GiB you will run out mid-seal), and `keys: not present` is expected — step 02
creates them.

## If stuck

* `container manager: not found` — install podman. `--container-mgr
  podman|docker|buildah` forces a choice if it picks the wrong one.
* `/dev/fuse: missing` — sealed builds compute the composefs digest through fuse.
  On a container host pass the device through; on a VM check the fuse module.
* `doctor` exits **1** when either status line says "not ready". That is deliberate,
  and it is the one command in this workshop that is allowed to fail.
* Nothing else to install yet: the boot step (05) uses plain **qemu + OVMF**, which
  runs on Linux, macOS and Windows, and needs **no KVM** — KVM only makes it faster.
  You will install qemu there, not here.
