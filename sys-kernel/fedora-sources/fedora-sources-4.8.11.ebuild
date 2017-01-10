# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"

inherit kernel-2
detect_version

DESCRIPTION="Full sources for the Linux kernel including Fedora patches"
HOMEPAGE="https://src.fedoraproject.org/cgit/rpms/kernel.git"
UNIPATCH_STRICTORDER="yes"
SRC_URI="${KERNEL_URI}"

KEYWORDS="~amd64 ~x86"
FEDORA_SRC="git://pkgs.fedoraproject.org/kernel.git"

: ${GEEK_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}
geek_prepare_storedir() {
	[[ -d ${GEEK_STORE_DIR} ]] || addwrite /
	addwrite "${GEEK_STORE_DIR}"
}

src_unpack() {
	geek_prepare_storedir

	local CSD="${GEEK_STORE_DIR}/fedora"
	if [ -d "${CSD}" ] ; then
		cd "${CSD}" || die "cd ${CSD} failed"
		[ -e .git ] && git pull --all
	else
		git clone --depth=1 -b f23 "${FEDORA_SRC}" "${CSD}"
		cd "${CSD}" || die "cd ${CSD} failed"
	fi

	mkdir -p "${T}/fedora"
	cp *.patch "${T}/fedora"

	for i in $(awk '/^Patch.*\.patch/{print $2}' kernel.spec) ; do
		UNIPATCH_LIST+=" ${T}/fedora/$i"
	done

	kernel-2_src_unpack
}
