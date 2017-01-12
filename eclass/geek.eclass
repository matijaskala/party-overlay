# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: geek.eclass
# @MAINTAINER:
# Matija Skala <mskala@gmx.com>
# @AUTHOR:
# Matija Skala <mskala@gmx.com>
# @BLURB: Eclass for combining VCS with tarballs
# @DESCRIPTION:
# Clone a git repository, then apply its contents to source code extracted from tarballs

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

geek_apply() {
	pushd "${S}" > /dev/null || die
	for i ; do
		ebegin "Applying ${GEEK_SOURCE_REPO}/$i"
		patch -f -p1 -r - -s < "${GEEK_STORE_DIR}/${GEEK_SOURCE_REPO}/$i"
		eend $?
	done
	popd > /dev/null || die
}
