
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
