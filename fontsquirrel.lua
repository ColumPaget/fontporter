--this module relates to getting fonts from the fontsquirrel API


function FontSquirrelList()
local P, item, font
local categories={}

P=GetCachedJSON("http://www.fontsquirrel.com/api/fontlist/all", "fontsquirrel")
if P ~= nil
then
item=P:next()
while item ~= nil
do
font={}
font.name=item:value("family_name")
font.foundry=item:value("foundry_name")
font.title=font.name
font.style=item:value("classification")
font.regular="https://www.fontsquirrel.com/fonts/download/" .. item:value("family_urlname")
font.languages=""
font.weight=""
font.fileformat=".zip"
font.fontformat=filesys.extn(item:value("font_filename"))
FontListAdd(categories, font)

item=P:next()
end
end

return categories
end

