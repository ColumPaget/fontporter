-- this module relates to caching files that have been downloaded


function CachedFileOpen(url, source)
local S, doc, str, cache_path, when

cache_path=process.getenv("HOME").."/.local/cache/fontporter/"..source..".json"

-- don't cache files for more than an hour
now=time.secs()
when=filesys.mtime(cache_path)
if now - when < 3600
then
S=stream.STREAM(cache_path)
if S ~= nil then return(S) end
end

--if we got here, then we didn't find the item in the cache, or it was too old
doc=""
S=stream.STREAM(url)
str=S:readln()
while str ~= nil
do
doc=doc..str
str=S:readln()
end
S:close()

filesys.mkdirPath(cache_path)
S=stream.STREAM(cache_path, "w")
if (S)
then
S:writeln(doc)
S:close()
end

S=stream.STREAM(cache_path)
return(S)
end



function GetCachedJSON(url, source)
local S, json
local P=nil

S=CachedFileOpen(url, source)
if S ~= nil
then
  json=S:readdoc()
  S:close()

  P=dataparser.PARSER("json", json)
end

return(P)
end

