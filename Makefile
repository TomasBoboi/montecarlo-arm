CROSS_COMPILE_PATH ?= "C:\Program Files (x86)\GNU Tools Arm Embedded\9 2019-q4-major\bin\"
COMPILER_PREFIX ?= arm-none-eabi

OUTPUT_FILE = montecarlo

AOPS = --warn --fatal-warnings -mfpu=vfp -mcpu=arm926ej-s
COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding -c -g


all: compile link clean

link:
	$(CROSS_COMPILE_PATH)\$(COMPILER_PREFIX)-ld startup.o util.o -T memmap -o $(OUTPUT_FILE).elf
	$(CROSS_COMPILE_PATH)\$(COMPILER_PREFIX)-objdump -D $(OUTPUT_FILE).elf > $(OUTPUT_FILE).list
	$(CROSS_COMPILE_PATH)\$(COMPILER_PREFIX)-objcopy $(OUTPUT_FILE).elf -O binary $(OUTPUT_FILE).bin

compile:montecarlo.s util.c memmap
	$(CROSS_COMPILE_PATH)\$(COMPILER_PREFIX)-as  $(AOPS) montecarlo.s -o startup.o
	$(CROSS_COMPILE_PATH)\$(COMPILER_PREFIX)-gcc $(COPS) util.c -o util.o
	
clean:
	del ".\$(OUTPUT_FILE).elf"
	del ".\$(OUTPUT_FILE).list"
	del ".\startup.o"