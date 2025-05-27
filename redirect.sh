#!/bin/bash
set -e
set -u

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${SCRIPT_DIR}/docs"

TOPURL="https://escomp.github.io/CTSM"

for f in $(find * -name "*.html"); do

    # Special handling for "master" branch
    if [[ "${f}" == *"versions/master/html/"* ]]; then
        relpath="$(echo $f | sed "s@versions/master/html/@@")"
    elif [[ "${f}" == *"versions/release-clm5.0/html/"* ]]; then
        relpath="$(echo $f | sed "s@versions/release-clm5.0/html/@release-clm5.0/@")"
    elif [[ "${f}" == *"versions/"* ]]; then
        echo $f >&2
        exit 1
    else
        relpath="${f}"
    fi

    # Check whether target page exists
    target_page="${TOPURL}/${relpath}"
    set +e
    returncode=$(curl -s -o /dev/null -w "%{http_code}" "${target_page}")
    set -e

    if [[ ${returncode} -ne 200 ]]; then
        fail=0
        
        original_target_page="${target_page}"
        echo "original_target_page: ${original_target_page}"
        relpath="$(dirname "${relpath}")/index.html"
        target_page="${TOPURL}/${relpath}"

        while [[ $(curl -s -o /dev/null -w "%{http_code}" "${target_page}") -ne 200 ]]; do
            relpath="$(dirname $(dirname "${relpath}"))/index.html"
            target_page="${TOPURL}/${relpath}"
            if [[ "${relpath}" == "versions/index.html" ]]; then
                echo "Failed to find best equivalent of ${original_target_page}" >&2
                fail=1
                break
            fi
        done
        if [[ ${fail} -ne 0 ]]; then
            break
        fi
        sed "s@RELPATH@$relpath@g" ../redirect_template.html | sed "s/This page has moved to/The CTSM documentation has moved. The closest equivalent of this page is at/g" > $f
    else
        sed "s@RELPATH@$relpath@g" ../redirect_template.html > $f
    fi
done

exit 0