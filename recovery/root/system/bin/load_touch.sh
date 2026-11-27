#!/system/bin/sh
# Load the touch controller that matches the installed display panel.
#
# arctic has shipped with at least three touch controllers:
#   * Chipone ICNL9916x  (dsi_panel_somaliaa_46_0f_0d_hdp_vdo)
#   * Novatek NT36528A  (dsi_panel_somaliaa_36_02_0a / 42_02_0b)
#   * Omnivision TD4160  (dsi_panel_somaliaa_43_10_0c_hdp_vdo, EEA)
#
# lcd_name is passed by the bootloader in /proc/cmdline.  Load the matching
# driver; for an unknown panel fall back to the vendor module order.

insmod /lib/modules/xiaomi_touch.ko
insmod /lib/modules/lct_tp.ko

lcd_name="$(tr ' ' '\n' < /proc/cmdline | sed -n 's/^lcd_name=//p' | head -n1)"

load_td4160() {
    while [ ! -e /odm/firmware/omnivision_ts_truly_fw.img ] && \
          [ ! -e /vendor/firmware/omnivision_ts_truly_fw.img ]; do
        sleep 1
    done
    insmod /lib/modules/td4160_spi.ko
}

case "$lcd_name" in
    *somaliaa_46_0f_0d*)
        insmod /lib/modules/chipone_icnl9916x_spi_ts.ko
        ;;
    *somaliaa_36_02_0a*|*somaliaa_42_02_0b*)
        insmod /lib/modules/novatek_nt36528a_spi_ts.ko
        ;;
    *somaliaa_43_10_0c*)
        load_td4160
        ;;
    *)
        # Unknown panel: try the controllers in the vendor load order.
        insmod /lib/modules/novatek_nt36528a_spi_ts.ko 2>/dev/null
        load_td4160 2>/dev/null
        insmod /lib/modules/chipone_icnl9916x_spi_ts.ko 2>/dev/null
        ;;
esac
