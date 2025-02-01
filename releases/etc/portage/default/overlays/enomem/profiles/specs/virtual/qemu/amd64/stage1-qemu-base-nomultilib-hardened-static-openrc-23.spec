subarch: amd64
target: stage1
version_stamp: qemu-base-nomultilib-hardened-static-openrc-20250121T185900Z
rel_type: 23.0-enomem
repos: /home/portage/storage/gentoo/catalyst/releases/portage/23-enomem/stage1/overlays/enomem
profile: enomem:virtual/qemu/amd64/base/no-multilib/hardened/static/stage1
snapshot_treeish: 20241229.xz
source_subpath: 23.0-enomem/stage3-amd64-qemu-base-nomultilib-hardened-static-openrc-20250121T185900Z.bootstrap.tar.xz
#source_subpath: 23.0-enomem/stage3-amd64-qemu-base-nomultilib-hardened-static-openrc-latest.bootstrap.tar.xz
compression_mode: pixz
#update_seed: no
update_seed: yes
#update_seed_command: --update --deep --newuse --emptytree --complete-graph y --with-bdeps y @world
update_seed_command: --update --deep --newuse --complete-graph y --with-bdeps y --usepkg --buildpkg --binpkg-respect-use=y @world
portage_confdir: /home/portage/storage/gentoo/catalyst/releases/portage/23-enomem/stage1
portage_prefix: releng
pkgcache_path: /home/portage/storage/gentoo/catalyst/var/tmp/catalyst/packages/qemu/hardened
