#!/bin/bash
# createTweakPackages.command
#
# 编译成功后运行，基于 LatestBuild 产物生成 Release 所需的发布文件：
#   - WeiboMApp_{目标App版本}.v{Tweak版本}.ipa （由 createIPA.command 生成的 Target.ipa 重命名）
#   - {PACKAGE_ID}_{Tweak版本}_iphoneos-arm64_rootless.deb （无根越狱）
#   - {PACKAGE_ID}_{Tweak版本}_iphoneos-arm_rootful.deb （有根越狱）
#   - {PACKAGE_ID}_{Tweak版本}_iphoneos-arm_TrollStore.zip （TrollStore 手动注入）
#
# 产物输出到 LatestBuild/TweakPackages/ 目录

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------- 发布配置（每次发版按需修改） ----------------
PACKAGE_ID="com.bitxeno.weiboMAppTweak"
TWEAK_NAME="WeiboMAppTweak"
TWEAK_VERSION="${TWEAK_VERSION:-1.0.0}"   # CI 中通过环境变量传入 tag 名
FILTER_BUNDLE_ID="com.weibo.international"
TARGET_APP_PLIST="${DIR}/WeiboMApp/TargetApp/WeiboOverseas.app/Info.plist"
# --------------------------------------------------------------

LATEST="${DIR}/LatestBuild"
DYLIB="${LATEST}/libWeiboMAppDylib.dylib"
IPA="${LATEST}/Target.ipa"
OUT="${LATEST}/TweakPackages"
WORK="${OUT}/.work"

function run {
	echo "Executing command: $@"
	$@
	if [[ $? != "0" ]]; then
		echo "Executing the above command has failed!"
		exit 1
	fi
}

function run_at {
	pushd $1
	shift
	run $@
	popd
}

echo "==================MonkeyDev(create tweak packages...)=================="

if [[ ! -f "${DYLIB}" ]]; then
	echo "未找到编译产物 ${DYLIB}，请先编译成功后运行本脚本！"
	exit 1
fi

TARGET_APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${TARGET_APP_PLIST}")
echo "目标App版本: ${TARGET_APP_VERSION}，Tweak版本: ${TWEAK_VERSION}"

run "rm -rf ${OUT}"
run "mkdir -p ${OUT} ${WORK}"

# ---------------- 1. tweak dylib：修正 install name 并 ad-hoc 签名 ----------------
run "cp ${DYLIB} ${WORK}/${TWEAK_NAME}.dylib"
install_name_tool -id "@rpath/${TWEAK_NAME}.dylib" "${WORK}/${TWEAK_NAME}.dylib"
run "codesign -f -s - --timestamp=none ${WORK}/${TWEAK_NAME}.dylib"

# ---------------- 2. filter plist：限定注入目标 App ----------------
cat > "${WORK}/${TWEAK_NAME}.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.org/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Filter</key>
	<dict>
		<key>Bundles</key>
		<array>
			<string>${FILTER_BUNDLE_ID}</string>
		</array>
	</dict>
</dict>
</plist>
EOF
run "plutil -lint ${WORK}/${TWEAK_NAME}.plist"

# ---------------- 3. deb 打包（$1=架构 $2=data路径 $3=输出deb） ----------------
# 用 python3 按 GNU ar 格式拼装 deb：
# 不同版本的 ar（如新版 cctools 会自动执行 ranlib）会把非 Mach-O 成员丢弃，导致 deb 损坏
function make_deb_ar {
	python3 - "$1" debian-binary control.tar.gz data.tar.gz <<'PYEOF'
import sys
out, members = sys.argv[1], sys.argv[2:]
with open(out, 'wb') as f:
    f.write(b'!<arch>\n')
    for m in members:
        data = open(m, 'rb').read()
        name = m if len(m) < 16 else m[:15]
        hdr = '{:<16}{:<12}{:<6}{:<6}{:<8}{:<10}'.format(
            name, '0', '0', '0', '644', str(len(data))).encode()
        f.write(hdr + b'`\n' + data)
        if len(data) % 2:
            f.write(b'\n')
PYEOF
}

function make_deb {
	local arch=$1 subpath=$2 deb=$3
	rm -rf "${WORK}/deb"
	mkdir -p "${WORK}/deb/control" "${WORK}/deb/data/${subpath}"
	cat > "${WORK}/deb/control/control" <<EOF
Package: ${PACKAGE_ID}
Name: ${TWEAK_NAME}
Version: ${TWEAK_VERSION}
Description: 去除微博国际版(轻享版)广告插件
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000)
Priority: optional
Author: bitxeno
Maintainer: bitxeno
Homepage: https://github.com/bitxeno/WeiboMApp
Architecture: ${arch}
EOF
	run "cp ${WORK}/${TWEAK_NAME}.dylib ${WORK}/${TWEAK_NAME}.plist ${WORK}/deb/data/${subpath}/"
	run tar czf "${WORK}/deb/control.tar.gz" -C "${WORK}/deb/control" control
	run tar czf "${WORK}/deb/data.tar.gz" -C "${WORK}/deb/data" "${subpath%%/*}"
	echo "2.0" > "${WORK}/deb/debian-binary"
	rm -f "${deb}"
	run_at "${WORK}/deb" make_deb_ar "${deb}"
	echo "生成 ${deb}"
}

make_deb "iphoneos-arm64" "var/jb/Library/MobileSubstrate/DynamicLibraries" "${OUT}/${PACKAGE_ID}_${TWEAK_VERSION}_iphoneos-arm64_rootless.deb"
make_deb "iphoneos-arm" "Library/MobileSubstrate/DynamicLibraries" "${OUT}/${PACKAGE_ID}_${TWEAK_VERSION}_iphoneos-arm_rootful.deb"

# ---------------- 4. TrollStore zip ----------------
TS_DIR_NAME="${PACKAGE_ID}_${TWEAK_VERSION}_iphoneos-arm_TrollStore"
mkdir -p "${WORK}/${TS_DIR_NAME}"
run "cp ${WORK}/${TWEAK_NAME}.dylib ${WORK}/${TS_DIR_NAME}/"
run_at "${WORK}" zip -qr "${OUT}/${TS_DIR_NAME}.zip" "${TS_DIR_NAME}"
echo "生成 ${OUT}/${TS_DIR_NAME}.zip"

# ---------------- 5. ipa 重命名 ----------------
if [[ -f "${IPA}" ]]; then
	run "cp ${IPA} ${OUT}/WeiboMApp_${TARGET_APP_VERSION}.v${TWEAK_VERSION}.ipa"
	echo "生成 ${OUT}/WeiboMApp_${TARGET_APP_VERSION}.v${TWEAK_VERSION}.ipa"
else
	echo "未找到 ${IPA}，请先运行 createIPA.command 生成 Target.ipa"
fi

rm -rf "${WORK}"
echo "==================MonkeyDev(done)=================="
ls -la "${OUT}"

exit;
