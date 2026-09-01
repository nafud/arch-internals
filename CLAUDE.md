# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repository is

A personal learning playground for **Arch Linux internals**, owned by a
learner starting from zero Arch knowledge and working toward deep
understanding of the distribution and the Linux kernel. It contains no
application code — only documentation, notes, lab artifacts, and repair
runbooks. The curriculum is **`ROADMAP.md`** (phases 0–10); everything else
in the repo is produced by working through it. Polished write-ups are
periodically promoted out of this repo into the owner's Kiln knowledgebase,
so notes here should be written well enough to graduate.

## Layout

```
ROADMAP.md          The learning plan — the spine of the repo. Phases 0–10,
                    each with wiki reading, concepts, labs, and a checkpoint.
README.md           Repo overview and conventions.
notes/NN-<topic>/   Per-phase study notes and lab journals
                    (01-installation … 08-graphics, numbered to match the
                    roadmap's phase order for phases 1–8).
labs/               Experiment artifacts: PKGBUILDs, systemd units, udev
                    rules, kernel-module hello-worlds, VM definitions.
runbooks/           Tested, step-by-step repair procedures (won't-boot,
                    broken-pacman, no-network, disk-full, failed-service).
configs/            Reference copies of interesting /etc configs from VMs.
tools/              Repo utilities. verify-links.sh checks every Markdown
                    link and flags wiki renames (redirects) — run it whenever
                    egress to wiki.archlinux.org is available.
```

Directories currently hold `.gitkeep` placeholders; they fill up as the owner
progresses.

## Sourcing and accuracy rules (important)

1. **The Arch Wiki (https://wiki.archlinux.org/) is the primary source** for
   any Arch-related content written here. Cite the specific wiki page(s) in
   every note, guide, or runbook you author or edit.
2. Arch is a rolling release and the wiki is a moving target. **When network
   access allows, verify claims and page titles against the live wiki before
   committing.** If the environment's egress policy blocks
   wiki.archlinux.org (as it did during this repo's initial setup), say so
   explicitly in your output and mark the affected content as unverified
   rather than presenting it as confirmed.
3. Never write instructions that violate Arch's own support boundaries:
   - No partial upgrades (`pacman -Sy <pkg>` without `-u` must never appear
     in a guide except as an anti-example).
   - AUR content is unsupported user content; guides must say to read
     PKGBUILDs before building.
   - Don't recommend AUR helpers as a substitute for understanding the
     manual `makepkg` flow.
4. Prefer current tooling names: `pkgctl repo clone` (devtools) rather than
   the deprecated `asp`; repos are `core`/`extra`/`multilib` (+
   `core-testing`/`extra-testing`) — the old `community` repo merged into
   `extra` in 2023.
5. Kernel-related content should distinguish the two build paths the wiki
   documents: Kernel/Arch build system and Kernel/Traditional compilation.

## Content conventions

- **Notes** (`notes/`): Markdown, one file per topic or lab session. Start
  each file with the date, the roadmap phase, and the wiki pages used.
  Explain *why* a step exists, not just what to type — that's the entire
  point of this repo.
- **Labs** (`labs/`): keep artifacts runnable/reproducible. A lab is complete
  only when the roadmap phase's break-and-repair exercise is done and
  documented.
- **Runbooks** (`runbooks/`): imperative, numbered steps, written to be
  usable under stress from a live ISO. Each must state its "tested on" date
  and the failure it was validated against.
- All commands shown for the learner's machines assume **a VM, not physical
  hardware**, unless a note says otherwise.
- **Never commit secrets, private keys, or LUKS headers/keyfiles**, even
  from throwaway VMs. `configs/` gets sanitized copies only.

## Working style for Claude in this repo

- The owner is *learning*: when asked to explain or write guides, favor
  mechanism and first principles over recipes, and link the wiki page that
  teaches each concept.
- When asked to review or extend `ROADMAP.md`, preserve its structure
  (Read / Understand / Lab / Checkpoint per phase) and its ordering
  rationale: install → pacman → boot → systemd → kernel → storage → network
  → graphics → maintenance → kernel deep-dive.
- Factual changes to the roadmap or runbooks should be verified against the
  Arch Wiki (rule 2 above) — for substantial revisions, a background
  verification agent pass before committing is the established practice
  here.
- There is no build, test suite, or CI in this repo. "Testing" a change
  means checking links resolve and facts match the wiki. Markdown should
  render cleanly on GitHub.
- Git: develop on the designated feature branch, clear descriptive commit
  messages, no force-pushes to shared history.

## Repo history note

Initial roadmap (2026-09-01) was fact-checked by a verification agent using
model knowledge only, because the sandbox's egress policy blocked
wiki.archlinux.org, archlinux.org, and kernel.org. All wiki page titles and
technical claims matched knowledge current to early 2026; a live-wiki
re-verification of `ROADMAP.md`'s links is a worthwhile first task from an
environment with network access to the wiki.
