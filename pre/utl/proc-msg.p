block-level on error undo, throw.
define input parameter p-msg as character no-undo.
def var v-file-name as character no-undo.
def var v-full-proc-name as character no-undo.
def stream sBat.
v-full-proc-name = search ("exe/msg.exe").
if search (v-full-proc-name) <> ? then do:
   if num-entries(p-msg,"~n") > 1 then
   do:
     run sendMultilineMessage in this-procedure.
   end.
   else
   do:
          os-command no-wait value (search ("exe/msg.exe") + " *  /TIME:0" +  p-msg).
    end.
end.
else do:
v-file-name = string (guid(generate-uuid)) + ".txt".
output to value (v-file-name).
export p-msg.
output close.
file-info:file-name = (v-file-name).
if search ("utl/w-msg.r") <> ?
then do:
  v-full-proc-name = search ("utl/w-msg.r").
end.
else do:
  v-full-proc-name = search ("utl/w-msg.w").
end.
if v-full-proc-name = ?
then do:
  message "Файл не найден - utl/w-msg.w" view-as alert-box.
end.
os-command no-wait value (search ("bin/prowin32.exe") + " -p " + v-full-proc-name + ' -param "FullFileName?' + file-info:full-pathname + '"').
end.
procedure sendMultilineMessage:
   define variable vCount as integer no-undo.
   define variable vNumberMsg as integer no-undo.
   define variable vPos   as integer no-undo.
   define variable vMsg   as character no-undo.
   define variable vBatFile as character no-undo.
   assign
     vMsg = p-msg
     vNumberMsg = 1
   .
   do while num-entries(vMsg,"~n") > 20:
      do vCount = 1 to 20:
         vPos = index(vMsg, "~n", vPos + 1).
         if vPos = length(vMsg) then leave.
      end.
      run runBatFile in this-procedure (substring(vMsg, 1, vPos - 1), vNumberMsg).
      assign
        vNumberMsg = vNumberMsg + 1
        vMsg = substring(vMsg,vPos + 1)
        vPos = 0
      .
   end.
   run runBatFile in this-procedure (vMsg, vNumberMsg).
end procedure.
procedure runBatFile:
   define input parameter iMsg as character no-undo.
   define input parameter iNumber as integer no-undo.
   define variable vBatFile     as character no-undo.
   define variable vBatFileFull as character no-undo.
   define variable vCount   as integer   no-undo.
   vBatFile = substitute("orderstat&1.bat", iNumber).
   output stream sBat to value (vBatFile).
   put stream sBat unformatted "(".
   do vCount = 1 to num-entries(iMsg, "~n"):
      if entry(vCount, iMsg, "~n") <> "" then
        put stream sBat unformatted
          " echo " entry(vCount, iMsg, "~n").
      if vCount <> num-entries(iMsg, "~n") and
         entry(vCount + 1, iMsg, "~n") <> "" then
        put stream sBat unformatted "&".
   end.
   put stream sBat unformatted
     ")|" v-full-proc-name " * /TIME:0"
   .
   output stream sBat close.
   vBatFileFull = search(vBatFile).
   if vBatFileFull <> ? then
   do:
     os-command no-wait value (vBatFileFull).
   end.
end procedure.
