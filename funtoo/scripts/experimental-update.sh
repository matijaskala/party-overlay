#!/bin/bash
eval `keychain --noask --eval id_dsa`  || exit 1
cd ../..
# get latest merge.py and friends
git pull || exit 1
./funtoo/scripts/merge.py --branch experimental /var/git/experimental-mini-2011 || exit 1
