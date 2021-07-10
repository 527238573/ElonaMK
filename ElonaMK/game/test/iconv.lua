local ffi = require("ffi");
ffi.cdef[[
long libiconv_open(const char* tocode, const char* fromcode);
long libiconv(int cd,  char** inbuf, long *inbytesleft, char** outbuf, long *outbytesleft);
long libiconv_close(int cd);
]];
local ICONV = ffi.load("iconv");
local iconv = {
	_cd = nil,
	BUFFER_LENGTH = 4096,
	openHandle = function(self,tocode,fromcode)
		if self._cd ~= nil and self._cd ~= -1 then
			error("please close it first!", 2);
			return false;
		end
		local o = {_cd = nil};
		--setmetatable(o, self)
		--self.__index = self
		setmetatable(o, {__index = self});
		if type(tocode) ~= "string" or type(fromcode) ~= "string" then
			error("paramater error,please input string!", 2);
			return false;
		end
		o._cd = ICONV.libiconv_open(tocode,fromcode);
		if o._cd == -1 then
			o._cd = nil;
			return false;
		end
		return o;
	end,
	iconv = function(self,str)
		local inLen = string.len(str);
		local insize = ffi.new("long[1]",inLen);
		local instr = ffi.new("char[?]",inLen+1,str);
		local inptr = ffi.new("char*[1]",instr);
		local outstr = ffi.new("char[?]",self.BUFFER_LENGTH+1);
		local outptr = ffi.new("char*[1]",outstr);
		local outsize = ffi.new("long[1]",self.BUFFER_LENGTH);
		local err = ICONV.libiconv(self._cd,inptr,insize,outptr,outsize);
		if err == -1 then
			return false,nil;
		end
		local out = ffi.string(outstr,self.BUFFER_LENGTH - outsize[0]);
		return true,out;
	end,
	closeHandle = function(self)
		if self._cd == nil or self._cd == -1 then
			error("please open it first!", 2);
			return false;
		end
		ICONV.libiconv_close(self._cd);
		self._cd = nil;
	end
};
return iconv;