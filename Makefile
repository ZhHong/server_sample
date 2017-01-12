.PHONY: all skynet clean

PLAT ?= linux
SHARED := -fPIC --shared
LUA_CLIB_PATH ?= common/luaclib

CFLAGS = -g -O2 -Wall

LUA_CLIB = protobuf log secret

all : skynet

skynet/Makefile :
	git submodule update --init

skynet : skynet/Makefile
	cd common/skynet && $(MAKE) $(PLAT) && cd ..

all : \
  $(foreach v, $(LUA_CLIB), $(LUA_CLIB_PATH)/$(v).so)

$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)
	cd common

$(LUA_CLIB_PATH)/protobuf.so : | $(LUA_CLIB_PATH)
	cd common/lualib-src/pbc && $(MAKE) lib && cd binding/lua53 && $(MAKE) && cd ../../../../.. && cp common/lualib-src/pbc/binding/lua53/protobuf.so $@

$(LUA_CLIB_PATH)/log.so : common/lualib-src/lua-log.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

$(LUA_CLIB_PATH)/secret.so : common/lualib-src/lua-secret.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

clean :
	cd common/skynet && $(MAKE) clean
	cd common/lualib-src/pbc && $(MAKE) clean
	cd common/lualib-src/pbc/binding/lua53 &&$(MAKE) clean
	cd common/luaclib && rm -f *.so
