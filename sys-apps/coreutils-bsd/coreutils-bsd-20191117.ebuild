# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Standard BSD utilities"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
COMMIT_ID="11d8bf9f0bf00ff62b1eec50659b2d614c4c631f"
SRC_URI="https://github.com/matijaskala/${PN}/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
RESTRICT="mirror"

DEPEND="dev-libs/libbsd"
RDEPEND="${DEPEND}
	!sys-apps/coreutils"

S=${WORKDIR}/${PN}-${COMMIT_ID}
