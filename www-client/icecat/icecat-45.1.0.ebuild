# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
VIRTUALX_REQUIRED="pgo"
WANT_AUTOCONF="2.1"
MOZ_ESR=1

# This list can be updated with scripts/get_langs.sh from the mozilla overlay
MOZ_LANGS=( ach af an ar as ast az be bg bn-BD bn-IN br bs ca cs cy da de
el en en-GB en-US en-ZA eo es-AR es-CL es-ES es-MX et eu fa fi fr
fy-NL ga-IE gd gl gu-IN he hi-IN hr hsb hu hy-AM id is it ja kk km kn ko
lt lv mai mk ml mr ms nb-NO nl nn-NO or pa-IN pl pt-BR pt-PT rm ro ru si
sk sl son sq sr sv-SE ta te th tr uk uz vi xh zh-CN zh-TW )

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_alpha/a}" # Handle alpha for SRC_URI
MOZ_PV="${MOZ_PV/_beta/b}" # Handle beta for SRC_URI
MOZ_PV="${MOZ_PV/_rc/rc}" # Handle rc for SRC_URI

if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly different version numbers
	MOZ_PV="${MOZ_PV}esr"
fi

# Patch version
PATCH="firefox-45.0-patches-04"
MOZ_HTTP_URI="https://archive.mozilla.org/pub/firefox/releases"

# Kill gtk3 support since gtk+-3.20 breaks it hard prior to 48.0
#MOZCONFIG_OPTIONAL_GTK3=1
MOZCONFIG_OPTIONAL_WIFI=1
MOZCONFIG_OPTIONAL_JIT="enabled"

MOZ_PN="firefox"
MOZ_P="firefox-${MOZ_PV}"
MOZEXTENSION_TARGET=browser/extensions

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-v6.45 pax-utils fdo-mime autotools virtualx mozlinguas

DESCRIPTION="IceCat Web Browser"
HOMEPAGE="https://www.gnu.org/software/gnuzilla"

#KEYWORDS="alpha amd64 arm arm64 hppa ia64 ppc ppc64 x86 amd64-linux x86-linux"

SLOT="0"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1 GPL-3 LGPL-3"
IUSE="hardened +hwaccel pgo selinux +gmp-autoupdate test"

#EGIT_REPO_URI="git://git.sv.gnu.org/gnuzilla.git"

# More URIs appended below...
SRC_URI="${SRC_URI}
	https://www.icecat.gnu/gnuzilla.tar.xz
	https://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz
	https://dev.gentoo.org/~axs/mozilla/patchsets/${PATCH}.tar.xz
	https://dev.gentoo.org/~polynomial-c/mozilla/patchsets/${PATCH}.tar.xz"

ASM_DEPEND=">=dev-lang/yasm-1.1"

# Mesa 7.10 needed for WebGL + bugfixes
RDEPEND="
	>=dev-libs/nss-3.21.1
	>=dev-libs/nspr-4.12
	selinux? ( sec-policy/selinux-mozilla )"

DEPEND="${RDEPEND}
	pgo? (
		>=sys-devel/gcc-4.5 )
	amd64? ( ${ASM_DEPEND}
		virtual/opengl )
	x86? ( ${ASM_DEPEND}
		virtual/opengl )"

# No source releases for alpha|beta
if [[ ${PV} =~ alpha ]]; then
	CHANGESET="8a3042764de7"
	SRC_URI="${SRC_URI}
		https://dev.gentoo.org/~nirbheek/mozilla/firefox/firefox-${MOZ_PV}_${CHANGESET}.source.tar.xz"
	S="${WORKDIR}/mozilla-aurora-${CHANGESET}"
else
	S="${WORKDIR}/firefox-${MOZ_PV}"
	SRC_URI="${SRC_URI}
		${MOZ_HTTP_URI}/${MOZ_PV}/source/firefox-${MOZ_PV}.source.tar.xz"
fi

QA_PRESTRIPPED="usr/lib*/${PN}/firefox"

BUILD_OBJ_DIR="${S}/ff"

pkg_setup() {
	moz_pkgsetup

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XDG_SESSION_COOKIE \
		XAUTHORITY

	if use pgo; then
		einfo
		ewarn "You will do a double build for profile guided optimization."
		ewarn "This will result in your build taking at least twice as long as before."
	fi
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	if use pgo || use debug || use test ; then
		CHECKREQS_DISK_BUILD="8G"
	else
		CHECKREQS_DISK_BUILD="4G"
	fi
	check-reqs_pkg_setup
}

src_unpack() {
	unpack ${A}

	# Unpack language packs
	mozlinguas_src_unpack
}

src_prepare() {
	# Apply our patches
	eapply "${WORKDIR}/firefox" \
		"${WORKDIR}/gnuzilla/data/patches"/* \
		"${FILESDIR}"/reorder-addon-sdk-moz.build.patch \
		"${FILESDIR}"/unity-menubar.patch \
		"${FILESDIR}"/jit-none-branch64.patch

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Ensure that our plugins dir is enabled as default
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/lib/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path for 32bit!"
	sed -i -e "s:/usr/lib64/mozilla/plugins:/usr/lib64/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path for 64bit!"

	# Fix sandbox violations during make clean, bug 372817
	sed -e "s:\(/no-such-file\):${T}\1:g" \
		-i "${S}"/config/rules.mk \
		-i "${S}"/nsprpub/configure{.in,} \
		|| die

	# Don't exit with error when some libs are missing which we have in
	# system.
	sed '/^MOZ_PKG_FATAL_WARNINGS/s@= 1@= 0@' \
		-i "${S}"/browser/installer/Makefile.in || die

	# Don't error out when there's no files to be removed:
	sed 's@\(xargs rm\)$@\1 -f@' \
		-i "${S}"/toolkit/mozapps/installer/packager.mk || die

	# Keep codebase the same even if not using official branding
	sed '/^MOZ_DEV_EDITION=1/d' \
		-i "${S}"/browser/branding/aurora/configure.sh || die

	einfo "Converting into IceCat ..."
	sed '/mozilla\.org\/legal/d' -i "${S}"/services/healthreport/healthreport-prefs.js
	sed "s|^\(pref(\"datareporting\.healthreport\.infoURL.*\", \"\)https://.*\(\");\)$|\1${HOMEPAGE}\2|" -i "${S}"/{services/healthreport,mobile/android/chrome/content}/healthreport-prefs.js
	sed "s|https://www.mozilla.org/legal/privacy/|${HOMEPAGE}|" -i "${S}"/browser/app/profile/firefox.js "${S}"/toolkit/content/aboutRights.xhtml
	rm "${S}"/browser/locales/en-US/searchplugins/ddg.xml
	for i in "${WORKDIR}"/gnuzilla/data/searchplugins/* ; do
		cp "${i}" "${S}"/browser/locales/en-US/searchplugins
		echo "$(basename "${i%.xml}")" >> "${S}"/browser/locales/en-US/searchplugins/list.txt
		cp "${i}" "${S}"/mobile/locales/en-US/searchplugins
		echo "$(basename "${i%.xml}")" >> "${S}"/mobile/locales/en-US/searchplugins/list.txt
	done
	for i in base/content/newtab/newTab.css themes/linux/newtab/newTab.css themes/windows/newtab/newTab.css themes/osx/newtab/newTab.css ; do
		echo '#newtab-customize-button, #newtab-intro-what{display:none}' >> "${S}/browser/${i}"
	done
	sed '/Promo2.iOSBefore/,/mobilePromo2.iOSLink/d' -i "${S}"/browser/components/preferences/in-content/sync.xul
	sed 's|www.mozilla.org/firefox/android.*sync-preferences|f-droid.org/repository/browse/?fdid=org.gnu.icecat|' -i "${S}"/browser/components/preferences/in-content/sync.xul
	rm -rf "${S}"/{browser,mobile/android}/branding/*
	cp "${FILESDIR}"/identity-icons-brand.svg "${WORKDIR}"/gnuzilla/data/branding/icecat/content
	echo "  content/branding/identity-icons-brand.svg" >> "${WORKDIR}"/gnuzilla/data/branding/icecat/content/jar.mn
	cp -a "${WORKDIR}"/gnuzilla/data/branding/icecat "${S}"/browser/branding/official
	cp -a "${WORKDIR}"/gnuzilla/data/branding/icecat "${S}"/browser/branding/unofficial
	cp -a "${WORKDIR}"/gnuzilla/data/branding/icecat "${S}"/browser/branding/nightly
	cp -a "${WORKDIR}"/gnuzilla/data/branding/icecatmobile "${S}"/mobile/android/branding/official
	cp -a "${WORKDIR}"/gnuzilla/data/branding/icecatmobile "${S}"/mobile/android/branding/unofficial
	cp -a "${WORKDIR}"/gnuzilla/data/branding/icecatmobile "${S}"/mobile/android/branding/nightly
	rm -rf "${S}"/browser/base/content/abouthome
	cp -a "${WORKDIR}"/gnuzilla/data/abouthome "${S}"/browser/base/content
	sed '/mozilla.*png/d' -i "${S}"/browser/base/jar.mn
	sed '/abouthome/s/*/ /' -i "${S}"/browser/base/jar.mn
	cp "${WORKDIR}"/gnuzilla/data/bookmarks.html.in "${S}"/browser/locales/generic/profile
	for i in community.end3 community.exp.end community.start2 community.mozillaLink community.middle2 community.creditsLink \
	community.end2 contribute.start contribute.getInvolvedLink contribute.end channel.description.start channel.description.end ; do
		find "${WORKDIR}/${MOZ_P}"*/* -name aboutDialog.dtd -exec sed -i "s|\(ENTITY ${i}\).*|\1 \"\">|" {} +
	done
	for i in rights.intro-point3-unbranded rights.intro-point4a-unbranded rights.intro-point4b-unbranded rights.intro-point4c-unbranded ; do
		find "${WORKDIR}/${MOZ_P}"*/* -name aboutRights.dtd -exec sed -i "s|\(ENTITY ${i}\).*|\1 \"\">|" {} +
	done
	sed -i '/helpus\.start/d' "${S}"/browser/base/content/aboutDialog.xul
	cp "${WORKDIR}"/gnuzilla/data/aboutRights.xhtml "${S}"/toolkit/content/aboutRights.xhtml
	cp "${WORKDIR}"/gnuzilla/data/aboutRights.xhtml "${S}"/toolkit/content/aboutRights-unbranded.xhtml
	cp "${WORKDIR}"/gnuzilla/data/branding/sync.png "${S}"/browser/themes/shared/fxa/logo.png
	find "${WORKDIR}/${MOZ_P}"*/* -type d -name firefox -exec rename firefox icecat {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type d -name firefox-ui -exec rename firefox icecat {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type d -name \*firefox\* -exec rename firefox icecat {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type f -name \*firefox\* -exec rename firefox icecat {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type f -name \*Firefox\* -exec rename Firefox IceCat {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type d -name \*fennec\* -exec rename fennec icecatmobile {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type f -name \*fennec\* -exec rename fennec icecatmobile {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type f -name \*Fennec\* -exec rename Fennec IceCatMobile {} +
	find "${WORKDIR}/${MOZ_P}"*/* -type f -name run-mozilla.sh -execdir mv {} run-icecat.sh \;
	find "${WORKDIR}/${MOZ_P}"*/* -type f -not -iregex '.*changelog.*' -not -iregex '.*copyright.*' -execdir sed --follow-symlinks -i "
		s|marketplace\.firefox\.com|f-droid.org/repository/browse|;
		s|org\.mozilla\.firefox|org.gnu.icecat|;
		s|Adobe Flash|Flash|;
		s|addons\.mozilla\.org.*/mobile|directory.fsf.org/wiki/GNU_IceCat|;
		s|addons\.mozilla\.org.*/android|directory.fsf.org/wiki/GNU_IceCat|;
		s|support\.mozilla\.org.*/mobile|libreplanet.org/wiki/Group:IceCat/icecat-help|;
		s|run-mozilla\.sh|run-icecat.sh|;
		s|mozilla-bin|icecat-bin|;
		s|Firefox Marketplace|F-droid free software repository|;
		s|https*://www\.mozilla\.com/plugincheck|${HOMEPAGE}/addons.html|;
		s|ww*3*\.mozilla\.com/plugincheck|${HOMEPAGE}/addons.html|;
		s|mozilla\.com/plugincheck|${HOMEPAGE}/addons.html|;
		s|\"https://www\.mozilla\.com/legay/privacy.*\"|\"${HOMEPAGE}\"|;
		s|https://www\.mozilla\.com/legay/privacy|${HOMEPAGE}|;

		s|Mozilla Firefox|GNU IceCat|;
		s|Mozilla Firefox|GNU IceCat|;
		s|firefox|icecat|;
		s|firefox|icecat|;
		s|fennec|icecatmobile|;
		s|fennec|icecatmobile|;
		s|Firefox|IceCat|;
		s|Firefox|IceCat|;
		s|Fennec|IceCatMobile|;
		s|Fennec|IceCatMobile|;
		s|FIREFOX|ICECAT|;
		s|FIREFOX|ICECAT|;
		s|FENNEC|ICECATMOBILE|;
		s|FENNEC|ICECATMOBILE|;
		s| Mozilla | GNU |;
		s| Mozilla | GNU |;

		s|GNU Public|Mozilla Public|;
		s|GNU Foundation|Mozilla Foundation|;
		s|GNU Corporation|Mozilla Corporation|;
		s|icecat.com|firefox.com|;
		s|IceCat-Spdy|Firefox-Spdy|;
		s|icecat-accounts|firefox-accounts|;
		s|IceCatAccountsCommand|FirefoxAccountsCommand|;
		s|https://www.mozilla.org/icecat/?utm_source=synceol|https://www.mozilla.org/firefox/?utm_source=synceol|;
	" "{}" ";"
	cat "${WORKDIR}"/gnuzilla/data/settings.js >> "${S}"/browser/app/profile/icecat.js
	cat "${WORKDIR}"/gnuzilla/data/settings.js >> "${S}"/mobile/android/app/mobile.js

        favicon="${WORKDIR}"/gnuzilla/data/branding/icecat/icecat.ico
        jpglogo="${WORKDIR}"/gnuzilla/data/../artwork/icecat.jpg
        ff256="${WORKDIR}"/gnuzilla/data/branding/icecat/default256.png
        ff128="${WORKDIR}"/gnuzilla/data/branding/icecat/mozicon128.png
        ff64="${WORKDIR}"/gnuzilla/data/branding/icecat/content/icon64.png
        ff48="${WORKDIR}"/gnuzilla/data/branding/icecat/default48.png
        ff32="${WORKDIR}"/gnuzilla/data/branding/icecat/default32.png
        ff24="${WORKDIR}"/gnuzilla/data/branding/icecat/default24.png
        ff22="${WORKDIR}"/gnuzilla/data/branding/icecat/default22.png
        ff16="${WORKDIR}"/gnuzilla/data/branding/icecat/default16.png
        gf300="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-xhdpi/icon_home_empty_icecat.png
        gf225="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-hdpi/icon_home_empty_icecat.png
        gf150="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-mdpi/icon_home_empty_icecat.png
        gf32="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-xhdpi/ic_status_logo.png
        gf24="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-hdpi/ic_status_logo.png
        gf16="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-mdpi/ic_status_logo.png
        wf24="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-mdpi-v11/ic_status_logo.png
        wf48="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-xhdpi-v11/ic_status_logo.png
        wf36="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-hdpi-v11/ic_status_logo.png
        ma50="${WORKDIR}"/gnuzilla/data/android-images/core/marketplace-logo.png
        ma128="${WORKDIR}"/gnuzilla/data/android-images/resources/drawable-mdpi/marketplace.png

        cp "${ff64}"  "${S}"/devtools/client/framework/dev-edition-promo/dev-edition-logo.png
        cp "${ff128}" "${S}"/mobile/android/base/resources/raw/bookmarkdefaults_favicon_support.png
        cp "${favicon}" "${S}"/addon-sdk/source/examples/toolbar-api/data/favicon.ico
        cp "${gf32}" "${S}"/browser/themes/shared/icon.png
        cp "${gf150}" "${S}"/mobile/android/base/resources/drawable-hdpi/icon_search_empty_icecat.png
        cp "${gf150}" "${S}"/mobile/android/base/resources/drawable-xhdpi/icon_search_empty_icecat.png
        cp "${gf150}" "${S}"/mobile/android/base/resources/drawable-xxhdpi/icon_search_empty_icecat.png
        cp "${gf32}" "${S}"/browser/themes/shared/theme-switcher-icon.png
        cp "${gf32}" "${S}"/browser/themes/shared/heme-switcher-icon@2x.png
        cp "${gf32}" "${S}"/browser/base/content/aboutaccounts/images/fox.png
        cp "${ff256}" "${S}"/browser/extensions/loop/chrome/content/shared/img/icecat-logo.png
        cp "${ff256}" "${S}"/browser/extensions/loop/chrome/content/shared/img/icecat-hello_logo.png

        cp "${ff16}" "${S}"/dom/canvas/test/crossorigin/image.png
        cp "${ff16}" "${S}"/image/test/unit/image1.png
        cp "${jpglogo}"  "${S}"/image/test/unit/image1png16x16.jpg
        cp "${jpglogo}"  "${S}"/image/test/unit/image1png64x64.jpg
        cp "${ff16}" "${S}"/image/test/unit/image2jpg16x16.png
        cp "${ff16}" "${S}"/image/test/unit/image2jpg16x16-win.png
        cp "${ff32}" "${S}"/image/test/unit/image2jpg32x32.png
        cp "${ff32}" "${S}"/image/test/unit/image2jpg32x32-win.png
        cp "${ff16}" "${S}"/dom/canvas/test/crossorigin/image-allow-credentials.png
        cp "${ff16}" "${S}"/dom/html/test/image-allow-credentials.png
        cp "${ff16}" "${S}"/dom/canvas/test/crossorigin/image-allow-star.png
        cp "${ff32}" "${S}"/toolkit/webapps/tests/data/icon.png
        cp "${ff16}" "${S}"/toolkit/components/places/tests/favicons/expected-favicon-big32.jpg.png
        cp "${ff16}" "${S}"/toolkit/components/places/tests/favicons/expected-favicon-big64.png.png
        cp "${jpglogo}"  "${S}"/toolkit/components/places/tests/favicons/favicon-big32.jpg
        cp "${ff64}" "${S}"/toolkit/components/places/tests/favicons/favicon-big64.png
        cp "${favicon}" "${S}"/image/test/unit/image4gif16x16bmp24bpp.ico
        cp "${favicon}" "${S}"/image/test/unit/image4gif16x16bmp32bpp.ico
        cp "${favicon}" "${S}"/image/test/unit/image4gif32x32bmp24bpp.ico
        cp "${favicon}" "${S}"/image/test/unit/image4gif32x32bmp32bpp.ico
        cp "${jpglogo}" "${S}"/image/test/unit/image1png16x16.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg16x16cropped.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg16x16cropped2.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg16x32cropped3.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg16x32scaled.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg32x16cropped4.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg32x16scaled.jpg
        cp "${jpglogo}" "${S}"/image/test/unit/image2jpg32x32.jpg
        cp "${ff32}" "${S}"/image/test/unit/image2jpg32x32.png
        cp "${ff32}" "${S}"/image/test/unit/image2jpg32x32-win.png

	for x in "${mozlinguas[@]}" ; do
		for i in "${WORKDIR}/${MOZ_P}-${x}${MOZ_LANGPACK_UNOFFICIAL:+.unofficial}"/browser/chrome/${x}/locale/branding/brand.{dtd,properties} ; do
			sed -i 's/\(trademarkInfo.part1\s*"\).*\(">\)/\1\2/' "${i}" || die
		done
	done

	eautoreconf

	# Must run autoconf in js/src
	cd "${S}"/js/src || die
	eautoconf

	# Need to update jemalloc's configure
	cd "${S}"/memory/jemalloc/src || die
	WANT_AUTOCONF= eautoconf
}

src_configure() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS="default"
	# Google API keys (see http://www.chromium.org/developers/how-tos/api-keys)
	# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
	# get your own set of keys.
	_google_api_key=AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	# We want rpath support to prevent unneeded hacks on different libc variants
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}"

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# Add full relro support for hardened
	use hardened && append-ldflags "-Wl,-z,relro,-z,now"

	# Only available on mozilla-overlay for experimentation -- Removed in Gentoo repo per bug 571180
	#use egl && mozconfig_annotate 'Enable EGL as GL provider' --with-gl-provider=EGL

	# Setup api key for location services
	echo -n "${_google_api_key}" > "${S}"/google-api-key
	mozconfig_annotate '' --with-google-api-keyfile="${S}/google-api-key"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	# Allow for a proper pgo build
	if use pgo; then
		echo "mk_add_options PROFILE_GEN_SCRIPT='\$(PYTHON) \$(OBJDIR)/_profile/pgo/profileserver.py'" >> "${S}"/.mozconfig
	fi

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	# workaround for funky/broken upstream configure...
	emake -f client.mk configure
}

src_compile() {
	if use pgo; then
		addpredict /root
		addpredict /etc/gconf
		# Reset and cleanup environment variables used by GNOME/XDG
		gnome2_environment_reset

		# Firefox tries to use dri stuff when it's run, see bug 380283
		shopt -s nullglob
		cards=$(echo -n /dev/dri/card* | sed 's/ /:/g')
		if test -z "${cards}"; then
			cards=$(echo -n /dev/ati/card* /dev/nvidiactl* | sed 's/ /:/g')
			if test -n "${cards}"; then
				# Binary drivers seem to cause access violations anyway, so
				# let's use indirect rendering so that the device files aren't
				# touched at all. See bug 394715.
				export LIBGL_ALWAYS_INDIRECT=1
			fi
		fi
		shopt -u nullglob
		addpredict "${cards}"

		CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
		MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		virtx emake -f client.mk profiledbuild || die "virtx emake failed"
	else
		CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
		MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		emake -f client.mk realbuild
	fi

}

src_install() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	cd "${BUILD_OBJ_DIR}" || die

	# Add our default prefs for firefox
	cp "${FILESDIR}"/gentoo-default-prefs.js-1 \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	mozconfig_install_prefs \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js"

	# Augment this with hwaccel prefs
	if use hwaccel ; then
		cat "${FILESDIR}"/gentoo-hwaccel-prefs.js-1 >> \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die
	fi

	echo "pref(\"extensions.autoDisableScopes\", 3);" >> \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	local plugin
	use gmp-autoupdate || for plugin in \
	gmp-gmpopenh264 ; do
		echo "pref(\"media.${plugin}.autoupdate\", false);" >> \
			"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
			|| die
	done

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake DESTDIR="${D}" install

	# Install language packs
	mozlinguas_src_install

	# Install extensions
	for x in "${WORKDIR}"/gnuzilla/data/extensions/* ; do
		xpi_install "${x}"
	done

		# Override preferences to set the MOZ_DEV_EDITION defaults, since we
		# don't define MOZ_DEV_EDITION to avoid profile debaucles.
		# (source: browser/app/profile/firefox.js)
		cat >>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" <<PROFILE_EOF
pref("app.feedback.baseURL", "https://input.mozilla.org/%LOCALE%/feedback/firefoxdev/%VERSION%/");
sticky_pref("lightweightThemes.selectedThemeID", "firefox-devedition@mozilla.org");
sticky_pref("browser.devedition.theme.enabled", true);
sticky_pref("devtools.theme", "dark");
PROFILE_EOF

		sizes="16 22 24 32 48 256"
		icon_path="${S}/browser/branding/official"
		icon="${PN}"
		name="GNU IceCat"

	# Install icons and .desktop for menu entry
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png"
	done
	# The 128x128 icon has a different name
	insinto "/usr/share/icons/hicolor/128x128/apps"
	newins "${icon_path}/mozicon128.png" "${icon}.png"
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${icon_path}/content/icon48.png" "${icon}.png"
	newmenu "${FILESDIR}/icon/${PN}.desktop" "${PN}.desktop"
	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
		"${ED}/usr/share/applications/${PN}.desktop" || die

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true"\
			 >> "${ED}/usr/share/applications/${PN}.desktop" \
			|| die
	fi

	# Required in order to use plugins and even run firefox on hardened, with jit useflag.
	if use jit; then
		pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{firefox,firefox-bin,plugin-container}
	else
		pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/plugin-container
	fi

	# very ugly hack to make firefox not sigbus on sparc
	# FIXME: is this still needed??
	use sparc && { sed -e 's/Firefox/FirefoxGentoo/g' \
					 -i "${ED}/${MOZILLA_FIVE_HOME}/application.ini" \
					|| die "sparc sed failed"; }
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}