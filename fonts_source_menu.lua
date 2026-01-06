-- this implements a simple menu that allows the user to select
-- a source to examine/download fonts from.


function SelectFontSource()
local Menu, list
local selection


while true
do
Out:clear()
Out:move(0,0)
Out:puts("~B~wFontPorter "..VERSION.."~>~0")

Menu=terminal.TERMMENU(Out, 1, 2, Out:width()-2, Out:length() - 4)
Menu:add("Locally Installed Fonts", "installed")
Menu:add("Fonts from Googlefonts", "googlefonts")
Menu:add("Fonts from FontSquirrel", "fontsquirrel")
Menu:add("Fonts from FontSource.org", "fontsource.org")
Menu:add("Fonts from FontShare.com", "fontshare.com")
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
	if selection=="fontshare.com" then list=FontShareList() end
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

