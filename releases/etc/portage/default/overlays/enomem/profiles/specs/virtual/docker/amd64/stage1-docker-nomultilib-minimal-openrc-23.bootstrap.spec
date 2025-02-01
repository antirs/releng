subarch: amd64
target: stage1
version_stamp: docker-nomultilib-minimal-openrc-20250121T185900Z
rel_type: 23.0-enomem
repos: /home/portage/storage/gentoo/catalyst/releases/portage/23-enomem/stage1/overlays/enomem
profile: enomem:virtual/docker/amd64/no-multilib/minimal/stage1
snapshot_treeish: 20241229.xz
source_subpath: 23.0-default/stage3-amd64-nomultilib-openrc-20250121T185900Z.tar.xz
#source_subpath: 23.0-default/stage3-amd64-nomultilib-openrc-latest.tar.xz
compression_mode: pixz
update_seed: yes
#update_seed: no
update_seed_command: --update --deep --newuse --emptytree --complete-graph y --with-bdeps y --buildpkg --usepkg --binpkg-respect-use y @world
#update_seed_command: --update --deep --newuse --emptytree --complete-graph y --with-bdeps y @world
portage_confdir: /home/portage/storage/gentoo/catalyst/releases/portage/23-enomem/stage1
portage_prefix: releng
pkgcache_path: /home/portage/storage/gentoo/catalyst/var/tmp/catalyst/packages/docker
