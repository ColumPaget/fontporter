-- these functions provide a 'base menu' that is then used by higher-level display functions
-- that implement specific menus like list of fonts, or list of font categories


-- adds backspace and left to the usual menu:run() command
-- accepts a callback function to display info about items
-- in the menu list as they are highlighted
function BasicMenuRun(menu, callback, callback_arg)
local key

while true
do
menu:draw()

if callback ~= nil then callback(menu, menu:curr(), callback_arg) end

key=Out:getc()


if key == "ESC" then return "EXIT"
elseif key == "BACKSPACE" then return "EXIT"
elseif key == "LEFT" then return "EXIT"
elseif key == "RIGHT" then return menu:curr()
elseif key == "\n" then return menu:curr()
elseif key == "w" then key="UP"
elseif key == "i" then key="UP"
elseif key == "s" then key="DOWN"
elseif key == "k" then key="DOWN"
elseif process.sigcheck(process.SIGWINCH) == true
then
process.sigwatch(process.SIGWINCH)
return "RESIZE"
end


menu:onkey(key)
end

return nil
end


function BottomBar(text)
local str, toks, line, i
local lines={}

toks=strutil.TOKENIZER(text, "\n")
line=toks:next()
while line ~= nil
do
table.insert(lines, line)
line=toks:next()
end


str=""
Out:move(0,Out:height() - (#lines))
for i, line in ipairs(lines)
do
if i > 1 then str=str.."\n" end
str=str..terminal.strtrunc(line, Out:width()) .."~>"
end

-- add this after truncate, as we need to go back to normal colors 
-- and can't afford to have this cut off by truncate
str=str .. "~0"

Out:puts(str)
end


function BasicMenuBottomBar()
BottomBar("~B~yKeys: ~wup,w,i~y:move selection up  ~wdown,s,k~y:move selection down  ~wenter,right~y:select  ~wescape,backspace,left~y:back")
end



function MenuColorLicence(licence)
local toks, tok
local retstr=""

toks=strutil.TOKENIZER(licence, ",")
tok=toks:next()
while tok ~= nil
do
if tok=="OFL-1.1" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="SIL OFL 1.1" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="LGPL" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="GPLv2" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="GPLv2+" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Apache" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Apache v2" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="MIT" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Public Domain" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Non Commercial" then retstr=retstr.. "~y"..tok.."~0 " end
if tok=="unknown" then retstr=retstr.. "~r"..tok.."~0 " end
tok=toks:next()
end

if retstr=="" then retstr="~0"..licence end

return retstr
end
