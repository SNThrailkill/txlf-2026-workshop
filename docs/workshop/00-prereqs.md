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
* No `bcvk`? Steps 00–04 and 07 do not need it. Install it before step 05:
  <https://github.com/bootc-dev/bcvk> — a separate binary, not a bootc subcommand.
