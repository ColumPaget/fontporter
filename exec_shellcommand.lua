

function ExecSubcommand(cmd)
local proc, str

   Out:move(0, 7)
   proc=process.PROCESS(cmd, "")
   str=proc:readln()
   while str
   do
   str=strutil.trim(str)
   Out:puts("~>" .. str.."~>\n")
   str=proc:readln()
   end

end
