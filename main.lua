-- 'main', the entry point of the code is at the bottom of this
-- 'main' is currently a bit of a dumping ground for stuff that
-- doesn't go in any of the other modules, but it's mostly the
-- User Interface code

GOOGLEFONTS_API_KEY="AIzaSyDQSLP4w0WE3UhvoSEtJmWtR1vhDgqMG7E"

VERSION="4.0"


-- surprisingly this function is only currently used in main.lua!
function PadStr(str, len)
local padded

padded=strutil.padto(str, ' ', len)
padded=string.sub(padded, 1, len)
return padded
end




function FontSortCompare(f1, f2)

if f1==nil and f2==nil then return false end
if f1==nil then return true end
if f2==nil then return false end
if f1.name < f2.name then return true end
return false
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
Menu:add("Fonts from SentyFont.com", "sentyfont.com")
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
	if selection=="sentyfont.com" then list=SentyFontsList() end
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
