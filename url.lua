-- helper functions relating to URLs

-- given a current url, and a 'new_url' that might be either a full url,
-- or a relative path from the current url, either:
-- 1) return 'new_url' if it's a full url
-- 2) return a new full url by combining current_url and the relative 'new_url
function URLFromCurrent(current_url, new_url)
local URL

if string.sub(new_url, 1, 5) == "http:" then return new_url end
if string.sub(new_url, 1, 6) == "https:" then return new_url end

if string.sub(new_url, 1, 1) ~= "/" then return(filesys.dirname(current_url) .. "/" .. new_url) end

URL=net.parseURL(current_url)
return(URL.type.."://"..URL.host..":"..URL.port..new_url)
end

