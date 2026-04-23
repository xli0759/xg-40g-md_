#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# =====================================================
# 针对 QiuSimons/luci-app-daed 的核心处理逻辑
# =====================================================

echo "pnpm 版本: $(pnpm --version)"

# 7. 清理官方 feeds 中旧的或冲突的 dae/daed 组件
rm -rf feeds/packages/net/dae
rm -rf feeds/packages/net/daed
rm -rf feeds/luci/applications/luci-app-dae
rm -rf feeds/luci/applications/luci-app-daed

# 8. 获取 QiuSimons 的 luci-app-daed 源码
# 官方 README 明确指定克隆到 package/dae，保持原样
git clone https://github.com/QiuSimons/luci-app-daed package/dae
git clone https://github.com/QiuSimons/vmlinux-btf package/vmlinux-btf

# 9. 修改内核参数以满足 DAE 的要求

# (1) 禁用 DEBUG_INFO_REDUCED（.config 中存在 =y，需要改为 not set）
#     官方文档要求设为 n，OpenWrt .config 语法中 =n 无效，
#     正确做法是先删除再追加 not set 注释
sed -i '/CONFIG_KERNEL_DEBUG_INFO_REDUCED/d' .config
echo "# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set" >> .config

# (2) 追加全部必需的内核与包配置
#     .config 中已有：CONFIG_KERNEL_DEBUG_INFO=y / CONFIG_KERNEL_CGROUPS=y /
#     CONFIG_KERNEL_CGROUP_BPF=y，追加不会冲突（后出现的值生效）
cat >> .config <<EOF
# 内核 eBPF / BTF 刚需选项（daed 要求）
CONFIG_DEVEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
# 编译 daed 核心、vmlinux-btf 外部 BTF 包与 LuCI 控制面板
CONFIG_PACKAGE_vmlinux-btf=y
CONFIG_PACKAGE_daed=y
CONFIG_PACKAGE_luci-app-daed=y
CONFIG_PACKAGE_luci-i18n-daed-zh-cn=y
EOF

echo "精简与 daed 配置完成！"
