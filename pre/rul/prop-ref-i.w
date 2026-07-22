DEFINE BUFFER locked_prop-ref FOR ub.prop-ref.
DEFINE TEMP-TABLE tt-prop-ref NO-UNDO LIKE ub.prop-ref.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-dtm-code as integer no-undo .
DEFINE INPUT PARAMETER p-dt-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-caller-id AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-ref".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function propreft-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.
FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info2 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info2, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info2 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info2, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info2, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info2, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info2, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info2, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info2, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info2 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info2, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info2 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable is-elved as logical no-undo init yes.
define variable is-ef as logical no-undo init yes.
DEFINE BUFFER FIRST_prop-ref FOR dictdb.prop-ref.
DEFINE BUFFER buf_prop-ref FOR dictdb.prop-ref.
define buffer buf_prop-head for ub.prop-head.
DEFINE BUTTON b-esys
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-main-part
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-prop-head
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "C"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-to AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-esys-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Код внешней системы"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-prefix AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 15.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-prop-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 97.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-sum-id-main-part AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 19 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-prop-ref SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-prop-ref.dt-code AT ROW 3.27 COL 50.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tt-prop-ref.ref-type AT ROW 3.67 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "item1", "item1":U
          SIZE 22.5 BY 7.9
     tt-prop-ref.sum-id AT ROW 4.57 COL 50.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Мнемонический идентификатор" FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 40 BY 1
     f-date-from AT ROW 6 COL 50.5 COLON-ALIGNED WIDGET-ID 18
     f-date-to AT ROW 6 COL 69 COLON-ALIGNED WIDGET-ID 20
     f-prefix AT ROW 7.27 COL 50.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     f-sum-id-main-part AT ROW 7.27 COL 66.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     b-main-part AT ROW 7.27 COL 88 WIDGET-ID 26
     f-esys-id AT ROW 8.47 COL 50.5 COLON-ALIGNED WIDGET-ID 28
     b-esys AT ROW 8.47 COL 62.5 WIDGET-ID 30
     tt-prop-ref.dtm-code AT ROW 10.6 COL 50.5 COLON-ALIGNED WIDGET-ID 6
          LABEL "Код объекта-операнда"
          VIEW-AS FILL-IN
          SIZE 15.5 BY 1
     b-prop-head AT ROW 10.6 COL 69 WIDGET-ID 8
     f-prop-name AT ROW 12.2 COL 1.5 NO-LABEL WIDGET-ID 16
     tt-prop-ref.Caller_id AT ROW 13.7 COL 16.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "доп.идент-тор"
          VIEW-AS FILL-IN NATIVE
          SIZE 63 BY 1
     "Тип итогов (среза)" VIEW-AS TEXT
          SIZE 26 BY 1 AT ROW 2.5 COL 1.5 WIDGET-ID 14
     SPACE(71.50) SKIP(11.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Срез данных по ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-date-from:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-date-to:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-prefix:HIDDEN IN FRAME Dialog-Frame           = TRUE
       f-prefix:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-prop-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-sum-id-main-part:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-prop-ref.ref-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-esys IN FRAME Dialog-Frame
DO:
  IF tt-prop-ref.dtm-code =?
  OR tt-prop-ref.dtm-code = 0 THEN DO:
     MESSAGE
     "Не выбран Объект-операнд"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  RUN proc-esys-id IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-main-part IN FRAME Dialog-Frame
DO:
  IF tt-prop-ref.dtm-code =?
  OR tt-prop-ref.dtm-code = 0 THEN DO:
     MESSAGE
     "Не выбран Объект-операнд"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  RUN proc-main-part IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-prop-head IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
FIND FIRST buf_prop-head NO-LOCK WHERE
          buf_prop-head.dtm-code = tt-prop-ref.dtm-code NO-ERROR.
IF AVAILABLE buf_prop-head THEN DO:
   v-rid-list = string(RECID(buf_prop-head)).
END.
  run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,INPUT "general-view"
                         ,input 'dc-storage':U
                         ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  IF v-rid-list <> '':U THEN DO:
     FIND FIRST buf_prop-head NO-LOCK WHERE
               recid(buf_prop-head) = INTEGER(v-rid-list).
     IF buf_prop-head.ref-type = '':U  THEN DO:
        MESSAGE
        "Для данного объекта операнда не предусмотрено создание срезов данных"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
     END.
     ASSIGN
     tt-prop-ref.dtm-code = buf_prop-head.dtm-code
     f-prop-name = buf_prop-head.prop-label
     tt-prop-ref.ref-type = buf_prop-head.ref-type
     .
     DISPLAY
     tt-prop-ref.dtm-code
     f-prop-name
     tt-prop-ref.ref-type
     WITH FRAME Dialog-Frame.
     RUN display-ref-type IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type, INPUT buf_prop-head.prop-name).
  END.
END.
ON VALUE-CHANGED OF tt-prop-ref.ref-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-prop-ref.ref-type.
  if p-mode <> 'ПРОСМОТР':U then do:
    RUN change-ref-type IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-from in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date7
    MENU-ITEM m-ed-date7-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date7-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date7-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date7-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date7 :HANDLE
      f-date-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle7 as handle no-undo .
  assign
    v-label-handle7 = f-date-from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle7)
  then do:
    if v-label-handle7 :tooltip = ""
    or v-label-handle7 :tooltip = ?
    then do:
      assign
        v-label-handle7 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date7-1 in menu m-ed-date7 DO:
    apply "ctrl-b":U to f-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-2 in menu m-ed-date7 DO:
    apply "ctrl-d":U to f-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-3 in menu m-ed-date7 DO:
    apply "ctrl-e":U to f-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-4 in menu m-ed-date7 DO:
    apply "ctrl-f":U to f-date-from in frame Dialog-Frame .
  END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-to in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date9 :HANDLE
      f-date-to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = f-date-to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to f-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to f-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to f-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to f-date-to in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK   :
  if p-dtm-code > 0 then do:
    find first buf_prop-head no-lock where
                        buf_prop-head.dtm-code = p-dtm-code no-error .
    if not available buf_prop-head then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Неверное значение параметра p-dtm-code=&1", p-dtm-code)
      view-as alert-box error .
      undo, return error .
    end.
  end.
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    FIND FIRST first_prop-ref EXCLUSIVE-LOCK.
    CREATE tt-prop-ref.
    ASSIGN
    tt-prop-ref.caller_id = p-caller-id
    tt-prop-ref.dtm-code = p-dtm-code
    tt-prop-ref.ref-type = (if available buf_prop-head
                            then buf_prop-head.ref-type
                            else '':U)
    .
  END.
  else do:
    IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      FIND FIRST LOCKED_prop-ref EXCLUSIVE-LOCK WHERE
                LOCKED_prop-ref.dt-code = p-dt-code .
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_prop-ref no-LOCK WHERE
                  LOCKED_prop-ref.dt-code = p-dt-code NO-ERROR.
    END.
    create tt-prop-ref.
    buffer-copy locked_prop-ref to tt-prop-ref.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE change-ref-type :
DEFINE INPUT PARAMETER p-ref-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
DEFINE VARIABLE date-1 AS date NO-UNDO.
DEFINE VARIABLE date-2 AS date NO-UNDO.
DEFINE VARIABLE v-dop AS character NO-UNDO.
DEFINE VARIABLE v-dop1 AS character NO-UNDO.
DEFINE VARIABLE v-dop2 AS character NO-UNDO.
DEFINE VARIABLE v-m AS integer NO-UNDO.
DEFINE VARIABLE v-y AS integer NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-ii as integer no-undo .
DEFINE VARIABLE v-ref-type as character no-undo .
DO v-ii = 1 TO NUM-ENTRIES(p-ref-type, ":"):
ASSIGN
v-ref-type = ENTRY(v-ii, p-ref-type, ":")
.
CASE v-ref-type:
  WHEN 'esys':U THEN DO:
      enable
      b-esys
      WITH FRAME Dialog-Frame.
      DISABLE
      tt-prop-ref.caller_id
      WITH FRAME Dialog-Frame.
      HIDE
      tt-prop-ref.caller_id
      b-main-part
      in FRAME Dialog-Frame.
  END.
  WHEN 'period':U THEN DO:
    run cur-time in this-procedure ( output v-today, output v-time).
    ASSIGN
    v-m = MONTH(v-today)
    v-y = YEAR(v-today)
    .
    IF v-m = 12  THEN DO:
        ASSIGN
        v-m = 1
        v-y = v-y + 1
        .
    END.
    ELSE DO:
        ASSIGN
        v-m = v-m + 1
        .
    END.
    date-1 = DATE( v-m, 1, v-y).
    IF v-m = 12  THEN DO:
        ASSIGN
        v-m = 1
        v-y = v-y + 1
        .
    END.
    ELSE DO:
        ASSIGN
        v-m = v-m + 1
        .
    END.
    ASSIGN
    date-2 = DATE( v-m, 1, v-y)
    date-2 = date-2 - 1
    .
    run gbl/get-per.w ( output glog
                  , input-output date-1
                  , input-output date-2) .
    IF NOT glog THEN RETURN NO-APPLY.
    IF date-1 <= v-today
      OR date-2 <= v-today THEN DO:
        MESSAGE
        "Нельзя ввести частный итог для текущего периода времени"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    ASSIGN
    v-dop1 = propreft-date-to-string(date-1) + '-' + propreft-date-to-string(date-1)
    v-dop2 = propreft-date-to-string(date-2) + '-' + propreft-date-to-string(date-2)
    v-dop = propreft-date-to-string(date-1) + '-' + propreft-date-to-string(date-2)
    .
    f-date-from = date-1.
    f-date-to = date-2.
     DISPLAY
     tt-prop-ref.caller_id
     WITH FRAME Dialog-Frame.
     enable
     tt-prop-ref.caller_id WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
     hIDE
     b-main-part
     in FRAME Dialog-Frame.
  END.
  when 'sel-goods':U then do:
    DISABLE
    tt-prop-ref.caller_id
    WITH FRAME Dialog-Frame.
    HIDE
    tt-prop-ref.caller_id
    b-main-part
    in FRAME Dialog-Frame.
  end.
  when 'one-ptrl':U then do:
    DISABLE
    tt-prop-ref.caller_id
    WITH FRAME Dialog-Frame.
    HIDE
    tt-prop-ref.caller_id
    in FRAME Dialog-Frame.
    display
    b-main-part
    with frame Dialog-Frame .
  end.
END CASE.
END.
ASSIGN
tt-prop-ref.sum-id = v-dop.
DISPLAY
tt-prop-ref.sum-id
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-ref-type :
DEFINE INPUT PARAMETER p-ref-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-prop-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ref-type as character no-undo .
DEFINE VARIABLE v-ii AS integer no-undo .
HIDE
f-date-from
IN FRAME Dialog-Frame.
HIDE
f-date-from f-date-to f-prefix f-sum-id-main-part b-main-part f-esys-id b-esys tt-prop-ref.Caller_id
IN FRAME Dialog-Frame.
DO v-ii = 1 TO NUM-ENTRIES(p-ref-type, ":"):
ASSIGN
v-ref-type = ENTRY(v-ii, p-ref-type, ":")
.
CASE v-ref-type:
 WHEN 'esys':U THEN DO:
    display
    f-esys-id
    WITH FRAME Dialog-Frame.
    IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
      ENABLE
      b-esys
      WITH FRAME Dialog-Frame.
    END.
  END.
  WHEN 'period':U THEN DO:
    DISPLAY
    f-date-from f-date-to
    tt-prop-ref.Caller_id
    WITH FRAME Dialog-Frame.
    IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
       ENABLE
       f-date-from
       f-date-to
       WITH FRAME Dialog-Frame.
    END.
    hide
    b-main-part in FRAME Dialog-Frame.
  END.
  WHEN 'sel-goods':U THEN DO:
    DISPLAY
    "G":U @ f-prefix f-sum-id-main-part
    WITH FRAME Dialog-Frame.
    IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
      ENABLE
      f-sum-id-main-part
      WITH FRAME Dialog-Frame.
    END.
    HIDE
    b-main-part IN FRAME Dialog-Frame.
  END.
  WHEN 'one-ptrl':U THEN DO:
    DISABLE
    tt-prop-ref.caller_id
    WITH FRAME Dialog-Frame.
    DISPLAY
    "petrol":U @ f-prefix f-sum-id-main-part b-main-part
    WITH FRAME Dialog-Frame.
    IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
      enable
      b-main-part
      WITH FRAME Dialog-Frame.
    END.
  END.
  WHEN 'blank':U THEN DO:
      DISPLAY
      p-prop-name @ f-prefix
      WITH FRAME Dialog-Frame.
  END.
END CASE.
END.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-prop-ref SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-date-from f-date-to f-prefix f-sum-id-main-part f-esys-id
          f-prop-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-ref THEN
    DISPLAY tt-prop-ref.dt-code tt-prop-ref.ref-type tt-prop-ref.sum-id
          tt-prop-ref.dtm-code tt-prop-ref.Caller_id
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-prop-ref.dt-code tt-prop-ref.ref-type
         tt-prop-ref.sum-id f-date-from f-date-to f-prefix f-sum-id-main-part
         b-main-part f-esys-id b-esys tt-prop-ref.dtm-code b-prop-head
         f-prop-name tt-prop-ref.Caller_id
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
define variable dops as character no-undo .
define variable dopst as character no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DO v-ii = 1 TO NUM-ENTRIES('blank,period,sel-goods,one-ptrl':U):
   ASSIGN
   v-dop = v-dop + ENTRY(v-ii, '_,Период дат,Опред.товары,Вид топлива':U) + chr(44) +
           ENTRY(v-ii, 'blank,period,sel-goods,one-ptrl':U) + chr(44).
END.
ASSIGN
v-dop = TRIM(v-dop, chr(44)).
ASSIGN
tt-prop-ref.ref-type:radio-buttons IN FRAME Dialog-Frame = v-dop.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-elved'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
if error-status:error
or logical(dops) = no then do:
  is-elved = no.
end.
dops = ''.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
if error-status:error
or logical(dops) = no then do:
  is-ef = no.
end.
if is-elved = no
and is-ef = no then do:
  tt-prop-ref.ref-type:disable(radio-label('one-ptrl':U
                              , tt-prop-ref.ref-type:radio-buttons IN FRAME Dialog-Frame)) in frame Dialog-Frame .
end.
IF p-mode = 'ДОБАВЛЕНИЕ':U
and tt-prop-ref.dtm-code = 0
THEN DO:
   f-prop-name = chr(63).
END.
ELSE DO:
  FIND FIRST buf_prop-head NO-LOCK WHERE
            buf_prop-head.dtm-CODE = tt-prop-ref.dtm-code.
 f-prop-name = buf_prop-head.prop-label.
END.
DISPLAY
f-prop-name
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-prop-ref THEN
DISPLAY
tt-prop-ref.dt-code
tt-prop-ref.dtm-code
tt-prop-ref.sum-id
tt-prop-ref.caller_id
tt-prop-ref.ref-type
WITH FRAME Dialog-Frame.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-prop-ref.sum-id  WHEN p-mode <> 'ПРОСМОТР':U AND p-mode <> 'ДОБАВЛЕНИЕ':U
tt-prop-ref.caller_id  WHEN p-mode <> 'ПРОСМОТР':U
b-prop-head WHEN p-mode = 'ДОБАВЛЕНИЕ':U and tt-prop-ref.dtm-code = 0
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
if tt-prop-ref.dtm-code > 0
and p-mode = 'ДОБАВЛЕНИЕ':U then do:
  apply "VALUE-CHANGED" to tt-prop-ref.ref-type.
  RUN display-ref-type IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type, (if available buf_prop-head then buf_prop-head.prop-name else '')).
end.
hide
f-esys-id
b-esys
in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-esys-id :
DEFINE INPUT PARAMETER p-ref-type AS character NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-ok as logical no-undo .
define variable v-value-integer as integer no-undo .
define buffer buf_ext-system for ub.ext-system.
DEFINE BUFFER buf_goods FOR ub.goods.
CASE entry(1, p-ref-type, ":"):
    WHEN 'esys':U THEN DO:
      find first buf_ext-system no-lock where
                  buf_ext-system.db-num = 0
              and buf_ext-system.esys-id = integer(replace(entry(1, p-ref-type, ":"), "es", "")) no-error.
      if available buf_ext-system THEN DO:
          run gen-key-rec in this-procedure (
                                              input 'ext-system':U
                                              ,input buffer buf_ext-system:handle
                                              ,output v-uniq-key-rec) .
      END.
      run bge/oxmlexts.p (
            input parparentproc
          , input 2
          , input substitute("esys-type > &1", '0':U)
          , input v-uniq-key-rec
          , output v-rid-list
          , output v-ok
      ).
      if v-ok then do:
        run gen-row-keyr in this-procedure
          ( input v-rid-list
           ,input ?
           ,input "ub"
           ,input ?
           ,input no-lock
           ,output v-tbl-row
           ,output v-tbl-name
         ).
        find first buf_ext-system no-lock where
                  rowid(buf_ext-system) = v-tbl-row.
        if not (buf_ext-system.esys-type > integer('0':U)) then do:
          message
          "Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа СПЕЦИАЛЬНЫЙ"
          view-as alert-box error .
          undo, return error.
        end.
        assign
        v-value-integer = buf_Ext-system.esys-id.
        ASSIGN
        f-esys-id = SUBSTITUTE("es&1", buf_Ext-system.esys-id).
        DISPLAY f-esys-id
        WITH FRAME Dialog-Frame.
    END.
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-main-part :
DEFINE INPUT PARAMETER p-ref-type AS character NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
CASE p-ref-type:
    WHEN 'one-ptrl':U THEN DO:
      run ref/petrlref.p ( INPUT parparentproc
                          ,INPUT "b-sel"
                          ,OUTPUT v-rid-list ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-rid-list = '':U THEN DO:
         UNDO, RETURN ERROR.
      END.
      FIND FIRST buf_goods no-lock WHERE
                RECID(buf_goods) = INTEGER(v-rid-list) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
      ASSIGN
      f-sum-id-main-part = string(buf_goods.gds-code).
      DISPLAY f-sum-id-main-part
      WITH FRAME Dialog-Frame.
    END.
END CASE.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sum-id-all AS CHARACTER NO-UNDO.
DO v-ii = 1 TO NUM-ENTRIES(tt-prop-ref.ref-type, ":"):
  CASE entry(v-ii, tt-prop-ref.ref-type, ":"):
    WHEN 'esys':U THEN DO:
      ASSIGN
      FRAME Dialog-Frame
      f-esys-id.
      v-sum-id = f-esys-id.
    END.
    WHEN 'period':U THEN DO:
      ASSIGN
      FRAME Dialog-Frame
      f-date-from
      f-date-to
      .
     if f-date-from = ?
      or f-date-to = ? then do:
        message
        "Не выбраны дата(-ы) начала/конца периода!"
        view-as alert-box error .
        undo, return error .
      end.
      v-sum-id = SUBSTITUTE("&1/&2/&3-&4/&5/&6"
                                      ,string(YEAR(f-date-from), "9999")
                                      ,string(MONTH(f-date-from), "99")
                                      ,string(DAY(f-date-from), "99")
                                      ,string(YEAR(f-date-to), "9999")
                                      ,string(MONTH(f-date-to), "99")
                                      ,string(DAY(f-date-to), "99")).
    END.
    WHEN 'sel-goods':U THEN DO:
      ASSIGN
      f-sum-id-main-part.
      v-sum-id = SUBSTITUTE("&1-&2"
                                      ,f-prefix:SCREEN-VALUE
                                      ,f-sum-id-main-part
                                      ).
    END.
    WHEN 'one-ptrl':U THEN DO:
      if not is-elved
      and not is-ef
      then do:
         message
         'В Вашей конфигурации нельзя добавлять итоги(срезы) типа ТОПЛИВО,' skip
         'так как не включены конфигурационные параметры is-elved и/или is-ef'
         view-as alert-box error .
         undo, return error .
      end.
      ASSIGN
      f-sum-id-main-part.
      v-sum-id = SUBSTITUTE("&1-&2"
                                      ,f-prefix:SCREEN-VALUE
                                      ,f-sum-id-main-part
                                      ).
    END.
    WHEN 'blank':U THEN DO:
      v-sum-id = SUBSTITUTE("&1"
                                      ,f-prefix:SCREEN-VALUE
                                      ).
    END.
  END CASE.
  v-sum-id-all = v-sum-id-all + (IF v-sum-id-all = "":U THEN '':U ELSE ":") + v-sum-id.
END.
ASSIGN
FRAME Dialog-Frame
tt-prop-ref.dt-code
tt-prop-ref.dtm-code
tt-prop-ref.caller_id
tt-prop-ref.ref-type
tt-prop-ref.sum-id = v-sum-id-all
.
run rul/prop-ref1.p ( INPUT p-mode
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-ref.dt-code
                ,INPUT tt-prop-ref.sum-id
                ,INPUT tt-prop-ref.dtm-code
                ,INPUT tt-prop-ref.caller_id
                ,INPUT tt-prop-ref.ref-type
                ) no-error.
if error-status:error then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.
