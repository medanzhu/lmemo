require "scanner";
--local ffi = require("ffi")
local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
int poll(struct pollfd *fds, unsigned long nfds, int timeout);
uint32_t GetModuleFileNameA(
  void * hModule,
  uint8_t * lpFilename,
  uint32_t nSize
);
]]

function sleep(s)
	ffi.C.poll(nil, 0, s*1000)
end

local iguard_path = "/home/git/stagingd/"
local alert_prefix = "stagingd-"

local function get_sep()
    local temp = os.tmpname();
    local sep = "/";
	sep = string.match(temp, "^/");
    if sep then
        return sep 
    else
        return "\\"
    end	
end 
  
local function write_alert(site,server,action,local_filename,str) 
end

function trigger(action,ftype,filename,filename_new)
	local filename_dst = filename;
	if (string.find(action, "MOVE")) then
		filename_dst = filename_new
	end
	print(action .. " 1 " .. filename_dst);
	if (string.find(action, "[MODIFIED][MOVE]")) then
		print(action .. " 2 " .. filename_dst);
		local fn, matched_pattern, str = scan_file(filename_dst);
		if (fn ~= nil) then
			prompt = "Found suspicious code in " .. filename_dst .. " ,giving up upload task ";
			print(prompt);
			write_alert(site,server,action,filename_dst,str)
			return -1 
		end
		
		return 0;
	else
		return 0;
	end
end

print("file change lua filter inited!\n");
