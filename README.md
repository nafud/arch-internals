# arch-internals

A personal playground for learning Arch Linux internals — from first manual
install down to kernel code. The plan lives in **[ROADMAP.md](ROADMAP.md)**;
this repo holds the working notes, lab configs, and runbooks produced along
the way. Polished write-ups graduate to my knowledgebase.

Primary source for everything: the [Arch Wiki](https://wiki.archlinux.org/).

## Layout

```
ROADMAP.md          The learning plan (phases 0–10)
notes/              Per-phase study notes and install/lab journals
  01-installation/
  02-pacman/
  03-boot/
  04-systemd/
  05-kernel/
  06-storage/
  07-networking/
  08-graphics/
labs/               Experiment artifacts: PKGBUILDs, unit files, udev rules,
                    kernel-module hello-worlds, VM definitions
runbooks/           Tested repair procedures (won't-boot, broken-pacman,
                    no-network, disk-full, failed-service)
configs/            Reference copies of interesting /etc configs from the VMs
tools/              Repo utilities (verify-links.sh — Markdown link checker)
```

## Conventions

- Everything is done in VMs first; nothing here should assume a specific
  physical machine.
- Every note records the Arch Wiki page(s) it draws from, since the wiki is a
  moving target on a rolling release.
- A lab isn't "done" until it includes the break-and-repair exercise from the
  corresponding roadmap phase.
- Never commit secrets, keys, or LUKS headers — even from throwaway VMs.
