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

function directory_exists( sPath )
  if type( sPath ) ~= "string" then return false end
  local response = os.execute( "cd " .. sPath )
  if response == 0 then
    return true
  end
  return false
end

function mkdir_win(pathname) 
	if (not directory_exists( pathname)) then 
		os.execute("mkdir " .. pathname)
	end
end

function mkdir_unix(pathname) 
	os.execute("mkdir -p " .. pathname)
end

