include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=node-config
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/node-config
	SECTION:=freifunk
	CATEGORY:=Freifunk
	TITLE:=Node Config Scripts
	DEPENDS:=+ip-full +babeld +fastd +owipcalc +batctl +haveged
endef

# Package description; a more verbose description on what our package does
define Package/node-config/description
	DIY Freifunk-Router - see https://github.com/yanosz/node-config for details.
endef

# Package preparation instructions; create the build directory and copy the source code.
# The last command is necessary to ensure our preparation instructions remain compatible with the patching system.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ../../freifunk $(PKG_BUILD_DIR)
	cp Makefile $(PKG_BUILD_DIR)
	cp uci-defaults $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/node-config/install
	$(INSTALL_DIR) $(1)/lib/freifunk
	$(CP) $(PKG_BUILD_DIR)/freifunk/* $(1)/lib/freifunk
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(CP) $(PKG_BUILD_DIR)/uci-defaults $(1)/etc/uci-defaults/zzz-node-config
endef

define Package/node-config-openvpn
	$(call Package/node-config)
	TITLE:=Node Config Scripts - OpenVPN additions
	DEPENDS:=+openvpn-mbedtls +node-config
endef

define Package/node-config-openvpn/description
	OpenVPN-Additions DIY Freifunk-Router - see https://github.com/yanosz/node-config for details.
endef

define Package/node-config-pptp
	$(call Package/node-config)
	TITLE:=Node Config Scripts - PPtP additions
	DEPENDS:=+kmod-nf-nathelper-extra +kmod-pptp +ppp-mod-pptp +node-config
endef

define Package/node-config-pptp/description
	PPtP additions DIY Freifunk-Router - see https://github.com/yanosz/node-config for details.
endef

define Package/node-config-pptp/install
	@echo "Nothing to be done"

endef

define Package/node-config-openvpn/install
	@echo "Nothing to be done"
endef


$(eval $(call BuildPackage,node-config))
$(eval $(call BuildPackage,node-config-pptp))
$(eval $(call BuildPackage,node-config-openvpn))
