# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/gentoo-zsh-completions/gentoo-zsh-completions-20141115.ebuild,v 1.4 2014/11/21 13:49:34 radhermit Exp $

EAPI=5

inherit eutils

DESCRIPTION="Gentoo specific zsh completion support (includes emerge and ebuild commands)"
HOMEPAGE="https://github.com/radhermit/gentoo-zsh-completions"
SRC_URI="http://dev.gentoo.org/~radhermit/dist/${P}.tar.xz"

LICENSE="ZSH"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc64-solaris"

RDEPEND=">=app-shells/zsh-4.3.5"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-eselect.patch
}

src_install() {
	insinto /usr/share/zsh/site-functions
	doins _*

	dodoc AUTHORS
}

pkg_postinst() {
	elog
	elog "If you happen to compile your functions, you may need to delete"
	elog "~/.zcompdump{,.zwc} and recompile to make the new completions available"
	elog "to your shell."
	elog
}
