require("stream")
require("strutil")
require("process")
require("dataparser")
require("terminal")
require("filesys")
require("xml")
require("net")

API_KEY="AIzaSyDQSLP4w0WE3UhvoSEtJmWtR1vhDgqMG7E"
VERSION="1.1"
settings={}
settings.use_sixel=false
settings.fonts_dir="/usr/share/fonts/"
--settings.preview_dir=process.getenv("HOME") .. "/.font_preview/"
settings.preview_dir="/tmp/.font_preview/"

function URLFromCurrent(current_url, new_url)
local URL

if string.sub(new_url, 1, 5) == "http:" then return new_url end
if string.sub(new_url, 1, 6) == "https:" then return new_url end

if string.sub(new_url, 1, 1) ~= "/" then return(filesys.dirname(current_url) .. "/" .. new_url) end

URL=net.parseURL(current_url)
return(URL.type.."://"..URL.host..":"..URL.port..new_url)
end


function FindImageViewer()
local viewers={"display", "feh", "fim", "sxiv", "miv2", "xv", "giv", "meh", "iv", "xviewer", "nomacs", "xzgv", "gthumb", "ristretto", "geeqie"}
local i,prog

for i,prog in ipairs(viewers)
do
	path=filesys.find(prog, process.getenv("PATH"))
	if strutil.strlen(path) > 0 then return path end
end

return nil
end


function FontSortCompare(f1, f2)

if f1==nil and f2==nil then return false end
if f1==nil then return true end
if f2==nil then return false end
if f1.name < f2.name then return true end
return false
end


function FontStyleEnumerate(style)
local styles={"regular", "serif", "sans-serif", "slab-serif", "monospace", "bold", "bold light", "bold italic", "italic", "light", "script", "display", "retro", "blackletter", "comic", "symbol"}
local i, found

if style == nil then return 0 end
for i,found in ipairs(styles)
do
	if found == style then return i end
end

return 999
end


function FontStyleCompare(s1, s2)
local i1, i2

i1=FontStyleEnumerate(s1)
i2=FontStyleEnumerate(s2)

return i1 < i2
end



function CachedFileOpen(url, source)
local S, doc, str, cache_path

cache_path=process.getenv("HOME").."/."..source..".json"
S=stream.STREAM(cache_path)
if S ~= nil then return(S) end

doc=""
S=stream.STREAM(url)
str=S:readln()
while str ~= nil
do
doc=doc..str
str=S:readln()
end
S:close()

S=stream.STREAM(cache_path, "w")
if (S)
then
S:writeln(doc)
S:close()
end

S=stream.STREAM(cache_path)
return(S)
end


function GetCachedJSON(url, source)
local S, P, json

S=CachedFileOpen(url, source)
json=S:readdoc()
S:close()

P=dataparser.PARSER("json", json)
return(P)
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




function FontCategoryAdd(categories, font, category)
local cat

cat=categories[category] 
if cat == nil
then 
cat={}
categories[category]=cat 
end

table.insert(cat, font)

end


function FontListAdd(categories, font)
local toks, tok

FontCategoryAdd(categories, font, font.category)

--[[ this was a bit of a disaster
toks=strutil.TOKENIZER(font.languages, ",")
tok=toks:next()
while tok ~= nil
do
FontCategoryAdd(categories, font, tok)
tok=toks:next()
end
]]--

end


function FontsParseStyle(font, filename)
local toks, tok, str
local italic=false 
local bold=false
local sans=false
local serif=false
local slab=false
local blackletter=false
local light=false
local script=false
local monospace=false
local display=false
local symbol=false
local retro=false
local comic=false
local barcode=false
local music=false

if strutil.strlen(font.spacing) > 0 then monospace=true end

str=string.lower(filename)
if string.find(str, "handwriting") ~= nil then script=true end
if string.find(str, "barcode") ~= nil then barcode=true end
if string.find(str, "roman") ~= nil then serif=true end
if string.find(str, "slab") ~= nil then slab=true end
if string.find(str, "stencil") ~= nil then display=true end
if string.find(str, "sans") ~= nil then sans=true
elseif string.find(str, "serif") ~= nil then serif=true end

str=string.lower(font.title)
if string.find(str, "handwriting") ~= nil then script=true end
if string.find(str, "barcode") ~= nil then barcode=true end
if string.find(str, "roman") ~= nil then serif=true end
if string.find(str, "slab") ~= nil then slab=true end
if string.find(str, "stencil") ~= nil then display=true end
if string.find(str, "sans") ~= nil then sans=true
elseif string.find(str, "serif") ~= nil then serif=true end


toks=strutil.TOKENIZER(font.style, "\\S|,", "m")
tok=toks:next()
while tok ~= nil
do
 tok=string.lower(tok)
 if tok=="barcode" then barcode=true end
 if tok=="music" then music=true end
 if tok=="grunge" then display=true end
 if tok=="comic" then comic=true end
 if tok=="retro" then retro=true end
 if tok=="stencil" then display=true end
 if tok=="display" then display=true end
 if tok=="novelty" then display=true end
 if tok=="italic" then italic=true end
 if tok=="oblique" then italic=true end
 if tok=="bold" then bold=true end
 if tok=="serif" then serif=true end
 if tok=="sans" then sans=true end
 if tok=="sans-serif" then sans=true end
 if tok=="sans serif" then sans=true end
 if tok=="slab" then slab=true end
 if tok=="slab-serif" then slab=true end
 if tok=="slab serif" then slab=true end
 if tok=="blackletter" then blackletter=true end
 if tok=="medieval" then blackletter=true end
 if tok=="roman" then serif=true end
 if tok=="thin" then light=true end
 if tok=="light" then light=true end
 if tok=="extralight" then light=true end
 if tok=="script" then script=true end
 if tok=="handwriting" then script=true end
 if tok=="caligraphic" then script=true end
 if tok=="calligraphic" then script=true end
 if tok=="handdrawn" then script=true end
 if tok=="pixel" then monospace=true end
 if tok=="mono" then monospace=true end
 if tok=="monospace" then monospace=true end
 if tok=="monospaced" then monospace=true end
 if tok=="programming" then monospace=true end
 if tok=="typewriter" then monospace=true end
 if tok=="symbol" then symbol=true end
 if tok=="cursor" then symbol=true end
 if tok=="dingbat" then symbol=true end
 if tok=="wingdings" then symbol=true end
 if tok=="icon" then symbol=true end
 if tok=="emoji" then symbol=true end
tok=toks:next()
end

if symbol == true then return("symbol") end
if music == true then return("music") end
if barcode == true then return("barcode") end
if comic == true then return("comic") end
if retro == true then return("retro") end
if script == true then return("script") end
if blackletter == true then return("blackletter") end
if slab == true then return("slab-serif") end
if display == true then return("display") end
if monospace == true then return("monospace") end

if italic == true 
then 
if bold == true then return("bold italic") end
if light == true then return("bold light") end
return("italic") 
end

if bold == true then return("bold") end
if light == true then return("light") end

--sans must come before serif, as a font could have both set
if sans == true then return("sans-serif") end
if serif == true then return("serif") end

return("regular")

end


function FontConfigParseDescription(input)
local font, toks, path, style, str

toks=strutil.TOKENIZER(input, ":") 

path=toks:next()

font={}
font.regular=path
font.title=strutil.trim(toks:next())
font.name=font.title .. " - "..filesys.basename(path)
font.style=""
font.spacing=""
font.foundry=""
font.languages=""
font.license=""

str=toks:next()
while str ~= nil
do
	if string.sub(str, 1, 8) == "foundry=" then font.foundry=string.sub(str, 9) 
	elseif string.sub(str, 1, 6) == "style=" then font.style=string.sub(str, 7)
	elseif string.sub(str, 1, 8) == "spacing=" then font.spacing=string.sub(str, 9)
	elseif string.sub(str, 1, 7) == "weight=" then font.weight=string.sub(str, 8)
	--this produces huge long strings of country-codes, with is more trouble than help
	--elseif string.sub(str, 1, 5) == "lang=" then font.languages=string.sub(str, 6)
	end
str=toks:next()
end

font.category=FontsParseStyle(font, path)
font.fileformat=filesys.extn(path)
font.fontformat=filesys.extn(path)

return font
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
if font ~= nil then FontListAdd(categories, font) end
str=S:readln()
end
S:close()

return(categories)
end



function ElsewhereParseFontDescription(str)
local font, toks, path, style

toks=strutil.TOKENIZER(str, "|")

path=toks:next()
if strutil.strlen(path) > 0
then
font={}
font.regular=path
font.title=toks:next()
font.name=font.title .. " - "..filesys.basename(path)
font.style=toks:next()
font.foundry=toks:next()
font.category=FontsParseStyle(font, path)
font.description=toks:next()
font.license=toks:next()
if font.license==nil then font.license="" end
font.languages=""
font.weight=""
font.fileformat=filesys.extn(path)
font.fontformat=filesys.extn(path)
end

return font
end



function ElsewhereFontsList()
local categories={}
local S, str, font

S=stream.STREAM(process.getenv("HOME") .. "/.config/fontporter/fonts-elsewhere.conf", "r")
if S == nil then S=stream.STREAM("/etc/fontporter.d/fonts-elsewhere.conf","r") end

if S ~= nil
then
str=S:readln()
while str ~= nil
do
str=strutil.trim(str)
font=ElsewhereParseFontDescription(str)
if font ~= nil then FontListAdd(categories, font) end
str=S:readln()
end
S:close()
end

return(categories)
end


function GoogleFontsList()
local P, I, item, font, files
local fonts={}
local languages={}
local categories={}

P=GetCachedJSON("https://www.googleapis.com/webfonts/v1/webfonts?key="..API_KEY, "googlefonts")
I=P:open("/items")

item=I:next()
while item ~= nil
do
font={}
font.name=item:value("family")
font.title=font.name
font.style=item:value("category")
font.category=FontsParseStyle(font, "")

files=item:open("/files")
font.regular=files:value("regular")
font.italic=files:value("italic")
--font.regular=item:value("files/regular")
--font.italic=item:value("files/italic")
font.languages=FontLanguages(item)
font.fileformat=filesys.extn(font.regular)
font.fontformat=filesys.extn(font.regular)
font.weight=""
FontListAdd(categories, font)

item=I:next()
end

return(categories)
end


function FontSquirrelList()
local P, item, font
local categories={}

P=GetCachedJSON("http://www.fontsquirrel.com/api/fontlist/all", "fontsquirrel")
item=P:next()
while item ~= nil
do
font={}
font.name=item:value("family_name")
font.foundry=item:value("foundry_name")
font.title=font.name
font.style=item:value("classification")
font.category=FontsParseStyle(font, "")
font.regular="https://www.fontsquirrel.com/fonts/download/" .. item:value("family_urlname")
font.languages=""
font.weight=""
font.fileformat=".zip"
font.fontformat=filesys.extn(item:value("font_filename"))
FontListAdd(categories, font)

item=P:next()
end

return categories
end



function CDNParseFontFace(current_url, toks)
local tok
local font={}

font.name="?"
font.style="serif"
font.category="serif"
font.weight=""
font.languages=""
font.regular=""
font.fileformat=".ttf"
font.fontformat=".ttf"

tok=toks:next()
while tok ~= nil
do

	if tok=="font-family:"
	then
		tok=toks:next()
		while tok==" " do tok=toks:next() end
		font.title=tok
	end

	if tok=="font-weight:"
	then
		tok=toks:next()
		while tok==" " do tok=toks:next() end
		font.weight=tok
	end

	if tok=="font-style:"
	then
		tok=toks:next()
		while tok==" " do tok=toks:next() end
		font.style=tok
		font.category=tok
	end

	if tok == "url"
	then
		tok=toks:next()
		while tok=="(" or tok==" " do tok=toks:next() end
		if filesys.extn(tok) == ".ttf" then font.regular=URLFromCurrent(current_url, tok) end
	end

	if tok == "}" then break end

tok=toks:next()
end

if strutil.strlen(font.title) > 0
then
font.title = font.title .. "-" .. font.style .. "-" .. font.weight
font.name=font.title
end

return font
end


function CDNGetCSS(url, categories) 
local S, doc, toks, tok

S=stream.STREAM(url)
if S ~= nil
then
doc=S:readdoc()
S:close()

toks=strutil.TOKENIZER(doc, "{|}|;|(|)|\\S", "Qms")
tok=toks:next()
while tok ~= nil
do
	if tok=="@font-face"
	then
		font=CDNParseFontFace(url, toks)
		if strutil.strlen(font.regular) > 0 then FontListAdd(categories, font) end
	end
tok=toks:next()
end
end

end



function CDNList(url)
local S, doc, toks, tag
local categories={}

S=stream.STREAM(url)
doc=S:readdoc()
S:close()

toks=xml.XML(doc)
tag=toks:next()
while tag ~= nil
do
	if tag.type ~= nil and string.lower(tag.type) == "key"
	then
	tag=toks:next()
	if filesys.extn(tag.data) == ".css" then CDNGetCSS( URLFromCurrent(url, tag.data), categories ) end
	end
	tag=toks:next()
end

return categories
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
	end

	item=Glob:next()
end

end



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
	str="/bin/sh -c 'cd "..strutil.quoteChars(destdir,' ').."; unzip -j -o "..strutil.quoteChars(fpath, ' ').."' &>/dev/null"
	os.execute(str)
  RationalizeDirectory(destdir, destdir)
elseif str == "tar"
then
	str="/bin/sh -c 'cd "..strutil.quoteChars(destdir,' ').."; tar -xf "..strutil.quoteChars(fpath, ' ').."' &>/dev/null"
	os.execute(str)
  RationalizeDirectory(destdir, destdir)
end


end


function DownloadCheckForFontFile(destdir)
local Glob, str, i, pattern
local patterns={"/*.ttf", "*.otf", "*.otb", "*.pfb", "*.pfa", "*.pcf", "*.bdf"}

for i,pattern in ipairs(patterns)
do
  Glob=filesys.GLOB(destdir..pattern)
  str=Glob:next()
  if str ~= nil then return(str) end
end

return nil
end


function DownloadFontFile(font, destdir, variant)
local url, fpath, str

str=DownloadCheckForFontFile(destdir)
if str ~= nil then return str end

filesys.mkdirPath(destdir)
filesys.chmod(destdir, "rwxrwxr-x")

url=font[variant]
if strutil.strlen(url) > 0
then
	fpath=destdir..font.title.."-"..font.category.."-"..variant..font.fileformat
	filesys.copy(url, fpath)
	filesys.chmod(fpath, "rw-rw-r-")

  UnpackFontFile(font, destdir, url, fpath)
end

return(DownloadCheckForFontFile(destdir))
end


function SetTerminalFont(font)
Out:puts("\x1b]50;"..font.title.."\x07")
Out:flush()
end


function InstallFont(font, font_root, require_root)
local path, fpath

Out:move(0,Out:length()-4)
path=font_root .. string.gsub(font.title, ' ', '_') .. "/"
Out:puts(" ~b~eInstalling: '"..font.title.."' to "..path.."~0\n")

if DownloadFontFile(font, path, "regular") ~= nil
then
DownloadFontFile(font, path, "italic")
os.execute("/bin/sh -c 'cd " .. strutil.quoteChars(path, ' ') .. "; mkfontscale; mkfontdir; fc-cache -fv &>/dev/null'")
Out:puts(" ~g~eOKAY: installed font '"..font.title.."' to "..path.."~0 PRESS ANY KEY\n")
else
Out:puts(" ~r~eERROR: failed to install font '"..font.title.."' to "..path.."~0 PRESS ANY KEY\n")
end
Out:flush()
Out:getc()

end



function PreviewGenerate(path, format, pointsize, height, line1, line2, line3)
local str, width

width=string.format("%d", Out:width() * 6)

str="convert -font '" .. path.. "' -pointsize " .. tostring(pointsize) 
str=str.." -fill '#000000' -size " .. tostring(width) .. "x" .. tostring(height)
str=str.." -gravity center xc:"
if strutil.strlen(line1) > 0 then str=str .. " -annotate +0-40 '" .. line1 .. "'" end
if strutil.strlen(line2) > 0 then str=str .. " -pointsize 24 -annotate +0+0 '" .. line2 .."'" end
if strutil.strlen(line3) > 0 then str=str .. " -annotate +0+30 '" .. line3 .. "'" end
if strutil.strlen(line4) > 0 then str=str .. " -annotate +0+60 '" .. line4 .."'" end
str=str.." -flatten "

if format=="sixel" then str=str.."sixel:"..settings.preview_dir.."/preview.six "
else str=str..settings.preview_dir.."/preview.png "
end

str=str.." 2>/dev/null"

filesys.mkdirPath(settings.preview_dir)
os.execute(str)
end



function PreviewOneLine(font_name, path, format)

if settings.use_sixel == true
then
PreviewGenerate(path, format, 24, 26,'ABCDEFGHIK abcdefghijk 0123456789')
os.execute("cat "..settings.preview_dir.."/preview.six")
end

end



function PreviewFont(font, use_sixel, x, y)
local str, path

Out:move(1,Out:height() -2)
Out:puts("~mDownloading preview. Please wait.~>~0")
str=string.gsub(font.title, ' ', '_')
path=settings.preview_dir .. str.."/"
path=DownloadFontFile(font, path, "regular")
Out:move(1,Out:height() -2)
Out:puts("~>")

if path ~= nil
then
if use_sixel==true
then
	Out:move(x, y)
	PreviewGenerate(path, "sixel", 26, 200, font_title, "The Quick Brown Fox", "Jumped Over the Lazy Dog")
	--filesys.copy("preview.six", "-")
	os.execute("cat " .. settings.preview_dir .. "/preview.six")
else
	PreviewGenerate(path, "png", 26, 200, font_title, "The Quick Brown Fox", "Jumped Over the Lazy Dog")
	os.execute(settings.image_viewer .. " ".. settings.preview_dir .. "/preview.png")
end

--filesys.unlink(path)
end

end



-- adds backspace and left to the usual menu:run() command
function BasicMenuRun(menu)
local key

while true
do
menu:draw()
key=Out:getc()
if key == "ESC" then break end
if key == "BACKSPACE" then break end
if key == "LEFT" then break end
if key == "RIGHT" then return menu:curr() end
if key == "\n" then return menu:curr() end
if key == "w" then key="UP" end
if key == "i" then key="UP" end
if key == "s" then key="DOWN" end
if key == "k" then key="DOWN" end
menu:onkey(key)
end

return nil
end


function BottomBar(text)
local str

Out:move(0,Out:height()-1)
str=terminal.strtrunc(text, Out:width())

-- add this after truncate, as we need to have it whatever
str=str .. "~>~0"
Out:puts(str)
end


function BasicMenuBottomBar()
BottomBar("~B~yKeys: ~wup,w,i~y:move selection up  ~wdown,s,k~y:move selection down  ~wenter,right~y:select  ~wescape,backspace,left~y:back")
end




function DisplayFontInfo(font, source) 
local ch, S, str


while true
do
Out:clear()
Out:move(0,0)
Out:puts("~B~+w~e"..font.name.."~0~B~y  " .. " from " .. source .. "~>~0\n")
Out:puts("\n")

str="~eFoundry:~0 " .. tostring(font.foundry)
if strutil.strlen(font.license) == 0 then str=str.."  ~eLicense:~0 ~runknown~0\n"
else str=str..("  License: " .. font.license) .."\n" end
str=str.."~eCategory:~0 " .. font.category .. "  ~eStyle:~0 " .. font.style.. "  ~eWeight:~0"..font.weight.."\n"
Out:puts(str)
Out:puts("~eLanguages:~0 " .. font.languages .. "\n")
if strutil.strlen(font.description) > 0 then Out:puts("~eDescription:~0 "..font.description.."\n") end

if font.fileformat==".pcf" or font.fileformat==".pcf.gz" then Out:puts("\n~rThis is a PCF font, preview will likely not work~0\n"); end
if font.fileformat==".otb" or font.fileformat==".otb.gz" then Out:puts("\n~rThis is an OTB font, preview will likely not work~0\n"); end

if source == "installed" then BottomBar("~B~yKeys: ~wv~y:launch viewer  ~wescape~y:back  ~wbackspace~y:back")
else BottomBar("~B~yKeys: ~wv~y:launch viewer  ~wi~y:install font for user  ~wg~y:install font systemwide  ~wescape~y:back  ~wbackspace~y:back")
end

if settings.use_sixel == true
then
PreviewFont(font, true, 2, 6)
end

ch=Out:getc()
if ch == 'd' then filesys.copy(font.regular, font.name..".ttf")
elseif ch == 'i' then InstallFont(font, process.getenv("HOME").."/.local/share/fonts/", false)
elseif ch == 'g' then InstallFont(font, settings.fonts_dir, true)
elseif ch == 'v' then PreviewFont(font, false)
elseif ch == 't' then SetTerminalFont(font)
elseif ch == 'ESC' then break
elseif ch == 'LEFT' then break
elseif ch == 'BACKSPACE' then break
end
end

end



function FontListFind(fontlist, name)
local key, font

 for key,font in pairs(fontlist)
 do
  if font.name == name then return font end
 end

return nil
end



function DisplayFontsRun(menu, fonts, source, style)
local key, item

Out:clear()
while true
do
Out:move(0,0)

if source == "installed" then Out:puts("~B~wLocally installed fonts of style: ~y" .. style .. "~>~0")
else Out:puts("~B~wFonts available from "..source.." of style: ~y" .. style .. "~>~0")
end

BasicMenuBottomBar()

menu:draw()
key=Out:getc()
if key == "ESC" then break end
if key == "BACKSPACE" then break end
if key == "LEFT" then break end
if key == "w" then key="UP" end
if key == "i" then key="UP" end
if key == "s" then key="DOWN" end
if key == "k" then key="DOWN" end

menu:onkey(key)
item=menu:curr()
font=FontListFind(fonts, item)
if key == "\n" then return font end
if key == "RIGHT" then return font end

if font ~= nil
then
	if strutil.strlen(font.description) > 0
	then
	Out:move(1, Out:length() -2) 
	Out:puts(font.description.."~>")
	end

	if source=="installed"
	then
	Out:move(4, Out:length() - 4)
	PreviewOneLine(font.title, font.regular, "sixel")
	end
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

if source == "installed"
then
Menu=terminal.TERMMENU(Out, 1, 2, Out:width()-2, Out:height() - 8)
else
Menu=terminal.TERMMENU(Out, 1, 2, Out:width()-2, Out:height() - 5)
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
	elseif font.fontformat==".pcf.gz" then item="~r"..PadStr("pcf", 6).."~0"
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
  if font==nil then break end
  DisplayFontInfo(font, source)
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
DisplayFonts(source, style_list[selection], selection) 
end

end




function SelectFontSource()
local Menu, list
local selection

Out:clear()
Out:move(0,0)
Out:puts("~B~wFontPorter "..VERSION.."~>~0")

Menu=terminal.TERMMENU(Out, 1, 6, Out:width()-2, 10)
Menu:add("Locally Installed Fonts", "installed")
Menu:add("Fonts from Googlefonts", "googlefonts")
Menu:add("Fonts from FontSquirrel", "fontsquirrel")
Menu:add("Fonts from Elsewhere", "elsewhere")
Menu:add("Fonts from Mozilla", "mozilla")

BasicMenuBottomBar()

selection=BasicMenuRun(Menu)
if strutil.strlen(selection) > 0
then
	if selection=="installed" then list=InstalledFontsList() end
	if selection=="googlefonts" then list=GoogleFontsList() end
	if selection=="fontsquirrel" then list=FontSquirrelList() end
	if selection=="elsewhere" then list=ElsewhereFontsList() end
	if selection=="mozilla" then list=CDNList("https://code.cdn.mozilla.net/") end
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


settings.image_viewer=FindImageViewer()
ParseCommandLine()

Out=terminal.TERM()
--Out:timeout(0)
terminal.utf8(3)
process.lu_set("Error:Silent", "y")

while true
do
list_source,list=SelectFontSource()
if list_source==nil then break end
DisplayFontStyleMenu(list_source, list)
end

Out:reset()
Out:clear()
Out:move(0,0)
