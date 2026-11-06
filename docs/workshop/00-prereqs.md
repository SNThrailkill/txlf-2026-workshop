# 00 — Prerequisites

**Goal:** confirm this machine has everything the workshop needs, then that it can
build *and* seal a bootc image.

The workshop's own pre-flight checks the toolchain, including the two pieces
`./build.py doctor` does not know about (cosign for step 07, qemu for step 05):

```bash
git clone https://github.com/SNThrailkill/txlf-2026-workshop
bash txlf-2026-workshop/check.sh
```

Then the proven pipeline's own check:

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
container manager: podman (podman version 5.x.y)
free disk: 42.3 GiB
/dev/fuse: present
Content builds: ready
Sealed images: ready
```

The two lines that matter are the last two. The free-disk number is a warning
threshold (below 20 GiB you will run out mid-seal), and `doctor` also prints a
line about keys not being present — expected for now; step 02 generates them.

## If stuck

* `MISSING` from `check.sh` — it prints the install hint for each item. Install
  and rerun; it exits non-zero until everything passes.
* `container manager: not found` in `doctor` — podman is missing, which
  `check.sh` would already have caught.
* `/dev/fuse: missing` — sealed builds compute the composefs digest through fuse.
  On a container host pass the device through; on a VM check the fuse module.
