#!/bin/bash

set -e

patches="$(readlink -f -- $1)"

mkdir -p $patches/patches/platform_frameworks_base
#mkdir -p $patches/patches/platform_packages_apps_Settings
cp "$(dirname "$0")"/own_patches/0001-aosp_Fix-patch-Don-t-wake-IR-HAL-to-the-infinity-and-beyo.patch $patches/patches/platform_frameworks_base/0050-aosp_Fix-patch-Don-t-wake-IR-HAL-to-the-infinity-and-beyo.patch
cp "$(dirname "$0")"/own_patches/0002-aosp_Display-headset-icon-by-default.patch $patches/patches/platform_frameworks_base/0051-aosp_Display-headset-icon-by-default.patch
cp "$(dirname "$0")"/own_patches/0003-aosp_Disable-button-backlight.patch $patches/patches/platform_frameworks_base/0052-aosp_Disable-button-backlight.patch
cp "$(dirname "$0")"/own_patches/0004-aosp_Remove-system-error-dialog-on-startup.patch $patches/patches/platform_frameworks_base/0053-aosp_Remove-system-error-dialog-on-startup.patch
cp "$(dirname "$0")"/own_patches/0005-aosp_Use-legacy-camera-api-to-fix-flashlight-in-qs.patch $patches/patches/platform_frameworks_base/0054-aosp_Use-legacy-camera-api-to-fix-flashlight-in-qs.patch

for project in $(cd $patches/patches; echo *);do
	p="$(tr _ / <<<$project |sed -e 's;platform/;;g')"
	[ "$p" == build ] && p=build/make
	repo sync -l --force-sync $p
	pushd $p
	git clean -fdx; git reset --hard
	for patch in $patches/patches/$project/*.patch;do
		#Check if patch is already applied
		if patch -f -p1 --dry-run -R < $patch > /dev/null;then
			continue
		fi

		if git apply --check $patch;then
			git am $patch
		elif patch -f -p1 --dry-run < $patch > /dev/null;then
			#This will fail
			git am $patch || true
			patch -f -p1 < $patch
			git add -u
			git am --continue
		else
			echo "Failed applying $patch"
		fi
	done
	popd
done

