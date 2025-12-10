-- these are commonly used utility functions


function TableToString(table)
local i,value
local retstr=""

for i,value in ipairs(table)
do
if retstr == "" then retstr=value
else retstr=retstr..","..value
end
end

return retstr
end


function ParserListToString(P)
local item
local str=""

if P ~= nil
then
  item=P:next()
  while item ~= nil
  do
        str=str..item:value()..","
        item=P:next()
  end
end

return str
end

