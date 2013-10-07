# Distributed under the terms of the GNU General Public License v2

EAPI="3"

inherit cmake-utils versionator

MY_PN="${PN/plugins/plug-ins}"
MY_PV=$(get_version_component_range '1-2')

DESCRIPTION="Official plugins for cairo-dock"
HOMEPAGE="http://www.glx-dock.org"
SRC_URI="http://launchpad.net/${MY_PN}/${MY_PV}/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="experimental"
IUSE="alsa clock dbusmenu disks doncky exif gmenu gnome gtk3 impulse kde mail mono nwmon scooby terminal tomboy upower vala webkit xfce xgamma xklavier xrandr zeitgeist"

RDEPEND="
	dev-libs/dbus-glib
	dev-libs/libxml2
	gnome-base/librsvg
	x11-libs/gtk+:2
	x11-libs/gtkglext
	~x11-misc/cairo-dock-${PV}

	gtk3? ( x11-libs/gtk+:3 )
	alsa? ( media-libs/alsa-lib )
	clock? ( dev-libs/libical )
	dbusmenu? ( dev-libs/libdbusmenu )
	exif? ( media-libs/libexif )
	gmenu? ( gnome-base/gnome-menus )
	mail? ( net-libs/libetpan )
	mono? ( dev-dotnet/glib-sharp )
	kde? ( kde-base/kdelibs )
	terminal? ( x11-libs/vte )
	upower? ( sys-power/upower )
	vala? ( dev-lang/vala:0.12 )
	webkit? ( net-libs/webkit-gtk )
	xgamma? ( x11-libs/libXxf86vm )
	xklavier? ( x11-libs/libxklavier )
	zeitgeist? ( gnome-extra/zeitgeist )
"

DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	# Don't use standard cmake-utils_use* functions because upstream tests STREQUAL "no/yes"
	local mycmakeargs=(
		"-DROOT_PREFIX=${D}"
		"$(usex alsa "" "-Denable-alsa=no")"
		"-Denable-dbusmenu-support=$(usex dbusmenu "yes" "no")"
		"$(usex disks "-Denable-disks=yes")"
		"$(usex doncky "-Denable-doncky=yes")"
		"-Denable-exif-support=$(usex exif "yes" "no")"
		"$(usex gmenu "" "-Denable-gmenu=no")"
		"$(usex gnome "" "-Denable-gnome-integration=no")"
		"-Denable-ical-support=$(usex clock "yes" "no")"
		"-Denable-impulse=$(usex impulse "yes" "no")"
		"$(usex kde "-Denable-kde-integration=yes" "")"
		"-Denable-mail=$(usex mail "yes" "no")"
		"-Denable-mono-interface=$(usex mono "yes" "no")"
		"$(usex nwmon "-Denable-network-monitor=yes" "")"
		"-Denable-recent-events=$(usex zeitgeist "yes" "no")"
		"$(usex scooby "-Denable-scooby-do=yes" "")"
		"-Denable-terminal=$(usex terminal "yes" "no")"
		"-Denable-upower-support=$(usex upower "yes" "no")"
		"-Denable-vala-interface=$(usex vala "yes" "no")"
		"$(usex webkit "" "-Denable-weblets=no")"
		"-Denable-xfce-integration=$(usex xfce "yes" "no")"
		"-Denable-xgamma=$(usex xgamma "yes" "no")"
		"-Denable-xrandr-support=$(usex xrandr "yes" "no")"
	)
	cmake-utils_src_configure
}
