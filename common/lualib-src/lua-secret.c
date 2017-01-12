#include <lua.h>
#include <lauxlib.h>

#include <time.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#define P 0xffffffffffffffc5ull
#define G 5
#define SMALL_CHUNK 256

#define HEX(v,c) { char tmp = (char) c; if (tmp >= '0' && tmp <= '9') { v = tmp-'0'; } else { v = tmp - 'a' + 10; } }

// powmodp64 for DH-key exchange

// The biggest 64bit prime

static inline uint64_t
mul_mod_p(uint64_t a, uint64_t b) {
	uint64_t m = 0;
	while(b) {
		if(b&1) {
			uint64_t t = P-a;
			if ( m >= t) {
				m -= t;
			} else {
				m += a;
			}
		}
		if (a >= P - a) {
			a = a * 2 - P;
		} else {
			a = a * 2;
		}
		b>>=1;
	}
	return m;
}

static inline uint64_t
pow_mod_p(uint64_t a, uint64_t b) {
	if (b==1) {
		return a;
	}
	uint64_t t = pow_mod_p(a, b>>1);
	t = mul_mod_p(t,t);
	if (b % 2) {
		t = mul_mod_p(t, a);
	}
	return t;
}

// calc a^b % p
static uint64_t
powmodp(uint64_t a, uint64_t b) {
	if (a > P)
		a%=P;
	return pow_mod_p(a,b);
}

static void
read64(lua_State *L, uint32_t xx[2], uint32_t yy[2]) {
	size_t sz = 0;
	const uint8_t *x = (const uint8_t *)luaL_checklstring(L, 1, &sz);
	if (sz != 8) {
		luaL_error(L, "Invalid uint64 x");
	}
	const uint8_t *y = (const uint8_t *)luaL_checklstring(L, 2, &sz);
	if (sz != 8) {
		luaL_error(L, "Invalid uint64 y");
	}
	xx[0] = x[0] | x[1]<<8 | x[2]<<16 | x[3]<<24;
	xx[1] = x[4] | x[5]<<8 | x[6]<<16 | x[7]<<24;
	yy[0] = y[0] | y[1]<<8 | y[2]<<16 | y[3]<<24;
	yy[1] = y[4] | y[5]<<8 | y[6]<<16 | y[7]<<24;
}

static void
push64(lua_State *L, uint64_t r) {
	uint8_t tmp[8];
	tmp[0] = r & 0xff;
	tmp[1] = (r >> 8 )& 0xff;
	tmp[2] = (r >> 16 )& 0xff;
	tmp[3] = (r >> 24 )& 0xff;
	tmp[4] = (r >> 32 )& 0xff;
	tmp[5] = (r >> 40 )& 0xff;
	tmp[6] = (r >> 48 )& 0xff;
	tmp[7] = (r >> 56 )& 0xff;

	lua_pushlstring(L, (const char *)tmp, 8);
}

static int
lfromhex(lua_State *L) {
	size_t sz = 0;
	const char * text = luaL_checklstring(L, 1, &sz);
	if (sz & 2) {
		return luaL_error(L, "Invalid hex text size %d", (int)sz);
	}
	char tmp[SMALL_CHUNK];
	char *buffer = tmp;
	if (sz > SMALL_CHUNK*2) {
		buffer = lua_newuserdata(L, sz / 2);
	}
	int i;
	for (i=0;i<sz;i+=2) {
		uint8_t hi,low;
		HEX(hi, text[i]);
		HEX(low, text[i+1]);
		if (hi > 16 || low > 16) {
			return luaL_error(L, "Invalid hex text", text);
		}
		buffer[i/2] = hi<<4 | low;
	}
	lua_pushlstring(L, buffer, i/2);
	return 1;
}

static int
ltohex(lua_State *L) {
	static char hex[] = "0123456789abcdef";
	size_t sz = 0;
	const uint8_t * text = (const uint8_t *)luaL_checklstring(L, 1, &sz);
	char tmp[SMALL_CHUNK];
	char *buffer = tmp;
	if (sz > SMALL_CHUNK/2) {
		buffer = lua_newuserdata(L, sz * 2);
	}
	int i;
	for (i=0;i<sz;i++) {
		buffer[i*2] = hex[text[i] >> 4];
		buffer[i*2+1] = hex[text[i] & 0xf];
	}
	lua_pushlstring(L, buffer, sz * 2);
	return 1;
}


static int
ldh64_public_key(lua_State *L){
	size_t sz = 0;
	const uint8_t *x = (const uint8_t *)luaL_checklstring(L, 1, &sz);
	if (sz != 8) {
		luaL_error(L, "Invalid dh uint64 key");
	}
	uint32_t xx[2];
	xx[0] = x[0] | x[1]<<8 | x[2]<<16 | x[3]<<24;
	xx[1] = x[4] | x[5]<<8 | x[6]<<16 | x[7]<<24;

	uint64_t x64 = (uint64_t)xx[0] | (uint64_t)xx[1]<<32;
	if (x64 == 0)
		return luaL_error(L, "Can't be 0");

	uint64_t r = powmodp(5,	x64);
	push64(L, r);
	return 1;
}

static int
ldh64_private_key(lua_State *L){
	char tmp[8];
	int i;
	char x = 0;
	for (i=0;i<8;i++) {
		tmp[i] = random() & 0xff;
		x ^= tmp[i];
	}
	if (x==0) {
		tmp[0] |= 1;	// avoid 0
	}
	lua_pushlstring(L, tmp, 8);
	return 1;
}

static int
ldh64_secret(lua_State *L){
	uint32_t x[2], y[2];
	read64(L, x, y);
	uint64_t xx = (uint64_t)x[0] | (uint64_t)x[1]<<32;
	uint64_t yy = (uint64_t)y[0] | (uint64_t)y[1]<<32;
	if (xx == 0 || yy == 0)
		return luaL_error(L, "Can't be 0");
	uint64_t sec=powmodp(xx,yy);
	push64(L,sec);
	return 1;
}

int luaopen_secret(lua_State *L){
	luaL_checkversion(L);
	srandom(time(NULL));
	luaL_Reg l[] =
	{
		{ "dh64_public_key", ldh64_public_key },
		{ "dh64_private_key", ldh64_private_key },
		{ "dh64_secret", ldh64_secret },
		{ "hexencode", ltohex },
		{ "hexdecode", lfromhex },
		{NULL,NULL},
	};
	luaL_newlib(L,l);
	return 1;
}
