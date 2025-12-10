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


--FontCategoryAdd(categories, font, font.category)

if strutil.strlen(font.fileformat) == 0 then font.fileformat=filesys.extn(font.regular) end
font.category=FontsParseStyle(font, "")

toks=strutil.TOKENIZER(font.category, ",")
tok=toks:next()
while tok ~= nil
do
FontCategoryAdd(categories, font, tok)
tok=toks:next()
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


