###########################################################
#
# perl-email-mime-encodings
#
###########################################################

PERL-EMAIL-MIME-ENCODINGS_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/R/RJ/RJBS
PERL-EMAIL-MIME-ENCODINGS_VERSION=1.315
PERL-EMAIL-MIME-ENCODINGS_SOURCE=Email-MIME-Encodings-$(PERL-EMAIL-MIME-ENCODINGS_VERSION).tar.gz
PERL-EMAIL-MIME-ENCODINGS_DIR=Email-MIME-Encodings-$(PERL-EMAIL-MIME-ENCODINGS_VERSION)
PERL-EMAIL-MIME-ENCODINGS_UNZIP=zcat
PERL-EMAIL-MIME-ENCODINGS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EMAIL-MIME-ENCODINGS_DESCRIPTION=A unified interface to MIME encodings and decoding.
PERL-EMAIL-MIME-ENCODINGS_SECTION=email
PERL-EMAIL-MIME-ENCODINGS_PRIORITY=optional
PERL-EMAIL-MIME-ENCODINGS_DEPENDS=perl
PERL-EMAIL-MIME-ENCODINGS_SUGGESTS=
PERL-EMAIL-MIME-ENCODINGS_CONFLICTS=

PERL-EMAIL-MIME-ENCODINGS_IPK_VERSION=2

PERL-EMAIL-MIME-ENCODINGS_CONFFILES=

PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR=$(BUILD_DIR)/perl-email-mime-encodings
PERL-EMAIL-MIME-ENCODINGS_SOURCE_DIR=$(SOURCE_DIR)/perl-email-mime-encodings
PERL-EMAIL-MIME-ENCODINGS_IPK_DIR=$(BUILD_DIR)/perl-email-mime-encodings-$(PERL-EMAIL-MIME-ENCODINGS_VERSION)-ipk
PERL-EMAIL-MIME-ENCODINGS_IPK=$(BUILD_DIR)/perl-email-mime-encodings_$(PERL-EMAIL-MIME-ENCODINGS_VERSION)-$(PERL-EMAIL-MIME-ENCODINGS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_SOURCE):
	$(WGET) -P $(@D) $(PERL-EMAIL-MIME-ENCODINGS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-email-mime-encodings-source: $(DL_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_SOURCE) $(PERL-EMAIL-MIME-ENCODINGS_PATCHES)

$(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_SOURCE) $(PERL-EMAIL-MIME-ENCODINGS_PATCHES) make/perl-email-mime-encodings.mk
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_DIR) $(@D)
	$(PERL-EMAIL-MIME-ENCODINGS_UNZIP) $(DL_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EMAIL-MIME-ENCODINGS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-email-mime-encodings-unpack: $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.configured

$(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.built: $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-email-mime-encodings: $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.built

$(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.staged: $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-email-mime-encodings-stage: $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.staged

$(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-email-mime-encodings" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EMAIL-MIME-ENCODINGS_PRIORITY)" >>$@
	@echo "Section: $(PERL-EMAIL-MIME-ENCODINGS_SECTION)" >>$@
	@echo "Version: $(PERL-EMAIL-MIME-ENCODINGS_VERSION)-$(PERL-EMAIL-MIME-ENCODINGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EMAIL-MIME-ENCODINGS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EMAIL-MIME-ENCODINGS_SITE)/$(PERL-EMAIL-MIME-ENCODINGS_SOURCE)" >>$@
	@echo "Description: $(PERL-EMAIL-MIME-ENCODINGS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EMAIL-MIME-ENCODINGS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EMAIL-MIME-ENCODINGS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EMAIL-MIME-ENCODINGS_CONFLICTS)" >>$@

$(PERL-EMAIL-MIME-ENCODINGS_IPK): $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR)/.built
	rm -rf $(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR) $(BUILD_DIR)/perl-email-mime-encodings_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR) DESTDIR=$(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR) install
	find $(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR)/CONTROL/control
	echo $(PERL-EMAIL-MIME-ENCODINGS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR)

perl-email-mime-encodings-ipk: $(PERL-EMAIL-MIME-ENCODINGS_IPK)

perl-email-mime-encodings-clean:
	-$(MAKE) -C $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR) clean

perl-email-mime-encodings-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-MIME-ENCODINGS_DIR) $(PERL-EMAIL-MIME-ENCODINGS_BUILD_DIR) $(PERL-EMAIL-MIME-ENCODINGS_IPK_DIR) $(PERL-EMAIL-MIME-ENCODINGS_IPK)
