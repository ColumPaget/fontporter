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

