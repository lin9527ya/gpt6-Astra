#!/bin/bash
# 冷咖啡破甲工作台 · deb 卸载后脚本
#
# 对应 build/linux/after-install.sh 注册的 root 感知启动器：只注销真实二进制的
# alternatives 会留下 /usr/bin/<exe> 悬空软链，所以两个候选都要摘掉。
# 后半段为 electron-builder 自带 templates/linux/after-remove.tpl 的副本（v26.15.3）。

if type update-alternatives >/dev/null 2>&1; then
    update-alternatives --remove '${executable}' '/opt/${sanitizedProductName}/${executable}-launcher' || true
    update-alternatives --remove '${executable}' '/opt/${sanitizedProductName}/${executable}' || true
else
    rm -f '/usr/bin/${executable}'
fi

# ---- 以下为 electron-builder 原模板内容 ----

APPARMOR_PROFILE_DEST='/etc/apparmor.d/${executable}'

# Remove and unload apparmor profile.
if [ -f "$APPARMOR_PROFILE_DEST" ]; then
  if apparmor_status --enabled > /dev/null 2>&1; then
    if ! { [ -x '/usr/bin/ischroot' ] && /usr/bin/ischroot; } && hash apparmor_parser 2>/dev/null; then
      apparmor_parser --remove "$APPARMOR_PROFILE_DEST" || true
    fi
  fi
  rm -f "$APPARMOR_PROFILE_DEST"
fi
