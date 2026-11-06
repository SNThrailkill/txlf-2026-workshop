# 02 — Generate demo Secure Boot keys

**Goal:** create your own PK/KEK/db hierarchy plus the UEFI `.auth` enrollment
blobs, then confirm no private key can reach git.

```bash
./build.py keygen --demo --with-auth
ls -l target/keys keys keys/auth/auto
git status --short
```

## What that actually runs

`keygen` is a thin wrapper, and you can read the scripts it calls:

* `keys/util/keygen.sh` — for **PK, KEK and db** it runs
  `openssl req -newkey rsa:4096 -nodes -x509 -sha256 -days 3650` with a subject
  like `CN=bootc examples Secure Boot db`, writing the private `.key` under
  `target/keys/` (never committed) and the public `.crt`/`.cer`. PK is the root
  of trust, KEK authorizes db updates, and db is the key that signs the
  bootloader and every UKI — the one that matters day to day.
* `keys/util/gen-auth.sh` — runs `sbsiglist`/`sbvarsign` (sbsigntools, in a
  container) to turn those certificates into the **`.auth` enrollment blobs**
  the firmware can apply on first boot.

No magic: two shell scripts. You are expected to trust them because you can read
them.

## ✓ You should see

* `target/keys/` contains **PK, KEK and db**, each as `.key` **and** `.crt`.
* `keys/` contains the three **`.crt`** files; `keys/auth/auto/` the three
  **`.auth`** blobs.
* `git status --short` shows **no `*.key` file** — private keys live under
  `target/`, which is gitignored. It *will* show `keys/*.crt` and
  `keys/auth/auto/*.auth` as modified, because keygen overwrote the repo's
  committed public certs with your demo ones.

**Do not commit those changes.** The housekeeping section of the cheatsheet
restores them with `git checkout -- keys`.

## If stuck

* `keygen` refuses without `--demo` — it is guarded so demo keys are never
  mistaken for production ones.
* `--with-auth` builds the blobs in a container, so it needs podman working
  (step 00).
* If `git status --short` ever shows a `.key`, stop: that must never be committed.
