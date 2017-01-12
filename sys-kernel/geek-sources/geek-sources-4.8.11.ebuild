# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
GEEK_SOURCES_IUSE="fedora suse"

inherit geek-sources
detect_version

DESCRIPTION="Full sources for the Linux kernel including Fedora and openSUSE patches"
HOMEPAGE="https://www.kernel.org"

KEYWORDS="~amd64 ~x86"
FEDORA_REPO_URI="git://pkgs.fedoraproject.org/kernel.git"
FEDORA_BRANCH="f23"
SUSE_REPO_URI="git://kernel.opensuse.org/kernel-source.git"
SUSE_BRANCH="stable"

fedora_apply() {
	geek_apply $(awk '/^Patch.*\.patch/{print $2}' kernel.spec)
}

suse_apply() {
	# masked arch.acpi.thermal because it is not compatible with linux 4.8.11
	# TODO remove the mask in later ebuilds
	geek_apply $(awk '!/(#|^$)/ && !/^(\+(needs|tren|trenn|hare|xen|jbeulich|jeffm|jjolly|agruen|still|philips|disabled|olh))|patches\.(kernel|rpmify|xen|arch.acpi.thermal).*/{gsub(/[ \t]/,"") ; print $1}' series.conf)
}
