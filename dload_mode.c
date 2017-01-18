#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/kallsyms.h>

MODULE_AUTHOR("kayrus");
MODULE_DESCRIPTION("Set Kyocera into dload mode");
MODULE_VERSION("1.0");
MODULE_LICENSE("GPL");

int (*_kc_bootmode_setup)(char *buf) = NULL;
int (*_kc_kbfm_setup)(char *buf) = NULL;
int (*_enable_dload_mode)(char *str) = NULL;
void (*_msm_set_restart_mode)(int mode) = NULL;

static int __init kc_exploit_init(void) {
	// pr_err is used because by default warnings and info messages are suppressed
	pr_err("kc_exploit: module loaded");

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
		pr_err("kc_exploit: kc_kbfm_setup returns: %d\n", _kc_kbfm_setup("f-ksg"));
	}

	_enable_dload_mode = (int (*)(char *str))kallsyms_lookup_name("enable_dload_mode");
	if (_enable_dload_mode == NULL)
		pr_err("kc_exploit: can not find enable_dload_mode() address\n");
	else {
		pr_err("kc_exploit: enable_dload_mode() address found: 0x%p\n", _enable_dload_mode);
		pr_err("kc_exploit: enable_dload_mode returns: %d\n", _enable_dload_mode("true"));
	}

	_msm_set_restart_mode = (void (*)(int mode))kallsyms_lookup_name("msm_set_restart_mode");
	if (_msm_set_restart_mode == NULL)
		pr_err("kc_exploit: can not find set_restart_mode() address\n");
	else {
		pr_err("kc_exploit: msm_set_restart_mode() address found: 0x%p\n", _msm_set_restart_mode);
		pr_err("kc_exploit: set restart_mode = download_mode\n");
		_msm_set_restart_mode(1);
	}

	return 0;
}

void cleanup_module(void) {
	pr_err("kc_exploit: module unloaded\n");
}

module_init(kc_exploit_init)
