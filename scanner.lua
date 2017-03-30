local filename_pattern = '.'

-- for php, lua regx
-- for php, lua regx
php_pattern = {
	'exec%(',
	'system%(',
	'shell_exec%(',
	'popen%(',
	'pcntl_exec%(',
	'passthru',
	'eval%(',
	'base64_decode%(',
	'gzinflage%(',
	'gzuncompress%(',
	'chr%(',
	'dl%(',
	'fopen%(',
	'readfile%(',
	'file%(',
	'file_get_contents%(',
	'opendir%(',
	'chdir%(',
	'fwrite%(',
	'unlink%(',
	'glob%(',
	'_exec',
	'array_map%(',
	'move_uploaded_file'
}

-- for asp, lua regx
asp_pattern = {
	'[#@].-==.*[#@]',
	'filesystemobject',	
	'%d%d%W+%d%d%W+%d%d%W+%d%d%W+%d%d%W+%d%d%W+%d%d',	
	'vbscript.encode',
	'jscript.encode',
	'javascript.encode',
	'execute.-request',
	'eval.-request',
	'execute.-session',
	'eval.-session',
	'wscript%.shell',
	'%%#@',
	'#@~',
	'chr.-chr.-chr.-',
	'opentextfile%(',
	'createtextfile%(',
	'llehs'
}

-- for aspx, lua regx
aspx_pattern = {
	'new.-process',
	'new.-streamwriter',
	'new.-tcpclient',
	'new.-directoryinfo',
	'new.-oledbconnection',
	'new.-oledbcommand',
	'webadmin2y'
}

-- for jsp, lua regx
jsp_pattern = {
	'new.-socket',
	'new.-processbuilder',
	'new.-file',
	'new.-fileinputstream',
	'new.-fileoutputStream',
	'new.-classloader',
	'drivermanager',
	'getruntime',
	'filereader',
	'filewriter',
	'jythonshell',
	'countdownLatch',
	'jythonshell',
	'gethostaddress'
}

local all_pattern = { php_pattern, asp_pattern, aspx_pattern, jsp_pattern }




function trim_dir_postfix(str)
	while true do
		if string.sub(str, -1, -1) == '\\' then
			str = string.sub(str, 0, -2)
		else
			return str
		end
	end
end

function var_dump(data, max_level, prefix)
    if type(prefix) ~= "string" then
        prefix = ""
    end
    if type(data) ~= "table" then
        print(prefix .. tostring(data))
    else
        print(data)
        if max_level ~= 0 then
            local prefix_next = prefix .. "    "
            print(prefix .. "{")
            for k,v in pairs(data) do
                io.stdout:write(prefix_next .. k .. " = ")
                if type(v) ~= "table" or (type(max_level) == "number" and max_level <= 1) then
                    print(v)
                else
                    if max_level == nil then
                        var_dump(v, nil, prefix_next)
                    else
                        var_dump(v, max_level - 1, prefix_next)
                    end
                end
            end
            print(prefix .. "}")
        end
    end
end

function vd(data, max_level)
    var_dump(data, max_level or 5)
end

function string:split(sep)
	local sep, fields = sep or "\t", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end


function filename_filter(filename, pattern)

	local list = string.split(string.lower(pattern), ':')
	local fname = string.lower(filename)
	for _, n in pairs(list) do
		if string.find(fname, n) then
			return true
		end
	end

	return nil

end
function scan_block(block, pattern_list)
	if not block then return nil end
	local str_list = string.split(block, '\n')
	for _, str in pairs(str_list) do
		local ret, matched_pattern, matched_str = scan_str(str, pattern_list)
		if ret then
			return true, matched_pattern, matched_str
		end
	end
	return nil
end


function scan_str(str, pattern_list)
	if not str then return nil end
	local pattern
	for _,pattern in pairs(pattern_list) do
		local s,e  = string.find(str, pattern)
		if s then
			return true, pattern, string.sub(str, s, e)
		end
	end
	return nil
end

function scan_file(filename)
	if not filename then return nil end
	print("to scan " .. filename)
	local f = io.open(filename, 'r')
	if not f then
		return nil
	end
	-- read first 16K of the file
	local content = f:read(2^14, '*line')
	f:close()
	content = string.lower(content)


	local pattern_list = {}
	--table.insert(pattern_list, php_pattern)
	if is_php(filename) then table.insert(pattern_list, php_pattern) end
	if is_asp(filename) then table.insert(pattern_list, asp_pattern) end
	if is_aspx(filename) then table.insert(pattern_list, aspx_pattern) end
	if is_jsp(filename) then table.insert(pattern_list, aspx_pattern) end
	
	if #pattern_list == 0 then pattern_list = all_pattern end
	
	for _, list in pairs(pattern_list) do
		local ret, matched_pattern, str =  scan_block(content, list)
		if ret then
			return filename, matched_pattern, str
		end
	end
	return nil
end

function is_php(filename)
	if string.find(filename, 'php') then
		return true
	elseif string.find(filename, 'inc') then
		return true
	else
		return nil
	end
end

function is_asp(filename)
	if string.find(filename, 'asp') then
		return true
	elseif string.find(filename, 'cer') then
		return true
	elseif string.find(filename, 'cdx') then
		return true
	elseif string.find(filename, 'inc') then
		return true
	else
		return nil
	end
end


function is_aspx(filename)
	if string.find(filename, 'aspx') then
		return true
	else
		return nil
	end
end

function is_jsp(filename)
	if string.find(filename, 'jsp') then
		return true
	elseif string.find(filename, 'jspx') then
		return true
	else
		return nil
	end
end
