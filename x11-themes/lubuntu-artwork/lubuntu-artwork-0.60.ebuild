# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Default Lubuntu themes"
HOMEPAGE="https://launchpad.net/lubuntu-desktop"
SRC_URI="mirror://ubuntu/pool/universe/${PN:0:1}/${PN}/${PN}_${PV}.tar.xz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND="x11-themes/gtk-engines-murrine"

src_compile() {
	:
}
