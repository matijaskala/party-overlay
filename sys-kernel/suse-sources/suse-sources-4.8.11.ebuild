# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"

inherit kernel-2
detect_version

DESCRIPTION="Full sources for the Linux kernel including openSUSE patches"
HOMEPAGE="https://kernel.opensuse.org"
UNIPATCH_STRICTORDER="yes"
SRC_URI="${KERNEL_URI}"

KEYWORDS="~amd64 ~x86"
SUSE_SRC="git://kernel.opensuse.org/kernel-source.git"
SUSE_BRANCH="stable"

: ${GEEK_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}
geek_prepare_storedir() {
	[[ -d ${GEEK_STORE_DIR} ]] || addwrite /
	addwrite "${GEEK_STORE_DIR}"
}

src_unpack() {
	geek_prepare_storedir

	local CSD="${GEEK_STORE_DIR}/suse"
	if [ -d "${CSD}" ] ; then
		cd "${CSD}" || die "cd ${CSD} failed"
		[ -e .git ] && git pull --all
	else
		git clone -b "${SUSE_BRANCH}" "${SUSE_SRC}" "${CSD}"
		cd "${CSD}" || die "cd ${CSD} failed"
	fi

	mkdir -p "${T}/suse"
	for i in patches.* ; do
		[ "$i" = patches.kernel.org ] || [ "$i" = patches.rpmify ] || cp -r "$i" "${T}/suse"
	done

	for i in $(awk '!/(#|^$)/ && !/^(\+(needs|tren|trenn|hare|xen|jbeulich|jeffm|jjolly|agruen|still|philips|disabled|olh))|patches\.(kernel|rpmify|xen).*/{gsub(/[ \t]/,"") ; print $1}' series.conf) ; do
		UNIPATCH_LIST+=" ${GEEK_STORE_DIR}/suse/$i"
	done

	kernel-2_src_unpack
}
