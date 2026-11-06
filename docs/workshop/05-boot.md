# 05 — Boot it

**Goal:** boot a sealed image as a VM and confirm the running root is the one the
UKI signed.

No special tooling: **plain qemu + OVMF**, which runs on Linux, macOS and Windows,
and works without KVM (TCG is slower but boots).

```bash
# 1. The demo disk and its cloud-init ISO — pre-built from Bootc-Fedora's
#    *published* sealed image (see this repo's build-demo-disk.yml for how):
curl -LO https://github.com/SNThrailkill/txlf-2026-workshop/releases/download/demo-disks/nginx-sealed-demo.qcow2
curl -LO https://github.com/SNThrailkill/txlf-2026-workshop/releases/download/demo-disks/cidata.iso

# 2. OVMF firmware:
#    Fedora:         sudo dnf install edk2-ovmf
#    Debian/Ubuntu:  sudo apt install ovmf
#    macOS:          brew install qemu        (the edk2-*.fd files ship with it)
#    Windows:        winget install SoftwareFreedomConservancy.QEMU

# 3. Start the VM. Adjust the two OVMF paths for your OS; drop -enable-kvm if
#    your machine has none.
cp /usr/share/edk2/ovmf/OVMF_VARS.fd ./VARS.fd
qemu-system-x86_64 -enable-kvm -m 4096 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/ovmf/OVMF_CODE.fd \
  -drive if=pflash,format=raw,file=./VARS.fd \
  -drive file=nginx-sealed-demo.qcow2,if=virtio \
  -drive file=cidata.iso,media=cdrom \
  -netdev user,id=n0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n0 \
  -nographic
```

Log in on the serial console as **root / txlf2026** (the cloud-init ISO sets it),
then:

```bash
bootc status
findmnt -no OPTIONS /
cat /proc/cmdline
```

## Why this VM looks the way it does

* The disk was installed from the **published** `ghcr.io/snthrailkill/bootc-fedora/nginx:sealed`, not from a local build, so you are booting Bootc-Fedora's own artifact.
* **Secure Boot is left in Setup Mode on purpose.** The disk's auto-enrol blobs
  were removed at build time, because step 06 boots an image sealed with *your*
  demo keys — a key Bootc-Fedora's enrolled db would reject. The signatures
  themselves were proven in step 04 and are verified again on published images in
  step 07; this VM demonstrates the *root digest* story.
* The image ships `console=ttyS0`, which is what makes `-nographic` work on every
  OS — no display needed.

## ✓ You should see

* `bootc status` tracking `ghcr.io/snthrailkill/bootc-fedora/nginx:sealed`.
* `findmnt -no OPTIONS /` shows an overlay with **`verity=require`**.
* `/proc/cmdline` carries **`composefs.digest=`** (or `composefs=`) and **no `root=`**.

## If stuck

* OVMF file paths differ per distro — find them (`dnf repoquery -l edk2-ovmf` on
  Fedora; on macOS they live under `brew --prefix qemu`); the filenames are
  `OVMF_CODE`/`OVMF_VARS` variants.
* `-enable-kvm: Invalid argument` → no KVM on this machine; drop the flag, expect a
  slower boot, and give the login prompt a minute or two.
* First boot runs cloud-init (root password) before the login prompt appears.
* The demo disk download is large (~1.7 GB); start it early or pair up and share.
