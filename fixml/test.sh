#!/bin/bash

# Simple unified test script for all FIXML implementations
# Usage: ./test.sh [quick|comprehensive|specific] [go|rust|lua|ocaml|zig|all]

MODE=${1:-quick}
LANG=${2:-all}

# Language commands
run_go() { ./go/fixml "$@"; }
run_rust() { ./rust/fixml "$@"; }
run_ocaml() { ./ocaml/fixml "$@"; }
run_zig() { ./zig/fixml "$@"; }
run_lua() { lua lua/fixml.lua "$@"; }

# Test a single file with a language
test_file() {
    local lang=$1 file=$2 mode=$3
    run_$lang $mode "$file" >/dev/null 2>&1 && \
    ./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" >/dev/null 2>&1
}

# Get test files based on mode
case $MODE in
    comprehensive) FILES=(tests/samples/originals/*.csproj); MODES=("" "--organize" "--fix-warnings" "--organize --fix-warnings") ;;
    specific) FILES=(tests/samples/*.csproj); MODES=("" "--organize" "--fix-warnings" "--organize --fix-warnings") ;;
    *) FILES=(tests/samples/*.csproj); MODES=("" "--organize" "--fix-warnings" "--organize --fix-warnings") ;;
esac

# Filter out organized files
TESTFILES=()
for f in "${FILES[@]}"; do
    [[ -f "$f" && "$f" != *".organized."* ]] && TESTFILES+=("$f")
done

# Set languages to test
case $LANG in
    all) LANGS=(go rust lua ocaml zig) ;;
    *) LANGS=($LANG) ;;
esac

echo "=== FIXML Test ($MODE mode) ==="
echo "Files: ${#TESTFILES[@]}, Languages: ${LANGS[*]}"
echo

TOTAL=0 PASSED=0

for lang in "${LANGS[@]}"; do
    # Check if executable exists
    case $lang in
        go) [[ ! -x ./go/fixml ]] && echo "$lang: executable not found" && continue ;;
        rust) [[ ! -x ./rust/fixml ]] && echo "$lang: executable not found" && continue ;;
        ocaml) [[ ! -x ./ocaml/fixml ]] && echo "$lang: executable not found" && continue ;;
        zig) [[ ! -x ./zig/fixml ]] && echo "$lang: executable not found" && continue ;;
        lua) { ! command -v lua >/dev/null || [[ ! -f lua/fixml.lua ]]; } && echo "$lang: not available" && continue ;;
    esac
    
    lang_passed=0 lang_total=0
    
    for mode in "${MODES[@]}"; do
        mode_passed=0
        for file in "${TESTFILES[@]}"; do
            lang_total=$((lang_total + 1))
            TOTAL=$((TOTAL + 1))
            if test_file $lang "$file" "$mode"; then
                mode_passed=$((mode_passed + 1))
                lang_passed=$((lang_passed + 1))
                PASSED=$((PASSED + 1))
            fi
        done
        [[ ${#MODES[@]} -gt 1 ]] && echo "  $lang ${mode:-default}: $mode_passed/${#TESTFILES[@]}"
    done
    
    echo "$lang: $lang_passed/$lang_total"
done

echo
echo "Total: $PASSED/$TOTAL ($(( PASSED * 100 / TOTAL ))%)"
[[ $PASSED -eq $TOTAL ]]