.PHONY: all skynet clean

PLAT ?= linux
SHARED := -fPIC --shared
LUA_CLIB_PATH ?= common/luaclib

CFLAGS = -g -O2 -Wall

LUA_CLIB = protobuf log secret cjson lfs webclient

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

$(LUA_CLIB_PATH)/cjson.so : common/lualib-src/lua-cjson/lua_cjson.c common/lualib-src/lua-cjson/strbuf.c common/lualib-src/lua-cjson/strbuf.h | $(LUA_CLIB_PATH)
	cd common/lualib-src/lua-cjson && $(MAKE) $(PLAT) && $(MAKE) install

$(LUA_CLIB_PATH)/lfs.so : common/lualib-src/luafilesystem/src/lfs.c common/lualib-src/luafilesystem/src/lfs.h
	cd common/lualib-src/luafilesystem/ && $(MAKE) $(PLAT) && $(MAKE) install

$(LUA_CLIB_PATH)/webclient.so: common/lualib-src/lua-webclient/webclient.c 
	$(CC) $(CFLAGS) $(SHARED) $< -o $@ -I$(SKYNET_INC) -lcurl

clean :
	cd common/skynet && $(MAKE) clean
	cd common/lualib-src/pbc && $(MAKE) clean
	cd common/lualib-src/pbc/binding/lua53 &&$(MAKE) clean
	cd common/luaclib && rm -f *.so
