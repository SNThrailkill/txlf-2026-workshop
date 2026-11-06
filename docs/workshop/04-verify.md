# 04 — Verify the seal

**Goal:** prove the image is actually *sealed*, not merely built, before you boot it.

```bash
./build.py verify --image nginx-sealed --tag demo
```

## ✓ You should see

* `sbverify` succeeds for **both** the bootloader (`systemd-bootx64.efi`) **and** the
  UKI, checked against `keys/db.crt`.
* The UKI command line contains **`composefs.digest`** (older bootc writes the bare
  `composefs=` form).
* The command line contains **no `root=`** — a stray `root=` would override composefs
  root detection at boot, which is why the script asserts on its absence.

## If stuck

* `sbverify` failing against `db.crt` means the UKI was signed with a different key
  than the one in `keys/`: rerun step 02, then step 03.
* `unexpected root= in UKI cmdline` is a real finding, not a workshop glitch — the
  seal chain is supposed to have removed it. Tell the instructor.
* `verify` reads the image from local storage, so it needs step 03's
  `localhost/nginx-sealed:demo` to exist.
