# 06 — Update in place, then roll back

**Goal:** stage a second sealed image onto the running machine, boot into it, then
roll back to the first.

On the **host**, build a second sealed image under a different tag:

```bash
./build.py seal --image nginx-sealed --tag demo2
```

On the **VM**:

```bash
bootc status
sudo bootc switch --transport containers-storage localhost/nginx-sealed:demo2
sudo systemctl reboot
sudo bootc status
sudo bootc rollback && sudo systemctl reboot
```

## ✓ You should see

* After the switch, `bootc status` lists **two deployments**: `demo2` staged and
  `demo` still booted.
* After the reboot the booted deployment is `demo2`.
* `bootc rollback` plus a reboot returns you to `demo`, with `demo2` still present.
* Both boots keep the seal — `verity=require`, and the digest on the cmdline.

## Why `containers-storage`

The VM cannot reach a registry, and the image you just built exists only in the
**host's** container storage. `--update-from-host` in step 05 bind-mounts that storage
into the guest, so `--transport containers-storage` resolves to the image you built.
Without that flag this step fails with "image not found" — a missing flag, not a
broken seal.

## If stuck

* `image not found` → the VM was created without `--update-from-host`; recreate it
  (step 05) and retry.
* `bootc switch` needs root: use `sudo`.
* The reboot lands back on `demo` → check `bootc status` for a staged entry, and
  confirm you did not regenerate keys between steps 03 and 06: the `demo2` UKI must be
  signed by the same demo keys to boot.
