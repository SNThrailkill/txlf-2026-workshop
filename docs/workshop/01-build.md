# 01 — Build an unsealed image

**Goal:** build the `nginx` image and get inside it, to see the tree the seal chain
will later sign.

```bash
./build.py images
./build.py matrix | jq .
./build.py build --image nginx --tag demo
./build.py shell --image nginx --tag demo
```

Inside that shell:

```bash
bootc status
ls /etc/containers/systemd
exit
```

## ✓ You should see

* `images` prints the image table, including **`nginx-sealed`** — the sealed variant
  you build in step 03.
* `matrix` prints JSON. It is the same table CI fans out from, so the images you
  build locally are the images that get published.
* The build completes target `nginx` and ends with a finished `podman build`.
* Inside the shell, `bootc status` lists **exactly one deployment** — the container
  you are standing in — and `/etc/containers/systemd` holds the nginx and Pi-hole
  quadlet files.

## If stuck

* A failed base pull is usually network or registry auth: retry once, then
  `./build.py build --image nginx --tag demo --pull`.
* `matrix | jq .` needs `jq`; `matrix` pretty-prints on its own, and `--compact`
  gives a single line.
* `bootc status` in a container looks sparse on purpose — you are not on a booted
  host yet. That is step 05.
