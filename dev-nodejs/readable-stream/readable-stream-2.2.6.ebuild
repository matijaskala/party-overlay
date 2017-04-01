# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Streams3, a user-land copy of the stream library from Node.js"
HOMEPAGE="https://github.com/nodejs/readable-stream"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"
S=${WORKDIR}

DEPEND=""
RDEPEND="net-libs/nodejs
	>=dev-nodejs/isarray-1.0.0
	>=dev-nodejs/inherits-2.0.1
	>=dev-nodejs/core-util-is-1.0.0
	>=dev-nodejs/process-nextick-args-1.0.6
	>=dev-nodejs/string_decoder-0.10
	>=dev-nodejs/util-deprecate-1.0.1
	>=dev-nodejs/buffer-shims-1.0.0
"

src_install() {
	mv package ${PN}
	insinto /usr/$(get_libdir)/node_modules
	doins -r ${PN}
}
