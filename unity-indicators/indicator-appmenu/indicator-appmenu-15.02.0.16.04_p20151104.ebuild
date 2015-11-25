# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils flag-o-matic gnome2 ubuntu

DESCRIPTION="Indicator for application menus"
HOMEPAGE="https://launchpad.net/indicator-appmenu"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="dev-libs/libdbusmenu:=
	dev-libs/libindicate-qt
	x11-libs/bamf:=
	dev-libs/libappindicator:3=
	x11-libs/gtk+:3
	x11-libs/libwnck:1
	x11-libs/libwnck:3"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
	append-cflags -Wno-error
}
