# Distributed under the terms of the GNU General Public License v2

EAPI="3"

inherit autotools eutils

DESCRIPTION="BAMF Application Matching Framework"
SRC_URI="http://launchpad.net/${PN}/0.3/${PV}/+download/${P}.tar.gz"
HOMEPAGE="https://launchpad.net/bamf"
KEYWORDS="*"
SLOT="0"
LICENSE="LGPL-3"
IUSE="gtk3 webapps"

DEPEND=">=dev-lang/vala-0.11.7
    gtk3? (
        >=x11-libs/libwnck-3.2.1
        >=x11-libs/gtk+-3.2.1 )
    gnome-base/libgtop
    dev-util/gtk-doc"
RDEPEND="${DEPEND}"

src_configure(){
    econf \
        $(use_enable webapps) \
        --with-gtk=$(usex gtk3 "3" "2")
}
