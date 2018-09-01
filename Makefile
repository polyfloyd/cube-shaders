ifdef VERBOSE
	Q :=
	E := @true 
else
	Q := @
	E := @echo 

	ifndef NOCOLOR
		COLOR_COMPILE := \x1b[32;1m
		COLOR_GIF     := \x1b[34;1m
		COLOR_RGB     := \x1b[31;1m
		COLOR_VIDEO   := \x1b[35;1m
		COLOR_RESET   := \x1b[0m
		E := @/bin/echo -e 
	endif
endif

SHELL=/bin/bash

GIFFPS=16
GIFGEOM=640x360
GIFSECONDS=3
RGBFPS=60
RGBGEOM=128x192
RGBSECONDS=8
VIDEOFPS=20
VIDEOGEOM=1366x768
VIDEOSECONDS=20

SHADY=shady
FFMPEG=ffmpeg

SRCDIR := ./anim
GIFDIR := ./gif
RGBDIR := ./rgb
VIDEODIR := ./video

SHADERFILES := $(shell find $(SRCDIR) -name '*.glsl')
GIFFILES    := $(SHADERFILES:$(SRCDIR)/%.glsl=$(GIFDIR)/%.gif)
RGBFILES    := $(SHADERFILES:$(SRCDIR)/%.glsl=$(RGBDIR)/%-${RGBGEOM}-${RGBFPS}fps-${RGBSECONDS}s.rgb.gz)
VIDEOFILES  := $(SHADERFILES:$(SRCDIR)/%.glsl=$(VIDEODIR)/%.mp4)

-include Makefile.local

.PHONY: all gif rgb video

all: gif rgb video

gif: $(GIFFILES)
rgb: $(RGBFILES)
video: $(VIDEOFILES)

$(GIFDIR)/%.gif: $(SRCDIR)/%.glsl
	$(E)" [$(COLOR_VIDEO)GIF$(COLOR_RESET)] $@"
	$(Q)mkdir -p `dirname $@`
	$(Q)$(SHADY) -i emulator.glsl -i $< -g $(GIFGEOM) -framerate $(GIFFPS) \
		-duration $(GIFSECONDS) -ofmt rgb24 | \
		$(FFMPEG) -f rawvideo -pixel_format rgb24 -video_size $(GIFGEOM) \
		-framerate $(GIFFPS) -t $(GIFSECONDS) -i - -threads 8 -y $@

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
