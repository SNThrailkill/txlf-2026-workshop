# 02 — Generate demo Secure Boot keys

**Goal:** create your own PK/KEK/db hierarchy plus the UEFI `.auth` enrolment blobs,
then confirm no private key can reach git.

```bash
./build.py keygen --demo --with-auth
ls -l target/keys keys keys/auth/auto
git status --short
```

## ✓ You should see

* `target/keys/` contains **PK, KEK and db**, each as `.key` **and** `.crt`.
* `keys/` contains the three **`.crt`** files; `keys/auth/auto/` contains the three
  **`.auth`** blobs.
* `git status --short` shows **no `*.key` file** — private keys live under
  `target/`, which is gitignored. It *will* show `keys/*.crt` and
  `keys/auth/auto/*.auth` as modified, because keygen overwrote the repo's committed
  public certs with your demo ones.

**Do not commit those changes.** They are throwaway demo material; the housekeeping
section of the cheatsheet restores them with `git checkout -- keys`.

## If stuck

* `keygen` refuses without `--demo` — it is guarded so demo keys are never mistaken
  for production ones.
* `--with-auth` builds the blobs in a container, so it needs podman working (step 00).
* If `git status --short` ever shows a `.key`, stop: that must never be committed.
