# 05 — Boot your sealed image

**Goal:** turn the image you sealed into a VM that boots it with *your* keys
enrolled, and confirm the running root is the one the UKI signed.

Everything here uses plain **qemu + OVMF**, which runs on Linux, macOS and
Windows; KVM is only an accelerator. If you cannot run image-builder (it needs
rootful podman), skip to the fallback at the end of this page.

### 1. Serve your sealed image from a local registry

image-builder installs from local container storage, and the image you built is
in *rootless* storage — so push it to a tiny local registry that the rootful
side can pull:

```bash
podman run -d -p 5000:5000 --name registry docker.io/library/registry:2
podman push --tls-verify=false localhost/nginx-sealed:demo \
  localhost:5000/nginx-sealed:demo
```

Keep this registry running — step 06 pushes a second image to it.

### 2. Build a bootable disk from your image

```bash
sudo podman pull --tls-verify=false localhost:5000/nginx-sealed:demo
mkdir -p demo-disk
sudo podman run --rm --privileged \
  -v "$PWD/demo-disk:/output" \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  ghcr.io/osbuild/image-builder-cli:latest \
  build \
    --bootc-ref localhost:5000/nginx-sealed:demo \
    --bootc-default-fs ext4 \
    --output-name demo-disk \
    --output-dir /output \
    qcow2
```

This runs `bootc install` inside a privileged container and writes
`demo-disk/demo-disk.qcow2`. `sudo` is required because image-builder needs real
root and the *rootful* container storage — which is exactly why the image went
through a registry first.

### 3. Boot it

```bash
curl -LO https://github.com/SNThrailkill/txlf-2026-workshop/releases/download/demo-disks/cidata.iso
# OVMF firmware for your OS:
#   Fedora: sudo dnf install edk2-ovmf | Debian/Ubuntu: sudo apt install ovmf
#   macOS:  brew install qemu | Windows: winget install SoftwareFreedomConservancy.QEMU
cp /usr/share/edk2/ovmf/OVMF_VARS.fd ./VARS.fd
qemu-system-x86_64 -enable-kvm -m 4096 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/ovmf/OVMF_CODE.fd \
  -drive if=pflash,format=raw,file=./VARS.fd \
  -drive file=demo-disk/demo-disk.qcow2,if=virtio \
  -drive file=cidata.iso,media=cdrom \
  -netdev user,id=n0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n0 \
  -nographic
```

Log in as **root / txlf2026** (the cloud-init ISO sets it), then:

```bash
bootc status
findmnt -no OPTIONS /
cat /proc/cmdline
```

## What just happened with Secure Boot

The VM's firmware starts with empty variables (**Setup Mode**), so nothing is
enrolled. On first boot systemd-boot finds the `.auth` enrollment blobs your
image ships on its ESP — the ones you generated in step 02 — enrolls them,
reboots, and now enforces Secure Boot with **your keys and yours only**. That is
why step 06 can later boot an image you seal yourself: its UKI is signed with
the same db key.

## ✓ You should see

* After the auto-enrollment reboot: Secure Boot **enabled**, `db` containing
  your demo keys and no Microsoft keys.
* `bootc status` tracking `localhost:5000/nginx-sealed:demo` (the ref
  image-builder installed).
* `findmnt -no OPTIONS /` shows an overlay with **`verity=require`**.
* `/proc/cmdline` carries **`composefs.digest=`** and **no `root=`**.

## If stuck

* image-builder needs rootful podman — on macOS/Windows use the fallback below.
* `sudo podman pull` fails with TLS errors → the `--tls-verify=false` flag is
  what allows the plain-HTTP registry.
* `-enable-kvm: Invalid argument` → no KVM on this machine; drop the flag and
  give the login prompt a minute or two.
* OVMF paths differ per distro — `dnf repoquery -l edk2-ovmf` (Fedora); on macOS
  they live under `brew --prefix qemu`.

## Fallback: a pre-built disk (any OS, no image-builder)

If image-builder is not an option, boot a disk built from Bootc-Fedora's
*published* image instead:

```bash
curl -LO https://github.com/SNThrailkill/txlf-2026-workshop/releases/download/demo-disks/nginx-sealed-demo.qcow2
```

Then run step 3's qemu command with `nginx-sealed-demo.qcow2` in place of
`demo-disk/demo-disk.qcow2`. This disk enrolls **Bootc-Fedora's** keys rather
than yours, so the boot works but **step 06's switch to your own image will be
rejected** — use this path only when you cannot build your own disk.
