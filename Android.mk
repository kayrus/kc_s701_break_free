LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
  disable_security.c

LOCAL_MODULE := disable_security

include $(BUILD_EXECUTABLE)
