function is_winos()
	local temp = os.tmpname();
    sep = string.match(temp, "^/");
    if sep then
	return false
	else 
	return true
	end
end

function CopyFile(SrcFile, DesFile)
      local file = io.open(SrcFile, "rb")
      assert(file)
      local data = file:read("*all")
      file:close()
      file = io.open(DesFile, "wb")
      assert(file)
      file:write(data)
      file:close()
end

function getCanonicalFile(fullname)
	local newfilename = string.gsub(fullname, "\\", "/")
	return newfilename
end

function getPath(fullname) 
	local pathname,filename  = string.match(fullname, "(.*)/(.*)")
	if ( is_winos() ) then 
		pathname = string.gsub(pathname, "/", "\\")
		pathname = string.gsub(pathname, ":", "")
	end
	return pathname,filename
end

local function directory_exists( sPath )
  if type( sPath ) ~= "string" then return false end
  local response = os.execute( "cd " .. sPath )
  if response == 0 then
    return true
  end
  return false
end

local function mkdir_win(pathname) 
	if (not directory_exists( pathname)) then 
		os.execute("mkdir " .. pathname)
	end
end

local function mkdir_unix(pathname) 
	os.execute("mkdir -p " .. pathname)
end

function copy_file(local_filename,backup_path)
    local pathname,filename = getPath(local_filename)
    if ( is_winos() ) then
         mkdir_win(backup_path .. pathname )
         --print(local_filename.. " " .. backup_path .. pathname .. "\\" .. filename )
         CopyFile(local_filename, backup_path .. pathname .. "\\" .. filename )
    else
         mkdir_unix(backup_path .. pathname )
         --print(local_filename.." " .. backup_path .. pathname .. "/" .. filename )
         CopyFile(local_filename, backup_path .. pathname .. "/" .. filename )
    end
end
