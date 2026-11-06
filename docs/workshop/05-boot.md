# 05 — Boot it

**Goal:** boot the sealed image as a VM that trusts **only your keys**, and confirm
the running root is the one the UKI signed.

> **`bcvk` is a separate binary, not a bootc subcommand.** `bootc bcvk` does not
> exist. Install it from <https://github.com/bootc-dev/bcvk>. This step needs real
> virtualisation: `/dev/kvm`, qemu, libvirt and virtiofsd.

```bash
bcvk libvirt run --name txlf-sealed \
  --firmware=uefi-secure --filesystem=ext4 \
  --secure-boot-keys target/keys --update-from-host \
  localhost/nginx-sealed:demo

bcvk libvirt ssh txlf-sealed
```

Inside the VM:

```bash
bootc status
findmnt -no OPTIONS /
cat /proc/cmdline
```

## Why those flags

* `--firmware=uefi-secure` — UEFI with Secure Boot enforced.
* `--filesystem=ext4` — sealing needs fs-verity, which XFS does not provide.
* `--secure-boot-keys target/keys` — enrols *your* PK/KEK/db rather than the vendor's.
  That is what "no Microsoft keys" below means.
* `--update-from-host` — bind-mounts the host's container storage into the guest, and
  it is the **only reason step 06's `containers-storage:` switch can resolve**. Leave
  it out and that step fails with "image not found".

## ✓ You should see

* Secure Boot enabled with **no Microsoft keys** in `db` — only the demo keys you
  generated in step 02.
* `findmnt -no OPTIONS /` shows an overlay carrying **`verity=require`**.
* `/proc/cmdline` carries **`composefs.digest=`** (or `composefs=`) and **no `root=`**.
* `bootc status` shows the deployment tracking `localhost/nginx-sealed:demo`.

## If stuck

* `--firmware` or `--secure-boot-keys` not recognised → your bcvk predates them. Run
  `bcvk libvirt run --help` and use the flags it lists.
* No `/dev/kvm` → enable nested virtualisation, or pair with someone who has it.
  Every other step works without this one.
* It boots but `verity=require` is missing → the image was not sealed; go back to
  step 03.
* Prefer to boot the *published* image instead of your own build? Drop
  `--secure-boot-keys target/keys --update-from-host` and use
  `ghcr.io/snthrailkill/bootc-fedora/nginx:sealed`. It boots, but step 06 then needs
  a reachable registry.
