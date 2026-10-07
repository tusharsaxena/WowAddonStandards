#!/usr/bin/env bash
# =============================================================================
# check-standard.sh — the mechanical gate for this repo's own invariants.
#
# Run it on demand, and from /dev-copilot:sync-docs, before committing a change
# to the standard. It is deliberately NOT a commit hook: a threshold on every
# commit gets routed around with --no-verify (CLAUDE.md, "The two checkpoints").
#
# Every check below is mechanically decidable. None of them reads meaning: a
# contradiction between two section files, or a citation that is in range but
# points at the wrong section, is still a human's or an agent's to find.
#
#   cr-bytes        no tracked file carries a CR byte (line-endings-§2)
#   gitattributes   .gitattributes is line-endings-§5's non-client LF body
#   citations       every filename-§N names a real section file and an existing
#                   "### N." heading; an unnumbered file takes no -§N at all;
#                   a -§ not followed by a number is malformed (documentation-§6)
#   sections        STANDARDS.md "## Sections" links == the tracked section files
#   anti-patterns   anti-patterns.md is numbered 1..N and the index says (#1–#N)
#   version-stamps  the STANDARDS.md title version (and date) is restated in
#                   README.md Status, EXECUTIVE_SUMMARY.md, NEW_ADDON_CONTEXT.md
#                   line 1 and CLAUDE.md's "As of" line
#   links           every relative .md link in a live doc resolves
#
# Frozen stores (harvests/, standards/_raw/, docs/audits/, docs/reviews/) and
# the changelog history (standards/CHANGELOG.md) are history: their citations
# and links were right when written, so checks 3 and 7 skip them.
#
# Usage:  bash scripts/check-standard.sh      (from anywhere inside the repo)
# Exit:   0 when every check passes, 1 when any fails. Each failure is printed
#         as "FAIL <check>: <detail>".
# Needs:  bash, git, coreutils, GNU grep, awk, diff (see DEPENDENCIES.md).
# =============================================================================
set -u
export LC_ALL=C

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "FAIL setup: not inside a git work tree" >&2
  exit 1
}
cd "$root" || exit 1

SECT=standards/standards
INDEX=standards/STANDARDS.md
FROZEN='^(harvests/|standards/_raw/|docs/audits/|docs/reviews/|standards/CHANGELOG\.md$)'
failed=0

fail() { # fail <check> <detail>
  echo "FAIL $1: $2"
  failed=1
}

pass() { # pass <check> <summary>
  echo "ok   $1: $2"
}

live_docs() { # tracked .md files outside the frozen stores
  git ls-files -- '*.md' | grep -Ev "$FROZEN"
}

# --- 1. cr-bytes --------------------------------------------------------------
check_cr_bytes() {
  local hits
  hits=$(git grep -Il $'\r' -- . 2>/dev/null)
  if [ -n "$hits" ]; then
    while IFS= read -r f; do fail cr-bytes "$f carries a CR byte"; done <<< "$hits"
  else
    pass cr-bytes "no tracked file carries a CR"
  fi
}

# --- 2. gitattributes ---------------------------------------------------------
# The LF body is the SECOND column-0 ```gitattributes fence in line-endings.md
# (the first is the client-bound CRLF body).
check_gitattributes() {
  local body d
  body=$(awk '/^```gitattributes$/ { n++; if (n == 2) { on = 1; next } }
              on && /^```$/ { exit }
              on' "$SECT/line-endings.md")
  if [ -z "$body" ]; then
    fail gitattributes "no second \`\`\`gitattributes fence in $SECT/line-endings.md"
    return
  fi
  if d=$(diff <(printf '%s\n' "$body") .gitattributes); then
    pass gitattributes ".gitattributes matches line-endings-§5's LF body"
  else
    fail gitattributes ".gitattributes differs from line-endings-§5's LF body:"
    printf '%s\n' "$d" | sed 's/^/       /' | head -20
  fi
}

# --- 3. citations -------------------------------------------------------------
# Placeholders the standard uses to TEACH the scheme are not citations. Each
# entry is "<path>|<token>" (path "*" = any file), token as grep -o prints it.
MALFORMED_OK=(
  '*|filename-§N'
  '*|<filename>-§<'
  "$SECT/documentation.md|-§\`"
  "$SECT/documentation.md|slash-commands-§:"
)

check_citations() {
  local headings cites bad tok f ok e n=0
  # "<file> <N>" for every numbered heading in a section file, plus "<file> -"
  # once per file so an unnumbered file is still known to exist
  headings=$(git ls-files -- "$SECT/*.md" | while IFS= read -r p; do
    awk -v f="$(basename "$p" .md)" \
      'BEGIN { print f, "-" }
       match($0, /^### [0-9]+\./) { print f, substr($0, 5, RLENGTH - 5) }' "$p"
  done)

  # Well-formed citations: "path:line:file N" for f-§N plus each /§M, –§M, -§M
  cites=$(live_docs | xargs grep -HnoE '[A-Za-z0-9_-]+-§[0-9]+((/|–|-)§[0-9]+)*' \
    | awk -F: '{
        tok = $3; split(tok, parts, "§"); file = parts[1]; sub(/-$/, "", file)
        for (i = 2; i in parts; i++) { num = parts[i]; sub(/[^0-9].*$/, "", num)
          print $1 ":" $2 ":" file " " num }
      }')
  bad=$(awk -v S="$SECT" '
        NR == FNR { if ($2 == "-") exists[$1] = 1; else { numbered[$1] = 1; ok[$0] = 1 }; next }
        { split($0, loc, ":"); split(loc[3], fn, " ")
          if (loc[3] in ok) next
          if (!(fn[1] in exists)) why = "names no file under " S "/"
          else if (!(fn[1] in numbered)) why = "cites an unnumbered file (cite it by bare filename)"
          else why = "has no ### " fn[2] ". heading in " S "/" fn[1] ".md"
          print loc[1] ":" loc[2] ": " fn[1] "-§" fn[2] " " why
        }' <(printf '%s\n' "$headings") <(printf '%s\n' "$cites"))
  if [ -n "$bad" ]; then
    while IFS= read -r line; do fail citations "$line"; n=$((n + 1)); done <<< "$bad"
  fi

  # Malformed: a -§ not followed by a section number
  while IFS= read -r hit; do
    [ -z "$hit" ] && continue
    f=${hit%%:*}; tok=${hit#*:*:}
    ok=0
    for e in "${MALFORMED_OK[@]}"; do
      if [ "$e" = "*|$tok" ] || [ "$e" = "$f|$tok" ]; then ok=1; break; fi
    done
    [ "$ok" -eq 1 ] && continue
    fail citations "${hit%:*}: malformed citation '$tok' (expected filename-§N)"
    n=$((n + 1))
  done <<< "$(live_docs | xargs grep -HnoE '[A-Za-z0-9_<>-]*-§([^0-9]|$)')"

  [ "$n" -eq 0 ] && pass citations "$(wc -l <<< "$cites" | tr -d ' ') filename-§N citations resolve"
}

# --- 4. sections --------------------------------------------------------------
check_sections() {
  local listed tracked d
  listed=$(awk '/^## Sections$/ { on = 1; next } on && /^## / { exit } on' "$INDEX" \
    | grep -oE '\]\(standards/[^)#]+\.md\)' | sed -E 's/^\]\(//; s/\)$//' | sort)
  tracked=$(git ls-files -- "$SECT/*.md" | sed 's|^standards/||' | sort)
  if d=$(diff <(printf '%s\n' "$listed") <(printf '%s\n' "$tracked")); then
    pass sections "$(wc -l <<< "$tracked" | tr -d ' ') section files, all listed"
  else
    printf '%s\n' "$d" | grep -E '^[<>]' | while IFS= read -r l; do
      case $l in
        '<'*) echo "FAIL sections: listed in $INDEX but not tracked: ${l#< }" ;;
        '>'*) echo "FAIL sections: tracked but missing from $INDEX ## Sections: ${l#> }" ;;
      esac
    done
    failed=1
  fi
}

# --- 5. anti-patterns ---------------------------------------------------------
check_anti_patterns() {
  local gaps last blurb
  gaps=$(awk '/^[0-9]+\. / { n = $1 + 0; want++
                 if (n != want) { print "entry " want " is numbered " n; want = n } }
              END { print "LAST " want }' "$SECT/anti-patterns.md")
  last=$(sed -n 's/^LAST //p' <<< "$gaps")
  gaps=$(grep -v '^LAST ' <<< "$gaps")
  if [ -n "$gaps" ]; then
    while IFS= read -r g; do fail anti-patterns "$SECT/anti-patterns.md: $g"; done <<< "$gaps"
  fi
  blurb=$(awk '/^## Sections$/ { on = 1; next } on && /^## / { exit } on' "$INDEX" \
    | grep -E '\]\(standards/anti-patterns\.md\)' | grep -oE '\(#1–#[0-9]+\)')
  if [ "$blurb" != "(#1–#$last)" ]; then
    fail anti-patterns "$INDEX blurb says '${blurb:-nothing}', the file runs #1–#$last"
  elif [ -z "$gaps" ]; then
    pass anti-patterns "#1–#$last contiguous, index agrees"
  fi
}

# --- 6. version-stamps --------------------------------------------------------
check_version_stamps() {
  local title ver date n=0
  title=$(head -1 "$INDEX")
  ver=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' <<< "$title" | head -1)
  date=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' <<< "$title" | head -1)
  if [ -z "$ver" ] || [ -z "$date" ]; then
    fail version-stamps "$INDEX line 1 carries no (vX.Y.Z, YYYY-MM-DD) stamp"
    return
  fi
  stamp() { # stamp <label> <text> <needle...>
    local label=$1 text=$2; shift 2
    for needle in "$@"; do
      if ! grep -qF -- "$needle" <<< "$text"; then
        fail version-stamps "$label does not say $needle ($INDEX is $ver, $date)"
        n=$((n + 1))
      fi
    done
  }
  stamp "README.md ## Status" \
    "$(awk '/^## Status$/ { on = 1; next } on && /^## / { exit } on' README.md)" "**$ver**"
  stamp "standards/EXECUTIVE_SUMMARY.md" \
    "$(grep -E 'current: ' standards/EXECUTIVE_SUMMARY.md)" "**$ver**, $date"
  stamp "standards/NEW_ADDON_CONTEXT.md line 1" \
    "$(head -1 standards/NEW_ADDON_CONTEXT.md)" "($ver, $date)"
  stamp "CLAUDE.md 'As of' line" "$(grep -E 'As of v' CLAUDE.md)" "As of $ver"
  [ "$n" -eq 0 ] && pass version-stamps "$ver, $date restated in all four places"
}

# --- 7. links -----------------------------------------------------------------
# Relative links to a .md file, outside fenced code blocks, must resolve.
# standards/ADDONS.md is excluded: its paths name sibling repos, not this one.
check_links() {
  local bad total
  bad=$(live_docs | grep -vx 'standards/ADDONS.md' | while IFS= read -r f; do
    awk -v F="$f" '
      /^[ \t]*```/ { fence = !fence; next }
      fence { next }
      { s = $0
        while (match(s, /\]\([^) \t]+\)/)) {
          t = substr(s, RSTART + 2, RLENGTH - 3); s = substr(s, RSTART + RLENGTH)
          if (t ~ /^[a-z]+:/ || t ~ /^#/ || t ~ /^</) continue
          sub(/#.*$/, "", t)
          if (t ~ /\.md$/) print F ":" NR ":" t
        } }' "$f"
  done | while IFS=: read -r f l t; do
    case $t in /*) p=".$t" ;; *) p="$(dirname "$f")/$t" ;; esac
    [ -e "$p" ] || echo "$f:$l: link target '$t' does not exist"
  done)
  if [ -n "$bad" ]; then
    while IFS= read -r line; do fail links "$line"; done <<< "$bad"
  else
    total=$(live_docs | wc -l | tr -d ' ')
    pass links "relative .md links resolve across $total live docs"
  fi
}

check_cr_bytes
check_gitattributes
check_citations
check_sections
check_anti_patterns
check_version_stamps
check_links

if [ "$failed" -ne 0 ]; then
  echo "check-standard: FAILED"
  exit 1
fi
echo "check-standard: all checks passed"
exit 0
