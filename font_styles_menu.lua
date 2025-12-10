--these functions provide a screen of 'font styles' using the 'basic_menu' functions
--selecting a font style lists fonts within that style group

function DisplayFontStyleMenu(source, style_list)
local list,key,category,selection
local sorted_styles={}
local Menu

for key,category in pairs(style_list)
do
table.insert(sorted_styles, key)
end

table.sort(sorted_styles, FontStyleCompare)


while true
do
Out:clear()

Out:move(0,0)
if source == "installed" then Out:puts("~B~wLocally installed fonts: select style~>~0")
else Out:puts("~B~wFonts available from "..source..": select style~>~0")
end

BasicMenuBottomBar()

Out:move(0,5)

Menu=terminal.TERMMENU(Out, 1, 6, Out:width()-2, Out:length()-8)

for i,key in ipairs(sorted_styles)
do
category=style_list[key]
Menu:add(key.. " ".. #category.." items", key)
end


selection=BasicMenuRun(Menu)
if selection == nil then break end
if selection == "EXIT" then break end
if selection ~= "RESIZE" then DisplayFonts(source, style_list[selection], selection)  end
end

end


