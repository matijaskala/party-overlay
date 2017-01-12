party-overlay
=============
To add this overlay edit the following files:


/etc/portage/package.mask:

```
sys-apps/portage::party-overlay
```

/etc/portage/repos.conf:

```
[party-overlay]
location = /usr/local/overlay/party-overlay
sync-type = git
sync-uri = git://github.com/matijaskala/party-overlay.git
auto-sync = yes
```

Then execute `emaint sync -r party-overlay`
