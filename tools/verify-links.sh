#!/usr/bin/env bash
# Verify every external link in the repo's Markdown files.
#
# For wiki.archlinux.org links this catches both dead pages (HTTP 404) and
# renamed pages (HTTP 301/302 redirect to a different title — MediaWiki serves
# real pages with 200 and redirects renamed ones).
#
# Usage: tools/verify-links.sh [file.md ...]   (defaults to all *.md in repo)
set -uo pipefail

cd "$(dirname "$0")/.."
files=("$@")
[ ${#files[@]} -eq 0 ] && mapfile -t files < <(find . -name '*.md' -not -path './.git/*')

mapfile -t urls < <(grep -hoE 'https?://[^) ">]+' "${files[@]}" | sed 's/[.,]$//' | sort -u)

fail=0
for url in "${urls[@]}"; do
    # -L follows redirects; url_effective reveals renames on the wiki
    read -r code final < <(curl -sS -o /dev/null -L --max-time 20 \
        -w '%{http_code} %{url_effective}\n' "$url" 2>/dev/null) || true
    case "${code:-000}" in
        200)
            if [ "$final" != "$url" ]; then
                printf 'REDIRECT %s -> %s\n' "$url" "$final"
                fail=1
            else
                printf 'OK       %s\n' "$url"
            fi
            ;;
        000) printf 'UNREACH  %s (blocked or timeout)\n' "$url"; fail=1 ;;
        *)   printf 'HTTP %-3s %s\n' "${code}" "$url"; fail=1 ;;
    esac
done
exit "$fail"
