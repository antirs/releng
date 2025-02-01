subarch: amd64
target: stage4
version_stamp: t440p-nomultilib-hardened-openrc-20250121T185900Z.bootstrap
rel_type: 23.0-enomem
repos: /home/portage/storage/gentoo/catalyst/releases/portage/23-enomem/stage4/overlays/enomem
profile: enomem:devices/notebook/amd64/lenovo/thinkpad/t440p/no-multilib/hardened/stage4
snapshot_treeish: 20241229.xz
source_subpath: 23.0-default/stage3-amd64-nomultilib-openrc-20250121T185900Z.tar.xz
#source_subpath: 23.0-default/stage3-amd64-nomultilib-openrc-latest.tar.xz
compression_mode: pixz
portage_confdir: /home/portage/storage/gentoo/catalyst/releases/portage/23-enomem/stage4
portage_prefix: releng
pkgcache_path: /home/portage/storage/gentoo/catalyst/var/tmp/catalyst/packages/23.0-enomem/t440p/hardened

stage4/packages:
	app-admin/logrotate
	app-admin/rsyslog
	app-editors/nano
	app-editors/vim
	app-misc/tmux
	app-portage/eix
	app-portage/gentoolkit
	dev-util/catalyst
	dev-util/ccache
	dev-util/pkgdev
	sec-policy/selinux-base
	sec-policy/selinux-base-policy
	sys-apps/dbus
	sys-apps/mlocate
	sys-apps/openrc
	sys-boot/grub
	sys-devel/distcc
	sys-fs/dosfstools
	sys-fs/cryptsetup
	sys-kernel/dracut
	sys-kernel/genkernel
	sys-kernel/gentoo-sources
	sys-kernel/installkernel
	sys-kernel/linux-firmware
	sys-boot/os-prober
	sys-process/audit
	sys-process/cronie

boot/kernel: gentoo

boot/kernel/gentoo/config: /home/portage/storage/gentoo/catalyst/releases/kconfig/devices/notebook/amd64/lenovo/thinkpad/t440p/amd64-6.12.7.config
boot/kernel/gentoo/sources: gentoo-sources
boot/kernel/gentoo/dracut_args: --xz --no-hostonly -o crypt -o multipath -I busybox
