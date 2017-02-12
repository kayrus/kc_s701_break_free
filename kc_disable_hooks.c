#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/kallsyms.h>
#include <linux/kmod.h>
#include <linux/security.h>

MODULE_AUTHOR("kayrus");
MODULE_DESCRIPTION("Disable custom Kyocera hooks on KYL22 platform");
MODULE_VERSION("1.0");
MODULE_LICENSE("GPLv2");

void (*_reset_security_ops)(void) = NULL;

static int __init kc_exploit_init(void) {
	// pr_err is used because by default warnings and info messages are suppressed
	pr_err("kc_exploit: module loaded");

	_reset_security_ops = (void (*)(void))kallsyms_lookup_name("reset_security_ops");
	if (_reset_security_ops == NULL)
		pr_err("kc_exploit: can not find reset_security_ops address\n");
	else {
		pr_err("kc_exploit: reset_security_ops() address found: 0x%p\n", _reset_security_ops);
		pr_err("kc_exploit: calling reset_security_ops()\n");
		_reset_security_ops();
	}

	return 0;
}

void cleanup_module(void) {
	pr_err("kc_exploit: module unloaded\n");
}

module_init(kc_exploit_init)
