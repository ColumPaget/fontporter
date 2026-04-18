-- functions relating to building a list of fonts either installed
-- or offered by a service

function FontCategoryAdd(categories, font, category)
local cat, id

id=font.name..tostring(font.fileformat)..tostring(font.weight)

cat=categories[category] 
if cat == nil
then 
cat={}
categories[category]=cat 
end

cat[id]=font

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

function FontListCategoryFinalize(category)
local new_cat={}
local key, font

for key,font in pairs(category)
do
table.insert(new_cat, font)
end

return new_cat
end


function FontListFinalize(fonts_list)
local key, category

for key,category in pairs(fonts_list)
do
fonts_list[key]=FontListCategoryFinalize(category)
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



