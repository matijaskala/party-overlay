# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )

inherit eutils distutils-r1

DESCRIPTION="langtable is used to guess reasonable defaults for locale, keyboard layout, etc."
HOMEPAGE="https://github.com/mike-fabian/langtable"
SRC_URI="http://github.com/mike-fabian/langtable/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE=""

python_install() {
	distutils-r1_python_install --install-data=/usr/share/langtable
	gzip --force --best "${D}/usr/share/langtable/"*.xml || die
}
