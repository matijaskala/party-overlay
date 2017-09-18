# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit vala

COMMIT_ID="e80c5b481d2521a55cd6e8e8d5a8f332fd8d1965"
DESCRIPTION="Brotli packer"
HOMEPAGE="https://github.com/matijaskala/brp"
SRC_URI="${HOMEPAGE}/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="
	app-arch/brotli:=
	dev-libs/glib:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	$(vala_depend)"

S=${WORKDIR}/${PN}-${COMMIT_ID}

src_prepare() {
	vala_src_prepare
	default
}

src_compile() {
	showcmd() {
		echo "$@"
		"$@"
	}
	showcmd ${VALAC} brp.gs libbrotlienc.vapi libbrotlidec.vapi --pkg=posix --ccode || die
	showcmd $(tc-getCC) ${CFLAGS} $(pkg-config --cflags --libs glib-2.0 libbrotlienc libbrotlidec) -o ${PN}$(get_exeext) ${PN}.c || die
}

src_install() {
	dobin ${PN}$(get_exeext)
}
