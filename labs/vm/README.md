# Lab 0 — VM playground + verified Arch ISO

- **Date:** 2026-09-01
- **Roadmap phase:** 0 — Foundations (lab)
- **Wiki pages:** [QEMU](https://wiki.archlinux.org/title/QEMU),
  [Installation guide](https://wiki.archlinux.org/title/Installation_guide) (§ Pre-installation)
- **Verification status:** written without live wiki access; commands are
  knowledge-based (early 2026), unverified against today's wiki. OVMF paths
  vary by host distro — check yours.

Goal: a disposable UEFI VM you can break without fear, booting an Arch ISO
whose authenticity you have *cryptographically verified* — your first contact
with Arch's trust model (the same web of trust pacman uses in Phase 2).

## 1. Get the ISO

Download the latest `archlinux-YYYY.MM.DD-x86_64.iso` **and its `.sig`
file** from a mirror listed at <https://archlinux.org/download/>. The ISO is
rebuilt monthly with archiso; always grab a current one (a stale ISO means a
huge first `pacman -Syu` and occasionally keyring pain).

## 2. Verify it (don't skip this)

The ISO is signed with the Arch release key. Two independent checks:

```sh
# Checksum: compare against the b2sums/sha256sums published on the
# download page (NOT on the mirror you downloaded from):
b2sum archlinux-*.iso

# Signature: fetch the signing key via WKD, then verify:
gpg --auto-key-locate clear,wkd -v --locate-external-key pierre@archlinux.org
gpg --keyserver-options auto-key-retrieve --verify archlinux-*.iso.sig
```

*Why both:* the checksum proves integrity (no corrupt download); the
signature proves authenticity (built by Arch, not a tampered mirror). Note
that a "Good signature" with an untrusted key warning is expected unless you
mark the key trusted — read what gpg is actually telling you.

## 3. Create the VM (QEMU/KVM, UEFI)

```sh
# One-time: a 40G sparse disk (grows on demand)
qemu-img create -f qcow2 arch.qcow2 40G

# Per-VM: writable copy of the UEFI vars (path is for an Arch/Fedora-ish
# host with edk2-ovmf installed — locate OVMF_VARS on your host)
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd ./ovmf_vars.fd
```

Then `./run.sh install` to boot the ISO, `./run.sh` afterwards to boot from
disk. Console tips: the ISO boots to a root zsh; add `console=ttyS0` in the
boot menu (press `e`) if you prefer the serial console flag workflow.

Alternatives if you'd rather click: virt-manager (libvirt frontend over the
same QEMU/KVM), VirtualBox, VMware. The roadmap only assumes *a* VM with
UEFI firmware and snapshot ability.

## 4. Snapshots = courage

```sh
qemu-img snapshot -c fresh-install arch.qcow2   # create
qemu-img snapshot -l arch.qcow2                 # list
qemu-img snapshot -a fresh-install arch.qcow2   # roll back (VM off!)
```

Take a snapshot before every break-and-repair exercise. Rolling back is not
cheating — repeating a repair *after* understanding it is.

## Done when

- [ ] ISO checksum matches the download page and gpg reports a good signature
- [ ] VM boots the ISO in UEFI mode (`ls /sys/firmware/efi/efivars` is non-empty in the live env)
- [ ] You can create, list, and roll back a snapshot
- [ ] You've walked the live environment per the Phase 0 study note
