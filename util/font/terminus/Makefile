# NOTE: This is not a system-wide install, just placing files in $(CURDIR).
.DEFAULT_GOAL := install

NAMES := \
		ter-u16n \
		ter-u18n \
		ter-u20n \
		ter-u22n \
		ter-u24n \
		ter-u28n \
		ter-u32n \

PSF_NAMES := $(addsuffix .psf, $(NAMES))
PSF_FILES := $(addprefix terminus_src/, $(PSF_NAMES))
GZ_FILES := $(addsuffix .gz, $(PSF_NAMES))


# NOTE: The builtin var $(CURDIR) should be the destination for the Terminus
#       $(GZ_FILES), while the $(UTILDIR) is the dir of the current Makefile.
UTILDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# Cut the last slash.
UTILDIR := $(UTILDIR:/=)

INFO := source "$(UTILDIR)/../../../lib/notifications.sh" \
		&& notification_title="[Terminus]" \
		&& INFO


install: $(GZ_FILES)

$(GZ_FILES): $(PSF_FILES)
	$(INFO) "Install '$(@:.psf.gz=)'"
	gzip --keep --stdout terminus_src/$(@:.gz=) > $@

$(PSF_FILES) &: terminus_src/configure
	$(INFO) "Compile"
	cd terminus_src && ./configure
	$(MAKE) --directory=terminus_src psf

terminus_src/configure: terminus.tar.gz
	# The `[ terminus_src/configure -ot terminus.tar.gz ]` is always true, so
	# this check prevents the recipe execution if the target is already exists.
	if [ ! -f terminus_src/configure ] ;\
	then \
		$(INFO) "Unpack" ;\
		tar --extract --gzip --file=$< ;\
		mv terminus-font-* terminus_src ;\
	fi

terminus.tar.gz:
	"$(UTILDIR)/download" "$(CURDIR)"
	mv terminus-font-*.tar.gz $@


uninstall:
	$(INFO) "Uninstall"
	rm --force ter-*.psf.gz


clean:
	$(INFO) "Clean"
	rm --force --recursive terminus_src terminus.tar.gz
