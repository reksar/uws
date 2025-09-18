# NOTE: This is not a system-wide install, just placing files in $(CURDIR).
.DEFAULT_GOAL := install

# NOTE: Depends on the download settings.
FONT_TYPE := InputMono

FONT_STYLES := Regular Bold Italic BoldItalic

TTF_NAMES := $(addsuffix .ttf,$(addprefix $(FONT_TYPE)-,$(FONT_STYLES)))

# NOTE: Full paths are required for $(PATCHER).
TTF_SOURCE_DIR := $(CURDIR)/input_src/Input_Fonts/Input/
ttf_source_name = $(shell echo "Input-$(style)_\($(FONT_TYPE)-$(style)\).ttf")
TTF_SOURCE_FILES := $(foreach style,$(FONT_STYLES),$(ttf_source_name))
TTF_SOURCE_FILES := $(addprefix $(TTF_SOURCE_DIR),$(TTF_SOURCE_FILES))

# For making a Nerd Font.
PATCHER_DIR := $(CURDIR)/FontPatcher
PATCHER := $(PATCHER_DIR)/font-patcher


# NOTE: The builtin var $(CURDIR) should be the destination for the Input
# $(TTF_NAMES), while the $(UTILDIR) is the dir of the current Makefile.
UTILDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# Cut the last slash.
UTILDIR := $(UTILDIR:/=)

INFO := source "$(UTILDIR)/../../../lib/notifications.sh" \
		&& notification_title="[Input]" \
		&& INFO


install: $(TTF_NAMES)

# Patch the specified TTF files with the Nerd patcher.
$(TTF_NAMES): $(TTF_SOURCE_FILES) $(PATCHER)
	if [ ! -f "$@" ] ;\
	then \
		$(INFO) "Install '$@'" ;\
		base=$(subst .ttf,,$@) \
		&& src=$$( \
			echo $(TTF_SOURCE_FILES) \
			| grep --only-matching --perl-regexp \
				"\S+$(subst -,.,$$base)\)\.ttf" \
		) \
		&& source $(PATCHER_DIR)/venv/bin/activate \
		&& $(PATCHER) --complete --outputdir "$(CURDIR)" --name "$$base" \
			"$$src" ;\
	fi

# NOTE: Font files are released before they are zipped, so this rule is always
# runs and `test "$@" -ot "$<"` is true.
$(TTF_SOURCE_FILES) &: input.zip
	for ttf in $(TTF_SOURCE_FILES); \
	do \
		if [ ! -f "$$ttf" ] ;\
		then \
			$(INFO) "Unpack" ;\
			mkdir --parents input_src ;\
			unzip -qd input_src input.zip ;\
		fi ;\
	done

input.zip:
	"$(UTILDIR)/download" "$(CURDIR)"
	mv build $@
	# Ensure that the downloaded file is a zip.
	unzip -qt input.zip

$(PATCHER):
	"$(UTILDIR)/../ensure-patcher" "$(PATCHER_DIR)"


uninstall:
	$(INFO) "Uninstall [$(TTF_NAMES)]"
	rm --force $(TTF_NAMES)


clean:
	$(INFO) "Clean"
	rm --force --recursive input.zip input_src "$(PATCHER_DIR)"
