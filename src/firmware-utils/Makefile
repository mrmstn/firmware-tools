CC = gcc
CFLAGS = -DDGC_PRDL=\"\"
WFLAGS = -Wall 

all: orbi mkdniimg

mkdniimg: src/mkdniimg.o
	$(CC) $(LDFLAGS) -o $@ $<

orbi: src/orbi.o
	$(CC) $(LDFLAGS) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) $(WFLAGS) -c -o $@ $<

clean:
	rm -f orbi mkdniimg *.o
