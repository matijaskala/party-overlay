# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils git-2

DESCRIPTION="Next generation Vala IDE"
HOMEPAGE="http://valama.github.io/valama"
EGIT_REPO_URI="git://github.com/Valama/valama.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMONDEPEND="
	>=dev-util/cmake-2.8.4
	>=dev-lang/vala-0.22
	>=dev-libs/glib-2.36.4
	>=dev-libs/gdl-3.4
	dev-util/glade
	>=dev-libs/libgee-0.10.5
	>=x11-libs/gtk+-2.32
	>=x11-libs/gtk+-3.4"

DEPEND="$COMMONDEPEND
	virtual/pkgconfig"
RDEPEND="$COMMONDEPEND"
