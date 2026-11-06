# 00 — Prerequisites

**Goal:** confirm this machine has everything the workshop needs, then that it can
build *and* seal a bootc image.

The workshop's own pre-flight checks the toolchain, including the two pieces
`./build.py doctor` does not know about (cosign for step 07, qemu for step 05):

```bash
git clone https://github.com/SNThrailkill/txlf-2026-workshop
bash txlf-2026-workshop/check.sh
```

Then my example repo:

```bash
git clone https://github.com/SNThrailkill/Bootc-Fedora
cd Bootc-Fedora
./build.py doctor
```

## ✓ You should see

From `check.sh`, every line `ok` — including **cosign** and **qemu** — followed by
`All prerequisites present.`

From `doctor`:

```
container manager: podman (podman version 5.8.9)
free disk: 42.3 GiB
/dev/fuse: present
keys: not present; run ./build.py keygen --demo (writes target/keys)
Content builds: ready
Sealed images: ready; run ./build.py keygen --demo, then ./build.py seal --image nginx-sealed
```

Everything except `keys:` should be green. `keys: not present` is expected on the
first run — step 02 generates them. The free-disk line is a warning threshold
(below 20 GiB you will run out mid-seal); note it measures the filesystem the
clone lives on, so clone into your home directory rather than `/tmp`.

## If stuck

* `MISSING` from `check.sh` — it prints the install hint for each item. Install
  and rerun; it exits non-zero until everything passes.
* `container manager: not found` in `doctor` — podman is missing, which
  `check.sh` would already have caught.
* `/dev/fuse: missing` — sealed builds compute the composefs digest through fuse.
  On a container host pass the device through; on a VM check the fuse module.
