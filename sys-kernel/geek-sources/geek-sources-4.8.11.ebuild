# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
GEEK_IUSE="fedora suse"

inherit geek
detect_version

DESCRIPTION="Full sources for the Linux kernel including Fedora and openSUSE patches"
HOMEPAGE="https://www.kernel.org"

KEYWORDS="~amd64 ~x86"
FEDORA_SRC="git://pkgs.fedoraproject.org/kernel.git"
FEDORA_BRANCH="f23"
SUSE_SRC="git://kernel.opensuse.org/kernel-source.git"
SUSE_BRANCH="stable"

fedora_apply() {
	for i in $(awk '/^Patch.*\.patch/{print $2}' kernel.spec) ; do
		geek_apply "$i"
	done
}

suse_apply() {
	for i in $(awk '!/(#|^$)/ && !/^(\+(needs|tren|trenn|hare|xen|jbeulich|jeffm|jjolly|agruen|still|philips|disabled|olh))|patches\.(kernel|rpmify|xen).*/{gsub(/[ \t]/,"") ; print $1}' series.conf) ; do
		geek_apply "$i"
	done
}
