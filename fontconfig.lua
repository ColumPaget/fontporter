-- functions relating to the 'fontconfig' utility

function FontConfigParseDescription(input)
local font, toks, path, style, str

toks=strutil.TOKENIZER(input, ":") 

path=toks:next()

font={}
font.regular=path
font.title=strutil.trim(toks:next())
font.name=font.title .. " - "..filesys.basename(path)
font.style=""
font.spacing=""
font.foundry=""
font.languages=""
font.license=""

str=toks:next()
while str ~= nil
do
	if string.sub(str, 1, 8) == "foundry=" then font.foundry=string.sub(str, 9) 
	elseif string.sub(str, 1, 6) == "style=" then font.style=string.sub(str, 7)
	elseif string.sub(str, 1, 8) == "spacing=" then font.spacing=string.sub(str, 9)
	elseif string.sub(str, 1, 7) == "weight=" then font.weight=string.sub(str, 8)
	--this produces huge long strings of country-codes, with is more trouble than help
	--elseif string.sub(str, 1, 5) == "lang=" then font.languages=string.sub(str, 6)
	end
str=toks:next()
end

font.category=FontsParseStyle(font, path)
font.fileformat=filesys.extn(path)
font.fontformat=FontDeduceFormat(path)
return font
end



