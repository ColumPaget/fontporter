

function SentyFontsNameFromFile(filename)
local pos, val, len, char, prev
local name=""

filename=strutil.httpUnQuote(filename)

--correct some typos and other issues
filename=string.gsub(filename, "SIlkRoad", "SilkRoad")
filename=string.gsub(filename, "WoodCut", "Woodcut")
filename=string.gsub(filename, "PaperCut", "Papercut")

len=strutil.strlen(filename)
for pos = 1,len
do
char=string.sub(filename, pos, pos)
if char == '.' then break end

val=string.byte(char)
if val >= 65 and val <=90 and prev ~= " " then name=name.." " end
name=name..char
prev=char
end

return name
end


function SentyFontsStyleMatch(font_name, style_strings, style_name)
local i, item
local retstr=""

for i,item in ipairs(style_strings)
do
  if string.find(font_name, item) ~= nil 
  then 
    if style_name==nil then retstr=retstr..item.."," 
    else retstr=retstr..style_name..","
    end
  end
end

return retstr
end


function SentyFontsGuessStyles(name)
local str, i, item
local style_strings={"woodcut", "calligraphy", "handwriting"}
local handwriting={"senty orchid", "senty donut", "senty sigua", "senty creek", "senty fountain pen", "hanyi senty scholar", "hanyi senty bubble tea", "senty caramal", "hanyi senty joy", "hanyi senty silk road", "hanyi senty diary", "hanyi senty journal", "hanyi senty cream puff", "hanyi senty pea","hanyi senty tea", "hanyi senty sea spray", "senty vanlilla", "senty tamarind"}
local display={"inscription", "senty ethereal wander", "senty watermelon", "movable type", "fun park", "chocolate", "sandlewood", "hanyi senty pastels", "chalk", "graffiti", "crayon","papercut"}
local calligraphy={"scroll", "brush", "senty cloud", "scholar", "suci tablet", "zhangjizhi", "encyclopedia", "hanyi senty wen","senty zhao"}
local historical={"song", "tang"}
local style=""

str=string.lower(name)

style=style..SentyFontsStyleMatch(str, style_strings)
style=style..SentyFontsStyleMatch(str, handwriting, "handwriting")
style=style..SentyFontsStyleMatch(str, display, "display")
style=style..SentyFontsStyleMatch(str, historical, "historical")
style=style..SentyFontsStyleMatch(str, calligraphy, "calligraphy")

if style == "" then return "regular" end
return style
end


function SentyFontsLoadFont(link) 
local url
local font={}

link=strutil.stripQuotes(link)

if filesys.extn(link) ~= ".ttf" then return null end

font.foundry="sentyfont.com"
font.license="Non Commercial"
font.category=""
font.languages="latin,chinese"
font.weight=0
font.regular="https://www.sentyfont.com/" .. link

font.name=filesys.basename(link)
font.title=SentyFontsNameFromFile(font.name)
font.style=SentyFontsGuessStyles(font.title)

return font
end


function SentyFontsParseAnchor(categories, data)
local toks, tok, font

toks=strutil.TOKENIZER(data, " ")
tok=toks:next()
while tok ~= nil
do
    if string.sub(tok, 1, 5)=="href="
    then 
    font=SentyFontsLoadFont(string.sub(tok, 6))
    if font ~= nil then FontListAdd(categories, font) end
    end
tok=toks:next()
end

end


function SentyFontsList()
local S, str, tags, tag
local categories={}


S=CachedFileOpen("https://www.sentyfont.com/download.htm", "sentyfont.com")
if S ~= nil
then
str=S:readdoc()
S:close()

tags=xml.XML(str)
tag=tags:next()
while tag ~= nil
do
  if tag.type=="a" then SentyFontsParseAnchor(categories, tag.data) end
  tag=tags:next()
end
end

return categories
end
