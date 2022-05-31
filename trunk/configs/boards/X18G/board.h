/* Mercury X18G */
/* 4 Wan/Lan ports; 2 LEDs(4:sys_green, 3:sys_red); 2 BTNs(8:reset,	21:mesh) */

#define BOARD_PID		"X18G"
#define BOARD_NAME		"X18G"
#define BOARD_DESC		"Mercury X18G Wireless Router/(TP-Link XDR1860)"
#define BOARD_VENDOR_NAME	"Mercury"
#define BOARD_VENDOR_URL	"http://www.mercurycom.com.cn/"
#define BOARD_MODEL_URL		"http://www.mercurycom.com.cn/"
#define BOARD_BOOT_TIME		20
#define BOARD_FLASH_TIME	120

#define  BOARD_GPIO_BTN_RESET 8
#undef  BOARD_GPIO_BTN_WPS
#define BOARD_GPIO_LED_INVERTED		/* LED pins value is inverted (1: LED show, 0: LED hide) */
#undef  BOARD_GPIO_LED_ALL
#undef  BOARD_GPIO_LED_WIFI
#define BOARD_GPIO_LED_WAN	  3
#define BOARD_GPIO_LED_POWER	4
#undef  BOARD_GPIO_LED_LAN
#undef  BOARD_GPIO_LED_USB
#undef  BOARD_GPIO_LED_ROUTER

#undef BOARD_GPIO_PWR_USB_ON
#undef BOARD_GPIO_PWR_USB
#define BOARD_HAS_5G_11AC	1
#define BOARD_HAS_5G_11AX	1
#define BOARD_HAS_2G_11AX	1
#define BOARD_NUM_ANT_5G_TX	2
#define BOARD_NUM_ANT_5G_RX	2
#define BOARD_NUM_ANT_2G_TX	2
#define BOARD_NUM_ANT_2G_RX	2
#define BOARD_NUM_ETH_LEDS	0
#define BOARD_NUM_ETH_EPHY	4
#define BOARD_HAS_EPHY_L1000	1
#define BOARD_HAS_EPHY_W1000	1
