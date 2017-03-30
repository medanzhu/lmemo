require "scanner"

local function get_sep()
    local temp = os.tmpname();
    local sep = string.match(temp, "^/");
    if sep then
        return sep 
    else
        return "\\"
    end
end 

filename = "/tmp/1/dddd.php"
local fn, matched_pattern, str = scan_file(filename);

print(matched_pattern); 
