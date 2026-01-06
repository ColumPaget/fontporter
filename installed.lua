LicenseStrings={
["this font software is licensed under the sil open font license, version 1.1"]="SIL OFL 1.1",
["licensed under the sil open font license, version 1.1"]="SIL OFL 1.1",
["released under the terms of the sil open font license"]="SIL OFL 1.1",
["sil open font license version 1.1 - 26 february 2007"]="SIL OFL 1.1",
["font is released under gnu general public license. full license text is available at http://www.gnu.org/copyleft/gpl.html."]="GPL",
["is free software, licensed under the terms of the gnu general public license."]="GPL",
['"This License" refers to version 2 of the GNU General Public License.']="GPLv2",
['"This License" refers to version 3 of the GNU General Public License.']="GPLv3",
["it is free software: you can redistribute it and/or modify it under the terms of the gnu general public license as published by the free software foundation, either version 3 of the license, or (at your option) any later version."]="GPLv3",
["license gplv2+: gnu gpl version 2 or later <http://gnu.org/licenses/gpl.html> with the gnu font embedding exception."]="GPLv2+",
["the free software foundation; either version 2 of the license, or"]="GPLv2",
["licensed under the mit license"]="MIT",
["gpl- general public license and ofl-open font license"]="SIL OFL 1.1",
["licensed under the bitstream vera license"]="Bitstream Vera License" 
}



function InstalledFontReadInfo(font, install_dir)
local S, toks, name, value
local fields={"name","title","description","foundry","category","style","languages","license","weight"}

S=stream.STREAM(install_dir.."/font.info", "r")
if S ~= nil
then
  str=S:readln()
	while str ~= nil
  do
    toks=strutil.TOKENIZER(strutil.trim(str), ":")
   	name=toks:next()
   	value=toks:remaining()
    if strutil.strlen(font[name]) ==  0 then font[name]=value end
  str=S:readln()
  end

S:close()
end

end




function InstalledFontStreamFindLicense(S)
local line, str, license

line=S:readln()
while line ~= nil
do
line=string.lower(line)
for str,license in pairs(LicenseStrings)
do
if string.find(line, str) then return license end
end

line=S:readln()
end

return nil
end


function InstalledFontReadLicenseFile(path)
local S
local license

S=stream.STREAM(path, "r")
if S ~= nil
then
license=InstalledFontStreamFindLicense(S)
S:close()
end

return license
end


function InstalledFontFindLicense(font)
local license_files={"GPL.txt", "COPYING", "COPYING.txt", "LICENSE", "LICENSE.txt", "SIL Open Font License.txt", "OFL-1.1.txt"}

local dir, str, path
local S

dir=filesys.dirname(font.regular)
InstalledFontReadInfo(font, dir)
if font.license ~= nil then return font.license end

S=stream.STREAM("cmd:strings -n 40 '".. font.regular .. "'" , "r")
if S ~= nil
then
font.license=InstalledFontStreamFindLicense(S)
S:close()
end

if font.license ~= nil then return font.license end


for i,item in ipairs(license_files)
do
 path=dir.."/"..item
 font.license=InstalledFontReadLicenseFile(path)
 if font.license ~= nil then return font.license end
end

return nil
end


function InstalledFontsList()
local categories={}
local S, str, font

S=stream.STREAM("cmd:fc-list : file family foundry style spacing weight lang")
str=S:readln()
while str ~= nil
do
  str=strutil.trim(str)
  font=FontConfigParseDescription(str)
  if font ~= nil 
  then 
    BottomBar("~B~yLOADING:~w" .. font.name)
    InstalledFontFindLicense(font)
    FontListAdd(categories, font) 
  end
  str=S:readln()
end
S:close()

return(categories)
end


