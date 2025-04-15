
function InstalledFontsList()
local categories={}
local S, str, font

S=stream.STREAM("cmd:fc-list : file family foundry style spacing weight lang")
str=S:readln()
while str ~= nil
do
str=strutil.trim(str)
font=FontConfigParseDescription(str)
if font ~= nil then FontListAdd(categories, font) end
str=S:readln()
end
S:close()

return(categories)
end


