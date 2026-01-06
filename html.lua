
function UnHTML(text)
local tags
local str=""

tags=xml.XML(text)
tag=tags:next()
while tag ~= nil
do
if tag.type == nil then str=str..tag.data end
tag=tags:next()
end

return strutil.htmlUnQuote(str)
end
