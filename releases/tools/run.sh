#!/bin/bash

_spec_file="$1"
_spec_file_template="${_spec_file}".template
_spec_file_env="${_spec_file}".env

_debug="$2"

[[ -n "${_debug}" ]] && _DEBUGP="echo"

_usage()
{
	echo "usage: $(basename "$0") <file.spec>"
}

[[ $# -lt 1 ]] && { _usage; exit 1; }

_ensure_log()
{
	local log_file=$(realpath -m "$1")
	local log_dir=$(dirname "$log_file")
	[[ -d "$log_dir" ]] || ${_DEBUGP} mkdir -p "$log_dir"
	[[ -f "$log_file" ]] || ${_DEBUGP} touch "$log_file"
}

_ensure_source_subpath()
{
	local spec_file="$1"
	local repo_root="$2"
	local source_subpath=$(cat "${spec_file}" | grep '^source_subpath: ' | sed -e 's/source_subpath: //')
	local source_subpath_latest=$(ls "${repo_root:-.}"/var/tmp/catalyst/builds/${source_subpath/-latest/*} | grep -v '\-latest' | sort -r | head -1)
	[[ -n "${source_subpath_latest}" ]] && ln -fs -T "${source_subpath_latest}" "${repo_root:-.}"/var/tmp/catalyst/builds/"${source_subpath}"
}

_ensure_snapshot()
{
	local repo_root="$1"
	local snapshot_latest=$(ls "${repo_root:-.}"/var/tmp/catalyst/snapshots/*.xz.sqfs | grep -v 'latest.xz.sqfs' | sort -r | head -1)
	[[ -n "${snapshot_latest}" ]] && ln -fs -T "${snapshot_latest}" "${repo_root:-.}"/var/tmp/catalyst/snapshots/gentoo-latest.xz.sqfs
}

_ensure_portdir()
{
    	local repo_root="$1"
	local portage_confdir="$2"
	cp -r "${repo_root}"/etc/portage/default/* "${portage_confdir}"/
}

_get_repo_root()
{
	local spec_file_env=$1
	env -i bash -c '{ source "'${spec_file_env}'"; echo "${REPO_ROOT}"; }'
}

_get_catalyst_conf()
{
	local spec_file_env=$1
	env -i bash -c '{ source "'${spec_file_env}'"; echo "${CATALYST_CONF}"; }'
}

_get_catalyst_log()
{
	local spec_file_env=$1
	env -i bash -c '{ source "'${spec_file_env}'"; echo "${CATALYST_LOG}"; }'
}

_get_portage_confdir()
{
	local spec_file_env=$1
	env -i bash -c '{ source "'${spec_file_env}'"; echo "${PORTAGE_CONFDIR}"; }'
}

_repo_root=$(_get_repo_root "${_spec_file_env}")
_catalyst_conf=$(_get_catalyst_conf "${_spec_file_env}")
_catalyst_log=$(_get_catalyst_log "${_spec_file_env}")
_portage_confdir=$(_get_portage_confdir "${_spec_file_env}")

if [[ -f "${_spec_file_template}" ]] && [[ -f "${_spec_file_env}" ]]; then
	cat "${_spec_file_template}" |
		env -i bash -c '{ source "'${_spec_file_env}'"; envsubst; }' \
	> "${_spec_file}"
fi

if [[ -f "${_spec_file}" ]] && \
   [[ -n "${_repo_root}" ]]; then
	_ensure_source_subpath "${_spec_file}" "${_repo_root}"
	_ensure_snapshot "${_repo_root}"
fi

if [[ -n "${_portage_confdir}" ]] && \
   [[ -n "${_repo_root}" ]]; then
	_ensure_portdir "${_repo_root}" "${_portage_confdir}"
fi

if [[ -f "${_spec_file}" ]] && \
   [[ -n "${_catalyst_conf}" ]] && \
   [[ -n "${_catalyst_log}" ]]; then
   	_ensure_log "${_catalyst_log}"
	${_DEBUGP} catalyst -a -d -c "${_catalyst_conf}" --log-file "${_catalyst_log}" -f "${_spec_file}" &> "${_catalyst_log%.log}.err"
fi
