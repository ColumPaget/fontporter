MODULES=includes.lua settings.lua url.lua cache.lua font_list.lua exec_shellcommand.lua download.lua fontstyle.lua fontconfig.lua preview.lua unpack.lua viewer.lua installed.lua elsewhere.lua fontsource.lua fontsquirrel.lua googlefonts.lua mozilla.lua omnibus-type.lua nerdfonts.com.lua main.lua

fontporter.lua: $(MODULES)
	cat $(MODULES) > fontporter.lua
	chmod a+x fontporter.lua

clean:
	rm fontporter.lua

install:
	-mkdir ~/bin/
	cp fontporter.lua ~/bin/
	-mkdir ~/.config/fontporter/
	cp fonts-elsewhere.conf ~/.config/fontporter/

