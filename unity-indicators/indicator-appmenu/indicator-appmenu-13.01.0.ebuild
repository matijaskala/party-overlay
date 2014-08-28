# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools eutils flag-o-matic gnome2

DESCRIPTION="An indicator to host the menus from an application."
HOMEPAGE="https://launchpad.net/indicator-appmenu"
SRC_URI="https://launchpadlibrarian.net/171795552/${PN}_${PV}%2B14.04.20140404.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/libdbusmenu:=
	x11-libs/bamf:=
	>=x11-libs/gtk+-3.5.12:3
	x11-libs/libwnck:3
	>=dev-libs/dbus-glib-0.76
	>=dev-libs/libindicator-0.4.1"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
	append-cflags -Wno-error
}

src_configure() {
	econf --with-gtk=3
}
