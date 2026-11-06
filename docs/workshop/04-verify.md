# 04 — Verify the seal

**Goal:** prove the sealed image's signatures and cmdline, using the same checks
a booted machine's firmware and kernel will perform.

```bash
./build.py verify --image nginx-sealed --tag demo
```

## What it runs, and why each check proves something

`verify` runs *inside* the built image. In order:

1. **`sbverify --list`** on the UKI and on systemd-boot — prints the signatures;
   diagnostics only.
2. **`sbverify --cert keys/db.crt`** on both, for real: the signature must chain
   to *your* db key. This is the same verification the firmware performs under
   Secure Boot, so passing it here predicts a boot the firmware will accept.
3. It extracts the UKI's `.cmdline` section and asserts **`composefs.digest` is
   present** — the kernel command line commits to the exact root filesystem, the
   value the initramfs later mounts with `verity=require`.
4. It asserts **`root=` is absent** — a traditional `root=` argument would
   override composefs root detection at boot, silently undoing the seal.
5. It checks `setup-root-conf.toml` exists — the marker that makes `bootc
   install` select the composefs backend.

Together: the signature proves *who sealed it*, the digest proves *what root it
commits to*, and the missing `root=` proves *nothing can substitute a different
root at boot*.

## ✓ You should see

* `sbverify` OK for the bootloader **and** the UKI, against `keys/db.crt`.
* `composefs.digest` (or the bare `composefs=` form) on the cmdline, and no
  `root=`.

## If stuck

* `sbverify` failing against `db.crt` means the UKI was signed with a different
  key than the one in `keys/`: rerun step 02, then step 03.
* `unexpected root= in UKI cmdline` is a real finding — tell the instructor.
* `verify` reads the image from local storage, so step 03's
  `localhost/nginx-sealed:demo` must exist.
