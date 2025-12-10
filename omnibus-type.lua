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
font.weight=0
font.regular=url
font.fileformat="otf"
font.fontformat="otf"

font.languages=""

FontListAdd(categories, font)
end





function OmnibusTypeFontsList()
local S, doc, toks, item, font, name, url, download
local fonts={}
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

