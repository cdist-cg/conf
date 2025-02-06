# NOTE: this file needs to be sourced and the $user variable needs to be defined
#
# 2022 Dennis Camera (dennis.camera at riiengineering.ch)
#
# This file is part of skonfig-base.
#
# skonfig-base is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# skonfig-base is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with skonfig-base. If not, see <http://www.gnu.org/licenses/>.
#

: "${user:?}"

prepare_cmds() { :; }

# NOTE: vixie cron, cronie, FreeBSD cron (and others?) add these "magic"
#       comments to the top of the crontab file:
#
#       # DO NOT EDIT THIS FILE - edit the master and reinstall.
#       # (/tmp/crontab.xii0AL installed on Wed Apr 13 13:04:43 2022)
#       # (Cron version -- $Id: crontab.c,v 2.13 1994/01/17 03:20:37 vixie Exp $)
#
#       crontab -l usually removes these lines in its output, but some
#       implementations (e.g. some versions of Cronie) don't, leading to a
#       repitition of these lines on every change.
#
#       Also, OpenBSD/NetBSD cron uses magic comments of a different form.
vixie_comment_filter='^# *\(DO NOT EDIT THIS FILE\|(.* installed on \|(\(Cron\|Cronie\) version \)'

case $(cat "${__global:?}/explorer/os")
in
	(solaris)
		crontab_print_cmd="crontab -l $(quote "${user}")"
		# TODO: On Solaris 10 crontab(1) exits with 0 if an error occurs.
		#       It only logs an error message to stderr.
		crontab_update_cmd="su - $(quote "${user}") -c crontab"

		# Make sure that awk from xpg4 is used for the scripts to work
		prepare_cmds() {
			# shellcheck disable=SC2016
			printf 'PATH=/usr/xpg4/bin/:${PATH}\n'
		}
		;;
	(*bsd)
		crontab_print_cmd="crontab -u $(quote "${user}") -l"
		crontab_update_cmd="crontab -u $(quote "${user}") -"
		;;
	(*)
		crontab_print_cmd="crontab -u $(quote "${user}") -l 2>/dev/null"

		# NOTE: the "VISUAL= EDITOR=cat crontab -e" hack produces a default
		#       crontab in case no crontab existed previously.
		#       This is to include the default wall of text in the newly
		#       created crontab.
		#       This hack produces an error on BusyBox's crontab:
		#       crontab: can't move 'root.new' to 'root': No such file or directory
		#
		#       Thus we only apply it on Debian-based systems because
		#       this seems to be a Debian specialty.
		#       https://salsa.debian.org/debian/cron/-/blob/debian/3.0pl1-137.1/debian/patches/features/Add-helpful-header-to-new-crontab.patch
		_crontab_default_cmd="test -f /etc/debian_version && VISUAL= EDITOR=cat crontab -u $(quote "${user}") -e 2>/dev/null"
		crontab_print_cmd="${crontab_print_cmd} | grep ^ || { ${_crontab_default_cmd}; }"

		# NOTE: Some versions of Vixie cron or its decendants don't
		#       properly clean up their magic comments on cronab -l.
		#       We strip them from the beginning of the file because
		#       otherwise they end up filling the file more with each
		#       edit.
		#
		#       $!N makes sure that matching comment lines are only removed from
		#       the beginning of the file.
		_crontab_strip_magic_comments_cmd="sed -e $(quote "/${vixie_comment_filter?}/d") -e :pl -e n -e bpl"
		crontab_print_cmd="{ ${crontab_print_cmd}; } | ${_crontab_strip_magic_comments_cmd}"

		crontab_update_cmd="crontab -u $(quote "${user}") -"
		;;
esac


# Export variables to be used by parent script

# crontab_print_cmd:
#     prints a command which when executed prints the current state of the
#     crontab, but without automatic comments (cf. $vixie_comment_filter) if
#     necessary.
# crontab_update_cmd:
#     update the crontab from stdin

# shellcheck disable=SC2090
export crontab_print_cmd crontab_update_cmd
