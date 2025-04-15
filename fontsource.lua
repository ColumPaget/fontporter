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

