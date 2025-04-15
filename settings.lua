-- default settings for fontporter

function InitSettings()

settings={}
settings.use_sixel=false
settings.fonts_dir="/usr/share/fonts/"
--settings.preview_dir=process.getenv("HOME") .. "/.font_preview/"
settings.preview_dir="/tmp/.font_preview/"

settings.image_viewer=FindImageViewer()

end
