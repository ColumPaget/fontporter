-- These functions relate to the screen that allows one to examine, preview and install a particular font



function SetTerminalFont(font)

Out:puts("\x1b]50;"..string.lower(font.title).."\x07")
Out:puts("\x1b]50;" .. "-*-" .. string.lower(font.title) .. "-*-r-normal--*-*-*-*-*-*-*-*\x07")
Out:flush()
end





function DisplayFontInfoBottomBar(font, source)
local str

str="~B~y~eKeys:~0~B ~wv~y:view ~wx~y:mock terminal ~wt~y:set terminal font "
if source ~= "installed" then str=str.. " ~wi~y:install font for user  ~wg~y:install font systemwide\n" end
str=str.."~wescape,backspace,left~y:back"
BottomBar(str)
end


function FormatFontInfoItem(title, value)
if strutil.strlen(value)==0 then return "~e"..title .. ":~0 ~runknown~0" end
if value=="unknown" then return "~e" .. title .. ":~0 ~runknown~0" end

return "~e" ..title .. ":~0 "..value.. " - " .. LicenseLongName(value)
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

str=FormatFontInfoItem("Foundry", font.foundry)
str=str.."  "..FormatFontInfoItem("License", font.license).."\n"

str=str.."~eCategory:~0 " .. font.category .. "  ~eStyle:~0 " .. font.style.. "  ~eWeight:~0 "..font.weight.."\n"
Out:puts(str)
Out:puts("~eLanguages:~0 " .. font.languages .. "\n")
if strutil.strlen(font.description) > 0 then Out:puts("~eDescription:~0 "..font.description.."\n") end

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


