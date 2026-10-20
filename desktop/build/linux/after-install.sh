#!/bin/bash
# 冷咖啡破甲工作台 · deb 安装后脚本
#
# 前半段是 electron-builder 自带 templates/linux/after-install.tpl 的副本（v26.15.3），
# 只把 /usr/bin/<exe> 和桌面项的入口换成一个 root 感知的启动器：
# Chromium 拒绝以 root 身份启动（FATAL: Running as root without --no-sandbox is
# not supported），而 --no-sandbox 只能在进程启动前给出，JS 层够不到。
# 启动器只在 uid=0 时补 --no-sandbox，普通用户仍然保留完整沙箱。
#
# 升级 electron-builder 时，请对照 node_modules/app-builder-lib/templates/linux/
# after-install.tpl 同步后半段。

APP_DIR='/opt/${sanitizedProductName}'
APP_BIN="$APP_DIR/${executable}"
LAUNCHER="$APP_DIR/${executable}-launcher"

# 写 root 感知启动器。真实二进制路径不变，AppArmor profile、chrome-sandbox 都不受影响。
cat > "$LAUNCHER" <<'LAUNCHER_EOF'
#!/bin/sh
# 由 deb 安装脚本生成。Chromium 不允许以 root 带沙箱启动，这里只在 uid=0 时补开关。
if [ "$(id -u)" = "0" ]; then
  exec "__APP_BIN__" --no-sandbox "$@"
fi
exec "__APP_BIN__" "$@"
LAUNCHER_EOF
sed -i "s|__APP_BIN__|$APP_BIN|g" "$LAUNCHER" || true
chmod 0755 "$LAUNCHER" || true

# /usr/bin/<exe> 指向启动器；优先级 200 高于真实二进制的 100，升级时也会切过来。
if type update-alternatives >/dev/null 2>&1; then
    if [ -L '/usr/bin/${executable}' -a -e '/usr/bin/${executable}' -a "`readlink '/usr/bin/${executable}'`" != '/etc/alternatives/${executable}' ]; then
        rm -f '/usr/bin/${executable}'
    fi
    update-alternatives --install '/usr/bin/${executable}' '${executable}' "$LAUNCHER" 200 || ln -sf "$LAUNCHER" '/usr/bin/${executable}'
else
    ln -sf "$LAUNCHER" '/usr/bin/${executable}'
fi

# 桌面项也走启动器，菜单里以 root 打开同样能过检查。
DESKTOP_FILE='/usr/share/applications/${executable}.desktop'
if [ -f "$DESKTOP_FILE" ]; then
    # 路径在 .desktop 里只出现在 Exec 行；不依赖引号形式，两种写法都能换。
    sed -i "s|$APP_BIN|/usr/bin/${executable}|g" "$DESKTOP_FILE" || true
fi

# ---- 以下为 electron-builder 原模板内容 ----

# Check if user namespaces are supported by the kernel and working with a quick test:
if ! { [[ -L /proc/self/ns/user ]] && unshare --user true; }; then
    # Use SUID chrome-sandbox only on systems without user namespaces:
    chmod 4755 '/opt/${sanitizedProductName}/chrome-sandbox' || true
else
    chmod 0755 '/opt/${sanitizedProductName}/chrome-sandbox' || true
fi

if hash update-mime-database 2>/dev/null; then
    update-mime-database /usr/share/mime || true
fi

if hash update-desktop-database 2>/dev/null; then
    update-desktop-database /usr/share/applications || true
fi

# Install apparmor profile. (Ubuntu 24+)
if apparmor_status --enabled > /dev/null 2>&1; then
  APPARMOR_PROFILE_SOURCE='/opt/${sanitizedProductName}/resources/apparmor-profile'
  APPARMOR_PROFILE_TARGET='/etc/apparmor.d/${executable}'
  if apparmor_parser --skip-kernel-load --debug "$APPARMOR_PROFILE_SOURCE" > /dev/null 2>&1; then
    cp -f "$APPARMOR_PROFILE_SOURCE" "$APPARMOR_PROFILE_TARGET"
    if ! { [ -x '/usr/bin/ischroot' ] && /usr/bin/ischroot; } && hash apparmor_parser 2>/dev/null; then
      apparmor_parser --replace --write-cache --skip-read-cache "$APPARMOR_PROFILE_TARGET"
    fi
  else
    echo "Skipping the installation of the AppArmor profile as this version of AppArmor does not seem to support the bundled profile"
  fi
fi
