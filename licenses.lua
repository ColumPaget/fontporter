
function LicenseTranslate(input)
local id

id=string.lower(input)
if id == "ofl-1.1" then return "SIL OFL 1.1" end
if id == "sil_ofl" then return "SIL OFL 1.1" end
if id == "itf_ffl" then return "ITF FFL" end
if id == "ufl-1.0" then return "Ubuntu 1.1" end
if id == "mit" then return "MIT" end
if id == "apache" then return "Apache" end
if id == "apache 2.0" then return "Apache v2" end
if id == "apache-2.0" then return "Apache v2" end
if id == "ipa" then return "IPA" end
if id == "cc0" then return "CC-0" end
if id == "cc0-1.0" then return "CC-0" end
if id == "cc-0" then return "CC-0" end
if id == "unlicense" then return "Unlicense" end
if id == "unlicence" then return "Unlicense" end

return input
end

function LicenseLongName(input)
local short_name

short_name=LicenseTranslate(input)

if input == "SIL OFL 1.1" then return "SIL Open Font License 1.1" end
if input == "ITF FFL" then return "Indian Type Foundry Free Font License" end
if input == "GPL" then return "GNU Public Licence" end
if input == "GPLv2" then return "GNU Public Licence Version 2" end
if input == "GPLv3" then return "GNU Public Licence Version 3" end
if input == "LGPL" then return "GNU Lesser Public Licence" end
if input == "LGPLv2" then return "GNU Lesser Public License v2" end
if input == "MIT" then return "MIT (X11) License" end
if input == "Apache" then return "Apache License" end
if input == "Apachev2" then return "Apache License Version 2" end
if input == "IPA" then return "Information-Technology Promotion Agency Font License" end
if input == "CC-0" then return "Creative Commons 'Zero Conditions' Public Domain" end
if input == "WTFPL" then return "Do What The F*ck You Like Public License" end
return input
end




function LicenseTypeColor(licence)
local toks, tok
local retstr=""

toks=strutil.TOKENIZER(licence, ",")
tok=toks:next()
while tok ~= nil
do
tok=LicenseTranslate(tok)

if tok=="SIL OFL 1.1" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="LGPL" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="LGPLv2" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="GPLv2" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="GPLv2+" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="GPLv3" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="WTFPL" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Apache" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Apache v2" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="MIT" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Public Domain" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="CC-0" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="Unlicense" then retstr=retstr.. "~g"..tok.."~0 " end
if tok=="ITF FFL" then retstr=retstr.. "~y"..tok.."~0 " end
if tok=="Non Commercial" then retstr=retstr.. "~y"..tok.."~0 " end
if tok=="unknown" then retstr=retstr.. "~r"..tok.."~0 " end

tok=toks:next()
end

if retstr=="" then retstr="~0"..licence end

return retstr
end
