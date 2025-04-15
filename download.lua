--this module relates to  downloading files


function DownloadCheckForFontFile(destdir)
local Glob, str, i, pattern, path
local patterns={"*.ttf", "*.otf", "*.otb", "*.pfb", "*.pfa", "*.pcf", "*.bdf"}

for i,pattern in ipairs(patterns)
do
  path=destdir .. pattern
  Glob=filesys.GLOB(path)
  str=Glob:next()
  if str ~= nil then return(str) end
end

return nil
end


function DownloadFontFile(font, destdir, variant)
local url, fpath, str

filesys.mkdirPath(destdir)
filesys.chmod(destdir, "rwxrwxr-x")

url=font[variant]
if strutil.strlen(url) > 0
then
	fpath=destdir..font.title.."-"..font.category.."-"..variant..font.fileformat
	--this 'copy' does the actual download
	filesys.copy(url, fpath)
	filesys.chmod(fpath, "rw-rw-r-")

	--unpack it!
  UnpackFontFile(font, destdir, url, fpath)
end

return(DownloadCheckForFontFile(destdir))
end

