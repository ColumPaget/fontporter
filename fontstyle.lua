-- functions related to font styles, sans, serif, monospace etc

font_style_aliases={
serif={"roman"},
greek={"greek"},
display={"display", "grunge", "stencil", "novelty", "signwriting", "signage", "retro", "woodcut"},
blackletter={"blackletter", "medieval", "medeival", "gothic", "woodcut"},
handwriting={"script", "handwriting", "handdrawn"},
calligraphy={"caligraphic", "calligraphic", "caligraphy", "calligraphy"},
monospace={"mono", "monospace", "monospaced", "pixel", "programming", "typewriter","courier"},
sans_serif={"sans", "sans%-serif","sans%-serif","sans serif", "humanist"},
slab_serif={"slab", "slab%-serif", "slab%-serif", "slab serif"},
light={"light", "thin", "extralight"},
barcode={"barcode","code128","code38"},
music={"music", "score"},
comic={"comic", "cartoon"},
italic={"italic", "oblique"},
bold={"bold"},
cyrillic={"russian","ukrainian","bulgarian","bosnian","serbian","belarusian","tatar","tajik"},
native_american={"cree","cherokee","algonquian","ojibwe","osage","yugtun"},
mesoamerican={"aztec","maya","olmec","toltec","mixtec","zaptoec"},
chinese={"chinese", "pinyin"},
india={"hindi","devanagari", "bangla", "bengali", "urdu", "kannada","gujarati", "gurumukhi", "gurmukhi", "malayalam", "odia", "tamil","telugu", "telugua", "meitei", "gupta", "sanskrit","brahmic"},
korean={"hangul", "korean"},
persian={"farsi", "persian"},
other_asian={"khmer","tibetan", "philippine","rohingya", "myanmar","hmong","Butuan","javanese","mongolian","thai", "sindhi"},
symbol={"symbol", "emoji", "math", "music"},
historical={"ancient", "old%-", "proto%-", "ogham", "phoenician", "runic", "runes", "elamite", "sogdian", "nabataean", "demotic", "meroitic","hieratic", "hieroglyphs", "cuneiform", "linear%-a", "linear%-b", "lycian", "lydian", "manichean", "manichaean", "byblos", "tocharian", "tangut", "khitan", "kushan", "minoan", "aramaic", "pahlavi", "parthian", "jurchen", "avestan", "mycenaean","indus", "woodcut"},
fictional={"klingon", "vulcan", "mandel", "elvish", "quenya", "tengwar", "sindarin", "sarati", "cirth", "aurebesh", "galactic"},
sci_fi={"klingon","vulcan","galactic","spacey","sci%-fi","alien","martian","star%-","futuristic"},
fantasy={"elvish", "tengwar", "sarati", "cirth", "orcish", "fantasy", "quenya", "sindarin", "lovecraft", "woodcut"},
japanese={"hiragana", "katakana"}
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


function FontStyleMatch(styles, input)
local category, members, found
local retstr=""

tok=FontStyleMatchMembers(input, root_font_styles)
if strutil.strlen(tok) > 0 then styles[tok]=tok end

for category,members in pairs(font_style_aliases)
do
  found=FontStyleMatchMembers(input, members) 
  if found ~= nil then styles[category]=found end
end

end


function FontStyleExamineString(styles, input)
local toks, tok

if input==nil then return end


if strutil.strlen(input) > 0
then
  toks=strutil.TOKENIZER(input, "\\S|,", "m")
  tok=toks:next()
  while tok ~= nil
  do
   tok=string.lower(tok)
   FontStyleMatch(styles, tok)
  
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

FontStyleExamineString(styles, font.style)
FontStyleExamineString(styles, font.info)
FontStyleExamineString(styles, font.languages)

for name,value in pairs(styles)
do
retstr=retstr..name..","
end

if strutil.strlen(retstr)==0 then retstr="regular" end

return retstr
end

