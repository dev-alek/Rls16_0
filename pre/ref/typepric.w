DEFINE NEW SHARED BUFFER buf_price-list-type FOR price-list-type.
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns as character no-undo .
define input-output parameter  p-rec-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник Типов прайс-листов".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
DEFINE TEMP-TABLE TT_cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE TT_grp   NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE TT_pay-type NO-UNDO LIKE ub.price-list-type-pay-type.
DEFINE TEMP-TABLE TT_cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.
PROCEDURE type-price-list-ADD :
define input  parameter p-db-num                       as integer   no-undo .
define input  parameter p-id                           as integer   no-undo .
define input  parameter p-name                         as character no-undo .
define input  parameter p-ban-discnt                   like   ub.price-list-type.ban-discnt          no-undo .
define input  parameter p-calc-round-method            like   ub.price-list-type.calc-round-method    no-undo .
define input  parameter p-calc-round-base              like   ub.price-list-type.calc-round-base      no-undo .
define input  parameter p-calc-increase-pc             like   ub.price-list-type.calc-increase-pc     no-undo .
define input  parameter p-calc-method                  like   ub.price-list-type.calc-method          no-undo .
define input  parameter p-create-price-doc             like   ub.price-list-type.create-price-doc     no-undo .
define input  parameter p-fix-cource-crc-base          like   ub.price-list-type.fix-cource-crc-base  no-undo .
define input  parameter p-fix-cource-crc-doc           like   ub.price-list-type.fix-cource-crc-doc   no-undo .
define input  parameter p-have-rs-qnty-group           like   ub.price-list-type.have-rs-qnty-group   no-undo .
define input  parameter p-have-rs-sum-group            like   ub.price-list-type.have-rs-sum-group    no-undo .
define input  parameter p-main                         like   ub.price-list-type.main                 no-undo .
define input  parameter p-only-gbd                     like   ub.price-list-type.only-gbd             no-undo .
define input  parameter p-plt-main-db-num              like   ub.price-list-type.plt-main-db-num      no-undo .
define input  parameter p-plt-main-id                  like   ub.price-list-type.plt-main-id          no-undo .
define input  parameter p-priority                     like   ub.price-list-type.priority             no-undo .
define input  parameter p-rs-buyer                     like   ub.price-list-type.rs-buyer             no-undo .
define input  parameter p-send-cassa                   like   ub.price-list-type.send-cassa           no-undo .
define input  parameter p-under-hand-corr              like   ub.price-list-type.under-hand-corr      no-undo .
define input  parameter p-under-round-method           like   ub.price-list-type.under-round-method         no-undo .
define input  parameter p-under-perc                   like   ub.price-list-type.under-perc           no-undo .
define input  parameter p-under-type-list              like   ub.price-list-type.under-type-list      no-undo .
define input  parameter p-use-cassa                    like   ub.price-list-type.use-cassa            no-undo .
define input  parameter p-use-gds-group                like   ub.price-list-type.use-gds-group        no-undo .
define input  parameter p-use-obj                      like   ub.price-list-type.use-obj              no-undo .
define input  parameter p-work-date                    like   ub.price-list-type.work-date            no-undo .
define input  parameter p-bgr-db-num                   like   ub.price-list-type.bgr-db-num           no-undo .
define input  parameter p-bgr-id                       like   ub.price-list-type.bgr-id               no-undo .
define input  parameter p-curr-code                    like   ub.price-list-type.curr-code            no-undo .
define input  parameter p-gop-db-num                   like   ub.price-list-type.gop-db-num           no-undo .
define input  parameter p-gop-db-num-for-calc-turnover like   ub.price-list-type.gop-db-num-for-calc-turnover  no-undo .
define input  parameter p-gop-id                       like   ub.price-list-type.gop-id                        no-undo .
define input  parameter p-gop-id-for-calc-turnover     like   ub.price-list-type.gop-id-for-calc-turnover      no-undo .
define input  parameter p-qgr-db-num                   like   ub.price-list-type.qgr-db-num                    no-undo .
define input  parameter p-qgr-id                       like   ub.price-list-type.qgr-id                        no-undo .
define input  parameter p-sgr-db-num                   like   ub.price-list-type.sgr-db-num                    no-undo .
define input  parameter p-sgr-id                       like   ub.price-list-type.sgr-id                        no-undo .
define input  parameter p-tog-db-num                   like   ub.price-list-type.tog-db-num                    no-undo .
define input  parameter p-tog-id                       like   ub.price-list-type.tog-id                        no-undo .
define input  parameter p-obj-turnover                 like   ub.price-list-type.obj-turnover                  no-undo .
define input  parameter p-ttg-summa                    like   ub.price-list-type.ttg-summa                     no-undo .
define input  parameter p-userid                       as character no-undo .
define input  parameter p-db-num-usr                   as integer   no-undo .
define input  parameter p-have-rs-turn-group           like   ub.price-list-type.have-rs-turn-group no-undo .
define input  parameter p-have-tog-db-num              like   ub.price-list-type.have-tog-db-num    no-undo .
define input  parameter p-have-tog-id                  like   ub.price-list-type.have-tog-id        no-undo .
define input  parameter p-use-cash-pay                 like   ub.price-list-type.use-cash-pay no-undo .
define input  parameter p-use-pay-type                 like   ub.price-list-type.use-pay-type no-undo .
define output parameter p-recid                        as recid no-undo .
define input  parameter table for tt_cassa .
define input  parameter table for tt_grp   .
define input  parameter table for tt_pay-type .
define input  parameter table for tt_cash-pay .
define variable v-text as character no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
if p-plt-main-id                     = ? then p-plt-main-id = 0 .
if p-bgr-id                          = ? then p-bgr-id                        = 0 .
if p-gop-id                          = ? then p-gop-id                        = 0 .
if p-gop-id-for-calc-turnover        = ? then p-gop-id-for-calc-turnover      = 0 .
if p-qgr-db-num                      = ? then p-qgr-db-num                    = 0 .
if p-qgr-id                          = ? then p-qgr-id                        = 0 .
if p-sgr-db-num                      = ? then p-sgr-db-num                    = 0 .
if p-sgr-id                          = ? then p-sgr-id                        = 0 .
if p-tog-db-num                      = ? then p-tog-db-num                    = 0 .
if p-tog-id                          = ? then p-tog-id                        = 0 .
if p-gop-db-num                      = ? then p-gop-db-num                    = 0 .
if p-gop-db-num-for-calc-turnover    = ? then p-gop-db-num-for-calc-turnover  = 0 .
if p-have-tog-db-num                 = ? then p-have-tog-db-num  = 0 .
if p-have-tog-id                     = ? then p-have-tog-id      = 0 .
if p-gop-id = 0  then  p-use-obj = 1 .
if p-gop-id-for-calc-turnover  = 0  then  p-obj-turnover = false  .
if p-tog-id = 0   then  p-obj-turnover = false  .
if p-tog-id = 0 and  p-bgr-id = 0   then  p-rs-buyer = 0.
if p-name = ? or p-name = ""  then do:
  return error "Название типа прайс-листа не должно быть пустым!" .
end.
if logical(p-have-rs-qnty-group) = true and  ( p-qgr-id = 0 or p-qgr-id = ? ) then do:
  return error "Не задана количественная группа!" .
end.
if p-have-rs-sum-group = true and  ( p-sgr-id = 0 or p-sgr-id = ? ) then do:
  return error "Не задана суммовая группа!" .
end.
if logical(p-under-type-list) = true and  ( p-plt-main-id = 0 or p-plt-main-id = ? ) then do:
  return error "Не задан родительский прайс-лист !" .
end.
define buffer parent_price-list-type for ub.price-list-type  .
if  logical(p-under-type-list) = true and p-main = true  then do:
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id = p-plt-main-id  and
               parent_price-list-type.plt-db-num =  p-plt-main-db-num no-error .
    if not available parent_price-list-type then  return error "Родительский прайс-лист не найден !" .
    if parent_price-list-type.stts <> integer('0':U) then  return error "Родительский прайс-лист удален !" .
    if parent_price-list-type.main = false  then  return error "Родительский прайс-лист должен быть ГЛАВНЫМ !" .
    if parent_price-list-type.under-type-list <> 0  then return error "Родительский прайс-лист не должен быть подчиненным !"  .
end.
if  logical(p-under-type-list) = true and p-main = false   then do:
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id = p-plt-main-id  and
               parent_price-list-type.plt-db-num =  p-plt-main-db-num no-error .
    if not available parent_price-list-type then  return error "Родительский прайс-лист не найден !" .
    if parent_price-list-type.stts <> integer('0':U) then  return error "Родительский прайс-лист удален !" .
    if parent_price-list-type.under-type-list <> 0  then return error "Родительский прайс-лист не должен быть подчиненным !"  .
end.
if logical(p-have-rs-qnty-group) = false  and not ( p-qgr-id = 0 or p-qgr-id = ? ) then do:
   p-qgr-id = 0.
   p-qgr-db-num = 0.
end.
if p-have-rs-sum-group = false  and  not( p-sgr-id = 0 or p-sgr-id = ? ) then do:
  p-sgr-id = 0.
  p-sgr-db-num = 0.
end.
if logical(p-have-rs-turn-group) = false  and not ( p-have-tog-id = 0 or p-have-tog-id = ? ) then do:
   p-have-tog-id = 0.
   p-have-tog-db-num = 0.
end.
if p-priority  = 0  and p-main = false  and p-under-type-list = 0 then do:
   return error "Не задан ПРИОРИТЕТ типа прайс-листа"   .
end.
if p-priority > 0 and p-main = false and p-under-type-list = 0 then do:
    if can-find (
          first buf_price-list-type no-lock where
                buf_price-list-type.under-type-list = 0          and
                buf_price-list-type.priority        = p-priority and
                buf_price-list-type.main            = false      and
                buf_price-list-type.stts            = integer('0':U)          and
            not
              ( buf_price-list-type.plt-db-num = p-db-num and
                buf_price-list-type.plt-id     = p-id )
              ) then
    return error "Уже есть тип прайс-листа с приоритетом " + string ( p-priority ) .
end.
find first ub.price-list-type exclusive-lock where
           ub.price-list-type.plt-db-num   = p-db-num and
           ub.price-list-type.plt-id       = p-id
           no-error .
    if not available ub.price-list-type then do:
      if p-main = true and p-only-gbd = 1 then do:
        if can-find ( first buf_price-list-type no-lock where
                          buf_price-list-type.main = true and
                          buf_price-list-type.only-gbd = 1 and
                          buf_price-list-type.stts = integer('0':U) and
                          buf_price-list-type.gop-id = p-gop-id and
                          buf_price-list-type.gop-db-num = p-gop-db-num ) then  do:
            if p-gop-id = 0 or p-gop-id = ? then do:
              v-text  = "для всех объектов" .
              end.
              else do:
              v-text  = "для объектов из группы №"  + string(p-gop-id) + " БД:" + string(p-gop-db-num).
              end.
            release ub.price-list-type no-error .
            return error "Уже существует ГЛАВНЫЙ ПРАЙС-ЛИСТ для автопереоценок " + v-text .
            end.
      end.
      create ub.price-list-type .
      assign
          ub.price-list-type.plt-db-num   = p-db-num
          ub.price-list-type.plt-id       = p-id
      .
    end.
       assign
          ub.price-list-type.plt-db-num                     = p-db-num
          ub.price-list-type.plt-id                         = p-id
          ub.price-list-type.name                           = p-name
          ub.price-list-type.ban-discnt                     = p-ban-discnt
          ub.price-list-type.calc-round-method              = p-calc-round-method
          ub.price-list-type.calc-round-base                = p-calc-round-base
          ub.price-list-type.calc-increase-pc               = p-calc-increase-pc
          ub.price-list-type.calc-method                    = p-calc-method
          ub.price-list-type.create-price-doc               = p-create-price-doc
          ub.price-list-type.fix-cource-crc-base            = p-fix-cource-crc-base
          ub.price-list-type.fix-cource-crc-doc             = p-fix-cource-crc-doc
          ub.price-list-type.have-rs-qnty-group             = p-have-rs-qnty-group
          ub.price-list-type.have-rs-sum-group              = p-have-rs-sum-group
          ub.price-list-type.main                           = p-main
          ub.price-list-type.only-gbd                       = p-only-gbd
          ub.price-list-type.plt-main-db-num                = if p-plt-main-id = 0 then p-db-num else p-plt-main-db-num
          ub.price-list-type.plt-main-id                    = if p-plt-main-id = 0 then p-id else p-plt-main-id
          ub.price-list-type.priority                       = p-priority
          ub.price-list-type.rs-buyer                       = p-rs-buyer
          ub.price-list-type.send-cassa                     = p-send-cassa
          ub.price-list-type.under-hand-corr                = p-under-hand-corr
          ub.price-list-type.under-round-method             = p-under-round-method
          ub.price-list-type.under-perc                     = p-under-perc
          ub.price-list-type.under-type-list                = p-under-type-list
          ub.price-list-type.use-cassa                      = p-use-cassa
          ub.price-list-type.use-gds-group                  = p-use-gds-group
          ub.price-list-type.use-obj                        = p-use-obj
          ub.price-list-type.work-date                      = p-work-date
          ub.price-list-type.bgr-db-num                     = p-bgr-db-num
          ub.price-list-type.bgr-id                         = p-bgr-id
          ub.price-list-type.curr-code                      = p-curr-code
          ub.price-list-type.gop-db-num                     = p-gop-db-num
          ub.price-list-type.gop-db-num-for-calc-turnover   = p-gop-db-num-for-calc-turnover
          ub.price-list-type.gop-id                         = p-gop-id
          ub.price-list-type.gop-id-for-calc-turnover       = p-gop-id-for-calc-turnover
          ub.price-list-type.qgr-db-num                     = p-qgr-db-num
          ub.price-list-type.qgr-id                         = p-qgr-id
          ub.price-list-type.sgr-db-num                     = p-sgr-db-num
          ub.price-list-type.sgr-id                         = p-sgr-id
          ub.price-list-type.tog-db-num                     = p-tog-db-num
          ub.price-list-type.tog-id                         = p-tog-id
          ub.price-list-type.obj-turnover                   = p-obj-turnover
          ub.price-list-type.ttg-summa                      = p-ttg-summa
          ub.price-list-type.have-rs-turn-group             =   p-have-rs-turn-group
          ub.price-list-type.have-tog-db-num                =   p-have-tog-db-num
          ub.price-list-type.have-tog-id                    =   p-have-tog-id
          ub.price-list-type.use-cash-pay                   =   p-use-cash-pay
          ub.price-list-type.use-pay-type                   =   p-use-pay-type
          ub.price-list-type.stts                           = integer('0':U)
          ub.price-list-type.sys-date                       = today
          ub.price-list-type.sys-time                       = time
          ub.price-list-type.sys-time-chr                   = string ( ub.price-list-type.sys-time,"hh:mm" )
          ub.price-list-type.who                            = p-userid
          ub.price-list-type.db-num-chg                     = p-db-num-usr
          p-recid = recid ( ub.price-list-type )
      .
  if p-use-cassa < 3 then do:
     for each tt_cassa : delete tt_cassa . end.
  end.
  if p-use-gds-group = 0  then do:
     for each tt_grp : delete tt_grp . end.
  end.
  for each ub.price-list-type-gds-grp exclusive-lock where
           ub.price-list-type-gds-grp.plt-db-num  = p-db-num and
           ub.price-list-type-gds-grp.plt-id      = p-id :
       if not can-find (first  tt_grp where tt_grp.node-code = ub.price-list-type-gds-grp.node-code ) then
       ub.price-list-type-gds-grp.stts   = integer('1':U) .
  end.
  for each tt_grp :
      find first  ub.price-list-type-gds-grp exclusive-lock where
              ub.price-list-type-gds-grp.node-code  = tt_grp.node-code and
              ub.price-list-type-gds-grp.plt-db-num  = p-db-num and
              ub.price-list-type-gds-grp.plt-id      = p-id no-error .
      if not available ub.price-list-type-gds-grp then do:
             create ub.price-list-type-gds-grp.
              assign
                ub.price-list-type-gds-grp.node-code  = tt_grp.node-code
                ub.price-list-type-gds-grp.plt-db-num     = p-db-num
                ub.price-list-type-gds-grp.plt-id         = p-id
                ub.price-list-type-gds-grp.stts       = integer('0':U)
                ub.price-list-type-gds-grp.sys-date     = today
                ub.price-list-type-gds-grp.sys-time     = time
                ub.price-list-type-gds-grp.sys-time-chr = string ( ub.price-list-type-gds-grp.sys-time,"hh:mm" )
                ub.price-list-type-gds-grp.who          = p-userid
                ub.price-list-type-gds-grp.db-num-chg   = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-gds-grp.stts   = integer('0':U)
          ub.price-list-type-gds-grp.sys-date     = today
          ub.price-list-type-gds-grp.sys-time     = time
          ub.price-list-type-gds-grp.sys-time-chr = string ( ub.price-list-type-gds-grp.sys-time,"hh:mm" )
          ub.price-list-type-gds-grp.who          = p-userid
          ub.price-list-type-gds-grp.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  for each ub.price-list-type-cassa exclusive-lock where
           ub.price-list-type-cassa.plt-db-num  = p-db-num and
           ub.price-list-type-cassa.plt-id      = p-id :
       if not can-find (first tt_cassa where
                              tt_cassa.cash-num = ub.price-list-type-cassa.cash-num and
                              tt_cassa.obj-code = ub.price-list-type-cassa.obj-code and
                              tt_cassa.pos-type = ub.price-list-type-cassa.pos-type
                              ) then
       ub.price-list-type-cassa.stts   = integer('1':U)  .
  end.
  for each tt_cassa :
      find first  ub.price-list-type-cassa exclusive-lock where
                  ub.price-list-type-cassa.cash-num = tt_cassa.cash-num and
                  ub.price-list-type-cassa.obj-code = tt_cassa.obj-code and
                  ub.price-list-type-cassa.pos-type = tt_cassa.pos-type and
                  ub.price-list-type-cassa.plt-db-num        = p-db-num and
                  ub.price-list-type-cassa.plt-id            = p-id     no-error .
      if not available ub.price-list-type-cassa then do :
             create ub.price-list-type-cassa.
              assign
                ub.price-list-type-cassa.cash-num     = tt_cassa.cash-num
                ub.price-list-type-cassa.obj-code     = tt_cassa.obj-code
                ub.price-list-type-cassa.pos-type     = tt_cassa.pos-type
                ub.price-list-type-cassa.plt-db-num   = p-db-num
                ub.price-list-type-cassa.plt-id       = p-id
                ub.price-list-type-cassa.stts         = integer('0':U)
                ub.price-list-type-cassa.sys-date     = today
                ub.price-list-type-cassa.sys-time     = time
                ub.price-list-type-cassa.sys-time-chr = string ( ub.price-list-type-cassa.sys-time,"hh:mm" )
                ub.price-list-type-cassa.who          = p-userid
                ub.price-list-type-cassa.db-num-chg   = p-db-num-usr
                ub.price-list-type-cassa.db-num       = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-cassa.stts   = integer('0':U)
          ub.price-list-type-cassa.sys-date     = today
          ub.price-list-type-cassa.sys-time     = time
          ub.price-list-type-cassa.sys-time-chr = string ( ub.price-list-type-cassa.sys-time,"hh:mm" )
          ub.price-list-type-cassa.who          = p-userid
          ub.price-list-type-cassa.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  for each ub.price-list-type-pay-type exclusive-lock where
           ub.price-list-type-pay-type.plt-db-num  = p-db-num and
           ub.price-list-type-pay-type.plt-id      = p-id :
       if not can-find (first tt_pay-type where
                              tt_pay-type.pay-code = ub.price-list-type-pay-type.pay-code
                              ) then
       ub.price-list-type-pay-type.stts   = integer('1':U)  .
  end.
  for each tt_pay-type :
      find first  ub.price-list-type-pay-type exclusive-lock where
                  ub.price-list-type-pay-type.pay-code = tt_pay-type.pay-code and
                  ub.price-list-type-pay-type.plt-db-num        = p-db-num and
                  ub.price-list-type-pay-type.plt-id            = p-id     no-error .
      if not available ub.price-list-type-pay-type then do :
             create ub.price-list-type-pay-type.
              assign
                ub.price-list-type-pay-type.pay-code     = tt_pay-type.pay-code
                ub.price-list-type-pay-type.plt-db-num   = p-db-num
                ub.price-list-type-pay-type.plt-id       = p-id
                ub.price-list-type-pay-type.stts         = integer('0':U)
                ub.price-list-type-pay-type.sys-date     = today
                ub.price-list-type-pay-type.sys-time     = time
                ub.price-list-type-pay-type.sys-time-chr = string ( ub.price-list-type-pay-type.sys-time,"hh:mm" )
                ub.price-list-type-pay-type.who          = p-userid
                ub.price-list-type-pay-type.db-num-chg   = p-db-num-usr
                ub.price-list-type-pay-type.db-num       = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-pay-type.stts   = integer('0':U)
          ub.price-list-type-pay-type.sys-date     = today
          ub.price-list-type-pay-type.sys-time     = time
          ub.price-list-type-pay-type.sys-time-chr = string ( ub.price-list-type-pay-type.sys-time,"hh:mm" )
          ub.price-list-type-pay-type.who          = p-userid
          ub.price-list-type-pay-type.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  for each ub.price-list-type-cash-pay exclusive-lock where
           ub.price-list-type-cash-pay.plt-db-num  = p-db-num and
           ub.price-list-type-cash-pay.plt-id      = p-id :
       if not can-find (first tt_cash-pay where
                              tt_cash-pay.cdpay-code = ub.price-list-type-cash-pay.cdpay-code and
                              tt_cash-pay.curr-code  = ub.price-list-type-cash-pay.curr-code
                              ) then
       ub.price-list-type-cash-pay.stts   = 1 .
  end.
  for each tt_cash-pay :
      find first  ub.price-list-type-cash-pay exclusive-lock where
                  ub.price-list-type-cash-pay.cdpay-code = tt_cash-pay.cdpay-code and
                  ub.price-list-type-cash-pay.curr-code  = tt_cash-pay.curr-code and
                  ub.price-list-type-cash-pay.plt-db-num        = p-db-num and
                  ub.price-list-type-cash-pay.plt-id            = p-id     no-error .
      if not available ub.price-list-type-cash-pay then do :
             create ub.price-list-type-cash-pay.
              assign
                ub.price-list-type-cash-pay.cdpay-code     = tt_cash-pay.cdpay-code
                ub.price-list-type-cash-pay.curr-code     = tt_cash-pay.curr-code
                ub.price-list-type-cash-pay.plt-db-num   = p-db-num
                ub.price-list-type-cash-pay.plt-id       = p-id
                ub.price-list-type-cash-pay.stts         = integer('0':U)
                ub.price-list-type-cash-pay.sys-date     = today
                ub.price-list-type-cash-pay.sys-time     = time
                ub.price-list-type-cash-pay.sys-time-chr = string ( ub.price-list-type-cash-pay.sys-time,"hh:mm" )
                ub.price-list-type-cash-pay.who          = p-userid
                ub.price-list-type-cash-pay.db-num-chg   = p-db-num-usr
                ub.price-list-type-cash-pay.db-num       = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-cash-pay.stts   = integer('0':U)
          ub.price-list-type-cash-pay.sys-date     = today
          ub.price-list-type-cash-pay.sys-time     = time
          ub.price-list-type-cash-pay.sys-time-chr = string ( ub.price-list-type-cash-pay.sys-time,"hh:mm" )
          ub.price-list-type-cash-pay.who          = p-userid
          ub.price-list-type-cash-pay.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  end.
end procedure.
PROCEDURE type-price-list-delete :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define buffer child_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
find first ub.price-list-type exclusive-lock where
        ub.price-list-type.plt-db-num   = p-db-num  and
        ub.price-list-type.plt-id       = p-id
        no-error .
 if not available ub.price-list-type then  return error .
 if ub.price-list-type.ban-discnt > 0 then do:
 define buffer buf_dis-rule for ub.dis-rule  .
 find first buf_dis-rule no-lock where
            buf_dis-rule.templ-rl-root = ub.price-list-type.ban-discnt and
            buf_dis-rule.charkey_one   = substitute("&1-&2", ub.price-list-type.plt-id, ub.price-list-type.plt-db-num)
            no-error .
     if available buf_dis-rule then do:
        message  substitute
          ( "Удалить этот тип нельзя, так как есть ссылка на ПРАВИЛО СКИДОК &1 &2" ,
             ub.price-list-type.ban-discnt  ,
             buf_dis-rule.des
            ) view-as alert-box error .
        return .
     end.
 end.
 find first ub.price-doc-forming no-lock where
            ub.price-doc-forming.plt-id = ub.price-list-type.plt-id and
            ub.price-doc-forming.plt-db-num = ub.price-list-type.plt-db-num and
            ub.price-doc-forming.stts = integer('0':U) no-error .
 if available ub.price-doc-forming then do:
        message "Удалить этот тип нельзя, так как есть незакрытые ДНЦ " ub.price-doc-forming.pdf-id "БД:" ub.price-doc-forming.pdf-db
        view-as alert-box error .
        return .
 end.
      assign
        ub.price-list-type.db-num-chg    = p-db-num-usr
        ub.price-list-type.stts          = integer('1':U)
        ub.price-list-type.sys-date      = today
        ub.price-list-type.sys-time      = time
        ub.price-list-type.sys-time-chr  = string ( ub.price-list-type.sys-time,"hh:mm" )
        ub.price-list-type.who           = p-userid
      .
      for each child_price-list-type exclusive-lock where
               child_price-list-type.plt-main-db-num = p-db-num  and
               child_price-list-type.plt-main-id     = p-id
               :
            assign
              child_price-list-type.db-num-chg    = p-db-num-usr
              child_price-list-type.stts          = integer('1':U)
              child_price-list-type.sys-date      = today
              child_price-list-type.sys-time      = time
              child_price-list-type.sys-time-chr  = string ( child_price-list-type.sys-time , "hh:mm" )
              child_price-list-type.who           = p-userid
            .
      end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable v-rec-list-cli as character no-undo .
define variable g-log  as logical   no-undo .
define variable v-name as character no-undo .
define variable v-a    as logical   no-undo .
define variable varlog as logical   no-undo .
define buffer ch_price-list-type for ub.price-list-type  .
define variable r-plt        as integer   no-undo init 2 .
define variable r-ban-discnt as integer   no-undo init 0.
define variable v-bg-color   as integer   no-undo .
define variable v-fg-color   as integer   no-undo .
function mark-string returns character
  ( buffer loc-table for ub.price-list-type, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.
function stts-string returns character
  ( buffer loc-table for ub.price-list-type   ) :
return entry (lookup (string(loc-table.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) .
end function.
function activ-pr returns character
  ( buffer loc-table for ub.price-list-type  ) :
  define buffer b_price-all for ub.price-all  .
  find first b_price-all no-lock where
             b_price-all.plt-db-num = loc-table.plt-db-num and
             b_price-all.plt-id     = loc-table.plt-id and
             b_price-all.status_    = 'акт':U
             no-error .
  if available b_price-all then return "+".
  else return "".
end function.
function name-pl returns character
  ( buffer loc-table for ub.price-list-type  ) :
  case loc-table.under-type-list :
      when ? then do:
        return ( loc-table.NAME ) .
      end.
      when 0 then do:
        return ( loc-table.name ) .
      end.
      when 1 then do:
        return (  "-> " + loc-table.name ) .
      end.
  end case.
end function.
define variable ref-rec as recid no-undo.
define variable loc_gop-id     as integer   no-undo .
define variable loc_tog-id     as integer   no-undo .
define variable loc_bgr-id     as integer   no-undo .
define variable loc_gop-db-num as integer   no-undo .
define variable loc_tog-db-num as integer   no-undo .
define variable loc_bgr-db-num as integer   no-undo .
define variable loc_plt-recid  as character no-undo .
define buffer buf_buyer-group    for ub.buyer-group  .
define buffer buf_turnover-group for ub.turnover-group  .
define buffer buf_grp-obj-price  for ub.grp-obj-price  .
define variable is-color as logical   no-undo .
DEFINE QUERY external_tables FOR buf_price-list-type.
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить тип ПЛ"
     BGCOLOR 8 .
DEFINE BUTTON B-add-M
     IMAGE-UP FILE "cmp/add-gtpl.bmp":U
     LABEL "Добавить ГТПЛ"
     SIZE 20 BY 1 TOOLTIP "Добавить главный тип прайс-листа"
     BGCOLOR 4 FGCOLOR 15 .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-color
     IMAGE-UP FILE "cmp/color.bmp":U
     IMAGE-DOWN FILE "cmp/color.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/color.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Цветовое выделение на экране".
DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить ТПЛ"
     BGCOLOR 8 .
DEFINE BUTTON B-del-pr
     LABEL "Удалить цены"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-history
     LABEL "История"
     SIZE 3 BY 1 TOOLTIP "История изменения справочника"
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить ТПЛ"
     BGCOLOR 8 .
DEFINE BUTTON B-price-doc
     LABEL "ДНЦ"
     SIZE 13.5 BY 1 TOOLTIP "Документы назначения цены"
     BGCOLOR 8 .
DEFINE BUTTON B-price-lists
     LABEL "Переоценки"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 3 BY 1 TOOLTIP "Печать справочника"
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск Код ТПЛ:"
      VIEW-AS TEXT
     SIZE 14.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип:"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение"
      VIEW-AS TEXT
     SIZE 16 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE FILL-IN-buy AS CHARACTER FORMAT "X(256)":U INITIAL "Покупатели:"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-tog AS CHARACTER FORMAT "X(256)":U INITIAL "Обороты:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_bgr_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.
DEFINE VARIABLE loc_gop_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.5 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.
DEFINE VARIABLE loc_tog_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.
DEFINE VARIABLE v-id AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по коду типа прайс-листа" NO-UNDO.
DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Последний корректировал"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE R-avtop AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Автопереоценки", 1,
"Ручные", 0
     SIZE 33 BY .67 NO-UNDO.
DEFINE VARIABLE R-buyer AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Группа", 1
     SIZE 16 BY .67 TOOLTIP "Выбор по группам покупателей" NO-UNDO.
DEFINE VARIABLE R-main AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Главный", 1,
"Неглавный", 0
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE R-obj AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Тек", 3,
"Группа", 1
     SIZE 19.63 BY .67 TOOLTIP "Выбор по группам объектов" NO-UNDO.
DEFINE VARIABLE R-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие", 0,
"Все", 2,
"Удаленные", 1
     SIZE 30.5 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.
DEFINE VARIABLE R-tog AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Группа", 1
     SIZE 16 BY .67 TOOLTIP "Выбор по группам оборотов покупателей" NO-UNDO.
DEFINE QUERY BROWSE-1grp FOR
             buf_price-list-type ,
             x_grp-obj-price
             SCROLLING.
DEFINE BROWSE BROWSE-1grp
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_price-list-type, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string(buffer buf_price-list-type) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_price-list-type.plt-id COLUMN-LABEL "Код! " FORMAT ">>>>>9":U
      buf_price-list-type.main COLUMN-LABEL "Г! "  FORMAT "+/ ":U
      logical(buf_price-list-type.only-gbd) @ v-a COLUMN-LABEL "А! " FORMAT "+/ ":U
      name-pl(buffer buf_price-list-type) @ v-name COLUMN-LABEL "Название типа прайс-листа! " FORMAT "X(100)":U
      WIDTH 36
      activ-pr(buffer buf_price-list-type) COLUMN-LABEL "Есть!цены"            FORMAT "x(4)":U
      buf_price-list-type.priority  COLUMN-LABEL 'Прио!ритет'  FORMAT ">>9":U
      buf_price-list-type.sys-date     COLUMN-LABEL "Дата!изм"  FORMAT "99/99/99":U
      buf_price-list-type.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_price-list-type.db-num-chg   COLUMN-LABEL "БД!изм"    FORMAT ">>>>9":U
      buf_price-list-type.plt-db-num FORMAT ">>>>9":U
      buf_price-list-type.plt-main-id  COLUMN-LABEL "Родитель!  " FORMAT ">>>>>9":U
      buf_price-list-type.plt-main-db-num COLUMN-LABEL "БД!РПЛ"    FORMAT ">>>>9":U
      buf_price-list-type.ban-discnt COLUMN-LABEL "Шаблон!скидки"  FORMAT ">>>>>9":U
  ENABLE
      buf_price-list-type.plt-id
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 16 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14.25
     B-add-M AT ROW 1 COL 24.25
     B-add AT ROW 1 COL 44.25
     B-lkp AT ROW 1 COL 54.25
     B-chg AT ROW 1 COL 64.25
     B-del AT ROW 1 COL 74.25
     B-print AT ROW 1 COL 91
     B-history AT ROW 1 COL 94
     B-Help AT ROW 1 COL 97
     B-price-doc AT ROW 2 COL 1
     B-price-lists AT ROW 2 COL 14.5
     B-del-pr AT ROW 2 COL 29.5
     B-color AT ROW 2 COL 97
     R-status AT ROW 3.17 COL 9.5 NO-LABEL
     R-obj AT ROW 3.17 COL 50.88 NO-LABEL
     R-buyer AT ROW 3.83 COL 50.88 NO-LABEL
     R-main AT ROW 3.88 COL 9.5 NO-LABEL
     R-avtop AT ROW 4.54 COL 5.5 NO-LABEL WIDGET-ID 6
     R-tog AT ROW 4.58 COL 50.88 NO-LABEL
     v-id AT ROW 5.21 COL 14.13 COLON-ALIGNED NO-LABEL
     BROWSE-1grp AT ROW 6.25 COL 1.5
     FILL-IN-8 AT ROW 2.46 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     FILL-IN-2 AT ROW 3.13 COL 42.13 NO-LABEL
     FILL-IN-1 AT ROW 3.17 COL 1.88 NO-LABEL
     loc_gop_name AT ROW 3.17 COL 69 COLON-ALIGNED NO-LABEL
     FILL-IN-buy AT ROW 3.79 COL 39.13 NO-LABEL
     FILL-IN-7 AT ROW 3.88 COL 4.88 NO-LABEL
     loc_bgr_name AT ROW 3.92 COL 64.5 COLON-ALIGNED NO-LABEL
     FILL-IN-tog AT ROW 4.54 COL 42 NO-LABEL
     loc_tog_name AT ROW 4.63 COL 64.5 COLON-ALIGNED NO-LABEL
     FILL-IN-6 AT ROW 5.13 COL 1.5 NO-LABEL
     v-user-name AT ROW 22.33 COL 5.75 COLON-ALIGNED WIDGET-ID 2
     SPACE(77.63) SKIP(0.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник Типов прайс-листов"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  define variable v-rec-id as recid no-undo .
  run ref/tp-price.w ( input parparentproc , false ,  input 'ДОБАВЛЕНИЕ':U , input-output v-rec-id ) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .
END.
ON CHOOSE OF B-add-M IN FRAME Dialog-Frame
DO:
  define variable v-rec-id as recid no-undo .
  run ref/tp-price.w ( input parparentproc, input TRUE ,  input 'ДОБАВЛЕНИЕ':U , input-output v-rec-id ) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .
END.
ON CHOOSE OF B-Cancel IN FRAME Dialog-Frame
DO:
  run uf-set in this-procedure(
   input 'color-p':U
  ,input v-cntxt-userid
  ,input string(is-color)
  ,input v-uf-Naim
  ,input v-uf-print-graft
  ,input v-uf-sort-gr
  ,input v-uf-type-price
  ,input v-uf-type-val
  ) no-error    .
  if error-status :error then .
  run uf-set in this-procedure(
   input 'tpl-mode-p':U
  ,input v-cntxt-userid
  ,input string(r-main) + chr(4) + string(r-obj) + chr(4) + string(r-avtop) + chr(4)
  ,input v-uf-Naim
  ,input v-uf-print-graft
  ,input v-uf-sort-gr
  ,input v-uf-type-price
  ,input v-uf-type-val
  ) no-error    .
  if error-status :error then .
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  if not available buf_price-list-type then return .
  if buf_price-list-type.stts <> integer('0':U) then do:
     message "Статус УДАЛЕН - изменять нельзя " view-as alert-box information .
     return .
  end.
  if buf_price-list-type.plt-db-num <>  v-cntxt-db-num then do:
     message "Нельзя изменять прайс-лист чужой БД!" view-as alert-box information .
     return .
  end.
  define variable v-rec-id as recid no-undo .
  v-rec-id = recid(buf_price-list-type) .
  run ref/tp-price.w (input parparentproc, buf_price-list-type.main , input 'ИЗМЕНЕНИЕ':U , input-output v-rec-id) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .
END.
ON CHOOSE OF B-color IN FRAME Dialog-Frame
DO:
  if B-color:IMAGE  = "cmp/nocol.bmp" then
  do:
    B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame Dialog-Frame  .
    is-color = true .
    run openbr .
  end.
  else do:
     B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame Dialog-Frame  .
     is-color = false  .
     run openbr .
  end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available buf_price-list-type then return .
define variable g#log as logical   no-undo .
   if buf_price-list-type.main then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_global-tpl-mpl_delete':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   end.
   else do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tpl-mpl_delete':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   end.
if not g#log then return .
  if buf_price-list-type.stts <> integer('0':U) then do:
     message "Уже удален!" view-as alert-box information .
     return .
  end.
  if buf_price-list-type.plt-db-num <>  v-cntxt-db-num then do:
     message "Нельзя удалять прайс-лист чужой БД!" view-as alert-box information .
     return .
  end.
  message "Удалять тип прайс-листов: " buf_price-list-type.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
run type-price-list-DELETE (
      buf_price-list-type.plt-db-num ,
      buf_price-list-type.plt-id     ,
      v-cntxt-db-num                 ,
      v-cntxt-userid                 )
      no-error .
 if error-status :error then return no-apply .
 run openbr .
END.
ON CHOOSE OF B-del-pr IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_mpl-price_delete':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
  if not available buf_price-list-type then return .
  if buf_price-list-type.main then do:
     message "Удалять цены по главному типу прайс-листов нельзя !" view-as alert-box error .
     return .
  end.
  if buf_price-list-type.plt-db-num <>  v-cntxt-db-num then do:
     message "Нельзя удалять прайс-лист чужой БД!" view-as alert-box information .
     return .
  end.
  message "Удалять цены по типу прайс-листов: " buf_price-list-type.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/del-pdf.p ( parparentproc , buf_price-list-type.plt-id, buf_price-list-type.plt-db-num ) .
  g-log = browse-1grp:refresh() .
END.
ON CHOOSE OF B-history IN FRAME Dialog-Frame
DO:
  if not available buf_price-list-type then return .
  run ref/c-tp-pl.w (
      parParentProc ,
      buf_price-list-type.plt-id ,
      buf_price-list-type.plt-db-num ) .
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
  if not available buf_price-list-type then return .
  define variable v-rec-id as recid no-undo .
  v-rec-id = recid(buf_price-list-type) .
  run ref/tp-price.w (input parparentproc ,buf_price-list-type.main , input 'ПРОСМОТР':U , input-output v-rec-id) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
    if available buf_price-list-type then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid10 as character no-undo .
define variable v-num-entry10 as integer   no-undo .
assign
  v-str-recid10 = trim( string( recid( buf_price-list-type ) , "->>>>>>>>>>>9":U ) )
  v-num-entry10 = lookup( v-str-recid10 , p-rec-list )
.
if v-num-entry10 > 0 then do:
  assign
    entry( v-num-entry10, p-rec-list ) = "":U
    p-rec-list = trim( replace( p-rec-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rec-list = p-rec-list + ( if p-rec-list = "":U then "":U else chr(44) ) + v-str-recid10
  .
end.
        g-log = browse-1grp:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-1grp:select-next-row ().
          apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
      end.
    end.
    apply "display" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-price-doc IN FRAME Dialog-Frame
DO:
  if not available buf_price-list-type then return .
  define variable v-rec-list as character no-undo .
  run str/docsprls.w ( parparentproc , "pl-type" , buf_price-list-type.plt-id  , buf_price-list-type.plt-db-num  , "b-del" , input-output v-rec-list) .
END.
ON CHOOSE OF B-price-lists IN FRAME Dialog-Frame
DO:
  define variable loc-ref-list as character no-undo .
  define variable p-list-mode as character no-undo .
  p-list-mode = "typepricelist":U .
  if not available buf_price-list-type then return .
  run str/pr-docs.w
    (input parparentproc
    ,input "":U
    ,input p-list-mode
    ,input ""
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input string(recid(buf_price-list-type))
    ,output loc-ref-list
    ) .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
    MESSAGE "Не реализовано".
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
   if ( available buf_price-list-type ) AND ( p-rec-list = "" ) THEN p-rec-list = string( recid( buf_price-list-type ) ) .
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if b-sel:SENSITIVE then apply  "CHOOSE":U to b-sel.
     else apply  "CHOOSE":U to b-lkp.
END.
ON ROW-DISPLAY OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if LOOKUP ("mode=twotpl":U,    p-bttns) > 0 then do:
    if mark-string(buffer buf_price-list-type, p-rec-list) = '*' then do:
       buf_price-list-type.priority  :bgcolor in browse BROWSE-1grp   = RED_COLOR .
    end.
  end.
  if is-color = false then return .
  if buf_price-list-type.ban-discnt > 0 then do:
     v-fg-color = 5  .
  end.
  else do:
     v-fg-color = ?  .
  end.
  if buf_price-list-type.under-type-list = 1 then do:
     run recolor in this-procedure (GRAY_COLOR , v-fg-color ) .
  end.
  else do:
     if can-find (first ch_price-list-type no-lock where
                        ch_price-list-type.under-type-list = 1 and
                        ch_price-list-type.stts            = integer('0':U) and
                        ch_price-list-type.plt-main-id     = buf_price-list-type.plt-id and
                        ch_price-list-type.plt-main-db-num = buf_price-list-type.plt-db-num )
        then do:
          run recolor in this-procedure (DARK_GRAY_COLOR, v-fg-color ) .
        end.
        else do:
          v-bg-color = ? .
          if buf_price-list-type.qgr-id > 0 then do:
             v-bg-color = 11 .
          end.
          if buf_price-list-type.sgr-id > 0 then do:
             v-bg-color = 10 .
          end.
          if buf_price-list-type.have-tog-id > 0 then do:
             v-bg-color = 14 .
          end.
          run recolor in this-procedure (v-bg-color , v-fg-color ) .
        end.
  end.
END.
ON START-SEARCH OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
   run sort-proc in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if available buf_price-list-type then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_price-list-type.who
  ,output v-user-name
  )  .
   DISPLAY v-user-name WITH FRAME Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF R-avtop IN FRAME Dialog-Frame
DO:
    ASSIGN R-avtop .
       run openbr .
END.
ON VALUE-CHANGED OF R-buyer IN FRAME Dialog-Frame
DO:
define variable vref-rec as character no-undo .
assign
  loc_bgr_name      = ""
  loc_bgr-db-num    = 0
  loc_bgr-id        = 0
.
   assign r-buyer .
   if r-buyer = 1 then do:
        run ref/gr-bupr.w ( input  parparentproc ,"b-sel" , input-output vref-rec ) .
        if vref-rec = ? or vref-rec = '' then do:
           r-buyer = 2.
           display r-buyer with frame Dialog-Frame.
           return no-apply.
        end.
        find ub.buyer-group where recid ( ub.buyer-group ) = int(vref-rec) no-lock .
        if available ub.buyer-group then do:
            assign
              loc_bgr_name      = ub.buyer-group.name
              loc_bgr-db-num    = ub.buyer-group.bgr-db-num
              loc_bgr-id        = ub.buyer-group.bgr-id
            .
        end.
   end.
  display loc_bgr_name with frame Dialog-Frame.
  run openbr .
END.
ON VALUE-CHANGED OF R-main IN FRAME Dialog-Frame
DO:
    ASSIGN R-main .
       run openbr .
END.
ON VALUE-CHANGED OF R-obj IN FRAME Dialog-Frame
DO:
define variable v-spis as character no-undo .
assign
  loc_gop_name      = ""
  loc_gop-db-num    = 0
  loc_gop-id        = 0
.
   assign r-obj .
   if r-obj = 2 or r-obj = 1 then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    if varlog = false then r-obj = 3.
    display r-obj loc_gop_name with frame Dialog-Frame.
   end.
   if r-obj = 1 then do:
        run ref/gr-objpr.w ( input  parparentproc , input "b-sel" , input-output v-spis ) .
        if v-spis = ? or v-spis = '' then do:
            r-obj = 2.
            loc_gop_name = '' .
            display r-obj loc_gop_name with frame Dialog-Frame.
            run openbr .
            return no-apply.
        end.
        else do:
          find ub.grp-obj-price where recid ( ub.grp-obj-price ) = int(v-spis) no-lock no-error.
          if available ub.grp-obj-price then do:
              assign
                loc_gop_name      = ub.grp-obj-price.name
                loc_gop-db-num    = ub.grp-obj-price.gop-db-num
                loc_gop-id        = ub.grp-obj-price.gop-id
              .
          end.
        end.
   end.
   if r-obj = 3 then do:
        if ( v-cntxt-obj-type = ? or v-cntxt-obj-type = "" ) and varlog = true then do:
           r-obj = 2.
           loc_gop_name = '' .
           display r-obj loc_gop_name with frame Dialog-Frame.
           run openbr .
           return no-apply.
        end.
        find first x_grp-obj-price no-error  .
        if available x_grp-obj-price then do:
            assign
              loc_gop_name      = x_grp-obj-price.name
              loc_gop-db-num    = x_grp-obj-price.gop-db-num
              loc_gop-id        = x_grp-obj-price.gop-id
            .
        end.
        define buffer buf_clients for ub.clients  .
        find first buf_clients no-lock where
                    buf_clients.obj-type   = v-cntxt-obj-type and
                    buf_clients.obj-code   = v-cntxt-obj-code no-error .
        loc_gop_name  = buf_clients.obj-name  .
   end.
   display loc_gop_name with frame Dialog-Frame.
   run openbr .
END.
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
   ASSIGN R-status .
  run openbr .
END.
ON VALUE-CHANGED OF R-tog IN FRAME Dialog-Frame
DO:
define variable v-ref-rec as recid no-undo .
define variable s-ref-rec as character no-undo .
assign
  loc_tog_name      = ""
  loc_tog-db-num    = 0
  loc_tog-id        = 0
.
   assign r-tog .
   if r-tog = 1 then do:
        run ref/gr-obupr.w ( input  parparentproc ,"b-sel" , input-output s-ref-rec ) .
        v-ref-rec = int(s-ref-rec) .
        if v-ref-rec = ? or v-ref-rec = 0 then do:
           r-tog = 2.
           display r-tog with frame Dialog-Frame.
           return no-apply.
        end.
        find ub.turnover-group where recid ( ub.turnover-group ) = v-ref-rec no-lock .
        if available ub.turnover-group then do:
            assign
              loc_tog_name      = ub.turnover-group.name
              loc_tog-db-num    = ub.turnover-group.tog-db-num
              loc_tog-id        = ub.turnover-group.tog-id
            .
        end.
   end.
  display loc_tog_name with frame Dialog-Frame.
  run openbr .
END.
ON CTRL-J OF v-id IN FRAME Dialog-Frame
DO:
 run proc-code in this-procedure ( YES , input frame Dialog-Frame v-id ) no-error.
 if error-status:error then return no-apply.
END.
ON RETURN OF v-id IN FRAME Dialog-Frame
DO:
  run proc-code in this-procedure ( no, input frame Dialog-Frame v-id ) no-error.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-1grp :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
  v-name:resizable in browse BROWSE-1grp   = true .
  buf_price-list-type.plt-id:read-only in browse BROWSE-1grp   = true .
  run init-proc in this-procedure .
  r-ban-discnt = 0 .
  if LOOKUP ("mode=ban-discnt":U,    p-bttns) > 0 then do:
     r-ban-discnt = integer(p-rec-list) no-error .
     p-rec-list = "".
  end.
  if LOOKUP ("mode=gop-id":U,    p-bttns) > 0 then do:
    find buf_grp-obj-price no-lock where recid (buf_grp-obj-price) = integer (p-rec-list) no-error .
    if available buf_grp-obj-price then do:
      assign
        p-rec-list     = ""
        r-obj          = 1
        loc_gop_name   = buf_grp-obj-price.name
        loc_gop-db-num = buf_grp-obj-price.gop-db-num
        loc_gop-id     = buf_grp-obj-price.gop-id
      .
    end.
    else return error "Ошибка поиска по группе объектов" .
  end.
  if LOOKUP ("mode=bgr-id":U,    p-bttns) > 0 then do:
    find buf_buyer-group no-lock where recid (buf_buyer-group) = integer (p-rec-list) no-error .
    if available buf_buyer-group then do:
      assign
        p-rec-list     = ""
        r-buyer        = 1
        loc_bgr_name   = buf_buyer-group.name
        loc_bgr-db-num = buf_buyer-group.bgr-db-num
        loc_bgr-id     = buf_buyer-group.bgr-id
      .
    end.
    else return error "Ошибка поиска по группе покупателей" .
  end.
  if LOOKUP ("mode=tog-id":U,    p-bttns) > 0 then do:
    find buf_turnover-group no-lock where recid (buf_turnover-group) = integer (p-rec-list) no-error .
    if available buf_turnover-group then do:
      assign
        p-rec-list     = ""
        r-tog          = 1
        loc_tog_name   = buf_turnover-group.name
        loc_tog-db-num = buf_turnover-group.tog-db-num
        loc_tog-id     = buf_turnover-group.tog-id
      .
    end.
    else return error "Ошибка поиска по группе оборотов покупателей" .
  end.
  if LOOKUP ("mode=plt-id":U,    p-bttns) > 0 then do:
    r-plt = 1 .
    loc_plt-recid      = p-rec-list  .
    p-rec-list = ""  .
  end.
  if index (p-bttns , "title=":U ) > 0 then do:
    define variable v-end-pos as integer   no-undo .
    define variable v-start-pos as integer   no-undo .
    define variable v-str-1 as character no-undo .
    v-start-pos = index ( p-bttns ,"title=":U) + 6 .
    v-end-pos = index ( p-bttns,"endtitle":U).
    v-str-1 = SUBSTRING ( p-bttns, v-start-pos , v-end-pos -  v-start-pos) .
    frame Dialog-Frame:TITLE = v-str-1 .
  end.
  if LOOKUP ("mode=twotpl":U,    p-bttns) > 0 then do:
    r-plt = 1 .
    loc_plt-recid      = p-rec-list  .
  end.
  if LOOKUP ("mode=all":U,    p-bttns) > 0 then do:
    assign
      r-status   = 0
      r-main     = 2
      r-avtop    = 2
      r-obj      = 2
      p-rec-list = ""
    .
  end.
  RUN enable_UI.
  disable
  B-price-doc   when LOOKUP ("b-sel":U,    p-bttns) > 0
  B-price-lists when LOOKUP ("b-sel":U,    p-bttns) > 0
  B-sel         when LOOKUP ("b-sel":U,    p-bttns) = 0
  B-add         when LOOKUP ("b-add":U,    p-bttns) = 0
  B-add-m       when LOOKUP ("b-add":U,    p-bttns) = 0
  B-chg         when LOOKUP ("b-chg":U,    p-bttns) = 0
  B-del         when LOOKUP ("b-del":U,    p-bttns) = 0
  B-del-pr      when LOOKUP ("b-del":U,    p-bttns) = 0
  B-mark        when LOOKUP ("b-mark":U,   p-bttns) = 0
  with frame Dialog-Frame .
  define variable v-main-tpl              as logical   no-undo .
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child             as logical   no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstmain in g#library
  (output v-main-tpl
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstall in g#library
(  output v-use-grp-buy
 , output v-use-oborot-buy
 , output v-use-qnty-group
 , output v-use-sum-group
 , output v-use-add-code
 , output v-use-sys-date-time
 , output v-use-shift-date-num
 , output v-use-cassa
 , output v-use-val
 , output v-use-pay-type
 , output v-use-cash-pay
 , output v-use-child
        )  .
  if v-use-child = false then do:
    assign
      buf_price-list-type.plt-main-id:visible in browse BROWSE-1grp = false .
      buf_price-list-type.plt-main-db-num:visible in browse BROWSE-1grp = false .
    .
  end.
  if v-main-tpl then hide  FILL-IN-buy FILL-IN-tog  B-add R-buyer R-tog B-del-pr in frame Dialog-Frame .
  if v-use-grp-buy     = false then hide FILL-IN-buy R-buyer in frame Dialog-Frame .
  if v-use-oborot-buy  = false then hide FILL-IN-tog R-tog   in frame Dialog-Frame .
  run openbr in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS BROWSE-1grp.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-status R-obj R-buyer R-main R-avtop R-tog v-id FILL-IN-8 FILL-IN-2
          FILL-IN-1 loc_gop_name FILL-IN-buy FILL-IN-7 loc_bgr_name FILL-IN-tog
          loc_tog_name FILL-IN-6 v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add-M B-add B-lkp B-chg B-del B-print
         B-history B-Help B-price-doc B-price-lists B-del-pr B-color R-status
         R-obj R-buyer R-main R-avtop R-tog v-id BROWSE-1grp FILL-IN-8
         FILL-IN-2 FILL-IN-1 loc_gop_name FILL-IN-buy FILL-IN-7 loc_bgr_name
         FILL-IN-tog loc_tog_name FILL-IN-6 v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
run uf-get in this-procedure(
     input  'color-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if v-uf-List_ = "yes"  then is-color = true .
if is-color = true  then B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame Dialog-Frame  .
if is-color = false then B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame Dialog-Frame  .
run uf-get in this-procedure(
     input  'tpl-mode-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error.
if error-status :error then
assign
  r-main   = 2
  r-obj    = 3
  r-avtop  = 2
.
else  do:
  r-main   = int (entry (1,v-uf-List_,chr(4))) no-error . if r-main   = ? then  r-main   = 2 .
  r-obj    = int (entry (2,v-uf-List_,chr(4))) no-error . if r-obj    = ? then  r-obj    = 3 .
  r-avtop  = int (entry (3,v-uf-List_,chr(4))) no-error . if r-avtop  = ? then  r-avtop  = 2 .
end.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
if (r-obj = 2 or r-obj = 1) and varlog = false then r-obj = 3.
run metod-obj-in-gop (
    v-cntxt-db-num ,
    v-cntxt-obj-type ,
    v-cntxt-obj-code ) .
run openbr in this-procedure .
END PROCEDURE.
PROCEDURE openbr :
   run sort-proc in this-procedure .
   apply "VALUE-CHANGED" to BROWSE-1grp IN FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as INTEGER no-undo.
DEFINE VARIABLE doc-rec AS RECID NO-UNDO.
  doc-rec = ? .
  find first  buf_price-list-type no-lock where  buf_price-list-type.plt-id = pardoc-code no-error  .
  if available buf_price-list-type then
    doc-rec = recid(buf_price-list-type) .
  reposition BROWSE-1grp to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to BROWSE-1grp in frame Dialog-Frame.
  else do:
      message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE recolor :
define input  parameter p-color_bg as integer   no-undo .
define input  parameter p-color_fg as integer   no-undo .
  assign
    buf_price-list-type.plt-id:bgcolor in browse BROWSE-1grp = p-color_bg
    buf_price-list-type.main:bgcolor in browse BROWSE-1grp = p-color_bg
    v-name:bgcolor in browse BROWSE-1grp = p-color_bg
    v-a:bgcolor in browse BROWSE-1grp = p-color_bg
  .
  assign
    buf_price-list-type.plt-id:fgcolor in browse BROWSE-1grp = p-color_fg
    buf_price-list-type.main:fgcolor in browse BROWSE-1grp = p-color_fg
    v-name:fgcolor in browse BROWSE-1grp = p-color_fg
    v-a:fgcolor in browse BROWSE-1grp = p-color_fg
  .
END PROCEDURE.
PROCEDURE sort-proc :
define variable column-handle as handle no-undo .
define variable v-type-sort as character no-undo .
column-handle = BROWSE-1grp:CURRENT-COLUMN  in frame Dialog-Frame no-error .
if not error-status :error  and valid-handle(column-handle) then do:
    if column-handle:label = 'Прио!ритет' then do:
      case column-handle:column-fgcolor:
        when 0 or when ? then
        assign
          column-handle:column-fgcolor = 4
          v-type-sort = "+"
        .
        when 4  then
        assign
          column-handle:column-fgcolor = 5
          v-type-sort = "-"
        .
        when 5  then
        assign
          column-handle:column-fgcolor = 0
          v-type-sort = "def"
        .
      end case.
    end.
end.
else do:
assign
  buf_price-list-type.priority:COLUMN-fgcolor in browse BROWSE-1grp   = 0
  v-type-sort = "def"
.
end.
if R-obj = 3 then do:
    case v-type-sort :
    when "+" then do:
    OPEN QUERY BROWSE-1grp
      FOR EACH buf_price-list-type WHERE
      ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
      ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
      ( r-main  = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
      ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
      ( R-buyer = 2 OR ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                         buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
      ( R-tog = 2 OR   ( buf_price-list-type.tog-id     = loc_tog-id AND
                         buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
      ( R-plt = 2 OR  LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
      , each x_grp-obj-price where
             x_grp-obj-price.gop-id        = buf_price-list-type.gop-id     and
             x_grp-obj-price.gop-db-num    = buf_price-list-type.gop-db-num
          BY buf_price-list-type.priority
          BY buf_price-list-type.plt-main-id DESC
          BY buf_price-list-type.plt-main-db-num DESC
          BY buf_price-list-type.under-type-list
          BY buf_price-list-type.sys-date DESC
          BY buf_price-list-type.sys-time DESC .
    end.
    when "-" then do:
    OPEN QUERY BROWSE-1grp
      FOR EACH buf_price-list-type WHERE
      ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
      ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
      ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
      ( r-avtop = 2 OR buf_price-list-type.only-gbd = r-avtop ) AND
      ( R-buyer = 2 OR    ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                            buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
      ( R-tog = 2 OR    ( buf_price-list-type.tog-id     = loc_tog-id AND
                          buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
      ( R-plt = 2 OR       LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
      , each x_grp-obj-price where
             x_grp-obj-price.gop-id        = buf_price-list-type.gop-id     and
             x_grp-obj-price.gop-db-num    = buf_price-list-type.gop-db-num
          BY buf_price-list-type.priority DESC
          BY buf_price-list-type.plt-main-id DESC
          BY buf_price-list-type.plt-main-db-num DESC
          BY buf_price-list-type.under-type-list
          BY buf_price-list-type.sys-date DESC
          BY buf_price-list-type.sys-time DESC .
    end.
    when "def" then do:
    buf_price-list-type.priority:COLUMN-fgcolor in browse BROWSE-1grp   = 0.
    OPEN QUERY BROWSE-1grp
      FOR EACH buf_price-list-type WHERE
      ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
      ( r-status = 2 OR buf_price-list-type.stts      =  r-status ) AND
      ( r-main = 2 OR  buf_price-list-type.main       =  logical(r-main) ) AND
      ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
      ( R-buyer = 2 OR ( buf_price-list-type.bgr-id   = loc_bgr-id AND
                      buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
      ( R-tog = 2 OR   ( buf_price-list-type.tog-id   = loc_tog-id AND
                      buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
      ( R-plt = 2 OR   LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
      , each x_grp-obj-price where
             x_grp-obj-price.gop-id        = buf_price-list-type.gop-id     and
             x_grp-obj-price.gop-db-num    = buf_price-list-type.gop-db-num
          BY buf_price-list-type.plt-main-id DESC
          BY buf_price-list-type.plt-main-db-num DESC
          BY buf_price-list-type.under-type-list
          BY buf_price-list-type.sys-date DESC
          BY buf_price-list-type.sys-time DESC .
    end.
    end case .
end.
else do:
case v-type-sort :
when "+" then do:
OPEN QUERY BROWSE-1grp
  FOR EACH buf_price-list-type WHERE
  ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
  ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
  ( r-main  = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
  ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
  ( r-obj   = 2 OR ( buf_price-list-type.gop-id     = loc_gop-id AND
                     buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND
  ( R-buyer = 2 OR ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                     buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
  ( R-tog = 2 OR   ( buf_price-list-type.tog-id     = loc_tog-id AND
                     buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
  ( R-plt = 2 OR  LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
  , FIRST x_grp-obj-price OUTER-JOIN
       BY buf_price-list-type.priority
       BY buf_price-list-type.plt-main-id DESC
       BY buf_price-list-type.plt-main-db-num DESC
       BY buf_price-list-type.under-type-list
       BY buf_price-list-type.sys-date DESC
       BY buf_price-list-type.sys-time DESC .
end.
when "-" then do:
OPEN QUERY BROWSE-1grp
  FOR EACH buf_price-list-type WHERE
  ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
  ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
  ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
  ( r-avtop = 2 OR buf_price-list-type.only-gbd = r-avtop ) AND
  ( r-obj = 2 OR        ( buf_price-list-type.gop-id     = loc_gop-id AND
                          buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND
  ( R-buyer = 2 OR    ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                        buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
  ( R-tog = 2 OR    ( buf_price-list-type.tog-id     = loc_tog-id AND
                      buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
   ( R-plt = 2 OR       LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
   , FIRST x_grp-obj-price OUTER-JOIN
       BY buf_price-list-type.priority DESC
       BY buf_price-list-type.plt-main-id DESC
       BY buf_price-list-type.plt-main-db-num DESC
       BY buf_price-list-type.under-type-list
       BY buf_price-list-type.sys-date DESC
       BY buf_price-list-type.sys-time DESC .
end.
when "def" then do:
buf_price-list-type.priority:COLUMN-fgcolor in browse BROWSE-1grp   = 0.
OPEN QUERY BROWSE-1grp
  FOR EACH buf_price-list-type WHERE
  ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
  ( r-status = 2 OR buf_price-list-type.stts      =  r-status ) AND
  ( r-main = 2 OR  buf_price-list-type.main       =  logical(r-main) ) AND
  ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
  ( r-obj = 2 OR   ( buf_price-list-type.gop-id   = loc_gop-id AND
                   buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND
  ( R-buyer = 2 OR ( buf_price-list-type.bgr-id   = loc_bgr-id AND
                   buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
  ( R-tog = 2 OR   ( buf_price-list-type.tog-id   = loc_tog-id AND
                   buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
  ( R-plt = 2 OR   LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
  , FIRST x_grp-obj-price OUTER-JOIN
       BY buf_price-list-type.plt-main-id DESC
       BY buf_price-list-type.plt-main-db-num DESC
       BY buf_price-list-type.under-type-list
       BY buf_price-list-type.sys-date DESC
       BY buf_price-list-type.sys-time DESC .
end.
end case .
end.
END PROCEDURE.
