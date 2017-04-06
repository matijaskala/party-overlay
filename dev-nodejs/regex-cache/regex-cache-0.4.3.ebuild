# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Memoize the results of a call to the RegExp constructor, avoiding repetitious runtime compilation of the same string and options, resulting in suprising performance improvements."
HOMEPAGE="https://github.com/jonschlinkert/regex-cache"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"
S=${WORKDIR}

DEPEND=""
RDEPEND="net-libs/nodejs
	>=dev-nodejs/is-primitive-2.0.0
	>=dev-nodejs/is-equal-shallow-0.1.3
"

src_install() {
	mv package ${PN}
	insinto /usr/$(get_libdir)/node_modules
	doins -r ${PN}
}