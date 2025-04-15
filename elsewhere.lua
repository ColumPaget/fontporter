-- this module contains functions relating to the 'elsewhere' list of fonts
-- that is fonts not available through one of the standard APIs 


function ElsewhereParseFontDescription(str)
local font, toks, path, style

toks=strutil.TOKENIZER(str, "|")

path=toks:next()
if strutil.strlen(path) > 0
then
font={}
font.regular=path
font.title=toks:next()
font.name=font.title .. " - "..filesys.basename(path)
font.style=toks:next()
font.foundry=toks:next()
font.category=FontsParseStyle(font, path)
font.info=toks:next()
font.license=toks:next()
if font.license==nil then font.license="" end
font.languages=""
font.weight=""
font.fileformat=filesys.extn(path)
font.fontformat=filesys.extn(path)
end

return font
end



function ElsewhereFontsList()
local categories={}
local S, str, font

S=stream.STREAM(process.getenv("HOME") .. "/.config/fontporter/fonts-elsewhere.conf", "r")
if S == nil then S=stream.STREAM("/etc/fontporter.d/fonts-elsewhere.conf","r") end
if S == nil then S=stream.STREAM("/etc/fonts-elsewhere.conf","r") end

if S ~= nil
then
str=S:readln()
while str ~= nil
do
str=strutil.trim(str)
font=ElsewhereParseFontDescription(str)
if font ~= nil then FontListAdd(categories, font) end
str=S:readln()
end
S:close()
end

return(categories)
end



