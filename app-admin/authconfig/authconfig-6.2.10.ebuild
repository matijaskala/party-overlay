# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="Command line tool for setting up authentication from network services"
HOMEPAGE="https://pagure.io/authconfig"
SRC_URI="https://releases.pagure.io/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="dev-libs/glib
	sys-devel/gettext
	dev-util/intltool
	dev-util/desktop-file-utils
	dev-perl/XML-Parser"
RDEPEND="${DEPEND} dev-libs/newt"

src_install() {
	emake DESTDIR="${D}" install
	# drop broken .desktop
	rm -f "${D}/usr/share/applications/authconfig.desktop"
}
