# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: geek-sources.eclass
# @MAINTAINER:
# Matija Skala <mskala@gmx.com>
# @AUTHOR:
# Matija Skala <mskala@gmx.com>
# @BLURB: Eclass for geek-sources
# @DESCRIPTION:
# This eclass applies the patches for geek-sources

inherit geek kernel-2

EXPORT_FUNCTIONS src_unpack

SRC_URI="${KERNEL_URI}"
IUSE="${GEEK_SOURCES_IUSE}"

geek-sources_src_unpack() {
	kernel-2_src_unpack

	geek_prepare_storedir

	for i in ${GEEK_IUSE} ; do
		use ${i} || continue
		geek_fetch ${i}
		pushd "${GEEK_STORE_DIR}/$i" > /dev/null || die
		GEEK_SOURCE_REPO=${i} ${i}_apply
		popd > /dev/null || die
	done
}
