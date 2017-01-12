# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: geek.eclass
# @MAINTAINER:
# Matija Skala <mskala@gmx.com>
# @AUTHOR:
# Matija Skala <mskala@gmx.com>
# @BLURB: Eclass for geek-sources
# @DESCRIPTION:
# This eclass applies the patches for geek-sources

inherit kernel-2

EXPORT_FUNCTIONS src_unpack

SRC_URI="${KERNEL_URI}"
IUSE="${GEEK_IUSE}"
: ${GEEK_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}

geek_prepare_storedir() {
	[[ -d ${GEEK_STORE_DIR} ]] || addwrite /
	addwrite "${GEEK_STORE_DIR}"
}

geek_fetch() {
	local uper=$(echo $1 | tr '[:lower:]' '[:upper:]')
	local BRANCH=${uper}_BRANCH
	local SRC=${uper}_SRC
	local CSD="${GEEK_STORE_DIR}/$1"
	if [ -d "${CSD}" ] ; then
		pushd "${CSD}" > /dev/null || die
		[ -e .git ] && git pull --all --quiet
		popd > /dev/null || die
	else
		git clone --depth=1 -b "${!BRANCH}" "${!SRC}" "${CSD}"
	fi
}

_GEEK_CURRENT_REPO=
geek_apply() {
	pushd "${S}" > /dev/null || die
	for i ; do
		ebegin "Applying ${_GEEK_CURRENT_REPO}/$i"
		patch -f -p1 -r - -s < "${GEEK_STORE_DIR}/${_GEEK_CURRENT_REPO}/$i"
		eend $?
	done
	popd > /dev/null || die
}

geek_src_unpack() {
	kernel-2_src_unpack

	geek_prepare_storedir

	for i in ${GEEK_IUSE} ; do
		use ${i} || continue
		geek_fetch ${i}
		pushd "${GEEK_STORE_DIR}/$i" > /dev/null || die
		_GEEK_CURRENT_REPO=${i}
		${i}_apply
		_GEEK_CURRENT_REPO=
		popd > /dev/null || die
	done
}
