# 07 — Supply chain: verify a published image

**Goal:** verify a *published* sealed image's signature and its SBOM attestation
without building anything.

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true \
  ghcr.io/snthrailkill/bootc-fedora/nginx:sealed

cosign verify-attestation --key cosign.pub --insecure-ignore-tlog=true \
  --type spdxjson ghcr.io/snthrailkill/bootc-fedora/nginx:sealed
```

## ✓ You should see

* `Verified OK` for the image — the registry digest is signed by the key in
  `cosign.pub`.
* `Verified OK` for the attestation, whose predicate is an SPDX SBOM: the inventory of
  what that image contains.

## Why the `--insecure-ignore-tlog` flag

Bootc-Fedora's CI **tries** to publish to the Rekor transparency log and **falls back**
to signing without a log entry when Rekor rejects the request. So some published images
carry a Rekor entry and some do not, and a plain `cosign verify` fails on the ones that
do not. `--insecure-ignore-tlog=true` accepts either — it is the flag Bootc-Fedora's own
CI uses when it verifies its own output.

It is also required for anything you sign yourself with `--tlog-upload=false`.

## If stuck

* `no matching signatures` → you left off `--insecure-ignore-tlog=true`.
* `no matching attestations` → wrong predicate type; this SBOM is `spdxjson`.
* `cosign: command not found` → cosign ships separately from sigstore; install it and
  retry. Nothing needs rebuilding.
