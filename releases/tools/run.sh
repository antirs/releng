#!/bin/bash

_spec_file_template="$1"
_spec_file_env="$2"
_resume="$3"

_spec_file="${_spec_file_template%.template}"
_spec_file="${_spec_file##*/}"

if [[ "${_resume}" == "0" ]]; then
    _timestamp="$(date '+%Y%m%dT%H%M%SZ')"
else
    _timestamp="${_resume}"
fi

_debug="$4"

[[ -n "${_debug}" ]] && _DEBUGP="echo"

_usage()
{
	echo "usage: $(basename "$0") <spec.template> <spec.env> <resume> [debug]"
}

[[ $# -lt 3 ]] && { _usage; exit 1; }

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
	local portage_confdir_source="$2"
	local portage_confdir="$3"
	mkdir -p "${portage_confdir}"
	cp -rP "${portage_confdir_source}"/* "${portage_confdir}"
	cp -r "${repo_root}"/etc/portage/default/* "${portage_confdir}"
	chown -R portage:portage "${portage_confdir}"
}

_ensure_confdir()
{
	local catalyst_conf_dir="$1"
	mkdir -p "${catalyst_conf_dir}"
	chown -R portage:portage "${catalyst_conf_dir}"
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
_catalyst_shdir=$(_get_spec_file_variable "${_spec_file_env}" CATALYST_SHDIR)
_catalyst_log=$(_get_spec_file_variable "${_spec_file_env}" CATALYST_LOG)
_portage_confdir_source=$(_get_spec_file_variable "${_spec_file_env}" PORTAGE_CONFDIR_SOURCE)
_portage_envs=$(_get_spec_file_variable "${_spec_file_env}" PORTAGE_ENVS)
_makeopts=$(_get_spec_file_variable "${_spec_file_env}" MAKEOPTS)
_distcc_hosts=$(_get_spec_file_variable "${_spec_file_env}" DISTCC_HOSTS)
_gentoo_mirrors=$(_get_spec_file_variable "${_spec_file_env}" GENTOO_MIRRORS)
_gentoobinhost=$(_get_spec_file_variable "${_spec_file_env}" GENTOOBINHOST)
_emerge_opts=$(_get_spec_file_variable "${_spec_file_env}" EMERGE_DEFAULT_OPTS)
_binpkg_gpg_home=$(_get_spec_file_variable "${_spec_file_env}" BINPKG_GPG_SIGNING_GPG_HOME)
_binpkg_gpg_key=$(_get_spec_file_variable "${_spec_file_env}" BINPKG_GPG_SIGNING_KEY)

_catalyst_conf_template_file="${_catalyst_conf_template##*/}"
_catalyst_conf="${_catalyst_conf_dir}"/"${_catalyst_conf_template_file%.template}"
_catalyst_shdir="${_catalyst_shdir:-/usr/share/catalyst/targets}"
_portage_confdir="${_catalyst_conf_dir}"/portage

if [[ -f "${_catalyst_conf_template}" ]] && [[ -f "${_spec_file_env}" ]] && \
   [[ -n "${_catalyst_conf_dir}" ]]; then
    	_ensure_confdir "${_catalyst_conf_dir}"
	cat "${_catalyst_conf_template}" |
		env -i CATALYST_SHDIR="${_catalyst_shdir}" TIMESTAMP="${_timestamp}" bash -c '{ source "'"${_spec_file_env}"'"; envsubst; }' \
	> "${_catalyst_conf}"
fi

if [[ -d "${_catalyst_conf_dir}" ]]; then
   if [[ -n "${_makeopts}" ]]; then
       echo "export MAKEOPTS='${_makeopts}'" \
	    > "${_catalyst_conf_dir}"/catalystrc
   fi
   if [[ -n "${_distcc_hosts}" ]]; then
       echo "export DISTCC_HOSTS='${_distcc_hosts}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
   if [[ -n "${_gentoo_mirrors}" ]]; then
       echo "export GENTOO_MIRRORS='${_gentoo_mirrors}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
   if [[ -n "${_emerge_opts}" ]]; then
       echo "export EMERGE_DEFAULT_OPTS='${_emerge_opts}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
   if [[ -n "${_binpkg_gpg_home}" ]]; then
       echo "export BINPKG_GPG_SIGNING_GPG_HOME='${_binpkg_gpg_home}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
   if [[ -n "${_binpkg_gpg_key}" ]]; then
       echo "export BINPKG_GPG_SIGNING_KEY='${_binpkg_gpg_key}'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
       echo "export BINPKG_GPG_SIGNING_BASE_COMMAND='/usr/bin/flock /run/portage-binpkg-gpg.lock /usr/bin/gpg --sign --armor [PORTAGE_CONFIG]'" \
	    >> "${_catalyst_conf_dir}"/catalystrc
   fi
fi

if [[ -f "${_spec_file_template}" ]] && [[ -f "${_spec_file_env}" ]] && \
   [[ -d "${_catalyst_conf_dir}" ]]; then
	cat "${_spec_file_template}" |
		env -i PORTAGE_CONFDIR="${_portage_confdir}" TIMESTAMP="${_timestamp}" bash -c '{ source "'"${_spec_file_env}"'"; envsubst; }' \
	> "${_catalyst_conf_dir}"/"${_spec_file}"
fi

if [[ -f "${_catalyst_conf_dir}"/"${_spec_file}" ]] && \
   [[ -n "${_repo_root}" ]]; then
	_ensure_source_subpath "${_catalyst_conf_dir}"/"${_spec_file}" "${_repo_root}"
	_ensure_snapshot "${_repo_root}"
fi

if [[ -n "${_portage_confdir}" ]] && [[ -f "${_spec_file_env}" ]] && \
   [[ -n "${_repo_root}" ]]; then
	_ensure_portdir "${_repo_root}" "${_portage_confdir_source}" "${_portage_confdir}"
	if [[ -n "${_gentoobinhost}" ]]; then
	    cat "${_repo_root}"/etc/portage/default/binrepos.conf/gentoobinhost.conf |
		env bash -c '{ source "'"${_spec_file_env}"'"; envsubst; }' \
	    > "${_catalyst_conf_dir}"/gentoobinhost.conf
	    cp "${_catalyst_conf_dir}"/gentoobinhost.conf "${_portage_confdir}"/binrepos.conf/
	fi
	if [[ -n "${_portage_envs}" ]]; then
	    mkdir -p "${_portage_confdir}"/package.env/releng
	    echo "${_portage_envs}" | xargs cat >> "${_portage_confdir}"/package.env/releng/99-custom
	    chown portage:portage "${_portage_confdir}"/package.env -R
	fi
	chown portage:portage "${_portage_confdir}"/gnupg -R
	chmod a+rX "${_portage_confdir}"/gnupg -R
	chmod a+rX "${_portage_confdir}"
fi

if [[ -f "${_catalyst_conf_dir}"/"${_spec_file}" ]] && \
   [[ -f "${_catalyst_conf}" ]] && \
   [[ -n "${_catalyst_log}" ]]; then
   	_ensure_log "${_catalyst_log}"
	if [[ "${_resume}" == "0" ]]; then
	    ${_DEBUGP} catalyst -a -d -c "${_catalyst_conf}" --log-file "${_catalyst_log}" -f "${_catalyst_conf_dir}"/"${_spec_file}" &> "${_catalyst_log%.log}.err"
	else
	    ${_DEBUGP} catalyst -d -c "${_catalyst_conf}" --log-file "${_catalyst_log}" -f "${_catalyst_conf_dir}"/"${_spec_file}" &> "${_catalyst_log%.log}.err"
	fi
fi
