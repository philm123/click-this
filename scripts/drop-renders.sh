#!/bin/bash
# Renders the Drop look offscreen with --png: every colorway, every shape and style, a classic
# twin for comparison, and three cue cards. Nothing is drawn on the screen.
# Usage: scripts/drop-renders.sh <bigarrow-binary> <out-dir>
set -u
BIN=$1
OUT=$2
mkdir -p "$OUT"
fail=0
run() { "$@" > /dev/null 2>> "$OUT/errors.txt" || { echo "FAILED: $*" >> "$OUT/errors.txt"; fail=1; }; }
point() { run "$BIN" point --look drop "$@"; }

for c in acid flare cobalt ink cement gum; do
  point --at 760,460 --color "$c" --from right --text "Click. This." --png "$OUT/colorway-$c.png"
done
for s in bend straight zigzag spiral; do
  point --at 760,460 --shape "$s" --from top-left --color flare --text "Not this one. That one." --png "$OUT/shape-$s.png"
done
point --at 760,460 --style ring --color cobalt --text "Flip it." --png "$OUT/style-ring.png"
point --rect 700,430,120,60 --style box --color acid --text "Type it here" --png "$OUT/style-box.png"
point --at 760,460 --size L --from bottom-left --text "Read this first" --png "$OUT/size-L.png"
point --at 760,460 --from top --close-button --color gum --text "Copy the PIN {{482913}}" --png "$OUT/copy-close.png"
run "$BIN" point --at 760,460 --from right --text "Click. This." --png "$OUT/classic-twin.png"
for card in 01-login 09-choice 11-checklist; do
  run "$BIN" card "docs/cards/$card.json" --look drop --png "$OUT/card-$card.png"
done
# Promo shots: --json records each PNG's top-left in global points, so a video can put the target
# exactly where its mock UI has it.
P="$OUT/promo"; mkdir -p "$P"
shot() { name=$1; shift; "$BIN" point --look drop --json "$@" --png "$P/$name.png" > "$P/$name.json" 2>> "$OUT/errors.txt" || fail=1; }
shot s1-menu --at 600,400 --from bottom-right --text "1. Menu. Top left."
shot s2-flyout --at 600,400 --from bottom-right --color flare --text "2. IAM & Admin. Service accounts."
shot s3-row --at 900,400 --from bottom-left --shape zigzag --color cobalt --text "3. Your bot. Not default."
shot s4-tab --at 900,400 --from bottom-left --text "4. Keys tab. Third one over."
shot s5-create --rect 600,400,300,56 --style box --from bottom-left --color flare --text "5. Add key. Create new."
run "$BIN" card scripts/promo/card.json --png "$P/d-card.png"
exit $fail
