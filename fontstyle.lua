-- functions related to font styles, sans, serif, monospace etc


function FontStyleCTX()
local ctx={}

ctx.italic=false 
ctx.bold=false
ctx.sans=false
ctx.serif=false
ctx.slab=false
ctx.blackletter=false
ctx.light=false
ctx.script=false
ctx.monospace=false
ctx.display=false
ctx.symbol=false
ctx.retro=false
ctx.comic=false
ctx.barcode=false
ctx.music=false

return ctx
end


-- turn a font style into a number in a list (used in 'font style compare' to order fonts)
function FontStyleEnumerate(style)
local styles={"regular", "serif", "sans-serif", "slab-serif", "monospace", "bold", "bold light", "bold italic", "italic", "light", "script", "display", "retro", "blackletter", "comic", "symbol"}
local i, found

if style == nil then return 0 end
for i,found in ipairs(styles)
do
  if found == style then return i end
end

return 999
end


-- compare font style names in such a way that we can sort them in order
function FontStyleCompare(s1, s2)
local i1, i2

i1=FontStyleEnumerate(s1)
i2=FontStyleEnumerate(s2)

return i1 < i2
end


function FontStyleExamineString(ctx, str)
local toks, tok

toks=strutil.TOKENIZER(str, "\\S|,", "m")
tok=toks:next()
while tok ~= nil
do
 tok=string.lower(tok)
 if tok=="barcode" then ctx.barcode=true end
 if tok=="music" then ctx.music=true end
 if tok=="grunge" then ctx.display=true end
 if tok=="comic" then ctx.comic=true end
 if tok=="retro" then ctx.retro=true end
 if tok=="stencil" then ctx.display=true end
 if tok=="display" then ctx.display=true end
 if tok=="novelty" then ctx.display=true end
 if tok=="italic" then ctx.italic=true end
 if tok=="oblique" then ctx.italic=true end
 if tok=="bold" then ctx.bold=true end
 if tok=="serif" then ctx.serif=true end
 if tok=="sans" then ctx.sans=true end
 if tok=="sans-serif" then ctx.sans=true end
 if tok=="sans serif" then ctx.sans=true end
 if tok=="slab" then ctx.slab=true end
 if tok=="slab-serif" then ctx.slab=true end
 if tok=="slab serif" then ctx.slab=true end
 if tok=="blackletter" then ctx.blackletter=true end
 if tok=="medieval" then ctx.blackletter=true end
 if tok=="roman" then ctx.serif=true end
 if tok=="thin" then ctx.light=true end
 if tok=="light" then ctx.light=true end
 if tok=="extralight" then ctx.light=true end
 if tok=="script" then ctx.script=true end
 if tok=="handwriting" then ctx.script=true end
 if tok=="caligraphic" then ctx.script=true end
 if tok=="calligraphic" then ctx.script=true end
 if tok=="handdrawn" then ctx.script=true end
 if tok=="pixel" then ctx.monospace=true end
 if tok=="mono" then ctx.monospace=true end
 if tok=="monospace" then ctx.monospace=true end
 if tok=="monospaced" then ctx.monospace=true end
 if tok=="programming" then ctx.monospace=true end
 if tok=="typewriter" then ctx.monospace=true end
 if tok=="symbol" then ctx.symbol=true end
 if tok=="cursor" then ctx.symbol=true end
 if tok=="dingbat" then ctx.symbol=true end
 if tok=="wingdings" then ctx.symbol=true end
 if tok=="icon" then ctx.symbol=true end
 if tok=="emoji" then ctx.symbol=true end
tok=toks:next()
end

end


-- try to figure out the style of a font
-- this is an involved process as people will -- call fonts many things, for example
-- 'cursive' 'handwriting', 'script', 'handdrawn' can all relate to the same style
function FontsParseStyle(font, filename)
local toks, tok, str, ctx

ctx=FontStyleCTX()


if strutil.strlen(font.spacing) > 0 then ctx.monospace=true end

str=string.lower(filename)
if string.find(str, "handwriting") ~= nil then ctx.script=true end
if string.find(str, "barcode") ~= nil then ctx.barcode=true end
if string.find(str, "roman") ~= nil then ctx.serif=true end
if string.find(str, "slab") ~= nil then ctx.slab=true end
if string.find(str, "stencil") ~= nil then ctx.display=true end

if string.find(str, "sans") ~= nil then ctx.sans=true
elseif string.find(str, "serif") ~= nil then ctx.serif=true end

str=string.lower(font.title)
if string.find(str, "handwriting") ~= nil then ctx.script=true end
if string.find(str, "barcode") ~= nil then ctx.barcode=true end
if string.find(str, "roman") ~= nil then ctx.serif=true end
if string.find(str, "slab") ~= nil then ctx.slab=true end
if string.find(str, "stencil") ~= nil then ctx.display=true end
if string.find(str, "mono") ~= nil then ctx.monospace=true end
if string.find(str, "symbol") ~= nil then ctx.symbol=true end

if string.find(str, "sans") ~= nil then ctx.sans=true
elseif string.find(str, "serif") ~= nil then ctx.serif=true end


FontStyleExamineString(ctx, font.style)
FontStyleExamineString(ctx, font.info)

if ctx.symbol == true then return("symbol") end
if ctx.music == true then return("music") end
if ctx.barcode == true then return("barcode") end
if ctx.comic == true then return("comic") end
if ctx.retro == true then return("retro") end
if ctx.script == true then return("script") end
if ctx.blackletter == true then return("blackletter") end
if ctx.slab == true then return("slab-serif") end
if ctx.display == true then return("display") end
if ctx.monospace == true then return("monospace") end

if ctx.italic == true 
then 
if ctx.bold == true then return("bold italic") end
if ctx.light == true then return("bold light") end
return("italic") 
end

if ctx.bold == true then return("bold") end
if ctx.light == true then return("light") end

--sans must come before serif, as a font could have both set
if ctx.sans == true then return("sans-serif") end
if ctx.serif == true then return("serif") end

return("regular")

end

