-- functions relating to unpacking fonts that have been downloaded as .zip or .tar.gz etc

function SelectUnpacker(url)
local extn

extn=filesys.extn(url)
if extn==".zip" then return "zip" end
if extn==".gz" then return "tar" end
if extn==".xz" then return "tar" end
if extn==".bz2" then return "tar" end

return ""
end


function UnpackFontFile(font, destdir, url, fpath)
local str

str=SelectUnpacker(url)
if strutil.strlen(str) == 0 then str=SelectUnpacker(font.fileformat) end

if str == "zip"
then
  str="/bin/sh -c 'cd "..strutil.quoteChars(destdir,' ').."; unzip -j -o "..strutil.quoteChars(fpath, ' ').."'"
  ExecSubcommand(str)
  RationalizeDirectory(destdir, destdir)
elseif str == "tar"
then
  str="/bin/sh -c 'cd "..strutil.quoteChars(destdir,' ').."; tar -xf "..strutil.quoteChars(fpath, ' ').."' &>/dev/null"
  ExecSubcommand(str)
  RationalizeDirectory(destdir, destdir)
end


end

