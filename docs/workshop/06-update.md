# 06 — Update in place, then roll back

**Goal:** boot a second sealed image — one sealed with *your* demo keys — on the
running VM, then roll back.

The VM from step 05 is still running and cannot reach a registry, so we run a tiny
**local registry** on your machine and push the new image to it. qemu's user
networking lets the guest reach your machine as `10.0.2.2`.

On the **host**:

```bash
./build.py seal --image nginx-sealed --tag demo2
podman run -d -p 5000:5000 --name registry docker.io/library/registry:2
podman push --tls-verify=false localhost/nginx-sealed:demo2 \
  localhost:5000/nginx-sealed:demo2
```

On the **VM** (root / txlf2026):

```bash
bootc status
sudo bootc switch --transport registry 10.0.2.2:5000/nginx-sealed:demo2
sudo systemctl reboot
sudo bootc status
sudo bootc rollback && sudo systemctl reboot
```

## ✓ You should see

* After the switch, `bootc status` lists **two deployments**: `demo2` staged and
  the published image still booted.
* After the reboot the booted deployment is `demo2` — your own sealed image, with
  your own demo keys in its UKI. It boots because the VM is in Setup Mode, and its
  root is still digest-checked: `verity=require` remains on the mount.
* `bootc rollback` plus a reboot returns you to the published image, with `demo2`
  still present.

## If stuck

* `image not found` or a connection error → the guest cannot reach the registry.
  Check it is running (`podman ps`), port 5000 is mapped, and the push succeeded.
* On macOS/Windows, the registry runs inside the podman VM, but `-p 5000:5000`
  forwards it to your host, so `10.0.2.2:5000` still reaches it.
* `bootc switch` needs root: use `sudo`.
* The reboot lands back on the old image → check `bootc status` for a staged
  entry, and confirm you did not regenerate keys between sealing `demo2` and
  switching: its UKI must be signed by the same demo keys that sealed the image
  you switched to.
* Registry left running afterwards? `podman rm -f registry` — it is not needed for
  step 07.
