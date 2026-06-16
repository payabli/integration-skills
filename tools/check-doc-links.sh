#!/usr/bin/env bash
#
# Validate links referenced in this repo — fast + cold-render tolerant.
#
# Default mode: every docs.payabli.com link under skills/.
#   .md API-reference/snippet pages can take 10–45s to render on a cold hit, but the HTML form
#   (same page, drop the .md) renders fast. So we probe the .md form with a SHORT timeout and,
#   on a miss, fall back to HTML. A link fails only if BOTH forms fail. docs.payabli.com returns
#   HTTP 200 even for missing pages, so a status check alone isn't enough — we also reject any
#   body containing a "Page Not Found" marker. This is the strict, fast check the per-PR
#   validator runs.
#
# --all (or SCAN_ALL=1): additionally check the outbound links in README.md, AGENTS.md,
#   CONTRIBUTING.md, SECURITY.md, and tools/ docs — including external hosts (GitHub, agent docs,
#   skills.sh, etc.) via a plain reachability probe. The monthly link-check workflow uses this;
#   it's kept OUT of the per-PR validator so a flaky third-party host can't fail an unrelated
#   skill PR.
#
# Checks run in parallel. Tunable via env: MD_TIMEOUT, HTML_TIMEOUT, RETRIES, CONCURRENCY, UA.
#
set -uo pipefail

export MD_TIMEOUT="${MD_TIMEOUT:-5}"
export HTML_TIMEOUT="${HTML_TIMEOUT:-15}"
export RETRIES="${RETRIES:-1}"
export UA="${UA:-Mozilla/5.0 (compatible; payabli-link-check/1.0)}"
CONCURRENCY="${CONCURRENCY:-16}"

SCAN_ALL="${SCAN_ALL:-0}"
[ "${1:-}" = "--all" ] && SCAN_ALL=1

if [ ! -d skills ]; then
  echo "::error::skills/ directory not found — run this from the repo root."
  exit 1
fi

# check_one <url> -> 0 if the link resolves, else 1.
# docs.payabli.com uses the .md→HTML fallback + Page-Not-Found body check; every other host
# uses a plain HTTP reachability probe (a final 2xx/3xx status counts as reachable).
check_one() {
  local url="$1" body code
  if [[ "$url" == https://docs.payabli.com* ]]; then
    # .md pages can cold-render slowly: probe the .md form with the SHORT timeout, then on a
    # miss fall through to the HTML form (drop .md) with the longer timeout. Non-.md docs pages
    # skip the probe and get the longer timeout directly.
    if [[ "$url" == *.md ]]; then
      if body=$(curl -fsSL -A "$UA" --max-time "$MD_TIMEOUT" --retry "$RETRIES" --retry-delay 1 "$url" 2>/dev/null) \
           && [ -n "$body" ] && ! grep -qiE 'page not found' <<<"$body"; then
        return 0
      fi
      url="${url%.md}"
    fi
    if body=$(curl -fsSL -A "$UA" --max-time "$HTML_TIMEOUT" --retry "$RETRIES" --retry-delay 1 "$url" 2>/dev/null) \
         && [ -n "$body" ] && ! grep -qiE 'page not found' <<<"$body"; then
      return 0
    fi
    return 1
  fi
  code=$(curl -sL -A "$UA" -o /dev/null -w '%{http_code}' \
              --max-time "$HTML_TIMEOUT" --retry "$RETRIES" --retry-delay 1 "$url" 2>/dev/null)
  [[ "$code" =~ ^[23] ]]
}
export -f check_one

# URLs that are example values, not browsable pages — the API base URLs appear in the
# README's .env snippet and won't resolve to HTML. Never link-checked.
SKIP_RE='^https?://(api-sandbox|api)\.payabli\.com'

# Strip trailing markdown punctuation, drop template placeholders and skip-list URLs, dedupe.
clean() { sed -E 's/[).,;]+$//' | grep -v '[{}]' | grep -vE "$SKIP_RE" | sort -u; }

# docs.payabli.com links under skills/ — always checked.
payabli_urls() {
  grep -rhoE 'https://docs\.payabli\.com[^[:space:])"`>]+' skills/ | clean
}

# all outbound http(s) links in the top-level docs we maintain — checked only in --all mode.
doc_urls() {
  grep -rhoE 'https?://[^[:space:])"`>]+' \
    README.md AGENTS.md CONTRIBUTING.md SECURITY.md tools/repo-freshness-check.md 2>/dev/null | clean
}

if [ "$SCAN_ALL" = 1 ]; then
  all_urls=$( { payabli_urls; doc_urls; } | sort -u )
else
  all_urls=$(payabli_urls)
fi

total=$(printf '%s\n' "$all_urls" | grep -c . || true)
if [ "$total" -eq 0 ]; then
  echo "::error::No links found — link extraction is likely broken."
  exit 1
fi

# Each worker prints the URL only if it fails.
broken=$(printf '%s\n' "$all_urls" | xargs -P "$CONCURRENCY" -I{} bash -c 'check_one "$1" || echo "$1"' _ {})

scope=$( [ "$SCAN_ALL" = 1 ] && echo "link(s) (incl. external)" || echo "docs.payabli.com link(s)" )
echo "Checked ${total} ${scope}."
if [ -n "$broken" ]; then
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    if [[ "$u" == *.md ]]; then detail="failed as both .md and HTML"; else detail="unreachable"; fi
    # Escape workflow-command data (%, CR, LF) to avoid log-command injection.
    safe=${u//%/%25}; safe=${safe//$'\r'/%0D}; safe=${safe//$'\n'/%0A}
    echo "::error title=Broken link::${safe} (${detail})"
  done <<<"$broken"
  echo "Broken:"; echo "$broken"
  exit 1
fi
echo "All links OK."
