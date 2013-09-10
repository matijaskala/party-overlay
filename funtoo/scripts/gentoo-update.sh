#!/bin/bash

eval `keychain --noask --eval id_dsa`  || exit 1

# This is the rsync mirror where we grab Portage updates from...
src=rsync://rsync.at.gentoo.org/gentoo-portage/

# This is the target directory for our updates...
dst=/var/git/portage-gentoo/
if [ ! -e $dst ]; then
	install -d /var/git/portage-gentoo || exit 1
fi
cd $dst || exit 1

# Make sure the gentoo.org branch is active...
#git checkout gentoo.org || exit 1
# Now, use rsync to write new changes directly on top of our working files. New files will be added, deprecated files will be deleted.
rsync --recursive --links --safe-links --perms --times --compress --force --whole-file --delete --timeout=180 --exclude=/.git --exclude=/metadata/cache/ --exclude=/distfiles --exclude=/local --exclude=/packages $src $dst || exit 1
# We want to make extra-sure that we don't grab any metadata, since we don't keep metadata for the gentoo.org tree (space reasons)
[ -e metadata/cache ] && rm -rf metadata/cache
[ -e metadata/md5-cache ] && rm -rf metadata/md5-cache
# the rsync command wiped our critical .gitignore file, so recreate it.
echo "distfiles/*" > $dst/.gitignore || exit 2
echo "packages/*" >> $dst/.gitignore || exit 3
# "git add ." will record all the changes to local files the git repo. So there must be no stray files.
if [ ! -d profiles/package.mask ]
then
	mv profiles/package.mask profiles/package.mask.bak || exit 4
	install -d profiles/package.mask || exit 4
	mv profiles/package.mask.bak profiles/package.mask/gentoo || exit 4
fi
#git add . || exit 1
# create a commit
#git commit -a -m "gentoo.org updates `date` update" || exit 1
# now, push these changes up.
#git push origin gentoo.org || exit 1
exit 0
