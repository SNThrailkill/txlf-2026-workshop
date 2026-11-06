# 07 — Verify a published image's attachments

**Goal:** check the signature and the SBOM that Bootc-Fedora publishes *with*
its sealed image, without building anything.

Every image Bootc-Fedora publishes carries two signed attachments alongside it in
the registry, discoverable from the image reference itself:

* a **signature** — proves the image you pull is the one the maintainer signed;
* an **SBOM attestation** — a signed statement listing every package in the
  image.

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true \
  ghcr.io/snthrailkill/bootc-fedora/nginx:sealed

cosign verify-attestation --key cosign.pub --insecure-ignore-tlog=true \
  --type spdxjson ghcr.io/snthrailkill/bootc-fedora/nginx:sealed
```

`cosign.pub` is Bootc-Fedora's public key, committed in its repo root. You never
download the SBOM as a file — `verify-attestation` fetches the attachment stored
with the image and checks it against the same key.

## ✓ You should see

* `Verified OK` for the image.
* `Verified OK` for the attestation — if you want to page through the package
  list it contains:

```bash
cosign verify-attestation --key cosign.pub --insecure-ignore-tlog=true \
  --type spdxjson ghcr.io/snthrailkill/bootc-fedora/nginx:sealed \
  | jq -r .payload | base64 -d | jq '.predicate.packages | length'
```

## If stuck

* `no matching signatures` → you left off `--insecure-ignore-tlog=true`, the
  flag that skips the transparency-log requirement.
* `no matching attestations` → wrong predicate type; this SBOM is `spdxjson`.
* `cosign: command not found` → cosign was in the prerequisites (step 00) —
  install it and retry. Nothing needs rebuilding.
