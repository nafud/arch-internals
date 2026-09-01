# Phase 0 kickoff — foundations

- **Date:** 2026-09-01
- **Roadmap phase:** 0 — Foundations
- **Wiki pages:** [Arch Linux](https://wiki.archlinux.org/title/Arch_Linux),
  [FAQ](https://wiki.archlinux.org/title/Frequently_asked_questions),
  [Arch terminology](https://wiki.archlinux.org/title/Arch_terminology),
  [Core utilities](https://wiki.archlinux.org/title/Core_utilities),
  [man page](https://wiki.archlinux.org/title/Man_page)
- **Verification status:** written without live wiki access (egress blocked
  in the authoring environment); facts current to early 2026, unverified
  against today's wiki. Re-check links with `tools/verify-links.sh`.

## Why this phase exists

Arch hands you an almost-bare system and expects *you* to assemble it. Every
later phase assumes you can read a man page, move around the filesystem, and
reason about processes. Building that muscle first means that during the
Phase 1 install you'll be learning *Arch*, not fighting the shell.

## The mental models to build

### 1. Everything is a file (approximately)

Devices (`/dev/sda`), kernel state (`/proc`, `/sys`), sockets, pipes — Unix
exposes nearly everything through the file abstraction. This is why `cat`,
`echo` and redirection turn out to be system-administration tools, not just
text utilities: `cat /proc/cmdline` reads kernel state through the same
syscalls (`open`/`read`) as reading a text file. Later phases lean on this
constantly.

### 2. The filesystem hierarchy is a contract

`man 7 file-hierarchy` (systemd's version) and `man hier` describe *where
things go and why*:

| Path | Contract |
|---|---|
| `/usr` | Vendor-supplied, read-only-in-principle OS content. On Arch, **owned by pacman** — hand-editing here gets overwritten on update. |
| `/etc` | Host-specific configuration. Yours to edit; packages only drop defaults here. |
| `/var` | Variable state that must survive reboot: logs, caches, the pacman database. |
| `/boot` | Kernel images and early-boot files; often a separate (FAT) partition on UEFI. |
| `/proc`, `/sys` | Not on disk at all — kernel interfaces mounted as pseudo-filesystems. |
| `/run`, `/tmp` | tmpfs — RAM-backed, gone on reboot. |

The `/usr` vs `/etc` split is *the* line that makes a rolling release
survivable: pacman updates `/usr` freely and leaves `/etc` to you (via
`.pacnew` files — Phase 2).

### 3. Man page sections are namespaces

`fstab` the *file format* is `man 5 fstab`; `mount` the *command* is
`man 8 mount`; `mount` the *syscall* is `man 2 mount`. Same word, three
documents. Sections you'll use constantly: 1 (user commands), 5 (file
formats), 7 (concepts/overviews), 8 (admin commands). `man -k <term>`
(apropos) searches them all.

### 4. Processes: fork, exec, signals, exit codes

Every process has a parent; the shell `fork()`s and `exec()`s your commands;
`$?` carries the exit code; signals (`kill -l`) are the kernel's asynchronous
notifications, of which `SIGTERM` (polite) vs `SIGKILL` (unblockable) is the
distinction that matters daily. PID 1 is special: it's the init process —
on Arch, systemd — and it adopts orphans. All of Phase 4 grows out of this.

### 5. The shell is a programming language

Pipes compose programs; redirection rewires their file descriptors
(stdin 0, stdout 1, stderr 2 — `2>&1` makes sense once you see fd numbers);
variables and quoting rules explain 90% of "weird" shell behavior. Write
scripts early, they're this repo's lab notebook automation.

## Study plan

1. Read the five wiki pages above; note anything surprising about Arch's
   principles (rolling release, no hand-holding, wiki-centrality).
2. Read `man man`, then `man 5 fstab` and `man 7 file-hierarchy` end to end
   — the goal is fluency in *reading manuals*, the content comes back later.
3. Boot any live Linux ISO in a VM (lab: `labs/vm/`) and walk the hierarchy:
   `ls -l /`, `findmnt`, `cat /proc/cmdline`, `ls /proc/$$/`, `echo $$`.
4. Write one small script (e.g. journal-entry generator for these notes).

## Checkpoint self-quiz (answer in writing before Phase 1)

- What belongs in `/etc` vs `/usr` vs `/var`, and who "owns" each on Arch?
- What does `man 5` mean, and why is `man 5 crontab` different from
  `man 1 crontab`?
- What is a rolling release, and what discipline does it demand of you?
- What happens, step by step, when you type `ls | wc -l` and press enter?
- What is PID 1, and what makes it different from every other process?
