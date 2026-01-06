-- functions relating to generating font previews

function PreviewGenerate(path, style, format, pointsize, height, line1, line2, line3, line4, line5)
local str, width, line, i
local lines={}
local pos=0

filesys.mkdirPath(settings.preview_dir)

table.insert(lines, line1)
table.insert(lines, line2)
table.insert(lines, line3)
table.insert(lines, line4)
table.insert(lines, line5)

if style=="terminal"
then
width=string.format("%d", (pointsize +2) * 40)
else width=string.format("%d", Out:width() * 6)
end

str="convert -font '" .. path .. "' -pointsize " .. tostring(pointsize) 
str=str.." -size " .. tostring(width) .. "x" .. tostring(height)

if style == "terminal"
then
pos=20
str=str.." -background black -fill green gravity left xc:"
else
--pos=-40
str=str.." -fill '#000000' -gravity center xc:"
end

for i,line in ipairs(lines)
do
if strutil.strlen(line) > 0 then str=str .. " -annotate +10+" .. tostring(pos)..  " '" .. line .. "'" end
pos = pos + pointsize + 6
end

str=str.." -flatten "

if format=="sixel" then str=str.."sixel:"..settings.preview_dir.."/preview.six "
else str=str..settings.preview_dir.."/preview.png "
end

str=str.." 2>/dev/null"

io.stderr:write(str)

os.execute(str)
end



function PreviewOneLine(font_name, path, format)

if settings.use_sixel == true
then
PreviewGenerate(path, "", format, 24, 26,'ABCDEFGHIK abcdefghijk 0123456789')
os.execute("cat "..settings.preview_dir.."/preview.six")
end

end



function PreviewFont(font, use_sixel, x, y, style, line1, line2, line3, line4, line5)
local str, path, destdir
local pointsize=26
local height=200

if style=="terminal"
then
pointsize=14
end

Out:move(1,Out:height() -2)
Out:puts("~mDownloading preview. Please wait.~>~0")
str=string.gsub(font.title, ' ', '_')
destdir=settings.preview_dir .. str.."/"

filesys.mkdirPath(destdir)
path=DownloadCheckForFontFile(destdir)
if path == nil then path=DownloadFontFile(font, destdir, "regular") end


Out:move(1,Out:height() -2)
Out:puts("~>")

if path ~= nil
then
if use_sixel==true
then
	Out:move(x, y)
	PreviewGenerate(path, style, "sixel", pointsize, height, line1, line2, line3, line4, line5)
	--filesys.copy("preview.six", "-")
	os.execute("cat " .. settings.preview_dir .. "/preview.six")
else
	PreviewGenerate(path, style, "png", pointsize, height, line1, line2, line3, line4, line5)
	os.execute(settings.image_viewer .. " ".. settings.preview_dir .. "/preview.png")
end

--filesys.unlink(path)
end

end


