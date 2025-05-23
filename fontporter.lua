-- 'includes', required function libraries for this app

require("stream")
require("strutil")
require("process")
require("dataparser")
require("terminal")
require("filesys")
require("xml")
require("net")
require("time")

-- default settings for fontporter

function InitSettings()

settings={}
settings.use_sixel=false
settings.fonts_dir="/usr/share/fonts/"
--settings.preview_dir=process.getenv("HOME") .. "/.font_preview/"
settings.preview_dir="/tmp/.font_preview/"

settings.image_viewer=FindImageViewer()

end
-- helper functions relating to URLs

-- given a current url, and a 'new_url' that might be either a full url,
-- or a relative path from the current url, either:
-- 1) return 'new_url' if it's a full url
-- 2) return a new full url by combining current_url and the relative 'new_url
function URLFromCurrent(current_url, new_url)
local URL

if string.sub(new_url, 1, 5) == "http:" then return new_url end
if string.sub(new_url, 1, 6) == "https:" then return new_url end

if string.sub(new_url, 1, 1) ~= "/" then return(filesys.dirname(current_url) .. "/" .. new_url) end

URL=net.parseURL(current_url)
return(URL.type.."://"..URL.host..":"..URL.port..new_url)
end

-- this module relates to caching files that have been downloaded


function CachedFileOpen(url, source)
local S, doc, str, cache_path, when

cache_path=process.getenv("HOME").."/.local/cache/fontporter/"..source..".json"

-- don't cache files for more than an hour
now=time.secs()
when=filesys.mtime(cache_path)
if now - when < 3600
then
S=stream.STREAM(cache_path)
if S ~= nil then return(S) end
end

--if we got here, then we didn't find the item in the cache, or it was too old
doc=""
S=stream.STREAM(url)
str=S:readln()
while str ~= nil
do
doc=doc..str
str=S:readln()
end
S:close()

filesys.mkdirPath(cache_path)
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

-- functions relating to building a list of fonts either installed
-- or offered by a service

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


function FontListFind(fontlist, name)
local key, font

 for key,font in pairs(fontlist)
 do
  if font.name == name then return font end
 end

return nil
end




function ExecSubcommand(cmd)
local proc, str

   Out:move(0, 7)
   proc=process.PROCESS(cmd, "")
   str=proc:readln()
   while str
   do
   str=strutil.trim(str)
   Out:puts("~>" .. str.."~>\n")
   str=proc:readln()
   end

end
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

-- functions related to font styles, sans, serif, monospace etc


function FontStyleCTX()
local ctx={}

ctx.italic=false 
ctx.bold=false
ctx.sans=false
ctx.serif=false
ctx.slab=false
ctx.blackletter=false
ctx.light=false
ctx.script=false
ctx.monospace=false
ctx.display=false
ctx.symbol=false
ctx.retro=false
ctx.comic=false
ctx.barcode=false
ctx.music=false

return ctx
end


-- turn a font style into a number in a list (used in 'font style compare' to order fonts)
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


-- compare font style names in such a way that we can sort them in order
function FontStyleCompare(s1, s2)
local i1, i2

i1=FontStyleEnumerate(s1)
i2=FontStyleEnumerate(s2)

return i1 < i2
end


function FontStyleExamineString(ctx, str)
local toks, tok

toks=strutil.TOKENIZER(str, "\\S|,", "m")
tok=toks:next()
while tok ~= nil
do
 tok=string.lower(tok)
 if tok=="barcode" then ctx.barcode=true end
 if tok=="music" then ctx.music=true end
 if tok=="grunge" then ctx.display=true end
 if tok=="comic" then ctx.comic=true end
 if tok=="retro" then ctx.retro=true end
 if tok=="stencil" then ctx.display=true end
 if tok=="display" then ctx.display=true end
 if tok=="novelty" then ctx.display=true end
 if tok=="italic" then ctx.italic=true end
 if tok=="oblique" then ctx.italic=true end
 if tok=="bold" then ctx.bold=true end
 if tok=="serif" then ctx.serif=true end
 if tok=="sans" then ctx.sans=true end
 if tok=="sans-serif" then ctx.sans=true end
 if tok=="sans serif" then ctx.sans=true end
 if tok=="slab" then ctx.slab=true end
 if tok=="slab-serif" then ctx.slab=true end
 if tok=="slab serif" then ctx.slab=true end
 if tok=="blackletter" then ctx.blackletter=true end
 if tok=="medieval" then ctx.blackletter=true end
 if tok=="roman" then ctx.serif=true end
 if tok=="thin" then ctx.light=true end
 if tok=="light" then ctx.light=true end
 if tok=="extralight" then ctx.light=true end
 if tok=="script" then ctx.script=true end
 if tok=="handwriting" then ctx.script=true end
 if tok=="caligraphic" then ctx.script=true end
 if tok=="calligraphic" then ctx.script=true end
 if tok=="handdrawn" then ctx.script=true end
 if tok=="pixel" then ctx.monospace=true end
 if tok=="mono" then ctx.monospace=true end
 if tok=="monospace" then ctx.monospace=true end
 if tok=="monospaced" then ctx.monospace=true end
 if tok=="programming" then ctx.monospace=true end
 if tok=="typewriter" then ctx.monospace=true end
 if tok=="symbol" then ctx.symbol=true end
 if tok=="cursor" then ctx.symbol=true end
 if tok=="dingbat" then ctx.symbol=true end
 if tok=="wingdings" then ctx.symbol=true end
 if tok=="icon" then ctx.symbol=true end
 if tok=="emoji" then ctx.symbol=true end
tok=toks:next()
end

end


-- try to figure out the style of a font
-- this is an involved process as people will -- call fonts many things, for example
-- 'cursive' 'handwriting', 'script', 'handdrawn' can all relate to the same style
function FontsParseStyle(font, filename)
local toks, tok, str, ctx

ctx=FontStyleCTX()


if strutil.strlen(font.spacing) > 0 then ctx.monospace=true end

str=string.lower(filename)
if string.find(str, "handwriting") ~= nil then ctx.script=true end
if string.find(str, "barcode") ~= nil then ctx.barcode=true end
if string.find(str, "roman") ~= nil then ctx.serif=true end
if string.find(str, "slab") ~= nil then ctx.slab=true end
if string.find(str, "stencil") ~= nil then ctx.display=true end

if string.find(str, "sans") ~= nil then ctx.sans=true
elseif string.find(str, "serif") ~= nil then ctx.serif=true end

str=string.lower(font.title)
if string.find(str, "handwriting") ~= nil then ctx.script=true end
if string.find(str, "barcode") ~= nil then ctx.barcode=true end
if string.find(str, "roman") ~= nil then ctx.serif=true end
if string.find(str, "slab") ~= nil then ctx.slab=true end
if string.find(str, "stencil") ~= nil then ctx.display=true end
if string.find(str, "mono") ~= nil then ctx.monospace=true end
if string.find(str, "symbol") ~= nil then ctx.symbol=true end

if string.find(str, "sans") ~= nil then ctx.sans=true
elseif string.find(str, "serif") ~= nil then ctx.serif=true end


FontStyleExamineString(ctx, font.style)
FontStyleExamineString(ctx, font.info)

if ctx.symbol == true then return("symbol") end
if ctx.music == true then return("music") end
if ctx.barcode == true then return("barcode") end
if ctx.comic == true then return("comic") end
if ctx.retro == true then return("retro") end
if ctx.script == true then return("script") end
if ctx.blackletter == true then return("blackletter") end
if ctx.slab == true then return("slab-serif") end
if ctx.display == true then return("display") end
if ctx.monospace == true then return("monospace") end

if ctx.italic == true 
then 
if ctx.bold == true then return("bold italic") end
if ctx.light == true then return("bold light") end
return("italic") 
end

if ctx.bold == true then return("bold") end
if ctx.light == true then return("light") end

--sans must come before serif, as a font could have both set
if ctx.sans == true then return("sans-serif") end
if ctx.serif == true then return("serif") end

return("regular")

end

-- functions relating to the 'fontconfig' utility

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
font.fontformat=FontDeduceFormat(path)
return font
end



-- functions relating to generating font previews

function PreviewGenerate(path, style, format, pointsize, height, line1, line2, line3, line4, line5)
local str, width, line, i
local lines={}
local pos=0

filesys.mkdirPath(settings.preview_dir)

table.insert(lines, line1)
table.insert(lines, line2)
table.insert(lines, line3)
table.insert(lines, line4)
table.insert(lines, line5)

if style=="terminal"
then
width=string.format("%d", (pointsize +2) * 40)
else width=string.format("%d", Out:width() * 6)
end

str="convert -font '" .. path .. "' -pointsize " .. tostring(pointsize) 
str=str.." -size " .. tostring(width) .. "x" .. tostring(height)

if style == "terminal"
then
pos=20
str=str.." -background black -fill green gravity left xc:"
else
--pos=-40
str=str.." -fill '#000000' -gravity center xc:"
end

for i,line in ipairs(lines)
do
if strutil.strlen(line) > 0 then str=str .. " -annotate +10+" .. tostring(pos)..  " '" .. line .. "'" end
pos = pos + pointsize + 6
end

str=str.." -flatten "

if format=="sixel" then str=str.."sixel:"..settings.preview_dir.."/preview.six "
else str=str..settings.preview_dir.."/preview.png "
end

str=str.." 2>/dev/null"

os.execute(str)
end



function PreviewOneLine(font_name, path, format)

if settings.use_sixel == true
then
PreviewGenerate(path, "", format, 24, 26,'ABCDEFGHIK abcdefghijk 0123456789')
os.execute("cat "..settings.preview_dir.."/preview.six")
end

end



function PreviewFont(font, use_sixel, x, y, style, line1, line2, line3, line4, line5)
local str, path, destdir
local pointsize=26
local height=200

if style=="terminal"
then
pointsize=14
end

Out:move(1,Out:height() -2)
Out:puts("~mDownloading preview. Please wait.~>~0")
str=string.gsub(font.title, ' ', '_')
destdir=settings.preview_dir .. str.."/"

filesys.mkdirPath(destdir)
path=DownloadCheckForFontFile(destdir)
if path == nil then path=DownloadFontFile(font, destdir, "regular") end


Out:move(1,Out:height() -2)
Out:puts("~>")

if path ~= nil
then
if use_sixel==true
then
	Out:move(x, y)
	PreviewGenerate(path, style, "sixel", pointsize, height, line1, line2, line3, line4, line5)
	--filesys.copy("preview.six", "-")
	os.execute("cat " .. settings.preview_dir .. "/preview.six")
else
	PreviewGenerate(path, style, "png", pointsize, height, line1, line2, line3, line4, line5)
	os.execute(settings.image_viewer .. " ".. settings.preview_dir .. "/preview.png")
end

--filesys.unlink(path)
end

end


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

--functions related to image viewers

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


-- this module contains functions relating to the 'elsewhere' list of fonts
-- that is fonts not available through one of the standard APIs 


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
font.info=toks:next()
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
if S == nil then S=stream.STREAM("/etc/fonts-elsewhere.conf","r") end

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



-- stuff related to the 'fontsource' API and website

function FontSourceGetFontDetails(font)
local P, item, list
local categories={}

P=GetCachedJSON("http://api.fontsource.org/v1/fonts/" .. font.name, "fontsource.org:"..font.name)
font.regular=P:value("/variants/400/normal/latin/url/ttf")
font.italic=P:value("/variants/400/italic/latin/url/ttf")

end



function FontSourceGetSubsets(font_info)
local subsets, item
local str=""

subsets=font_info:open("subsets")
item=subsets:next()
while item ~= nil
do
str=str..item:value()..","
item=subsets:next()
end

return str
end


function FontSourceList()
local P, item, font, list
local categories={}

P=GetCachedJSON("http://api.fontsource.org/v1/fonts", "fontsource.org")
item=P:next()
while item ~= nil
do
font={}
font.name=item:value("id")
font.foundry=item:value("type")
font.title=item:value("family")
font.style=item:value("category")
font.license=item:value("license")
font.category=FontsParseStyle(font, "")

font.languages=FontSourceGetSubsets(item)
font.weight=""
font.fileformat=".ttf"
font.fontformat=filesys.extn(item:value("font_filename"))
FontListAdd(categories, font)

item=P:next()
end

return categories
end

--this module relates to getting fonts from the fontsquirrel API


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

-- functions relating to getting font from googlefonts webfont API

function GoogleFontsList()
local P, I, item, font
local fonts={}
local languages={}
local categories={}

P=GetCachedJSON("https://www.googleapis.com/webfonts/v1/webfonts?key=" .. GOOGLEFONTS_API_KEY, "googlefonts")
I=P:open("/items")

item=I:next()
while item ~= nil
do
font={}
font.name=item:value("family")
font.title=font.name
font.style=item:value("category")
font.category=FontsParseStyle(font, "")

font.regular=item:value("files/regular")
font.italic=item:value("files/italic")
font.languages=FontLanguages(item)
font.fileformat=filesys.extn(font.regular)
font.fontformat=filesys.extn(font.regular)
font.weight=""
FontListAdd(categories, font)

item=I:next()
end

return(categories)
end

-- functions relating to getting fonts from Mozilla's MozillaCDN


function MozillaCDNParseFontFace(current_url, toks)
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


function MozillaCDNGetCSS(url, categories) 
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
		font=MozillaCDNParseFontFace(url, toks)
		if strutil.strlen(font.regular) > 0 then FontListAdd(categories, font) end
	end
tok=toks:next()
end
end

end



function MozillaCDNList(url)
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
	if filesys.extn(tag.data) == ".css" then MozillaCDNGetCSS( URLFromCurrent(url, tag.data), categories ) end
	end
	tag=toks:next()
end

return categories
end



-- functions relating to getting fonts from omnibus-type.com


function OmnibusTypeFontAdd(categories, name, url)
local font

if strutil.strlen(name) == 0 then return end
if strutil.strlen(url) == 0 then return end

font={}
font.foundry="Omnibus-Type"
font.license="SIL OFL 1.1"
font.name=name
font.title=font.name
font.style="serif"
font.languages=""
font.category=FontsParseStyle(font, "")
font.weight=0
font.regular=url
font.fileformat="otf"
font.fontformat="otf"

--[[
font.languages=FontLanguages(item)
font.fileformat=filesys.extn(font.regular)
font.fontformat=filesys.extn(font.regular)
font.weight=""
]]--

FontListAdd(categories, font)
end





function OmnibusTypeFontsList()
local S, doc, toks, item, font, name, url, download
local fonts={}
local languages={}
local categories={}

S=CachedFileOpen("https://www.omnibus-type.com/", "omnibus-type")
if S ~= nil
then
doc=S:readdoc()
S:close()

toks=xml.XML(doc)
item=toks:next()
while item ~= nil
do
  if item.type ~= nil and string.lower(item.type) == "a"  
	then

	str=string.sub(item.data, 1, 41) 
	if str == "href=\"https://www.omnibus-type.com/fonts/"
	then
	url=strutil.stripQuotes(string.sub(item.data, 6))
	item=toks:next() -- <span>
	item=toks:next()
	name=item.data
	download="https://www.omnibus-type.com/wp-content/uploads/" .. string.gsub(name, " ", "-") .. ".zip"
  if name ~= nil and download ~= nil then OmnibusTypeFontAdd(categories, name, download) end
	end

	end
item=toks:next()
end
end

return(categories)
end


-- stuff related to the 'nerdfonts.com' website

function NerdFontsExtractURL(data)
local toks, item, url

toks=strutil.TOKENIZER(data, "\\S", "Q")
item=toks:next()
while item ~= nil
do
if string.sub(item, 1, 5) == "href=" then url=strutil.stripQuotes(string.sub(item, 6)) end
item=toks:next()
end

return url
end



function NerdFontsNew()
local font={}

font.foundry="nerdfonts.com"
font.license="SIL OFL 1.1"
font.style="serif"
font.category=""
font.languages=""
font.weight=0

return font
end


function NerdFontsParseFont(toks) 
local item, font


font=NerdFontsNew()
item=toks:next()
while item ~= nil
do
if item.type == "a"
then
  font.regular=NerdFontsExtractURL(item.data)
elseif item.type == "span" and item.data == "class=\"nerd-font-invisible-text\""
then
  font.name=strutil.htmlUnQuote(toks:next().data)
  font.title=font.name
elseif item.type == "strong"
then
  item=toks:next()
  if string.sub(item.data, 1, 15)=="&bull; Version:"
  then
  item=toks:next()
  font.version=strutil.htmlUnQuote(toks:next().data)
  elseif string.sub(item.data, 1, 12)=="&bull; Info:"
  then
  item=toks:next()
  font.info=strutil.htmlUnQuote(toks:next().data)
  end
elseif item.type == "div" and item.data == "class=\"nerd-font-buttons-wrapper\"" 
then 
  break
end

item=toks:next()
end

font.fileformat=filesys.extn(font.regular)
font.fontformat="otf"
font.category=FontsParseStyle(font, "")


return font
end



function NerdFontsList()
local P, item, font, list
local categories={}

S=CachedFileOpen("https://www.nerdfonts.com/font-downloads", "nerdfonts.com")
if S ~= nil
then
doc=S:readdoc()
S:close()

toks=xml.XML(doc)
item=toks:next()
while item ~= nil
do
  if item.type == "div" and item.data == "class=\"item\""
  then 
    if font ~= nil then FontListAdd(categories, font) end
     font=NerdFontsParseFont(toks)
  end
  item=toks:next()
end
end

return categories

end
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
