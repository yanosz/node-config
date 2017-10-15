ifndef LEDE_MIRROR
  LEDE_MIRROR:=http://downloads.lede-project.org/releases/
endif

ifndef LEDE_SDK
  LEDE_SDK:=17.01.3/targets/x86/64/lede-sdk-17.01.3-x86-64_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz
endif

SDK_FILE:= $(notdir $(LEDE_SDK))
SDK_URL:= $(LEDE_MIRROR)/$(LEDE_SDK)

ifdef TRAVIS_TAG
  PKG_VERSION:=$(TRAVIS_TAG)
endif

ifndef PKG_VERSION
  PKG_VERSION:=1.0
endif

ifndef PKG_RELEASE
  PKG_RELEASE:=1
endif

ifdef BUILD_KEY
  SIGN_STR:="BUILD_KEY=$(BUILD_KEY)"
else
  SIGN_STR:="CONFIG_SIGNED_PACKAGES="
endif

world: target/bin/packages/all/nodeconfig/Packages

clean:
	$(RM) -rf target

target:
	mkdir -p target
	mkdir -p tmp
	wget -c $(SDK_URL) -O tmp/$(SDK_FILE)
	tar -C target --strip 1 -xf tmp/$(SDK_FILE)

target/.config: target
	echo "src-link nodeconfig $(PWD)/lede_built" > target/feeds.conf
	./target/scripts/feeds update -a
	./target/scripts/feeds install -a
	$(MAKE) -C target defconfig

target/bin/packages/all/nodeconfig/Packages: target/.config
	$(MAKE) -C target package/node-config/compile CONFIG_TARGET_ARCH_PACKAGES=all
	$(MAKE) -C target package/index CONFIG_TARGET_ARCH_PACKAGES=all $(SIGN_STR)
	$(RM) -rf target/bin/packages/all/base/




