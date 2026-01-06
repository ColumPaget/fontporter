-- functions related to font styles, sans, serif, monospace etc
-- some of the functions in here try to 'guess' fonts styles by looking for strings in the name, language list or description
-- as some short strings, like "cree" can turn up in names and description as e.g. 'creek' or 'creepy' so we have different
-- word 'alias' lists for name, languages and 'style'

font_style_aliases={
serif={"roman"},
greek={"greek"},
display={"display", "grunge", "stencil", "novelty", "signwriting", "signage", "retro", "woodcut"},
blackletter={"blackletter", "medieval", "medeival", "gothic", "woodcut"},
handwriting={"script", "handwriting", "handdrawn"},
calligraphy={"caligraphic", "calligraphic", "caligraphy", "calligraphy"},
monospace={"mono", "monospace", "monospaced", "pixel", "programming", "typewriter","courier"},
sans_serif={"sans", "sans.serif","humanist"},
slab_serif={"slab", "slab.serif"},
light={"^light", "^thin%s", "%sthin%s", "extralight", "narrow"},
symbol={"symbol", "emoji", "math", "music"},
barcode={"barcode","code128","code.128","code39","code.39","ean13","ean.13","codabar","databar"},
music={"music", "score"},
comic={"comic", "cartoon", "comedy"},
italic={"italic", "oblique"},
bold={"bold"},
cyrillic={"russian","ukrainian","bulgarian","bosnian","serbian","belarusian","tatar","tajik"},
native_american={"cherokee","algonquian","ojibwe"},
mesoamerican={"aztec","olmec","toltec","mixtec","zaptoec"},
chinese={"chinese", "pinyin"},
india={"hindi","devanagari", "bangla", "bengali", "kannada","gujarati", "gurumukhi", "gurmukhi", "malayalam", "tamil","telugu", "telugua", "meitei", "gupta", "sanskrit","brahmic"},
korean={"hangul", "korean"},
japanese={"hiragana", "katakana"},
persian={"farsi", "persian"},
other_asian={"khmer","tibetan", "philippine","rohingya", "myanmar","hmong","Butuan","javanese","mongolian","sindhi"},
historical={"ancient", "old%-", "proto%-", "ogham", "phoenician", "runic", "runes", "elamite", "sogdian", "nabataean", "demotic", "meroitic","hieratic", "hieroglyphs", "cuneiform", "linear%-a", "linear%-b", "lycian", "lydian", "manichean", "manichaean", "byblos", "tocharian", "tangut", "khitan", "kushan", "minoan", "aramaic", "pahlavi", "parthian", "jurchen", "avestan", "mycenaean","indus", "woodcut"},
fictional={"klingon", "vulcan", "mandel", "elvish", "quenya", "tengwar", "sindarin", "sarati", "cirth", "aurebesh", "galactic"},
sci_fi={"klingon","vulcan","galactic","spacey","sci%-fi","alien","martian","star%-","futuristic"},
fantasy={"elvish", "tengwar", "sarati", "cirth", "orcish", "fantasy", "quenya", "sindarin", "lovecraft", "woodcut"},
horror={"horror", "creepy", "halloween", "sinister"}
}


font_lang_aliases={
greek={"greek"},
cyrillic={"russian","ukrainian","bulgarian","bosnian","serbian","belarusian","tatar","tajik"},
native_american={"cree","cherokee","algonquian","ojibwe","osage","yugtun"},
mesoamerican={"aztec","maya","olmec","toltec","mixtec","zaptoec"},
chinese={"chinese", "pinyin"},
india={"hindi","devanagari", "bangla", "bengali", "urdu", "kannada","gujarati", "gurumukhi", "gurmukhi", "malayalam", "odia", "tamil","telugu", "telugua", "meitei", "gupta", "sanskrit","brahmic"},
korean={"hangul", "korean"},
persian={"farsi", "persian"},
japanese={"hiragana", "katakana"},
other_asian={"khmer","tibetan", "philippine","rohingya", "myanmar","hmong","Butuan","javanese","mongolian","thai", "sindhi"},
symbol={"symbol", "emoji", "math", "music"},
barcode={"barcode","code128","code.128","code39","code.39","ean13","ean.13","codabar","databar"},
historical={"ancient", "old%-", "proto%-", "ogham", "phoenician", "runic", "runes", "elamite", "sogdian", "nabataean", "demotic", "meroitic","hieratic", "hieroglyphs", "cuneiform", "linear%-a", "linear%-b", "lycian", "lydian", "manichean", "manichaean", "byblos", "tocharian", "tangut", "khitan", "kushan", "minoan", "aramaic", "pahlavi", "parthian", "jurchen", "avestan", "mycenaean","indus", "woodcut"},
fictional={"klingon", "vulcan", "mandel", "elvish", "quenya", "tengwar", "sindarin", "sarati", "cirth", "aurebesh", "galactic"},
sci_fi={"klingon","vulcan","galactic","alien"},
fantasy={"elvish", "tengwar", "sarati", "cirth", "orcish", "fantasy", "quenya", "sindarin"},
}


font_name_aliases={
serif={"roman"},
sans_serif={"^sans$", "sans.serif","humanist"},
slab_serif={"^slab", "slab.serif"},
italic={"italic", "oblique"},
light={"^light$", "^thin$", "extralight", "narrow"},
bold={"^bold$"},
display={"display", "stencil", "novelty", "signwriting", "woodcut"},
monospace={"mono", "monospace", "monospaced", "courier"},
symbol={"symbol", "emoji"},
comic={"comic", "cartoon"},
barcode={"barcode","code128","code.128","code39","code.39","ean13","ean.13","codabar","databar"},
}


root_font_styles={"regular", "sans_serif", "slab_serif", "monospace", "bold", "bold light", "bold italic", "italic", "light", "handwriting", "calligraphy", "display", "historical", "fictional", "sci_fi", "fantasy", "blackletter", "comic", "symbol", "emoji", "barcode", "music", "math", "braille", "cjk", "cyrillic", "arabic", "greek", "hebrew", "persian", "chinese", "japanese", "korean", "india", "tibetan", "vietnamese", "other_asian",  "native_american", "mesoamerican"}




-- turn a font style into a number in a list (used in 'font style compare' to order fonts)
function FontStyleEnumerate(style)
local i, found

if style == nil then return 0 end
for i,found in ipairs(root_font_styles)
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




function FontStyleMatchMembers(style, members) 
local i, candidate

if style ~= nil
then
for i,candidate in ipairs(members)
do
	if string.find(style, candidate) ~= nil then return candidate end
end
end

return nil 
end


function FontStyleMatch(styles, input, aliases)
local category, members, found
local retstr=""

for category,members in pairs(aliases)
do
  found=FontStyleMatchMembers(input, members) 
  if found ~= nil then styles[category]=found end
end

end


function FontStyleExamineString(styles, input, aliases)
local toks, tok

if input==nil then return end


if strutil.strlen(input) > 0
then
  toks=strutil.TOKENIZER(input, "\\S|,|-|_", "m")
  tok=toks:next()
  while tok ~= nil
  do
   tok=string.lower(tok)
   FontStyleMatch(styles, tok, aliases)
  
   tok=toks:next()
  end
end

end



-- try to figure out the style of a font
-- this is an involved process as people will -- call fonts many things, for example
-- 'cursive' 'handwriting', 'script', 'handdrawn' can all relate to the same style
function FontsParseStyle(font, filename)
local styles={}
local retstr=""

FontStyleExamineString(styles, font.style, font_style_aliases)
FontStyleExamineString(styles, font.description, font_style_aliases)
FontStyleExamineString(styles, font.languages, font_lang_aliases)
FontStyleExamineString(styles, font.name, font_name_aliases)

for name,value in pairs(styles)
do
retstr=retstr..name..","
end

if strutil.strlen(retstr)==0 then retstr="regular" end

return retstr
end

