block-level on error undo, throw.
define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-trn-doc as recid         no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 503102c480fa, 3492, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-resort.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-resort.p $":U .
define variable vss-description as character no-undo initial "Печать документа пересортицы":U .
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info4 as character no-undo format "x(65)":U
  initial "@(#)$Workfile$ $Revision$":U .
define stream excel-line .
define stream excel-cell .
define temp-table temp_cell-data no-undo
  field data-key   as character
  field data-value as character
  index pi         is primary   unique data-key
.
define temp-table temp_line-data no-undo
  field data-key   as character
  field xl-line-id as integer
  field Num        as integer
  field Artic      as character
  field Name       as character
  field EdIzm      as character
  field Qnty       as character
  field Price      as character
  field Sum        as character
  field PerCent    as character
  field Cost       as character
  index pi         is primary   unique xl-line-id
.
define variable v-r-resort-current-data-row as integer   no-undo .
define variable v-r-resort-cell-file-name   as character no-undo .
define variable v-r-resort-data-file-name   as character no-undo .
procedure r-resort-init :
  define buffer buf_temp_cell-data for temp_cell-data .
  define buffer buf_usr-flt        for ubflt.usr-flt .
  do
  for buf_temp_cell-data
    , buf_usr-flt
  on error undo, return error
  :
    assign
      v-r-resort-current-data-row = 0
    .
    run gbl/_tmpfile.p
      ( input "xd"
      , input ".txt"
      , output v-r-resort-data-file-name
      ) .
    output stream excel-line to value( v-r-resort-data-file-name ) .
    run gbl/_tmpfile.p
      ( input "xc"
      , input ".txt"
      , output v-r-resort-cell-file-name
      ) .
    output stream excel-cell to value( v-r-resort-cell-file-name ) .
    run r-resort-write-cell-data in this-procedure
      ( input "valutCode":U
      , input "0":U
      ) .
    run r-resort-write-cell-data in this-procedure
      ( input "columnList":U
      , input "Num,Artic,Name,EdIzm,Qnty,Price,Sum,PerCent,Cost"
      ) .
    run r-resort-write-cell-data in this-procedure
      ( input "columnType":U
      , input "I,S,S,S,D,D,D,D,D":U
      ) .
    run r-resort-write-cell-data in this-procedure
      ( input "columnAmount":U
      , input "9":U
      ) .
  end.
end procedure.
procedure r-resort-close :
  do
  on error undo, return error
  :
    output stream excel-line close .
    output stream excel-cell close .
    output to value( string( session :temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append .
    export string ("exe/" + "peresort.xlt":U) .
    export "exe/t_97.bas":U .
    export v-r-resort-cell-file-name .
    export v-r-resort-data-file-name .
    output close .
  end.
end procedure.
procedure r-resort-write-cell-data :
  define input parameter p-data-key   as character no-undo .
  define input parameter p-data-value as character no-undo .
  define buffer buf_temp_cell-data for temp_cell-data .
  do
  for buf_temp_cell-data
  on error undo, return error
  :
    find first buf_temp_cell-data where
               buf_temp_cell-data.data-key = p-data-key no-error.
    if not available buf_temp_cell-data
    then do:
      create buf_temp_cell-data .
      assign
        buf_temp_cell-data.data-key = p-data-key
      .
    end.
    assign
      buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
      buf_temp_cell-data.data-key   chr(9)
      buf_temp_cell-data.data-value chr(10)
    .
  end.
end procedure.
procedure r-resort-write-line-data :
  define input parameter p-Num     as integer   no-undo .
  define input parameter p-Artic   as character no-undo .
  define input parameter p-Name    as character no-undo .
  define input parameter p-EdIzm   as character no-undo .
  define input parameter p-Qnty    as character no-undo .
  define input parameter p-Price   as character no-undo .
  define input parameter p-Sum     as character no-undo .
  define input parameter p-PerCent as character no-undo .
  define input parameter p-Cost    as character no-undo .
  define buffer buf_temp_line-data for temp_line-data .
  do
  for buf_temp_line-data
  on error undo, return error
  :
    for each buf_temp_line-data
    :
      delete buf_temp_line-data .
    end.
    create buf_temp_line-data .
    assign
      v-r-resort-current-data-row = v-r-resort-current-data-row + 1
    .
    assign
      buf_temp_line-data.data-key   = "LD":U
      buf_temp_line-data.xl-line-id = v-r-resort-current-data-row
      buf_temp_line-data.Num        = p-Num
      buf_temp_line-data.Artic      = p-Artic
      buf_temp_line-data.Name       = p-Name
      buf_temp_line-data.EdIzm      = p-EdIzm
      buf_temp_line-data.Qnty       = p-Qnty
      buf_temp_line-data.Price      = p-Price
      buf_temp_line-data.Sum        = p-Sum
      buf_temp_line-data.PerCent    = p-PerCent
      buf_temp_line-data.Cost       = p-Cost
    .
    put stream excel-line unformatted
      buf_temp_line-data.data-key chr(9)
    .
    if buf_temp_line-data.Num = ?
    then do:
      put stream excel-line unformatted
        chr(9)
      .
    end.
    else do:
      put stream excel-line unformatted
        buf_temp_line-data.Num    chr(9)
      .
    end.
    put stream excel-line unformatted
      buf_temp_line-data.Artic    chr(9)
      buf_temp_line-data.Name     chr(9)
      buf_temp_line-data.EdIzm    chr(9)
      buf_temp_line-data.Qnty     chr(9)
      buf_temp_line-data.Price    chr(9)
      buf_temp_line-data.Sum      chr(9)
    .
    if buf_temp_line-data.PerCent = ?
    then do:
      put stream excel-line unformatted
        chr(9)
      .
    end.
    else do:
      put stream excel-line unformatted
        buf_temp_line-data.PerCent chr(9)
      .
    end.
    .
    put stream excel-line unformatted
      buf_temp_line-data.Cost     chr(10)
    .
  end.
end procedure.
procedure r-resort-run-excel :
  define input parameter p-header-filename as character no-undo .
  define input parameter p-data-filename   as character no-undo .
  define variable v-template-file-name as character no-undo .
  define variable v-vb-file-name       as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  for buf_temp-param
  on error undo, return error
  :
    create buf_temp-param.
    assign
      v-template-file-name = search( string ("exe/" + "peresort.xlt":U) )
      v-vb-file-name       = search( "exe/t_97.bas" )
    .
    if v-template-file-name = ? or
       v-template-file-name = "":U
    then do:
      message
        "Ошибка имени файла шаблона."
      view-as alert-box error .
    end.
    if v-vb-file-name = ? or
       v-vb-file-name = "":U
    then do:
      message
        "Ошибка имени файла кода обработки."
      view-as alert-box error .
    end.
    run paramls-write in this-procedure
      ( input "template":U
      , input "template-file-name":U
      , input v-template-file-name
      ) .
    run paramls-write in this-procedure
      ( input "template":U
      , input "vb-file-name":U
      , input v-vb-file-name
      ) .
    run paramls-write in this-procedure
      ( input "data":U
      , input "data-header-filename":U
      , input p-header-filename
      ) .
    run paramls-write in this-procedure
      ( input "data":U
      , input "data-filename":U
      , input p-data-filename
      ) .
    run gbl/macroxlt.p
      ( input-output table buf_temp-param
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              "Ошибка создания файла Excel."  skip( 0 )
              return-value                    skip( 0 )
              trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
      view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable v-host-name    as character no-undo .
define variable p-host-code    as integer   no-undo .
define variable v-doc-num      as character no-undo .
define variable price-sale-in  as decimal   no-undo .
define variable price-sale-out as decimal   no-undo .
define variable d-road-tax     as decimal   no-undo .
define variable d-excise       as decimal   no-undo .
define variable sum-sale-in    as decimal   no-undo .
define variable sum-sale-out   as decimal   no-undo .
define variable sum-sale-total as decimal   no-undo .
define variable sum-cost-in    as decimal   no-undo .
define variable sum-cost-out   as decimal   no-undo .
define variable sum-cost-total as decimal   no-undo .
define variable itog-sum-sale-in  as decimal   no-undo .
define variable itog-sum-sale-out as decimal   no-undo .
define variable itog-sum-cost-in  as decimal   no-undo .
define variable itog-sum-cost-out as decimal   no-undo .
define variable fact-qnty-in   as decimal   no-undo .
define variable fact-qnty-out  as decimal   no-undo .
define variable t_inv-date     as date     no-undo .
define variable j_LineCount    as integer   no-undo .
define variable word-sum-total as character no-undo .
define variable word-sum-temp1 as character no-undo .
define variable word-sum-temp2 as character no-undo .
define variable word-sum-buf-1 as character no-undo .
define variable word-sum-buf-2 as character no-undo .
define variable word-sum-buf-3 as character no-undo .
define variable v-stroka       as integer   no-undo .
define variable v-stroka-out   as integer   no-undo .
define variable v-sum-sale-in  as decimal   no-undo .
define variable v-doc-date     as character no-undo .
define variable v-inv-date     as character no-undo .
define buffer bf_trn-doc    for ub.trn-doc    .
define buffer bf_doc-line   for ub.doc-line   .
define buffer bf_goods-in   for ub.goods      .
define buffer bf_goods-out  for ub.goods      .
define buffer bf_object     for ub.clients    .
define buffer bf_parts-root for ub.parts-root .
define buffer bf_parts-in   for ub.parts      .
define buffer bf_parts-out  for ub.parts      .
define temp-table tt-resort-out no-undo
  field j_LineCount as integer
  field stroka      as integer
  field artic       like ub.goods.artic
  field gds-name    like ub.goods.gds-name
  field gds-code    like ub.goods.gds-code
  field unit-base   like ub.goods.unit-base
  field fact-qnty   as decimal
  field price-sale  as decimal
  field sum-sale    as decimal
  field d-per-cent  as decimal
  field sum-cost    as decimal
.
define temp-table tt-resort-in no-undo
  field j_LineCount as integer
  field artic       like ub.goods.artic
  field gds-name    like ub.goods.gds-name
  field gds-code    like ub.goods.gds-code
  field unit-base   like ub.goods.unit-base
  field fact-qnty   as decimal
  field price-sale  as decimal
  field sum-sale    as decimal
  field sum-cost    as decimal
.
FUNCTION Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Rouble AS CHARACTER NO-UNDO.
  RUN get-roubles IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Rouble ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Rouble ).
END FUNCTION.
PROCEDURE get-roubles :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rub AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
           jj     = LENGTH( Word )
           j_last = INTEGER( SUBSTRING( Word, jj - 3, 1 ) )
           l_prev =        ( SUBSTRING( Word, jj - 4, 1 ) = "1" ).
    IF      j_last = 1                THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубль" ).  END.
    ELSE IF j_last > 1 AND j_last < 5 THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубля" ). END.
                                      ELSE DO: ASSIGN p-rub = "рублей". END.
  END.
END PROCEDURE.
FUNCTION Copecks RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Copeck AS CHARACTER NO-UNDO.
  RUN get-copecks IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Copeck ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Copeck ).
END FUNCTION.
PROCEDURE get-copecks :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-kop AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN  Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
            jj     = LENGTH( Word )
            j_last = INTEGER( SUBSTRING( Word, jj,     1 ) )
            l_prev =        ( SUBSTRING( Word, jj - 1, 1 ) = "1" ).
    IF           j_last = 1                THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейка" ).
    END. ELSE IF j_last > 1 AND j_last < 5 THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейки" ).
    END.                                   ELSE DO:
      ASSIGN p-kop = "копеек".
    END.
  END.
END PROCEDURE.
FUNCTION get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.
  RUN get-number-grade IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION.
FUNCTION Word-Sum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.
  RUN conv-sum-to-word IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION.
PROCEDURE get-number-grade :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = ",один,два,три,четыре,пять,шесть,семь,восемь,девять".    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = "десять,одиннадцать,двенадцать,тринадцать,четырнадцать,пятнадцать,шестнадцать,семнадцать,восемнадцать,девятнадцать".    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = ",,двадцать,тридцать,сорок,пятьдесят,шестьдесят,семьдесят,восемьдесят,девяносто".   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = ",сто,двести,триста,четыреста,пятьсот,шестьсот,семьсот,восемьсот,девятьсот".  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END.
END PROCEDURE.
PROCEDURE conv-sum-to-word :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,триллион,,,миллиард,,,миллион,,,тысяч" ).
        IF SUBSTRING( Formatted, jj,     1 )  = "1" AND
           SUBSTRING( Formatted, jj - 1, 1 ) <> "1" AND jj = 12 THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
        IF SUBSTRING( Formatted, jj, 1 ) = "2" OR
           SUBSTRING( Formatted, jj, 1 ) = "3" OR
           SUBSTRING( Formatted, jj, 1 ) = "4" THEN DO:
          IF jj = 12 THEN DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "и". END.
          END.       ELSE DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
          END.
        END.
        IF ( SUBSTRING( Formatted, jj,     1 ) <> "1" AND
             SUBSTRING( Formatted, jj,     1 ) <> "2" AND
             SUBSTRING( Formatted, jj,     1 ) <> "3" AND
             SUBSTRING( Formatted, jj,     1 ) <> "4" AND jj <> 12 ) OR
           ( SUBSTRING( Formatted, jj - 1, 1 )  = "1" AND jj <  12 ) THEN DO: ASSIGN Word = TRIM( Word ) + "ов". END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END.
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "одна". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "две".  END.
        ELSE DO: ASSIGN Word = get-decade-word( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ). END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
        ASSIGN Word = get-decade-word( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
      END.                                        ELSE DO:
        ASSIGN Word = get-decade-word( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      ASSIGN Word = get-decade-word( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END.
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Ноль". END.
    ASSIGN p-res = TRIM( OutSum ).
  END.
END PROCEDURE.
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.
  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION.
PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
               ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
                p-word
               ) +
                      " ":U + p-curr + " ":U +
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
                        END.
END PROCEDURE.
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE.
function CenterLine returns character ( input p-in-string as character
                                      , input p-rep-width as integer ) :
  define variable v-out-string as character no-undo .
  run get-center-line in this-procedure
    (  input p-in-string
    ,  input p-rep-width
    , output v-out-string
    ) no-error .
  return ( if error-status :error then '':U else v-out-string ) .
end function.
define stream text_out .
do
on error undo, return error return-value
:
  run WaitFram-Show in this-procedure
    ( input 'Идет формирование отчета, ждите...'
    ) .
  run get-report-num  in p-parent-proc
    (
      output g#report-num
    ) .
  run get-quest-print in p-parent-proc
    (
      output g#quest-print
    ) .
  find first bf_trn-doc no-lock where
      recid( bf_trn-doc ) = p-rec-trn-doc no-error .
  if not available bf_trn-doc
  then do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найден документ пересортицы с идентификатором &1.'
                      , p-rec-trn-doc
                      )
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.doc-type     <> 'инв':U or
     bf_trn-doc.ext-doc-type <> 'vp':U
  then do:
    run waitfram-hide in this-procedure .
    message
      'Данная форма только для печати документа пересортицы.'
    view-as alert-box error .
    undo, return error .
  end.
  find first bf_object no-lock where
             bf_object.obj-type = bf_trn-doc.obj-type and
             bf_object.obj-code = bf_trn-doc.obj-code .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output p-host-code
  ,output v-host-name
  ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure .
    message
      'Не могу определить текущую фирму.'
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.host-code <> p-host-code
  then do:
    run waitfram-hide in this-procedure .
    message
      'Ошибка определения текущей фирмы.'
    view-as alert-box error .
    undo, return error .
  end.
  assign
    t_inv-date = ( if bf_trn-doc.status_ = 'факт':U then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
  .
output stream text_out to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  put stream text_out unformatted
    '-----------------------------------------------------------------------' skip
    '|     Предприятие, организация     |            Со склада             |' skip
    '-----------------------------------------------------------------------' skip
    '|' +
    substring( string( CenterLine( v-host-name,        34 ) + fill( ' ':U, 34 ), "x(34)":U ), 1, 34 )
        +                              '|' +
    substring( string( CenterLine( bf_object.obj-name, 34 ) + fill( ' ':U, 34 ), "x(34)":U ), 1, 34 )
                                                                        + '|' skip
    '-----------------------------------------------------------------------' skip( 4 )
    space( 59 ) '-----------------------------------' skip
    space( 59 ) '|Номер документа |Дата составления|' skip
    space( 59 ) '-----------------------------------' skip
    caps(
    substring( string( CenterLine( entry( lookup( bf_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ), 59 )
                     + fill( ' ':U, 59 ), "x(59)":U )
                     , 1, 59 )
        ) +     '|' +
    substring( string( CenterLine(         bf_trn-doc.doc-code,                   16 ) + fill( ' ':U, 16 ), "x(34)":U ), 1, 16 )
                               + '|' +
    substring( string( CenterLine( string( bf_trn-doc.doc-date, "99/99/9999":U ), 16 ) + fill( ' ':U, 16 ), "x(34)":U ), 1, 16 )
                                                + '|' skip
    space( 59 ) '-----------------------------------' skip( 1 )
    'Примечание: ' substring( replace( bf_trn-doc.PS, chr(10), ' ':U ), 1, 125 ) skip
    'Дата проведения: ' string( t_inv-date, "99/99/9999":U ) skip
  .
  put stream text_out unformatted
    '-----------------------------------------------------------------------------------------------------------------------------------' skip
    '|  N | Номенклатурный |     Наименование, сорт,                        |Ед.|Количест-|  Цена   |   Сумма   |     %     |   Сумма   |' skip
    '| п/п|     номер      |        размер                                  |изм|   во    |Розничная| Розничная | Отклонения|  Учетная  |' skip
  .
  run r-resort-init            in this-procedure .
      v-doc-date =     string( entry(2,string(bf_trn-doc.doc-date),"/") + "/" +
    entry(1,string(bf_trn-doc.doc-date),"/") + "/" +
    entry(3,string(bf_trn-doc.doc-date),"/"))
    .
      v-inv-date =     string( entry(2,string(t_inv-date),"/") + "/" +
    entry(1,string(t_inv-date),"/") + "/" +
    entry(3,string(t_inv-date),"/"))
    .
  run r-resort-write-cell-data in this-procedure
    ( input "h_OwnFirm":U
    , input trim( v-host-name )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_ObjName":U
    , input trim( bf_object.obj-name )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_DocType":U
    , input caps( entry( lookup( bf_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_DocCode":U
    , input bf_trn-doc.doc-code
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_DocDate":U
    , input string( v-doc-date )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_DocFact":U
    , input string( v-inv-date )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_PostScr":U
    , input trim( replace( bf_trn-doc.PS, chr(10), ' ':U ) )
    ) .
  assign
    j_LineCount    = 0
    sum-sale-total = 0.00
    sum-cost-total = 0.00
  .
  for each  bf_parts-root no-lock where
            bf_parts-root.doc-code = bf_trn-doc.doc-code
    , first bf_goods-out  no-lock where
            bf_goods-out.gds-code  = bf_parts-root.orig-gds-code
    , first bf_goods-in   no-lock where
            bf_goods-in.gds-code   = bf_parts-root.gds-code
   break by bf_parts-root.doc-code
         by bf_parts-root.orig-gds-code
         by bf_parts-root.gds-code
  :
    if first-of (bf_parts-root.gds-code) then do:
      assign
        sum-sale-in    = 0.00
        sum-sale-out   = 0.00
        sum-cost-in    = 0.00
        sum-cost-out   = 0.00
        fact-qnty-in   = 0.00
        v-sum-sale-in  = 0.00
        fact-qnty-out  = 0.00.
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  bf_goods-in.gds-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output v-doc-num
  ,output price-sale-in
  ,output d-road-tax
  ,output d-excise
  ) no-error .
    if error-status :error
    then do:
      run waitfram-hide in this-procedure .
      message
        'Не могу определить текущие продажные цены для оприходованного товара.' skip
        bf_goods-in.artic bf_goods-in.prod-type bf_goods-in.prod-code '.'
      view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  bf_goods-out.gds-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output v-doc-num
  ,output price-sale-out
  ,output d-road-tax
  ,output d-excise
  ) no-error .
    if error-status :error
    then do:
      run waitfram-hide in this-procedure .
      message
        'Не могу определить текущие продажные цены для оприходованного товара.' skip
        bf_goods-in.artic bf_goods-in.prod-type bf_goods-in.prod-code '.'
      view-as alert-box error .
      undo, return error .
    end.
     for each bf_parts-out no-lock where
        bf_parts-out.out-code  = bf_trn-doc.doc-code          and
        bf_parts-out.obj-type  = bf_trn-doc.obj-type          and
        bf_parts-out.obj-code  = bf_trn-doc.obj-code          and
        bf_parts-out.artic     = bf_goods-out.artic           and
        bf_parts-out.prod-type = bf_goods-out.prod-type       and
        bf_parts-out.prod-code = bf_goods-out.prod-code       and
        bf_parts-out.fact-qnty < 0  on error undo, return error return-value :
        if bf_parts-out.part-code = bf_parts-root.orig-part-code then
        do:
           assign
              sum-sale-out  = sum-sale-out  + price-sale-out          * bf_parts-out.fact-qnty
              sum-cost-out  = sum-cost-out  + bf_parts-out.price-rubl * bf_parts-out.fact-qnty
              fact-qnty-out = fact-qnty-out + bf_parts-out.fact-qnty
              .
        end.
        else
        do:
           if bf_parts-out.out-code   = bf_parts-root.in-code then
           do:
              assign
                 sum-sale-out  = sum-sale-out  + price-sale-out          * bf_parts-out.fact-qnty
                 sum-cost-out  = sum-cost-out  + bf_parts-out.price-rubl * bf_parts-out.fact-qnty
                 fact-qnty-out = fact-qnty-out + bf_parts-out.fact-qnty
                 .
           end.
        end.
     end.
     for each bf_parts-in   no-lock where
        bf_parts-in.out-code   = bf_trn-doc.doc-code         and
        bf_parts-in.obj-type   = bf_trn-doc.obj-type         and
        bf_parts-in.obj-code   = bf_trn-doc.obj-code         and
        bf_parts-in.artic      = bf_goods-in.artic           and
        bf_parts-in.prod-type  = bf_goods-in.prod-type       and
        bf_parts-in.prod-code  = bf_goods-in.prod-code       and
        bf_parts-in.fact-qnty > 0     on error undo, return error return-value :
        if bf_parts-in.part-code  = bf_parts-root.part-code then
        do:
           assign
              sum-sale-in  = sum-sale-in  + price-sale-in          * bf_parts-in.fact-qnty
              sum-cost-in  = sum-cost-in  + bf_parts-in.price-rubl * bf_parts-in.fact-qnty
              fact-qnty-in = fact-qnty-in + bf_parts-in.fact-qnty
              .
        end.
        else
        do:
           if bf_parts-in.in-code    = bf_parts-root.in-code then
           do:
              assign
                 sum-sale-in  = sum-sale-in  + price-sale-in          * bf_parts-in.fact-qnty
                 sum-cost-in  = sum-cost-in  + bf_parts-in.price-rubl * bf_parts-in.fact-qnty
                 fact-qnty-in = fact-qnty-in + bf_parts-in.fact-qnty
                 .
           end.
        end.
     end.
    find first tt-resort-out where tt-resort-out.artic = bf_goods-out.artic no-error .
    if not available tt-resort-out then do :
        create tt-resort-out .
      assign
        j_LineCount    = j_LineCount + 1
          tt-resort-out.j_LineCount     = j_LineCount
          tt-resort-out.artic           = bf_goods-out.artic
          tt-resort-out.gds-name        = bf_goods-out.gds-name
          tt-resort-out.unit-base       = bf_goods-out.unit-base
          tt-resort-out.fact-qnty       = fact-qnty-out
          tt-resort-out.price-sale      = price-sale-out
          tt-resort-out.sum-sale        = sum-sale-out
          tt-resort-out.sum-cost        = sum-cost-out
          v-sum-sale-in                 = 0
      .
    end .
    find first tt-resort-in where tt-resort-in.artic = bf_goods-in.artic no-error .
    if not available tt-resort-in then do :
       create tt-resort-in .
       assign
          j_LineCount                = j_LineCount + 1
          tt-resort-in.j_LineCount   = j_LineCount
          tt-resort-in.artic         = bf_goods-in.artic
          tt-resort-in.gds-name      = bf_goods-in.gds-name
          tt-resort-in.unit-base     = bf_goods-in.unit-base
          tt-resort-in.fact-qnty     = fact-qnty-in
          tt-resort-in.price-sale    = price-sale-in
          tt-resort-in.sum-sale      = sum-sale-in
          tt-resort-in.sum-cost      = sum-cost-in
          v-sum-sale-in              = v-sum-sale-in + sum-sale-in
        .
    end .
    find first tt-resort-out where tt-resort-out.artic = bf_goods-out.artic no-error .
    if available tt-resort-out then do :
       assign tt-resort-out.d-per-cent = (( v-sum-sale-in + tt-resort-out.sum-sale) / v-sum-sale-in ) * 100.00 .
    end .
  end.
  do while v-stroka ne j_LineCount :
    v-stroka = v-stroka + 1 .
    find first tt-resort-out where tt-resort-out.j_LineCount = v-stroka no-error .
    if available tt-resort-out then do :
      assign
        itog-sum-cost-out = itog-sum-cost-out + tt-resort-out.sum-cost
        itog-sum-sale-out = itog-sum-sale-out + tt-resort-out.sum-sale
        v-stroka-out      = v-stroka-out      + 1
      .
      put stream text_out unformatted
        '|----|----------------|------------------------------------------------|---|---------|---------|-----------|-----------|-----------|' skip
      .
      put stream text_out unformatted                                                '|'
        string( string( v-stroka-out,                 ">>>9":U  ), "x(4)":U  )       '|'
        string( tt-resort-out.artic,                  "x(16)":U  )                   '|'
        string( tt-resort-out.gds-name,               "x(48)":U )                    '|'
        string( tt-resort-out.unit-base,              "x(3)":U  )                    '|'
        string( string( tt-resort-out.fact-qnty,      "->>>>9.<<":U ), "x(9)":U  )   '|'
        string( string( tt-resort-out.price-sale,     ">>>>>9.99":U ), "x(9)":U  )   '|'
        string( string( tt-resort-out.sum-sale,       "->>>>>>9.99":U ), "x(11)":U ) '|'
        string( string( tt-resort-out.d-per-cent,     "->>>>>9.<<%":U ), "x(11)":U ) '|'
        string( string( tt-resort-out.sum-cost,       "->>>>>>9.99":U ), "x(11)":U ) '|' skip
      .
      if length( tt-resort-out.gds-name ) > 48
      then do:
        put stream text_out unformatted
          '|    |                |'
          string( substring( tt-resort-out.gds-name, 49 ), "x(48)":U )
          '|   |         |         |           |           |           |' skip
        .
      end.
      run r-resort-write-line-data in this-procedure
        (
          input v-stroka-out
        , input "'" + tt-resort-out.artic
        , input tt-resort-out.gds-name
        , input tt-resort-out.unit-base
        , input trim( string( tt-resort-out.fact-qnty,    "->>>>9.<<":U ) )
        , input trim( string( tt-resort-out.price-sale,   ">>>>>9.99":U ) )
        , input trim( string( tt-resort-out.sum-sale,     "->>>>>>9.99":U ) )
        , input trim( string( tt-resort-out.d-per-cent,   "->>>>>>9.<<":U ) )
        , input trim( string( tt-resort-out.sum-cost,     "->>>>>>9.99":U ) )
        ) .
    end.
    find first tt-resort-in where tt-resort-in.j_LineCount = v-stroka no-error .
    if available tt-resort-in then do :
      assign
          itog-sum-cost-in = itog-sum-cost-in + tt-resort-in.sum-cost
          itog-sum-sale-in = itog-sum-sale-in + tt-resort-in.sum-sale
        .
      put stream text_out unformatted
        '|    |----------------|------------------------------------------------|---|---------|---------|-----------|-----------|-----------|' skip
      .
      put stream text_out unformatted                                            '|'
                                                                             '    |'
        string( tt-resort-in.artic,               "x(16)":U  )                   '|'
        string( tt-resort-in.gds-name,            "x(48)":U )                    '|'
        string( tt-resort-in.unit-base,           "x(3)":U  )                    '|'
        string( string ( tt-resort-in.fact-qnty,  "->>>>9.<<":U ), "x(9)":U  )   '|'
        string( string ( tt-resort-in.price-sale, ">>>>>9.99":U ), "x(9)":U  )   '|'
        string( string ( tt-resort-in.sum-sale,   "->>>>>>9.99":U ), "x(11)":U ) '|'
                                                                      '           |'
        string( string( tt-resort-in.sum-cost,    "->>>>>>9.99":U ), "x(11)":U ) '|' skip
      .
      if length( tt-resort-in.gds-name ) > 48
      then do:
        put stream text_out unformatted
          '|    |                |'
          string( substring( tt-resort-in.gds-name, 49 ), "x(48)":U )
          '|   |         |         |           |           |           |' skip
        .
      end.
    run r-resort-write-line-data in this-procedure
      (
        input ?
        , input tt-resort-in.artic
        , input tt-resort-in.gds-name
        , input tt-resort-in.unit-base
        , input trim( string( tt-resort-in.fact-qnty,    "->>>>9.<<":U ) )
        , input trim( string( tt-resort-in.price-sale,   ">>>>>9.99":U ) )
        , input trim( string( tt-resort-in.sum-sale,     "->>>>>>9.99":U ) )
      , input ?
        , input trim( string( tt-resort-in.sum-cost,     "->>>>>>9.99":U ) )
      ) .
    end.
  end.
  assign
    sum-sale-total = sum-sale-total + itog-sum-sale-in + itog-sum-sale-out
    sum-cost-total = sum-cost-total + itog-sum-cost-in + itog-sum-cost-out
  .
  assign
    word-sum-total = Total-Word( sum-sale-total, Roubles( sum-sale-total ), Copecks( sum-sale-total ) )
    word-sum-buf-1 = '':U
    word-sum-buf-2 = '':U
    word-sum-buf-3 = '':U
  .
  if length( word-sum-total ) > 97
  then do:
    assign
      word-sum-temp1 = breakstr( word-sum-total, 97, input-output word-sum-buf-1, input-output word-sum-buf-2 )
      word-sum-temp2 = word-sum-buf-2
    .
    if length( word-sum-temp2 ) > 125
    then do:
      assign
        word-sum-temp1 = breakstr( word-sum-temp2, 125, input-output word-sum-buf-2, input-output word-sum-buf-3 )
      .
    end.
    else do:
      assign
        word-sum-buf-2 = word-sum-temp2
        word-sum-buf-3 = '':U
      .
    end.
  end.
  else do:
    assign
      word-sum-buf-1 = word-sum-total
      word-sum-buf-2 = '':U
      word-sum-buf-3 = '':U
    .
  end.
  put stream text_out unformatted
    '------------------------------------------------------------------------------------------------------------------------------------' skip
    '                                                              Итого:                           |'
    string( string( sum-sale-total, "->>>>>>9.99":U ), "x(11)":U )
                                                                                                        '|           |'
    string( string( sum-cost-total, "->>>>>>9.99":U ), "x(11)":U )
                                                                                                                                '|' skip
    '                                                                                               -------------------------------------' skip
    '    Разница сумм розничная: '
    string( word-sum-buf-1, "x(97)":U  ) skip
    string( word-sum-buf-2, "x(125)":U ) skip
    string( word-sum-buf-3, "x(125)":U ) skip
  .
  if word-sum-buf-2 <> '':U
  then do:
    put stream text_out unformatted
      skip
    .
    if word-sum-buf-3 <> '':U
    then do:
      put stream text_out unformatted
        skip
      .
    end.
  end.
  put stream text_out unformatted
    '    МОЛ:        _________________________     _________________________     _________________________'                         skip
    '                       должность                       подпись                 расшифровка подписи   '                         skip( 1 )
    '    Бухгалтер:  _________________________     _________________________'                                                       skip
    '                       подпись                    расшифровка подписи  '                                                       skip( 1 )
  .
  run r-resort-write-cell-data in this-procedure
    ( input "h_SaleTot":U
    , input trim( string( sum-sale-total, "->>>>>>9.99":U ) )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_CostTot":U
    , input trim( string( sum-cost-total, "->>>>>>9.99":U ) )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input "h_WordTot":U
    , input 'Разница сумма розничная: ' + word-sum-total
    ) .
  run waitfram-hide  in this-procedure .
  run r-resort-close in this-procedure .
  output stream text_out close .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 2 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure get-center-line :
  define  input parameter p-in-string  as character no-undo .
  define  input parameter p-rep-width  as integer   no-undo .
  define output parameter p-out-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if length( p-in-string ) < p-rep-width
    then do:
      assign
        p-out-string = fill( ' ':U, integer( ( p-rep-width - length( p-in-string ) ) * 0.5 ) ) + p-in-string
      .
    end.
    else do:
      assign
        p-out-string = p-in-string
      .
    end.
  end.
end procedure.
