#!/usr/bin/python2

from merge_utils import *

# Progress overlay merge
if not os.path.exists("/usr/bin/svn"):
	print("svn binary not found at /usr/bin/svn. Exiting.")
	sys.exit(1)

gentoo_src = DeadTree("gentoo","/var/git/portage-gentoo")
party_overlay = Tree("party-overlay", branch, "git://github.com/matijaskala/party-overlay.git", pull=True)
funtoo_original_overlay = Tree("funtoo-overlay", branch, "git://github.com/funtoo/funtoo-overlay.git", pull=True)
foo_overlay = Tree("foo-overlay", "master", "https://github.com/slashbeast/foo-overlay.git", pull=True)
bar_overlay = Tree("bar-overlay", "master", "git://github.com/adessemond/bar-overlay.git", pull=True)
squeezebox_overlay = Tree("squeezebox", "master", "git://git.overlays.gentoo.org/user/squeezebox.git", pull=True)
progress_overlay = SvnTree("progress", "https://gentoo-progress.googlecode.com/svn/overlays/progress")
sabayon_for_gentoo = Tree("sabayon-for-gentoo", "master", "git://github.com/Sabayon/for-gentoo.git", pull=True)
mate_overlay = Tree("mate", "master", "git://github.com/Sabayon/mate-overlay.git", pull=True)

funtoo_original_packages = [
	"app-admin/salt",
	"app-backup/rsnapshot",
	"app-crypt/gnupg",
	"app-dicts/dictd-moby-thesaurus",
	"app-editors/sublime-text",
	"app-portage/eix",
	"app-portage/genlop",
	"app-vim/gentoo-syntax",
	"dev-lang/perl",
	"mail-mta/postfix",
	"net-analyzer/zabbix",
	"net-p2p/bittorrent-sync",
	"sys-auth/keystone",
	"sys-auth/keystone-client",
	"sys-boot/boot-update",
	"sys-cluster/glance",
	"sys-cluster/nova",
	"sys-cluster/vzctl",
	"sys-devel/binutils",
	"sys-devel/gcc-config",
	"sys-devel/libtool",
	"sys-kernel/alt-sources",
	"sys-kernel/bliss-initramfs",
	"sys-kernel/bliss-kernel",
	"sys-kernel/debian-sources",
	"sys-kernel/debian-sources-lts",
	"sys-kernel/dkms",
	"sys-kernel/linode-sources",
	"sys-kernel/openvz-rhel5-stable",
	"sys-kernel/openvz-rhel6-stable",
	"sys-kernel/openvz-rhel6-test",
	"sys-kernel/std-sources",
	"sys-kernel/sysrescue-std-sources",
	"sys-kernel/ubuntu-server",
	"sys-kernel/ubuntu-sources",
	"www-client/surf",
	"www-servers/nginx",
	"www-servers/thin",
]

steps = [
	SyncTree(gentoo_src,exclude=["/metadata/cache/**", "CVS", "ChangeLog", "dev-util/metro"]),
	ApplyPatchSeries("%s/funtoo/patches" % party_overlay.root ),
	ThirdPartyMirrors(),
	SyncDir(party_overlay.root, "profiles", exclude=["categories", "default", "repo_name", "updates", "package.mask/party-compat"]),
	MergeUpdates(party_overlay.root),
	ProfileDepFix(),
	SyncDir(party_overlay.root,"licenses"),
	SyncDir(party_overlay.root,"eclass"),
	SyncDir(party_overlay.root,"metadata"),
	SyncFiles(gentoo_src.root, {
		"profiles/arch/amd64/use.mask":"profiles/funtoo/1.0/linux-gnu/arch/x86-64bit/use.mask/01-gentoo",
		"profiles/arch/x86/package.use.mask":"profiles/funtoo/1.0/linux-gnu/arch/x86-32bit/package.use.mask/01-gentoo",
		"profiles/arch/x86/use.mask":"profiles/funtoo/1.0/linux-gnu/arch/x86-32bit/use.mask/01-gentoo",
	}),
	InsertEbuilds(party_overlay, select="all", skip=funtoo_original_packages, replace=True, merge=["sys-apps/systemd", "sys-devel/gcc", "sys-fs/udev"]),
	InsertEbuilds(foo_overlay, select="all", skip=["media-sound/deadbeef", "sys-fs/mdev-bb", "sys-fs/mdev-like-a-boss", "media-video/handbrake"], replace=["app-shells/rssh","net-misc/unison"]),
	InsertEbuilds(bar_overlay, select="all", skip=["app-emulation/qemu"], replace=False),
	InsertEbuilds(mate_overlay, select="all", skip=None, replace=False),
	InsertEbuilds(squeezebox_overlay, select="all", skip=None, replace=False),
	InsertEbuilds(funtoo_original_overlay, select=funtoo_original_packages, skip=None, replace=True),
	SyncDir(mate_overlay.root, "eclass"),
	SyncDir(mate_overlay.root, "sets"),
	SyncFiles(mate_overlay.root, {
		"profiles/package.mask":"profiles/funtoo/1.0/linux-gnu/mix-ins/mate/package.mask",
		"profiles/package.use.mask":"profiles/funtoo/1.0/linux-gnu/mix-ins/mate/package.use.mask"
	}),
	InsertEbuilds(sabayon_for_gentoo, select=["app-admin/equo", "app-admin/matter", "sys-apps/entropy", "sys-apps/entropy-server", "sys-apps/entropy-client-services","app-admin/rigo", "sys-apps/rigo-daemon", "sys-apps/magneto-core", "x11-misc/magneto-gtk", "x11-misc/magneto-gtk3", "kde-misc/magneto-kde", "app-misc/magneto-loader"], replace=True),
	SyncDir(progress_overlay.root, "eclass"),
	SyncDir(progress_overlay.root, "profiles/unpack_dependencies"),
	SyncFiles(progress_overlay.root, {
		"profiles/use.aliases":"profiles/use.aliases/progress",
		"profiles/use.mask":"profiles/use.mask/progress"
	}),
	#InsertEbuilds(progress_overlay, select="all", skip=None, replace=True, merge=["dev-java/guava", "dev-lang/python", "dev-python/psycopg", "dev-python/pysqlite", "dev-python/python-docs", "dev-python/simpletal", "dev-python/wxpython", "dev-util/gdbus-codegen", "x11-libs/vte"]),
	#MergeUpdates(progress_overlay.root),
	#AutoGlobMask("dev-lang/python", "python*_pre*"),
	ApplyPatchSeries("%s/partylinux/patches" % party_overlay.root ),
	Minify(),
	GenCache(),
	GenUseLocalDesc()
]

# work tree is a non-git tree in tmpfs for enhanced performance - we do all the heavy lifting there:

work = UnifiedTree("/var/work/merge-%s" % os.path.basename(dest[0]),steps)
work.run()

steps = [
	GitPrep("funtoo.org"),
	SyncTree(work)
]

# then for the production tree, we rsync all changes on top of our prod git tree and commit:

for d in dest:
	if not os.path.isdir(d):
		os.makedirs(d)
	if not os.path.isdir("%s/.git" % d):
		runShell("( cd %s; git init )" % d )
		runShell("echo 'created by merge.py' > %s/README" % d )
		runShell("( cd %s; git add README; git commit -a -m 'initial commit by merge.py' )" % d )
		runShell("( cd %s; git checkout -b funtoo.org; git rm -f README; git commit -a -m 'initial funtoo.org commit' )" % ( d ) )
		print("Pushing disabled automatically because repository created from scratch.")
		push = False
	prod = UnifiedTree(d,steps)
	prod.run()
	prod.gitCommit(message="updates by Skala",push=push)
