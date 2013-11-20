XCO_SRC := $(wildcard *.xco)
V_SRC := $(patsubst %.xco,%.v,$(XCO_SRC))

ifndef $(IMG_NAME)
	IMG_NAME := side_camp_gray
endif

IMG_FILE := $(IMG_NAME).jpg
COE_FILE := $(IMG_NAME).coe

all: $(V_SRC)

%.v: %.xco src/$(COE_FILE)
	coregen -p coregen.cgp -b $*.xco

coe: src/$(COE_FILE)

src/$(COE_FILE): src/$(IMG_FILE) src/img_to_coe.py src/img_to_coe.m
	cd src; \
	rm img_data.coe; \
	matlab -nojvm -nodisplay -nosplash -r "img_to_coe('$(IMG_FILE)')"; \
	ln -s $(COE_FILE) img_data.coe

clean:
	find . ! -name '*.xco' -a ! -name 'Makefile' -a ! -name '*.cgp' -a ! -name '*.cgc' -a ! -name '.gitignore' -a ! -name 'src' -a ! -name '*.jpg' -a ! -name '*.py' -a ! -name '*.m' -delete
