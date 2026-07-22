DEFINE TEMP-TABLE X_order NO-UNDO LIKE order-doc.
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define input parameter  parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define output parameter rec-order as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список Заказов".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define new shared temp-table tt-zakaz like ub.order-line
    field gds-name          as character
    field minZapas          as decimal
    field volMinZapas       as integer
    field ostatokDay        as decimal
    field qntyDaySale       as integer
    field qntyDayGoods      as integer
    field ostatokGoods      as decimal
    field qntyDay           as integer
    field contract-prn-code as character
    field contract-code     as integer
    index pi    gds-code          contract-code
    index artic artic             prod-type         prod-code
    index contr contract-prn-code.
define new shared temp-table temp-gds-qnty no-undo
    field day      as date
    field ost      as decimal
    field gds-code as integer
    index pi is unique primary day gds-code
    index by-ost               ost .
define variable mDebug as logical no-undo.
mDebug = session:debug-alert.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable mDiadocApi as component-handle no-undo.
define variable mDiadocConnection as component-handle no-undo.
define variable m-sys-key as character no-undo.
define variable marpar-type as character no-undo.
define variable mPublishHand as handle  no-undo.
define variable mFlaftest as logical no-undo.
   create "Diadoc.DiadocClient":U mDiadocApi no-error.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mySeqUtd as int64 no-undo init ?.
if mDiadocApi eq ?
then do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message("Нет библиотеки Diadoc или не удалось создать объект Diadoc.DiadocClient", "EDOError").
end.
else do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message(substitute ("Версия библиотеки Diadoc &1" , mDiadocApi:GetFullVersion()) , "EDOError").
end.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-utd-mark no-undo like utd-marking-lines
  field side as character.
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
function CheckQnty returns logical
(  input idb-num  as integer,
   input idoc-id  as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","Qnty").
   end.
   if iErrType ne "CheckQnty"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","Qnty").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"QntyMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"Qnty").
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      define variable Vflagmark as logical no-undo.
      find first buf_utd-marking-lines
                    where buf_utd-marking-lines.db-num   = utd-lines.db-num
                      and buf_utd-marking-lines.doc-id   = utd-lines.doc-id
                      and buf_utd-marking-lines.LineNum  = utd-lines.LineNum
                      and length(buf_utd-marking-lines.mark) > 13
      no-lock no-error.
      if not available buf_utd-marking-lines
      then
         next block-line.
      define variable vqntyMark as integer no-undo.
      define variable vqntyOAD  as integer no-undo.
      vqntyMark = 0.
      vqntyOAD  = 0.
      block-mark:
      for each utd-marking-lines
           where utd-marking-lines.db-num  = utd-lines.db-num
             and utd-marking-lines.doc-id  = utd-lines.doc-id
             and utd-marking-lines.LineNum = utd-lines.LineNum
             and length(utd-marking-lines.mark) > 13
             and utd-marking-lines.doc-level  = 1
      no-lock:
         if isMark(utd-marking-lines.mark)
         then do:
            find first marking where marking.mark eq utd-marking-lines.mark
            no-lock no-error.
            if available marking
            then do:
               if marking.box-qnty ne ?
               then
                  vqntyMark = vqntyMark + marking.box-qnty.
            end.
         end.
         else do:
            find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq utd-marking-lines.db-num
                                                and utd-marking-lines-attr.doc-id    eq utd-marking-lines.doc-id
                                                and utd-marking-lines-attr.LineNum   eq utd-marking-lines.LineNum
                                                and utd-marking-lines-attr.mark      eq utd-marking-lines.mark
                                                and utd-marking-lines-attr.attr-code eq "box-qnty"
            no-lock no-error.
            if available utd-marking-lines-attr
            then
               vqntyOAD = vqntyOAD + dec(utd-marking-lines-attr.attr-value).
         end.
      end.
      if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyMark            ne 0
      then do:
         if utd-lines.Quantity  < vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
         else if utd-lines.Quantity  <> vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"QntyMark",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
      end.
      else if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyOAD ne 0
         and utd-lines.Quantity  ne vqntyOAD
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyOAD)).
   end.
end.
function CheckGds returns logical
(  input idb-num   as integer,
   input idoc-id   as integer,
   input iobj-type as character,
   input iobj-code as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","GtinQntyNotOne").
   end.
   if iErrType ne "CheckGds"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","GtinQntyNotOne").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"InLineNotMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoGtinForMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarcodForGtin").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkingForTypeEDO").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotMarkForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MultGtinForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarCodeForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotFindGdsForBarCode").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotEqGgsForLineAndMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"GtinQntyNotOne").
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define variable vGdsCode as integer no-undo.
   EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(iobj-type, iobj-code).
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      vGdsCode = ?.
      define variable Vflagmark as logical no-undo.
      define variable VflagOAD  as logical no-undo.
      assign
         Vflagmark = no
         VflagOAD = no
      .
      block-mark:
      for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if    isMark(utd-marking-lines.mark)
            or isOAD (utd-marking-lines.mark)
         then do:
            define variable vnewGdsCode as integer no-undo.
            vnewGdsCode = getGdsCodeByDM(utd-marking-lines.mark).
            if isMark(utd-marking-lines.mark)
            then do:
               Vflagmark = yes.
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"InLineNotMark",utd-marking-lines.mark).
                  next block-mark.
               end.
               if vnewGdsCode eq ?
               then
                  vnewGdsCode = GetGdsCodeByGtin(marking.gds-ext-id).
               if    marking.gds-code eq 0
                  or marking.gds-code eq ?
                  or marking.sts eq 0
                  or marking.sts eq ?
                  or marking.box-qnty eq ?
                  or (marking.gds-code ne vnewGdsCode
                      and vnewGdsCode ne ?
                      and vnewGdsCode ne 0)
               then do:
                  find first marking where marking.mark eq utd-marking-lines.mark
                  exclusive-lock no-error.
                  if marking.box-qnty = ? then marking.box-qnty = getQntyUTDByDM(marking.mark).
                  if marking.gds-ext-id = "" then marking.gds-ext-id = getGtinByDM(marking.mark).
                  if marking.gds-code = ? or marking.gds-code ne vnewGdsCode then marking.gds-code = vnewGdsCode.
                  if    marking.gds-ext-id eq ""
                     or marking.gds-ext-id eq ?
                  then do:
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoGtinForMark",string(utd-lines.LineNum ) + chr(4) + marking.mark).
                  end.
                  else if    marking.gds-code eq 0
                          or marking.gds-code eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoBarcodForGtin",string(utd-lines.LineNum ) + chr(4) + marking.gds-ext-id).
                  else if     marking.sts eq 0
                          or  marking.sts eq ?
                  then
                     marking.sts = objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
               end.
               if utd-marking-lines.doc-level eq 1
               then do:
                  if marking.box-qnty eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"MarkNotFormatqnty",string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
            else do:
               VflagOAD = yes.
               define variable vQnty as decimal no-undo.
               vQnty = getQntyUTDByCodId(utd-marking-lines.mark) .
               setAttrUtdMarkingLines (utd-marking-lines.db-num,
                                       utd-marking-lines.doc-id,
                                       utd-marking-lines.LineNum,
                                       utd-marking-lines.mark,
                                       "box-qnty",
                                        string(vQnty)).
               define variable vgtin as character no-undo.
               vgtin = getGtinByDM(utd-marking-lines.mark).
               if getQntyCodeByGtin(vgtin) ne 1
               then
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"GtinQntyNotOne",string(utd-lines.LineNum ) + chr(4) + vgtin).
            end.
            if utd-marking-lines.gds-code ne vnewGdsCode
            and vnewGdsCode ne ?
            and vnewGdsCode ne 0
            then do:
               find first buf_utd-marking-lines
                        where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                          and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                          and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                          and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vnewGdsCode.
               end.
            end.
         end.
         else  do:
            define variable vgdsbar as integer no-undo.
            vgdsbar = GetGdsCodeByGtin(utd-marking-lines.mark).
            if    utd-marking-lines.gds-code ne vgdsbar
            then do:
               find first buf_utd-marking-lines
                          where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                            and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                            and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                            and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vgdsbar.
               end.
            end.
            if vgdsbar ne ?
            then do:
                              if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                         ( vgdsbar,
                           'mark-type':U,
                           output v-par-val,
                           output v-par-type
                          ).
               if      (EDOParSec:GetIsEDOForType(v-par-val)
                    or  EDOParSec:GetIsArticForType(v-par-val))
                and not EDOParSec:GetIsTransitionalForType(v-par-val)
                and     EDOParSec:IsEdo
               then do:
                  AddUtdErr(utd-marking-lines.db-num,
                            utd-marking-lines.doc-id,
                            buffer utd-marking-lines:handle,
                            iErrType,
                            "MarkingForTypeEDO",
                            string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
         end.
         if vGdsCode eq ?
         then
            vGdsCode = utd-marking-lines.gds-code.
         if vGdsCode ne utd-marking-lines.gds-code
         and utd-marking-lines.gds-code > 0
         then do:
            vGdsCode = -1.
         end.
      end.
      if  vGdsCode = -1
      then do:
         vGdsCode = ?.
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"MultGtinForLine",string(utd-lines.LineNum )).
         next block-line.
      end.
      if vGdsCode ne ?
      then do:
                  if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                   ( vGdsCode,
                     'mark-type':U,
                     output v-par-val,
                     output v-par-type
                    ).
         if   not EDOParSec:GetIsTransitionalForType(v-par-val)
             and(
              (    EDOParSec:GetIsEDOForType(v-par-val)
                  and not Vflagmark)
              or  (EDOParSec:GetIsArticForType(v-par-val)
                  and not VflagOAD
                  and not Vflagmark))
         then do:
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NotMarkForLine",string(utd-lines.LineNum)).
         end.
      end.
      if utd-lines.gds-code ne vGdsCode
      then do:
         find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                     and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                     and buf_utd-lines.LineNum eq utd-lines.LineNum
         exclusive-lock no-error.
         if available buf_utd-lines
         then
            buf_utd-lines.gds-code = vGdsCode.
         release buf_utd-lines.
      end.
      define variable VBarCode as character no-undo.
      VBarCode = getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode").
      if VBarCode ne ?
      then do:
         if num-entries(VBarCode," ") > 0
         then
            VBarCode = entry(num-entries(VBarCode," "),VBarCode," ").
         vgdsbar = GetGdsCodeByGtin(VBarCode).
         if vgdsbar eq ? or vgdsbar eq 0
         then do:
            AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotFindGdsForBarCode",
                      string(utd-lines.LineNum ) + chr(4) + VBarCode).
         end.
         else do:
            if    utd-lines.gds-code eq ?
               or utd-lines.gds-code eq 0
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then
                  buf_utd-lines.gds-code = vgdsbar.
               release buf_utd-lines.
            end.
            else if utd-lines.gds-code ne vgdsbar
            then do:
               AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotEqGgsForLineAndMark",
                      string(utd-lines.LineNum ) + chr(4) + String(vgdsbar) + chr(4) + String(utd-lines.gds-code)).
            end.
         end.
      end.
      if vGdsCode eq ? and utd-lines.gds-code eq ?
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NoBarCodeForLine",string(utd-lines.LineNum )).
   end.
end.
function GetUtdLineForOrig return logical
(input idb-num as integer,
 input idoc-id as integer,
 input ilineNum as integer,
 input idb-numOrig as integer,
 input idoc-idOrig as integer,
 buffer edoc-lines for utd-lines):
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   block-mark:
   for each utd-marking-lines where utd-marking-lines.db-num  eq idb-num
                                and utd-marking-lines.doc-id  eq idoc-id
                                and utd-marking-lines.LineNum eq iLineNum
                                and utd-marking-lines.site eq "-"
   no-lock:
      find first edoc-marking-lines where edoc-marking-lines.db-num eq idb-numOrig
                                      and edoc-marking-lines.doc-id eq idoc-idOrig
                                      and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
      if available edoc-marking-lines
      then do:
         find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                 and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                 and edoc-lines.LineNum           = edoc-marking-lines.LineNum
         no-lock no-error.
            leave block-mark.
       end.
   end.
    if not available edoc-lines
    then do:
       find  first  utd-lines where utd-lines.db-num      = idb-num
                                and utd-lines.doc-id      = idoc-id
                                and utd-lines.LineNum     = ilinenum
          no-lock no-error.
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.ProductCode = utd-lines.ProductCode
       no-lock no-error.
    end.
    if not available edoc-lines
    then
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.gds-code    = utd-lines.gds-code
       no-lock no-error.
end.
function GetLastUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ) forward.
function getObgFns return logical
(input iDocumentNumber   as character ,
 input iFnsParticipantId as character ,
 input ikpp              as character ,
 output ohost-code       as integer,
 output oobj-type        as character ,
 output oobj-code        as integer ,
 output otext            as character  ):
    define buffer ext-classif   for ext-classif.
    define buffer clients       for clients.
    define buffer buf_clients   for clients.
    define buffer clients-attr  for clients-attr.
    find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                             and ext-classif.charkey_three eq iFnsParticipantId
    no-lock no-error.
    if available ext-classif
    then do:
       if ext-classif.CharKey_One eq 'маг':U
       then do:
          assign
             oobj-type = ext-classif.CharKey_One
             oobj-code = ext-classif.Key#_One
          .
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
          no-lock no-error .
          if available clients
          then
             ohost-code =  clients.host-code.
       end.
       else do:
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
                 and can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
          no-lock no-error .
          if not available clients
          then do:
             otext = substitute("По &1 получатель  &2 не наша фирма." ,iDocumentNumber, iFnsParticipantId) .
             return no.
          end.
          ohost-code = ext-classif.Key#_One.
          block-cl:
          for each clients-attr
             where clients-attr.attr-code  = 'kpp':U
               and clients-attr.obj-type   = 'маг':U
               and clients-attr.attr-value = ikpp
               and can-find(buf_clients where buf_clients.obj-type   = clients-attr.obj-type
                                          and buf_clients.obj-code   = clients-attr.obj-code
                                          and buf_clients.host-code  = ohost-code)
          no-lock :
             leave block-cl.
          end.
          if     available clients
             and clients.obj-type eq 'маг':U
          then do:
             assign
                oobj-type = clients.obj-type
                oobj-code = clients.obj-code
             .
          end.
          else if available clients-attr
          then do:
             assign
                oobj-type = clients-attr.obj-type
                oobj-code = clients-attr.obj-code
             .
          end.
          else do:
             otext = substitute("По &1 не найден объект по КПП &2." ,iDocumentNumber, ikpp ).
             return yes.
          end.
       end.
    end.
    else do:
       otext = substitute("По &1 не найден получатель  &2." ,iDocumentNumber, iFnsParticipantId) .
       return no.
    end.
    return ?.
end.
function CheckUcdForReturn return logical
(input idb-numUcd as integer,
 input idoc-idUcd as integer,
 input idb-numRet as integer,
 input idoc-idRet as integer  ):
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numUcd
                                 and utd-marking-lines.doc-id eq idoc-idUcd
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       create tt-utd-mark.
       buffer-copy utd-marking-lines to tt-utd-mark
       assign
          tt-utd-mark.side = "+"
       .
    end.
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numRet
                                 and utd-marking-lines.doc-id eq idoc-idRet
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
       no-lock no-error.
       if available tt-utd-mark
       then
          tt-utd-mark.side = "".
       else do:
          create tt-utd-mark.
          buffer-copy utd-marking-lines to tt-utd-mark
          assign
             tt-utd-mark.side = "-"
          .
       end.
    end.
    for each tt-utd-mark where  tt-utd-mark.side ne ""
    no-lock:
       AddUtdErrForTab(utd.db-num, utd.doc-id, "utd-marking-lines", buffer tt-utd-mark:handle, "UCDСompar", "NotMark" + tt-utd-mark.side, tt-utd-mark.mark).
    end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
function GetLastUTDinPackAft returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ) forward.
function SaturateAndCheckUTD return character
(input idb-num as integer,
 input idoc-id as integer  ):
   define buffer clients-attr          for clients-attr.
   define buffer clients               for clients.
   define buffer Utd                   for Utd.
   define buffer utd_ret               for ub.utd.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer buf_utddoc-lines      for utd-lines.
   define buffer marking               for marking.
   define buffer marking-lines         for marking-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define buffer contract              for contract.
   define buffer old_utd               for Utd.
   define variable vError as character no-undo.
   define variable vGdsCode as integer no-undo.
   define variable vcli-type as character no-undo.
   define variable vcli-code as integer no-undo.
   define variable vhost-code as integer no-undo init ?.
   define variable vcontract-code as integer no-undo.
   define variable vobj-type as character no-undo init ?.
   define variable vobj-code as integer no-undo init ?.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vMark as logical no-undo.
   define variable VUcd as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable VFileMark as logical no-undo.
   define variable vunit     as int no-undo.
   define variable vunitCode as character no-undo.
   define variable vMarkingUtd as logical no-undo.
   find first Utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available Utd
   then do:
      VUcd = utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
      VFileMark = getattrutd (utd.db-num,utd.doc-id,"FileName") begins "ON_NSCHFDOPPRMARK_".
      ClearUtdErr(utd.db-num,utd.doc-id,"loadUtd").
      assign
            vobj-type  = utd.obj-type
            vobj-code  = utd.obj-code
            vhost-code = utd.host-code
      .
      do:
         define variable vtext       as character no-undo.
         define variable vhost-code1 as integer   no-undo.
         define variable vobj-type1  as character no-undo.
         define variable vobj-code1  as integer   no-undo.
          getObgFns
                    (input utd.DocumentNumber ,
                     input utd.obj-FnsParticipantId ,
                     input utd.obj-kpp,
                     output vhost-code1,
                     output vobj-type1,
                     output vobj-code1,
                     output vtext ).
         assign
            vobj-type  = vobj-type1   when vobj-type  eq ? or vobj-type  eq ""
            vobj-code  = vobj-code1   when vobj-code  eq ? or vobj-code  eq 0
            vhost-code = vhost-code1  when vhost-code eq ? or vhost-code eq 0
         .
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(vobj-type, vobj-code).
         CheckGds (utd.db-num,utd.doc-id,vobj-type,vobj-code,"loadUTD").
         block-line:
         for each utd-lines where utd-lines.db-num eq utd.db-num
                              and utd-lines.doc-id eq utd.doc-id
         no-lock:
            vGdsCode =?.
            define variable vNotMarkForLine as logical no-undo.
            vNotMarkForLine = no.
            if not VUcd
            then do:
               find first utd-marking-lines
                    where utd-marking-lines.db-num  = utd-lines.db-num
                      and utd-marking-lines.doc-id  = utd-lines.doc-id
                      and utd-marking-lines.LineNum = utd-lines.LineNum
               no-lock no-error.
               if not available utd-marking-lines
               then do:
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"loadUtd","NotMarkForLine",string(utd-lines.LineNum)).
                  vNotMarkForLine = yes.
               end.
            end.
            block-mark:
            for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
            no-lock:
               vMark = yes.
               if     isMark(utd-marking-lines.mark)
                  and utd-marking-lines.gds-code  ne 0
                  and utd-marking-lines.gds-code ne ?
               then do:
                                    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                        ( utd-marking-lines.gds-code,
                         'mark-type':U,
                         output v-par-val,
                         output v-par-type
                         ).
                   if     not VFileMark
                      and not VUcd
                      and EDOParSec:GetIsEDOForType(v-par-val) and EDOParSec:IsEdo
                   then do:
                       AddUtdErr(utd.db-num,
                                  utd.doc-id,
                                  buffer utd-marking-lines:handle,
                                  "loadUtd",
                                  "NotON_NSCHFDOPPRMARK",
                                  string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
                  end.
               end.
            end.
            if utd-lines.gds-code eq 0 or utd-lines.gds-code eq ?
            then do :
               if     VUcd
               then do:
                  GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  GetUtdLineForOrig(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,volddb-num,volddoc-id, buffer buf_utddoc-lines).
                  if available buf_utddoc-lines
                  then do:
                     vGdsCode = buf_utddoc-lines.gds-code.
                     vunitCode = buf_utddoc-lines.UnitCode.
                     if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
                        and buf_utddoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                     then
                        AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChangForUtd",
                            string(utd-lines.LineNum )                  + chr(4) +
                            buf_utddoc-lines.UnitCode                   + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
                  end.
                  if     utd-lines.UnitCode ne ?
                     and utd-lines.UnitCode ne ""
                     and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                  then
                     AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChang",
                            string(utd-lines.LineNum )                  + chr(4) +
                            utd-lines.UnitCode                          + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
               end.
            end.
            else
               vGdsCode = utd-lines.gds-code.
            define variable vValText as character no-undo.
            define variable vValDec  as decimal no-undo.
            VValText = GetAttrUtdlines (utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity").
            if VValText = ?
            then do:
               vValDec = utd-lines.Quantity.
               setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(utd-lines.Quantity)).
            end.
            else
               vValDec = dec(VValText).
            release bar-code .
            if     vGdsCode > 0 and vGdsCode ne ?
            then do:
               assign
                  vunitCode = utd-lines.UnitCode when utd-lines.UnitCode ne ? and utd-lines.UnitCode ne ""
                  vunit = ?
                  vunit = integer (getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unit"))
               no-error.
               if vunit ne 0 and vunit ne ?
               then do:
                  find units where units.OKEI eq vunit no-lock no-error.
                  if available units
                  then
                     vunitCode = units.unit-name.
               end.
               find first bar-code where bar-code.gds-code eq vGdsCode
                                     and bar-code.unit-cli eq vUnitCode
               no-lock no-error.
               if not available bar-code
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "Unit",
                            string(utd-lines.LineNum )                  + chr(4) +
                            string(vGdsCode)                            + chr(4) +
                            (if vunit ne ? then string(vunit ) else "") + chr(4) +
                            vunitCode).
            end.
            if utd-lines.Quantity ne vValDec * (if avail bar-code then bar-code.cli-base-rate else 1)
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then do:
                  buf_utd-lines.Quantity = vValDec * (if avail bar-code then bar-code.cli-base-rate else 1).
                  release buf_utd-lines.
               end.
            end.
            vValDec  = decimal(getAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old")) no-error.
            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old_new",string(vValDec * (if avail bar-code then bar-code.cli-base-rate else 1))).
            if     not VUcd
               and CheckMarkUtdLine(utd.db-num,utd.doc-id,utd-lines.LineNum)
            then
               vMarkingUtd = yes .
         end.
         if not VUcd
         then
            CheckQnty(utd.db-num, utd.doc-id, "loadUtd").
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
         else do:
            assign
              vcli-type = ?
              vcli-code = ?
            .
            AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoSuppForId",utd.cli-FnsParticipantId ).
         end.
         find first contract  where contract.host-code eq vhost-code
                                and contract.cli-type  eq vcli-type
                                and contract.cli-code  eq vcli-code
                                and contract.contract-prn-code eq Utd.BaseDocumentNumber
         no-lock no-error.
         define variable VContractEdo as logical no-undo init yes.
         if available contract
         then do:
            assign
               VContractEdo = contract.whole-send-news > 0
               vcontract-code = contract.contract-code
            .
            if not VContractEdo
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoEdoDoc", Utd.BaseDocumentNumber).
         end.
         else do:
            vcontract-code = ?.
         end.
      end.
      if not GetLastUTDinPackAft (utd.db-num, utd.doc-id, volddb-num, volddoc-id)
      then do:
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoLastDoc",string(utd.PackageId) + chr(4) + string(volddb-num) + chr(4) + string(volddoc-id)).
      end.
      define variable vdoc-code as character no-undo init ?.
      if utd.EDocType              eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
      then do:
         find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
         if available utd_ret
         then do:
            vdoc-code = utd_ret.doc-code.
            CheckUcdForReturn(utd.db-num,utd.doc-id,utd_ret.db-num,utd_ret.doc-id).
         end.
      end.
   end.
   find current utd exclusive-lock no-error.
   if available utd
   then do:
      assign
         utd.cli-type      = vcli-type      when vcli-type      ne ?
         utd.cli-code      = vcli-code      when vcli-type      ne ?
         utd.host-code     = vhost-code     when vhost-code     ne ? and vhost-code     ne 0
         utd.contract-code = vcontract-code when vcontract-code ne ?
         utd.obj-type      = vobj-type      when vobj-type      ne ? and vobj-type      ne ""
         utd.obj-code      = vobj-code      when vobj-code      ne ? and vobj-code      ne 0
         utd.doc-code      = vdoc-code      when vdoc-code      ne ?
      .
      if   ( utd.contract-code eq ?
         or utd.contract-code eq 0)
         and not vucd
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoContForFirmId",(if utd.host-code eq ? then "?" else string (utd.host-code)) + chr(4) +  utd.BaseDocumentNumber).
      if utd.host-code eq ?
         or utd.host-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoFirmForId",if utd.obj-FnsParticipantId eq ? then "?" else utd.obj-FnsParticipantId ).
      if utd.obj-code eq ?
         or utd.obj-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoShopForKpp",utd.obj-kpp).
   end.
   vError = GetErrForUtdstr(utd.db-num,utd.doc-id,"loadUtd").
   if vError eq ""
   then do:
      if utd.sts eq 0 or utd.sts eq ?
      then
         utd.sts = if VUcd
                   then ObjSrv:Env:Utd:Sts:th:ConfirmedUcd:KeyIntDB
                   else ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      if utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB
      then do:
         utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      end.
      if     not VUcd
         and utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB
      then do:
         if not vMarkingUtd
         then
            utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB.
      end.
   end.
   else do:
      if utd.sts ne ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB
      then
         utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB.
   end.
   if     utd.sts-edi  >= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
      and utd.sts-edi  <= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyEnd
   then
      utd.sts-edi = ?.
   else if     (not vMark and  not vucd) or not VContractEdo
           and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
   then
      utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB.
   release utd no-error.
   if error-status:error
   then
      return error return-value.
   return vError.
end.
function ReCheckload returns logical
(idb-num as integer,
 idoc-id as integer,
 iload   as logical ):
   subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
   define buffer buf_c-utd for ub.c-utd .
   define buffer buf_utd   for ub.utd .
   find first buf_utd where buf_utd.db-num eq idb-num
                        and buf_utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available buf_utd
   then do:
      if    iload
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:loaderror:KeyIntDB
      then do:
         SaturateAndCheckUTD(buf_utd.db-num, buf_utd.doc-id) no-error .
         if  error-status:error then
         do:
            message return-value view-as alert-box.
         end.
      end.
      if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB
      then do:
         find last buf_c-utd no-lock where buf_c-utd.db-num eq buf_utd.db-num and
                                           buf_c-utd.doc-id eq buf_utd.doc-id and
                                           buf_c-utd.sts    eq buf_utd.sts and
                                           buf_c-utd.sts    eq ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
         no-error .
         if available (buf_c-utd)
         then do:
            buf_utd.sts = buf_c-utd.sts .
            buf_utd.sts-edi = buf_c-utd.sts-edi .
         end.
         else do:
            if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
               or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
            then
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
            else
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
            buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:Verification:KeyIntDB .
         end.
      end.
      if buf_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
      then do:
         run utl/utd-checkSpec.p (input buf_utd.db-num,
                                  input buf_utd.doc-id) .
      end.
   end.
   release buf_utd.
   unsubscribe "getNextseq".
end.
function ReCheck returns logical
(idb-num as integer,
 idoc-id as integer ):
   ReCheckload(idb-num,idoc-id,no).
end.
function GetLastUTDForPac returns logical
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp gt iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
function GetprevUTDForPac returns logical
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp < iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
function GetLastUTDinPackAft returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function GetLastUTDinPackbef returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetprevUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function GetLastUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,datetime("01/01/1900"),output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function delMark returns logical
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         delMark(buffer buf_utd-marking-line).
         delete buf_utd-marking-line.
      end.
   end.
end.
function addMark returns logical
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   define buffer par_utd-marking-line for utd-marking-lines.
   define buffer buf_utd for ub.utd .
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         if buf_utd-marking-line.doc-level ne utd-marking-lines.doc-level + 1
         then do:
            find current  buf_utd-marking-line exclusive-lock no-error.
            if available buf_utd-marking-line
            then
               buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1.
         end.
      end.
      else do:
         find first buf_utd no-lock where buf_utd.db-num    eq utd-marking-lines.db-num
                                      and buf_utd.doc-id    eq utd-marking-lines.doc-id
                                      no-error .
         create buf_utd-marking-line.
         buffer-copy utd-marking-lines except doc-level mark sts gds-code to buf_utd-marking-line
         assign
            buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1
            buf_utd-marking-line.mark      = marking.mark
            buf_utd-marking-line.gds-code  = marking.Gds-code
            buf_utd-marking-line.sts      = if (available buf_utd and buf_utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB)
                                            then marking.sts
                                            else
                                            if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(marking.sts)) or
                                               can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(marking.sts)) or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                                             then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                                             else marking.sts
         .
         if  buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
         do:
           for first par_utd-marking-line no-lock where
                     par_utd-marking-line.db-num  = buf_utd-marking-line.db-num
                 and par_utd-marking-line.doc-id  = buf_utd-marking-line.doc-id
                 and par_utd-marking-line.LineNum = buf_utd-marking-line.LineNum
                 and par_utd-marking-line.mark    = marking.mark-parent
                 and par_utd-marking-line.sts     = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
           :
             buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
           end.
         end.
      end.
      addMark(buffer buf_utd-marking-line).
   end.
end.
function UnLockUTDMarkbuf returns logical
(buffer old_utd for utd,
 iAll as logical ):
   define variable voldkey    as character no-undo.
      run gen-key-rec (input "utd",
                       input  buffer old_utd:handle,
                       output voldkey).
   for each marking where marking.loc-key eq voldkey
   exclusive-lock:
      if    iAll
         or (    marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
             and marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB )
      then do:
         marking.loc-key = "".
         marking.sts =  ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB.
      end.
   end.
end.
function UnLockUTDMark returns logical
(idb-num as integer ,idoc-id as integer ,iall as logical):
   define buffer old_utd for utd.
   find first old_utd where old_utd.db-num eq idb-num
                        and old_utd.db-num eq idoc-id
   no-lock no-error.
   if available old_utd
   then do:
      UnLockUTDMarkbuf(buffer old_utd,iall).
   end.
end.
function changSts returns logical
(idb-num as integer ,
 idoc-id as integer ,
 old_sts_edo as character ,
 new_sts_edo as character  ):
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "RevocationAccepted"
           or  new_sts_edo eq "RecipientSignatureRequestRejected"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,yes).
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "WithRecipientSignature"
        or  new_sts_edo eq "WithRecipientPartiallySignature"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,no).
end.
function SetLockUTDMark returns logical
(idb-num as integer ,idoc-id as integer ):
   define buffer new_utd for utd.
   define buffer old_utd for utd.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable voldkey    as character no-undo.
   define variable vnewkey    as character no-undo.
   find first new_utd where new_utd.db-num eq idb-num
                        and new_utd.doc-id eq idoc-id
   no-lock no-error.
   if not GetLastUTDinPack (new_utd.db-num,new_utd.doc-id,volddb-num,volddoc-id)
   then do trans:
      find first old_utd where old_utd.db-num eq volddb-num
                           and old_utd.doc-id eq volddoc-id
      no-lock no-error.
         run gen-key-rec (input "utd",
                          input  buffer new_utd:handle,
                          output vnewkey).
         run gen-key-rec (input "utd",
                          input  buffer old_utd:handle,
                          output voldkey).
      for each utd-marking-lines where utd-marking-lines.db-num eq new_utd.db-num
                                   and utd-marking-lines.doc-id eq new_utd.doc-id
      no-lock:
         find first marking where marking.mark eq utd-marking-lines.mark no-lock no-error.
         if available  marking
         then do:
            if    marking.loc-key eq ""
               or marking.loc-key eq ?
               or marking.loc-key eq voldkey
            then do:
               find current marking exclusive-lock no-error.
               if available marking
               then do:
                  marking.loc-key = vnewkey.
                  release marking.
               end.
            end.
            else if marking.loc-key ne vnewkey
            then do:
               addutderr(new_utd.db-num,new_utd.doc-id,buffer new_utd:handle,"LoadUtd","MarkLock",marking.mark + chr(4) + marking.loc-key).
            end.
         end.
      end.
      UnLockUTDMark(old_utd.db-num,old_utd.doc-id,yes).
   end.
end.
function CheckedocMark return logical
(input idb-numorig as integer,
 input idoc-idorig as integer,
 input idb-numedoc as integer,
 input idoc-idedoc as integer  ):
    define variable VChekOk    as logical   no-undo init yes.
    define variable vMarkUtd   as logical   no-undo.
    define variable v-par-type as character no-undo.
    define variable v-par-val  as character no-undo.
    define buffer buf_utd-attr      for utd-attr.
    define buffer buf_utd           for utd.
    define buffer utd-marking-lines for utd-marking-lines.
    define buffer utd-lines         for utd-lines.
    define buffer marking           for marking.
    define buffer edoc-lines        for utd-lines.
       for each utd-marking-lines where utd-marking-lines.db-num    eq idb-numorig
                                    and utd-marking-lines.doc-id    eq idoc-idorig
                                    and utd-marking-lines.doc-level eq 1
                                    and utd-marking-lines.sts       eq objSrv:Env:marking:Sts:Mark:Checked_:KeyIntDB
       no-lock:
          if    isMark (utd-marking-lines.mark)
          then do:
             create tt-utd-mark.
             buffer-copy utd-marking-lines to tt-utd-mark
             assign
                tt-utd-mark.side = "+"
             .
          end.
       end.
       for each utd-marking-lines where utd-marking-lines.db-num eq idb-numedoc
                                    and utd-marking-lines.doc-id eq idoc-idedoc
                                    and utd-marking-lines.doc-level eq 1
       no-lock:
          if    isMark (utd-marking-lines.mark)
          then do:
             find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
             no-lock no-error.
             if available tt-utd-mark
             then
                tt-utd-mark.side = "".
             else do:
                create tt-utd-mark.
                buffer-copy utd-marking-lines to tt-utd-mark
                assign
                   tt-utd-mark.side = "-"
                .
             end.
          end.
       end.
       for each tt-utd-mark where  tt-utd-mark.side ne ""
       no-lock:
          AddUtdErrForTab(idb-numedoc, idoc-idedoc, "utd-marking-lines", buffer tt-utd-mark:handle, "edoc", "MarkOrig" + tt-utd-mark.side, tt-utd-mark.mark).
          VChekOk = no.
       end.
       for each utd-lines where utd-lines.db-num    eq idb-numorig
                            and utd-lines.doc-id    eq idoc-idorig
       no-lock:
          find first edoc-lines where edoc-lines.db-num eq idb-numedoc
                                  and edoc-lines.doc-id eq idoc-idedoc
                                  and edoc-lines.LineNum eq utd-lines.LineNum
          no-lock no-error.
          define variable VUtdlinequentity as decimal no-undo.
          VUtdlinequentity = dec (getattrutdlinesex(utd-lines.db-num ,utd-lines.doc-id,utd-lines.LineNum,"QuantityBarCode","0")).
          if     VUtdlinequentity eq ?
             or (if available edoc-lines then edoc-lines.Quantity else 0) ne VUtdlinequentity
          then
             AddUtdErr(idb-numedoc, idoc-idedoc,buffer edoc-lines:handle,"edoc","lineQnty",string(edoc-lines.LineNum ) + chr(4) + string(VUtdlinequentity) + chr(4) + string(edoc-lines.Quantity ) ).
       end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
function CheckEdoc returns character
(idb-numOrig as integer ,
 idoc-idOrig as integer,
 idb-num as integer ,
 idoc-id as integer ):
   define buffer utd  for ub.utd.
   define buffer utd-lines  for ub.utd-lines.
   define buffer utd-marking-lines  for ub.utd-marking-lines.
   define buffer edoc-lines for ub.utd-lines.
   define variable vSts as integer no-undo.
   define variable vMarkutd as logical no-undo.
   vSts = objSrv:Env:utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
   Block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   exclusive-lock:
      define variable ismarkin as logical no-undo.
      define variable isOAD as logical no-undo.
      define variable isper as logical no-undo.
      getMarkUtdLine(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,
           output ismarkin, output isOAD, output isper).
      if    utd-lines.Price                eq 0
         or utd-lines.Total                eq 0
         or utd-lines.TotalWithVatExcluded eq 0
         or utd-lines.Quantity             eq 0
      then do:
         for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                      and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                      and utd-marking-lines.linenum eq utd-lines.LineNum
         no-lock:
            if    isMark(utd-marking-lines.mark)
               or isOad(utd-marking-lines.mark)
            then do:
               AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,"Edoc","Amount" , string(utd-lines.LineNum )).
               next Block-line.
            end.
         end.
         delete utd-lines.
      end.
      else if   ( utd-lines.Total                ne 0
              or utd-lines.Quantity             ne 0)
              and ismarkin or isOAD
      then do:
         Block-mark:
         for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                      and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                      and utd-marking-lines.linenum eq utd-lines.LineNum
         no-lock:
            if  (isOAD and
                  isMark(utd-marking-lines.mark)
               or isOad(utd-marking-lines.mark) )
               or (ismarkin and
                  isMark(utd-marking-lines.mark))
            then do:
               leave Block-mark.
            end.
         end.
         if not available utd-marking-lines
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,"Edoc","Mark" ,string(utd-lines.LineNum)).
      end.
   end.
   for each utd-lines where utd-lines.db-num eq idb-numOrig
                        and utd-lines.doc-id eq idoc-idOrig
   no-lock:
      find first edoc-lines where edoc-lines.db-num eq idb-num
                              and edoc-lines.doc-id eq idoc-id
                              and edoc-lines.LineNum eq utd-lines.LineNum
      no-lock no-error.
      if     available edoc-lines
      then do:
         if edoc-lines.Quantity ne 0
         then do:
            if edoc-lines.Price ne utd-lines.Price
            then
               AddUtdErr(edoc-lines.db-num,edoc-lines.doc-id,buffer edoc-lines:handle,"Edoc","Price" ,string(edoc-lines.LineNum)).
         end.
      end.
      vSts = objSrv:Env:utd:Sts:th:SignatureRequired:KeyIntDB.
      CheckedocMark(idb-numOrig , idoc-idOrig , idb-num , idoc-id).
   end.
   define variable vError as character no-undo.
   vError = GetErrForUtdstr(idb-num , idoc-id ,"edoc").
   if vError ne ""
   then
      vSts = objSrv:Env:utd:Sts:th:edocError:KeyIntDB.
   else
      vSts = objSrv:Env:utd:Sts:th:SignatureRequired:KeyIntDB.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available utd
   then do:
      utd.sts = vsts.
   end.
end.
function CrEdoc returns character
(iPack as character ,
 iTimestamp as datetime):
   define variable vdb-num as integer no-undo.
   define variable vdoc-id as integer no-undo.
   define buffer utd  for ub.utd.
   define buffer edoc for ub.utd.
   define buffer utd_ret   for ub.utd.
   define buffer utd-attr  for ub.utd-attr.
   define buffer edoc-attr for ub.utd-attr.
   define buffer utd-lines  for ub.utd-lines.
   define buffer edoc-lines for ub.utd-lines.
   define buffer utd-lines-attr  for ub.utd-lines-attr.
   define buffer edoc-lines-attr for ub.utd-lines-attr.
   define buffer utd-marking-lines  for ub.utd-marking-lines.
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
   define buffer edoc-marking-lines-attr for ub.utd-marking-lines-attr.
   define variable vTimestamp  as datetime no-undo.
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                   and utd.Timestamp ge iTimestamp
   no-lock no-error.
   if available utd
   then
      return "Есть документ позже".
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                   and utd.Timestamp le iTimestamp
   no-lock no-error.
   if not available utd
   then
      return "Не найден УКД".
   define variable vdb-numOrig as integer no-undo.
   define variable vdoc-idOrig as integer no-undo.
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                   and utd.Timestamp le iTimestamp
   no-lock no-error.
   if available utd
   then do:
      subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
      MySeqUtd = ?.
      vTimestamp = utd.Timestamp.
      create edoc.
      vdb-num = utd.db-num.
      vdoc-id = utd.doc-id.
      buffer-copy utd except doc-id db-num DocumentExt OrganizationExt comment to edoc
      assign
         edoc.EDocType = objSrv:Env:Utd:EDocType:edoc:KeyIntDB
         edoc.Timestamp = iTimestamp + 1
         edoc.AmendmentRequested = no
         edoc.sts-edi  = objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
      .
      validate edoc.
      for each utd-attr where utd-attr.db-num eq vdb-num
                          and utd-attr.doc-id eq vdoc-id
                          and utd-attr.attr-code ne "ststhbeforeCorrection"
                          and utd-attr.attr-code ne "sendcode"
      no-lock:
         create edoc-attr.
         buffer-copy utd-attr except doc-id db-num to edoc-attr
         assign
            edoc-attr.db-num = edoc.db-num
            edoc-attr.doc-id = edoc.doc-id
         .
      end.
      for each utd-lines where utd-lines.db-num eq vdb-num
                           and utd-lines.doc-id eq vdoc-id
      no-lock:
         create edoc-lines.
         buffer-copy utd-lines except doc-id db-num to edoc-lines
         assign
            edoc-lines.db-num = edoc.db-num
            edoc-lines.doc-id = edoc.doc-id
         .
         release edoc-lines.
      end.
      for each utd-lines-attr where utd-lines-attr.db-num eq vdb-num
                                and utd-lines-attr.doc-id eq vdoc-id
      no-lock:
         create edoc-lines-attr.
         buffer-copy utd-lines-attr except doc-id db-num to edoc-lines-attr
         assign
            edoc-lines-attr.db-num = edoc.db-num
            edoc-lines-attr.doc-id = edoc.doc-id
         .
      end.
      for each utd-marking-lines where utd-marking-lines.db-num eq vdb-num
                                   and utd-marking-lines.doc-id eq vdoc-id
                                   and utd-marking-lines.doc-level eq 1
      no-lock:
         create edoc-marking-lines.
         buffer-copy utd-marking-lines except doc-id db-num to edoc-marking-lines
         assign
            edoc-marking-lines.db-num = edoc.db-num
            edoc-marking-lines.doc-id = edoc.doc-id
         .
      end.
      for each utd-marking-lines-attr where utd-marking-lines-attr.db-num eq vdb-num
                                        and utd-marking-lines-attr.doc-id eq vdoc-id
      no-lock:
         if utd-marking-lines-attr.attr-code eq "box-qnty"
         then do:
             find first edoc-marking-lines-attr  where edoc-marking-lines-attr.db-num    eq utd-marking-lines-attr.db-num
                                                   and edoc-marking-lines-attr.doc-id    eq utd-marking-lines-attr.doc-id
                                                   and edoc-marking-lines-attr.LineNum   eq utd-marking-lines-attr.LineNum
                                                   and edoc-marking-lines-attr.mark      eq utd-marking-lines-attr.mark
                                                   and edoc-marking-lines-attr.attr-code eq utd-marking-lines-attr.attr-code
             no-lock no-error.
         end.
         if not avail edoc-marking-lines-attr
         then do:
             create edoc-marking-lines-attr.
             buffer-copy utd-marking-lines-attr except doc-id db-num to edoc-marking-lines-attr
             assign
                edoc-marking-lines-attr.db-num = vdb-num
                edoc-marking-lines-attr.doc-id = vdoc-id
             .
         end.
         release edoc-marking-lines-attr.
      end.
      for each utd where utd.PackageId eq iPack
                     and utd.EDocType  eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
                     and utd.Timestamp gt vTimestamp
                     and utd.Timestamp le iTimestamp
                     and (    utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WithRecipientPartiallySignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
      no-lock by utd.PackageId by utd.EDocType by utd.Timestamp:
         edoc.Total = edoc.Total + utd.total.
         edoc.Vat = edoc.Vat + utd.Vat.
         edoc.DocumentDate = utd.DocumentDate.
         edoc.Timestamp = utd.Timestamp + 1.
         for each utd-lines where utd-lines.db-num     = utd.db-num
                              and utd-lines.doc-id     = utd.doc-id
         no-lock:
            block-mark:
            for each utd-marking-lines where utd-marking-lines.db-num eq utd-lines.db-num
                                         and utd-marking-lines.doc-id eq utd-lines.doc-id
                                         and utd-marking-lines.LineNum eq utd-lines.LineNum
                                         and utd-marking-lines.site eq "-"
                                         no-lock:
               if isOAD(utd-marking-lines.mark)
               then do:
                  define variable VOAD as character no-undo.
                  VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                               and edoc-marking-lines.doc-id eq edoc.doc-id
                                               and edoc-marking-lines.mark   begins VOAD
                  no-lock no-error.
               end.
               else
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                  and edoc-marking-lines.doc-id eq edoc.doc-id
                                                  and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     no-lock no-error.
               if available edoc-marking-lines
               then do:
                  find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                    and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                    and edoc-lines.LineNum           = edoc-marking-lines.LineNum
                  exclusive-lock no-error.
                  leave block-mark.
               end.
            end.
            if not available edoc-lines
            then
               find first edoc-lines where edoc-lines.db-num      = edoc.db-num
                                       and edoc-lines.doc-id      = edoc.doc-id
                                       and edoc-lines.ProductCode = utd-lines.ProductCode
               exclusive-lock no-error.
            if not available edoc-lines
            then do:
               find last edoc-lines where edoc-lines.db-num      = edoc.db-num
                                      and edoc-lines.doc-id      = edoc.doc-id
               no-lock no-error.
               define variable vline as integer no-undo.
               vline = if available edoc-lines then edoc-lines.linenum + 1 else 1.
               create edoc-lines.
               buffer-copy utd-lines except doc-id db-num linenum to edoc-lines
               assign
                  edoc-lines.db-num = edoc.db-num
                  edoc-lines.doc-id = edoc.doc-id
                  edoc-lines.linenum = vline
               .
            end.
            else
               assign
                  edoc-lines.Vat       = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Vat_old") )       + utd-lines.Vat
                  edoc-lines.Total     = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Total_old") )     + utd-lines.Total
                  edoc-lines.Quantity  = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Quantity_old_new") )  + utd-lines.Quantity.
                  edoc-lines.TotalWithVatExcluded = edoc-lines.Total - edoc-lines.Vat.
               .
            define variable Vqnty as decimal no-undo.
            Vqnty = dec(getattrUtdlines(edoc-lines.db-num,edoc-lines.doc-id,edoc-lines.LineNum,"Quantity") )
                  + dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Quantity") ).
            setattrUtdlines(edoc-lines.db-num,edoc-lines.doc-id,edoc-lines.LineNum,"Quantity",string(vqnty)).
            if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
               and edoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
            then
               AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,
                   "loadUtd",
                   "UcdUnitChangForUtd",
                   string(edoc-lines.LineNum )                  + chr(4) +
                   edoc-lines.UnitCode                   + chr(4) +
                   getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
            if     utd-lines.UnitCode ne ?
               and utd-lines.UnitCode ne ""
               and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
            then
               AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,
                      "loadUtd",
                      "UcdUnitChang",
                      string(edoc-lines.LineNum )                  + chr(4) +
                      utd-lines.UnitCode                          + chr(4) +
                      getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
            for each utd-marking-lines where utd-marking-lines.db-num eq utd-lines.db-num
                                         and utd-marking-lines.doc-id eq utd-lines.doc-id
                                         and utd-marking-lines.LineNum eq utd-lines.LineNum
            no-lock by utd-marking-lines.site by utd-marking-lines.doc-level desc:
               if utd-marking-lines.site eq "-"
               then do:
                  if isOAD(utd-marking-lines.mark)
                  then do:
                     VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                     and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                     and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     exclusive-lock no-error.
                     if not available edoc-marking-lines
                     then
                        find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                     and edoc-marking-lines.doc-id eq edoc.doc-id
                                                     and edoc-marking-lines.mark   begins VOAD
                        exclusive-lock no-error.
                     if not available edoc-marking-lines
                     then
                        AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
                     else do:
                        define variable v37tegdoc as character no-undo.
                        define variable v37tegedoc as character no-undo.
                        v37tegdoc  = GetTegCod( utd-marking-lines.mark,"37").
                        v37tegedoc = GetTegCod(edoc-marking-lines.mark,"37").
                        vqnty = int(v37tegedoc) - int(v37tegdoc) no-error.
                        if error-status:error
                        then
                           message "беда с маркой" skip edoc-marking-lines.mark skip utd-marking-lines.mark
                           view-as alert-box.
                        else if vqnty = 0
                        then
                           delete edoc-marking-lines.
                        else do:
                           edoc-marking-lines.mark  = VOAD + string(vqnty).
                           setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(vQnty)).
                        end.
                     end.
                  end.
                  else do:
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                     and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                     and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     exclusive-lock no-error.
                     if available edoc-marking-lines
                     then
                        delete edoc-marking-lines.
                     else
                        AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
                  end.
               end.
               else if utd-marking-lines.site eq "+"
               then do:
                  if isOAD(utd-marking-lines.mark)
                  then do:
                     VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                  and edoc-marking-lines.doc-id eq edoc.doc-id
                                                  and edoc-marking-lines.mark   begins VOAD
                     exclusive-lock no-error.
                     if available edoc-marking-lines
                     then do:
                        v37tegdoc  = GetTegCod( utd-marking-lines.mark,"37").
                        v37tegedoc = GetTegCod(edoc-marking-lines.mark,"37").
                        vqnty = int(v37tegedoc) + int(v37tegdoc) no-error.
                        if error-status:error
                        then
                           message "беда с маркой" skip edoc-marking-lines.mark skip utd-marking-lines.mark
                           view-as alert-box.
                        else if vqnty = 0
                        then
                           delete edoc-marking-lines.
                        else do:
                           edoc-marking-lines.mark  = VOAD + string(vqnty).
                           setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(vQnty)).
                        end.
                     end.
                     else do:
                        create edoc-marking-lines.
                        buffer-copy utd-marking-lines except doc-id db-num to edoc-marking-lines
                        assign
                           edoc-marking-lines.db-num = edoc.db-num
                           edoc-marking-lines.doc-id = edoc.doc-id
                        .
                        setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(int(GetTegCod(edoc-marking-lines.mark,"37")))) no-error.
                     end.
                  end.
                  else do:
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                  and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                  and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
                  if not available edoc-marking-lines
                  then do:
                     create edoc-marking-lines.
                     buffer-copy utd-marking-lines except doc-id db-num linenum to edoc-marking-lines
                     assign
                        edoc-marking-lines.db-num  = edoc-lines.db-num
                        edoc-marking-lines.doc-id  = edoc-lines.doc-id
                        edoc-marking-lines.linenum = edoc-lines.linenum
                     .
                  end.
                  else
                     AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"Edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
               end.
            end.
            release edoc-lines.
         end.
         release edoc-lines.
      end.
      find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
      if not avail utd_ret
      then
         CheckEdoc (vdb-num,vdoc-id,edoc.db-num,edoc.doc-id) .
   end.
   for each utd where utd.PackageId eq iPack
                     and utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                     and utd.Timestamp < iTimestamp
      exclusive-lock:
         utd.sts-edi = objSrv:Env:Utd:sts:edi:Changed:KeyIntDB.
         utd.sts     = objSrv:Env:Utd:sts:th:Rejection:KeyIntDB.
      end.
      unsubscribe "getNextseq".
   end.
end.
define variable Mext-sys as integer no-undo init ?.
define variable mdb-num-local as integer no-undo.
run gbl/getdbnum.p (output mdb-num-local).
function  getExtSys returns integer
():
   define buffer ext-system      for ext-system.
   define buffer ext-system-attr for ext-system-attr.
   Mext-sys = ?.
   block-sys-obj:
   for each ext-system where ext-system.esys-type eq 12
                         and ext-system.db-num    eq mdb-num-local
   no-lock:
       find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                    and ext-system-attr.esys-id eq ext-system.esys-id
                                    and ext-system-attr.esya-attr-code eq 'obj':U
       no-lock no-error.
       if     available ext-system-attr
          and           ext-system-attr.esya-attr-value eq v-cntxt-obj-type + string(v-cntxt-obj-code)
       then do:
          Mext-sys = ext-system-attr.esys-id.
          leave block-sys-obj.
       end.
   end.
   if Mext-sys eq ?
   then do:
      block-sys-host:
      for each ext-system where ext-system.esys-type eq 12
                            and ext-system.db-num    eq mdb-num-local
      no-lock:
          find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                       and ext-system-attr.esys-id eq ext-system.esys-id
                                       and ext-system-attr.esya-attr-code eq 'host-code':U
          no-lock no-error.
          if     available ext-system-attr
             and           ext-system-attr.esya-attr-value eq string(v-cntxt-host-code-obj)
          then do:
             Mext-sys = ext-system-attr.esys-id.
             leave block-sys-host.
          end.
      end.
   end.
   return Mext-sys.
end.
function  getExtAttr returns character
(input icode as character ):
   define variable oValue as character no-undo.
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   get-key-value section "ProxyServ" key icode value oValue.
   if oValue eq ?
   then do:
      if Mext-sys eq ?
      then
         getExtSys ().
      find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                      and ext-system.esys-id eq Mext-sys no-error.
      if available ext-system
      then do:
             if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
         (ext-system.esys-id,
          mdb-num-local,
          icode,
          output oValue,
          output vtype) no-error.
       end.
   end.
   return if oValue eq ? then "" else oValue .
end.
function  SetExtAttr returns character
(input icode   as character,
 input iValue  as character):
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   if Mext-sys eq ?
   then
      getExtSys ().
   find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                   and ext-system.esys-id eq Mext-sys no-error.
   if available ext-system
   then do:
       if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (ext-system.esys-id,
       mdb-num-local,
       icode,
       iValue) no-error.
    end.
end.
define stream File-stream.
function PutMes returns character
(idext as character ):
   if valid-handle(mPublishHand)
   then
      publish "WriteLogAsunc" from mPublishHand (idext,yes).
   else do:
      if idext begins "error"
      then do:
         message substring (idext,6)
            view-as alert-box.
         if mDiadocApi ne ?
         then
            idext = substitute ("&1 (&2)",idext , mDiadocApi:GetFullVersion())no-error.
      end.
      output stream File-stream to "diadoc_user.log" append.
      put stream File-stream unformatted now " " idext skip.
      output stream File-stream close.
   end.
end.
function PutErr returns character
(idext as character ):
   define variable vi as integer no-undo.
   define variable vnumerr as integer no-undo.
   define variable vtext as character extent 25 no-undo .
   if error-status:num-messages > 0 then do:
      vnumerr = error-status:num-messages.
      vnumerr = min(vnumerr,extent(vtext)).
      do vi = 1 to vnumerr:
         vtext[vi] = error-status:get-message(vi).
      end.
      idext = idext + chr(10) + "Ошибка: [":U.
      do vi = 1 to vnumerr:
         idext = idext + chr(10) + vtext[vi] no-error.
      end.
      idext = idext +  chr(10) +  " ]" no-error.
      if not  idext begins "Error"
      then
         idext = "Error " + idext.
      PutMes(idext).
   end.
end.
function PutStat returns character
(itext as character,
 iflag as logical):
   if valid-handle(mPublishHand)
   then
      publish "PutStatAsunc" from mPublishHand (itext,iflag).
   PutMes(itext).
end.
function chekStop returns logical
( ):
   define variable oStop as logical no-undo.
   if valid-handle(mPublishHand)
   then
      publish "StopProc" from mPublishHand (output oStop).
   return oStop.
end.
function  putloggetdesc returns logical
(is1 as character ,is2 as character ,
is3 as character ):
end.
function  getdesc returns logical
(input iObj as component-handle):
   if iObj eq ? then return false.
   if mdebug
   then do:
   output stream File-stream to "diadoc_load.txt" append.
   define variable vReflector as component-handle no-undo.
   define variable vDescobj  as component-handle no-undo.
   define variable vPropertyNames  as component-handle no-undo.
   define variable vMethodsNames as component-handle no-undo.
   define variable vMethodDesc as component-handle no-undo.
   define variable vMethodsName as character  no-undo.
   define variable vPropertyValue as char no-undo.
   create "Diadoc.Reflector" vReflector.
   vDescobj = vReflector:Describe(iObj).
  put   stream File-stream  unformatted skip (1)
   "------------------------------------------" skip
   vDescobj:GetInterfaceName() skip.
   define variable vPropertyName as character no-undo.
   define variable vPropertyType as character no-undo.
   .
   putloggetdesc(vDescobj:GetInterfaceName(),"","").
   putloggetdesc("property","","").
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
  put stream File-stream  unformatted skip "property" skip.
  vPropertyNames = vDescobj:GetPropertiesNames().
   vi= vPropertyNames:count.
   do vi= 1 to vPropertyNames:count :
      vPropertyName = "".
      vPropertyType = "".
      vPropertyValue = "".
      vPropertyName  = vPropertyNames:GetItem(vi - 1) no-error.
      vPropertyType  = vDescobj:GetPropertyType(vPropertyName) no-error .
      vPropertyValue = substring((vDescobj:GetProperty(vPropertyName)),1,4000) no-error.
      putloggetdesc(vPropertyName,vPropertyType,vPropertyValue).
     put stream File-stream  unformatted vPropertyName " " vPropertyType  " " vPropertyValue skip.
   end.
   release object vPropertyNames.
   put stream File-stream  unformatted skip "method" skip.
   vMethodsNames = vDescobj:GetMethodsNames().
   vi = vMethodsNames:count.
   do vi = 1 to vMethodsNames:count :
      vMethodsName = "".
      vMethodsName = vMethodsNames:GetItem(vi - 1)no-error.
      vMethodDesc  = vDescobj:GetMethodDesc(vMethodsName)no-error.
      putloggetdesc("method",vMethodsName, vMethodDesc:RetVal).
      put stream File-stream  unformatted vMethodsName  " retval " vMethodDesc:RetVal skip.
      do vii  = 1 to vMethodDesc:args:count:
         define variable varg as character no-undo.
         varg = "".
         varg = vMethodDesc:args:GetItem(vii - 1) no-error.
         put stream File-stream  unformatted " args " varg  skip .
         putloggetdesc(" args ",varg, "").
      end.
      release object vMethodDesc.
   end.
   release object vMethodsNames.
   put stream File-stream  unformatted "end---------------------------------------" skip.
   output stream File-stream close.
   release object vDescobj.
   release object vReflector.
   end.
   return true.
end.
function getxsddocum returns logical
(iOrganization as component-handle):
   if iOrganization eq ? then return false.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType as component-handle no-undo.
   define variable vFunctions as component-handle no-undo.
   define variable vFunction as component-handle no-undo.
   define variable vVersions as component-handle no-undo.
   define variable vVersion as component-handle no-undo.
   define variable vTitles as component-handle no-undo.
   define variable vTitle as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable viiii as integer no-undo.
   if mdebug
   then do:
   output stream File-stream to "diadoc_doc.txt" append.
   vDocumentTypes = iOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      put stream File-stream  unformatted "DocumentType -> NAme " vDocumentType:name skip.
      put stream File-stream  unformatted "DocumentType -> Title " vDocumentType:Title skip.
      vFunctions = vDocumentType:Functions.
      do vii =1 to vFunctions:count:
         vFunction = vFunctions:GetItem(vii - 1 ).
         put stream File-stream  unformatted "DocumentType -> Function -> NAme " vFunction:name skip.
         vVersions = vFunction:Versions.
         do viii =1 to vVersions:count:
            vVersion = vVersions:GetItem(viii - 1 ).
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> version " vVersion:version skip.
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> IsActual " vVersion:IsActual skip.
            vTitles  = vVersion:Titles.
            do viiii =1 to vTitles:count:
               vTitle = vTitles:GetItem(viiii - 1 ).
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> IsFormal " vTitle:IsFormal skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> XsdUrl " vTitle:XsdUrl skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> HaveUserDataXSD " vTitle:HaveUserDataXSD skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> type " vTitle:type skip.
               release object vTitle.
            end.
           release object vTitles.
            release object vVersion.
         end.
         release object vVersions.
         release object vFunction.
      end.
      release object vFunctions.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   put stream File-stream  unformatted "--------------------------------------------------- " skip.
  output stream File-stream close.
  end.
   return true.
end.
function GetDocTitleType returns character
(iOrganizationGuid as character ,
itype as character ,
ifunction as character,
iversion as character
):
   if iOrganizationGuid eq ? then return "".
   define variable vOrganization  as component-handle no-undo.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType  as component-handle no-undo.
   define variable vFunctions     as component-handle no-undo.
   define variable vFunction      as component-handle no-undo.
   define variable vVersions      as component-handle no-undo.
   define variable vVersion       as component-handle no-undo.
   define variable vTitles        as component-handle no-undo.
   define variable vTitle         as component-handle no-undo.
   define variable vi             as integer no-undo.
   define variable vii            as integer no-undo.
   define variable viii           as integer no-undo.
   define variable viiii          as integer no-undo.
   define variable oTitleType as character no-undo.
   vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
   if vOrganization eq ? then return "".
   vDocumentTypes = vOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      if vDocumentType:name eq iType
      then do:
         vFunctions = vDocumentType:Functions.
         do vii =1 to vFunctions:count:
            vFunction = vFunctions:GetItem(vii - 1 ).
            if vFunction:name eq ifunction
            then do:
               vVersions = vFunction:Versions.
               do viii =1 to vVersions:count:
                  vVersion = vVersions:GetItem(viii - 1 ).
                  if vVersion:version eq iversion
                  then do:
                     vTitles  = vVersion:Titles.
                     do viiii =1 to vTitles:count:
                        vTitle = vTitles:GetItem(viiii - 1 ).
                        oTitleType = oTitleType + "," + vTitle:type.
                        release object vTitle.
                     end.
                     release object vTitles.
                  end.
                  release object vVersion.
               end.
               release object vVersions.
            end.
            release object vFunction.
         end.
         release object vFunctions.
      end.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   release object vOrganization.
   return left-trim(oTitleType,",").
end.
define temp-table tt-type no-undo
          field id as char
          field name as character
          index pi id .
define temp-table tt-Class no-undo like tt-type.
function crcode returns character
():
   define variable vtypelist as character no-undo.
   define variable vtypename as character no-undo.
   define variable vi as integer no-undo.
   vtypelist =
              "UniversalTransferDocument|"
             + "UniversalTransferDocumentRevision|"
             + "UniversalCorrectionDocument|"
             + "UniversalCorrectionDocumentRevision"
             .
   vtypename =
              "УПД|"
             + "Исправление УПД|"
             + "УКД|"
             + "Исправление УКД"
             .
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-type.
      assign
         tt-type.id   =  entry(vi,vtypelist,"|")
         tt-type.name =  entry(vi,vtypename,"|")
      .
   end.
   vtypelist = "Inbound|"
             + "Outbound|"
             + "Proxy".
   vtypename = "входящий документ|"
             + "исходящий документ|"
             + "документ, переданный через промежуточного получателя|".
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-Class.
      assign
         tt-Class.id   =  entry(vi,vtypelist,"|")
         tt-Class.name =  entry(vi,vtypename,"|")
      .
   end.
end.
crcode().
function getOrganizationInfo returns character
(input iContAgent as component-handle,
                                                output oinn as character,
                                                output oKpp as character,
                                                output oFnsParticipantId as character,
                                                output oOrgName as character,
                                                output oAdditionalInfo as character,
                                                output OarddrRus as character
                                                 ):
   define variable vi as integer no-undo.
   define variable vContAgentOrganizationDetails   as component-handle no-undo.
   define variable vAddrRus                        as component-handle no-undo.
   if iContAgent ne ?
   then do:
      getdesc(iContAgent).
      vContAgentOrganizationDetails = iContAgent:OrganizationDetails.
      oinn = vContAgentOrganizationDetails:Inn.
      oKpp = vContAgentOrganizationDetails:Kpp.
      oFnsParticipantId = vContAgentOrganizationDetails:FnsParticipantId.
      oAdditionalInfo = vContAgentOrganizationDetails:OrganizationAdditionalInfo.
      getdesc(vContAgentOrganizationDetails).
      oOrgName = vContAgentOrganizationDetails:OrgName.
      getdesc(vContAgentOrganizationDetails:Address).
      vAddrRus = vContAgentOrganizationDetails:Address:RussianAddress.
      getdesc(vAddrRus ).
      if vAddrRus ne ?
      then do:
         if vAddrRus:ZipCode ne ""
         then
            OarddrRus = OarddrRus + " " + vAddrRus:ZipCode.
         if vAddrRus:Region ne ""
         then
            OarddrRus = OarddrRus + " Регион: " + vAddrRus:Region.
         if vAddrRus:Territory ne ""
         then
            OarddrRus = OarddrRus + " Область: " + vAddrRus:Territory.
         if vAddrRus:City ne ""
         then
            OarddrRus = OarddrRus + " Город: " + vAddrRus:City.
         if vAddrRus:Locality ne ""
         then
            OarddrRus = OarddrRus + " Район: " + vAddrRus:Locality.
         if vAddrRus:Street ne ""
         then
            OarddrRus = OarddrRus + " Улица: " + vAddrRus:Street.
         if vAddrRus:Block ne ""
         then
            OarddrRus = OarddrRus + " Стр: " + vAddrRus:Block.
         if vAddrRus:Building ne ""
         then
            OarddrRus = OarddrRus + " Дом: " + vAddrRus:Building.
         if vAddrRus:Apartment ne ""
         then
            OarddrRus = OarddrRus + " Квартира: " + vAddrRus:Apartment.
      end.
      release object vAddrRus.
      release object vContAgentOrganizationDetails.
   end.
end.
function ConectByCertif return component-handle
(iThumbprint as character ):
  if mDiadocApi eq ? then return ?.
  if iThumbprint eq ""
  then do:
     release object mDiadocConnection no-error.
     return ?.
  end.
   mDiadocApi:ApiClientId =  getextAttr('diadoc-key':U).
   mDiadocApi:ServerUrl   =  getextAttr('server-addr':U).
   define variable vSSl as character no-undo.
   vSSl =  getextAttr('diadoc-ssl':U).
   if vSSl ne ""
      and logical(vSSl)
   then
      mDiadocApi:VerifySslCertificate = no.
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     message "Не задан адрес сервера или ключ разработчика для внешей системы Диадок"
     view-as alert-box.
     release object mDiadocConnection no-error.
     return ?.
  end.
  define variable VProxy as character no-undo.
   vProxy =  getextAttr('proxy-addr':U).
   if     vProxy ne ""
      and vProxy ne ?
   then do:
      mDiadocApi:ProxyMode =  "UseProxy".
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr('proxy-login':U).
      mDiadocApi:ProxySettings:Password = getextAttr('proxy-pswd':U).
   end.
   define variable vtest as component-handle no-undo.
   vtest = mDiadocApi:TestConnection2().
   if not vtest:ConnectionSuccess
   then do:
      PutMes(vtest:ErrorText).
   end.
   else
      mDiadocConnection = mDiadocApi:CreateConnectionByCertificate(iThumbprint,"") no-error.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocApi:CreateConnectionByCertificate:").
   release object vtest.
   return mDiadocConnection.
end.
function ConectByLogin return component-handle
():
   define variable vSSl as character no-undo.
   if mDiadocApi eq ? then return ?.
   mDiadocApi:ApiClientId = getextAttr('diadoc-key':U).
   mDiadocApi:ServerUrl   = getextAttr('server-addr':U).
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     PutMes( "Error Не задан адрес сервера или ключ разработчика для внешей системы Диадок").
     release object mDiadocConnection no-error.
     return ?.
  end.
  vSSl =  getextAttr('diadoc-ssl':U).
  if vSSl ne ""
     and logical(vSSl)
  then
      mDiadocApi:VerifySslCertificate = no.
  define variable VProxy as character no-undo.
   vProxy =  getextAttr('proxy-addr':U).
   if     vProxy ne ""
      and vProxy ne ?
   then do:
      mDiadocApi:ProxyMode =  "UseProxy".
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr('proxy-login':U).
      mDiadocApi:ProxySettings:Password = getextAttr('proxy-pswd':U).
   end.
   mDiadocConnection = mDiadocAPI:CreateConnectionByLogin(getextAttr('diadoc-user':U),getextAttr('diadoc-pwd':U)) no-error.
   define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocAPI:CreateConnectionByLogin").
   return mDiadocConnection.
end.
function GetDocumforid returns character
(input  iorg as character ,
 input  idoc-id as character ,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   if
          iorg  ne ?
      and iorg  ne ""
      and idoc-id ne ?
      and idoc-id ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(iorg) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(idoc-id,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", iorg,idoc-id)).
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", iorg,idoc-id)).
         return "Нет доступа к организации " + iorg.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   release object vOrganization no-error.
   return "".
end.
function GetDocum returns character
(input  idb-num as integer,
 input  idoc-id as integer,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if     available utd
      and utd.OrganizationExt ne ?
      and utd.OrganizationExt ne ""
      and utd.DocumentExt ne ?
      and utd.DocumentExt ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(utd.OrganizationExt) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(utd.DocumentExt,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", utd.OrganizationExt,utd.DocumentExt)).
         release object vOrganization no-error.
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", utd.OrganizationExt,utd.DocumentNumber)).
         return "Нет доступа к организации " + utd.OrganizationExt.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   return "".
end.
function GetFirstUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         find first buf_utd where Buf_utd.PackageId eq utd.PackageId
                              and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
         no-lock.
         assign
            odb-num = buf_utd.db-num
            odoc-id = buf_utd.doc-id
         .
         return if available buf_utd then (recid(utd) eq recid(buf_utd)) else no.
      end.
   end.
   return ?.
end.
function AddOADLine returns integer
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iGtin    as char,
 iQnty    as int,
 isite    as character ):
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define variable vnewMark as character no-undo.
    define variable vQnty    as integer   no-undo.
    vnewMark = "02" + iGtin + "37" + string(iQnty).
    find first utd-marking-lines where utd-marking-lines.mark       = vnewMark
                                   and utd-marking-lines.db-num     = idb-num
                                   and utd-marking-lines.doc-id     = idoc-id
                                   and utd-marking-lines.Linenum    = iLinenum
    exclusive-lock no-error.
    if available utd-marking-lines
    then do:
       delete utd-marking-lines.
       vQnty = AddOADLine(idb-num, idoc-id, iLinenum, iGtin, iQnty * 2 ,isite ).
    end.
    else do:
       create utd-marking-lines.
       assign
          utd-marking-lines.mark      = vnewMark
          utd-marking-lines.db-num    = idb-num
          utd-marking-lines.doc-id    = idoc-id
          utd-marking-lines.Linenum   = iLinenum
          utd-marking-lines.site      = isite
          utd-marking-lines.doc-level = 1
          utd-marking-lines.gds-code  = ?
       .
       vQnty = iQnty.
    end.
    return vQnty.
 end.
function addMarkforUtd returns recid
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iMark as character  ,
 isite   as character,
 iUtdType as character    ):
    define buffer     marking            for ub.marking.
    define buffer     marking-attr       for ub.marking-attr.
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define variable vMRC  as decimal no-undo.
    define variable vQnty as decimal no-undo.
   define variable vRec as recid no-undo.
   if     imark ne "-"
      and imark ne ""
      and imark ne ?
   then do:
      imark = repTegforDm(imark).
      vQnty = getQntyUTDByCodId(imark) .
      find first utd-marking-lines where utd-marking-lines.mark       = imark
                                     and utd-marking-lines.db-num     = idb-num
                                     and utd-marking-lines.doc-id     = idoc-id
                                     and utd-marking-lines.Linenum    = iLinenum
      exclusive-lock no-error.
      if not available utd-marking-lines
      then do:
         create utd-marking-lines.
         assign
            utd-marking-lines.mark      = imark
            utd-marking-lines.db-num    = idb-num
            utd-marking-lines.doc-id    = idoc-id
            utd-marking-lines.Linenum   = iLinenum
            utd-marking-lines.site      = isite
            utd-marking-lines.doc-level = 1
            utd-marking-lines.gds-code  = ?
         .
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.mark      = imark
            utd-marking-lines-attr.db-num    = idb-num
            utd-marking-lines-attr.doc-id    = idoc-id
            utd-marking-lines-attr.Linenum   = iLinenum
            utd-marking-lines-attr.attr-code = "box-qnty"
            utd-marking-lines-attr.attr-value = string(vQnty)
         .
         vRec = recid(utd-marking-lines).
         release utd-marking-lines-attr.
         release utd-marking-lines.
      end.
      else do:
         if    (    isite eq "-"
            and utd-marking-lines.site eq "+")
         or (    isite eq "+"
            and utd-marking-lines.site eq "-")
         then
            delete utd-marking-lines.
         else if isOAD (imark)
         then do:
            vQnty = AddOADLine(idb-num, idoc-id, iLinenum, GetTegCod(imark,"02"), int(vQnty) ,isite ).
            create utd-marking-lines-attr.
            assign
               utd-marking-lines-attr.mark      = imark
               utd-marking-lines-attr.db-num    = idb-num
               utd-marking-lines-attr.doc-id    = idoc-id
               utd-marking-lines-attr.Linenum   = iLinenum
               utd-marking-lines-attr.attr-code = "box-qnty"
               utd-marking-lines-attr.attr-value = string(vQnty)
            .
         end.
         vRec = recid(utd-marking-lines).
         release utd-marking-lines.
      end.
      if isMark (imark)
      then do:
         find first marking where marking.mark eq iMark exclusive-lock no-error.
         if not available marking
         then do:
            create marking.
            marking.mark = iMark.
            marking.gds-code = ?.
            marking.unit     = getLevelUTDByCodId(marking.mark) .
         end.
         assign
           marking.unit-ext   = if marking.unit-ext = "" or marking.unit-ext = ? then
                                   getLevelMotpByCodId(marking.mark)
                                else marking.unit-ext
           marking.box-qnty   = vQnty
           marking.unit       = if marking.unit-ext = "LEVEL2" then "КИТУ" else getLevelUTDByCodId(marking.mark)
         .
         if        (     iUtdType eq "UniversalTransferDocument"
                  and marking.sts = objSrv:Env:marking:Sts:Mark:NotAvailable:KeyIntDB)
         then
            marking.sts = ?.
      end.
   end.
   return vRec.
end.
function isSaleMarkInUpak returns logical
(iMark    as char ):
   define buffer buf_marking       for ub.marking.
   for each buf_marking no-lock where
            buf_marking.mark-parent = iMark
   :
     if can-do(objSrv:Env:marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or
        can-do(objSrv:Env:marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) then
       return true.
     if isSaleMarkInUpak(buf_marking.mark) then
       return true.
   end.
   return false.
 end.
function setStatusUpak returns logical
(iDbNum   as integer ,
 iDocId   as integer ,
 iLineNum as integer ,
 iMark    as char ,
 iSts     as integer):
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_marking           for ub.marking.
   for each buf_marking exclusive-lock where
            buf_marking.mark-parent = iMark,
      first buf_utd-marking-lines exclusive-lock where
            buf_utd-marking-lines.doc-id  = iDocId
        and buf_utd-marking-lines.db-num  = iDbNum
        and buf_utd-marking-lines.lineNum = iLineNum
        and buf_utd-marking-lines.mark = buf_marking.mark
   :
     setStatusUpak(iDbNum, iDocId, iLineNum, buf_marking.mark, iSts).
   end.
   for first buf_utd-marking-lines exclusive-lock where
             buf_utd-marking-lines.doc-id  = iDocId
         and buf_utd-marking-lines.db-num  = iDbNum
         and buf_utd-marking-lines.lineNum = iLineNum
         and buf_utd-marking-lines.mark = iMark,
       first buf_marking exclusive-lock where
             buf_marking.mark = buf_utd-marking-lines.mark
   :
     if  buf_marking.sts <> objSrv:Env:marking:Sts:Mark:MarkError:KeyIntDB
     then do:
       assign
         buf_utd-marking-lines.sts = iSts
         buf_marking.sts           = iSts
       .
     end.
   end.
   return true.
end.
define temp-table tt-recid no-undo
          field orgid as char
          field docid as char
          field parent as char
          field stamp as datetime
          index pi orgid docid
          index parent parent  stamp.
function ProcessSystemMessStart return component-handle
(IStartStop as logical):
   if mDiadocConnection eq ? then
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vReceiptGenerationProcess as component-handle no-undo.
   define variable vi as integer no-undo.
   if mDiadocConnection ne ?
   then do:
      vOrganizationList = mDiadocConnection:GetOrganizationList().
       do vi = 1 to vOrganizationList:count:
          vOrganization = vOrganizationList:GetItem(vi - 1 ).
          vReceiptGenerationProcess = vOrganization:GetReceiptGenerationProcess().
          release object vOrganization.
          if IStartStop
          then
             vReceiptGenerationProcess:Start().
          else
             vReceiptGenerationProcess:Stop().
          release object vReceiptGenerationProcess.
       end.
       release object vOrganizationList.
   end.
end.
procedure  changeIdToGuid :
define input  parameter iOrganization as component-handle no-undo.
   define variable vOrgId   as character no-undo.
   define variable vOrgGuid as character no-undo.
   define buffer utd for utd.
   assign
      vOrgId   = iOrganization:id.
      vOrgGuid = iOrganization:guid
   no-error.
   if     error-status:num-messages eq 0
      and vOrgId   ne ""
      and vOrgGuid ne ""
   then do:
      define variable vfirst as logical no-undo init yes.
      repeat preselect each utd where utd.OrganizationExt = vOrgId exclusive-lock:
         find next utd.
         if vfirst
         then do:
            PutMes("Конвертация документов").
            vfirst = no.
         end.
         utd.OrganizationExt = vOrgGuid.
         validate utd.
         PutMes(substitute ("У документа &1 изменен индификатор организации с &2 на &3",ub.utd.DocumentNumber,vOrgId,utd.OrganizationExt)).
      end.
      if not vfirst
      then
         PutMes("Конвертация документов завершина.").
   end.
end.
procedure getNewUpd :
   define variable VLastDate as date no-undo init ?.
   define variable vDocument     as component-handle no-undo.
   define variable vYear         as integer no-undo.
   define variable vMonth        as integer no-undo.
   define variable vDay          as integer no-undo.
   define variable vBegLoadDate  as date    no-undo.
   define variable vLastLoadDate as date    no-undo.
   define buffer utd for utd.
   VLastDate = date( getextAttr('diadoc-lastload':U)) no-error.
   find first sys-ctrl no-lock.
   if VLastDate eq ?
   then
      VLastDate = sys-ctrl.cut-date + 3.
   else if sys-ctrl.cut-date ne ?
   then
      VLastDate = max(VLastDate,sys-ctrl.cut-date + 3) .
   vLastLoadDate = VLastDate.
   for each tt-recid:
      delete tt-recid.
   end.
   if chekStop() then return "Остановка пользователем".
    run  UpdateUTDInform(if VLastDate eq ? then today - 365 else VLastDate - 3,today + 1,output VLastDate).
   if chekStop() then return "Остановка пользователем".
   if VLastDate ne ?
   then do:
      setextAttr('diadoc-lastload':U,string(VLastDate)).
      vYear = year(vLastLoadDate).
      vMonth = month(vLastLoadDate) - 2.
      vDay   = day(vLastLoadDate).
      if vMonth <= 0 then
         assign
            vMonth = vMonth + 12
            vYear  = vYear - 1
            .
      repeat:
         vBegLoadDate = date(vMonth, vDay, vYear) no-error.
         if error-status:error then
            vDay = vDay - 1.
         else
            leave.
      end.
      vBegLoadDate = vBegLoadDate + 1.
   end.
   block-rec:
   for each tt-recid break by tt-recid.parent descending by tt-recid.stamp descending :
      if  tt-recid.parent eq ""
      then next  block-rec.
      if first-of (tt-recid.parent)
      then do:
         for each utd where utd.PackageId eq tt-recid.parent
         no-lock break by utd.PackageId descending by utd.Timestamp descending :
            if chekStop() then return "Остановка пользователем".
            if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
            then do:
               subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               MySeqUtd = ?.
               CrEdoc(utd.PackageId,utd.Timestamp).
               unsubscribe "getNextseq".
               next block-rec.
            end.
         end.
      end.
   end.
   PutMes("Обновление информации по ранее загруженным документам за период c " + (if vBegLoadDate <> ? then
                                                                                     string(vBegLoadDate)
                                                                                  else "?")
                                                                                  + " по " +
                                                                                  (if vLastLoadDate <> ? then
                                                                                      string(vLastLoadDate)
                                                                                   else
                                                                                      "?")
                                                                                   ).
   define variable vobj as character no-undo.
   vobj = getExtAttr('host-code':U).
   if vobj ne "0"
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                      and utd.host-code eq int(vobj)
                      and (   utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                           or utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB
                           )
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq ""
          then do:
              run  UpdateUTDInformOne(vDocument).
             release object vDocument no-error.
          end.
       end.
   vobj = getExtAttr('obj':U).
   if vobj ne ""
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                      and utd.obj-type + string(utd.obj-code) eq vobj
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq ""
          then do:
              run  UpdateUTDInformOne(vDocument).
             release object vDocument no-error.
          end.
       end.
end.
procedure  SendAuto:
 define variable vOrganization as component-handle no-undo.
 define variable vOrganizationList as component-handle no-undo.
 define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then do:
      message "По данному сертификату не удалось подключиться к Диадок"
      view-as alert-box.
   end.
   else do:
      for each tt-recid:
         delete tt-recid.
      end.
      vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
      if vOrganizationList eq ? then return error ?.
      vi = vOrganizationList:Count()no-error.
      if vi eq ?
      then
         return error ?.
      do vi = 1 to vOrganizationList:Count() :
         vOrganization = vOrganizationList:GetItem(vi - 1 ).
         define variable vorgid as character no-undo.
         vorgid = vOrganization:guid.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
             run  SendReceiptsAsync(utd.db-num,utd.doc-id).
         end.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
             run  updOneUTD(utd.db-num,utd.doc-id).
         end.
      end.
   end.
end.
procedure SendAccept:
   define input  parameter iTypeAccept     as character no-undo.
   define input  parameter iReplyTask      as component-handle no-undo.
   define input  parameter iOrganizationGuid as character no-undo.
   define input  parameter iWorkflowId     as integer no-undo.
   define input  parameter iTitleTypes    as character  no-undo.
   define output parameter oOperationCode as character no-undo.
   define variable vContentItems as component-handle no-undo.
   define variable vContentItem  as component-handle no-undo.
   define variable vSigner       as component-handle no-undo.
   define variable vBuyerTitle   as component-handle no-undo.
   define variable vEmployee     as component-handle no-undo.
   define variable vContentOperCode as component-handle no-undo.
   define variable vOrganization   as component-handle no-undo.
   define variable vUserperm   as component-handle no-undo.
   define variable vi as integer no-undo.
  define variable vdate as date no-undo.
  define variable vDocumentCreator as character no-undo.
  define variable vDocumentCreatorBase as character no-undo.
  define variable vOperationCode as character no-undo.
  define variable vOperationContenttext as character no-undo.
  define variable vOperationContent as character no-undo.
  define variable vThumbprint as character no-undo.
  define variable vJobTitle   as character no-undo.
  vThumbprint = mDiadocConnection:Certificate:Thumbprint.
  vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
  if vOrganization eq ?
  then do:
     run str\utdacp.w (output vdate, output  vDocumentCreator, output vDocumentCreatorBase, output vOperationCode, output vOperationContent) no-error.
     if vdate eq ?
     then
        return error "".
  end.
  else do:
     define variable vTitleType as character no-undo.
     define variable vSignSet   as component-handle no-undo.
     define variable vSeller as logical no-undo.
     vUserperm = vOrganization:GetUserPermissions().
     vJobTitle = vUserperm:JobTitle.
     release object vUserperm.
     blk-tit:
     do vi = 1 to num-entries(iTitleTypes):
        vTitleType = entry(vi,iTitleTypes).
        vSeller = index(vTitleType,"Seller") > 0.
        if vSeller
        then
           next blk-tit.
        vSignSet = vOrganization:GetExtendedSignerDetails2(vThumbprint, vTitleType) no-error.
        if error-status:num-messages > 0
        then do:
           define variable vTasksetSign   as component-handle no-undo.
           define variable vTasksetSignDetal   as component-handle no-undo.
           vTasksetSign = vOrganization:CreateSetExtendedSignerDetailsTask(VThumbprint).
           getdesc(vTasksetSign).
           vTasksetSign:DocumentTitleType = vTitleType.
           getdesc(vTasksetSign).
           vTasksetSignDetal = vTasksetSign:ExtendedSignerDetailsToPost.
           getdesc(vTasksetSignDetal).
           vTasksetSignDetal:JobTitle  = vJobTitle    .
           vTasksetSignDetal:SignerType = "LegalEntity" .
           vTasksetSignDetal:SignerInfo = "".
           vTasksetSignDetal:Powers = if VSeller then "InvoiceSigner"  else "PersonDocumentedOperation".
           vTasksetSignDetal:Status = if VSeller then "SellerEmployee" else "BuyerEmployee".
           vTasksetSignDetal:PowersBase = "Должностные обязанности".
           getdesc(vTasksetSignDetal).
           release object vTasksetSignDetal.
           vTasksetSign:send() no-error.
           if error-status:num-messages > 0 then do:
              PutErr(substitute("Error Ошибка при установке подписанта по документу &1 ", vTitleType )).
           end.
           release object vTasksetSign.
        end.
        else do:
           getdesc(vSignSet).
           release object vSignSet.
        end.
     end.
     vOperationContent = if iTypeAccept eq "AcceptDocumentWithDisc"
                         then "2"
                         else if iTypeAccept eq "AcceptDocumentNotAccepted"
                         then "3"
                         else "1".
     vdate = today.
     vDocumentCreator = substitute("&1, ИНН~/КПП &2~/&3", vOrganization:name , vOrganization:inn , vOrganization:kpp).
     release object vOrganization.
  end.
  if    vJobTitle eq ?
     or vJobTitle eq ""
  then
     vJobTitle = mDiadocConnection:Certificate:JobTitle.
   if (   iWorkflowId = 3
      or iWorkflowId = 5
      or iWorkflowId = 8
      or iWorkflowId = 11
      or iWorkflowId = 12
      or iWorkflowId = 13
      or iWorkflowId = 16)
      and iReplyTask ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContentItem = vContentItems:GetItem(vi - 1 ):Content.
         getdesc(vContentItem).
         vBuyerTitle = vContentItem:UniversalTransferDocumentBuyerTitle no-error.
         getdesc(vBuyerTitle).
           if vBuyerTitle eq ?
         then do:
            vBuyerTitle = vContentItem:UniversalCorrectionDocumentBuyerTitle.
            getdesc(vBuyerTitle).
            vOperationContenttext = "C изменением стоимости согласен".
         end.
         else do:
            oOperationCode = vOperationContent.
   vOperationContenttext = if vOperationContent eq "1"
                       then "Принято без разногласий"
                       else if vOperationContent eq "2"
                       then "Принято с разногласиями"
                       else if vOperationContent eq "3"
                       then "Товары не приняты"
                       else vOperationContent.
            getdesc(vBuyerTitle).
            vEmployee = vBuyerTitle:Employee.
            getdesc(vEmployee).
            define variable vUser   as component-handle no-undo.
            vUser = mDiadocConnection:GetMyUser().
            getdesc(vUser).
            vEmployee:position        = vJobTitle    .
            vEmployee:FirstName       = vUser:FirstName  .
            vEmployee:LastName        = vUser:LastName   .
            vEmployee:MiddleName      = vUser:MiddleName .
            vEmployee:EmployeeBase     = "Должностные обязанности".
            release object vUser.
            getdesc(vEmployee).
            getdesc(mDiadocConnection:Certificate).
            getdesc(vContentItem:UniversalTransferDocumentBuyerTitle).
            getdesc(vBuyerTitle:ContentOperCode).
            vContentOperCode = vBuyerTitle:ContentOperCode.
            vContentOperCode:TotalCode = vOperationContent.
            vBuyerTitle:OperationCode   = oOperationCode.
            release object vContentOperCode.
            release object vEmployee.
         end.
         vBuyerTitle:DocumentCreator = vDocumentCreator .
         vBuyerTitle:DocumentCreatorBase     = vDocumentCreatorBase.
         vBuyerTitle:OperationContent =  vOperationContenttext.
         vBuyerTitle:AcceptanceDate   = vdate.
         getdesc(vBuyerTitle).
         getdesc(vBuyerTitle:Signers).
         vSigner = vBuyerTitle:Signers:additems().
         getdesc(vSigner).
         getdesc(vSigner:SignerReference).
         getdesc(vSigner:SignerDetails).
         vSigner:SignerReference:CertificateThumbprint = mDiadocConnection:Certificate:Thumbprint.
         vSigner:SignerReference:boxid = iOrganizationGuid.
         getdesc(vSigner:SignerReference).
         release object vBuyerTitle no-error.
         release object vContentItem.
      end.
      release object vContentItems.
   end.
end.
function SendAnswer returns character
(iReplyTask as component-handle,iorg as char,iTypeAnswer as character,imes as longchar ):
   define variable vContent       as component-handle no-undo.
   define variable vContentItems  as component-handle no-undo.
   define variable vSigner        as component-handle no-undo.
   define variable vSignTask      as component-handle no-undo.
   define variable vOrganization  as component-handle no-undo.
   define variable vUserperm      as component-handle no-undo.
   define variable vUser          as component-handle no-undo.
   define variable vi as integer no-undo.
   if     itypeAnswer ne "AcceptRevocation"
      and iReplyTask  ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContent = vContentItems:GetItem(vi - 1 ):Content.
         vContent:comment =  imes.
        getdesc(vContent).
         vSigner = vContent:Signer.
         getdesc(vSigner).
         vOrganization = mDiadocConnection:GetOrganizationById(iOrg) no-error.
         vUserperm = vOrganization:GetUserPermissions().
         define variable vJobTitle as character no-undo.
         vJobTitle = vUserperm:JobTitle.
         if    vJobTitle eq ?
            or vJobTitle eq ""
         then
            vJobTitle = mDiadocConnection:Certificate:JobTitle.
         release object vUserperm.
         release object vOrganization.
         vUser = mDiadocConnection:GetMyUser().
         getdesc(vUser).
         vSigner:Surname    = vUser:FirstName.
         vSigner:FirstName  = vUser:LastName.
         vSigner:Patronymic = vUser:MiddleName.
         vSigner:JobTitle   = vJobTitle.
         vSigner:Inn        = mDiadocConnection:Certificate:inn.
         getdesc(vSigner).
         release object vUser.
         release object vSigner.
         release object vContent.
      end.
      release object vContentItems.
   end.
end.
procedure send:
   define input  parameter iDocument as component-handle no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter icomment as character no-undo.
   define output parameter oOperationCode as character no-undo.
   define variable vReplyTask    as component-handle no-undo.
   define variable vTypeAnswer as character no-undo.
   define variable vTypeAnswer_orig as character no-undo.
   define variable Vmes as longchar  no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentid as character no-undo.
   define variable vi as integer no-undo.
   if iDocument ne ?
   then do:
      case iTypeAnswer:
         when "Подписания"                 then vTypeAnswer =  "AcceptDocument".
         when "отказ подписи"              then vTypeAnswer =  "RejectDocument".
         when "запрос коректировки"        then vTypeAnswer =  "CorrectionRequest".
         when "Запрос анулирование"        then vTypeAnswer =  "RevocationRequest".
         when "Подтверждение анулирования" then vTypeAnswer =  "AcceptRevocation".
         when "отказ анулирования"         then vTypeAnswer =  "RejectRevocation".
         when "подписать с расхождениями"  then vTypeAnswer =  "AcceptDocumentWithDisc".
         when "подписать товар не принят"  then vTypeAnswer =  "AcceptDocumentNotAccepted".
         otherwise vTypeAnswer = iTypeAnswer .
      end case.
      vTypeAnswer_orig = vTypeAnswer.
      if    vTypeAnswer =  "AcceptDocumentWithDisc"
         or vTypeAnswer =  "AcceptDocumentNotAccepted"
      then
         vTypeAnswer =  "AcceptDocument".
      if mDiadocConnection:AuthenticateType ne "Certificate" then return error "не сертификат".
      vReplyTask = iDocument:CreateReplySendTask2(vTypeAnswer).
      vOrganizationGuid = iDocument:OrganizationGuid.
      vDocumentid     = iDocument:DocumentId.
      getdesc(iDocument).
      if vTypeAnswer =  "AcceptDocument"
      then do:
         define variable vtitletype as character no-undo.
         vTitleType = GetDocTitleType(vOrganizationGuid,iDocument:TypeNamedId,iDocument:DocumentFunction,iDocument:Version).
         run sendAccept in this-procedure (vTypeAnswer_orig,
                                           vReplyTask,
                                           iDocument:OrganizationGuid,
                                           iDocument:WorkflowId,
                                           vtitletype,
                                           output oOperationCode ) no-error.
         if error-status:error
         then
            return error "".
      end.
      else do:
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error.
         if available utd
         then do:
            if   vTypeAnswer ne  "CorrectionRequest"
                and vTypeAnswer ne  "RejectDocument"
            then
               icomment = "".
            if vTypeAnswer eq  "RejectDocument"
            then do:
               if icomment eq ? or icomment eq "" then icomment = utd.comment.
               Vmes = (if icomment ne ? and icomment ne "" then icomment + "," else "" ) + GetErrForUtdStr(utd.db-num,utd.doc-id,?).
            end.
            else do:
                Vmes = GetErrForUtd(utd.db-num,utd.doc-id,?) .
                Vmes = GetErrComText(icomment,Vmes).
            end.
            if mFlaftest
            then do:
               output stream File-stream to "SendAnswer.txt" .
               put stream File-stream unformatted string(Vmes).
               output stream File-stream close.
               message "сформирован файл " search("SendAnswer.txt")
               view-as alert-box.
               return error "ничего не отправляем".
            end.
            else
               SendAnswer(vReplyTask,iDocument:OrganizationGuid, iTypeAnswer,Vmes) no-error.
            if error-status:error
            then
               return error "".
            end.
         end.
      if not mFlaftest
      then do:
         getdesc(vReplyTask).
          vReplyTask:Send() no-error.
         if error-status:num-messages > 0 then do:
            Puterr(substitute("Error Ошибка при выполнение действия по документу &1. ", vDocumentid )).
            release object vReplyTask.
            return error "Ошибка при выполнение дейстия с документом".
         end.
      end.
   end.
end.
procedure SendReceiptsAsync :
define input  parameter idb-num as integer no-undo.
define input  parameter idoc-id as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка подписи ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      define variable vAsyncResult   as component-handle no-undo.
      vAsyncResult = vDocument:SendReceiptsAsync().
      release object vDocument.
      PutMes(substitute("Запущена асинхронная обработка ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      find first utd where utd.db-num eq idb-num
                       and utd.doc-id eq idoc-id
      exclusive-lock no-error.
      if available utd
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq ""
         then do:
             run  UpdateUTDInformOne(vDocument).
            release object vDocument.
         end.
         utd.flagRI = yes.
    end.
      PutMes(vAsyncResult:Result).
      release object vAsyncResult.
      if getdocum (idb-num, idoc-id, output vDocument) eq ""
      then do:
          run  UpdateUTDInformOne(vDocument).
         release object vDocument.
      end.
   end.
end.
procedure SendAnsver:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter iComment as character no-undo.
   define variable vSendcode as character no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2",idb-num,idoc-id,iTypeAnswer)).
       run   SendReceiptsAsync(idb-num,idoc-id).
         find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
               no-lock.
      if      (not utd.AmendmentRequested
          and  iTypeAnswer eq "CorrectionRequest")
          or iTypeAnswer ne "CorrectionRequest"
      then do:
          run   send in this-procedure (vDocument,iTypeAnswer,iComment,output vSendcode) no-error.
         if error-status:error
         then do:
            release object vDocument.
            return error return-value.
         end.
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 Завершина",idb-num,idoc-id,iTypeAnswer)).
      end.
      else
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 пропущена",idb-num,idoc-id,iTypeAnswer)).
      release object vDocument.
      if     vSendcode ne ?
         and vSendcode ne ""
      then
         setattrutd (idb-num,idoc-id,"sendcode",vSendcode).
      if not mFlaftest
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq ""
         then do:
             run   UpdateUTDInformOne(vDocument).
            release object vDocument.
         end.
         if    iTypeAnswer eq "CorrectionRequest"
            or iTypeAnswer eq "AcceptRevocation"
            or iTypeAnswer eq "RejectRevocation"
            or iTypeAnswer eq "RejectDocument"
            or iTypeAnswer eq "AcceptDocument"
            or iTypeAnswer eq "AcceptDocumentWithDisc"
            or iTypeAnswer eq "AcceptDocumentNotAccepted"
         then do:
            if getdocum (idb-num, idoc-id, output vDocument) eq ""
            then do:
                run  UpdateUTDInformOne(vDocument).
               release object vDocument.
            end.
            if   not mFlaftest
            then do trans:
               find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
                                and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
               exclusive-lock no-error.
               if available utd
               then do :
                  case iTypeAnswer:
                     when   "AcceptDocument"               then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "RejectDocument"               then utd.sts-edi = if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
                                                                              then ObjSrv:Env:Utd:Sts:edi:sendAutoRejected:KeyIntDB
                                                                              else ObjSrv:Env:Utd:Sts:edi:sendRejected:KeyIntDB.
                     when   "CorrectionRequest"            then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendAdjustment:KeyIntDB.
                     when   "AcceptRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "RejectRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "AcceptDocumentWithDisc"       then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "AcceptDocumentNotAccepted"    then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                  end case.
                  if iTypeAnswer eq "CorrectionRequest"
                  then do:
                     utd.sts = ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB.
                     if     utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                     then do:
                         run   SendAnsver(idb-num,idoc-id,"AcceptDocumentWithDisc",iComment).
                     end.
                  end.
               end.
            end.
         end.
      end.
   end.
end.
procedure  SendResponse :
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iAccept as logical no-undo.
   define input  parameter itestMod as logical no-undo.
    define buffer utd for utd.
    define buffer buf_utd for utd.
    itestMod = not itestMod.
    define variable vreturn as logical no-undo.
    find first utd where utd.db-num eq idb-num
                     and utd.doc-id eq idoc-id
    no-lock no-error.
    if available utd
    then do:
       if utd.EDocType              = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB
       then do:
          if     iAccept
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientSignature:KeyIntDB
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientPartiallySignature:KeyIntDB
          then do:
             vreturn = yes.
             if itestMod
             then do:
                for each buf_utd where buf_utd.PackageId eq utd.PackageId
                                   and buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                                   and buf_utd.Timestamp <= utd.Timestamp
                                   and (     buf_utd.sts-edi   eq objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
                no-lock :
                    run  SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"AcceptDocument","")no-error.
                   if error-status:error then return error return-value.
                end.
             end.
          end.
       end.
       else if utd.EDocType              = objSrv:Env:Utd:EDocType:returns:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                define variable vsend as logical no-undo.
                vsend = logical(getattrutdex (idb-num,idoc-id,"returnSend","no")).
                if vsend
                then
                   return error "Документ был отправлен рание. Повторная отправка возможна через сервис.".
                find first buf_utd where buf_utd.OrganizationExt eq utd.parentOrganizationExt
                                     and buf_utd.DocumentExt     eq utd.parentDocumentExt
                no-lock no-error.
                if available buf_utd
                then do:
                   if getattrutd (idb-num,idoc-id,"TypeUTD") ne "счфДОП"
                   then do:
                       run  SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"CorrectionRequest",GetErrForUtd(utd.db-num,utd.doc-id,"return"))no-error.
                      if error-status:error then return error return-value.
                   end.
                end.
                run bge/sendutd.p(
                     parparentproc,
                     mDiadocConnection:Certificate:Thumbprint,
                     idb-num,
                     idoc-id) no-error.
                if error-status:error then return error return-value.
                do trans :
                   find first utd where utd.db-num eq idb-num
                                    and utd.doc-id eq idoc-id
                   exclusive-lock no-error.
                   utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB.
                   setattrutd (idb-num,idoc-id,"returnSend","yes").
                end.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then
                 run  SendReceiptsAsync(idb-num,idoc-id).
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB
       then do:
          if not iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:RequestsMyRevocation:KeyIntDB
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptRevocation","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectRevocation","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if   utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Changed:KeyIntDB
              or utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocument","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureAdjustment:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"CorrectionRequest","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureNotAccepted:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocumentNotAccepted","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       if itestmod and not vreturn
       then do:
          PutMes (substitute('Error Документ с № "&5" в.н. "&2" по БД "&1" в статусе "&3" выполнить операцию "&4" не возможно.',
                             utd.db-num,
                             utd.doc-id,
                             ObjSrv:Env:Utd:Sts:EDI:GetLabel(utd.sts-edi),
                             if iAccept then "Подписать" else "Отказать",
                             utd.DocumentNumber)
                             ).
       end.
    end.
    return string(vreturn).
end.
define temp-table tt-pack no-undo
          field orgid as char
          field docid as char
          field packid as char
          field stamp as datetime
          index pi packid   stamp   orgid  docid
          .
function CheckLoad returns logical
(iDocument as component-handle,
 output ohost-code as integer ,
 output oObj-type  as character  ,
 output oObj-code  as integer ):
   define variable vFlag as logical no-undo.
   define variable vDocumentChild as component-handle no-undo.
   define variable vContent as component-handle no-undo.
   define variable vConsignees as component-handle no-undo.
   define variable vfilename as character no-undo.
   oObj-type  = ?.
   oObj-code  = ?.
   ohost-code = ?.
   define buffer ext-classif   for ext-classif.
   define buffer clients       for clients.
   define buffer buf_clients   for clients.
   define buffer clients-attr  for clients-attr.
   if   iDocument:type eq "UniversalTransferDocument"
     or iDocument:type eq "UniversalTransferDocumentRevision"
   then main-block :
   do on error undo main-block, return error:
      getdesc(iDocument).
      vfilename = iDocument:filename.
      if iDocument:Direction eq "Inbound"
      then do:
         define variable vOrganizationGuid as character no-undo.
         define variable vDocumentid as character no-undo.
         vOrganizationGuid = iDocument:OrganizationGuid.
         vDocumentid     = iDocument:DocumentId.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error .
         if available utd
         then do:
            assign
               Oobj-type = utd.obj-type
               Oobj-code = utd.obj-code
               ohost-code = utd.host-code.
            .
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller") no-error.
         getdesc(vDocumentChild).
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and ohost-code ne 0 and ohost-code ne ?)
         then vFlag = no.
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and (ohost-code eq 0 and ohost-code eq ?))
         then do:
             find first clients  where clients.obj-type   = Oobj-type
                                   and clients.obj-code   = Oobj-code
             no-lock no-error .
             if available clients
             then
                ohost-code =  clients.host-code.
             vFlag = no.
         end.
         else if vDocumentChild ne ?
         then do:
            if iDocument:version  eq "utd820_05_01_01"
            then do:
               vContent = vDocumentChild:UniversalTransferDocument no-error.
            end.
            else
               vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error.
            release object vDocumentChild.
            if vContent ne ?
            then do:
               getdesc(vContent).
               define variable vFnsParticipantId as character no-undo.
               define variable vinn as character no-undo.
               define variable vkpp as character no-undo.
               define variable vorgname as character no-undo.
               define variable vAddrOrg as character no-undo.
               define variable vAdditionalInfo as character no-undo.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Sellers).
                  getdesc(vContent:Sellers:Seller).
                  getdesc(vContent:Sellers:Seller:GetItem(0)).
                  getdesc(vContent:Sellers:Seller:GetItem(0):OrganizationDetails).
                  getOrganizationInfo(vContent:Sellers:Seller:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
               end.
               else do:
                  vFnsParticipantId =  vContent:SenderFnsParticipantId.
               end.
               find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                        and ext-classif.charkey_three eq vFnsParticipantId
               no-lock no-error.
               if available ext-classif
               then do:
                  find first clients
                    where clients.obj-type   = ext-classif.CharKey_One
                      and clients.obj-code   = ext-classif.Key#_One
                      and not can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
                  no-lock no-error .
                  if not available clients
                  then do:
                     PutMes(substitute("По &1 отправитель &2 наша фирма." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                     return no.
                  end.
               end.
               else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
               end.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Buyers).
                  getdesc(vContent:Buyers:Buyer).
                  getdesc(vContent:Buyers:Buyer:GetItem(0)).
                  getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo,output vAddrOrg).
               end.
               else do:
                  vConsignees = vContent:Consignees.
                  getdesc(vConsignees).
                  getdesc(vConsignees:Consignee).
                  if vConsignees:Consignee:count > 0
                  then do:
                     getdesc(vConsignees:Consignee:GetItem(0)).
                     getOrganizationInfo(vConsignees:Consignee:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  release object vConsignees.
                  vFnsParticipantId = vContent:RecipientFnsParticipantId.
               end.
               release object vContent.
               define variable otext as character no-undo.
               vFlag = getObgFns
                          (input iDocument:DocumentNumber ,
                           input vFnsParticipantId ,
                           input vkpp,
                           output ohost-code,
                           output oobj-type,
                           output oobj-code,
                           output otext ).
               if otext ne "" and otext ne ?
               then
                  PutMes( otext).
               if vFlag  eq no
               then
                  return vFlag .
            end.
            else do:
               PutMes("Error Ошибка получения данных из Диадок UniversalTransferDocument" + if iDocument:version  eq "utd820_05_01_01" then "" else "WithHyphens").
               return no.
            end.
         end.
         else do:
            PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
            return no.
         end.
      end.
      else
         return yes.
      if ohost-code eq ? or ohost-code eq 0
      then do:
         PutMes(substitute("По &1 не удалось определить фирму по получателю  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
         return no.
      end.
   end.
   else do:
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vpack as character no-undo init ?.
      define variable vcli-type as character no-undo.
      define variable vcli-code as integer no-undo.
      define variable vfns as character no-undo.
      define variable vchar as character no-undo.
      vDocumentChild = iDocument:GetDynamicContent("Seller")no-error.
      if vDocumentChild eq ?
      then do:
         PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
         return no.
      end.
      vContent = vDocumentChild:UniversalCorrectionDocument no-error.
      if vContent ne ?
      then do:
         getOrganizationInfo(vContent:Seller,output vchar,output vchar,vFns, output vchar,  output vchar, output vchar).
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq vFns
         no-lock no-error.
         if available ext-classif
         then do:
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            GetprevUTDForPac(vpack,iDocument:Timestamp,output vdb-num,output vdoc-id ).
            release object vContent.
         end.
         else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
               end.
      end.
      else do:
         PutErr("Error Ошибка получения данных из Диадок Seller").
         return no.
      end.
      release object vDocumentChild.
      define buffer     utd for utd.
      find first utd where utd.db-num eq vdb-num
                       and utd.doc-id eq vdoc-id
      no-lock no-error.
      if available utd
      then do:
         assign
            oobj-type  = utd.obj-type
            oobj-code  = utd.obj-code
            ohost-code = utd.host-code
            vfilename  = getattrutd (utd.db-num,utd.doc-id,"FileName")
         .
      end.
      else do:
         PutMes(substitute("Не найден оригенальный документ по пакету &1.",vpack)).
         return no.
      end.
   end.
   if  yes
   then do:
      define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(oobj-type, oobj-code).
      if     not EDOParSec:IsEdo
         and vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else if     not EDOParSec:IsEdoNotmark
              and not vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для не маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else
         vFlag = yes.
   end.
   return vFlag.
end.
procedure  UpdateUTDInformOne :
   define input  parameter iDocument as component-handle no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentId as character no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable vtext as longchar no-undo.
   define buffer utd           for ub.utd.
   define buffer old_utd           for ub.utd.
   define buffer utd-lines      for ub.utd-lines.
   define buffer marking       for ub.marking.
   define buffer marking-lines for ub.marking-lines.
   define buffer utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define variable vDocumentChild               as component-handle no-undo.
   define variable vContent                     as component-handle no-undo.
   define variable vValues                      as component-handle no-undo.
   define variable vSellers                     as component-handle no-undo.
   define variable vConsignees                  as component-handle no-undo.
   define variable vInvoiceTable                as component-handle no-undo.
   define variable vItems                       as component-handle no-undo.
   define variable vExtendedInvoiceItem         as component-handle no-undo.
   define variable vItemIdentificationNumber    as component-handle no-undo.
   define variable vTransferBaseCol             as component-handle no-undo.
   define variable vTransferBase                as component-handle no-undo.
   define variable vorgname as character no-undo.
   define variable vAddrOrg as character no-undo.
   define variable vAdditionalInfo as character no-undo.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vunits  as component-handle no-undo.
   define variable vunit   as component-handle no-undo.
   define variable VValue  as character        no-undo.
   define variable vsite   as character        no-undo.
   define variable vNewUtd as logical          no-undo.
   if iDocument eq ?
   then
     return.
   vOrganizationGuid = iDocument:OrganizationGuid.
   vDocumentid     = iDocument:DocumentId.
   find first utd where utd.DocumentExt     = vDocumentid
                    and utd.OrganizationExt = vOrganizationGuid
   no-lock no-error .
   find first tt-recid where tt-recid.orgid eq vOrganizationGuid
                         and tt-recid.docid eq vDocumentid
   no-lock no-error.
   if not available tt-recid
   then do trans:
      if iDocument  ne ?
         and (
                  iDocument:type eq "UniversalTransferDocument"
               or iDocument:type eq "UniversalTransferDocumentRevision"
               or iDocument:type eq "UniversalCorrectionDocument"
              )
      then do:
         PutMes(substitute("Загрузка документа  &1 от &2." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         define variable vhost-code as integer   no-undo.
         define variable vobj-type  as character no-undo.
         define variable vobj-code  as integer   no-undo.
         if not CheckLoad(iDocument,output vhost-code,output vobj-type,output  vobj-code )
         then do:
            PutMes(substitute("Документ &1 от &2 пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            create tt-recid.
            assign
               tt-recid.orgid = vOrganizationGuid
               tt-recid.docid = vDocumentid
            .
            return.
         end.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error  .
         if available utd
         then do:
            if     utd.sts-edi > ObjSrv:Env:Utd:Sts:edi:StatFinesh
               and iDocument:RevocationStatus ne "RequestsMyRevocation"
            then do:
               create tt-recid.
               assign
                  tt-recid.orgid = vOrganizationGuid.
                  tt-recid.docid = vDocumentid
               .
               PutMes(substitute("Документ &1 от &2 в конечном статусе. Документ пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            end.
            find current utd exclusive-lock no-error  no-wait  .
            if  not available  utd
            then do:
               PutMes(substitute("Документ &1 от &2 заблокирован и будет пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate )).
               return.
            end.
         end.
         subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
         MySeqUtd = ?.
         if     not available  utd
         then do:
            create utd.
            assign
               utd.DocumentExt      = vDocumentid
               utd.OrganizationExt  = vOrganizationGuid
               vNewUtd              = yes
            .
            validate utd.
         end.
         assign
            utd.host-code = vhost-code when vhost-code ne ? and vhost-code ne 0
            utd.obj-code  = vobj-code  when vobj-code  ne ? and vobj-code  ne 0
            utd.obj-type  = vobj-type  when vobj-type  ne ? and vobj-type  ne ""
         .
         setattrutd (utd.db-num,utd.doc-id,"FileName",iDocument:FileName).
         utd.RevocationStatus = iDocument:RevocationStatus.
         utd.RecipientResponseStatus          = iDocument:RecipientResponseStatus.
         utd.TypeId           = iDocument:type.
         utd.CounteragentId   = iDocument:Counteragent:guid.
         utd.CustomDocumentId = iDocument:CustomDocumentId.
         utd.sts-edi = ?.
         utd.DocumentNumber = iDocument:DocumentNumber.
         utd.DocumentDate   = date(iDocument:DocumentDate).
         utd.Timestamp      = datetime(iDocument:Timestamp) .
         utd.ReceiptStatus  = iDocument:RecipientReceiptMetadata:ReceiptStatus.
         utd.Direction      = iDocument:Direction.
         utd.ModifyDate = today.
         utd.flagRI     =    utd.ReceiptStatus eq "GeneralReceiptStatusNotAcceptable" or utd.ReceiptStatus eq "Finished".
         utd.EDocType = if   iDocument:type eq "UniversalTransferDocument"
                          or iDocument:type eq "UniversalTransferDocumentRevision"
                        then objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                        else objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
         getdesc(iDocument).
         getdesc(iDocument:Counteragent).
         getdesc(iDocument:RecipientReceiptMetadata).
         getdesc(iDocument:ConfirmationMetadata).
         utd.AmendmentRequested = logical(iDocument:AmendmentRequested).
         if iDocument:type ne "UniversalTransferDocumentRevision"
         then do:
                utd.Revised = logical(iDocument:Revised).
                utd.Corrected = logical(iDocument:Corrected).
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller").
         getdesc(vDocumentChild).
         if   iDocument:type eq "UniversalTransferDocument"
           or iDocument:type eq "UniversalTransferDocumentRevision"
         then do:
            utd.Total = iDocument:total.
            utd.Vat = iDocument:Vat.
         end.
         else do:
            utd.Total = decimal (iDocument:TotalInc) - decimal (iDocument:TotalDec).
            utd.Vat = decimal (iDocument:VatInc) - decimal (iDocument:VatDec).
         end.
         find first utd-lines where utd-lines.db-num     = utd.db-num
                                and utd-lines.doc-id     = utd.doc-id
                                no-lock no-error.
         if     (   vNewUtd
                 or utd.Direction ne "Inbound"
                 or not available utd-lines)
            and vDocumentChild ne ?
         then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  vContent = vDocumentChild:UniversalTransferDocument no-error.
               end.
               else
                  vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  define variable vInfoCount as integer no-undo.
                  define variable vInfos as component-handle no-undo.
                  define variable vInfo as component-handle no-undo.
                  vInfos = vContent:AdditionalInfoId:AdditionalInfo.
                  do vInfoCount = 1 to vInfos:count:
                     vInfo = vInfos:getitem(vInfoCount - 1).
                     getdesc(vInfo).
                     setattrutd (utd.db-num,utd.doc-id,vInfo:id,vInfo:value).
                  end.
                  getdesc(vContent:TransferInfo).
                  getdesc(vContent:TransferInfo:TransferBases).
                  vTransferBasecol = vContent:TransferInfo:TransferBases:TransferBase.
                  getdesc(vTransferBasecol).
                  do vi = 1 to min(vTransferBasecol:count,1):
                     vTransferBase = vTransferBasecol:getitem(vi - 1).
                     getdesc(vTransferBase).
                     utd.BaseDocumentNumber = vTransferBase:BaseDocumentNumber.
                     utd.BaseDocumentName   = vTransferBase:BaseDocumentName.
                     utd.BaseDocumentDate   = date(vTransferBase:BaseDocumentDate).
                     release object vTransferBase.
                  end.
                  release object vTransferBasecol.
                  vSellers = vContent:Sellers.
                  getdesc(vSellers).
                  getdesc(vSellers:Seller:GetItem(0)).
                  if vSellers:Seller:count > 0
                  then
                     getOrganizationInfo(vSellers:Seller:GetItem(0),output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  release object vSellers.
                  if iDocument:version  ne "utd820_05_01_01"
                  then
                     utd.cli-FnsParticipantId = vContent:SenderFnsParticipantId.
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  if iDocument:version  eq "utd820_05_01_01"
                  then do:
                     getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  else do:
                     vConsignees = vContent:Consignees.
                     getdesc(vConsignees).
                     if vConsignees:Consignee:count > 0
                     then do:
                        getOrganizationInfo(vConsignees:Consignee:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                        setattrutd (utd.db-num,utd.doc-id,"Consignee_ИнфДляУчаст",vAdditionalInfo).
                     end.
                     utd.obj-FnsParticipantId = vContent:RecipientFnsParticipantId.
                     release object vConsignees.
                  end.
                  utd.obj-info = vorgname + " " + vAddrOrg + " ИНН: " + utd.obj-inn + " КПП: " + utd.obj-kpp.
                  vInvoiceTable = vContent:Table.
                  getdesc(vInvoiceTable).
                  vItems = vInvoiceTable:Item.
                  release object vInvoiceTable.
                  do vi = 1 to vItems:Count:
                     vExtendedInvoiceItem= vItems:GetItem(vi - 1).
                     getdesc(vExtendedInvoiceItem).
                     find first utd-lines where utd-lines.db-num     = utd.db-num
                                            and utd-lines.doc-id     = utd.doc-id
                                            and utd-lines.LineNum    = vi
                     exclusive-lock no-error.
                     if not available  utd-lines
                     then do:
                        create utd-lines.
                        assign
                           utd-lines.db-num   = utd.db-num
                           utd-lines.doc-id   = utd.doc-id
                           utd-lines.Linenum  = vi
                           utd-lines.gds-code = ?
                        .
                     end.
                     utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                     utd-lines.UnitCode    = vExtendedInvoiceItem:UnitnAME.
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vExtendedInvoiceItem:Quantity)).
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:unit)).
                     utd-lines.Price       = vExtendedInvoiceItem:Price.
                     utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded.
                     utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate,"/"),"%")).
                     utd-lines.Vat       = vExtendedInvoiceItem:Vat.
                     utd-lines.Total     = vExtendedInvoiceItem:Subtotal.
                     utd-lines.Article   = vExtendedInvoiceItem:ItemVendorCode.
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations).
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration).
                     if vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo).
                     if vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                     if vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:GETITEM(0) ).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber).
                     do vii = 1 to vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:COUNT:
                        vItemIdentificationNumber = vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:GETITEM(vii - 1).
                        getdesc(vItemIdentificationNumber).
                        getdesc(vItemIdentificationNumber:Unit).
                        if vItemIdentificationNumber:TransPackageId ne ? and vItemIdentificationNumber:TransPackageId ne ""
                        then do:
                           VValue = repTegforDm(vItemIdentificationNumber:TransPackageId).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        vunit = vItemIdentificationNumber:Unit.
                        do viii = 1 to vunit:count:
                           vValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        release object  vunit.
                        getdesc(vItemIdentificationNumber:PackageId).
                        vunit = vItemIdentificationNumber:PackageId.
                        do viii = 1 to vunit:count:
                           VValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        release object  vunit.
                        release object vItemIdentificationNumber.
                     end.
                     vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                     do vii = 1 to vunits:count:
                        vunit = vunits:GETITEM(vii - 1).
                        getdesc(vunit).
                        if     vunit:Id eq "штрихкод"
                            or vunit:Id eq "ean"
                        then do:
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                           find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                          and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                          and utd-marking-lines.Linenum    = utd-lines.Linenum
                           no-lock no-error.
                           if not available utd-marking-lines
                           then do:
                              vtext = vunit:Value.
                              do viii = 1 to num-entries(vtext," "):
                                 VValue = entry(viii,vtext," ").
                                 addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                              end.
                           end.
                        end.
                        if vunit:Id eq "Документ о соответствии" then do:
                          define variable v-sert-value as character no-undo .
                          find first utd-lines-attr exclusive-lock where utd-lines-attr.doc-id = utd-lines.doc-id and
                          utd-lines-attr.db-num = utd-lines.db-num and
                          utd-lines-attr.LineNum = utd-lines.LineNum and
                          utd-lines-attr.attr-code = "doc_sertif" no-error .
                          if available (utd-lines-attr) then utd-lines-attr.attr-value = utd-lines-attr.attr-value + "; " + vunit:value .
                          else setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"doc_sertif",vunit:value).
                        end.
                        release object  vunit.
                     end.
                     release object  vunits.
                     release utd-lines.
                     release object vExtendedInvoiceItem.
                  end.
                  release object vItems.
               end.
               else do:
                  PutMes("Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens".
               end.
            end.
            else do:
               vContent = vDocumentChild:UniversalCorrectionDocument.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  getdesc(vContent:Seller).
                  getdesc(vContent:EventContent).
                  getdesc(vContent:EventContent:CorrectionBase).
                  getOrganizationInfo(vContent:Seller,output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  do:
                      vInvoiceTable = vContent:Table.
                      getdesc(vInvoiceTable).
                      getdesc(vInvoiceTable:TotalsInc).
                      getdesc(vInvoiceTable:TotalsDec).
                      getdesc(vInvoiceTable:Items).
                      getdesc(vInvoiceTable:Items:item).
                      vItems = vInvoiceTable:Items:item.
                      release object vInvoiceTable.
                      do vi = 1 to vItems:Count:
                         vExtendedInvoiceItem = vItems:GetItem(vi - 1).
                         getdesc(vExtendedInvoiceItem).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo ).
                         find first utd-lines where utd-lines.db-num     = utd.db-num
                                                and utd-lines.doc-id     = utd.doc-id
                                                and utd-lines.LineNum    = vi
                         exclusive-lock no-error.
                         if not available  utd-lines
                         then do:
                            create utd-lines.
                            assign
                               utd-lines.db-num   = utd.db-num
                               utd-lines.doc-id   = utd.doc-id
                               utd-lines.Linenum  = vi
                               utd-lines.gds-code = ?
                            .
                         end.
                         utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                         vValues = vExtendedInvoiceItem:CorrectedValues no-error.
                         if vValues ne ?
                         then do:
                            getdesc(vExtendedInvoiceItem:OriginalValues ).
                            getdesc(vExtendedInvoiceItem:CorrectedValues ).
                            getdesc(vExtendedInvoiceItem:AmountsInc ).
                            getdesc(vExtendedInvoiceItem:AmountsDec ).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vValues:unit)).
                            define variable vQuantity as decimal no-undo.
                            vQuantity    = vValues:Quantity.
                            utd-lines.Price       = vValues:Price.
                            utd-lines.TotalWithVatExcluded   = vValues:SubtotalWithVatExcluded.
                            utd-lines.TaxRate   =   if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")).
                            utd-lines.Vat       = vValues:Vat.
                            utd-lines.Total     = vValues:Subtotal.
                            release object vValues.
                            vValues = vExtendedInvoiceItem:OriginalValues.
                            vQuantity    = vQuantity - vValues:Quantity.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vValues:Price.
                            utd-lines.Vat       = utd-lines.Vat - vValues:Vat.
                            utd-lines.Total     = utd-lines.Total  - vValues:Subtotal.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vValues:SubtotalWithVatExcluded.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vValues:Quantity)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vValues:Price)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vValues:SubtotalWithVatExcluded)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vValues:Vat)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vValues:Subtotal)).
                            release object vValues.
                            vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "cis"
                                  or vunit:Id eq "cis_до"
                                  or vunit:Id eq "sscc"
                                  or vunit:Id eq "sscc_до"
                               then do:
                                  vtext = vunit:Value.
                                  if vtext ne "-"
                                  then do viii = 1 to num-entries(vtext," "):
                                     VValue = entry(viii,vtext," ").
                                     vsite = if     vunit:Id eq "cis" or vunit:Id eq "sscc" then "+" else "-".
                                     addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                  end.
                               end.
                               release object vunit.
                            end.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "штрихкод"
                                   or vunit:Id eq "ean"
                               then do:
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                                  find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                                 and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                                 and utd-marking-lines.Linenum    = utd-lines.Linenum
                                  no-lock no-error.
                                  if not available utd-marking-lines
                                  then do:
                                    vtext = vunit:Value.
                                    do viii = 1 to num-entries(vtext," "):
                                       VValue = entry(viii,vtext," ").
                                       addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                    end.
                                 end.
                              end.
                              release object  vunit.
                           end.
                            release object vunits.
                            release utd-lines.
                            release utd-marking-lines.
                         end.
                         else do:
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers ).
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber).
                            vunits = vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "-".
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                            end.
                            release object vunits.
                            getdesc(vExtendedInvoiceItem:CorrectedItemIdentificationNumbers).
                            vunits = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "+".
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                            end.
                            release object vunits.
                            getdesc(vExtendedInvoiceItem:TaxRate ).
                            getdesc(vExtendedInvoiceItem:UnitName ).
                            getdesc(vExtendedInvoiceItem:Unit ).
                            getdesc(vExtendedInvoiceItem:Quantity ).
                            getdesc(vExtendedInvoiceItem:Price ).
                            getdesc(vExtendedInvoiceItem:Excise ).
                            getdesc(vExtendedInvoiceItem:SubtotalWithVatExcluded ).
                            getdesc(vExtendedInvoiceItem:Vat ).
                            getdesc(vExtendedInvoiceItem:WithoutVat).
                            getdesc(vExtendedInvoiceItem:Subtotal ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                            vValues = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:Unit:CorrectedValue)).
                            utd-lines.Price       = vExtendedInvoiceItem:Price:CorrectedValue.
                            utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded:CorrectedValue.
                            utd-lines.UnitCode    = vExtendedInvoiceItem:UnitName:CorrectedValue.
                            utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate:CorrectedValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:CorrectedValue,"/"),"%")).
                            utd-lines.Vat       = vExtendedInvoiceItem:Vat:CorrectedValue.
                            utd-lines.Total     = vExtendedInvoiceItem:Subtotal:CorrectedValue.
                            vQuantity    = dec(vExtendedInvoiceItem:Quantity:CorrectedValue) - dec(vExtendedInvoiceItem:Quantity:OriginalValue).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vExtendedInvoiceItem:Price:OriginalValue.
                            utd-lines.Vat       = utd-lines.Vat - vExtendedInvoiceItem:Vat:OriginalValue.
                            utd-lines.Total     = utd-lines.Total  - vExtendedInvoiceItem:Subtotal:OriginalValue.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vExtendedInvoiceItem:Quantity:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vExtendedInvoiceItem:Price:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vExtendedInvoiceItem:TaxRate:OriginalValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:OriginalValue,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vExtendedInvoiceItem:Vat:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vExtendedInvoiceItem:Subtotal:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"UnitCode_old", vExtendedInvoiceItem:UnitName:OriginalValue).
                         end.
                         vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                         getdesc(vunits).
                         do vii = 1 to vunits:count:
                            vunit = vunits:GETITEM(vii - 1).
                            getdesc(vunit).
                            if     vunit:Id eq "штрихкод"
                                or vunit:Id eq "ean"
                            then do:
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                               find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                              and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                              and utd-marking-lines.Linenum    = utd-lines.Linenum
                               no-lock no-error.
                               if not available utd-marking-lines
                               then do:
                                 vtext = vunit:Value.
                                 do viii = 1 to num-entries(vtext," "):
                                    VValue = entry(viii,vtext," ").
                                    addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                 end.
                              end.
                           end.
                           release object  vunit.
                        end.
                        release object  vunits.
                         release object vExtendedInvoiceItem.
                      end.
                      release object vItems.
                  end.
                  release object vContent.
               end.
               else do:
                  create tt-recid.
                  assign
                     tt-recid.orgid = vOrganizationGuid
                     tt-recid.docid = vDocumentid
                  .
                  PutMes("Error Ошибка получения данных из Диадок UniversalCorrectionDocument").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalCorrectionDocument".
               end.
            end.
         end.
         release object vDocumentChild.
         define variable vsetPAck as logical no-undo.
         define variable vcli-type as character no-undo.
         define variable vcli-code as integer no-undo.
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then do:
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            define variable vPack as character no-undo.
            if   iDocument:type eq "UniversalTransferDocument"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,utd.DocumentNumber,utd.DocumentDate).
            else if iDocument:type eq "UniversalTransferDocumentRevision"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalDocumentNumber,date(iDocument:OriginalDocumentDate)).
            else
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            if vPack ne utd.PackageId
            then
               assign
                  vsetPAck      = yes
                  utd.PackageId = vPack
               .
         end.
         if vNewUtd or vsetPAck then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if vNewUtd  then do:
                  GetLastUTDinPackbef(utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  find first old_utd where old_utd.db-num eq volddb-num
                                       and old_utd.doc-id eq volddoc-id
                     no-lock no-error.
                  for each utd-marking-lines where utd-marking-lines.db-num eq utd.db-num
                                               and utd-marking-lines.doc-id eq utd.doc-id
                  exclusive-lock:
                     if available old_utd
                        and utd.db-num ne volddb-num
                        and utd.doc-id ne volddoc-id
                     then
                        find first buf_utd-marking-lines where buf_utd-marking-lines.mark       = utd-marking-lines.mark
                                                           and buf_utd-marking-lines.db-num     = old_utd.db-num
                                                           and buf_utd-marking-lines.doc-id     = old_utd.doc-id
                        no-lock no-error.
                     utd-marking-lines.sts = if available buf_utd-marking-lines then buf_utd-marking-lines.sts else  objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
                  end.
                  validate utd.
                  ReCheckload( utd.db-num, utd.doc-id,yes).
                  subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               end.
            end.
            else do:
               GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
               find first old_utd where old_utd.db-num eq volddb-num
                                    and old_utd.doc-id eq volddoc-id
               no-lock no-error.
               if not available old_utd
                  or (   utd.db-num eq volddb-num
                     and utd.doc-id eq volddoc-id)
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoAvailDoc",string(utd.PackageId) + chr(4) + string(utd.db-num) + chr(4) + string(utd.doc-id)).
               else do:
                   assign
                       utd.obj-inn               = old_utd.obj-inn
                       utd.obj-kpp               = old_utd.obj-kpp
                       utd.obj-FnsParticipantId  = old_utd.obj-FnsParticipantId
                       utd.obj-info              = old_utd.obj-info
                       utd.parentDocumentExt     = old_utd.DocumentExt
                       utd.parentOrganizationExt = old_utd.OrganizationExt
                       utd.contract-code         = old_utd.contract-code
                   .
               end.
               validate utd.
               SaturateAndCheckUTD( utd.db-num, utd.doc-id).
            end.
         end.
         GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
         find first old_utd where old_utd.db-num eq volddb-num
                              and old_utd.doc-id eq volddoc-id
         no-lock no-error.
         if available old_utd
         then
            assign
               utd.parentDocumentExt     = old_utd.DocumentExt
               utd.parentOrganizationExt = old_utd.OrganizationExt
            .
         create tt-recid.
         assign
            tt-recid.orgid = vOrganizationGuid
            tt-recid.docid = vDocumentid
         .
         if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
         then do:
            tt-recid.parent = utd.PackageId.
            tt-recid.stamp  = utd.Timestamp.
         end.
         release utd no-error.
         if error-status:error
         then
            PutMes(substitute("Документ &1 от &2 не загружен. &3" ,iDocument:DocumentNumber,iDocument:DocumentDate,return-value) ).
         else
            PutMes(substitute("Документ &1 от &2 загружен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         unsubscribe "getNextseq".
      end.
   end.
end.
function packetupdd returns date
(iOrganization as component-handle, iDocument as component-handle):
   define variable VPack as character no-undo.
   define variable vorgid as character no-undo.
   define variable vdocid as character no-undo.
   define variable vstamp as datetime no-undo.
   define variable VPack2 as character no-undo.
   define variable vorgid2 as character no-undo.
   define variable vdocid2 as character no-undo.
   define variable vstamp2 as datetime no-undo.
   define variable VPackage as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define variable vDocuments as component-handle no-undo.
      VPack = iDocument:PackageId.
      vorgid = iDocument:OrganizationGuid.
      vdocid = iDocument:DocumentId.
      vstamp = iDocument:Timestamp.
      find first tt-pack where tt-pack.packid eq VPack
                           and tt-pack.stamp  eq vstamp
                           and tt-pack.orgid  eq vorgid
                           and tt-pack.docid  eq vdocid
      no-lock no-error.
      if not available tt-pack
      then do:
         create tt-pack.
         assign
            tt-pack.packid = VPack
            tt-pack.stamp  = vstamp
            tt-pack.orgid  = vorgid
            tt-pack.docid  = vdocid
         .
      end.
      getdesc(iDocument ).
      getdesc(iDocument:InitialDocumentIds ).
      vDocuments = iDocument:InitialDocumentIds.
      do vi= 1 to vDocuments:Count:
         vDocument = iOrganization:GetDocumentById(vDocuments:GetItem(vi - 1),false).
         getdesc(vDocument ).
         vorgid2 = vDocument:OrganizationGuid.
         vdocid2 = vDocument:DocumentId.
         vstamp2 = vDocument:Timestamp.
         find first tt-pack where tt-pack.packid eq VPack
                              and tt-pack.stamp  eq vstamp2
                              and tt-pack.orgid  eq vorgid2
                              and tt-pack.docid  eq vdocid2
         no-lock no-error.
         if not available tt-pack
         then do:
            create tt-pack.
            assign
               tt-pack.packid = VPack
               tt-pack.stamp  = vstamp2
               tt-pack.orgid  = vorgid2
               tt-pack.docid  = vdocid2
            .
         end.
         release object vDocument.
      end.
      release object vDocuments.
end.
procedure UpdateUTDInform:
   define input  parameter ibeg-date as date no-undo.
   define input  parameter iend-date as date no-undo.
   define output parameter odatelast as date no-undo.
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vDocumentsTask as component-handle no-undo.
   define variable vDocumentList  as component-handle no-undo.
   define variable vDocumentchildList  as component-handle no-undo.
   define variable vDocument       as component-handle no-undo.
   define buffer ext-classif_obj for ext-classif.
   define buffer ext-classif_Cli  for ext-classif.
   define variable vi  as integer no-undo.
   define variable vii as integer no-undo.
   odatelast = ibeg-date.
   vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
   if vOrganizationList eq ? then return error ?.
   vi = vOrganizationList:Count()no-error.
   if vi eq ?
   then
      return error ?.
   for each tt-recid:
      delete tt-recid.
   end.
   for each tt-pack:
      delete tt-pack.
   end.
   do vi = 1 to vOrganizationList:Count() :
      vOrganization = vOrganizationList:GetItem(vi - 1 ).
      getdesc(vOrganization).
      run changeIdtoGuid(vOrganization).
      vDocumentsTask = vOrganization:GetDocumentsTask().
                  vDocumentsTask:FromSendDate = ibeg-date  .
                  vDocumentsTask:ToSendDate   = iend-date.
                  for each tt-type, each tt-Class:
                      vDocumentsTask:Category     = tt-type.id + "." + tt-Class.id.
                     PutMes(substitute("Формируем список зависимых документов за период с &2 по &3  &1Категория: &4 &5",
                                       chr(10),
                                       ibeg-date ,
                                       iend-date,
                                       if tt-type .id eq "Any" then "" else tt-type.name,
                                       tt-Class.name)).
                      vDocumentList = vDocumentsTask:GetDocuments() no-error.
                      if vDocumentList ne ?
                      then do:
                        do vii= 1 to vDocumentList:Count:
                           if chekStop() then return ?.
                           vDocument = vDocumentList:GetItem(vii - 1).
                           odatelast = max(odatelast,vDocument:DocumentDate) no-error.
                           odatelast = min(odatelast,today).
                           packetupdd(vOrganization, vDocument).
                           release object vDocument.
                         end.
                         release object vDocumentList.
                      end.
                   end.
                   define variable VAlldoc    as integer no-undo.
                   define variable vprocessed as integer no-undo.
                   for each tt-pack :
                      VAlldoc = VAlldoc + 1.
                   end.
                   for each tt-pack :
                       if chekStop() then return ?.
                      if GetDocumforid (tt-pack.orgid, tt-pack.docid, output vDocument) eq ""
                      then do:
                          run  UpdateUTDInformOne(vDocument).
                         release object vDocument.
                     end.
                     vprocessed = vprocessed + 1.
                     PutStat (substitute ("Обработано документов &1 из &2",vprocessed,vAllDoc),yes).
                  end.
      release object vOrganization.
      release object vDocumentsTask.
   end.
   release object vOrganizationList.
end.
procedure updOneUTD:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   for each tt-recid:
      delete tt-recid.
   end.
   if getdocum (idb-num, idoc-id, output vDocument) eq ""
   then do:
       run  UpdateUTDInformOne(vDocument).
      release object vDocument.
   end.
end.
function CRnewDocum return character
(
iOrgGuid as character,
iContGuid as character,
iTypeUTD as character,
 iFile as character
 ):
define variable vOrganization as component-handle no-undo.
define variable vSendTask as component-handle no-undo.
    vOrganization = mDiadocConnection:GetOrganizationById(iOrgGuid ) no-error.
    if vOrganization ne ?
    then do:
       vSendTask = vOrganization:CreatePackageSendTask2().
       getdesc(vSendTask).
       vSendTask:CounteragentId = iContGuid  .
       vSendTask:AddDocumentFromFile("UniversalTransferDocument", iTypeUTD, "utd820_05_01_01", iFile).
       vSendTask:Send()no-error.
       if error-status:num-messages > 0 then do:
          PutErr("ERROR Ошибка отправки документа").
          return error "ERROR Ошибка отправки документа".
       end.
       else do:
          PutMes("Документ отправлен успешно.").
          message "Документ отправлен успешно."
          view-as alert-box.
       end.
       release object vSendTask.
      release object vOrganization .
   end.
end.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?.
   return.
end.
define variable v-rid-list      as character no-undo .
define variable row_order       as rowid     no-undo .
define variable recid_order     as integer   no-undo .
define variable ii              as integer   no-undo .
define variable v-cli           as logical   no-undo .
define variable filter-point    as character no-undo.
define variable Status_         as character no-undo .
DEFINE buffer buf_order for ub.order-doc.
define buffer buf_goods for ub.goods .
define variable bcol    as handle extent no-undo.
define variable hBrowse as handle no-undo.
define buffer db-attr for ub.db-attr .
define variable StatusOrder as class ibs.th.str.order.sts.order no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
function round-maxInt returns decimal
    (input p-dec as decimal) forward.
function round-maxDec returns decimal
    (input p-dec as decimal) forward.
function round-minInt returns decimal
    (input p-dec as decimal) forward.
define variable rPeriodZakaz       as integer   no-undo .
define variable vDaySale           as integer   no-undo .
define variable pGarantDay         as integer   no-undo .
define variable pDelDayGoods       as logical   no-undo .
define variable typeDocChoose      as character no-undo .
define variable dateZakaz          as character no-undo .
define variable zakazPeriod        as character no-undo .
define variable qntyPeriod         as integer   no-undo .
define variable pDateOrder         as date      no-undo .
define variable vLine              as integer   no-undo .
define variable vDateStart         as date      no-undo .
define variable vDateEnd           as date      no-undo .
define variable periodDate         as date      no-undo .
define variable v-fact-orderStart  as decimal   no-undo .
define variable v-fact-orderEnd    as decimal   no-undo .
define variable v-fact-order-start as decimal   no-undo .
define variable v-fact-order-end   as decimal   no-undo .
define buffer buf_PromoGoogs      for ub.PromoGoods .
define buffer buf_PromoAction     for ub.PromoAction .
define buffer buf_stk-line        for ub.stk-line .
define buffer buf_trn-doc         for ub.trn-doc .
define buffer buf_goods-attr      for ub.goods-attr .
define buffer buf_cli-gds         for ub.cli-gds .
define buffer buf_temp-gds-qnty   for temp-gds-qnty .
define buffer buf_doc-line        for ub.doc-line .
define buffer buf_order-line      for ub.order-line .
define buffer buf_order-doc       for ub.order-doc .
define buffer buf_contract-specif for ub.contract-specif .
procedure crt-orderLine:
    define input parameter par-params      as character no-undo .
    define input parameter pDocCode as integer no-undo .
    define input parameter pDbNum as integer no-undo .
    define input parameter table for tt-gds-list .
    define variable kk as integer no-undo .
    define variable ii as integer no-undo .
    pDateOrder = date(entry(1,par-params,chr(4))) .
    rPeriodZakaz = integer(entry(2,par-params,chr(4))) .
    vDaySale = integer (entry(3,par-params,chr(4))) .
    pGarantDay = integer(entry(4,par-params,chr(4))) .
    pDelDayGoods = logical(entry(5,par-params,chr(4))) .
    typeDocChoose = entry(6,par-params,chr(4)) .
    dateZakaz = entry(7,par-params,chr(4)) .
    find first buf_order-doc no-lock where buf_order-doc.doc-code = pDocCode and
        buf_order-doc.db-num = pDbNum no-error .
    find last buf_order-line no-lock where buf_order-line.doc-code = pDocCode and
        buf_order-line.db-num = pDbNum no-error .
    if available (buf_order-line) then vLine = buf_order-line.line-num .
    do kk = 1 to num-entries (dateZakaz,chr(7)):
        zakazPeriod = entry(kk,dateZakaz,chr(7)) .
        create tt-dateZakaz .
        assign
            tt-dateZakaz.id        = kk
            tt-dateZakaz.dateStart = date(entry(1,zakazPeriod,chr(8)))
            tt-dateZakaz.dateEnd   = date(entry(2,zakazPeriod,chr(8)))
            .
    end.
    for each tt-dateZakaz:
        qntyPeriod = qntyPeriod + 1 .
        if tt-dateZakaz.dateStart < vDateStart or vDateStart = ? then vDateStart = tt-dateZakaz.dateStart .
        if tt-dateZakaz.dateEnd > vDateEnd or vDateEnd = ? then vDateEnd = tt-dateZakaz.dateEnd .
    end.
    for each gds-list:
        for first buf_goods-attr no-lock where buf_goods-attr.gds-code = gds-list.gds-code and
            buf_goods-attr.attr-code = 'min-zapas':U:
            gds-list.minZapas = decimal (buf_goods-attr.attr-value) .
        end.
    end.
    for each gds-list:
        find first tt-zakaz no-lock where tt-zakaz.gds-code = gds-list.gds-code no-error .
        if available (tt-zakaz) then next .
        create tt-zakaz .
        assign
            tt-zakaz.gds-code          = gds-list.gds-code
            tt-zakaz.artic             = gds-list.artic
            tt-zakaz.gds-name          = gds-list.gds-name
            tt-zakaz.prod-code         = gds-list.prod-code
            tt-zakaz.prod-type         = gds-list.prod-type
            tt-zakaz.garant-stock      = 0
            tt-zakaz.minZapas          = gds-list.minZapas
            tt-zakaz.ostatokDay        = 0
            tt-zakaz.ostatokGoods      = 0
            tt-zakaz.rest              = 0
            tt-zakaz.qntyDay           = kk - 1
            tt-zakaz.qntyDaySale       = 0
            tt-zakaz.average-sales     = 0
            tt-zakaz.order-qnty        = 0
            tt-zakaz.volMinZapas       = 0
            tt-zakaz.sales             = 0
            tt-zakaz.volume-goods      = 0
            tt-zakaz.contract-prn-code = gds-list.contract
            tt-zakaz.contract-code     = gds-list.contract-code
            .
        for each buf_cli-gds no-lock where buf_cli-gds.artic = gds-list.artic and
            buf_cli-gds.prod-code = gds-list.prod-code and
            buf_cli-gds.prod-type = gds-list.prod-type:
            tt-zakaz.rest = tt-zakaz.rest + buf_cli-gds.supp-qnty .
        end.
        empty temp-table temp-gds-qnty .
        if pDelDayGoods then run ost-gds-day(vDateStart, vDateEnd, gds-list.gds-code, v-cntxt-obj-type, v-cntxt-obj-code, tt-zakaz.rest) .
        for each tt-dateZakaz:
            run day-begin-fact-order in this-procedure ( input tt-dateZakaz.dateStart
                , output v-fact-order-start
                ).
            run factord-end-day in this-procedure ( input tt-dateZakaz.dateEnd
                , output v-fact-order-end
                ).
            if pDelDayGoods then
            do:
                for each buf_temp-gds-qnty where buf_temp-gds-qnty.gds-code = gds-list.gds-code and
                    buf_temp-gds-qnty.ost > 0 and
                    buf_temp-gds-qnty.day >= tt-dateZakaz.dateStart and
                    buf_temp-gds-qnty.day <= tt-dateZakaz.dateEnd:
                    tt-zakaz.qntyDayGoods = tt-zakaz.qntyDayGoods + 1 .
                end.
            end.
            else tt-zakaz.qntyDayGoods = tt-dateZakaz.dateEnd - tt-dateZakaz.dateStart + 1.
            do ii = 0 to num-entries (typeDocChoose,chr(7)):
                for each buf_doc-line no-lock
                    where
                    buf_doc-line.ext-doc-type = entry(ii,typeDocChoose,chr(7)) and
                    buf_doc-line.obj-code = v-cntxt-obj-code and
                    buf_doc-line.obj-type = v-cntxt-obj-type and
                    buf_doc-line.artic = gds-list.artic and
                    buf_doc-line.prod-code = gds-list.prod-code and
                    buf_doc-line.prod-type = gds-list.prod-type and
                    buf_doc-line.fact-order >= v-fact-order-start and
                    buf_doc-line.fact-order <= v-fact-order-end :
                    tt-zakaz.qntyDaySale = tt-zakaz.qntyDaySale + 1 .
                    case entry(ii,typeDocChoose,chr(7)):
                        when   'ie':U  or
                        when   'im':U     then
                            do:
                                tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                            end.
                        when  'we':U      then
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  'wm':U       then
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  'em':U       then
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  'ev':U      then
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  'rv':U  then
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                        when  'ee':U      then
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  're':U  then
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                        when  'es':U     then
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        when  'rs':U then
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                        when  'we':U then
                            tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                    end case.
                end.
            end.
        end.
        if tt-zakaz.qntyDayGoods <> 0 then tt-zakaz.average-sales = round-maxDec(tt-zakaz.sales / tt-zakaz.qntyDayGoods) .
        if tt-zakaz.qntyDayGoods <> 0 then
        do:
            if tt-zakaz.rest > -1 then
            do:
                tt-zakaz.ostatokDay = tt-zakaz.rest - ((integer(pDateOrder - date(today)) * tt-zakaz.average-sales)) .
                if tt-zakaz.ostatokDay < 0 then tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale).
                else tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale - tt-zakaz.ostatokDay) .
            end.
            else tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale - tt-zakaz.rest).
            if tt-zakaz.qntyDaySale <> 0 then
            do:
                tt-zakaz.volMinZapas = round-maxInt(tt-zakaz.volume-goods + tt-zakaz.minZapas) .
                tt-zakaz.garant-stock = pGarantDay * tt-zakaz.average-sales .
                tt-zakaz.order-qnty = round-maxInt(tt-zakaz.volume-goods + tt-zakaz.minZapas + tt-zakaz.garant-stock) .
                if tt-zakaz.average-sales <> 0 then tt-zakaz.ostatokGoods = round-minInt(tt-zakaz.rest / tt-zakaz.average-sales) .
            end.
            else tt-zakaz.volume-goods = 0 .
        end.
        for each buf_PromoGoogs no-lock where buf_PromoGoogs.gds-code = gds-list.gds-code,
            first buf_PromoAction no-lock where buf_PromoAction.id = buf_PromoGoogs.idAction and
            buf_PromoAction.end-date >= today and buf_PromoAction.beg-date <= today and buf_PromoAction.Status_ = 1:
            tt-zakaz.promo = true .
        end.
        find first buf_goods no-lock where
            buf_goods.gds-code = tt-zakaz.gds-code.
        create buf_order-line.
        assign
            vLine                        = vLine + 1
            buf_order-line.doc-code      = pDocCode
            buf_order-line.db-num        = pDbNum
            buf_order-line.line-num      = vLine
            buf_order-line.gds-code      = tt-zakaz.gds-code
            buf_order-line.artic         = tt-zakaz.artic
            buf_order-line.prod-type     = if avail buf_goods then buf_goods.prod-type else ""
            buf_order-line.prod-code     = if avail buf_goods then buf_goods.prod-code else 0
            buf_order-line.order-qnty    = tt-zakaz.order-qnty
            buf_order-line.fact-qnty     = tt-zakaz.order-qnty
            buf_order-line.rest          = tt-zakaz.rest
            buf_order-line.sales         = tt-zakaz.sales
            buf_order-line.average-sales = tt-zakaz.average-sales
            buf_order-line.stock-goods   = if tt-zakaz.average-sales = 0 and tt-zakaz.ostatokDay <> 0 then -1 else integer(tt-zakaz.ostatokGoods)
            buf_order-line.volume-goods  = tt-zakaz.volume-goods
            buf_order-line.volume-stock  = if tt-zakaz.minZapas > tt-zakaz.rest then tt-zakaz.minZapas else tt-zakaz.volMinZapas
            buf_order-line.min-stock     = tt-zakaz.minZapas
            buf_order-line.garant-stock  = tt-zakaz.garant-stock
            buf_order-line.promo         = tt-zakaz.promo
            .
        validate buf_order-line.
    end .
end procedure .
procedure ost-gds-day :
    do
        on error undo, return error return-value
        :
        define input parameter p-dateStart as decimal no-undo .
        define input parameter p-dateEnd as decimal no-undo .
        define input parameter p-gds-code like ub.goods.gds-code no-undo .
        define input parameter p-obj-type as character no-undo .
        define input parameter p-obj-code as integer no-undo .
        define input parameter p-ost-today as decimal no-undo .
        define variable vOst as decimal no-undo .
        define buffer p_goods     for ub.goods .
        define buffer p-doc-line  for ub.doc-line .
        define buffer pc-gds-obj  for ub.c-gds-obj .
        define buffer pc-gds-obj2 for ub.c-gds-obj .
        find first p_goods no-lock where p_goods.gds-code = p-gds-code no-error .
        if error-status :error then return error .
        do periodDate = vDateStart to vDateEnd:
            create temp-gds-qnty .
            assign
                temp-gds-qnty.day      = periodDate
                temp-gds-qnty.gds-code = p_goods.gds-code
                .
            find first pc-gds-obj no-lock where pc-gds-obj.gds-code = p_goods.gds-code and
                pc-gds-obj.obj-code = p-obj-code and
                pc-gds-obj.obj-type = p-obj-type and
                pc-gds-obj.corr-date = periodDate no-error .
            if not available (pc-gds-obj) then
            do:
                find last pc-gds-obj2 no-lock where pc-gds-obj2.gds-code = p_goods.gds-code and
                    pc-gds-obj2.obj-code = p-obj-code and
                    pc-gds-obj2.obj-type = p-obj-type and
                    pc-gds-obj2.corr-date < periodDate no-error .
                if available (pc-gds-obj2) then temp-gds-qnty.ost = pc-gds-obj2.fact-qnty .
            end.
            else temp-gds-qnty.ost = pc-gds-obj.fact-qnty .
        end.
    end.
end procedure.
function round-maxInt returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if absolute(p-dec - TRUNCATE (p-dec, 0)) < 0.5
        then
    do:
        if p-dec > 0 then p-int = integer (p-dec + 0.4) .
        else p-int = integer(p-dec) .
    end .
    else
    do:
        if p-dec < 0 then p-int = integer (p-dec + 0.4) .
        else p-int = integer(p-dec) .
    end.
    return p-int .
end function.
function round-minInt returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if absolute(p-dec - TRUNCATE (p-dec, 0)) > 0.5
        then
    do:
        if p-dec > 0 then p-int = integer (p-dec - 0.4) .
        else p-int = integer(p-dec) .
    end .
    else
    do:
        if p-dec < 0 then p-int = integer (p-dec - 0.4) .
        else p-int = integer(p-dec) .
    end.
    return p-int .
end function.
function round-maxDec returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if p-dec - TRUNCATE (p-dec, 1) > 0
        then
    do:
        if TRUNCATE (p-dec, 1) = 0 then p-int = TRUNCATE (p-dec, 1) .
        else p-int = TRUNCATE (p-dec, 1) + 0.1 .
    end.
    else
    do:
        if p-dec - TRUNCATE (p-dec, 1) > 0
            then
        do:
            p-int = TRUNCATE (p-dec, 1) - 0.1.
        end.
        else
        do:
            assign
                p-int = TRUNCATE (p-dec, 1) .
            .
        end.
    end.
    return p-int .
end function.
function round-minDec returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if p-dec - TRUNCATE (p-dec, 1) < 0
        then
    do:
        if TRUNCATE (p-dec, 1) = 0 then p-int = TRUNCATE (p-dec, 1) .
        else p-int = TRUNCATE (p-dec, 1) - 0.1 .
    end.
    else
    do:
        if p-dec - TRUNCATE (p-dec, 1) > 0
            then
        do:
            p-int = TRUNCATE (p-dec, 1) - 0.1.
        end.
        else
        do:
            assign
                p-int = p-dec
                .
        end.
    end.
    return p-int .
end function.
FUNCTION num-doc RETURNS character
    (p-doc-code as integer, p-db-num as integer) FORWARD.
FUNCTION user-name RETURNS character
    (p-user-id as character ) FORWARD.
FUNCTION get-sts RETURNS character
    (p-sts as integer ) FORWARD.
FUNCTION cli-name RETURNS character
    (cli-code as integer, cli-type as character ) FORWARD.
FUNCTION prep-nameorcode RETURNS CHARACTER
    ( input p-nameorcode as character )  FORWARD.
DEFINE BUTTON b-add
    LABEL "&Добавить"
    SIZE 10 BY 1.
DEFINE BUTTON b-cli
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..."
    SIZE 3.5 BY 1.04.
DEFINE BUTTON b-copy
    LABEL "&Копия"
    SIZE 10 BY 1.
DEFINE VARIABLE statusNotif AS LOGICAL INITIAL true
    LABEL "Уведомления о статусах"
    VIEW-AS TOGGLE-BOX
    SIZE 27.5 BY 1
    FONT 1 NO-UNDO.
DEFINE BUTTON b-date-End
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..."
    SIZE 3.5 BY 1.04.
DEFINE BUTTON b-date-Start
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..."
    SIZE 3.5 BY 1.04.
DEFINE BUTTON b-del
    LABEL "&Удалить"
    SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход"
    SIZE 10 BY 1.
DEFINE BUTTON b-help
    LABEL "Помощь":L
    SIZE 7 BY 1.
DEFINE BUTTON b-hist
    IMAGE-UP FILE "cmp/b-hist.bmp":U
    IMAGE-DOWN FILE "cmp/b-hist.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
    LABEL "&История"
    SIZE 3 BY 1.
DEFINE BUTTON b-lookup
    LABEL "&Просмотр"
    SIZE 10 BY 1.
DEFINE BUTTON b-mark
    LABEL "&*"
    SIZE 3 BY 1.
DEFINE BUTTON b-markGoods
    LABEL "&Сбросить"
    SIZE 10 BY 1 TOOLTIP "Сбросить фильтры".
DEFINE BUTTON b-reset
    LABEL "&Обновить"
    SIZE 10 BY 1 TOOLTIP "Сбросить фильтры".
DEFINE BUTTON b-sch
    LABEL "&Фильтр"
    SIZE 7 BY 1.
DEFINE BUTTON b-sel
    LABEL "&Выбор"
    SIZE 10 BY 1.
DEFINE BUTTON b-send
    LABEL "&Отправить"
    SIZE 10 BY 1.
DEFINE BUTTON b-update
    LABEL "&Изменить"
    SIZE 10 BY 1.
DEFINE BUTTON bt-no-sel-all
    LABEL "+"
    SIZE 3 BY 1.
DEFINE BUTTON bt-not-sel-desel-all
    LABEL "-"
    SIZE 3 BY 1.
DEFINE VARIABLE c-status     AS CHARACTER FORMAT "X(256)":U INITIAL "0"
    LABEL "Статус"
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все","0",
    "Новый","1",
    "Отправлен","2",
    "Подтверждено без изменений","3",
    "Есть изменения","4",
    "Отклонен","5",
    "Ожидает поставку","6",
    "Поставка принята","7",
    "Получено поставщиком","8"
    DROP-DOWN-LIST
    SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code     AS CHARACTER FORMAT "x(20)"
    LABEL "Поставщик"
    VIEW-AS FILL-IN
    SIZE 10.88 BY 1.
DEFINE VARIABLE cli-name     AS CHARACTER FORMAT "x(40)"
    VIEW-AS FILL-IN
    SIZE 47 BY 1.
DEFINE VARIABLE cli-type     AS CHARACTER FORMAT "x(3)"
    VIEW-AS FILL-IN
    SIZE 4 BY 1.
DEFINE VARIABLE Date-End     AS DATE      FORMAT "99/99/9999":U
    LABEL "по"
    VIEW-AS FILL-IN
    SIZE 10.88 BY 1 NO-UNDO.
DEFINE VARIABLE date-Start   AS DATE      FORMAT "99/99/9999":U
    LABEL "За период с"
    VIEW-AS FILL-IN
    SIZE 10.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-mark       AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 56.38 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num     AS INTEGER   FORMAT "->>>9":U INITIAL 0
    VIEW-AS TEXT
    SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE num-contract AS CHARACTER FORMAT "X(256)":U
    LABEL "Номер договора"
    VIEW-AS FILL-IN
    SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE num-order    AS CHARACTER FORMAT "X(256)":U
    LABEL "Номер заказа"
    VIEW-AS FILL-IN
    SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE r-goods      AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Код товара", 0,
    "Название товара", 1
    SIZE 35 BY 1 NO-UNDO.
DEFINE QUERY br-order FOR
    X_order SCROLLING.
DEFINE BROWSE br-order
    QUERY br-order NO-LOCK DISPLAY
    mark-string( input recid(X_order), input v-rid-list) column-label "*" format "X(1)":U
    X_order.order-item column-label "№ заказа" FORMAT "X(12)":U width 12
    get-sts(X_order.sts) column-label "Статус" FORMAT "X(256)":U width 15
    X_order.order-date column-label "Дата поставки" FORMAT "99/99/9999":U width 15
    X_order.doc-date column-label "Дата создания" FORMAT "99/99/9999":U width 15
    X_order.cli-code column-label "Код пост-ка" format ">>>999":U width 12
    cli-name(X_order.cli-code, X_order.cli-type) column-label "Поставщик" FORMAT "x(256)":U width 30
    X_order.contract-prn-code column-label "Номер договора" FORMAT "x(256)":U width 30
    user-name(X_order.user-id) column-label "Исполнитель" FORMAT "x(256)":U width 30
    X_order.doc-code column-label "№ заказа в ТН" FORMAT ">>>>>>>>>9":U width 15
    WITH NO-ROW-MARKERS SEPARATORS SIZE 130 BY 23.08 FIT-LAST-COLUMN.
DEFINE FRAME d-order
    b-exit AT ROW 1 COL 1.5 WIDGET-ID 4
    b-add AT ROW 1 COL 11.5 WIDGET-ID 28
    b-sel AT ROW 1 COL 11.5 WIDGET-ID 8
    b-update AT ROW 1 COL 21.5 WIDGET-ID 6
    b-lookup AT ROW 1 COL 31.5 WIDGET-ID 10
    b-copy AT ROW 1 COL 41.5 WIDGET-ID 12
    b-del AT ROW 1 COL 51.5 WIDGET-ID 14
    b-send AT ROW 1 COL 61.5 WIDGET-ID 30
    b-reset AT ROW 1 COL 71.5 WIDGET-ID 30
    b-sch AT ROW 1 COL 114 WIDGET-ID 16
    b-help AT ROW 1 COL 121 WIDGET-ID 18
    b-hist AT ROW 1 COL 128 WIDGET-ID 18
    b-date-Start AT ROW 2.46 COL 26.13 WIDGET-ID 252
    date-Start AT ROW 2.5 COL 13.13 COLON-ALIGNED WIDGET-ID 238
    Date-End AT ROW 2.5 COL 32.5 COLON-ALIGNED WIDGET-ID 36
    b-date-End AT ROW 2.5 COL 45.75 WIDGET-ID 250
    c-status AT ROW 2.5 COL 97 COLON-ALIGNED WIDGET-ID 228
    b-cli AT ROW 3.61 COL 26.13 WIDGET-ID 240
    statusNotif AT ROW 1 COL 99 WIDGET-ID 240
    cli-code AT ROW 3.67 COL 13.13 COLON-ALIGNED WIDGET-ID 244
    cli-type AT ROW 3.67 COL 27.75 COLON-ALIGNED NO-LABEL WIDGET-ID 248
    cli-name AT ROW 3.67 COL 80.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 246
    num-order AT ROW 3.67 COL 97 COLON-ALIGNED WIDGET-ID 254
    num-contract AT ROW 4.79 COL 97 COLON-ALIGNED WIDGET-ID 256
    r-goods AT ROW 4.96 COL 15.38 NO-LABEL WIDGET-ID 260
    bt-no-sel-all AT ROW 6 COL 5 WIDGET-ID 22 NO-TAB-STOP
    bt-not-sel-desel-all AT ROW 6 COL 8 WIDGET-ID 24 NO-TAB-STOP
    b-mark AT ROW 6 COL 11 WIDGET-ID 26 NO-TAB-STOP
    f-mark AT ROW 6 COL 13.13 COLON-ALIGNED NO-LABEL WIDGET-ID 258
    b-markGoods AT ROW 6 COL 71.5 WIDGET-ID 266
    br-order AT ROW 7 COL 1.5 WIDGET-ID 200
    mark-num AT ROW 6 COL 1 NO-LABEL WIDGET-ID 20
    SPACE(127.12) SKIP(23.10)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Реестр заказов" WIDGET-ID 100.
ASSIGN
    FRAME d-order:SCROLLABLE = FALSE
    FRAME d-order:HIDDEN     = TRUE.
ASSIGN
    br-order:COLUMN-RESIZABLE IN FRAME d-order = TRUE.
ON WINDOW-CLOSE OF FRAME d-order
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-add IN FRAME d-order
    DO:
        define variable varlog as logical no-undo .
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_add-def':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        if not varlog then return no-apply .
        run rep/g-rsrvPlan.p (parparentproc, yes) no-error .
        run init-sort .
    END.
ON CHOOSE OF b-cli IN FRAME d-order
    DO:
        define variable v-types   as character no-undo .
        define variable ref-list  as character no-undo .
        define variable ref-rec   as integer   no-undo .
        def    var      supp-type as character no-undo.
        run ref/cli-all.w (parparentproc
            , "b-sel,b-add"
            , ?
            , ?
            , ?
            , ?
            , ?
            , ?
            , output ref-list) .
        if ref-list <> "" then
        do:
            ref-rec = integer (ref-list).
            find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
            assign
                cli-code = string(ub.clients.obj-code)
                cli-type = ub.clients.obj-type
                cli-name = ub.clients.obj-name
                .
            display cli-code with frame d-order.
            display ub.clients.obj-type @ cli-type with frame d-order.
            display ub.clients.obj-name @ cli-name with frame d-order .
            v-cli = true .
            run init-sort .
        end.
    END.
ON CHOOSE OF b-copy IN FRAME d-order
    DO:
        define variable Log-Res as logical no-undo .
        define buffer bf_order           for ub.order-doc .
        define buffer bf_order-line      for ub.order-line .
        define buffer bf_order-attr      for ub.order-doc-attr .
        define buffer bf_order-line-attr for ub.order-line-attr .
        define buffer buf_X_order        for X_order.
        if num-entries(v-rid-list) = 1 then
            find first buf_X_order no-lock where
                recid(buf_X_order) = int(v-rid-list) no-error.
        else if available (X_order) then
                find first buf_X_order no-lock where
                    recid(buf_X_order) = recid(X_order) no-error.
        if available (buf_X_order) then
        do:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_add-def':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
            if not log-res then return no-apply .
            empty temp-table tt-zakaz .
            create bf_order .
            assign
                bf_order.doc-code = next-value (s-order-code, ub)
                bf_order.db-num   = v-cntxt-db-num.
            buffer-copy buf_X_order except doc-code db-num order-item to bf_order .
            assign
                bf_order.user-id    = v-cntxt-userid
                bf_order.sts        = 1
                bf_order.doc-date   = now
                bf_order.order-date = today + 1
                .
            date(entry(1,bf_order.params,chr(4))) = today .
            empty temp-table gds-list.
            for each ub.order-line no-lock where
                ub.order-line.db-num = buf_X_order.db-num and
                ub.order-line.doc-code = buf_X_order.doc-code:
                find first buf_goods no-lock where buf_goods.gds-code = ub.order-line.gds-code no-error .
                if available (buf_goods) then
                do:
                    find first gds-list where gds-list.gds-code = buf_goods.gds-code and gds-list.contract = buf_X_order.contract-prn-code no-error .
                    if not available (gds-list) then
                    do:
                        create gds-list .
                        buffer-copy buf_goods to gds-list .
                        gds-list.contract = buf_X_order.contract-prn-code .
                        gds-list.contract-code = buf_X_order.contract-code .
                    end.
                end.
            end.
            if bf_order.params <> "" then
                run crt-orderLine (
                    input bf_order.params,
                    input bf_order.doc-code,
                    input bf_order.db-num,
                    input table tt-gds-list) no-error .
            for each ub.order-doc-attr no-lock where
                ub.order-doc-attr.db-num = buf_X_order.db-num and
                ub.order-doc-attr.doc-code = buf_X_order.doc-code and
                ub.order-doc-attr.attr-code <> "copyOrder":
                create bf_order-attr .
                bf_order-attr.doc-code = bf_order.doc-code .
                buffer-copy ub.order-doc-attr except doc-code to bf_order-attr .
            end.
            for each ub.order-line-attr no-lock where
                ub.order-line-attr.db-num   = buf_X_order.db-num and
                ub.order-line-attr.doc-code = buf_X_order.doc-code:
                create bf_order-line-attr .
                bf_order-line-attr.doc-code = bf_order.doc-code .
                buffer-copy ub.order-line-attr except doc-code to bf_order-line-attr .
            end.
            create bf_order-attr .
            assign
                bf_order-attr.doc-code   = bf_order.doc-code
                bf_order-attr.db-num     = bf_order.db-num
                bf_order-attr.attr-code  = "copyOrder"
                bf_order-attr.attr-value = string(buf_X_order.doc-code)
                .
            OPEN QUERY br-order FOR EACH X_order no-lock by X_order.doc-code desc INDEXED-REPOSITION.
            release bf_order .
            release bf_order-line .
            release bf_order-attr .
            release X_order.
            run init-sort .
        end.
        else
        do:
            message "Не выбран заказ для копирования"
                view-as alert-box.
        end.
    END.
ON CHOOSE OF b-date-End IN FRAME d-order
    DO:
        run sel-date in this-procedure
            (input Date-End :handle
            ,input ""
            ) .
        if date(Date-End:screen-value) < Date-Start then
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-End with frame d-order .
        end.
        assign Date-End .
        if Date-Start <> ? then
        do:
            run init-sort .
        end.
    END.
ON CHOOSE OF b-date-Start IN FRAME d-order
    DO:
        run sel-date in this-procedure
            (input Date-Start :handle
            ,input ""
            ) .
        if Date-End < date(Date-Start:screen-value) then
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-Start with frame d-order .
        end.
        assign Date-Start .
        if Date-End <> ? then
        do:
            run init-sort .
        end.
    END.
ON CHOOSE OF b-del IN FRAME d-order
    DO:
        define buffer bf_order for ub.order-doc .
        define variable Log-Res  as logical   no-undo init yes.
        define variable undelete as logical   no-undo .
        define variable zakazNum as character no-undo .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if not log-res then return no-apply .
        if v-rid-list = "" then
        do:
            if AVAILABLE (X_order) then
            do:
                if X_order.sts = 1 then
                do:
                    message "Удалить заказ с кодом ТН №" + string (X_order.doc-code) + "?"
                        view-as alert-box question buttons yes-no update undelete.
                    if undelete then
                    do:
                        find first bf_order exclusive-lock where bf_order.doc-code = X_order.doc-code and
                            bf_order.db-num = X_order.db-num no-error .
                        delete bf_order .
                        delete X_order .
                    end.
                end.
                else
                do:
                    message "Заказ №" + string (X_order.order-item) + " не может быть удален"
                        view-as alert-box.
                end.
            end.
            else
            do:
                message "Не выбран заказ для удаления"
                    view-as alert-box.
            end.
        end.
        if v-rid-list <> "" then
        do:
            do ii = 0 to num-entries (v-rid-list):
                find first X_order where recid(X_order) = integer(entry (ii,v-rid-list)) and
                    X_order.sts = StatusOrder:NewStatus:KeyIntDB no-error .
                if available (X_order) then
                do:
                    if zakazNum = "" then zakazNum = string(X_order.doc-code) .
                    else zakazNum = zakazNum + ", " + string(X_order.doc-code) .
                end.
            end .
            message "Удалить заказы с кодом ТН №" + zakazNum + "?"
                view-as alert-box question buttons yes-no update undelete.
            if not undelete then return .
        end.
        do ii = 0 to num-entries (v-rid-list):
            find first X_order where recid(X_order) = integer(entry (ii,v-rid-list)) and
                X_order.sts = StatusOrder:NewStatus:KeyIntDB no-error .
            if available (X_order) then
            do:
                find first bf_order exclusive-lock where bf_order.doc-code = X_order.doc-code and
                    bf_order.db-num = X_order.db-num no-error .
                delete bf_order .
            end.
        end .
        v-rid-list = "" .
        run init-sort .
    END.
ON CHOOSE OF b-hist IN FRAME d-order
    DO:
        define variable v-rid-list as character no-undo.
        if available (X_order) then
        do:
            run ref/cordhist.w (
                X_order.db-num,
                X_order.doc-code,
                parparentproc,
                0,
                "",
                0,
                "",
                "one",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
        end.
    END.
ON CHOOSE OF b-lookup IN FRAME d-order
    DO:
        define variable Log-Res as logical no-undo .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_lookup':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if not log-res then return no-apply .
        if available (X_order) then
        do:
            run str/order-doc.w (input parparentproc,
                input X_order.doc-code,
                input 'ПРОСМОТР':U
                )  .
        end.
        else
        do:
            message "Не выбран заказ"
                view-as alert-box.
            return no-apply .
        end.
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then
        do:
            enable b-del with frame d-order .
        end.
        else disable b-del with frame d-order .
    END.
ON CHOOSE OF b-mark IN FRAME d-order
    DO:
        define variable loc#log as logical no-undo .
        if available X_order then
        do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid24 as character no-undo .
define variable v-num-entry24 as integer   no-undo .
assign
  v-str-recid24 = trim( string( recid( X_order ) , "->>>>>>>>>>>9":U ) )
  v-num-entry24 = lookup( v-str-recid24 , v-rid-list )
.
if v-num-entry24 > 0 then do:
  assign
    entry( v-num-entry24, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid24
  .
end.
            row_order = rowid(X_order).
            loc#log = br-order:refresh() .
            reposition br-order to rowid row_order.
            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
            do:
                loc#log = br-order:select-next-row ().
                apply "VALUE-CHANGED" to br-order in frame d-order.
            end.
            if num-entries( v-rid-list ) = 0 then
            do:
                hide mark-num in frame d-order.
                enable b-copy with frame d-order .
            end.
            else
            do:
                if num-entries (v-rid-list) > 1 then disable b-copy with frame d-order .
                else enable b-copy with frame d-order .
                display
                    num-entries( v-rid-list ) @ mark-num
                    with frame d-order.
            end.
        end.
        apply "entry" to br-order in frame d-order.
    END.
ON CHOOSE OF b-reset IN FRAME d-order
    DO:
        Date-Start = today - 14 .
        Date-End = today .
        cli-code = "" .
        cli-type = "" .
        cli-name = "" .
        c-status = "-1" .
        num-order = "" .
        v-cli = false .
        f-mark = "" .
        r-goods = 0 .
        num-contract = "" .
        b-markGoods:visible = false .
        r-goods:sensitive = true .
        f-mark:sensitive = true .
        display Date-Start Date-End cli-code
            cli-type cli-name c-status num-order f-mark num-contract with frame d-order .
        run init-sort .
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then
        do:
            enable b-del with frame d-order .
        end.
        else disable b-del with frame d-order .
    END.
ON CHOOSE OF b-sel IN FRAME d-order
    DO:
        define buffer buf_order for ub.order-doc .
        if v-rid-list = "" then
        do:
            if available (X_order) then
            do:
                find first buf_order no-lock where buf_order.doc-code = X_order.doc-code no-error .
                v-rid-list = string(recid(buf_order)) .
            end.
        end.
        rec-order = v-rid-list .
    END.
ON CHOOSE OF b-send IN FRAME d-order
    DO:
        define variable ii           as integer   no-undo .
        define variable log-res      as logical   no-undo .
        define variable p-ok         as logical   no-undo .
        define variable qntyNew      as integer   no-undo .
        define variable qntyNull     as integer   no-undo .
        define variable errorRidList as character no-undo .
        define variable ridList      as character no-undo .
        define buffer bf_order     for ub.order-doc .
        define buffer buf_X_order  for X_order .
        define buffer X_order-line for ub.order-line .
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if not log-res then return no-apply .
        if v-rid-list = "" then
        do:
            if X_order.sts <> StatusOrder:NewStatus:KeyIntDB then
            do:
                message "Заказ уже был отправлен."
                    view-as alert-box.
                return no-apply .
            end.
            find first X_order-line no-lock where X_order-line.doc-code = X_order.doc-code and
                X_order-line.db-num = X_order.db-num and X_order-line.order-qnty <= 0 no-error .
            if not available (X_order-line) then
            do:
                message "Вы уверены, что хотите отправить заказ поставщику?"
                    view-as alert-box question buttons yes-no update p-ok.
                if p-ok then
                do:
                    run bge\send1cerp.p (parparentproc,
                        this-procedure,
                        this-procedure,
                        "order",
                        (buffer X_order:handle),
                        ?,
                        ?) no-error.
                    if  error-status:error then
                    do:
                        message return-value
                            view-as alert-box.
                        return .
                    end.
                    X_order.sts = StatusOrder:Sended:KeyIntDB .
                    find first bf_order exclusive-lock where bf_order.doc-code = X_order.doc-code and
                        bf_order.db-num = X_order.db-num no-error .
                    if available (bf_order) then
                    do:
                        bf_order.sts = X_order.sts .
                        release bf_order.
                    end.
                end.
                else return no-apply.
            end.
            else
            do:
                message "Количество товара в заказе не может быть отрицательным или равным нулю"
                    view-as alert-box .
                return no-apply .
            end.
        end.
        else
        do:
            do ii = 1 to num-entries (v-rid-list):
                find first buf_X_order no-lock where recid(buf_X_order) = integer(entry (ii,v-rid-list)) no-error .
                if buf_X_order.sts <> StatusOrder:NewStatus:KeyIntDB then
                do:
                    qntyNew = qntyNew + 1 .
                    next .
                end.
                find first X_order-line no-lock where
                    X_order-line.db-num = buf_X_order.db-num and
                    X_order-line.doc-code = buf_X_order.doc-code and
                    X_order-line.order-qnty <= 0 no-error .
                if available (X_order-line) then
                do:
                    qntyNull = qntyNull + 1 .
                    if errorRidList = "" then errorRidList = string(recid(buf_X_order)) .
                    else errorRidList = errorRidList + "," + string(recid(buf_X_order)) .
                    next .
                end.
                    if ridList = "" then ridList = string(recid(buf_X_order)) .
                    else ridList = ridList + "," + string(recid(buf_X_order)) .
            end.
            if qntyNull = (ii - 1) then
            do:
                message "Отправлять можно заказы только c положительным количеством товара."
                    view-as alert-box.
                return no-apply .
            end.
            if qntyNew = (ii - 1) then
            do:
                message "Отправлять можно только новые заказы."
                    view-as alert-box.
                return no-apply .
            end.
            if (qntyNew + qntyNull) = (ii - 1) then
            do:
                message "Отправлять можно заказы только c положительным количеством товара."
                    view-as alert-box.
                message "Отправлять можно только новые заказы."
                    view-as alert-box.
                return no-apply .
            end.
            if errorRidList <> "" then do:
                do ii = 1 to num-entries (errorRidList):
                    find first buf_X_order no-lock where recid(buf_X_order) = integer(entry (ii,errorRidList)) no-error .
                   message "В заказе c кодом ТН " + string(buf_X_order.doc-code) + " не должно быть строк с количеством <= 0"
                    view-as alert-box.
                end.
            end.
            if qntyNew > 0 then do:
                message "Отправлять можно только новые заказы."
                    view-as alert-box.
            end.
            if ridList <> "" then do:
            message "Вы уверены, что хотите отправить выбранные заказы поставщику?"
                view-as alert-box question buttons yes-no update p-ok.
            end.
            if p-ok then
            do:
                do ii = 1 to num-entries (ridList):
                    find first buf_X_order no-lock where recid(buf_X_order) = integer(entry (ii,ridList)) no-error .
                find first X_order-line no-lock where
                    X_order-line.db-num = buf_X_order.db-num and
                    X_order-line.doc-code = buf_X_order.doc-code and
                    X_order-line.order-qnty <= 0 no-error .
                if available (X_order-line) then
                do:
                    qntyNull = qntyNull + 1 .
                    next .
                end.
                    run bge\send1cerp.p (parparentproc,
                        this-procedure,
                        this-procedure,
                        "order",
                        (buffer buf_X_order:handle),
                        ?,
                        ?) no-error.
                    if  error-status:error then
                    do:
                        message return-value
                            view-as alert-box.
                        next .
                    end.
                    buf_X_order.sts = StatusOrder:Sended:KeyIntDB .
                    find first bf_order exclusive-lock where bf_order.doc-code = buf_X_order.doc-code and
                        bf_order.db-num = buf_X_order.db-num no-error .
                    if available (bf_order) then
                    do:
                        bf_order.sts = buf_X_order.sts .
                        release bf_order.
                    end.
                end.
            end.
            else return no-apply.
        end.
        v-rid-list = "" .
        disable b-del with frame d-order .
        run init-sort .
    END.
ON CHOOSE OF b-update IN FRAME d-order
    DO:
        define variable Log-Res as logical no-undo init "true".
        if available (X_order) then
        do:
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
            if not log-res then return no-apply .
            if X_order.sts = StatusOrder:NewStatus:KeyIntDB then
            do:
                run str/order-doc.w (input parparentproc,
                    input X_order.doc-code,
                    input 'ИЗМЕНЕНИЕ':U
                    )  .
                run init-sort .
            end.
            else
            do:
                message "Редактировать заказ можно только в статусе: 'Новый'"
                    view-as alert-box.
                return .
            end.
        end.
        else
        do:
            message "Не выбран заказ"
                view-as alert-box.
            return no-apply .
        end.
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then
        do:
            enable b-del with frame d-order .
        end.
        else disable b-del with frame d-order .
    END.
ON ROW-DISPLAY OF br-order IN FRAME d-order
    DO:
        if  X_order.sts = StatusOrder:DeliveryCompleted:KeyIntDB then
        do:
            do ii = 1 to extent (bcol):
                if valid-handle (bcol[ii])
                    then
                do:
                    assign
                        bcol[ii]:fgcolor = 8.
                end.
            end.
        end.
        if  X_order.sts = StatusOrder:Corrected:KeyIntDB then
        do:
            do ii = 1 to extent (bcol):
                if valid-handle (bcol[ii])
                    then
                do:
                    assign
                        bcol[ii]:fgcolor = 5.
                end.
            end.
        end.
        if  X_order.sts = StatusOrder:Cancelled:KeyIntDB then
        do:
            do ii = 1 to extent (bcol):
                if valid-handle (bcol[ii])
                    then
                do:
                    assign
                        bcol[ii]:fgcolor = 12.
                end.
            end.
        end.
    END .
on value-changed OF br-order IN FRAME d-order
    DO:
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then
        do:
            enable b-del with frame d-order .
        end.
        else disable b-del with frame d-order .
    END .
ON CHOOSE OF bt-no-sel-all IN FRAME d-order
    DO:
        define variable loc#log as logical no-undo .
        if available X_order then
        do:
            v-rid-list = "" .
            for each X_order no-lock:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid28 as character no-undo .
define variable v-num-entry28 as integer   no-undo .
assign
  v-str-recid28 = trim( string( recid( X_order ) , "->>>>>>>>>>>9":U ) )
  v-num-entry28 = lookup( v-str-recid28 , v-rid-list )
.
if v-num-entry28 > 0 then do:
  assign
    entry( v-num-entry28, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid28
  .
end.
                loc#log = br-order:refresh() .
            end.
        end.
        if num-entries( v-rid-list ) <> 0 then
        do:
            if num-entries (v-rid-list) > 1 then disable b-copy with frame d-order .
            display
                num-entries( v-rid-list ) @ mark-num
                with frame d-order.
        end.
    END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-order
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list = "" .
        loc#log = br-order:refresh() no-error .
        enable b-copy with frame d-order .
        hide mark-num in frame d-order.
    END.
ON VALUE-CHANGED OF c-status IN FRAME d-order
    DO:
        assign c-status .
        run init-sort .
    END.
ON VALUE-CHANGED OF statusNotif IN FRAME d-order
    DO:
        assign statusNotif .
        find first db-attr exclusive-lock where db-attr.db-num = v-cntxt-db-num and
            db-attr.attr-code = "orderStatusNitif" no-error .
        if not available (db-attr) then
        do:
            create db-attr .
            assign
                db-attr.db-num    = v-cntxt-db-num
                db-attr.attr-code = "orderStatusNitif"
                .
        end.
        db-attr.attr-value = string(statusNotif) .
    END.
ON LEAVE OF cli-code IN FRAME d-order
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.
ON RETURN OF cli-code IN FRAME d-order
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.
ON TAB OF cli-code IN FRAME d-order
    DO:
        define variable ref-list as character no-undo .
        define variable ref-rec  as integer   no-undo .
        v-cli = false .
        assign cli-code .
        run init-sort .
    END.
ON LEAVE OF cli-name IN FRAME d-order
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.
ON RETURN OF cli-name IN FRAME d-order
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.
ON TAB OF cli-name IN FRAME d-order
    DO:
        v-cli = false .
        assign cli-name .
        run init-sort .
    END.
ON return,LEAVE OF Date-End IN FRAME d-order
    DO:
        apply "TAB":U to self .
    END.
ON TAB OF Date-End IN FRAME d-order
    DO:
        date(Date-End:screen-value) no-error.
        if error-status:error then
        do:
            message "Ошибка ввода даты"
                view-as alert-box.
            display Date-End with frame d-order .
            return no-apply .
        end.
        if string(Date-End) <> Date-End:screen-value then
        do:
            if date(Date-End:screen-value) < Date-Start then
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .
            end.
            assign Date-End .
            display Date-End with frame d-order .
            if Date-Start <> ? then
            do:
                run init-sort .
            end.
        end.
    END.
ON return,LEAVE OF date-Start IN FRAME d-order
    DO:
        apply "TAB":U to self .
    END.
ON TAB OF date-Start IN FRAME d-order
    DO:
        date(Date-Start:screen-value) no-error.
        if error-status:error then
        do:
            message "Ошибка ввода даты"
                view-as alert-box.
            display Date-Start with frame d-order .
            return no-apply .
        end.
        if string(Date-Start) <> Date-Start:screen-value then
        do:
            if Date-End < date(Date-Start:screen-value) then
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .
            end.
            assign Date-Start .
            display Date-Start with frame d-order .
            if Date-End <> ? then
            do:
                run init-sort .
            end.
        end.
    END.
ON LEAVE,return,tab OF f-mark IN FRAME d-order
    DO:
        if f-mark = f-mark:screen-value
            then
            return .
        assign
            f-mark
            .
        f-mark:sensitive    = f-mark = "".
        b-markGoods:visible   = f-mark <> "".
        b-markGoods:sensitive = b-markGoods:visible.
        r-goods:sensitive = false .
        apply "entry" to b-markGoods IN FRAME d-order .
        run init-sort .
    END.
ON CHOOSE OF b-markGoods  IN FRAME d-order
    DO:
        f-mark:screen-value = "".
        assign
            f-mark
            .
        f-mark:sensitive    = f-mark = "".
        b-markGoods:visible   = f-mark <> "".
        b-markGoods:sensitive = b-markGoods:visible.
        r-goods:sensitive = true .
        apply "entry" to f-mark IN FRAME d-order .
        run init-sort .
    END.
ON leave OF num-contract IN FRAME d-order
    DO:
        apply "TAB":U to self .
    END.
ON RETURN OF num-contract IN FRAME d-order
    DO:
        apply "TAB":U to self .
    END.
ON TAB OF num-contract IN FRAME d-order
    DO:
        assign num-contract .
        run init-sort .
    END.
ON leave OF num-order IN FRAME d-order
    DO:
        apply "TAB":U to self .
    END.
ON RETURN OF num-order IN FRAME d-order
    DO:
        apply "TAB":U to self .
    END.
ON mouse-select-dblclick OF br-order IN FRAME d-order
    DO:
        if AVAILABLE (X_order) then
        do:
            if X_order.sts = StatusOrder:NewStatus:KeyIntDB then apply "Choose" to b-update in frame d-order.
            else    apply "Choose" to b-lookup in frame d-order.
        end.
    END.
ON TAB OF num-order IN FRAME d-order
    DO:
        assign num-order .
        run init-sort .
    END.
ON VALUE-CHANGED OF r-goods IN FRAME d-order
    DO:
        assign r-goods .
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-order:PARENT eq ?
    THEN FRAME d-order:PARENT = ACTIVE-WINDOW.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-order
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
on choose of b-help in frame d-order
do:
  apply "help":u to frame d-order .
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-order:width - 0.3
                fh            = frame d-order:first-child
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-order :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-order :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-order :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-order :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-order :height = v-frame-height
          .
          if frame d-order :scrollable = true
          then do:
            assign
              frame d-order :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-order :scrollable = true
          then do:
            assign
              frame d-order :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-order :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame d-order :height
      v-frame-virtual-height = frame d-order :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-order :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-order
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-order :scrollable = true
      then do:
        assign
          frame d-order :virtual-height = frame d-order :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-order :height = frame d-order :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-order :height = frame d-order :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-order :scrollable = true
      then do:
        assign
          frame d-order :virtual-height = frame d-order :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame d-order :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame d-order :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-order :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-order :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-order :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-order :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-order :width = v-frame-width
          .
          if frame d-order :scrollable = true
          then do:
            assign
              frame d-order :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-order :scrollable = true
          then do:
            assign
              frame d-order :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-order :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame d-order :width
      v-frame-virtual-width = frame d-order :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-order :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-order
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-order :scrollable = true
      then do:
        assign
          frame d-order :virtual-width = frame d-order :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-order :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame d-order :width = frame d-order :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-order :scrollable = true
      then do:
        assign
          frame d-order :virtual-width = frame d-order :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame d-order :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame d-order :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-order
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-order :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-order :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-order :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-order :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame d-order
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame d-order :height
      v-col-delta = v-new-col - frame d-order :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame d-order :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-order :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-order :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-order :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame d-order :width
      v-diasize-current-frame-height = frame d-order :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame d-order
    :
      assign
        v-diasize-orig-frame-height = frame d-order :height
        v-diasize-orig-frame-width  = frame d-order :width
        v-diasize-browse-handle     = browse br-order :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-order :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-Start in frame d-order
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
on delete-character of Date-Start in frame d-order
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
on ctrl-d of Date-Start in frame d-order
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
on ctrl-b of Date-Start in frame d-order
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
on ctrl-e of Date-Start in frame d-order
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
on ctrl-f of Date-Start in frame d-order
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
  define MENU m-ed-date33
    MENU-ITEM m-ed-date33-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date33-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date33-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date33-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Date-Start :POPUP-MENU in frame d-order = ?
  then do:
    ASSIGN
      Date-Start :POPUP-MENU in frame d-order = MENU m-ed-date33 :HANDLE
      Date-Start :MENU-MOUSE in frame d-order = 3
    .
  end.
  define variable v-label-handle33 as handle no-undo .
  assign
    v-label-handle33 = Date-Start :side-label-handle in frame d-order
  .
  if valid-handle (v-label-handle33)
  then do:
    if v-label-handle33 :tooltip = ""
    or v-label-handle33 :tooltip = ?
    then do:
      assign
        v-label-handle33 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date33-1 in menu m-ed-date33 DO:
    apply "ctrl-b":U to Date-Start in frame d-order .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-2 in menu m-ed-date33 DO:
    apply "ctrl-d":U to Date-Start in frame d-order .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-3 in menu m-ed-date33 DO:
    apply "ctrl-e":U to Date-Start in frame d-order .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-4 in menu m-ed-date33 DO:
    apply "ctrl-f":U to Date-Start in frame d-order .
  END.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-End in frame d-order
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
on delete-character of Date-End in frame d-order
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
on ctrl-d of Date-End in frame d-order
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
on ctrl-b of Date-End in frame d-order
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
on ctrl-e of Date-End in frame d-order
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
on ctrl-f of Date-End in frame d-order
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
  define MENU m-ed-date35
    MENU-ITEM m-ed-date35-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date35-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date35-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date35-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Date-End :POPUP-MENU in frame d-order = ?
  then do:
    ASSIGN
      Date-End :POPUP-MENU in frame d-order = MENU m-ed-date35 :HANDLE
      Date-End :MENU-MOUSE in frame d-order = 3
    .
  end.
  define variable v-label-handle35 as handle no-undo .
  assign
    v-label-handle35 = Date-End :side-label-handle in frame d-order
  .
  if valid-handle (v-label-handle35)
  then do:
    if v-label-handle35 :tooltip = ""
    or v-label-handle35 :tooltip = ?
    then do:
      assign
        v-label-handle35 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date35-1 in menu m-ed-date35 DO:
    apply "ctrl-b":U to Date-End in frame d-order .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-2 in menu m-ed-date35 DO:
    apply "ctrl-d":U to Date-End in frame d-order .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-3 in menu m-ed-date35 DO:
    apply "ctrl-e":U to Date-End in frame d-order .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-4 in menu m-ed-date35 DO:
    apply "ctrl-f":U to Date-End in frame d-order .
  END.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-order :SET-REPOSITIONED-ROW(9, "CONDITIONAL") .
end.
find first db-attr no-lock where db-attr.db-num = v-cntxt-db-num and
    db-attr.attr-code = "orderStatusNitif" no-error .
if not available (db-attr) then statusNotif = true .
else statusNotif = logical (db-attr.attr-value) .
StatusOrder =  new ibs.th.str.order.sts.order().
Date-Start = today - 14 .
Date-End = today .
for each buf_order exclusive-lock where buf_order.obj-code = v-cntxt-obj-code and
    buf_order.obj-type = v-cntxt-obj-type and
    buf_order.db-num = v-cntxt-db-num and
    buf_order.sts = StatusOrder:NewStatus:KeyIntDB and
    buf_order.doc-date < datetime (today - 1):
    delete buf_order .
end.
for each buf_order no-lock where buf_order.obj-code = v-cntxt-obj-code and
    buf_order.obj-type = v-cntxt-obj-type and
    buf_order.db-num = v-cntxt-db-num:
    create X_order .
    buffer-copy buf_order to X_order .
end.
extent (bcol) = ?.
hbrowse = browse br-order:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).
    bcol[ii] = hbrowse:get-browse-column (ii).
end.
run init-temp .
RUN enable_UI.
run init-sort .
WAIT-FOR GO OF FRAME d-order.
END.
RUN disable_UI.
PROCEDURE init-temp :
    define variable ii         as integer   no-undo .
    define variable Status_    as character no-undo .
    define variable Status_EDI as character no-undo .
    define variable Edoc_type  as character no-undo .
    Status_ = "Все" + chr(44) + '-1':U .
    do ii = 1 to StatusOrder:mapType:GetItemByLab(ii):
        if StatusOrder:CurrProp:KeyIntDB >= 50
            and StatusOrder:CurrProp:KeyIntDB < 60
            then next .
        Status_ = Status_ + chr(44) + StatusOrder:CurrProp:Label_ + chr(44) + string(StatusOrder:CurrProp:KeyIntDB) .
    end.
    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame d-order = Status_ .
    c-status = "-1" .
END PROCEDURE.
PROCEDURE disable_UI :
    HIDE FRAME d-order.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY date-Start Date-End c-status cli-code cli-type cli-name num-order
        num-contract r-goods f-mark mark-num statusNotif
        WITH FRAME d-order.
    ENABLE b-exit b-add b-update b-lookup b-copy b-del b-send b-reset b-sch
        b-help b-hist b-date-Start date-Start Date-End b-date-End c-status statusNotif
        b-cli cli-code cli-type cli-name num-order num-contract r-goods b-mark
        f-mark b-markGoods br-order mark-num bt-not-sel-desel-all bt-no-sel-all
        WITH FRAME d-order.
    hide b-markGoods b-sch b-sel in frame d-order .
    VIEW FRAME d-order.
    OPEN QUERY br-order FOR EACH X_order no-lock by X_order.doc-code desc INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init-sort :
    define variable vInt      as logical   no-undo.
    define variable vi        as integer   no-undo.
    define variable vGdsCode  as integer   no-undo.
    define variable vGtin     as character no-undo.
    define variable vMark     as character no-undo.
    define variable vMarkGtin as character no-undo.
    define variable vGdsName  as character no-undo .
    define variable vOkGoods  as logical   no-undo .
    define variable vDbNumCur as integer   no-undo.
    define variable vCodeCur  as integer   no-undo.
    define buffer goods       for ub.goods.
    define buffer bar-code    for ub.bar-code.
    define buffer prod-bc     for ub.prod-bc.
    define buffer marking     for ub.marking .
    define buffer order-line  for ub.order-line .
    define buffer buf_X_order for X_order .
    if avail X_order then
        assign
            vDbNumCur = X_order.db-num
            vCodeCur  = X_order.doc-code
            .
    for each X_order:
        delete X_order .
    end.
    mark-num = 0.
    display mark-num with frame d-order.
    hide mark-num in frame d-order.
    for each buf_order no-lock where buf_order.obj-code = v-cntxt-obj-code and
        buf_order.obj-type = v-cntxt-obj-type and
        buf_order.db-num = v-cntxt-db-num:
        create X_order .
        buffer-copy buf_order to X_order .
    end.
    if f-mark <> "" then
    do:
        case r-goods:
            when 0 then
                do:
                    int(f-mark) no-error.
                    vInt = not error-status:error.
                    if vInt
                        then
                        find first goods where goods.gds-code eq int(f-mark) no-lock no-error.
                    if available goods
                        then
                    do:
                        vGdsCode  = goods.gds-code.
                    end.
                    else
                    do:
                        if vInt
                            then
                            find first bar-code where bar-code.b-code eq int(f-mark) no-lock no-error.
                        if available bar-code
                            then
                        do:
                            vGdsCode  = bar-code.gds-code.
                        end.
                        else
                        do:
                            block-fill:
                            do vi = 0 to 10:
                                find first prod-bc where prod-bc.b-str eq fill("0",vi) + f-mark no-lock no-error.
                                if available prod-bc
                                    then
                                    leave block-fill.
                            end.
                            if available prod-bc
                                then
                            do:
                                if prod-bc.bc-on-type = 'GTIN':U
                                    then
                                    vGdsCode = prod-bc.b-code.
                                else
                                do:
                                    find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
                                    if available bar-code
                                        then
                                        vGdsCode  = bar-code.gds-code.
                                end.
                            end.
                            else
                            do:
                                vMark     = getcodeident(f-mark).
                                vMarkGtin = getGtinByDM (f-mark).
                                if vMark = ? and vMarkGtin = "" then
                                do:
                                    for each X_order:
                                        delete X_order .
                                    end.
                                end.
                            end.
                        end.
                    end.
                end.
            otherwise
            do:
                vGdsName = prep-nameorcode(f-mark) .
            end.
        end case .
    end.
    if vMark <> ""
        then
    do:
        find first marking where marking.mark     begins vMark
            no-lock no-error.
        if not available marking
            then
            find first marking where marking.mark     begins "02" + vMarkGtin + "37"
                no-lock no-error.
        if available marking
            then
        do :
            vGdsCode = marking.gds-code .
        end .
    end.
    if vGdsCode <> 0 then
    do:
        for each X_order:
            find first order-line where order-line.db-num  = X_order.db-num
                and order-line.doc-code   = X_order.doc-code
                and order-line.gds-code = vGdsCode
                no-lock no-error.
            if available (order-line) then next .
            else delete X_order .
        end.
    end.
    if vGdsName <> "" then
    do:
        for each X_order:
            vOkGoods = false .
            for each order-line where order-line.db-num  = X_order.db-num
                and order-line.doc-code   = X_order.doc-code no-lock,
                first goods where goods.gds-code = order-line.gds-code and
                goods.gds-name contains vGdsName no-lock :
                vOkGoods = true .
                leave .
            end.
            if not vOkGoods then delete X_order .
        end.
    end.
    if num-contract <> "" then
    do:
        for each X_order :
            if X_order.contract-prn-code begins num-contract then next .
            else delete X_order .
        end.
    end.
    if c-status <> "-1" then
    do:
        for each X_order where X_order.sts <> integer(c-status):
            delete X_order .
        end.
    end.
    if date-Start <> ? and Date-End <> ? then
    do:
        for each X_order where date-Start > date(X_order.doc-date) or Date-End < date(X_order.doc-date):
            delete X_order .
        end.
    end.
    if v-cli then
    do:
        for each X_order where X_order.cli-code <> integer(cli-code) and X_order.cli-type = cli-type :
            delete X_order .
        end.
    end.
    else
    do:
        if cli-code <> "" then
        do:
            for each X_order where X_order.cli-code <> integer(cli-code):
                delete X_order .
            end.
        end.
        if cli-name <> "" then
        do:
            for each X_order :
                if X_order.cli-name begins cli-name then next .
                else delete X_order .
            end.
        end.
    end.
    if num-order <> "" then
    do:
        for each X_order:
            if string(X_order.order-item) begins num-order then next .
            else delete X_order .
        end.
    end.
    v-cli = false .
    apply "CHOOSE":U to bt-not-sel-desel-all IN FRAME d-order.
    OPEN QUERY br-order FOR EACH X_order no-lock by X_order.doc-code desc INDEXED-REPOSITION.
    br-order:refresh () in frame d-order no-error .
    if vCodeCur <> 0 then
        find first buf_X_order no-lock where
            buf_X_order.db-num   = vDbNumCur
            and buf_X_order.doc-code = vCodeCur
            no-error.
    if avail buf_X_order then do:
        reposition br-order to rowid rowid(buf_X_order).
        if buf_X_order.sts = StatusOrder:NewStatus:KeyIntDB then
        do:
            enable b-del with frame d-order .
        end.
        else disable b-del with frame d-order .
    end .
    else do:
        reposition br-order to row 1.
        enable b-del with frame d-order .
    end.
END PROCEDURE.
FUNCTION cli-name RETURNS character
    (cli-code as integer, cli-type as character ):
    define variable v-cli-name as character no-undo.
    find first ub.clients no-lock where ub.clients.obj-code = cli-code and
        ub.clients.obj-type = cli-type no-error .
    if available (ub.clients) then
    do:
        v-cli-name = ub.clients.obj-name .
    end.
    return v-cli-name.
end function.
FUNCTION get-sts RETURNS character
    (p-sts as integer ):
    define variable v-sts as character no-undo.
    v-sts = StatusOrder:GetLabel(p-sts) .
    return v-sts.
end function.
FUNCTION num-doc RETURNS character
    (p-doc-code as integer, p-db-num as integer):
    return string(p-doc-code).
end function.
FUNCTION user-name RETURNS character
    (p-user-id as character ):
    define variable v-user-name as character no-undo.
    find first ub.user-account no-lock where ub.user-account.user-id = p-user-id no-error .
    if available (ub.user-account) then
    do:
        v-user-name = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
    end.
    return v-user-name.
end function.
FUNCTION prep-nameorcode RETURNS CHARACTER
    ( input p-nameorcode as character ) :
    define variable v-nameorcode as character no-undo .
    define variable nameorcode   as character no-undo .
    if trim(p-nameorcode) = '' then  return ''.
    v-nameorcode = trim( trim( p-NameOrCode) , "*" ) .
    if index(v-NameOrCode, chr(34) ,1 ) = 1
        and R-index(v-NameOrCode, chr(34) ,1 ) = 1 then
    do:
        assign
            v-NameOrCode = trim(v-NameOrCode, chr(34))
            .
        nameorcode = v-nameorcode.
    end.
    define variable v-dopi as character no-undo .
    assign
        v-dopi = substring(v-NameOrCode, length(v-NameOrCode), 1)
        .
    if index("abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъыьэюя", v-dopi) > 0
        or index("1234567890", v-dopi) > 0
        then
    do:
        v-NameOrCode = v-NameOrCOde + "*".
    end.
    v-NameOrCode = LC(v-NameOrCode).
    RETURN v-nameorcode.
END FUNCTION.
