subarch: amd64
target: stage1
version_stamp: nomultilib-hardened-fortify3-openrc-20250131T202005Z.bootstrap
rel_type: 23.0-test
repos: /home/portage/storage/gentoo/catalyst/catalyst/portage/overlays/enomem
profile: enomem:default/amd64/no-multilib/hardened/fortify3/stage1
snapshot_treeish: latest.xz
source_subpath: 23.0-default/stage3-amd64-nomultilib-openrc-latest.tar.xz
compression_mode: pixz
#update_seed: no
update_seed: yes
#update_seed_command: --update --deep --newuse --emptytree --complete-graph y --with-bdeps y @world
update_seed_command: --update --deep --newuse --emptytree --complete-graph y --with-bdeps y --usepkg --buildpkg --binpkg-respect-use=y @world
portage_confdir: /home/portage/storage/gentoo/catalyst/catalyst/portage/23-test/stage1
portage_prefix: releng
pkgcache_path: /home/portage/storage/gentoo/catalyst/catalyst/var/tmp/catalyst/packages/23.0-test/hardened/fortify3/stage1-amd64
