--functions related to image viewers

function FindImageViewer()
local viewers={"display", "feh", "fim", "sxiv", "miv2", "xv", "giv", "meh", "iv", "xviewer", "nomacs", "xzgv", "gthumb", "ristretto", "geeqie"}
local i,prog

for i,prog in ipairs(viewers)
do
	path=filesys.find(prog, process.getenv("PATH"))
	if strutil.strlen(path) > 0 then return path end
end

return nil
end

