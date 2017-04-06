# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Resolve the source map and/or sources for a generated file."
HOMEPAGE="https://github.com/lydell/source-map-resolve"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"
S=${WORKDIR}

DEPEND=""
RDEPEND="net-libs/nodejs
	>=dev-nodejs/source-map-url-0.4.0
	>=dev-nodejs/atob-2.0.0
	>=dev-nodejs/urix-0.1.0
	>=dev-nodejs/resolve-url-0.2.1
"

src_install() {
	mv package ${PN}
	insinto /usr/$(get_libdir)/node_modules
	doins -r ${PN}
}