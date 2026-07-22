block-level on error undo, throw.
block-level on error undo, throw.
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
   function SavePARAM returns logical ( input iName as character, input iValue as character ):
      put unformatted SUBSTITUTE("<PARAM name='&1'>", iName).
      put unformatted iValue.
      put unformatted SUBSTITUTE("</PARAM name='&1'>", iName) skip.
   end .
   function GetPARAM returns character  ( input iFile as character, input iName as character ):
      define variable vLob  as longchar no-undo.
      define variable vFrom as int64    no-undo.
      define variable vTo   as int64    no-undo.
      iFile = SearchFile (iFile).
      if iFile eq ? then return ?.
      copy-lob file iFile to vLob no-error.
      vFrom = index(vLob, SUBSTITUTE("<PARAM name='&1'>", iName)).
      if vFrom <= 0 then return ?.
      assign
         vTo = index(vLob, SUBSTITUTE("</PARAM name='&1'>", iName))
         vFrom = vFrom + LENGTH(SUBSTITUTE("<PARAM name='&1'>", iName)).
      if vTo < vFrom then return ?.
      return string(substring(vLob, vFrom, vTo - vFrom)).
   end.
define variable vFileParam as character no-undo.
define variable mliststrfile as character no-undo.
define variable mi           as integer   no-undo.
define variable changstr     as logical   no-undo.
define variable chancript    as logical   no-undo.
define variable chancriptone as logical   no-undo.
define variable changmd5     as logical   no-undo.
define variable mfilesize    as integer   no-undo.
define variable msizeinfile  as integer   no-undo.
define variable mverinfile   as integer   no-undo.
define variable v-md5-signature  as character no-undo.
define variable mfile        as character no-undo.
define variable mfilename    as character no-undo.
define variable mfileNew     as character no-undo.
define variable mFileRes     as character no-undo.
define variable mDirUpdCk    as character no-undo.
define stream sOut.
define stream dir-stream.
define temp-table tt-file-ver
field  filename as character
field  filesize as integer
field  filever as integer init ?
.
if search("adm/l-i.r") eq ?
then do:
   vFileParam = SearchFile ("filesize.txt").
   mFileRes = search("utl/mkstrglb.p").
   mFileRes = replace(mFileRes,"mkstrglb.p","mkstrres.txt").
   output stream sOut to value( mFileRes ).
   output stream sOut close.
   mliststrfile = "cmp/str-glb2.p,cmp/str-glb3.p,cmp/str-glb4.p,cmp/str-glb5.p,cmp/str-glbl.p,cmp/str-glbt.p".
   block-file:
   do mi = 1 to num-entries(mliststrfile):
      changstr = yes.
      run SaveFileList(entry(mi,mliststrfile),"cmp/str-glbl.i").
   end.
   if    changstr
      or search ("cmp/str-glbl.i") eq ?
   then do:
      if search("str-glbl.new") ne ?
      then do:
         message "Уже начато формирвание str-glbl.i в другой сесссии" skip
            search("str-glbl.new")
         view-as alert-box.
         return.
      end.
      if search("cmp/str-glbl.i") ne ?
      then do:
         output stream sOut to value( search("cmp/str-glbl.i")).
         put stream sOut "удален" skip.
         output stream sOut close.
      end.
      changstr = yes.
define variable vss-revision    as character no-undo init "$Revision: 6cc672b19ae2, 2597, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Ср сен 23 11:55:30 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mkstrglb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mkstrglb.p $":U .
define variable vss-description as character no-undo init "Создание файла препроцессингов для системы".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable v-rus-num-lines as integer   no-undo .
define variable v-eng-num-lines as integer   no-undo .
define temp-table temp-definitions no-undo
  field temp-name as character
  field temp-rus-line as integer
  field temp-eng-line as integer
  index xpk is primary unique temp-name .
define stream sinp .
define stream sout .
do
on error undo, leave
on stop  undo, leave
:
  define variable v-ok as logical   no-undo .
  run waitfram-show in this-procedure
    (input "Создание файла определений cmp/str-glbl.i"
    ) .
  define variable mFileStr as character no-undo.
  define variable mdir as character no-undo.
  define variable vi as integer no-undo.
  mFileStr = replace (search ("cmp/str-glbl.p"), "\","/").
  do vi = 1 to num-entries(mFileStr,"/") - 2:
     mdir = mdir + entry(vi,mFileStr,"/") + "/".
  end.
  run cmp/str-glbl.p
    (input mdir + 'cmp'
    ,output v-rus-num-lines
    ) 'rus':U .
  run waitfram-show in this-procedure
    (input "Создание файла определений int/cmp/str-glbl.i"
    ) .
  run cmp/str-glbl.p
    (input mdir + 'int/cmp':U
    ,output v-eng-num-lines
    ) 'eng':U .
  run waitfram-show in this-procedure
    (input "Проверка файлов определений cmp/str-glbl.i, int/cmp/str-glbl.i"
    ) .
  define variable v-line     as character no-undo .
  define variable v-line-num as integer   no-undo .
  assign
    v-line-num = 0
  .
  input stream sinp from value(search('cmp/str-glbl.i':U)) .
  repeat
  :
    assign
      v-line     = '':U
      v-line-num = v-line-num + 1
    .
    import stream sinp unformatted
      v-line
      .
    if v-line begins '&glob'
    then do:
      find first temp-definitions
        where temp-definitions.temp-name = entry(2, v-line, ' ':U)
        no-error .
      if not available temp-definitions
      then do:
        create temp-definitions .
        assign
          temp-definitions.temp-name     = entry(2, v-line, ' ':U)
        .
      end.
      assign
        temp-definitions.temp-rus-line = v-line-num
      .
    end.
  end.
  input stream sinp close .
  v-rus-num-lines = v-line-num.
  assign
    v-line-num = 0
  .
  if search("int/cmp/str-glbl.i") ne ?
  then do:
     input stream sinp from value(search('int/cmp/str-glbl.i':U)) .
     repeat
     :
       assign
         v-line     = '':U
         v-line-num = v-line-num + 1
       .
       import stream sinp unformatted
         v-line
         .
       if v-line begins '&glob'
       then do:
         find first temp-definitions
           where temp-definitions.temp-name = entry(2, v-line, ' ':U)
           no-error .
         if not available temp-definitions
         then do:
           create temp-definitions .
           assign
             temp-definitions.temp-name     = entry(2, v-line, ' ':U)
           .
         end.
         assign
           temp-definitions.temp-eng-line = v-line-num
         .
       end.
     end.
     input stream sinp close .
  end.
  v-eng-num-lines = v-line-num.
  define variable v-clear-file  as logical   no-undo .
  define variable v-error-exist as logical   no-undo .
  assign
    v-clear-file = true
  .
  for each temp-definitions
    where temp-definitions.temp-rus-line = 0
       or temp-definitions.temp-eng-line = 0
  on error undo, return error return-value
  :
    assign
      v-error-exist = true
    .
    if v-clear-file = true
    then do:
      assign
        v-clear-file = false
      .
      output stream sout to value('str-glbl_err.txt':U) .
      output stream sout close .
    end.
    output stream sout to value('str-glbl_err.txt':U) append .
    export stream sout temp-definitions .
    output stream sout close .
  end.
  run waitfram-hide in this-procedure .
  output to "error.log".
  if v-error-exist = true
  then do:
     put unformatted
      "Были обнаружены ошибки при создании файлов" skip
      "" skip
      "Создание файлов определений str-glbl.i завершено" skip
      "Файл" 'cmp/str-glbl.i':U skip
      "Строк в файле " v-rus-num-lines skip
      "Файл" 'int/cmp/str-glbl.i':U skip
      "Строк в файле " v-eng-num-lines skip
    .
  end.
  else do:
     put unformatted
      "OK" skip
      "" skip
      "Создание файлов определений str-glbl.i завершено" skip
      "Файл" 'cmp/str-glbl.i':U skip
      "Строк в файле " v-rus-num-lines skip
      "Файл" 'int/cmp/str-glbl.i':U skip
      "Строк в файле " v-eng-num-lines skip
     .
  end.
  output close.
end.
   end.
   mliststrfile = "upd/code.xml,cmp/procasunc.xml".
   block-md5:
   do mi = 1 to num-entries(mliststrfile):
      mfile = entry(mi,mliststrfile).
      mfileNew = mFile.
      entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
      if search (mfile) eq ?
      then
         next block-md5.
      run SaveFileList (mfile,mfileNew).
      do:
         mfileNew = search (mfile).
         entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
         run gbl/md5.p(mfile,output v-md5-signature).
         output stream sOut to value(mfileNew).
         put stream sOut unformatted string(encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
 )  skip.
         output stream sOut close.
      end.
   end.
   define variable mdbver as integer no-undo.
   block-upd:
   do mdbver = 1 to 999999999:
      mfile    = substitute("upd/&1.xml",string(mdbver ,"999999999")).
      if    search(mfile)    eq ?
      then
         leave block-upd.
      mfileNew = mFile.
      entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
      run SaveFileList (mfile,mfileNew).
      mfile = search(mfile).
      mfileNew = mFile.
      entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
      run gbl/md5.p(mfile,output v-md5-signature).
      output stream sOut to value(mfileNew).
      put stream sOut unformatted encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
   skip.
      output stream sOut close.
   end.
   mDirUpdCk = objExists("updck","D").
   if mDirUpdCk <> ? then do:
       input stream dir-stream from os-dir( mDirUpdCk ) no-attr-list no-echo .
       block-updck:
       repeat:
          import stream dir-stream mfilename mfile .
          file-info :file-name = mfile.
          if caps( file-info :file-type ) begins "F":U and
             entry(2, file-info:file-name, ".") = "xml" then
          do:
             mfileNew = mFile.
             entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
             run SaveFileList (mfile,mfileNew).
             mfile = search(mfile).
             mfileNew = mFile.
             entry(num-entries(mfileNew,"."),mfileNew,".")= "md5".
             run gbl/md5.p(mfile,output v-md5-signature).
             output stream sOut to value(mfileNew).
             put stream sOut unformatted encode(v-md5-signature + "updck" ) + string(index(encode(string(v-md5-signature)), "k"))
   skip.
             output stream sOut close.
          end.
       end.
       input stream dir-stream close.
   end.
   mliststrfile = "cmp/actn.txt,cmp/menu.txt".
   do mi = 1 to num-entries(mliststrfile):
      mfile = entry(mi,mliststrfile).
      mfilenew = replace (mfile,".txt",".enc").
      run SaveFileList (mfile,mfileNew).
      mfile = search(mfile).
      chancriptone = yes.
      mfilenew = replace (mfile,".txt",".enc").
      if    chancriptone
         or search(mfilenew) eq ?
      then do:
          chancript = yes.
          run utl/filecrypnodb.p ( input mfile
                               , input "sysadm"
                               , input yes
                               , input mfileNew
                              ) .
      end.
   end.
   run utlcomp/crpwd.p(yes).
   run utlcomp/crkey.p(yes).
   run SaveFileList ("utlcomp/crpwd.p","utlcomp/crpwd.i").
   run SaveFileList ("utlcomp/crkey.p","utlcomp/keypub.i").
   run SaveFileList ("utlcomp/crkey.p","utlcomp/keypriv.i").
   run SaveFileList ("utlcomp/crkey.p","utlcomp/keyset.i").
end.
procedure SaveFileList:
   define input  parameter iFileNameOld as character no-undo.
   define input  parameter iFileNameNew as character no-undo.
   output stream sOut to value( mFileRes ) append.
   put stream sOut unformatted iFileNameOld  " " iFileNameNew skip.
   put stream sOut unformatted "utl/chkstrgbl.p " iFileNameNew skip.
   output stream sOut close.
end.
define stream sinp .
procedure getverfile:
   define input  parameter iFileName as character no-undo.
   define output parameter oFilesize as integer   no-undo.
   define output parameter oFilever  as integer   no-undo.
   define variable vTXt as character no-undo.
   if iFileName eq ?
   then do:
      ofilesize = 0.
      return.
   end.
   else do:
      file-info:file-name = iFileName.
      ofilesize = file-info:file-size.
   end.
   input stream sinp from value(iFileName) .
   import stream sinp unformatted vTXt .
   oFilever = integer (trim(vtxt,'"')) no-error.
   input stream sinp close .
end.
