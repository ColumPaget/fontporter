--this module relates to getting fonts from the fontsquirrel API


function FontShareList()
local P, fonts, item, font
local categories={}

P=GetCachedJSON("https://api.fontshare.com/v2/fonts/", "fontshare.com")
if P ~= nil
then
fonts=P:open("fonts")
if fonts ~= nil
then
   item=fonts:next()
   while item ~= nil
   do
   font={}
   font.name=item:value("name")
   font.foundry=item:value("foundry_name")
   font.title=font.name
   font.style=item:value("category")
   font.regular="https://api.fontshare.com/v2/fonts/download/" .. item:value("slug")
   font.languages=item:value("languages")
   font.weight=""
   font.license=item:value("license_type")
   font.description=UnHTML(item:value("story"))
   font.fileformat=".zip"
   font.fontformat=".ttf"
   FontListAdd(categories, font)
   
   item=fonts:next()
   end
end
end

return categories
end

