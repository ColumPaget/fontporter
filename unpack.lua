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

