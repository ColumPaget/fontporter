-- functions relating to getting fonts from Mozilla's MozillaCDN


function MozillaCDNParseFontFace(current_url, toks)
local tok
local font={}

font.name="?"
font.style="serif"
font.category="serif"
font.weight=""
font.languages=""
font.regular=""
font.fileformat=".ttf"
font.fontformat=".ttf"

tok=toks:next()
while tok ~= nil
do

	if tok=="font-family:"
	then
		tok=toks:next()
		while tok==" " do tok=toks:next() end
		font.title=tok
	end

	if tok=="font-weight:"
	then
		tok=toks:next()
		while tok==" " do tok=toks:next() end
		font.weight=tok
	end

	if tok=="font-style:"
	then
		tok=toks:next()
		while tok==" " do tok=toks:next() end
		font.style=tok
		font.category=tok
	end

	if tok == "url"
	then
		tok=toks:next()
		while tok=="(" or tok==" " do tok=toks:next() end
		if filesys.extn(tok) == ".ttf" then font.regular=URLFromCurrent(current_url, tok) end
	end

	if tok == "}" then break end

tok=toks:next()
end

if strutil.strlen(font.title) > 0
then
font.title = font.title .. "-" .. font.style .. "-" .. font.weight
font.name=font.title
end

return font
end


function MozillaCDNGetCSS(url, categories) 
local S, doc, toks, tok

S=stream.STREAM(url)
if S ~= nil
then
doc=S:readdoc()
S:close()

toks=strutil.TOKENIZER(doc, "{|}|;|(|)|\\S", "Qms")
tok=toks:next()
while tok ~= nil
do
	if tok=="@font-face"
	then
		font=MozillaCDNParseFontFace(url, toks)
		if strutil.strlen(font.regular) > 0 then FontListAdd(categories, font) end
	end
tok=toks:next()
end
end

end



function MozillaCDNList(url)
local S, doc, toks, tag
local categories={}

S=stream.STREAM(url)
doc=S:readdoc()
S:close()

toks=xml.XML(doc)
tag=toks:next()
while tag ~= nil
do
	if tag.type ~= nil and string.lower(tag.type) == "key"
	then
	tag=toks:next()
	if filesys.extn(tag.data) == ".css" then MozillaCDNGetCSS( URLFromCurrent(url, tag.data), categories ) end
	end
	tag=toks:next()
end

return categories
end



