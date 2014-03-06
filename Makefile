
FILES=SramController.vhd \
	SramControllerTestGen.vhd \
	SramTestTop.vhd

WORK_DIR="/tmp/work"
MODELSIMINI_PATH=/home/erik/Development/FPGA/OV76X0/modelsim.ini

CC=vcom
FLAGS=-work $(WORK_DIR) -93 -modelsimini $(MODELSIMINI_PATH)
VLIB=vlib

all: lib work vhdlfiles

lib:
	$(MAKE) -C ../Lib -f ../Lib/Makefile

work:
	$(VLIB) $(WORK_DIR)

clean:
	rm -rf *~ rtl_work *.wlf transcript *.bak

vhdlfiles:
	$(CC) $(FLAGS) $(FILES)
