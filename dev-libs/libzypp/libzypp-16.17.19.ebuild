# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils

DESCRIPTION="ZYpp Package Management library"
HOMEPAGE="http://doc.opensuse.org/projects/libzypp/HEAD/"
# version bumps check here:
#  https://build.opensuse.org/package/show/openSUSE:Factory/libzypp
SRC_URI="http://github.com/openSUSE/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="doc libproxy"

RDEPEND="
	dev-libs/boost
	dev-libs/expat
	dev-libs/libxml2
	dev-libs/popt
	dev-libs/libsolv[rpm]
	dev-libs/openssl:0
	net-misc/curl
	sys-libs/zlib
	virtual/udev
	libproxy? ( net-libs/libproxy )
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	doc? ( app-doc/doxygen[dot] )
"

# tests require actual instance of zypp to be on system
RESTRICT="test mirror"

src_configure() {
	sed -i s:sys/types:sys/sysmacros: zypp/PathInfo.cc || die

	local mycmakeargs=(
		"-DUSE_TRANSLATION_SET=zypp"
		"-DCMAKE_CXX_FLAGS=-DLIBSOLV_TOOLVERSION=\\\"1.0\\\""
		$(cmake-utils_use_disable doc AUTODOCS)
		$(cmake-utils_use_disable libproxy LIBPROXY)
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	cmake-utils_src_compile -C po translations
}

src_test() {
	cmake-utils_src_compile -C tests
	cmake-utils_src_test
}

src_install() {
	cmake-utils_src_install
	cmake-utils_src_install -C po
}
