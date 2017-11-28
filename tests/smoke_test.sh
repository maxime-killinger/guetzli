#!/bin/bash

GUETZLI=${1:-bin/Release/guetzli}
BEES_PNG=$(dirname $0)/bees.png
BEES_JPG=$(dirname $0)/bees.jpg
BUTTERAUGLI=$2

pngtopnm < $BEES_PNG | cjpeg -sample 1x1 -quality 100 > $BEES_JPG || exit 2

function run_test() {
  # png/jpeg stdin/file stdout/file flags...
  local in=
  local out=$(dirname $0)/bees.compressed.jpg
  echo "Testing $@, output in $out"
  case "$1" in
    png) in=$BEES_PNG ;;
    jpeg) in=$BEES_JPG ;;
    *) exit 2 ;;
  esac
  shift
  local inouthandling="$1:$2"
  shift; shift
  case "$inouthandling" in
    file:file) $GUETZLI $@ $in ;;
    *) exit 2 ;;
  esac
  test -f "$out" || { echo "$out doesn't exist"; exit 1; }
  djpeg < $out > /dev/null || { echo "$out is not a valid JPEG"; exit 1; }
  if [ -n "$BUTTERAUGLI" ]; then
    $BUTTERAUGLI $in
  fi
  rm $out
  echo "OK"
}

run_test png file file
run_test jpeg file file


run_test png file file --verbose
run_test png file file --nomemlimit
run_test png file file --memlimit 100
run_test png file file --quality 85

echo $GUETZLI /dev/null /dev/null
$GUETZLI /dev/null /dev/null
if [[ $? -ne 1 ]]; then
  echo "Expected a clean failure"
  exit 1
fi

