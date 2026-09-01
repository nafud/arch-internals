# Arch Linux Internals — Learning Roadmap

A structured path from zero Arch knowledge to understanding how Arch Linux and
its kernel actually operate, with the [Arch Wiki](https://wiki.archlinux.org/)
as the primary source throughout. Every phase links the canonical wiki pages,
states what you should be able to do afterwards, and gives hands-on lab work
for this repository's playground.

**How to use this roadmap**

- Work through the phases in order; each one builds on the previous.
- Do everything in a virtual machine first (QEMU/KVM, VirtualBox, or VMware).
  Breaking and repairing a VM is the fastest way to learn internals.
- Keep notes and working configs in this repo (see the suggested layout in
  `README.md`), and promote polished write-ups to your knowledgebase.
- The Arch Wiki is versionless and maintained continuously — when this roadmap
  and the wiki disagree, trust the wiki.

**Two ground rules of Arch** (internalize these before anything else):

1. Arch is a **rolling release**: there are no version upgrades, only
   continuous updates via `pacman -Syu`. **Partial upgrades are unsupported**
   (never `pacman -Sy <pkg>` without `-u`).
2. Arch follows the **KISS / do-it-yourself principle**: the distribution
   gives you upstream software with minimal patching, and *you* assemble and
   maintain the system. That is exactly why it is an ideal internals classroom.

---

## Phase 0 — Foundations (before touching Arch)

Arch assumes general Linux literacy. If you have none, build it here; if you
have some, skim and move on.

**Read**

- [Arch Linux](https://wiki.archlinux.org/title/Arch_Linux) — the principles:
  simplicity, modernity, pragmatism, user centrality, versatility.
- [Frequently asked questions](https://wiki.archlinux.org/title/Frequently_asked_questions)
- [Arch terminology](https://wiki.archlinux.org/title/Arch_terminology)
- [Core utilities](https://wiki.archlinux.org/title/Core_utilities)
- [man page](https://wiki.archlinux.org/title/Man_page) — learn to read
  manuals; `man man`, `man 5 fstab` (sections matter).

**Understand**

- The shell (Bash), pipes, redirection, environment variables.
- The filesystem hierarchy: `/etc`, `/usr`, `/var`, `/boot`, `/proc`, `/sys`
  (`man 7 file-hierarchy`, `man hier`).
- Users, groups, permissions, ownership.
- What a process is; signals; `ps`, `top`, `kill`.

**Lab**

- Set up a VM hypervisor on your current OS and verify you can boot any live
  Linux ISO in it.
- Practice: navigate the FHS on a live system, read three man pages end to
  end, write a small shell script.

**Checkpoint** — you can explain: what `/etc` vs `/usr` vs `/var` hold, what a
man page section number means, and what a rolling release is.

---

## Phase 1 — Manual installation (the canonical Arch lesson)

The manual install *is* the introduction to Arch internals: you perform every
step another distro's installer hides. Skip `archinstall` for now — it works,
but it defeats the purpose of learning.

**Read**

- [Installation guide](https://wiki.archlinux.org/title/Installation_guide) —
  THE page. Follow it verbatim in a VM.
- [Partitioning](https://wiki.archlinux.org/title/Partitioning)
- [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition)
- [File systems](https://wiki.archlinux.org/title/File_systems)
- [fstab](https://wiki.archlinux.org/title/Fstab)
- [chroot](https://wiki.archlinux.org/title/Chroot) — understand what
  `arch-chroot` actually does (bind-mounts `/proc`, `/sys`, `/dev`, etc.).
- [General recommendations](https://wiki.archlinux.org/title/General_recommendations)
  — the official "what now?" page after installation.
- [Mirrors](https://wiki.archlinux.org/title/Mirrors) and
  [Reflector](https://wiki.archlinux.org/title/Reflector)

**Understand**

- The live ISO environment (released monthly, built with archiso).
- UEFI vs legacy BIOS boot, GPT vs MBR partition tables.
- Why the ESP exists, what mounts where, and how `genfstab` produces `fstab`.
- What `pacstrap` installs (`base`, `linux`, `linux-firmware`) and what those
  packages actually contain.
- CPU microcode updates (`intel-ucode` / `amd-ucode`) — what they are and how
  they get loaded at boot.
- Bootloader installation (start with GRUB or systemd-boot; Phase 3 goes deep).

**Lab**

- Install Arch manually in a UEFI VM, typing every command yourself. Document
  each step and *why* it exists in `notes/01-installation/`.
- Do a second install with different choices: BIOS/MBR, different filesystem,
  systemd-boot instead of GRUB.
- Deliberately skip a step (e.g. forget the bootloader or fstab entry), boot,
  observe the failure, then repair it from the live ISO with `arch-chroot`.

**Checkpoint** — you can install Arch from memory using only `man` pages and
the wiki, and you can explain what every command in your install log did.

---

## Phase 2 — Package management: pacman, libalpm, and the AUR

Pacman is the heart of Arch system operation. Understanding it deeply is
non-negotiable for troubleshooting.

**Read**

- [pacman](https://wiki.archlinux.org/title/Pacman) — full page, including
  the database and cache sections.
- [pacman/Tips and tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
- [pacman/Package signing](https://wiki.archlinux.org/title/Pacman/Package_signing)
- [Official repositories](https://wiki.archlinux.org/title/Official_repositories)
- [System maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [Downgrading packages](https://wiki.archlinux.org/title/Downgrading_packages)
  and the [Arch Linux Archive](https://wiki.archlinux.org/title/Arch_Linux_Archive)
- [Arch build system](https://wiki.archlinux.org/title/Arch_build_system)
- [makepkg](https://wiki.archlinux.org/title/Makepkg) and
  [PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD)
- [Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository)
- [AUR helpers](https://wiki.archlinux.org/title/AUR_helpers) — note they are
  **unsupported**; learn the manual `makepkg` flow first.

**Understand**

- pacman is a frontend to **libalpm** (Arch Linux Package Management library).
- On-disk anatomy:
  - `/etc/pacman.conf` — repos, options, hooks behaviour (`man pacman.conf`).
  - `/etc/pacman.d/mirrorlist` — mirror selection.
  - `/var/lib/pacman/sync/` — sync databases downloaded from mirrors.
  - `/var/lib/pacman/local/` — the local database: one directory per installed
    package holding `desc`, `files`, and install scripts. This *is* the record
    of your installed system.
  - `/var/cache/pacman/pkg/` — downloaded package cache (your rollback safety
    net; clean with `paccache`, not `rm`).
- Package format: `.pkg.tar.zst` archives containing the files plus
  `.PKGINFO` and `.MTREE` metadata.
- pacman hooks (`/usr/share/libalpm/hooks/`, `/etc/pacman.d/hooks/`,
  `man alpm-hooks`) — how things like initramfs rebuilds trigger automatically
  on kernel updates.
- Package signing: `pacman-key`, the `archlinux-keyring` package, the web of
  trust from the Arch master keys.
- Repositories: `core`, `extra`, `multilib` (+ `core-testing`/`extra-testing`).
  Note: the old `community` repo was merged into `extra` when Arch moved
  packaging to Git in 2023 — older docs still mention it.
- The build chain: PKGBUILD → `makepkg` → package → `pacman -U`. Official
  package sources are fetched with `pkgctl repo clone` from the `devtools`
  package (the older `asp` tool is deprecated).
- The AUR ships **build scripts, not binaries** — you (or a helper) build
  locally. Read every PKGBUILD before building; the AUR is user content.
- **How the distribution itself operates** (the machinery behind your
  mirror): every official package base (*pkgbase* — split packages share
  one PKGBUILD and one repo) has its own Git repository on
  Arch's GitLab (this is what `pkgctl repo clone` fetches); a packager bumps
  the PKGBUILD, builds it in a clean chroot with devtools, signs the package
  with their key (trusted via `archlinux-keyring`), and pushes it into the
  repo databases; mirrors then sync from the master server in tiers. Tracing
  one real package update from upstream release notes to `pacman -Syu` on
  your VM makes the whole rolling-release model concrete.
- Key operations and what they touch: `-Syu`, `-U`, `-R`/`-Rs`, `-Qi`/`-Qo`/
  `-Ql`, `-F`, `-Qtd` (orphans), `.pacnew`/`.pacsave` handling with
  `pacdiff`.

**Lab**

- Inspect `/var/lib/pacman/local/<pkg>/` for a few packages; correlate `files`
  with `pacman -Ql`.
- Unpack a `.pkg.tar.zst` from the cache and read `.PKGINFO`.
- Write a trivial PKGBUILD (e.g. package a shell script), build it with
  `makepkg`, install with `pacman -U`, then remove it.
- Build one AUR package fully manually (git clone → read PKGBUILD → makepkg).
- Clone an official package's source with `pkgctl repo clone` and rebuild it.
- Break-and-repair: interrupt an update to simulate a corrupt local DB entry,
  practice cache-based downgrade of a package, resolve a `.pacnew` for
  `/etc/pacman.conf` with `pacdiff`.
- Set up `reflector` and a `paccache` cleanup hook/timer.

**Checkpoint** — given a broken update (key error, conflicting files, orphan
mess, or "unable to lock database"), you can diagnose and repair it without
reinstalling.

---

## Phase 3 — The boot process, end to end

This is where Arch internals get real: firmware → bootloader → kernel →
initramfs → init. Most "my system won't boot" troubleshooting lives here.

**Read**

- [Arch boot process](https://wiki.archlinux.org/title/Arch_boot_process) —
  the map for this whole phase.
- [Unified Extensible Firmware Interface](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface)
- [GRUB](https://wiki.archlinux.org/title/GRUB) and
  [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot)
- [mkinitcpio](https://wiki.archlinux.org/title/Mkinitcpio) — read all of it,
  especially the HOOKS section.
- [Kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters)
- [Microcode](https://wiki.archlinux.org/title/Microcode)
- [Unified kernel image](https://wiki.archlinux.org/title/Unified_kernel_image)

**Understand**

- Firmware stage: UEFI boot entries (`efibootmgr`), the ESP, Secure Boot (at
  least conceptually); or BIOS/MBR boot code for legacy.
- Bootloader stage: how GRUB (`grub-mkconfig`) and systemd-boot (loader
  entries in the ESP) find and start the kernel; EFISTUB as the "no
  bootloader" option.
- Kernel + initramfs stage:
  - What `/boot` contains: `vmlinuz-linux`, `initramfs-linux.img`,
    `initramfs-linux-fallback.img`.
  - What the initramfs is (a cpio archive providing early userspace), why it
    exists (mounting the real root: modules, encryption, RAID, LVM).
  - mkinitcpio configuration: `/etc/mkinitcpio.conf` (`MODULES`, `BINARIES`,
    `FILES`, `HOOKS`) and presets in `/etc/mkinitcpio.d/`.
  - How hooks work (busybox-based default vs the `systemd` hook), what
    `autodetect` does, why the fallback image is bigger.
  - Alternatives exist: dracut, booster.
  - Unified kernel images (UKIs) as the modern single-file boot artifact.
- Handoff to init: the kernel mounts the initramfs, runs its `/init`,
  switches root, and executes `/sbin/init` — a symlink to systemd.
- Kernel command line: where it is set per bootloader, how to read it at
  runtime (`/proc/cmdline`), common parameters (`root=`, `rw`, `quiet`,
  `loglevel=`).

**Lab**

- Diagram the full boot chain of your VM by hand, from firmware to login.
- List and interpret your UEFI entries with `efibootmgr -v`.
- Unpack your initramfs with `lsinitcpio` and inspect its `/init` script.
- Edit `mkinitcpio.conf` (e.g. add a module), regenerate with `mkinitcpio -P`,
  verify with `lsinitcpio`.
- Boot with edited kernel parameters from the bootloader menu (e.g.
  `systemd.unit=rescue.target`, remove `quiet`).
- Convert a VM from GRUB to systemd-boot, then to a UKI booted via EFISTUB.
- Break-and-repair: delete the initramfs and rebuild it from a live ISO
  chroot; misconfigure `root=` and recover from the emergency shell.

**Checkpoint** — given any boot failure, you can identify *which stage* failed
from the symptoms and fix it from a live ISO.

---

## Phase 4 — systemd and the daemon landscape

Arch uses systemd for init, service management, logging, device events,
timers, and more. Fluency here is fluency in a running Arch system: nearly
every long-running process on a stock install is either PID 1 or a daemon it
supervises, so this phase is a deep dive into what daemons *are* and which
ones make Arch tick.

**Read**

- [systemd](https://wiki.archlinux.org/title/Systemd) — full page.
- [systemd/Journal](https://wiki.archlinux.org/title/Systemd/Journal)
- [systemd/Timers](https://wiki.archlinux.org/title/Systemd/Timers)
- [systemd/User](https://wiki.archlinux.org/title/Systemd/User) — the
  per-user instance.
- [systemd FAQ](https://wiki.archlinux.org/title/Systemd/FAQ)
- [udev](https://wiki.archlinux.org/title/Udev)
- [D-Bus](https://wiki.archlinux.org/title/D-Bus)
- [systemd-timesyncd](https://wiki.archlinux.org/title/Systemd-timesyncd)
- Man pages: `man systemd`, `man systemd.unit`, `man systemd.service`,
  `man systemd.exec`, `man systemd.socket`, `man systemd.target`,
  `man bootup`, `man daemon` (systemd's own essay on classic vs "new-style"
  daemons — read this one carefully), `man journalctl`, `man udev`,
  `man sd_notify`.

**Understand — what a daemon is**

- The classic SysV daemon recipe (double-fork, `setsid`, detach from the
  terminal, write a pidfile, log to syslog) versus a systemd "new-style"
  daemon: an ordinary foreground process that systemd starts, supervises in
  its own cgroup, and whose stdout/stderr land in the journal. `man daemon`
  covers both worlds.
- Service types and what they mean for supervision: `simple`/`exec`,
  `forking`, `oneshot`, `notify` (readiness via `sd_notify`) and
  `notify-reload`, `dbus`, `idle`.
- **Socket activation**: systemd listens on the socket, starts the daemon on
  first connection, and passes the file descriptor in — why this enables
  parallel boot and on-demand services.
- Every service runs in its own **cgroup** (v2): explore the tree with
  `systemd-cgls`, live usage with `systemd-cgtop`; resource limits via
  `man systemd.resource-control`.
- Sandboxing directives in unit files (`ProtectSystem=`, `PrivateTmp=`,
  `NoNewPrivileges=`, … — `man systemd.exec`) and the audit tool
  `systemd-analyze security <unit>`.

**Understand — the machinery of systemd itself**

- Units and their types (service, target, timer, mount, socket, path, …);
  targets as runlevel successors (`multi-user.target`, `graphical.target`).
- Unit file locations and precedence: `/usr/lib/systemd/system/` (packaged)
  vs `/etc/systemd/system/` (admin); drop-in overrides via
  `systemctl edit`; what `enable` actually does (creates symlinks per the
  unit's `[Install]` section).
- Dependency and ordering directives (`Wants=`, `Requires=`, `After=`,
  `Before=`) and how the boot transaction is assembled.
- The journal: binary logs, persistence in `/var/log/journal/`, filtering
  (`-b`, `-u`, `-p`, `--since`), size management.
- Boot-time analysis: `systemd-analyze`, `systemd-analyze blame`,
  `systemd-analyze critical-chain`.
- The user instance: `systemctl --user`, lingering, where user units live.

**Understand — the daemon roster of a stock Arch system**

Run `systemctl list-units --type=service` on your VM and account for every
row. On a minimal install you should be able to explain at least:

| Daemon | Job | Interrogate with |
|---|---|---|
| `systemd` (PID 1) | init, service manager, supervision | `systemctl` |
| `systemd-journald` | collects kernel + service logs | `journalctl` |
| `systemd-udevd` | kernel uevents → device nodes, rules, module loading | `udevadm` |
| `systemd-logind` | seats, sessions, power/lid handling | `loginctl` |
| `systemd-timesyncd` | SNTP time sync | `timedatectl` |
| `systemd-networkd` / `systemd-resolved` | networking / DNS (if enabled — Phase 7) | `networkctl` / `resolvectl` |
| D-Bus broker | inter-process message bus that most of the above talk over | `busctl` |
| `agetty` | the login prompt on each virtual console | `systemctl status getty@tty1` |

- D-Bus as the system's nervous system: system vs session bus, how
  `systemctl`/`loginctl`/`timedatectl` are largely D-Bus clients of the
  corresponding daemon, bus activation of services. Explore with
  `busctl list`, `busctl tree`, `busctl introspect`. (Arch has shipped
  `dbus-broker` as its default D-Bus implementation since January 2023; the
  reference `dbus-daemon` remains available via `dbus-daemon-units`.)
- udev in depth: kernel uevents, rules (`/etc/udev/rules.d/`), persistent
  device naming (`/dev/disk/by-uuid/`, network interface names).
- Related pieces you'll meet constantly: `systemd-tmpfiles`,
  `systemd-sysusers`, `timedatectl`, `localectl`, `hostnamectl`.

**Lab**

- Account for every running service on your minimal VM (the table above):
  for each, find its unit file, its cgroup, its journal stream, and its
  D-Bus name if it has one. Write the tour up in `notes/04-systemd/`.
- Write a custom service unit + timer pair (e.g. a backup script), enable it,
  trace its logs in the journal.
- Write the same small daemon twice: once `Type=simple`, once `Type=notify`
  with an `sd_notify` readiness call (a shell script with `systemd-notify`
  is fine); observe how `systemctl start` behaves differently.
- Make a toy socket-activated echo service (`.socket` + `.service`) and
  watch systemd spawn it on first connection.
- Run `systemd-analyze security` against a stock daemon and your own service;
  harden yours with sandboxing directives until the score improves.
- Explore the bus: `busctl tree org.freedesktop.login1`, then
  `busctl introspect org.freedesktop.login1 /org/freedesktop/login1`, and
  call a method (e.g. query your session) from the CLI.
- Override a packaged unit with `systemctl edit` and inspect the drop-in.
- Walk your boot with `systemd-analyze critical-chain` and speed something up.
- Write a udev rule (e.g. symlink or permission change for a USB device) and
  test with `udevadm monitor` / `udevadm test`.
- Break-and-repair: mask a critical unit, observe the degraded boot, recover
  via `systemd.unit=rescue.target`; kill `systemd-udevd` mid-session and
  watch supervision restart it.

**Checkpoint** — you can name every daemon on your minimal system and its
job, explain how a service goes from unit file to supervised cgroup, and go
from "service X misbehaves" to root cause using `systemctl status`,
`journalctl`, and unit-file inspection alone.

---

## Phase 5 — The kernel on Arch

Now the core of your goal: what the kernel is, how Arch packages it, how to
configure, replace, and build it.

**Read**

- [Kernel](https://wiki.archlinux.org/title/Kernel) — official kernels and
  the compilation overview.
- [Kernel module](https://wiki.archlinux.org/title/Kernel_module)
- [Kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters) (revisit)
- [sysctl](https://wiki.archlinux.org/title/Sysctl)
- [Kernel/Traditional compilation](https://wiki.archlinux.org/title/Kernel/Traditional_compilation)
- [Kernel/Arch build system](https://wiki.archlinux.org/title/Kernel/Arch_build_system)
- [Dynamic Kernel Module Support](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support) (DKMS)

**Understand**

- The officially supported kernel packages — `linux` (stable), `linux-lts`,
  `linux-hardened`, `linux-zen` — how they differ, and that multiple kernels
  can be installed side by side (each gets its own `/boot` images and
  `/usr/lib/modules/<version>/` tree).
- Where the kernel lives on disk: compressed image `vmlinuz-*` in `/boot`,
  modules under `/usr/lib/modules/$(uname -r)/`.
- Arch's kernel config is introspectable: `zcat /proc/config.gz` (the Arch
  kernels enable `CONFIG_IKCONFIG_PROC`).
- Modules end to end: `lsmod`, `modinfo`, `modprobe`; auto-loading via udev
  and module aliases; configuration in `/etc/modprobe.d/` (options,
  blacklisting) and `/etc/modules-load.d/` (forced loading).
- Runtime tuning: `sysctl` and `/proc/sys/`, persistent settings in
  `/etc/sysctl.d/`.
- The kernel's userspace-facing pseudo-filesystems: `/proc` (processes,
  `cmdline`, `meminfo`) and `/sys` (devices, drivers, kobjects) — how tools
  like `lscpu`, `lsblk`, `ip` are largely readers of these.
- Out-of-tree modules and why DKMS exists (rebuilding third-party modules on
  every kernel update); the `linux-headers` packages.
- Building your own kernel both ways:
  1. **Arch Build System way** — modify the official `linux` PKGBUILD
     (via `pkgctl repo clone linux`), change the config, build a proper
     package.
  2. **Traditional way** — kernel.org sources, `make menuconfig`, `make`,
     manual module + image install, initramfs preset, bootloader entry.
- How a kernel update flows through the system: pacman installs new modules
  and image → alpm hooks regenerate the initramfs → old running kernel keeps
  running but can't load modules that were removed (the classic "reboot after
  kernel update" issue).

**Lab**

- Install `linux-lts` alongside `linux`, add a boot entry, and verify you can
  choose kernels at boot (`uname -r` to confirm).
- Diff the configs of two official kernels (`/proc/config.gz` vs the other
  kernel's shipped config).
- Blacklist a module, set a module option, and force-load one; verify each
  with `modinfo`/`lsmod` and the journal.
- Tune something with `sysctl` (e.g. `vm.swappiness`), persist it, verify
  after reboot.
- Build a custom kernel with a modified config using the ABS method; boot it.
- Build a trivial out-of-tree "hello world" kernel module against
  `linux-headers`, load it, read its `printk` output with `dmesg`; then
  package it with DKMS so it survives a kernel update.
- Watch a kernel update happen: run the update, read the hook output, confirm
  the initramfs was rebuilt, and inspect `/usr/lib/modules/` before and after
  rebooting.

**Checkpoint** — you can explain what happens on disk and at boot when the
`linux` package updates, and you have booted a kernel you built yourself.

---

## Phase 6 — Storage, filesystems, and encryption

Root-cause troubleshooting regularly bottoms out in storage. This phase makes
the block-device stack transparent.

**Read**

- [File systems](https://wiki.archlinux.org/title/File_systems) (revisit)
- [ext4](https://wiki.archlinux.org/title/Ext4)
- [Btrfs](https://wiki.archlinux.org/title/Btrfs)
- [LVM](https://wiki.archlinux.org/title/LVM)
- [dm-crypt](https://wiki.archlinux.org/title/Dm-crypt) — start with
  [dm-crypt/Encrypting an entire system](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [Persistent block device naming](https://wiki.archlinux.org/title/Persistent_block_device_naming)
- [Swap](https://wiki.archlinux.org/title/Swap) and
  [Zram](https://wiki.archlinux.org/title/Zram)
- [Solid state drive](https://wiki.archlinux.org/title/Solid_state_drive) (TRIM)

**Understand**

- The block layer as a stack: disk → partition → (LUKS) → (LVM) → filesystem,
  and how device-mapper implements the middle layers (`lsblk`, `dmsetup ls`).
- Why persistent naming (UUID/PARTUUID/labels) matters in `fstab` and kernel
  parameters.
- ext4 vs btrfs mental models; btrfs subvolumes and snapshots.
- LUKS: headers, keyslots, `cryptsetup`; how the `encrypt` (or `sd-encrypt`)
  mkinitcpio hook unlocks root at boot — tying Phase 3 and Phase 6 together.
- Swap files/partitions, zram, and what the OOM killer is.

**Lab**

- In a VM with a spare disk: build a full stack by hand — partition, LUKS,
  LVM on LUKS, filesystems, mount via UUID, then reproduce it as an encrypted
  Arch install that unlocks at boot.
- Create btrfs subvolumes and take/restore a snapshot before an update.
- Break-and-repair: corrupt an fstab entry and boot (emergency mode
  practice); back up and intentionally damage a LUKS header on a *throwaway*
  volume, observe, restore from backup.

**Checkpoint** — you can read any `lsblk` output and explain every layer, and
an encrypted-boot failure doesn't scare you.

---

## Phase 7 — Networking

**Read**

- [Network configuration](https://wiki.archlinux.org/title/Network_configuration)
- [systemd-networkd](https://wiki.archlinux.org/title/Systemd-networkd)
- [systemd-resolved](https://wiki.archlinux.org/title/Systemd-resolved)
- [NetworkManager](https://wiki.archlinux.org/title/NetworkManager)
- [Network configuration/Wireless](https://wiki.archlinux.org/title/Network_configuration/Wireless)
  and [iwd](https://wiki.archlinux.org/title/Iwd)
- [nftables](https://wiki.archlinux.org/title/Nftables) /
  [firewalld](https://wiki.archlinux.org/title/Firewalld)
- [OpenSSH](https://wiki.archlinux.org/title/OpenSSH)

**Understand**

- The `ip` command (`iproute2`) as the ground truth: links, addresses,
  routes, neighbors.
- Pick **one** network manager and know why (networkd for servers/VMs,
  NetworkManager for laptops); never run two managers on one interface.
- DNS resolution path: `/etc/resolv.conf`, `/etc/nsswitch.conf`,
  systemd-resolved's stub resolver.
- Wireless stack: kernel driver → nl80211 → iwd/wpa_supplicant → manager.
- Firewalling with nftables basics.

**Lab**

- Configure the VM's network three ways in sequence: manually with `ip`,
  with systemd-networkd `.network` files, with NetworkManager.
- Set up systemd-resolved and trace a lookup with `resolvectl query -v` (or
  `resolvectl status`).
- Write a minimal nftables ruleset allowing SSH in, and verify it.
- Break-and-repair: sabotage DNS (bad `resolv.conf`) and diagnose with
  `resolvectl`/`dig`; bring an interface down and restore it manually.

**Checkpoint** — "the network is down" turns into a layered diagnosis (link →
address → route → DNS → firewall) you can run from memory.

---

## Phase 8 — Graphics and desktop plumbing *(optional but recommended)*

Skip or defer if you run Arch headless; do it if you daily-drive a desktop.

**Read**

- [Xorg](https://wiki.archlinux.org/title/Xorg) and
  [Wayland](https://wiki.archlinux.org/title/Wayland)
- [Kernel mode setting](https://wiki.archlinux.org/title/Kernel_mode_setting)
- Your GPU's page: [NVIDIA](https://wiki.archlinux.org/title/NVIDIA),
  [AMDGPU](https://wiki.archlinux.org/title/AMDGPU), or
  [Intel graphics](https://wiki.archlinux.org/title/Intel_graphics)
- [Desktop environment](https://wiki.archlinux.org/title/Desktop_environment) /
  [Window manager](https://wiki.archlinux.org/title/Window_manager) /
  [Display manager](https://wiki.archlinux.org/title/Display_manager)

**Understand**

- KMS/DRM in the kernel; Mesa for userspace OpenGL/Vulkan; how NVIDIA's
  proprietary driver differs (and interacts with kernel updates — DKMS again).
- X11 vs Wayland architecture at a block-diagram level.
- The login chain: display manager → session → compositor/WM.

**Lab**

- Bring up a minimal graphical session from scratch (e.g. a lightweight WM or
  compositor) without a display manager first; add one after.
- Read the journal/Xorg log to trace how your GPU driver and displays were
  detected.

---

## Phase 9 — Maintenance, troubleshooting method, and security

This phase turns accumulated knowledge into a repeatable operating practice.

**Read**

- [System maintenance](https://wiki.archlinux.org/title/System_maintenance) — reread fully.
- [General troubleshooting](https://wiki.archlinux.org/title/General_troubleshooting)
- [Security](https://wiki.archlinux.org/title/Security)
- The [Arch Linux news feed](https://archlinux.org/news/) — read it **before**
  every update; manual-intervention notices land there.

**Understand & practice**

- A standing update discipline: read news → snapshot/backup → `pacman -Syu` →
  handle `.pacnew` → reboot after kernel/systemd updates → check
  `systemctl --failed` and the journal.
- The generic debug loop: reproduce → observe (journal, dmesg, status) →
  hypothesize → test → fix → document. Write your own runbooks in this repo.
- Rescue toolbox: live ISO + `arch-chroot`, cache/ALA downgrades, reinstalling
  `archlinux-keyring` on stale systems, fallback initramfs, `rescue.target` /
  `emergency.target`.
- Security hardening basics from the wiki: minimal services, sudo policy,
  firewall on, understanding what you install (especially from the AUR).

**Lab**

- Write runbooks: "system won't boot", "pacman is broken", "no network",
  "disk full", "service fails at boot". Test each by breaking a snapshot of
  your VM and repairing it with only your runbook + the wiki.
- Simulate a months-out-of-date system (snapshot, wait or use ALA) and bring
  it current cleanly.

**Checkpoint** — you have personally caused and repaired: an unbootable
system, a broken package manager, a failed service, and a broken network.

---

## Phase 10 — Deep kernel internals *(the long game)*

Everything above makes you an advanced Arch user; this phase is for going
beneath the distro into the kernel itself. It is open-ended.

**Read / resources**

- [Kernel](https://wiki.archlinux.org/title/Kernel) wiki page's links onward
  to [kernel.org](https://www.kernel.org/) and the
  [official kernel documentation](https://docs.kernel.org/).
- *The Linux Programming Interface* (Kerrisk) for the syscall boundary.
- *Linux Kernel Development* (Love) for classic internals
  (scheduler, memory, VFS), then current docs.kernel.org for what changed.
- [Profiling](https://wiki.archlinux.org/title/Profiling) /
  [perf](https://wiki.archlinux.org/title/Perf) on the wiki.

**Topics, roughly in order**

1. Syscalls: `strace` a simple program; understand the user/kernel boundary.
2. Processes and scheduling: task states, priorities, cgroups (v2 — also how
   systemd organizes services; `systemd-cgls`, `systemd-cgtop`).
3. Memory: virtual memory, page cache, `/proc/meminfo`, OOM behaviour.
4. VFS and filesystems: mounts, namespaces, inodes, the page cache again.
5. Devices and drivers: the device model in `/sys`, bus/driver binding.
6. Tracing and observability: `dmesg`/`printk` levels, ftrace
   (`/sys/kernel/tracing`), `perf`, then eBPF tooling.
7. Kernel debugging on Arch: booting a custom kernel in QEMU with gdb.
8. Read real code: pick one tiny subsystem or driver and trace one code path
   from syscall to hardware.

**Lab ideas**

- `strace`/`ltrace` a pacman transaction; map syscalls to what you know it
  does on disk.
- Use ftrace/perf to observe what happens during boot or an I/O-heavy task.
- Extend your Phase 5 hello-world module: add a `/proc` or sysfs entry,
  a parameter, and proper logging.
- Run your custom kernel under QEMU with `-s` and attach gdb to it.

---

## Ongoing habits (from day one)

- **Read the Arch news before updating.** Non-negotiable on a rolling release.
- Keep a lab journal in this repo; write up anything that took you >30
  minutes to figure out.
- When you hit a problem, go wiki → man page → journal → upstream docs, in
  that order, before searching forums.
- Revisit [System maintenance](https://wiki.archlinux.org/title/System_maintenance)
  monthly until it is second nature.
- Contribute back: fix a wiki typo, comment on an AUR package, file a good
  bug report — the fastest way to make knowledge stick.
