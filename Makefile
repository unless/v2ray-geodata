#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-geodata
PKG_VERSION:=$(shell date "+%Y.%m.%d")
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sbwml <admin@cooluc.com>

include $(INCLUDE_DIR)/package.mk

define Package/v2ray-geodata/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://www.v2fly.org
  PKGARCH:=all
endef

define Package/v2ray-geoip
  $(call Package/v2ray-geodata/default)
  TITLE:=GeoIP List for V2Ray
  LICENSE:=CC-BY-SA-4.0
endef

define Package/v2ray-geosite
  $(call Package/v2ray-geodata/default)
  TITLE:=Geosite List for V2Ray
  LICENSE:=GPL-3.0
endef

define Package/v2ray-geoip-asn
  $(call Package/v2ray-geodata/default)
  TITLE:=GeoIP ASN List for V2Ray
  LICENSE:=CC-BY-SA-4.0
endef

GEOIP_URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
GEOSITE_URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

define Build/Compile
	mkdir -p $(PKG_BUILD_DIR) ; \
	cd $(PKG_BUILD_DIR) || exit 1 ; \
	curl -fL --retry 3 --progress-bar $(GEOIP_URL) -o geoip.dat || exit 1 ; \
	curl -fL --retry 3 --progress-bar $(GEOSITE_URL) -o geosite.dat || exit 1 ; \
	curl -fsL --retry 3 $(GEOIP_URL).sha256sum -o geoip.dat.sha256sum || exit 1 ; \
	curl -fsL --retry 3 $(GEOSITE_URL).sha256sum -o geosite.dat.sha256sum || exit 1 ; \
	sed 's|[[:space:]].*|  geoip.dat|' geoip.dat.sha256sum | sha256sum -c - || exit 1 ; \
	sed 's|[[:space:]].*|  geosite.dat|' geosite.dat.sha256sum | sha256sum -c - || exit 1 ; \
endef

define Package/v2ray-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geoip.dat $(1)/usr/share/v2ray/geoip.dat
endef

define Package/v2ray-geosite/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geosite.dat $(1)/usr/share/v2ray/geosite.dat
endef

$(eval $(call BuildPackage,v2ray-geoip))
$(eval $(call BuildPackage,v2ray-geosite))
