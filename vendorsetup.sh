# Apply the device-specific minui DRM fix if it has not been applied yet.
# The Unisoc DRM driver on arctic rejects atomic commits (-EINVAL), which
# leaves the panel showing the bootloader splash.  TWRP's legacy
# drmModeSetCrtc path works on this platform.
TOP="${ANDROID_BUILD_TOP:-$PWD}"
if [ -d "$TOP/bootable/recovery/minuitwrp" ]; then
    if ! grep -q "drmModeSetCrtc(drm_fd, crtc->crtc_id" \
            "$TOP/bootable/recovery/minuitwrp/graphics_drm.cpp" 2>/dev/null; then
        git -C "$TOP/bootable/recovery" apply \
            "$TOP/device/xiaomi/arctic/patches/0001-minuitwrp-use-legacy-drm-modeset.patch" \
            || echo "warning: failed to apply arctic DRM fix"
    fi
fi

add_lunch_combo twrp_arctic-user
add_lunch_combo twrp_arctic-userdebug
add_lunch_combo twrp_arctic-eng
