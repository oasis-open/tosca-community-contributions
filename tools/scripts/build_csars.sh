#!/bin/bash
#
# Build a CSAR for each community-authored profile under
# profiles/community/tosca/. Profiles are discovered by their TOSCA.meta files
# (the authoritative CSAR entry-point marker); each CSAR filename is derived from
# the profile's advertised name+version -- the `profile:` keyword in the file
# named by that TOSCA.meta's Entry-Definitions -- so no list is kept in sync.
#
# CSARs are written to ${CSARS_DIR} (default /tmp/csars).

set -eo pipefail

HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")
ROOT=$(readlink --canonicalize "${HERE}/../..")   # tools/scripts -> repo root
CSARS_DIR="${CSARS_DIR:-/tmp/csars}"
PROFILES_ROOT="${ROOT}/profiles/community/tosca"

mkdir -p "${CSARS_DIR}"

# Package one profile directory (identified by its TOSCA.meta) as a CSAR,
# naming it from the profile keyword in the declared entry file.
build_csar() {
    local dir="$1"
    local entry name_version csar
    entry=$(awk -F': *' '/^Entry-Definitions:/{print $2; exit}' "${dir}/TOSCA.meta")
    entry="${entry:-profile.yaml}"
    name_version=$(awk '/^profile:/{print $2; exit}' "${dir}/${entry}")
    if [ -z "${name_version}" ]; then
        echo "WARNING: no 'profile:' keyword in ${dir}/${entry}; skipping" >&2
        return
    fi
    csar="${name_version/:/.}.csar"   # community.tosca.core:0.1 -> community.tosca.core.0.1.csar
    echo "Creating ${name_version}  ->  ${csar}"
    ( cd "${dir}" && zip -r "${CSARS_DIR}/${csar}" . > /dev/null )
}

# Discover profiles by their TOSCA.meta entry-point markers.
while IFS= read -r meta; do
    build_csar "$(dirname "${meta}")"
done < <(find "${PROFILES_ROOT}" -name TOSCA.meta | sort)

echo
echo "CSARs written to ${CSARS_DIR}:"
ls -1 "${CSARS_DIR}"/*.csar
