-- functions relating to the 'fontconfig' utility



function FontDeduceFormat(path)
local fmt, str

fmt=filesys.extn(path)
if fmt == ".gz" or fmt == ".bz2" or fmt == ".xz"
then
str=filesys.filename(path)
fmt=filesys.extn(str)
end

if fmt then fmt=string.lower(fmt) end

return fmt
end


function FontConfigConvertLangCodes(font)
local locales={ ar="arabic", be="belarusian", bn="bengali", bo="tibetan", bs="bosnian", de="german", en="english", el="greek", es="spanish", fr="french", it="italian", hi="hindi", cr="cree", chr="cherokee", fa="persian", ga="gujarati", he="hebrew", iw="hebrew", hr="croat", hu="hungarian", ia="interlingua", io="ido", is="icelandic", jp="japanese", km="khmer", ko="korean", kn="kannada", la="latin", lt="lithuanian", mk="macedonian", ml="malayalam", mn="mongolian", nl="dutch", oj="ojibwa", pl="polish", pt="portuguese", qya="quenya", ru="russian", sa="sanskrit", si="sinhala", sjn="sindarin", so="somali", sr="serbian", ss="swati", sw="swahili", sv="swedish", ta="tamil", te="telugu", th="thai", tlh="klingon", tg="tajik", tr="turkish", tt="tatar", ug="uighur", uk="ukrainian", ur="urdu", vi="vietnamese", xh="xhosa", zh="chinese", zu="zulu"}
local toks, tok

toks=strutil.TOKENIZER(font.langcodes, "|")
tok=toks:next()
while tok ~= nil
do
pos=string.find(tok, '-')
if pos ~= nil and pos > 0 then tok=string.sub(tok, 1, pos-1) end
if locales[tok] ~= nil then font.languages=font.languages .. locales[tok].."," end
tok=toks:next()
end

end



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
font.langcodes=""

str=toks:next()
while str ~= nil
do
	if string.sub(str, 1, 8) == "foundry=" then font.foundry=string.sub(str, 9) 
	elseif string.sub(str, 1, 6) == "style=" then font.style=string.sub(str, 7)
	elseif string.sub(str, 1, 8) == "spacing=" then font.spacing=string.sub(str, 9)
	elseif string.sub(str, 1, 7) == "weight=" then font.weight=string.sub(str, 8)
	elseif string.sub(str, 1, 5) == "lang=" then font.langcodes=string.sub(str, 6)
	end
str=toks:next()
end

if font.spacing=="100" 
then 
if font.style ~= "" then font.style=font.style.."," end
font.style=font.style .."monospace" 
end

FontConfigConvertLangCodes(font)
font.category=FontsParseStyle(font, path)
font.fileformat=filesys.extn(path)
font.fontformat=FontDeduceFormat(path)
return font
end



