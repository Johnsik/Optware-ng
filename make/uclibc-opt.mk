##########################################################
#
# uclibc-opt
#
###########################################################
#
# Provides uclibc-opt packaging for package buildroot
#

UCLIBC-OPT_VERSION ?= 0.9.28
UCLIBC-OPT_IPK_VERSION ?= $(BUILDROOT_IPK_VERSION)
UCLIBC-OPT_LIBS_SOURCE_DIR ?= $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root$(TARGET_PREFIX)/lib
ifeq ($(UCLIBC-OPT_LIBS_SOURCE_DIR),$(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root$(TARGET_PREFIX)/lib)
UCLIBC-OPT_FROM_BUILDROOT=1
endif


UCLIBC-OPT_DESCRIPTION=micro C library for embedded Linux systems
UCLIBC-OPT_SECTION=base
UCLIBC-OPT_PRIORITY=required
ifneq ($(OPTWARE_TARGET), $(filter buildroot-armeabi buildroot-armeabi-ng buildroot-mipsel buildroot-mipsel-ng shibby-tomato-arm, $(OPTWARE_TARGET)))
UCLIBC-OPT_DEPENDS=
else
#	to make feed firmware-independent, we make
#	all packages dependent on uclibc-opt by hacking ipkg-build from ipkg-utils,
#	so make uclibc-opt dependent on libnsl, which is a part of uClibc
UCLIBC-OPT_DEPENDS=libnsl
endif
ifeq (ipkg-opt, $(filter ipkg-opt, $(PACKAGES)))
UCLIBC-OPT_SUGGESTS=ipkg-opt
else
UCLIBC-OPT_SUGGESTS=
endif
UCLIBC-OPT_CONFLICTS=

# UCLIBC-OPT_IPK_DIR is the directory in which the ipk is built.
# UCLIBC-OPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UCLIBC-OPT_BUILD_DIR=$(BUILD_DIR)/uclibc-opt
UCLIBC-OPT_IPK_DIR=$(BUILD_DIR)/uclibc-opt-$(UCLIBC-OPT_VERSION)-ipk
UCLIBC-OPT_IPK=$(BUILD_DIR)/uclibc-opt_$(UCLIBC-OPT_VERSION)-$(UCLIBC-OPT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# For building/cleaning targets see buildroot package
#

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/buildroot
#
$(UCLIBC-OPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: uclibc-opt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UCLIBC-OPT_PRIORITY)" >>$@
	@echo "Section: $(UCLIBC-OPT_SECTION)" >>$@
	@echo "Version: $(UCLIBC-OPT_VERSION)-$(UCLIBC-OPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUILDROOT_MAINTAINER)" >>$@
	@echo "Source: $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)" >>$@
	@echo "Description: $(UCLIBC-OPT_DESCRIPTION)" >>$@
	@echo "Depends: $(UCLIBC-OPT_DEPENDS)" >>$@
	@echo "Suggests: $(UCLIBC-OPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(UCLIBC-OPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/etc/uclibc-opt/...
# Documentation files should be installed in $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/doc/uclibc-opt/...
# Daemon startup scripts should be installed in $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??uclibc-opt
#
# You may need to patch your application to make it use these locations.
#
ifdef UCLIBC-OPT_FROM_BUILDROOT
UCLIBC-OPT_LIBS=ld-uClibc libc libdl libgcc_s libm libintl libnsl libpthread \
	libthread_db libresolv  librt libutil libuClibc libstdc++
ifeq ($(BUILRTOOT_GCC), 4.1.1)
UCLIBC-OPT_LIBS+=libssp
endif
else
UCLIBC-OPT_LIBS=ld-uClibc libc libdl libgcc_s libm libpthread \
	libthread_db libresolv librt libutil libuClibc
endif

UCLIBC-OPT_LIBS_PATTERN=$(patsubst %,$(UCLIBC-OPT_LIBS_SOURCE_DIR)/%*so*,$(UCLIBC-OPT_LIBS))

$(UCLIBC-OPT_BUILD_DIR)/.staged: make/uclibc-opt.mk
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	cp -af $(UCLIBC-OPT_LIBS_PATTERN) $(STAGING_LIB_DIR)
	touch $@

ifdef UCLIBC-OPT_FROM_BUILDROOT
uclibc-opt-stage: $(BUILDROOT_BUILD_DIR)/.staged
else
uclibc-opt-stage: $(UCLIBC-OPT_BUILD_DIR)/.staged
endif

ifdef UCLIBC-OPT_FROM_BUILDROOT
$(UCLIBC-OPT_IPK): $(BUILDROOT_BUILD_DIR)/.built make/uclibc-opt.mk
else
$(UCLIBC-OPT_IPK): make/uclibc-opt.mk
endif
	rm -rf $(UCLIBC-OPT_IPK_DIR) $(BUILD_DIR)/uclibc-opt_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(UCLIBC-OPT_IPK_DIR)
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(UCLIBC-OPT_IPK_DIR) install-strip
#	tar -xv -C $(UCLIBC-OPT_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.$(TARGET_ARCH).tar \
#		--wildcards $(UCLIBC-OPT_LIBS_PATTERN) .$(TARGET_PREFIX)/sbin/ldconfig
	$(INSTALL) -d $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -d $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib
	cp -af $(UCLIBC-OPT_LIBS_PATTERN) $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib
	-$(STRIP_COMMAND) $(patsubst %, $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib/%*so*, $(UCLIBC-OPT_LIBS))
	### package non-stripped libpthread and libthread_db
	cp -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libpthread* $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libthread_db* \
							$(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(UCLIBC-OPT_IPK_DIR)/CONTROL/control
ifdef UCLIBC-OPT_FROM_BUILDROOT
	$(INSTALL) -d $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/usr/lib
	$(INSTALL) -d $(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root$(TARGET_PREFIX)/sbin/ldconfig \
		$(UCLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -m 755 $(BUILDROOT_SOURCE_DIR)/postinst $(UCLIBC-OPT_IPK_DIR)/CONTROL/postinst
endif
#	$(INSTALL) -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(UCLIBC-OPT_IPK_DIR)/CONTROL/prerm
#	echo $(UCLIBC-OPT_CONFFILES) | sed -e 's/ /\n/g' > $(UCLIBC-OPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UCLIBC-OPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
uclibc-opt-ipk: $(UCLIBC-OPT_IPK)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
uclibc-opt-dirclean:
	rm -rf $(UCLIBC-OPT_IPK_DIR) $(UCLIBC-OPT_IPK)
#
#
# Some sanity check for the package.
#
uclibc-opt-check: $(UCLIBC-OPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
