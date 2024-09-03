# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024, Tiny Tapeout LTD
# Author: Uri Shaked

SRC_DIR = ../src
VERILOG_SOURCES = $(SRC_DIR)/*.v
TOP_MODULE = tt_um_nvious_graphics

VFLAGS = --x-assign fast --x-initial fast --noassert 
CFLAGS = -O3 -march=native -Iobj_dir -I/usr/share/verilator/include
LDFLAGS = -lSDL2

all: obj_dir/V$(TOP_MODULE).h
	make -C obj_dir -f V$(TOP_MODULE).mk

obj_dir/V$(TOP_MODULE).h : $(VERILOG_SOURCES) main.cpp
	verilator $(VFLAGS) --cc $(VERILOG_SOURCES) --top-module $(TOP_MODULE) --exe main.cpp -CFLAGS "$(CFLAGS)" -LDFLAGS "$(LDFLAGS)"

lint: $(VERILOG_SOURCES)
	verilator --lint-only -Wall $(VERILOG_SOURCES) --top-module $(TOP_MODULE)

sim: all
	obj_dir/V$(TOP_MODULE)

clean:
	rm -rf obj_dir

distclean: clean

.PHONY: all lint sim clean distclean
