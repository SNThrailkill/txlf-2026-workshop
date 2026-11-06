# 01 — Build your first bootc image

**Goal:** write a Containerfile, build it with plain podman, and get inside the
image to see what a bootc image actually is.

Bootc images are just container images with a little extra structure, so the
build step is a normal `podman build`. Start from Bootc-Fedora's published
image and add something small so you can prove your change landed.

```dockerfile
# Containerfile
FROM ghcr.io/snthrailkill/bootc-fedora/nginx:latest
RUN dnf -y install htop && dnf clean all
```

```bash
podman build -t localhost/my-bootc:demo .
podman run --rm -it localhost/my-bootc:demo /bin/bash
```

Inside the container:

```bash
bootc status
rpm -q htop
ls /etc/containers/systemd
exit
```

## ✓ You should see

* The build completes and is tagged `localhost/my-bootc:demo`.
* Inside, `bootc status` lists **one deployment** — this container is a bootable
  system image, and that command is the same one a real booted host runs.
* `rpm -q htop` proves your package landed in the image.
* `/etc/containers/systemd` holds the nginx and Pi-hole quadlet files inherited
  from the base.

## Behind the scenes

`./build.py build` in Bootc-Fedora does exactly what you just did —
`podman build --target nginx` plus a tag — there is no magic. Step 03 uses it
for convenience; you now know what it runs. (The image you pulled is *unsealed*:
no signed UKI yet. Steps 02–04 add that.)

## If stuck

* A failed base pull is usually network or registry auth; retry once, then
  `podman pull ghcr.io/snthrailkill/bootc-fedora/nginx:latest` by hand.
* `bootc status` in a container looks sparse on purpose — you are not on a
  booted host yet; that is step 05.
