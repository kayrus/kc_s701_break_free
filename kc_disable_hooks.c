#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/kallsyms.h>
#include <linux/kmod.h>
#include <linux/security.h>
#include <linux/netfilter.h>

MODULE_AUTHOR("kayrus");
MODULE_DESCRIPTION("Disable custom Kyocera hooks");
MODULE_VERSION("1.0");
MODULE_LICENSE("GPLv2");

int (*_kc_bootmode_setup)(char *buf) = NULL;
int (*_kc_kbfm_setup)(char *buf) = NULL;
int (*_kclsm_bootmode_setup)(char *buf) = NULL;
int (*_kclsm_kbfm_setup)(char *buf) = NULL;
struct security_operations *_kclsm_security_ops = NULL;
struct security_operations *_selinux_ops = NULL;

struct security_operations tmp_kclsm_security_ops;
struct security_operations tmp_selinux_ops;

// disable selinux pointers
void (*_reset_security_ops)(void) = NULL;

int mount_return_zero(char *dev_name, struct path *path,
                            char *type, unsigned long flags, void *data)
{       
	pr_err("kc_exploit: dummy mount hook has been triggered\n");
        return 0;
}

int umount_return_zero(struct vfsmount *mnt, int flags)
{
	pr_err("kc_exploit: dummy umount hook has been triggered\n");
	return 0;
}

static int __init kc_exploit_init(void) {
	// pr_err is used because by default warnings and info messages are suppressed
	pr_err("kc_exploit: module loaded");

	// trying to find security related functions and call them to disable security hooks
	// * kc_bootmode_setup
	// * kc_kbfm_setup
	// * kclsm_kbfm_setup
	// * kclsm_security_ops
	_kc_bootmode_setup = (int (*)(char *buf))kallsyms_lookup_name("kc_bootmode_setup");
	if (_kc_bootmode_setup == NULL)
		pr_err("kc_exploit: can not find kc_bootmode_setup() address\n");
	else {
		pr_err("kc_exploit: kc_bootmode_setup() address found: 0x%p\n", _kc_bootmode_setup);
		pr_err("kc_exploit: kc_bootmode_setup() returns: %d\n", _kc_bootmode_setup("f-ksg"));
	}
	_kc_kbfm_setup = (int (*)(char *buf))kallsyms_lookup_name("kc_kbfm_setup");
	if (_kc_kbfm_setup == NULL)
		pr_err("kc_exploit: can not find kc_kbfm_setup() address\n");
	else {
		pr_err("kc_exploit: kc_kbfm_setup() address found: 0x%p\n", _kc_kbfm_setup);
		pr_err("kc_exploit: kc_kbfm_setup returns: %d\n", _kc_kbfm_setup("kcfactory"));
	}
	_kclsm_bootmode_setup = (int (*)(char *buf))kallsyms_lookup_name("kclsm_bootmode_setup");
	if (_kclsm_bootmode_setup == NULL)
		pr_err("kc_exploit: can not find kclsm_bootmode_setup() address\n");
	else {
		pr_err("kc_exploit: kclsm_bootmode_setup() address found: 0x%p\n", _kclsm_bootmode_setup);
		pr_err("kc_exploit: kclsm_bootmode_setup() returns: %d\n", _kclsm_bootmode_setup("f-ksg"));
	}
	_kclsm_kbfm_setup = (int (*)(char *buf))kallsyms_lookup_name("kclsm_kbfm_setup");
	if (_kclsm_kbfm_setup == NULL)
		pr_err("kc_exploit: can not find kclsm_kbfm_setup() address\n");
	else {
		pr_err("kc_exploit: kclsm_kbfm_setup() address found: 0x%p\n", _kclsm_kbfm_setup);
		pr_err("kc_exploit: kclsm_kbfm_setup returns: %d\n", _kclsm_kbfm_setup("kcfactory"));
	}

	// trying to find selinux related hook functions and replace them with "return 0;" ones
	_kclsm_security_ops = (struct security_operations *)kallsyms_lookup_name("kclsm_security_ops");
	if (_kclsm_security_ops == NULL)
		pr_err("kc_exploit: can not find kclsm_security_ops address\n");
	else {
		pr_err("kc_exploit: kclsm_security_ops address found: 0x%p\n", _kclsm_security_ops);
		pr_err("kc_exploit: kclsm_security_ops.sb_mount (%pF) address found: 0x%p\n", (*_kclsm_security_ops).sb_mount, (*_kclsm_security_ops).sb_mount);
		pr_err("kc_exploit: kclsm_security_ops.sb_umount (%pF) address found: 0x%p\n", (*_kclsm_security_ops).sb_umount, (*_kclsm_security_ops).sb_umount);
		tmp_kclsm_security_ops.sb_mount = (*_kclsm_security_ops).sb_mount;
		tmp_kclsm_security_ops.sb_umount = (*_kclsm_security_ops).sb_umount;
		pr_err("kc_exploit: setting kclsm_security_ops.sb_mount to return 0\n");
		(*_kclsm_security_ops).sb_mount = mount_return_zero;
		pr_err("kc_exploit: setting kclsm_security_ops.sb_umount to return 0\n");
		(*_kclsm_security_ops).sb_umount = umount_return_zero;
	}

	_selinux_ops = (struct security_operations *)kallsyms_lookup_name("selinux_ops");
	if (_selinux_ops == NULL)
		pr_err("kc_exploit: can not find selinux_ops address\n");
	else {
		pr_err("kc_exploit: selinux_ops address found: 0x%p\n", _selinux_ops);
		pr_err("kc_exploit: selinux_ops.sb_mount (%pF) address found: 0x%p\n", (*_selinux_ops).sb_mount, (*_selinux_ops).sb_mount);
		pr_err("kc_exploit: selinux_ops.sb_umount (%pF) address found: 0x%p\n", (*_selinux_ops).sb_umount, (*_selinux_ops).sb_umount);
		tmp_selinux_ops.sb_mount = (*_selinux_ops).sb_mount;
		tmp_selinux_ops.sb_umount = (*_selinux_ops).sb_umount;
		pr_err("kc_exploit: setting selinux_ops.sb_mount to return 0\n");
		(*_selinux_ops).sb_mount = mount_return_zero;
		pr_err("kc_exploit: setting selinux_ops.sb_umount to return 0\n");
		(*_selinux_ops).sb_umount = umount_return_zero;
	}
/*
	_reset_security_ops = (void (*)(void))kallsyms_lookup_name("reset_security_ops");
	if (_reset_security_ops == NULL)
		pr_err("kc_exploit: can not find reset_security_ops address\n");
	else {
		pr_err("kc_exploit: reset_security_ops() address found: 0x%p\n", _reset_security_ops);
		pr_err("kc_exploit: calling reset_security_ops()\n");
		_reset_security_ops();
	}
*/

	return 0;
}

void cleanup_module(void) {
	if (_kclsm_security_ops != NULL) {
		pr_err("kc_exploit: restoring original kclsm_security_ops pointers\n");
		(*_kclsm_security_ops).sb_mount = tmp_kclsm_security_ops.sb_mount;
		(*_kclsm_security_ops).sb_umount = tmp_kclsm_security_ops.sb_umount;
	}
	if (_selinux_ops != NULL) {
		pr_err("kc_exploit: restoring original selinux_ops pointers\n");
		(*_selinux_ops).sb_mount = tmp_selinux_ops.sb_mount;
		(*_selinux_ops).sb_umount = tmp_selinux_ops.sb_umount;
	}

	pr_err("kc_exploit: module unloaded\n");
}

module_init(kc_exploit_init)
