# Sealing a bootc image, end to end

Hands-on workshop for **TXLF 2026**. You take a Fedora bootc image, give it a signed
UKI with a composefs root and fs-verity, boot it, update it in place, and roll it back.

Every build/seal/verify command in this repo runs against
**[SNThrailkill/Bootc-Fedora](https://github.com/SNThrailkill/Bootc-Fedora)** — this
repo is only the workshop materials, so there is nothing to fork or vendor here.
The commands are proven against that repo at **`main` = 8c0ac1c**; if the surface
drifts, `./build.py --help` there is the source of truth. Step 05 offers a
pre-built fallback disk installed from Bootc-Fedora's published sealed image (see
[`build-demo-disk.yml`](.github/workflows/build-demo-disk.yml)).

## The eight steps at a glance

| # | Step | You end with | Time |
|---|---|---|---|
| 00 | [Prerequisites](docs/workshop/00-prereqs.md) | `check.sh` and `doctor` both green | 10 min |
| 01 | [Build your first bootc image](docs/workshop/01-build.md) | your own image, built with plain podman | 20 min |
| 02 | [Keys](docs/workshop/02-keys.md) | a demo PK/KEK/db, no private key in git | 15 min |
| 03 | [Seal](docs/workshop/03-seal.md) | `nginx-sealed` with a signed UKI | 25 min |
| 04 | [Verify](docs/workshop/04-verify.md) | `sbverify` OK on bootloader **and** UKI | 15 min |
| 05 | [Boot your sealed image](docs/workshop/05-boot.md) | a VM that boots with your keys | 30 min |
| 06 | [Update](docs/workshop/06-update.md) | your second image running, then a rollback | 30 min |
| 07 | [Supply chain](docs/workshop/07-supply-chain.md) | `Verified OK` on signature and SBOM | 15 min |

## Prerequisites

All of these are checked up front by step 00's `check.sh`:

* **podman** — required; the workshop never uses docker
* **Python 3.9+** and **git**
* **`/dev/fuse`** — sealed builds compute the composefs digest through fuse
* **~20 GB free disk**
* **cosign** — step 07
* **qemu** — step 05 (with an **OVMF** firmware build; KVM is optional, it only
  makes the boot faster)

## Quickstart

```bash
git clone https://github.com/SNThrailkill/txlf-2026-workshop
bash txlf-2026-workshop/check.sh              # 00, part 1

git clone https://github.com/SNThrailkill/Bootc-Fedora
cd Bootc-Fedora
./build.py doctor                             # 00, part 2
./build.py keygen --demo --with-auth          # 02
./build.py seal --image nginx-sealed --tag demo     # 03
./build.py verify --image nginx-sealed --tag demo   # 04
```

Then work through `docs/workshop/` in order. [`CHEATSHEET.md`](CHEATSHEET.md) has
every command in one place if you fall behind.

## Licence

[MIT](LICENSE). Bootc-Fedora itself carries its own licence — see that repo.
