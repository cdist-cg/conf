#!/bin/sh -e

SCRDIR=$(cd "${0%/*}/." && pwd -P)

test -d "${SCRDIR}" || { echo 'Could not determine CWD.' >&2; exit 1; }

OUTFILE="${SCRDIR%/files/*}/files/openwrt/tzdata.tsv"

mkdir -p "${OUTFILE%/*}"

case ${1-}
in
	(local)
		printf 'Using local tzdata.lua to construct %s\n' "${OUTFILE}"

		lua -l luci.sys.zoneinfo.tzdata - <<-'EOF' >"${OUTFILE}"
		for i, p in ipairs(luci.sys.zoneinfo.tzdata.TZ) do
		   print(p[1], p[2])
		end
		EOF
		;;
	(fetch|"")
		printf 'Downloading tzdata.lua to construct %s\n' "${OUTFILE}"

		TZDATA_LUA_URL='https://git.openwrt.org/?p=project/luci.git;a=blob_plain;f=modules/luci-base/luasrc/sys/zoneinfo/tzdata.lua'
		export TZDATA_LUA_URL

		tzdata_lua_contents=$(
			python3 -c 'import os,sys,urllib.request;sys.stdout.write(urllib.request.urlopen(os.environ["TZDATA_LUA_URL"]).read().decode())'
		) || {
			printf 'Failed to download tzdata.lua from %s\n' "${TZDATA_LUA_URL}" >&2
			exit 1
		}

		{
			printf %s "${tzdata_lua_contents}" | grep -v '^module'
			echo 'for _, p in pairs(TZ) do print(p[1], p[2]) end'
		} | lua >"${OUTFILE}"
		;;
	(-h|--help|*)
		printf 'Usage: %s (fetch|local)\n\n' "$0"
		printf 'fetch:\n\tDownload tzdata.lua from the LuCI Git repository and convert to TSV for use by the type.\n'
		printf 'local:\n\tUse the installed tzdata.lua file (script must be run on an OpenWrt system with LuCI installed)\n'

		# exit 0 if --help, 1 otherwise.
		test "$1" = '--help' -o "$1" = '-h'
		exit
		;;
esac
