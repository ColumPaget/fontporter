-- 'main', the entry point of the code is at the bottom of this
-- 'main' is currently a bit of a dumping ground for stuff that
-- doesn't go in any of the other modules, but it's mostly the
-- User Interface code

GOOGLEFONTS_API_KEY="AIzaSyDQSLP4w0WE3UhvoSEtJmWtR1vhDgqMG7E"

VERSION="3.0"






function FontSortCompare(f1, f2)

if f1==nil and f2==nil then return false end
if f1==nil then return true end
if f2==nil then return false end
if f1.name < f2.name then return true end
return false
end




function FontLanguages(item)
local P, I, str

str=""
P=item:open("subsets")
I=P:next()
while I ~= nil
do
	str=str..I:value()..","
	I=P:next()
end

return str
end




function FontDeduceFormat(path)
local fmt, str

fmt=filesys.extn(path)
if fmt == ".gz" or fmt == ".bz2" or fmt == ".xz"
then
str=filesys.filename(path)
fmt=filesys.extn(str)
end

if fmt then fmt=string.lower(fmt) end

return fmt
end





function RationalizeDirectory(destdir, currdir)
local item, Glob, info

Glob=filesys.GLOB(currdir.."/*")
item=Glob:next()
while item ~= nil
do
	info=Glob:info()

	if info.type=="directory" then RationalizeDirectory(destdir, item)
	elseif filesys.extn(item) == ".ttf" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".otf" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".otb" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".pfa" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".pfb" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".pcf" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".bdf" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".txt" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	elseif filesys.extn(item) == ".md" then filesys.rename(item, destdir.."/"..filesys.basename(item))
	end

	item=Glob:next()
end

filesys.rmdir(currdir)
end






function SetTerminalFont(font)

Out:puts("\x1b]50;"..string.lower(font.title).."\x07")
Out:puts("\x1b]50;" .. "-*-" .. string.lower(font.title) .. "-*-r-normal--*-*-*-*-*-*-*-*\x07")
Out:flush()
end


function InstallFont(font, font_root, require_root)
local path, fpath

Out:move(0,Out:length()-4)
path=font_root .. string.gsub(font.title, ' ', '_') .. "/"
Out:puts(" ~b~eInstalling: '"..font.title.."' to "..path.."~0\n")

DownloadFontFile(font, path, "regular")
DownloadFontFile(font, path, "italic")
DownloadFontFile(font, path, "bold")

-- one of the above should have downloaded
if DownloadCheckForFontFile(path) ~= nil
then
str="/bin/sh -c 'cd " .. strutil.quoteChars(path, ' ') .. "; mkfontscale; mkfontdir; fc-cache -fv'"
ExecSubcommand(str)

Out:puts(" ~g~eOKAY: installed font '"..font.title.."' to "..path.."~0 PRESS ANY KEY\n")
else
Out:puts(" ~r~eERROR: failed to install font '"..font.title.."' to "..path.."~0 PRESS ANY KEY\n")
end
Out:flush()
Out:getc()

end




-- adds backspace and left to the usual menu:run() command
-- accepts a callback function to display info about items
-- in the menu list as they are highlighted
function BasicMenuRun(menu, callback, callback_arg)
local key

while true
do
menu:draw()

if callback ~= nil then callback(menu, menu:curr(), callback_arg) end

key=Out:getc()


if key == "ESC" then return "EXIT"
elseif key == "BACKSPACE" then return "EXIT"
elseif key == "LEFT" then return "EXIT"
elseif key == "RIGHT" then return menu:curr()
elseif key == "\n" then return menu:curr()
elseif key == "w" then key="UP"
elseif key == "i" then key="UP"
elseif key == "s" then key="DOWN"
elseif key == "k" then key="DOWN"
elseif process.sigcheck(process.SIGWINCH) == true
then
process.sigwatch(process.SIGWINCH)
return "RESIZE"
end


menu:onkey(key)
end

return nil
end


function BottomBar(text)
local str, toks, line, i
local lines={}

toks=strutil.TOKENIZER(text, "\n")
line=toks:next()
while line ~= nil
do
table.insert(lines, line)
line=toks:next()
end


str=""
Out:move(0,Out:height() - (#lines))
for i, line in ipairs(lines)
do
if i > 1 then str=str.."\n" end
str=str..terminal.strtrunc(line, Out:width()) .."~>"
end

-- add this after truncate, as we need to go back to normal colors 
-- and can't afford to have this cut off by truncate
str=str .. "~0"

Out:puts(str)
end


function BasicMenuBottomBar()
BottomBar("~B~yKeys: ~wup,w,i~y:move selection up  ~wdown,s,k~y:move selection down  ~wenter,right~y:select  ~wescape,backspace,left~y:back")
end


function DisplayFontInfoBottomBar(font, source)
local str

str="~B~y~eKeys:~0~B ~wv~y:view ~wx~y:mock terminal ~wt~y:set terminal font "
if source ~= "installed" then str=str.. " ~wi~y:install font for user  ~wg~y:install font systemwide\n" end
str=str.."~wescape,backspace,left~y:back"
BottomBar(str)
end


function DisplayFontInfo(font, source) 
local ch, S, str

if source == "fontsource.org" then FontSourceGetFontDetails(font) end

while true
do
Out:clear()
Out:move(0,0)
Out:puts("~B~+w~e"..font.name.."~0~B~y  " .. " from " .. source .. "~>~0\n")
Out:puts("\n")

str="~eFoundry:~0 " .. tostring(font.foundry)
if strutil.strlen(font.license) == 0 then str=str.."  ~eLicense:~0 ~runknown~0\n"
else str=str..("  License: " .. font.license) .."\n" end
str=str.."~eCategory:~0 " .. font.category .. "  ~eStyle:~0 " .. font.style.. "  ~eWeight:~0 "..font.weight.."\n"
Out:puts(str)
Out:puts("~eLanguages:~0 " .. font.languages .. "\n")
if strutil.strlen(font.info) > 0 then Out:puts("~eDescription:~0 "..font.info.."\n") end

if font.fileformat==".bdf" then Out:puts("\n~rThis is a BDF font, preview will likely not work~0\n"); end
if font.fileformat==".pcf" then Out:puts("\n~rThis is a PCF font, preview will likely not work~0\n"); end
if font.fileformat==".otb" then Out:puts("\n~rThis is an OTB font, preview will likely not work~0\n"); end


DisplayFontInfoBottomBar(font, source)
if settings.use_sixel == true
then
PreviewFont(font, true, 2, 6, "", "The Quick Brown Fox", "Jumped Over The Lazy Dog", "1234567890")
end

ch=Out:getc()
if ch == 'd' then filesys.copy(font.regular, font.name..".ttf")
elseif ch == 'i' then InstallFont(font, process.getenv("HOME").."/.local/share/fonts/", false)
elseif ch == 'g' then InstallFont(font, settings.fonts_dir, true)
elseif ch == 'v' then PreviewFont(font, false, 0, 0, "", "The Quick Brown Fox", "Jumped Over The Lazy Dog", "1234567890")
elseif ch == 'x' then PreviewFont(font, false, 0, 0, "terminal", " user@server1: kill -9 thegibson", " bash: kill: (20344) - Operation not permitted", " user@server1: hack the planet", " bash: hack: command not found", "user@server1: _")
elseif ch == 't' then SetTerminalFont(font)
elseif ch == 'ESC' then break
elseif ch == 'LEFT' then break
elseif ch == 'BACKSPACE' then break
end
end

end



-- when moving through the 'list of fonts' menu 
-- this function displays info on each font as it's highlighted. 
function DisplayFontsMenuInfo(menu, item, fonts)
local font, str

if item==nil then return end

font=FontListFind(fonts, item)
if font ~= nil
then
	if strutil.strlen(font.info) > 0
	then
	Out:move(1, Out:length() -3) 
	-- ~> at start end end, as we may not end on the same line as we start
	str="~>" .. font.info .. "~>"
	Out:puts(str)
	end

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



function PadStr(str, len)
local padded

padded=strutil.padto(str, ' ', len)
padded=string.sub(padded, 1, len)
return padded
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
	item=item .. "  ~e" .. PadStr(font.title, 30) .. "~0   ~b" .. PadStr(font.style, 20).. "  "
	if strutil.strlen(font.license) > 0 then item=item..font.license end
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



function DisplayFontStyleMenu(source, style_list)
local list,key,category,selection
local sorted_styles={}
local Menu

for key,category in pairs(style_list)
do
table.insert(sorted_styles, key)
end
table.sort(sorted_styles, FontStyleCompare)


while true
do
Out:clear()

Out:move(0,0)
if source == "installed" then Out:puts("~B~wLocally installed fonts: select style~>~0")
else Out:puts("~B~wFonts available from "..source..": select style~>~0")
end

BasicMenuBottomBar()

Out:move(0,5)

Menu=terminal.TERMMENU(Out, 1, 6, Out:width()-2, Out:length()-8)

for i,key in ipairs(sorted_styles)
do
category=style_list[key]
Menu:add(key.. " ".. #category.." items", key)
end


selection=BasicMenuRun(Menu)
if selection == nil then break end
if selection == "EXIT" then break end
if selection ~= "RESIZE" then DisplayFonts(source, style_list[selection], selection)  end
end

end




function SelectFontSource()
local Menu, list
local selection


while true
do
Out:clear()
Out:move(0,0)
Out:puts("~B~wFontPorter "..VERSION.."~>~0")

Menu=terminal.TERMMENU(Out, 1, 6, Out:width()-2, 10)
Menu:add("Locally Installed Fonts", "installed")
Menu:add("Fonts from Googlefonts", "googlefonts")
Menu:add("Fonts from FontSquirrel", "fontsquirrel")
Menu:add("Fonts from FontSource.org", "fontsource.org")
Menu:add("Fonts from Mozilla", "mozilla")
Menu:add("Fonts from OmnibusType", "omnibus-type")
Menu:add("Fonts from NerdFonts.com", "nerdfonts.com")
Menu:add("Fonts from Elsewhere", "elsewhere")

BasicMenuBottomBar()

selection=BasicMenuRun(Menu)
if selection=="EXIT" then return nil end

if strutil.strlen(selection) > 0 and selection ~= "RESIZE"
then
	if selection=="installed" then list=InstalledFontsList() end
	if selection=="googlefonts" then list=GoogleFontsList() end
	if selection=="fontsquirrel" then list=FontSquirrelList() end
	if selection=="fontsource.org" then list=FontSourceList() end
	if selection=="omnibus-type" then list=OmnibusTypeFontsList() end
	if selection=="nerdfonts.com" then list=NerdFontsList() end
	if selection=="mozilla" then list=MozillaCDNList("https://code.cdn.mozilla.net/") end
	if selection=="elsewhere" then list=ElsewhereFontsList() end
	break
end

end

return selection,list
end


function PrintHelp()

print("usage: lua fontporter.lua [options]")
print("options:")
print("  -sixel             enable sixel graphics for font previews")
print("  -viewer <prog>     use program 'prog' to view font previews")
print("  -fontsdir <path>   set directory fonts are stored in")
print("  -?                 display this help")
print("  -h                 display this help")
print("  -help              display this help")
print("  --help             display this help")

--if we are displaying help, don't run the program
os.exit(0)
end



function ParseCommandLine()
for i,item in ipairs(arg)
do
	if item=="-sixel" then settings.use_sixel=true
	elseif item=="-viewer" then settings.image_viewer=arg[i+1]; arg[i+1]=""
	elseif item=="-fontsdir" then settings.fonts_dir=arg[i+1]; arg[i+1]="" 
	elseif item=="-?" then PrintHelp()
	elseif item=="-h" then PrintHelp()
	elseif item=="-help" then PrintHelp()
	elseif item=="--help" then PrintHelp()
	end
end

end


InitSettings()
ParseCommandLine()

process.sigwatch(process.SIGWINCH)
Out=terminal.TERM()
--Out:timeout(0)
terminal.utf8(3)
process.lu_set("Error:Silent", "y")
process.lu_set("HTTP:UserAgent", "fontporter: 3.0")

while true
do
list_source,list=SelectFontSource()
if list_source==nil then break end
DisplayFontStyleMenu(list_source, list)
end

Out:reset()
Out:clear()
Out:move(0,0)
