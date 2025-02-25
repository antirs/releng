#!/bin/bash

_spec_file_template="$1"

_spec_file="${_spec_file_template%.template}"
_spec_file_env="${_spec_file}".env
_spec_file="${_spec_file##*/}"

_timestamp="$(date '+%Y%m%dT%H%M%SZ')"

_debug="$2"

[[ -n "${_debug}" ]] && _DEBUGP="echo"

_usage()
{
	echo "usage: $(basename "$0") <spec.template> [debug]"
}

[[ $# -lt 1 ]] && { _usage; exit 1; }

_ensure_log()
{
	local log_file
	local log_dir
	log_file=$(realpath -m "$1")
	log_dir=$(dirname "$log_file")

	[[ -d "$log_dir" ]] || ${_DEBUGP} mkdir -p "$log_dir"
	[[ -f "$log_file" ]] || ${_DEBUGP} touch "$log_file"
}

_ensure_source_subpath()
{
	local spec_file="$1"
	local repo_root="$2"
	local source_subpath
	local source_subpath_latest
	source_subpath=$(cat "${spec_file}" | grep '^source_subpath: ' | sed -e 's/source_subpath: //')
	source_subpath_latest=$(ls "${repo_root:-.}"/var/tmp/catalyst/builds/${source_subpath/-latest/*} | grep -v '\-latest' | sort -r | head -1)
	[[ -n "${source_subpath_latest}" ]] && ln -fs -T "${source_subpath_latest}" "${repo_root:-.}"/var/tmp/catalyst/builds/"${source_subpath}"
}

_ensure_snapshot()
{
	local repo_root="$1"
	local snapshot_latest
	snapshot_latest=$(ls "${repo_root:-.}"/var/tmp/catalyst/snapshots/*.xz.sqfs | grep -v 'latest.xz.sqfs' | sort -r | head -1)
	[[ -n "${snapshot_latest}" ]] && ln -fs -T "${snapshot_latest}" "${repo_root:-.}"/var/tmp/catalyst/snapshots/gentoo-latest.xz.sqfs
}

_ensure_portdir()
{
    	local repo_root="$1"
	local portage_confdir="$2"
	cp -r "${repo_root}"/etc/portage/default/* "${portage_confdir}"/
}

_ensure_confdir()
{
	local catalyst_conf_dir="$1"
	mkdir -p "${catalyst_conf_dir}"
}

_get_spec_file_variable()
{
    local spec_file_env=$1
    local spec_file_variable=$2
    env -i TIMESTAMP="${_timestamp}" bash -c '{ source "'"${spec_file_env}"'"; echo "${'"${spec_file_variable}"'}"; }'
}

_repo_root=$(_get_spec_file_variable "${_spec_file_env}" REPO_ROOT)
_catalyst_conf_template=$(_get_spec_file_variable "${_spec_file_env}" CATALYST_CONF_TEMPLATE)
_catalyst_conf_dir=$(_get_spec_file_variable "${_spec_file_env}" CATALYST_CONF_DIR)
_catalyst_log=$(_get_spec_file_variable "${_spec_file_env}" CATALYST_LOG)
_portage_confdir=$(_get_spec_file_variable "${_spec_file_env}" PORTAGE_CONFDIR)
_makeopts=$(_get_spec_file_variable "${_spec_file_env}" MAKEOPTS)
_distcc_hosts=$(_get_spec_file_variable "${_spec_file_env}" DISTCC_HOSTS)
_gentoobinhost=$(_get_spec_file_variable "${_spec_file_env}" GENTOOBINHOST)
_features=$(_get_spec_file_variable "${_spec_file_env}" FEATURES)

_catalyst_conf_template_file="${_catalyst_conf_template##*/}"
_catalyst_conf="${_catalyst_conf_dir}"/"${_catalyst_conf_template_file%.template}"

if [[ -f "${_catalyst_conf_template}" ]] && [[ -f "${_spec_file_env}" ]] && \
   [[ -n "${_catalyst_conf_dir}" ]]; then
    	_ensure_confdir "${_catalyst_conf_dir}"
	cat "${_catalyst_conf_template}" |
		env -i TIMESTAMP="${_timestamp}" bash -c '{ source "'"${_spec_file_env}"'"; envsubst; }' \
	> "${_catalyst_conf}"
fi

if [[ -d "${_catalyst_conf_dir}" ]]; then
   if [[ -n "${_makeopts}" ]] && [[ -n "${_distcc_hosts}" ]]; then
       echo "export MAKEOPTS='${_makeopts}'" \
	    > "${_catalyst_conf_dir}"/catalystrc
       echo "export DISTCC_HOSTS='${_distcc_hosts}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
   if [[ -n "${_features}" ]]; then
       echo "export FEATURES='${_features}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
fi

if [[ -f "${_spec_file_template}" ]] && [[ -f "${_spec_file_env}" ]] && \
   [[ -d "${_catalyst_conf_dir}" ]]; then
	cat "${_spec_file_template}" |
		env -i TIMESTAMP="${_timestamp}" bash -c '{ source "'"${_spec_file_env}"'"; envsubst; }' \
	> "${_catalyst_conf_dir}"/"${_spec_file}"
fi

if [[ -f "${_catalyst_conf_dir}"/"${_spec_file}" ]] && \
   [[ -n "${_repo_root}" ]]; then
	_ensure_source_subpath "${_catalyst_conf_dir}"/"${_spec_file}" "${_repo_root}"
	_ensure_snapshot "${_repo_root}"
fi

if [[ -n "${_portage_confdir}" ]] && [[ -f "${_spec_file_env}" ]] && \
   [[ -n "${_repo_root}" ]]; then
	_ensure_portdir "${_repo_root}" "${_portage_confdir}"
	if [[ -n "${_gentoobinhost}" ]]; then
	    cat "${_repo_root}"/etc/portage/default/binrepos.conf/gentoobinhost.conf |
		env bash -c '{ source "'"${_spec_file_env}"'"; envsubst; }' \
	    > "${_catalyst_conf_dir}"/gentoobinhost.conf
	    cp "${_catalyst_conf_dir}"/gentoobinhost.conf "${_portage_confdir}"/binrepos.conf/
	fi
fi

if [[ -f "${_catalyst_conf_dir}"/"${_spec_file}" ]] && \
   [[ -f "${_catalyst_conf}" ]] && \
   [[ -n "${_catalyst_log}" ]]; then
   	_ensure_log "${_catalyst_log}"
	${_DEBUGP} catalyst -a -d -c "${_catalyst_conf}" --log-file "${_catalyst_log}" -f "${_catalyst_conf_dir}"/"${_spec_file}" &> "${_catalyst_log%.log}.err"
fi
