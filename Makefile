ifdef VERBOSE
	Q :=
	E := @true 
else
	Q := @
	E := @echo 

	ifndef NOCOLOR
		COLOR_COMPILE := \x1b[32;1m
		COLOR_RGB     := \x1b[31;1m
		COLOR_VIDEO   := \x1b[35;1m
		COLOR_RESET   := \x1b[0m
		E := @/bin/echo -e 
	endif
endif

SHELL=/bin/bash

RGBFPS=60
RGBGEOM=128x192
RGBSECONDS=8
VIDEOFPS=20
VIDEOGEOM=1366x768
VIDEOSECONDS=20

SHADY=shady
FFMPEG=ffmpeg

SRCDIR := ./anim
RGBDIR := ./rgb
VIDEODIR := ./video

SHADERFILES := $(shell find $(SRCDIR) -name '*.glsl')
RGBFILES   := $(SHADERFILES:$(SRCDIR)/%.glsl=$(RGBDIR)/%-${RGBGEOM}-${RGBFPS}fps-${RGBSECONDS}s.rgb.gz)
VIDEOFILES := $(SHADERFILES:$(SRCDIR)/%.glsl=$(VIDEODIR)/%.mp4)

-include Makefile.local

.PHONY: all rgb video

all: rgb video

rgb: $(RGBFILES)
video: $(VIDEOFILES)

$(RGBDIR)/%-${RGBGEOM}-${RGBFPS}fps-${RGBSECONDS}s.rgb.gz: $(SRCDIR)/%.glsl
	$(E)" [$(COLOR_RGB)RGB$(COLOR_RESET)] $@"
	$(Q)mkdir -p `dirname $@`
	$(Q)set -o pipefail && $(SHADY) -i $< -g $(RGBGEOM) -framerate $(RGBFPS) -duration $(RGBSECONDS) -ofmt rgb24 | \
		gzip > $@ || rm $@

$(VIDEODIR)/%.mp4: $(SRCDIR)/%.glsl
	$(E)" [$(COLOR_VIDEO)VIDEO$(COLOR_RESET)] $@"
	$(Q)mkdir -p `dirname $@`
	$(Q)$(SHADY) -i emulator.glsl -i $< -g $(VIDEOGEOM) -framerate $(VIDEOFPS) \
		-duration $(VIDEOSECONDS) -ofmt rgb24 | \
		$(FFMPEG) -f rawvideo -pixel_format rgb24 -video_size $(VIDEOGEOM) \
		-framerate $(VIDEOFPS) -t $(VIDEOSECONDS) -i - -quality good -cpu-used 0 \
		-qmin 10 -qmax 42 -threads 8 -y $@
