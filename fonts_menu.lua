
-- when moving through the 'list of fonts' menu 
-- this function displays info on each font as it's highlighted. 
function DisplayFontsMenuInfo(menu, item, fonts)
local font
local str=""

if item==nil then return end

font=FontListFind(fonts, item)
if font ~= nil
then

	-- ~> clear to end at the start, as we may not end on the same line as we start
  str="~>" 

--[[
  if strutil.strlen(font.languages) > 0 
  then
  str=str.."languages: "..font.languages .."\n"
  end
]]--

	if strutil.strlen(font.info) > 0
	then
	str=str..font.info
	end

	str=str.."~>"
	Out:move(1, Out:length() - 5) 
	Out:puts(str)

	if source=="installed"
	then
	Out:move(4, Out:length() - 4)
	PreviewOneLine(font.title, font.regular, "sixel")
	end
end
end



function DisplayFontsRun(menu, fonts, source, style)
local key, item, font

while true
do
Out:clear()
Out:move(0,0)

if source == "installed" then Out:puts("~B~wLocally installed fonts of style: ~y" .. style .. "~>~0")
else Out:puts("~B~wFonts available from "..source.." of style: ~y" .. style .. "~>~0")
end

BasicMenuBottomBar()

item=BasicMenuRun(menu, DisplayFontsMenuInfo, fonts)
if item == "EXIT" then return nil end
if item ~= "RESIZE"
then
font=FontListFind(fonts, item)
return font
end

end

return nil
end





function DisplayFonts(source, category, style)
local key, font, selection, str, item
local Menu

if source==nil then return end
if category==nil then return end

if source == "installed"
then
Menu=terminal.TERMMENU(Out, 1, 2, Out:width()-2, Out:height() - 8)
else
Menu=terminal.TERMMENU(Out, 1, 2, Out:width()-2, Out:height() - 6)
end

table.sort(category, FontSortCompare)
for key,font in pairs(category)
do

	if font.fontformat==".ttf" then item="~b"..PadStr("ttf", 6).."~0"
	elseif font.fontformat==".otf" then item="~y"..PadStr("otf", 6).."~0"
	elseif font.fontformat==".otb" then item="~y"..PadStr("otb", 6).."~0"
	elseif font.fontformat==".pfa" then item="~m"..PadStr("pfa", 6).."~0"
	elseif font.fontformat==".pfb" then item="~m"..PadStr("pfb", 6).."~0"
	elseif font.fontformat==".pcf" then item="~r"..PadStr("pcf", 6).."~0"
	elseif font.fontformat==".bdf" then item="~r"..PadStr("bdf", 6).."~0"
	else item=PadStr(font.fontformat, 6)
	end

	item=item .. PadStr(font.foundry, 16)
	item=item .. "  ~e" .. PadStr(font.title, 30) .. "~0   ~m" .. PadStr(font.style, 20).. "  "
	if strutil.strlen(font.license) > 0 then item=item.. MenuColorLicence(font.license) end
	item=item.."~0"
	--.. font.languages.."  license:"..font.license
	Menu:add(item, font.name)
end

while true
do
  font=DisplayFontsRun(Menu, category, source, style)
  if font==nil or font=="EXIT" then break end
  if font ~= "RESIZE" then DisplayFontInfo(font, source) end
end

end

