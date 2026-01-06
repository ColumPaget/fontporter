function InstallFontWriteInfo(font, install_dir)
local S, i, item
local fields={"name","title","description","foundry","category","style","languages","license","weight"}

S=stream.STREAM(install_dir.."/font.info", "w")
if S ~= nil
then
for i,item in ipairs(fields)
do
  if strutil.strlen(font[item]) >  0 then  S:writeln(item..": "..font[item].."\n")
  else S:writeln(item..": unknown\n")
  end
end

S:close()
end

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

InstallFontWriteInfo(font, path)

Out:puts(" ~g~eOKAY: installed font '"..font.title.."' to "..path.."~0 PRESS ANY KEY\n")
else
Out:puts(" ~r~eERROR: failed to install font '"..font.title.."' to "..path.."~0 PRESS ANY KEY\n")
end
Out:flush()
Out:getc()

end


