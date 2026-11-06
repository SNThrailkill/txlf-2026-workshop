# 03 — Seal the image

**Goal:** turn that unsealed tree into a signed UKI with a composefs root and
fs-verity.

```bash
./build.py seal --image nginx-sealed --tag demo
```

This runs the seal chain: flatten the content stage, compute the composefs digest,
build a UKI carrying kernel + initramfs + cmdline (with the digest in the cmdline),
sign the UKI with your db key, and sign systemd-boot too. It needs **podman and
`/dev/fuse`**; build.py passes `--device /dev/fuse --cap-add=all` for you.

## ✓ You should see

* The build reaches the seal stage and **`ukify` and `sbsign` run without errors**.
* It ends with a completed build tagged `localhost/nginx-sealed:demo`.

## If stuck

* `/dev/fuse is missing; sealed builds need fuse` — fix step 00; the build stops
  before spending ten minutes to reach the same error.
* A missing-key error means step 02 did not run (or ran in another checkout):
  `target/keys/db.key` must exist.
* This is the slow step — five to fifteen minutes depending on the machine. If it
  dies on disk space, free space rather than retrying.
