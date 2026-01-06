
-- making this a global is bad form, but due to these functions being used as 
-- a 'callback' from the 'BasicMenuRun' function, it's not instantly easy to 
-- make this into an object. Likely I need to declare a 'menu' object that is
-- applied to all menus, but for now a global will do
fonts_menu_info_lines=0
fonts_menu_total_lines=0
fonts_menu_info_preview=false

function FontsMenuSetup(source)
local height

height=Out:height()

if height < 9 then return 0,0,false end
if height < 15 then return 2,2,false end


if source == "installed" and settings.use_sixel == true 
then
if height < 20 then return 2,6,true end
return 4,8,true
end

return 4,4,false
end


function DisplayFontsMenuFormatInfo(font, info_lines)
local desc=""
local screen_width, str
local lines=0
local len=0

screen_width=Out:width() -2

--set lines to 1 to allow room for
--'support' line
lines=1

str=strutil.unQuote(font.description)
for i = 1,strutil.strlen(str),1
do
 char=string.sub(str, i, i)

 if char == "\n" then desc=desc .. " "
 else desc=desc..char
 end

 if len >= screen_width 
 then
 len=0
 lines=lines+1
 end

 len=len+1
end


-- info_lines -1 because 'supports:' steals a line 
-- -5 characters to allow for '...' on the end and some extra space
len=(screen_width * (info_lines-1)) - 5 
if strutil.strlen(desc) > len then desc=string.sub(desc, 1, len) .. "..." end


str="~esupports:~0 "..  FontsParseStyle(font, "")
str=string.sub(str, 1, screen_width)
str=str .. "\r\n~>" .. desc

while lines < info_lines-1
do
str=str .. "\r\n~>"
lines=lines+1
end

-- ~> clear to end at the start, as we may not end on the same line as we start
return "~>" .. str .. "~>"
end


-- when moving through the 'list of fonts' menu 
-- this function displays info on each font as it's highlighted. 
function DisplayFontsMenuInfo(menu, item, fonts)
local font
local str=""

if item==nil then return end
if fonts_menu_total_lines == 0 then return end

font=FontListFind(fonts, item)
if font ~= nil
then
   if fonts_menu_info_lines > 0
   then
      str=DisplayFontsMenuFormatInfo(font, fonts_menu_info_lines);
      Out:move(0, Out:length() - (fonts_menu_total_lines + 1)) 
      Out:puts(str)
   end

   if fonts_menu_info_preview == true and fonts_menu_total_lines > 4
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



fonts_menu_info_lines, fonts_menu_total_lines, fonts_menu_info_preview = FontsMenuSetup(source)

-- we take +3 off the height heree to allow for topbar, bottom bar, and a bit of space between top
-- and start of the menu
Menu=terminal.TERMMENU(Out, 1, 2, Out:width()-2, Out:height() - (fonts_menu_total_lines + 4))

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
	if strutil.strlen(font.license) > 0 then item=item.. LicenseTypeColor(font.license) end
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

