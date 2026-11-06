# 06 — Update in place, then roll back

**Goal:** seal a second image, boot it on the running VM, then roll back to the
first.

The VM from step 05 is still running, and the registry you started there is
still serving.

On the **host**:

```bash
./build.py seal --image nginx-sealed --tag demo2
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

`10.0.2.2` is the fixed address qemu's user-mode networking assigns as the
guest's gateway to your machine — it is not specific to this VM; it is the
default slirp subnet (network `10.0.2.0/24`, guest `10.0.2.15`).

## ✓ You should see

* After the switch, `bootc status` lists **two deployments**: `demo2` staged and
  `demo` still booted.
* After the reboot, `demo2` is booted — accepted by Secure Boot because its UKI
  is signed with the same demo db key the VM enrolled in step 05.
* `bootc rollback` plus a reboot returns you to `demo`, with `demo2` still
  present.

## If stuck

* `image not found` or a connection error → the guest cannot reach the registry.
  Check it is running (`podman ps`), port 5000 is mapped, and the push succeeded.
* The reboot lands back on the old image → check `bootc status` for a staged
  entry, and confirm you did not regenerate keys between step 02 and now.
* On macOS/Windows the registry runs inside the podman VM, but `-p 5000:5000`
  forwards it to your host, so `10.0.2.2:5000` still reaches it.

## Clean up

```bash
# on the host, once you are done with the VM:
podman rm -f registry
```

> If you used the fallback disk in step 05, this step will not work: that VM
> enrolled Bootc-Fedora's keys, which reject your demo2 UKI. Build your own disk
> (step 05, primary path) and redo it.
