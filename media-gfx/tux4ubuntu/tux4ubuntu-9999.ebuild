# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Let's bring Tux to Linux!"
HOMEPAGE="https://tux4ubuntu.blogspot.com"
EGIT_REPO_URI="git://github.com/tuxedojoe/${PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+grub +icons"

src_install() {
	if use icons ; then
		insinto /usr/share/icons
		doins -r tux-icon-theme
	fi
	if use grub ; then
		insinto /usr/share/grub/themes
		doins -r tux-grub-theme
	fi
}
