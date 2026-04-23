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

# =====================================================
# 1. 安装 eBPF 编译依赖 (修复 llvm-strip-not-found 错误)
# =====================================================
echo "正在安装 clang 和 llvm..."
sudo apt-get update
sudo apt-get install -y clang llvm

# =====================================================
# 2. 配置 ImmortalWrt 官方 daed 核心与内核选项
# =====================================================

# 官方 feed 已经原生包含 daed 和 luci-app-daed，无需另外 git clone。
# 我们直接修改内核参数以满足 eBPF 和 BTF 的要求：

# (1) 禁用 DEBUG_INFO_REDUCED（官方强制要求为 n）
sed -i '/CONFIG_KERNEL_DEBUG_INFO_REDUCED/d' .config
echo "# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set" >> .config

# (2) 追加全部必需的内核选项与依赖包
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

# 编译诊断模块
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y

# 选中官方的 daed 以及对应的 LuCI 控制面板
CONFIG_PACKAGE_daed=y
CONFIG_PACKAGE_luci-app-daed=y
EOF

echo "ImmortalWrt 官方 daed 及内核配置完成！"
echo "精简与 daed 配置完成！"
