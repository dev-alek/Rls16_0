define input  parameter parParentProc  as widget-handle no-undo.
define input parameter p-title as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма настройки печати списка документов    ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
DEFINE new shared TEMP-TABLE wt-docs no-undo
  field ext-doc-type as character
  FIELD acc-date    AS DATE      COLUMN-LABEL "Дата проводки"
  FIELD agnt        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Исполнитель"
  FIELD base-rate   AS DECIMAL   FORMAT ">>,>>9.99" COLUMN-LABEL "Курс"
  FIELD base-scale  AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Масштаб"
  FIELD boss        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Менеджер"
  FIELD cli-code    AS INTEGER   FORMAT "99999" COLUMN-LABEL "Код"
  FIELD cli-name    AS CHARACTER FORMAT "X(40)" COLUMN-LABEL "Контрагент"
  FIELD cli-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент"
  FIELD creid       AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Создал"
  FIELD ctr-num     AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент! !"
  FIELD discnt-pc   AS DECIMAL   FORMAT "->9.9%" COLUMN-LABEL "Скидка"
  FIELD discnt-rubl AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка"
  FIELD discnt-type AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Скидка"
  FIELD doc-code    AS CHARACTER FORMAT "X(14)" COLUMN-LABEL "Номер"
  FIELD doc-date    AS DATE      COLUMN-LABEL "Дата"
  FIELD doc-qnty    AS DECIMAL   FORMAT "->>,>>>,>>9.<<<" COLUMN-LABEL "Заявлено"
  FIELD doc-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Тип"
  FIELD exch-code   AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Валюта"
  FIELD exch-date   AS DATE      COLUMN-LABEL "Таможня"
  FIELD exch-rate   AS DECIMAL   FORMAT ">>,>>9.99"
  COLUMN-LABEL "Курс"
  FIELD exch-scale  AS INTEGER   FORMAT ">>9"
  COLUMN-LABEL "Масштаб"
  FIELD fact-base   AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD fact-date   AS DATE
  COLUMN-LABEL "факт"
  FIELD fact-num    AS INTEGER
  FIELD fact-qnty   AS DECIMAL   FORMAT "->>,>>>,>>9.<<<"
  COLUMN-LABEL "Фактически"
  FIELD fact-rubl   AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD flag_       AS LOGICAL   COLUMN-LABEL "Закр"
  FIELD internal    AS LOGICAL   COLUMN-LABEL "Внутр"
  FIELD inv-num     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Инвойс"
  FIELD obj-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Код"
  FIELD obj-type    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "ПО ОБЪЕКТАМ"
  FIELD office      AS LOGICAL
  FIELD ord-num     AS CHAR FORMAT "x(14)"
  COLUMN-LABEL "заказ"
  FIELD out-code    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Номер РН"
  FIELD ov          AS LOGICAL   FORMAT "+/-"
  COLUMN-LABEL "Акт переоценки"
  FIELD pay-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Оплата"
  FIELD print-rubl  AS LOGICAL
  COLUMN-LABEL "Рублевая"
  FIELD PS          AS CHARACTER FORMAT "X(50)"
  COLUMN-LABEL "Примечание"
  FIELD ship-date   AS DATE      COLUMN-LABEL "Дата"
  FIELD ship-num    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Отгрузка"
  FIELD status_     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "статус"
  FIELD tot-calc    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "Расчет"
  FIELD tot-cli     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По ТТН"
  FIELD tot-doc     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-fact    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD tot-ov      AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По акту"
  FIELD tot-rubl    AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-sale    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD wrkr        AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Кладовщик"
  FIELD host-code AS INTEGER   FORMAT "99999" COLUMN-LABEL "Фирма"
    field vat-type      as character
    field vat-base      as decimal
    field vat-rubl      as decimal
    field vat18-base    as decimal
    field vat18-rubl    as decimal
    field vat10-base    as decimal
    field vat10-rubl    as decimal
    field vat-on        as logical
    field doc-attr      as character
    field OurObjectName like ub.clients.obj-name
    field pay-name      like ub.pay-type.obj-name
    field Oper_Name     as character
    field Mngr_Name     as character
    field Wrkr_name     as character
    field Course        as decimal
    field pay-waitdate  as date
    field Isp-Name      as character
    field SLT-base      like ub.trn-doc.SLT-base
    field SLT-rubl      like ub.trn-doc.SLT-rubl
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define buffer buf_rep_currency for ub.currency.
define variable v-cntxt-host-name-obj as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
run get-report-num  in parParentProc ( output g#report-num ).
run get-gds-engl   in parParentProc ( output g#gds-engl ) .
DEFINE SHARED BUFFER t-doc FOR trn-doc.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table doc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define shared buffer temp-trn-doc for doc-list  .
define shared query br-docs for t-doc except  , temp-trn-doc scrolling.
define variable v-ind           as integer   no-undo .
define variable Log-Res1         as logical   no-undo .
define variable Log-Res2         as logical   no-undo .
define buffer object for clients .
define variable v-continue as logical   no-undo .
assign
  v-continue = true
.
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "В&ыход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE RubText AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rublevye_allshift :"
      VIEW-AS TEXT
     SIZE 12.88 BY .83
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE SumText AS CHARACTER FORMAT "X(256)":U INITIAL "Суммы"
      VIEW-AS TEXT
     SIZE 7.88 BY .83 NO-UNDO.
DEFINE VARIABLE ValText AS CHARACTER FORMAT "X(256)":U INITIAL "ВАЛЮТНЫЕ :"
      VIEW-AS TEXT
     SIZE 12.88 BY .83
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE IMAGE-1
     FILENAME "cmp/blank":U
     SIZE 34.13 BY 7.29.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 36.25 BY 7.75.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 35.63 BY 7.75.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 72 BY 5.75.
DEFINE VARIABLE Discnt-PC AS LOGICAL INITIAL no
     LABEL "Процент скидки"
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.
DEFINE VARIABLE IspName AS LOGICAL INITIAL no
     LABEL "Исполнитель"
     VIEW-AS TOGGLE-BOX
     SIZE 21.63 BY .75 NO-UNDO.
DEFINE VARIABLE Kladov AS LOGICAL INITIAL no
     LABEL "Кладовщик"
     VIEW-AS TOGGLE-BOX
     SIZE 14.63 BY .75 NO-UNDO.
DEFINE VARIABLE Kurs AS LOGICAL INITIAL no
     LABEL "Курс"
     VIEW-AS TOGGLE-BOX
     SIZE 8.63 BY .75 NO-UNDO.
DEFINE VARIABLE NDS-Rubl AS LOGICAL INITIAL no
     LABEL "НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 8.63 BY .75 NO-UNDO.
DEFINE VARIABLE NDS-Val AS LOGICAL INITIAL no
     LABEL "НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 8 BY .75 NO-UNDO.
DEFINE VARIABLE Nums AS LOGICAL INITIAL no
     LABEL "Количество"
     VIEW-AS TOGGLE-BOX
     SIZE 16.38 BY .75 NO-UNDO.
DEFINE VARIABLE Operator AS LOGICAL INITIAL no
     LABEL "Оператор"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .75 NO-UNDO.
DEFINE VARIABLE Our-Obj AS LOGICAL INITIAL no
     LABEL "Название своего объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 29.25 BY .75 NO-UNDO.
DEFINE VARIABLE PayType AS LOGICAL INITIAL no
     LABEL "Вид оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 19.25 BY .75 NO-UNDO.
DEFINE VARIABLE Rubl-BruttoSaleSum AS LOGICAL INITIAL no
     LABEL "Цен документа ( без скидки )"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.
DEFINE VARIABLE Rubl-CostSum AS LOGICAL INITIAL no
     LABEL "Учетных цен"
     VIEW-AS TOGGLE-BOX
     SIZE 17.25 BY .75 NO-UNDO.
DEFINE VARIABLE Rubl-DiscntSum AS LOGICAL INITIAL no
     LABEL "Скидок"
     VIEW-AS TOGGLE-BOX
     SIZE 10.63 BY .75 NO-UNDO.
DEFINE VARIABLE Rubl-Effect AS LOGICAL INITIAL no
     LABEL "Эффективности"
     VIEW-AS TOGGLE-BOX
     SIZE 20.88 BY .75 NO-UNDO.
DEFINE VARIABLE Rubl-NettoSaleSum AS LOGICAL INITIAL no
     LABEL "Цен документа ( со скидкой )"
     VIEW-AS TOGGLE-BOX
     SIZE 31.38 BY .75 NO-UNDO.
DEFINE VARIABLE TorgPred AS LOGICAL INITIAL no
     LABEL "Торговый представитель"
     VIEW-AS TOGGLE-BOX
     SIZE 27.13 BY .75 NO-UNDO.
DEFINE VARIABLE Up-PC AS LOGICAL INITIAL no
     LABEL "Процент фактической наценки"
     VIEW-AS TOGGLE-BOX
     SIZE 33.63 BY .75 NO-UNDO.
DEFINE VARIABLE Val-BruttoSaleSum AS LOGICAL INITIAL no
     LABEL "Цен документа ( без скидки )"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.
DEFINE VARIABLE Val-CostSum AS LOGICAL INITIAL no
     LABEL "Учетных цен"
     VIEW-AS TOGGLE-BOX
     SIZE 18.63 BY .75 NO-UNDO.
DEFINE VARIABLE Val-DiscntSum AS LOGICAL INITIAL no
     LABEL "Скидок"
     VIEW-AS TOGGLE-BOX
     SIZE 10.63 BY .75 NO-UNDO.
DEFINE VARIABLE Val-Effect AS LOGICAL INITIAL no
     LABEL "Эффективности"
     VIEW-AS TOGGLE-BOX
     SIZE 20.75 BY .75 NO-UNDO.
DEFINE VARIABLE Val-NettoSaleSum AS LOGICAL INITIAL yes
     LABEL "Цен документа ( со скидкой )"
     VIEW-AS TOGGLE-BOX
     SIZE 31.38 BY .75 NO-UNDO.
DEFINE FRAME DLGOKCAN
     Rubl-BruttoSaleSum AT ROW 2.71 COL 40.88
     Val-BruttoSaleSum AT ROW 2.75 COL 4.63
     Rubl-NettoSaleSum AT ROW 3.71 COL 40.88
     Val-NettoSaleSum AT ROW 3.75 COL 4.63
     Rubl-DiscntSum AT ROW 4.71 COL 40.88
     Val-DiscntSum AT ROW 4.75 COL 4.63
     Rubl-CostSum AT ROW 5.71 COL 40.88
     Val-CostSum AT ROW 5.75 COL 4.63
     Rubl-Effect AT ROW 6.71 COL 40.88
     Val-Effect AT ROW 6.75 COL 4.63
     NDS-Rubl AT ROW 7.71 COL 40.88
     NDS-Val AT ROW 7.75 COL 4.63
     Discnt-PC AT ROW 10 COL 4.75
     TorgPred AT ROW 10.04 COL 41.13
     Up-PC AT ROW 11 COL 4.75
     Operator AT ROW 11.04 COL 41.13
     PayType AT ROW 12 COL 4.75
     Kladov AT ROW 12.04 COL 41.13
     Kurs AT ROW 13 COL 4.75
     IspName AT ROW 13.04 COL 41.13
     Nums AT ROW 13.96 COL 4.63
     Our-Obj AT ROW 14.04 COL 41.13
     Btn_OK AT ROW 15.71 COL 25.88
     b-help AT ROW 15.71 COL 36.25
     Btn_Cancel AT ROW 15.75 COL 15.38
     ValText AT ROW 1.63 COL 14.75 COLON-ALIGNED NO-LABEL
     SumText AT ROW 1.63 COL 41.88 COLON-ALIGNED NO-LABEL
     RubText AT ROW 1.63 COL 51.13 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 1.21 COL 2.38
     RECT-2 AT ROW 1.21 COL 38.88
     IMAGE-1 AT ROW 1.42 COL 39.63
     "Суммы" VIEW-AS TEXT
          SIZE 7 BY .83 AT ROW 1.63 COL 8.88
          FGCOLOR 0
     RECT-4 AT ROW 9.42 COL 2.5
     SPACE(1.62) SKIP(3.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Параметры отчета по документам":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.
ON CHOOSE OF Btn_Cancel IN FRAME DLGOKCAN
DO:
    return "NO" .
END.
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN
DO:
  define variable CurrWidth as integer no-undo .
  define variable var-frame-width as integer no-undo .
  assign
    Nums
    Val-BruttoSaleSum
    Rubl-BruttoSaleSum
    Val-NettoSaleSum
    Rubl-NettoSaleSum
    Val-DiscntSum
    Rubl-DiscntSum
    Val-CostSum
    Rubl-CostSum
    Val-Effect
    Rubl-Effect
    Discnt-PC
    TorgPred
    Up-PC
    Operator
    PayType
    Kladov
    Kurs
    Our-Obj
    IspName
    NDS-Val
    NDS-Rubl
  .
    run waitfram-show in this-procedure  ( "Обработка документов" ) .
    if not can-find( first wt-docs ) then do:
        DO WHILE available t-doc :
            GET prev br-docs.
        END.
        assign
          v-ind = 0
        .
        GET next br-docs.
        DO WHILE available t-doc :
            FIND pay-type NO-LOCK
              WHERE pay-type.obj-code = t-doc.pay-code no-error
              .
            FIND Object NO-LOCK
              WHERE Object.obj-type = t-doc.obj-type
                AND Object.obj-code = t-doc.obj-code
              .
            CREATE wt-docs .
            BUFFER-COPY t-doc TO wt-docs.
            assign
              wt-docs.doc-attr = ( substr( t-doc.doc-type, 1, 1 ) +
                              substr( t-doc.status_ , 1, 1 ) +
                              ( if t-doc.flag_    then "+" else "-" ) +
                              ( if t-doc.internal     then "в" else " " ) )
              wt-docs.pay-name = if not available pay-type then string(t-doc.pay-code) else pay-type.obj-name
              wt-docs.pay-waitdate = wt-docs.fact-date
              wt-docs.Oper_Name = t-doc.creid
              wt-docs.OurObjectName = Object.obj-name
            .
            if base-code <> 0 then
                wt-docs.Course = t-doc.base-rate / t-doc.base-scale .
            run rep/get-psn.p ( input t-doc.boss, output wt-docs.Mngr_Name) .
            run rep/get-psn.p ( input t-doc.wrkr, output wt-docs.Wrkr_name) .
            run rep/get-psn.p ( input t-doc.agnt, output wt-docs.Isp-Name ) .
            assign
              v-ind = v-ind + 1
            .
            if ( v-ind modulo 10 ) = 0
            then do:
              run waitfram-show in this-procedure  ( "Обработка документов : " + string( v-ind ) ) .
            end.
            if v-ind modulo 1000 = 0
            and v-continue <> ?
            then do:
              message
                "Уже распечатано строк" v-ind skip
                "Вы желаете продолжить формирование отчета?" skip
                "Yes"    chr(9) "Продолжить формирование отчета" skip
                "No"     chr(9) "Прервать отчет" skip
                "Cancel" chr(9) "Продолжить формирование отчета" skip
                ""       chr(9) "и больше не показывать это сообщение" skip
                view-as alert-box question buttons yes-no-cancel update v-continue .
              if v-continue = false then do:
                leave .
              end.
            end.
            get next br-docs.
        end.
    end.
    run waitfram-hide in this-procedure  .
    run rep/docsrepo.p
      (input  "Отчет по документам. " + p-title
      ,input  Val-BruttoSaleSum
      ,input  Rubl-BruttoSaleSum
      ,input  Val-NettoSaleSum
      ,input  Rubl-NettoSaleSum
      ,input  Val-DiscntSum
      ,input  Rubl-DiscntSum
      ,input  Val-CostSum
      ,input  Rubl-CostSum
      ,input  Val-Effect
      ,input  Rubl-Effect
      ,input  Discnt-PC
      ,input  TorgPred
      ,input  Up-PC
      ,input  Operator
      ,input  PayType
      ,input  Kurs
      ,input  Our-Obj
      ,input  Kladov
      ,input  IspName
      ,input  no
      ,input  NDS-Val
      ,input  NDS-Rubl
      ,input  Nums
      ,input  v-continue
      ,input  g#report-num
      ,output var-frame-width
      ).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.
    if base-code = 0 then do:
      HIDE
        SumText RubText ValText Rubl-BruttoSaleSum
        Rubl-NettoSaleSum Rubl-DiscntSum
        Rubl-CostSum Rubl-Effect NDS-Rubl
        in frame DLGOKCAN .
    end.
    else do:
      HIDE IMAGE-1    in frame DLGOKCAN .
    end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_document-reports-sale_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res1
    )  .
end.
    if not Log-Res1 then do:
      DISABLE
        Nums Val-BruttoSaleSum Rubl-BruttoSaleSum Val-NettoSaleSum
        Rubl-NettoSaleSum Val-DiscntSum Rubl-DiscntSum
        Discnt-PC TorgPred Up-PC Operator
        PayType Kladov Kurs Our-Obj IspName
        WITH FRAME DLGOKCAN.
    end.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_document-reports-cost_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res2
    )  .
end.
    if not Log-Res2 then do:
      DISABLE
        Rubl-CostSum Val-CostSum Val-Effect Rubl-Effect
        WITH FRAME DLGOKCAN.
    end.
    if not ( Log-Res1 OR Log-Res2 ) then do:
      message
        "У Вас недостаточно ПРАВ" skip
        "для выполнения данного действия." skip
        "Обратитесь к администратору системы."
        view-as alert-box error.
      LEAVE MAIN-BLOCK .
    end.
    if num-results( "br-docs" ) = 0 then do:
      message "Список П У С Т !" view-as alert-box information .
      LEAVE MAIN-BLOCK .
    end.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  ASSIGN
    RubText = "РУБЛЕВЫЕ :"
  .
  DISPLAY Rubl-BruttoSaleSum Val-BruttoSaleSum Rubl-NettoSaleSum
          Val-NettoSaleSum Rubl-DiscntSum Val-DiscntSum Rubl-CostSum Val-CostSum
          Rubl-Effect Val-Effect NDS-Rubl NDS-Val Discnt-PC TorgPred Up-PC
          Operator PayType Kladov Kurs IspName Nums Our-Obj ValText SumText
          RubText
      WITH FRAME DLGOKCAN.
  ENABLE RECT-1 RECT-2 IMAGE-1 Rubl-BruttoSaleSum Val-BruttoSaleSum
         Rubl-NettoSaleSum Val-NettoSaleSum Rubl-DiscntSum Val-DiscntSum
         Rubl-CostSum Val-CostSum Rubl-Effect Val-Effect NDS-Rubl NDS-Val
         RECT-4 Discnt-PC TorgPred Up-PC Operator PayType Kladov Kurs IspName
         Nums Our-Obj Btn_OK b-help Btn_Cancel ValText SumText RubText
      WITH FRAME DLGOKCAN.
END PROCEDURE.
