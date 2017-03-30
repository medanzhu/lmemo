require "scanner"
require "file"

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


local iguard_path = "/home/danzhu/stagingd/"
local backup_path = "/home/danzhu/backup"
local alert_prefix = "alert-"
local force_del = 1 

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
    local day = os.date("%Y%m%d",os.time())
    local f=io.open(iguard_path .. "logs"..get_sep().. alert_prefix .. day .. ".log", "a+")
    if not f then
        return nil
    end
    local now = os.date("%Y-%m-%d %H:%M:%S",os.time())
    f:write(now .. ",warn,".. site .."," ..server .. "," .. action .. ",403,File " .. atoutf8(local_filename) .. atoutf8(str .."\n"))
    f:close()
end


local function clear_file(local_filename)
	if ffi.os == "Windows" then
		cmd = "del /Q "
	else 
		cmd = "rm -f "
	end
    copy_file(local_filename,backup_path)
	print(cmd .. local_filename)
	os.execute(cmd .. local_filename )		
end 


function trigger(site,server,action,local_filename,remote_filename)
	if (string.find(action, "UPLOAD")) then
		print(action .. " " .. local_filename )
		--os.execute("sleep 1")
		local fn, matched_pattern, str = scan_file(local_filename)
		if (fn ~= nil) then
			prompt = "Found suspicious code in " .. local_filename 
			print(prompt)
			write_alert(site,server,action,local_filename,"Found suspicios code : " .. str)
		    if ( force_del ) then
                clear_file(local_filename)
			    write_alert(site,server,"DELETE",local_filename,"Try to backup and remove the suspicios file")
            end
		end
	end
end

print("file change lua filter inited!\n");
