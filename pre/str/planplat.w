define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-type     as character no-undo .
define variable p-status       as character no-undo .
define variable p-host-code    as integer   no-undo .
define variable p-doc-type     as character no-undo .
define variable p-fo-type     as character no-undo .
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Планирование платежей" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
assign
  p-host-code = v-cntxt-host-code-obj
.
if p-type = "inc"
then do:
  assign
    p-doc-type = 'при':U
    p-fo-type = 'рас':U
  .
end.
else do:
  assign
    p-doc-type = 'рас':U
    p-fo-type = 'при':U
  .
end.
  define buffer buf_fin-doc   for fin-doc .
  define buffer buf_fin-ob    for fin-ob .
  define buffer buf_contract  for contract.
  define buffer buf1_contract for contract.
  find first sysconf no-lock where sysconf.host-code = p-host-code .
  define variable cli-list        as character no-undo .
  define variable cont-list        as character no-undo .
  define variable g-log            as logical   no-undo .
  define variable curr-code        as integer   no-undo .
  define variable v-doc-rec        as recid no-undo .
  define variable v-doc-rec1       as recid no-undo .
  define variable sort-column-name as character no-undo .
  define variable sort-column-name1 as character no-undo .
  define variable p-gen  as character no-undo .
  define variable l-curr  as character no-undo .
  define variable p-contr as character no-undo .
  define variable p-sum   as decimal   no-undo .
  define variable filter-point as character no-undo init "Планирование платежей" .
  define variable num-fin-ob as integer initial 0 no-undo .
  define variable num-fin-doc as integer initial 0 no-undo .
  define variable ind1 as integer initial 0 no-undo .
  define variable ind2 as integer initial 0 no-undo .
  define variable v-conn-avt  as character no-undo .
  define variable v-par-type  as character     no-undo.
  define variable v-list as character no-undo .
  define variable v-end as logical   no-undo .
  define variable sel-date as logical initial no no-undo .
  define variable v-order-col  as character no-undo .
  define variable v-order-col1 as character no-undo .
  define variable v-size-col1 as decimal   no-undo .
  define variable v-size-col2 as decimal   no-undo .
  define variable v-size-col3 as decimal   no-undo .
  define variable v-size-col4 as decimal   no-undo .
  define variable v-size-col5 as decimal   no-undo .
  DEFINE VARIABLE v-payer-code as integer  no-undo .
  DEFINE VARIABLE v-payer-type as character  no-undo .
  run uf-get in this-procedure(
     input  'planplat-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
  )  no-error.
  if error-status :error then message  vss-workfile vss-revision vss-description skip  error-status :get-message(1) skip  return-value skip  ""  view-as alert-box error .
  if not error-status:error then do:
    v-order-col  = entry ( 1, v-uf-List_ ,chr(4) ) no-error.
    v-order-col1 = entry ( 2, v-uf-List_ ,chr(4) ) no-error.
    v-size-col1  = decimal (entry(3, v-uf-List_ ,chr(4))) no-error.
    v-size-col2  = decimal (entry(4, v-uf-List_ ,chr(4))) no-error.
    v-size-col3  = decimal (entry(5, v-uf-List_ ,chr(4))) no-error.
    v-size-col4  = decimal (entry(6, v-uf-List_ ,chr(4))) no-error.
    v-size-col5  = decimal (entry(7, v-uf-List_ ,chr(4))) no-error.
    if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 15.
    if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 15.
    if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3 = 10.
    if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4 = 15.
    if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5 = 15.
    if v-order-col = ""  or v-order-col = ?  then v-order-col = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19".
    if v-order-col1 = "" or v-order-col1 = ? then v-order-col1 = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21".
 end.
  DEFINE temp-table temp-fin-ob no-undo
    field   ri             as  recid
    field   ind            as integer
    field   del            as logical
    INDEX pi  IS PRIMARY   ind
    INDEX pi1  ri
    INDEX pi2  del
  .
  DEFINE temp-table temp-fin-doc no-undo
    field   ri             as  recid
    field   ind            as integer
    field   del            as logical
    INDEX pi  IS PRIMARY   ind
    INDEX pi1  ri
    INDEX pi2  del
  .
  DEFINE temp-table tp-contr no-undo
    field   id             as integer
    INDEX pi  IS PRIMARY   id
  .
  define buffer temp-contr   for tp-contr.
  define buffer temp-contr1  for tp-contr.
DEFINE TEMP-TABLE temp_fin-ob NO-UNDO LIKE fin-ob
       field no-con-sum as decimal
       field ri as recid .
FUNCTION contract-gen RETURNS CHARACTER
  ( input p-contract-code as integer )  FORWARD.
FUNCTION contract-id RETURNS CHARACTER
  ( input p-contract-code as integer )  FORWARD.
FUNCTION get-curr-sum RETURNS decimal
  ( input p-cur as integer, input p-doc-curr as integer, input p-cur-contr as integer, input p-sum-contract as decimal, input p-sum-rubl as decimal, input p-sum-base as decimal, input p-sum-doc as decimal )  FORWARD.
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer )  FORWARD.
FUNCTION get-free-sum RETURNS decimal
  ( BUFFER loc-fin-ob FOR fin-ob )  FORWARD.
FUNCTION get-free-sum1 RETURNS decimal
  ( BUFFER loc-fin-doc FOR fin-doc )  FORWARD.
FUNCTION get-ostat RETURNS decimal
  ( input p-sum1 as decimal, input p-sum2 as decimal )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input typ as integer )  FORWARD.
DEFINE BUTTON B-allmark
     LABEL "Вд.*"
     SIZE 5 BY 1.
DEFINE BUTTON B-allmark-2
     LABEL "Вд.*"
     SIZE 5 BY 1.
DEFINE BUTTON B-conn-add
     LABEL "Соз&д.св."
     SIZE 10 BY 1.
DEFINE BUTTON B-conn-doc
     LABEL "Связи пл."
     SIZE 10 BY 1.
DEFINE BUTTON B-conn-fo
     LABEL "Связи ф-о"
     SIZE 10 BY 1.
DEFINE BUTTON B-conn-view
     LABEL "Свя&зи все"
     SIZE 10 BY 1.
DEFINE BUTTON B-date
     LABEL "Применить"
     SIZE 10 BY 1.04
     FGCOLOR 4 .
DEFINE BUTTON B-del-doc
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-mark-2
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-oplat
     LABEL "О&платить"
     SIZE 10 BY 1.
DEFINE BUTTON B-oplat-list
     LABEL "Cписок"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-unmark
     LABEL "Сн.*"
     SIZE 5 BY 1.
DEFINE BUTTON B-unmark-2
     LABEL "Сн.*"
     SIZE 5 BY 1.
DEFINE BUTTON B-view-doc
     LABEL "Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-view-fo
     LABEL "Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "1"
     SIZE 2.75 BY 1.
DEFINE VARIABLE cli-code AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "код"
     VIEW-AS FILL-IN
     SIZE 6 BY .93.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(14)"
     LABEL "Наим."
     VIEW-AS FILL-IN
     SIZE 14.5 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY .93.
DEFINE VARIABLE curr-name AS CHARACTER FORMAT "X(5)":U
      VIEW-AS TEXT
     SIZE 4.13 BY 1 NO-UNDO.
DEFINE VARIABLE date-1 AS DATE FORMAT "99/99/9999"
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE date-2 AS DATE FORMAT "99/99/9999"
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num-2 AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE s-curr-code AS INTEGER FORMAT ">>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)"
     LABEL "&Нач. номера"
     VIEW-AS FILL-IN
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sum-fin-doc AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE sum-fin-ob AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 18.25 BY 1 NO-UNDO.
DEFINE VARIABLE Curr-Types AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 8 BY 1.82 NO-UNDO.
DEFINE VARIABLE RADIO-find-cli AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Плательщик", 1,
"Получатель", 2
     SIZE 13.38 BY 2.07 NO-UNDO.
DEFINE VARIABLE RADIO-find-doc AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Фин.обяз.", 1,
"Платежи", 2
     SIZE 12 BY 1.89 NO-UNDO.
DEFINE VARIABLE Sel-Client AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 8 BY 1.82 NO-UNDO.
DEFINE VARIABLE Sel-Contr AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 8 BY 1.82 NO-UNDO.
DEFINE VARIABLE Sel-Status AS CHARACTER INITIAL "new"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all",
"Не факт", "new",
"Факт", "fact"
     SIZE 10 BY 1.74 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 132.75 BY 2.33.
DEFINE RECTANGLE RECT-status
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 133 BY 2.22.
DEFINE QUERY Fin-Doc-List FOR
      buf_fin-doc,
      temp-contr1 SCROLLING.
DEFINE QUERY Fin-Ob-List FOR
      buf_fin-ob,
      temp-contr SCROLLING.
DEFINE BROWSE Fin-Doc-List
  QUERY Fin-Doc-List DISPLAY
     mark-string(recid(ub.buf_fin-doc), 1)    COLUMN-LABEL '*'  FORMAT "x(1)"
     buf_fin-doc.fin-doc-type    COLUMN-LABEL 'Тип'  Format "x(3)"
     buf_fin-doc.prn-doc-code    COLUMN-LABEL '№ док-та'  Format "x(9)"
     buf_fin-doc.doc-date    COLUMN-LABEL 'Создан'  format "99/99/99"
     buf_fin-doc.sum-doc   COLUMN-LABEL 'Сумма в валюте док-та'
     (buf_fin-doc.payer-type + ' ' + string(buf_fin-doc.payer-code))    COLUMN-LABEL 'Код плател.'  Format "x(16)"
     buf_fin-doc.payer-name   COLUMN-LABEL 'Плательщик' Format "x(50)"
     (contract-id( buf_fin-doc.contract-code))  @ p-contr COLUMN-LABEL 'Договор' Format "x(16)"
     buf_fin-doc.con-sum-contr   COLUMN-LABEL 'Сумма связи (в.д.)'  Format "->>>,>>>,>>>,>>>.99"
     get-ostat(buf_fin-doc.sum-contr, buf_fin-doc.con-sum-contr)   COLUMN-LABEL 'Своб. остаток (в.д.)'  Format "->>>,>>>,>>>,>>>.99"
     (get-currency(buf_fin-doc.curr-code)) @ l-curr  COLUMN-LABEL 'Вал' Format "x(3)"
     buf_fin-doc.sum-doc   COLUMN-LABEL 'Сумма в валюте док-та'
     (buf_fin-doc.receiver-type + ' ' + string(buf_fin-doc.receiver-code))    COLUMN-LABEL 'Код получ.'  Format "x(10)"
     buf_fin-doc.receiver-name   COLUMN-LABEL 'Получатель' Format "x(50)"
     buf_fin-doc.perm-date    COLUMN-LABEL 'Разр.'  format "99/99/99"
     buf_fin-doc.pay-date    COLUMN-LABEL 'Платеж'  format "99/99/99"
     buf_fin-doc.fact-date   COLUMN-LABEL 'Закрыт' format "99/99/99"
     buf_fin-doc.status_    COLUMN-LABEL 'Статус'  Format "x(6)"
     (get-currency(buf_fin-doc.curr-code)) @ l-curr  COLUMN-LABEL 'Вал' Format "x(3)"
     get-curr-sum(s-curr-code, buf_fin-doc.curr-code, buf_fin-doc.contract-curr, buf_fin-doc.sum-contr, buf_fin-doc.sum-rubl, buf_fin-doc.sum-base, buf_fin-doc.sum-doc ) @ p-sum   COLUMN-LABEL 'Сумма в выбр.вал.'  Format "->>>,>>>,>>>,>>>.99"
     buf_fin-doc.fin-ext-doc-type   COLUMN-LABEL 'Расш.тип' Format "x(3)"
     buf_fin-doc.fin-doc-code   COLUMN-LABEL 'Вн.N'
     (if buf_fin-doc.obj-code = 0 then '' else (buf_fin-doc.obj-type + ' ' + string(buf_fin-doc.obj-code)))   COLUMN-LABEL 'Объект'
     enable buf_fin-doc.fin-doc-type
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74 BY 16.07 ROW-HEIGHT-CHARS .78.
DEFINE BROWSE Fin-Ob-List
  QUERY Fin-Ob-List DISPLAY
      mark-string(recid(ub.buf_fin-ob), 0)    COLUMN-LABEL '*'  FORMAT "x(1)"
     buf_fin-ob.doc-date    COLUMN-LABEL 'Создан'  format "99/99/99"
     buf_fin-ob.sum-doc   COLUMN-LABEL 'Сумма в вал. док-та'
     (buf_fin-ob.payer-type + ' ' + string(buf_fin-ob.payer-code))    COLUMN-LABEL 'Код плател.'  Format "x(16)"
     buf_fin-ob.payer-name   COLUMN-LABEL 'Плательщик'  Format "x(50)"
     (contract-id( buf_fin-ob.contract-code )) @ p-contr   COLUMN-LABEL 'Договор' Format "x(16)"
     buf_fin-ob.prn-doc-code    COLUMN-LABEL '№ док-та'  Format "x(9)"
     buf_fin-ob.doc-type    COLUMN-LABEL 'Т'  Format "x(1)"
     buf_fin-ob.pay-date    COLUMN-LABEL 'Платеж'  format "99/99/99"
     buf_fin-ob.con-sum-contr   COLUMN-LABEL 'Сумма связи (в.д.)'  Format "->>>,>>>,>>>,>>>.99"
     get-ostat(buf_fin-ob.sum-contr, buf_fin-ob.con-sum-contr)   COLUMN-LABEL 'Своб. остаток (в.д.)'  Format "->>>,>>>,>>>,>>>.99"
     buf_fin-ob.fact-date    COLUMN-LABEL 'Закрыт'  format "99/99/99"
     (buf_fin-ob.receiver-type + ' ' + string(buf_fin-ob.receiver-code))    COLUMN-LABEL 'Код получ.'  Format "x(10)"
     buf_fin-ob.receiver-name   COLUMN-LABEL 'Получатель'  Format "x(50)"
     (get-currency(buf_fin-ob.curr-code))  @ l-curr COLUMN-LABEL 'Вал' Format "x(3)"
     get-curr-sum(s-curr-code, buf_fin-ob.curr-code, buf_fin-ob.contract-curr, buf_fin-ob.sum-contract, buf_fin-ob.sum-rubl, buf_fin-ob.sum-base, buf_fin-ob.sum-doc ) @ p-sum  COLUMN-LABEL 'Сумма в выбр.вал.' Format "->>>,>>>,>>>,>>>.99"
     (if buf_fin-ob.obj-code = 0 then '' else (buf_fin-ob.obj-type + ' ' + string(buf_fin-ob.obj-code)))   COLUMN-LABEL 'Объект' Format "x(14)"
     buf_fin-ob.doc-code   COLUMN-LABEL 'Вн.N' Format "x(10)"
     (contract-gen( buf_fin-ob.contract-code))  @ p-gen  COLUMN-LABEL 'Условие генерации' Format "x(50)"
     enable buf_fin-ob.doc-type
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74 BY 16.07 ROW-HEIGHT-CHARS .78.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-conn-add AT ROW 1 COL 11
     B-conn-view AT ROW 1 COL 21
     B-oplat-list AT ROW 1 COL 31
     B-Help AT ROW 1 COL 121
     B-conn-doc AT ROW 2.04 COL 11
     B-view-doc AT ROW 2.04 COL 21
     B-del-doc AT ROW 2.04 COL 31
     B-conn-fo AT ROW 2.04 COL 111
     B-view-fo AT ROW 2.04 COL 121
     Fin-Ob-List AT ROW 3.07 COL 76
     Fin-Doc-List AT ROW 3.11 COL 1.5
     B-mark-2 AT ROW 19.41 COL 1.5
     B-unmark-2 AT ROW 19.41 COL 9.5
     B-allmark-2 AT ROW 19.41 COL 15
     sum-fin-doc AT ROW 19.41 COL 31.5 COLON-ALIGNED
     B-mark AT ROW 19.41 COL 77
     B-unmark AT ROW 19.41 COL 85
     B-allmark AT ROW 19.41 COL 90
     B-oplat AT ROW 19.41 COL 95
     sum-fin-ob AT ROW 19.41 COL 105 COLON-ALIGNED NO-LABEL
     BUTTON-cli AT ROW 20.85 COL 97.88
     sch-code AT ROW 20.93 COL 35.5 COLON-ALIGNED
     RADIO-find-cli AT ROW 20.93 COL 64.5 NO-LABEL
     cli-code AT ROW 20.93 COL 84.5 COLON-ALIGNED
     cli-type AT ROW 20.93 COL 91 COLON-ALIGNED NO-LABEL
     RADIO-find-doc AT ROW 20.96 COL 10.38 NO-LABEL
     BUTTON-curr AT ROW 21.89 COL 120.88
     s-curr-code AT ROW 21.93 COL 110 COLON-ALIGNED NO-LABEL
     sch-date AT ROW 21.96 COL 35.5 COLON-ALIGNED
     cli-name AT ROW 21.96 COL 84.5 COLON-ALIGNED
     Curr-Types AT ROW 23.41 COL 11 NO-LABEL
     Sel-Client AT ROW 23.41 COL 39.5 NO-LABEL
     Sel-Contr AT ROW 23.41 COL 63 NO-LABEL
     date-1 AT ROW 23.41 COL 94.25 COLON-ALIGNED
     Sel-Status AT ROW 23.41 COL 121 NO-LABEL
     B-date AT ROW 24.22 COL 81.5
     date-2 AT ROW 24.3 COL 94.38 COLON-ALIGNED
     mark-num-2 AT ROW 19.41 COL 4.5 NO-LABEL
     mark-num AT ROW 19.41 COL 80 NO-LABEL
     curr-name AT ROW 21.85 COL 115.63 NO-LABEL
     "Договоры:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 23.37 COL 51.5
          FGCOLOR 4
     "Валюта:" VIEW-AS TEXT
          SIZE 7.5 BY .93 AT ROW 23.41 COL 1.5
          FGCOLOR 4
     "Платежи:" VIEW-AS TEXT
          SIZE 8.88 BY .93 AT ROW 2.04 COL 2
          FGCOLOR 4
     "Показ в валюте:" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 20.96 COL 108.5
          FGCOLOR 4
     "Платеж:" VIEW-AS TEXT
          SIZE 8.13 BY .93 AT ROW 23.33 COL 81.88
          FGCOLOR 4
     "Контрагенты:" VIEW-AS TEXT
          SIZE 11 BY 1 AT ROW 23.41 COL 27
          FGCOLOR 4
     "Стат.пл.:" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 23.37 COL 110.5
          FGCOLOR 4
     "Фин. обязательства:" VIEW-AS TEXT
          SIZE 22 BY .93 AT ROW 2.04 COL 76.5
          FGCOLOR 4
     "Поиск:" VIEW-AS TEXT
          SIZE 7.38 BY .93 AT ROW 21 COL 1.88
          FGCOLOR 4
     RECT-status AT ROW 23.26 COL 1.25
     RECT-1 AT ROW 20.82 COL 1.38 WIDGET-ID 2
     SPACE(15.87) SKIP(2.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Планирование платежей"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-allmark IN FRAME Dialog-Frame
DO:
  if num-fin-doc > 1 then do:
    message "У вас выбрано более одного платежа, в этом случае можно выбрать только 1 фин. обязательство!" view-as alert-box ERROR.
    return no-apply.
  end.
  for each temp-fin-ob: delete temp-fin-ob . end.
  assign
    sum-fin-ob = 0
    num-fin-ob = 0
    ind1 = 0
  .
  GET FIRST Fin-Ob-List NO-LOCK .
  DO WHILE AVAILABLE(buf_fin-ob):
    create temp-fin-ob .
    assign
      temp-fin-ob.ri = recid( buf_fin-ob )
      temp-fin-ob.ind = ind1
      ind1 = ind1 + 1
      num-fin-ob = num-fin-ob + 1
      temp-fin-ob.del = no
    .
    assign  sum-fin-ob = sum-fin-ob + get-free-sum(buffer buf_fin-ob) .
    GET next Fin-Ob-List NO-LOCK .
  end.
  if num-fin-ob = 0 then hide mark-num in frame Dialog-Frame.
  else                   display num-fin-ob @ mark-num  with frame Dialog-Frame.
  display sum-fin-ob  with frame Dialog-Frame.
  RUN OpenBr(yes, no, '':U) .
END.
ON CHOOSE OF B-allmark-2 IN FRAME Dialog-Frame
DO:
  if num-fin-ob > 1 then do:
    message "У вас выбрано более одного фин. обязательства, в этом случае можно выбрать только 1 платеж!" view-as alert-box ERROR.
    return no-apply.
  end.
  for each temp-fin-doc: delete temp-fin-doc . end.
  assign
    sum-fin-doc = 0
    num-fin-doc = 0
    ind1 = 0
  .
  GET FIRST Fin-Doc-List NO-LOCK .
  DO WHILE AVAILABLE(buf_fin-doc):
    create temp-fin-doc .
    assign
      temp-fin-doc.ri = recid( buf_fin-doc )
      temp-fin-doc.ind = ind1
      ind1 = ind1 + 1
      num-fin-doc = num-fin-doc + 1
      temp-fin-doc.del = no
    .
    assign  sum-fin-doc = sum-fin-doc + get-free-sum1(buffer buf_fin-doc) .
    GET next Fin-Doc-List NO-LOCK .
  end.
  if num-fin-doc = 0 then hide mark-num-2 in frame Dialog-Frame.
  else                   display num-fin-doc @ mark-num-2  with frame Dialog-Frame.
  display sum-fin-doc  with frame Dialog-Frame.
  RUN OpenBr1(yes, no, '':U) .
END.
ON CHOOSE OF B-conn-add IN FRAME Dialog-Frame
DO:
  if num-fin-ob > 0 and num-fin-doc > 0 then do:
    run proc-check-contract no-error  .
    if error-status:error then return no-apply.
    assign v-list = "" .
    if num-fin-ob = 1 and num-fin-doc > 1 then do:
      find first temp-fin-ob .
      for each temp-fin-doc :
        if v-list = "" then  assign v-list = string(temp-fin-doc.ri) .
        else  assign v-list = v-list + "," + string(temp-fin-doc.ri) .
      end.
      run str/fin-con2.w ( parParentProc, v-cntxt-host-code-obj, temp-fin-ob.ri, v-list, output v-end) .
      if v-end then do:
        for each temp-fin-doc :
          find first fin-doc no-lock where recid (fin-doc) = temp-fin-doc.ri .
          if fin-doc.con-stat = 2 then delete temp-fin-doc .
        end.
        RUN OpenBr(yes, no, '':U) .
        RUN OpenBr1(yes, no, '':U) .
      end.
    end.
    else do:
      find first temp-fin-doc .
      for each temp-fin-ob :
        if v-list = "" then  assign v-list = string(temp-fin-ob.ri) .
        else  assign v-list = v-list + "," + string(temp-fin-ob.ri) .
      end.
      run str/fin-con1.w ( parParentProc, v-cntxt-host-code-obj, temp-fin-doc.ri, v-list, output v-end) .
      if v-end then do:
        for each temp-fin-ob :
          find first fin-ob no-lock where recid (fin-ob) = temp-fin-ob.ri .
          if fin-ob.con-stat = 2 then delete temp-fin-ob .
        end.
        RUN OpenBr(yes, no, '':U) .
        RUN OpenBr1(yes, no, '':U) .
      end.
    end.
  end.
  else do:
    message "Нет выбранных фин. обязательств или платежей!" view-as alert-box error .
  end.
END.
ON CHOOSE OF B-conn-doc IN FRAME Dialog-Frame
DO:
  if available buf_fin-doc then do:
    run str/finconn.w ( input parParentProc, input v-cntxt-host-code-obj, input p-doc-type, input "fin-doc", input string(buf_fin-doc.fin-doc-code)) .
    RUN OpenBr(yes, no, '':U) .
    RUN OpenBr1(yes, no, '':U) .
  end.
END.
ON CHOOSE OF B-conn-fo IN FRAME Dialog-Frame
DO:
  if available buf_fin-ob then do:
    run str/finconn.w ( input parParentProc, input v-cntxt-host-code-obj, input p-doc-type, input "fin-ob", input buf_fin-ob.doc-code) .
    RUN OpenBr(yes, no, '':U) .
    RUN OpenBr1(yes, no, '':U) .
  end.
END.
ON CHOOSE OF B-conn-view IN FRAME Dialog-Frame
DO:
  define variable rr as integer initial 0  no-undo .
  run str/finconn.w ( input parParentProc, input v-cntxt-host-code-obj, input p-doc-type, input "all", input "" ) .
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON CHOOSE OF B-date IN FRAME Dialog-Frame
DO:
  assign date-1 date-2 .
  if date-1 = ? and date-2 = ? then do:
    assign sel-date = no .
  end.
  else do:
    assign sel-date = yes .
    if date-1 = ? then assign date-1 = 1/1/1900 .
    if date-2 = ? then assign date-2 = 1/1/3000 .
  end.
  RUN OpenBr(yes, no, '':U) .
END.
ON CHOOSE OF B-del-doc IN FRAME Dialog-Frame
DO:
  if not available buf_fin-doc then return.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-doc_deletion':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
  if not g-log then return.
  find first fin-doc exclusive-lock where recid(fin-doc) = recid(buf_fin-doc) NO-ERROR.
  if not avail fin-doc then return no-apply.
  IF fin-doc.status_ <> 'новый':U  THEN DO:
    MESSAGE "Платеж закрыт - удалять нельзя!"  VIEW-AS ALERT-BOX ERROR.
    RETURN .
  END.
  g-log = no.
  MESSAGE
    "Вы уверены, что хотите удалить платеж N " fin-doc.prn-doc-code " от " string(fin-doc.doc-date,"99/99/9999") "?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE g-log.
  IF g-log <> YES THEN RETURN .
  do on error undo, return on stop undo, return no-apply :
    run trg/findocdl.p ( input parParentProc
                         ,input fin-doc.host-code
                         ,input fin-doc.fin-doc-code
                         ,input no
                         ,input no) no-error.
  end.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  if available buf_fin-ob then   do:
    find first temp-fin-ob where temp-fin-ob.ri = recid( buf_fin-ob ) no-error  .
    if available temp-fin-ob then do:
      delete temp-fin-ob .
      assign
        sum-fin-ob = sum-fin-ob - get-free-sum(buffer buf_fin-ob)
        num-fin-ob = num-fin-ob - 1
      .
    end.
    else do:
      if num-fin-doc > 1 and num-fin-ob > 0 then do:
        message "У вас выбрано более одного платежа, в этом случае можно выбрать только 1 фин. обязательство!" view-as alert-box ERROR.
        return no-apply.
      end.
      create temp-fin-ob .
      assign
        temp-fin-ob.ri = recid( buf_fin-ob )
        temp-fin-ob.ind = ind1
        ind1 = ind1 + 1
        num-fin-ob = num-fin-ob + 1
      .
      assign  sum-fin-ob = sum-fin-ob + get-free-sum(buffer buf_fin-ob) .
    end.
    g-log = Fin-Ob-List:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Fin-Ob-List:select-next-row ().
      apply "value-changed" to Fin-Ob-List in frame Dialog-Frame.
    end.
    if num-fin-ob = 0 then hide mark-num in frame Dialog-Frame.
    else                   display num-fin-ob @ mark-num  with frame Dialog-Frame.
    display sum-fin-ob  with frame Dialog-Frame.
  end.
  apply "entry" to Fin-Ob-List .
END.
ON CHOOSE OF B-mark-2 IN FRAME Dialog-Frame
DO:
  if available buf_fin-doc then   do:
    find first temp-fin-doc where temp-fin-doc.ri = recid( buf_fin-doc ) no-error  .
    if available temp-fin-doc then do:
      delete temp-fin-doc .
      assign
        sum-fin-doc = sum-fin-doc - get-free-sum1(buffer buf_fin-doc)
        num-fin-doc = num-fin-doc - 1
      .
    end.
    else do:
      if num-fin-ob > 1 and num-fin-doc > 0 then do:
        message "У вас выбрано более одного фин. обязательства, в этом случае можно выбрать только 1 платеж!" view-as alert-box ERROR.
        return no-apply.
      end.
      create temp-fin-doc .
      assign
        temp-fin-doc.ri = recid( buf_fin-doc )
        temp-fin-doc.ind = ind2
        ind2 = ind2 + 1
        num-fin-doc = num-fin-doc + 1
      .
      assign  sum-fin-doc = sum-fin-doc + get-free-sum1(buffer buf_fin-doc) .
    end.
    g-log = Fin-Doc-List:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Fin-Doc-List:select-next-row ().
      apply "value-changed" to Fin-Doc-List in frame Dialog-Frame.
    end.
    if num-fin-doc = 0 then hide mark-num-2 in frame Dialog-Frame.
    else                   display num-fin-doc @ mark-num-2  with frame Dialog-Frame.
    display sum-fin-doc  with frame Dialog-Frame.
  end.
  apply "entry" to Fin-Doc-List .
END.
ON CHOOSE OF B-oplat IN FRAME Dialog-Frame
DO:
  if num-fin-ob < 1 then do:
    message "Нет выбранных фин. обязательств!" view-as alert-box error .
    return no-apply .
  end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-doc_add-def':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
  if not g-log then return no-apply.
  define variable v-ri as recid initial ? no-undo .
  run str/payfinob.w ( input parParentProc, input v-cntxt-host-code-obj, input table temp-fin-ob, output v-ri) no-error  .
  if error-status:error then return no-apply.
  assign v-list = "" .
  if v-ri <> ? then do:
    for each temp-fin-ob :
      if v-list = "" then assign v-list = string(temp-fin-ob.ri) .
      else assign v-list = v-list + "," + string(temp-fin-ob.ri) .
    end.
    assign v-conn-avt = "no" .
    run gbl/conf-rd.p ( input "fincnavt"
                        ,input v-cntxt-host-code-obj
                        ,input ""
                        ,input 0
                        ,input ""
                        ,input ""
                        ,input ""
                        ,input no
                        ,output v-conn-avt
                        ,output v-par-type) no-error.
    if v-conn-avt = "no" then do:
      run str/fin-con1.w ( parParentProc, v-cntxt-host-code-obj, v-ri, v-list, output v-end) .
    end.
    else do:
      assign v-end = yes .
      run conn-avt ( v-ri, v-list ) .
    end.
    if v-end then do:
      for each temp-fin-ob :
        find first fin-ob no-lock where recid (fin-ob) = temp-fin-ob.ri .
        if fin-ob.con-stat = 2 then delete temp-fin-ob .
      end.
    end.
    RUN OpenBr(yes, no, '':U) .
    RUN OpenBr1(yes, no, '':U) .
  END.
END.
ON CHOOSE OF B-oplat-list IN FRAME Dialog-Frame
DO:
  run str/paypvavt.p (v-cntxt-host-code-obj) no-error  .
  if error-status:error then return no-apply.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  define variable cur-clmn-loc as integer   no-undo .
  define variable column-handle as handle no-undo .
  define variable v-list as character no-undo .
  define variable v-i as integer   no-undo .
  define variable v-pos as integer   no-undo .
  define variable v-list-new as character no-undo .
  define variable v-elem as character no-undo .
  define variable v-list-str as character no-undo .
  define variable v-list-str1 as character no-undo .
  assign
    cur-clmn-loc  = 1
    column-handle = Fin-Ob-List:first-column
    v-list        = column-handle:label + "#"
    v-list-new = ""
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = Fin-Ob-List:num-columns then leave .
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.
  v-list = trim(v-list, "#") .
  repeat v-i = 1 to Fin-Ob-List:num-columns :
    v-elem = entry( v-i, v-list , "#") .
    v-pos = lookup( v-elem, '*' + '#' +  'Т' + '#' +  '№ док-та' + '#' +  'Платеж' + '#' +  'Сумма в вал. док-та' + '#' +  'Сумма связи (в.д.)' + '#' +  'Своб. остаток (в.д.)' + '#' +  'Закрыт' + '#' +  'Договор' + '#' +  'Код получ.' + '#' +  'Получатель' + '#' +  'Код плател.' + '#' +  'Плательщик' + '#' +  'Создан' + '#' +  'Вал' + '#' +  'Сумма в выбр.вал.' + '#' +  'Объект' + '#' +  'Вн.N' + '#' +  'Условие генерации' , "#") .
  end.
  v-list-str = "" .
  repeat v-i = 1 to num-entries(v-list-new) :
    v-elem = entry(v-i , v-list-new ) .
    if int(v-elem) > 1 then  v-list-str  = v-list-str + v-elem + "," .
  end.
  assign
    cur-clmn-loc  = 1
    column-handle = Fin-Doc-List:first-column
    v-list        = column-handle:label + "#"
    v-list-new = ""
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = Fin-Doc-List:num-columns then leave .
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.
  v-list = trim(v-list, "#") .
  repeat v-i = 1 to Fin-Doc-List:num-columns :
    v-elem = entry( v-i, v-list , "#") .
    v-pos = lookup( v-elem, '*' + '#' +  'Тип' + '#' +  'Статус' + '#' +  '№ док-та' + '#' +  'Создан' + '#' +  'Сумма в валюте док-та' + '#' +  'Сумма связи (в.д.)' + '#' +  'Своб. остаток (в.д.)' + '#' +  'Договор' + '#' +  'Код получ.' + '#' +  'Получатель' + '#' +  'Код плател.' + '#' +  'Плательщик' + '#' +  'Разр.' + '#' +  'Платеж' + '#' +  'Закрыт' + '#' +  'Вал' + '#' +  'Сумма в выбр.вал.' + '#' +  'Расш.тип' + '#' +  'Вн.N' + '#' +  'Объект' , "#") .
    v-list-new = v-list-new + string(v-pos) + "," .
  end.
  v-list-str1 = "" .
  repeat v-i = 1 to num-entries(v-list-new) :
    v-elem = entry(v-i , v-list-new ) .
    if int(v-elem) > 1 then  v-list-str1  = v-list-str1 + v-elem + "," .
  end.
    v-list-new = "".
  run uf-set in this-procedure(
    input  'planplat-p':U
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
  ) no-error    .
  if error-status :error then  message vss-workfile vss-revision vss-description skip error-status :get-message(1) skip return-value skip "uf-set" view-as alert-box error .
END.
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame
DO:
  GET FIRST Fin-Ob-List NO-LOCK .
  if not available buf_fin-ob then return.
  for each temp-fin-ob: delete temp-fin-ob . end.
  assign
    sum-fin-ob = 0
    num-fin-ob = 0
  .
  g-log = Fin-Ob-List:refresh() .
  if num-fin-ob = 0 then hide mark-num in frame Dialog-Frame.
  else                   display num-fin-ob @ mark-num  with frame Dialog-Frame.
  display sum-fin-ob  with frame Dialog-Frame.
END.
ON CHOOSE OF B-unmark-2 IN FRAME Dialog-Frame
DO:
  GET FIRST Fin-Doc-List NO-LOCK .
  if not available buf_fin-doc then return.
  for each temp-fin-doc: delete temp-fin-doc . end.
  assign
    sum-fin-doc = 0
    num-fin-doc = 0
  .
  g-log = Fin-Doc-List:refresh() .
  if num-fin-doc = 0 then hide mark-num-2 in frame Dialog-Frame.
  else                 display num-fin-doc @ mark-num-2  with frame Dialog-Frame.
  display sum-fin-doc  with frame Dialog-Frame.
END.
ON CHOOSE OF B-view-doc IN FRAME Dialog-Frame
DO:
  if not available buf_fin-doc then return.
  run ref/showfind.p (
                       input parParentProc
                      ,input v-cntxt-host-code-obj
                      ,input buf_fin-doc.host-code
                      ,input buf_fin-doc.fin-doc-code
                      ).
END.
ON CHOOSE OF B-view-fo IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_lookup':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
  if not g-log then  return .
  define variable rr as recid no-undo .
  if not available buf_fin-ob then return.
  run str/sh-finob.p ( input parParentProc, input v-cntxt-host-code-obj, input recid(buf_fin-ob)).
END.
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame
DO:
  define variable agnt-list as character no-undo .
  run ref/cli-all.w (parParentProc, "b-sel", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first clients no-lock where RECID(clients) = int (agnt-list) no-error.
    if clients.obj-type <> 'чел':U and clients.obj-type <> 'орг':U then do:
      message "Контрагент может быть только " 'орг':U " или " 'чел':U view-as alert-box ERROR .
      return no-apply.
    end.
    assign cli-name  = clients.obj-name  cli-code = clients.obj-code  cli-type = clients.obj-type.
  end.
  else assign cli-name = ""   cli-code = ?  cli-type  = ? .
  display cli-name    cli-code     cli-type   with frame Dialog-Frame.
  run proc-find-cli in this-procedure(no, input cli-code, input cli-type ) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF BUTTON-curr IN FRAME Dialog-Frame
DO:
  define variable ri as recid init ? no-undo .
  run ref/currency.w ( input parparentproc
                      ,input "b-sel"
                      ,input-output ri ).
  if ri = ? then return no-apply.
  find currency where recid ( currency ) = ri no-lock.
  assign
    s-curr-code = currency.curr-code
    curr-name = currency.curr-abbr
  .
  display curr-name s-curr-code with frame Dialog-Frame.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON CTRL-J OF cli-code IN FRAME Dialog-Frame
DO:
  run proc-find-cli  in this-procedure(yes, input cli-code, input cli-type ) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF cli-code IN FRAME Dialog-Frame
DO:
  assign cli-code.
  run find-cli in this-procedure (input cli-type, input cli-code)  .
END.
ON CTRL-J OF cli-name IN FRAME Dialog-Frame
DO:
  assign cli-name .
  run proc-find-cli-name in this-procedure(yes, input frame Dialog-Frame cli-name ) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF cli-name IN FRAME Dialog-Frame
DO:
  assign cli-name .
  run proc-find-cli-name  in this-procedure(no, input frame Dialog-Frame cli-name ) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-type.
  run find-cli in this-procedure (input cli-type, input cli-code)  .
END.
ON RETURN OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  run find-cli in this-procedure (input cli-type, input cli-code)  .
END.
ON VALUE-CHANGED OF Curr-Types IN FRAME Dialog-Frame
DO:
  assign Curr-Types .
  define variable ref-rec as recid init ? no-undo .
  if Curr-Types = "sel" then do:
    run ref/currency.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output ref-rec ).
    if ref-rec = ? then do:
      assign Curr-Types = "all" .
      display Curr-Types with frame Dialog-Frame.
    end.
    else do:
      find first  currency where recid ( currency ) = ref-rec no-lock.
      assign curr-code = currency.curr-code .
    end.
  end.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON RETURN OF Fin-Doc-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Fin-Doc-List IN FRAME Dialog-Frame
DO:
    if b-mark-2:sensitive then apply "choose" to b-mark-2 in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF Fin-Doc-List IN FRAME Dialog-Frame
DO:
  v-payer-code = buf_fin-doc.payer-code.
  v-payer-type = buf_fin-doc.payer-type.
  OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob where buf_fin-ob.payer-code = v-payer-code and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 NO-LOCK,        first temp-contr.
END.
ON RETURN OF Fin-Ob-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Fin-Ob-List IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RADIO-find-cli IN FRAME Dialog-Frame
DO:
  assign RADIO-find-cli .
  if cli-code <> ? and cli-code <> 0 then apply "return" to cli-code in frame Dialog-Frame.
  else if cli-name <> "" then apply "return" to cli-name in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RADIO-find-doc IN FRAME Dialog-Frame
DO:
  assign RADIO-find-doc .
  if sch-code <> "" then apply "return" to sch-code in frame Dialog-Frame.
  else do:
    if sch-date <> ? and sch-date <> ? and sch-date:screen-value <> "  /  /" then apply "return" to sch-date in frame Dialog-Frame.
    else do:
      if cli-code <> ? and cli-code <> 0 then apply "return" to cli-code in frame Dialog-Frame.
      else if cli-name <> "" then apply "return" to cli-name in frame Dialog-Frame.
    end.
  end.
END.
ON LEAVE OF s-curr-code IN FRAME Dialog-Frame
DO:
  assign s-curr-code .
  define variable ri as recid init ? no-undo .
  find first currency where currency.curr-code = s-curr-code no-error.
  if not available currency then do:
    run ref/currency.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output ri ).
    if ri = ? then return no-apply.
    find currency where recid ( currency ) = ri .
  end.
  assign
    curr-name = currency.curr-abbr
    s-curr-code = currency.curr-code
  .
  display s-curr-code curr-name with frame Dialog-Frame.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON RETURN OF s-curr-code IN FRAME Dialog-Frame
DO:
  assign s-curr-code .
  define variable ri as recid init ? no-undo .
  find first currency where currency.curr-code = s-curr-code no-error.
  if not available currency then do:
    run ref/currency.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output ri ).
    if ri = ? then return no-apply.
    find currency where recid ( currency ) = ri .
  end.
  assign
    curr-name = currency.curr-abbr
    s-curr-code = currency.curr-code
  .
  display s-curr-code curr-name with frame Dialog-Frame.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code  in this-procedure(yes, input frame Dialog-Frame sch-code ) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code  in this-procedure(no, input frame Dialog-Frame sch-code ) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure(yes, input frame Dialog-Frame sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
DO:
  assign sch-date .
  run proc-find-date in this-procedure(no, input sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF Sel-Client IN FRAME Dialog-Frame
DO:
  assign Sel-Client .
  assign cli-list = "" .
  if Sel-Client = "sel" then do:
    run ref/cli-all.w (parParentProc, "b-sel,b-mark", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
    if cli-list = "" then do:
      assign Sel-Client = "all" .
      disp Sel-Client with frame Dialog-Frame.
    end.
    else do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame Dialog-Frame.
      for each temp-contr  where temp-contr.id <> -1 : delete temp-contr . end.
      for each temp-contr1 where temp-contr1.id <> -1 : delete temp-contr1 . end.
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cli-list):
        find first clients no-lock where recid(clients) = integer (entry (ii, cli-list)) .
        for each contract no-lock
          where contract.host-code = v-cntxt-host-code-obj
            and contract.cli-type = clients.obj-type
            and contract.cli-code = clients.obj-code
        :
          create temp-contr .
          assign temp-contr.id = contract.contract-code .
          create temp-contr1 .
          assign temp-contr1.id = contract.contract-code .
        end.
      end.
    end.
  end .
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON VALUE-CHANGED OF Sel-Contr IN FRAME Dialog-Frame
DO:
  assign Sel-Contr .
  if Sel-Client = "all" then do:
    for each temp-contr where temp-contr.id <> -1 : delete temp-contr . end.
    for each temp-contr1 where temp-contr1.id <> -1 : delete temp-contr1 . end.
  end.
  assign cont-list = "" .
  if Sel-Contr = "sel" then do:
    if Sel-Client = "sel" then do:
      find first clients no-lock where recid(clients) = integer (cli-list) .
      run str/cont-all.w ( parParentProc, v-cntxt-host-code-obj, "b-add,b-mark,b-sel", 'фирма':U, clients.obj-type, clients.obj-code, ?, ?, "current":U, p-doc-type, input-output cont-list ) .
    end.
    else do:
      run str/cont-all.w ( parParentProc, v-cntxt-host-code-obj, "b-add,b-mark,b-sel", 'фирма':U, ?, ?, ?, ?, "current":U, p-doc-type, input-output cont-list ) .
    end.
    if cont-list = "" then do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame Dialog-Frame.
    end.
    else do:
      for each temp-contr where temp-contr.id <> -1 : delete temp-contr . end.
      for each temp-contr1 where temp-contr1.id <> -1 : delete temp-contr1 . end.
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cont-list):
        find first contract no-lock where recid(contract) = integer (entry (ii, cont-list)) .
        create temp-contr .
        assign temp-contr.id = contract.contract-code .
        create temp-contr1 .
        assign temp-contr1.id = contract.contract-code .
      end.
    end.
  end .
  else do:
    if Sel-Client = "sel" then do:
        find first clients no-lock where recid(clients) = integer (cli-list) .
        for each contract no-lock
          where contract.host-code = p-host-code
            and contract.cli-type = clients.obj-type
            and contract.cli-code = clients.obj-code
        :
          create temp-contr .
          assign temp-contr.id = contract.contract-code .
          create temp-contr1 .
          assign temp-contr1.id = contract.contract-code .
        end.
    end.
  end.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.
ON VALUE-CHANGED OF Sel-Status IN FRAME Dialog-Frame
DO:
  assign Sel-Status .
  if Sel-Status = "new" then assign p-status = 'новый':U .
  else                       assign p-status = 'факт':U .
  RUN OpenBr1(yes, no, '':U) .
  apply "entry" to Fin-Doc-List .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  Fin-Doc-List :SET-REPOSITIONED-ROW(15, "CONDITIONAL") .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse fin-ob-list :handle
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
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse fin-doc-list :handle
  ) .
run diasize_init in this-procedure .
b-quit:SELECTED = no .
def var sort-labelFin-Ob-List   as character no-undo .
def var sort-clmnFin-Ob-List    as handle    no-undo .
def var cur-clmnFin-Ob-List     as handle    no-undo .
def var cur-clmn-locFin-Ob-List as integer   no-undo .
def var re-queryFin-Ob-List     as logical   initial no no-undo .
on start-search, ctrl-o of Fin-Ob-List in frame Dialog-Frame do:
   run sort-brFin-Ob-List
     (input (if available buf_fin-ob
             then recid(buf_fin-ob)
             else ?
            )
     ).
end.
PROCEDURE sort-brFin-Ob-List :
  define input parameter p-recid as recid no-undo .
  if re-queryFin-Ob-List = no then do:
    assign
       cur-clmnFin-Ob-List = Fin-Ob-List:current-column in frame Dialog-Frame
    .
    if sort-clmnFin-Ob-List <> ? then sort-clmnFin-Ob-List:column-fgcolor = 0.
    if cur-clmnFin-Ob-List = sort-clmnFin-Ob-List then do:
      assign
         sort-labelFin-Ob-List = ""
         sort-clmnFin-Ob-List = ?
      .
     end.
     else do:
       assign
         sort-labelFin-Ob-List = cur-clmnFin-Ob-List:label
         sort-clmnFin-Ob-List  = cur-clmnFin-Ob-List
         sort-clmnFin-Ob-List:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locFin-Ob-List = 1
  .
  def var column-handle as handle no-undo .
  column-handle = Fin-Ob-List:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnFin-Ob-List then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locFin-Ob-List = cur-clmn-locFin-Ob-List + 1
    .
  end.
  case sort-labelFin-Ob-List:
        when 'Т'  then DO:    assign       sort-column-name = "buf_fin-ob.doc-type"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ док-та'  then DO:    assign       sort-column-name = "buf_fin-ob.prn-doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Платеж'  then DO:    assign       sort-column-name = "buf_fin-ob.pay-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в выбр.вал.'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-curr-sum&1,&2,&3,&4,&5,&6,&7,&8)', chr(34), s-curr-code, buf_fin-ob.curr-code, buf_fin-ob.contract-curr, buf_fin-ob.sum-contract, buf_fin-ob.sum-rubl, buf_fin-ob.sum-base, buf_fin-ob.sum-doc)     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма связи (в.д.)'  then DO:    assign       sort-column-name = "buf_fin-ob.con-sum-contr"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Своб. остаток (в.д.)'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-ostat&1,&2,&3)', chr(34), buf_fin-ob.sum-contr, buf_fin-ob.con-sum-contr)     .     run OpenBr(yes, no, '':U).   . END.
        when 'Закрыт'  then DO:    assign       sort-column-name = "buf_fin-ob.fact-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Договор'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-id&1,&2)', chr(34), buf_fin-ob.contract-code)     .     run OpenBr(yes, no, '':U).   . END.
        when 'Код получ.'  then DO:    assign       sort-column-name = "(buf_fin-ob.receiver-type + ' ' + string(buf_fin-ob.receiver-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Получатель'  then DO:    assign       sort-column-name = "buf_fin-ob.receiver-name"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Код плател.'  then DO:    assign       sort-column-name = "(buf_fin-ob.payer-type + ' ' + string(buf_fin-ob.payer-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Плательщик'  then DO:    assign       sort-column-name = "buf_fin-ob.payer-name"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name = "buf_fin-ob.doc-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Вал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-currency&1,&2)', chr(34), buf_fin-ob.curr-code)     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в вал. док-та'  then DO:    assign       sort-column-name = "buf_fin-ob.sum-doc"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "(if buf_fin-ob.obj-code = 0 then '' else (buf_fin-ob.obj-type + ' ' + string(buf_fin-ob.obj-code)))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Вн.N'  then DO:    assign       sort-column-name = "buf_fin-ob.doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Условие генерации'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-gen&1,&2)', chr(34), buf_fin-ob.contract-code)     .     run OpenBr(yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultFin-Ob-List') then do:
          run mv-brw-defaultFin-Ob-List.
        end.
      if sort-labelFin-Ob-List <> "" then do:
        assign
          cur-clmnFin-Ob-List:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locFin-Ob-List = ?
      .
    end.
  end case.
    if cur-clmn-locFin-Ob-List <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnFin-Ob-List') then do:
        run ch-clmnFin-Ob-List in this-procedure (cur-clmn-locFin-Ob-List).
      end.
    end.
  if p-recid <> ? then do:
    reposition Fin-Ob-List to recid p-recid no-error.
    apply "value-changed" to Fin-Ob-List in frame Dialog-Frame.
  end.
  apply "entry" to Fin-Ob-List in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnFin-Ob-List:
if cur-clmnFin-Ob-List = ? then do:
   run OpenBr(yes, no, '':U).
end.
else do:
   assign re-queryFin-Ob-List = yes.
   run sort-brFin-Ob-List
     (input (if available buf_fin-ob
             then recid(buf_fin-ob)
             else ?
            )
     ).
   assign re-queryFin-Ob-List = no.
end.
end.
def var sort-labelFin-Doc-List   as character no-undo .
def var sort-clmnFin-Doc-List    as handle    no-undo .
def var cur-clmnFin-Doc-List     as handle    no-undo .
def var cur-clmn-locFin-Doc-List as integer   no-undo .
def var re-queryFin-Doc-List     as logical   initial no no-undo .
on start-search, ctrl-o of Fin-Doc-List in frame Dialog-Frame do:
   run sort-brFin-Doc-List
     (input (if available buf_fin-doc
             then recid(buf_fin-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brFin-Doc-List :
  define input parameter p-recid as recid no-undo .
  if re-queryFin-Doc-List = no then do:
    assign
       cur-clmnFin-Doc-List = Fin-Doc-List:current-column in frame Dialog-Frame
    .
    if sort-clmnFin-Doc-List <> ? then sort-clmnFin-Doc-List:column-fgcolor = 0.
    if cur-clmnFin-Doc-List = sort-clmnFin-Doc-List then do:
      assign
         sort-labelFin-Doc-List = ""
         sort-clmnFin-Doc-List = ?
      .
     end.
     else do:
       assign
         sort-labelFin-Doc-List = cur-clmnFin-Doc-List:label
         sort-clmnFin-Doc-List  = cur-clmnFin-Doc-List
         sort-clmnFin-Doc-List:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locFin-Doc-List = 1
  .
  def var column-handle as handle no-undo .
  column-handle = Fin-Doc-List:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnFin-Doc-List then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locFin-Doc-List = cur-clmn-locFin-Doc-List + 1
    .
  end.
  case sort-labelFin-Doc-List:
        when 'Тип'  then DO:    assign       sort-column-name1 = "buf_fin-doc.fin-doc-type"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Статус'  then DO:    assign       sort-column-name1 = "buf_fin-doc.status_"     .     run OpenBr1(yes, no, '':U).   . END.
        when '№ док-та'  then DO:    assign       sort-column-name1 = "buf_fin-doc.prn-doc-code"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name1 = "buf_fin-doc.doc-date"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Сумма в выбр.вал.'  then DO:   assign       sort-column-name1 = substitute('dynamic-function(&1get-curr-sum&1,&2,&3,&4,&5,&6,&7,&8)', chr(34), s-curr-code, buf_fin-doc.curr-code, buf_fin-doc.contract-curr, buf_fin-doc.sum-contr, buf_fin-doc.sum-rubl, buf_fin-doc.sum-base, buf_fin-doc.sum-doc)     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Сумма связи (в.д.)'  then DO:    assign       sort-column-name1 = "buf_fin-doc.con-sum-contr"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Своб. остаток (в.д.)'  then DO:   assign       sort-column-name1 = substitute('dynamic-function(&1get-ostat&1,&2,&3)', chr(34), buf_fin-doc.sum-contr, buf_fin-doc.con-sum-contr)     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Договор'  then DO:   assign       sort-column-name1 = substitute('dynamic-function(&1contract-id&1,&2)', chr(34), buf_fin-doc.contract-code)     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Код получ.'  then DO:    assign       sort-column-name1 = "(buf_fin-doc.receiver-type + ' ' + string(buf_fin-doc.receiver-code))"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Получатель'  then DO:    assign       sort-column-name1 = "buf_fin-doc.receiver-name"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Код плател.'  then DO:    assign       sort-column-name1 = "(buf_fin-doc.payer-type + ' ' + string(buf_fin-doc.payer-code))"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Плательщик'  then DO:    assign       sort-column-name1 = "buf_fin-doc.payer-name"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Разр.'  then DO:    assign       sort-column-name1 = "buf_fin-doc.perm-date"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Платеж'  then DO:    assign       sort-column-name1 = "buf_fin-doc.pay-date"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Закрыт'  then DO:    assign       sort-column-name1 = "buf_fin-doc.fact-date"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Вал'  then DO:   assign       sort-column-name1 = substitute('dynamic-function(&1get-currency&1,&2)', chr(34), buf_fin-doc.curr-code)     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Сумма в валюте док-та'  then DO:    assign       sort-column-name1 = "buf_fin-doc.sum-doc"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Расш.тип'  then DO:    assign       sort-column-name1 = "buf_fin-doc.fin-ext-doc-type"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Вн.N'  then DO:    assign       sort-column-name1 = "buf_fin-doc.fin-doc-code"     .     run OpenBr1(yes, no, '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name1 = "(if buf_fin-doc.obj-code = 0 then '' else (buf_fin-doc.obj-type + ' ' + string(buf_fin-doc.obj-code)))"     .     run OpenBr1(yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name1 = ""
      .
      run OpenBr1(yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultFin-Doc-List') then do:
          run mv-brw-defaultFin-Doc-List.
        end.
      if sort-labelFin-Doc-List <> "" then do:
        assign
          cur-clmnFin-Doc-List:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locFin-Doc-List = ?
      .
    end.
  end case.
    if cur-clmn-locFin-Doc-List <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnFin-Doc-List') then do:
        run ch-clmnFin-Doc-List in this-procedure (cur-clmn-locFin-Doc-List).
      end.
    end.
  if p-recid <> ? then do:
    reposition Fin-Doc-List to recid p-recid no-error.
    apply "value-changed" to Fin-Doc-List in frame Dialog-Frame.
  end.
  apply "entry" to Fin-Doc-List in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnFin-Doc-List:
if cur-clmnFin-Doc-List = ? then do:
   run OpenBr1(yes, no, '':U).
end.
else do:
   assign re-queryFin-Doc-List = yes.
   run sort-brFin-Doc-List
     (input (if available buf_fin-doc
             then recid(buf_fin-doc)
             else ?
            )
     ).
   assign re-queryFin-Doc-List = no.
end.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-1 in frame Dialog-Frame
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
on delete-character of date-1 in frame Dialog-Frame
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
on ctrl-d of date-1 in frame Dialog-Frame
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
on ctrl-b of date-1 in frame Dialog-Frame
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
on ctrl-e of date-1 in frame Dialog-Frame
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
on ctrl-f of date-1 in frame Dialog-Frame
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
  define MENU m-ed-date16
    MENU-ITEM m-ed-date16-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date16-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date16-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date16-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date16 :HANDLE
      date-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle16 as handle no-undo .
  assign
    v-label-handle16 = date-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle16)
  then do:
    if v-label-handle16 :tooltip = ""
    or v-label-handle16 :tooltip = ?
    then do:
      assign
        v-label-handle16 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date16-1 in menu m-ed-date16 DO:
    apply "ctrl-b":U to date-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-2 in menu m-ed-date16 DO:
    apply "ctrl-d":U to date-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-3 in menu m-ed-date16 DO:
    apply "ctrl-e":U to date-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-4 in menu m-ed-date16 DO:
    apply "ctrl-f":U to date-1 in frame Dialog-Frame .
  END.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-2 in frame Dialog-Frame
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
on delete-character of date-2 in frame Dialog-Frame
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
on ctrl-d of date-2 in frame Dialog-Frame
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
on ctrl-b of date-2 in frame Dialog-Frame
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
on ctrl-e of date-2 in frame Dialog-Frame
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
on ctrl-f of date-2 in frame Dialog-Frame
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
  define MENU m-ed-date18
    MENU-ITEM m-ed-date18-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date18-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date18-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date18-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date18 :HANDLE
      date-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle18 as handle no-undo .
  assign
    v-label-handle18 = date-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle18)
  then do:
    if v-label-handle18 :tooltip = ""
    or v-label-handle18 :tooltip = ?
    then do:
      assign
        v-label-handle18 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date18-1 in menu m-ed-date18 DO:
    apply "ctrl-b":U to date-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-2 in menu m-ed-date18 DO:
    apply "ctrl-d":U to date-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-3 in menu m-ed-date18 DO:
    apply "ctrl-e":U to date-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-4 in menu m-ed-date18 DO:
    apply "ctrl-f":U to date-2 in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable v-right-supp as logical   no-undo init true .
define variable v-right-buyer as logical   no-undo init true  .
if p-type = "inc" then do:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-supp':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-supp
    )  .
end.
  if v-right-supp = false then return .
end.
else do:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-buyer':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-buyer
    )  .
end.
  if v-right-buyer = false then return .
end.
  assign
    Fin-Ob-List:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200
    Fin-Ob-List:num-locked-columns = 1
    Fin-Doc-List:MAX-DATA-GUESS IN FRAME Dialog-Frame   = 200
    Fin-Doc-List:num-locked-columns = 1
    buf_fin-ob.doc-type:read-only in browse Fin-Ob-List = yes
    buf_fin-doc.fin-doc-type:read-only in browse Fin-Doc-List = yes
    sum-fin-ob:read-only = yes
    sum-fin-doc:read-only = yes
  .
  create temp-contr .
  assign temp-contr.id = -1 .
  create temp-contr1 .
  assign temp-contr1.id = -1 .
  find first clients no-lock where clients.obj-type = 'орг':U and clients.obj-code = v-cntxt-host-code-obj .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame Dialog-Frame
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
on delete-character of sch-date in frame Dialog-Frame
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
on ctrl-d of sch-date in frame Dialog-Frame
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
on ctrl-b of sch-date in frame Dialog-Frame
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
on ctrl-e of sch-date in frame Dialog-Frame
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
on ctrl-f of sch-date in frame Dialog-Frame
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
  define MENU m-ed-date22
    MENU-ITEM m-ed-date22-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date22-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date22-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date22-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date22 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle22 as handle no-undo .
  assign
    v-label-handle22 = sch-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle22)
  then do:
    if v-label-handle22 :tooltip = ""
    or v-label-handle22 :tooltip = ?
    then do:
      assign
        v-label-handle22 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date22-1 in menu m-ed-date22 DO:
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-2 in menu m-ed-date22 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-3 in menu m-ed-date22 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-4 in menu m-ed-date22 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
  RUN enable_UI.
  if mark-num = 0   then hide mark-num   in frame Dialog-Frame.
  if mark-num-2 = 0 then hide mark-num-2 in frame Dialog-Frame.
  assign
    RADIO-find-doc
    RADIO-find-cli
  .
  find first currency where currency.curr-code = 0 no-error.
  assign
    curr-name = currency.curr-abbr
    s-curr-code = currency.curr-code
  .
  display s-curr-code curr-name with frame Dialog-Frame.
  buf_fin-ob.receiver-name:resizable in browse Fin-Ob-List   = true .
  buf_fin-ob.payer-name:resizable    in browse Fin-Ob-List   = true .
  p-gen:resizable                    in browse Fin-Ob-List   = true .
  buf_fin-ob.receiver-name:width     in browse Fin-Ob-List  = v-size-col1 .
  buf_fin-ob.payer-name:width        in browse Fin-Ob-List  = v-size-col2 .
  p-gen:width                        in browse Fin-Ob-List  = v-size-col3 .
  buf_fin-doc.receiver-name:resizable in browse Fin-Doc-List   = true .
  buf_fin-doc.payer-name:resizable    in browse Fin-Doc-List   = true .
  buf_fin-doc.receiver-name:width     in browse Fin-Doc-List  = v-size-col4 .
  buf_fin-doc.payer-name:width        in browse Fin-Doc-List  = v-size-col5 .
  REPOSITION Fin-Ob-List to row 1 No-ERROR.
  REPOSITION Fin-Doc-List to row 1 No-ERROR.
  Run OpenBR(yes, no, '':U) .
  Run OpenBR1(yes, no, '':U) .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numFin-Ob-List as INT EXTENT 19 no-undo.
DEF VAR varmviFin-Ob-List       as INT no-undo.
DEF VAR varmvjFin-Ob-List       as INT no-undo.
DEF VAR varmvkFin-Ob-List       as INT no-undo.
DEF VAR varmvlFin-Ob-List       as INT no-undo.
DEF VAR move-elementFin-Ob-List as INT no-undo.
def var jjFin-Ob-List           as int no-undo.
do varmviFin-Ob-List = 1 to EXTENT(cur-clmn-numFin-Ob-List):
  ASSIGN cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = varmviFin-Ob-List.
END.
RUN start-mv-clmnFin-Ob-List.
PROCEDURE start-mv-clmnFin-Ob-List:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true = true   THEN DO:
   DO jjFin-Ob-List = NUM-ENTRIES(v-order-col) TO 1 BY -1:
     RUN re-move-clmnFin-Ob-List ( cur-clmn-numFin-Ob-List[INTEGER(ENTRY (jjFin-Ob-List, v-order-col))] , 2).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE Fin-Ob-List do:
  RUN re-move-clmnFin-Ob-List ( 2, 19).
END.
ON ctrl-cursor-left OF BROWSE Fin-Ob-List do:
  RUN re-move-clmnFin-Ob-List (19, 2).
END.
PROCEDURE re-move-clmnFin-Ob-List:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviFin-Ob-List = 1 TO EXTENT(cur-clmn-numFin-Ob-List):
    if cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = source-column THEN cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = -1.
  END.
  if Fin-Ob-List:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjFin-Ob-List = source-column - 1 to target-column BY -1:
    DO varmviFin-Ob-List = 1 TO EXTENT(cur-clmn-numFin-Ob-List):
        if cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = varmvjFin-Ob-List THEN DO:
          cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = cur-clmn-numFin-Ob-List[varmviFin-Ob-List] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjFin-Ob-List = source-column + 1 to target-column:
    DO varmviFin-Ob-List = 1 TO EXTENT(cur-clmn-numFin-Ob-List):
      if cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = varmvjFin-Ob-List THEN DO:
        cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = cur-clmn-numFin-Ob-List[varmviFin-Ob-List] - 1.
      END.
    END.
  END.
  DO varmviFin-Ob-List = 1 TO EXTENT(cur-clmn-numFin-Ob-List):
    if cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = -1 THEN cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnFin-Ob-List:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmviFin-Ob-List = 1 TO EXTENT(cur-clmn-numFin-Ob-List):
    if cur-clmn-numFin-Ob-List[varmviFin-Ob-List] = cur-clmn-loc THEN move-elementFin-Ob-List = varmviFin-Ob-List.
  END.
  RUN re-move-clmnFin-Ob-List (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultFin-Ob-List:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlFin-Ob-List = 2 to EXTENT(cur-clmn-numFin-Ob-List):
    RUN re-move-clmnFin-Ob-List (cur-clmn-numFin-Ob-List[varmvlFin-Ob-List], varmvlFin-Ob-List).
  END.
  RUN start-mv-clmnFin-Ob-List.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numFin-Doc-List as INT EXTENT 21 no-undo.
DEF VAR varmviFin-Doc-List       as INT no-undo.
DEF VAR varmvjFin-Doc-List       as INT no-undo.
DEF VAR varmvkFin-Doc-List       as INT no-undo.
DEF VAR varmvlFin-Doc-List       as INT no-undo.
DEF VAR move-elementFin-Doc-List as INT no-undo.
def var jjFin-Doc-List           as int no-undo.
do varmviFin-Doc-List = 1 to EXTENT(cur-clmn-numFin-Doc-List):
  ASSIGN cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = varmviFin-Doc-List.
END.
RUN start-mv-clmnFin-Doc-List.
PROCEDURE start-mv-clmnFin-Doc-List:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true = true   THEN DO:
   DO jjFin-Doc-List = NUM-ENTRIES(v-order-col1) TO 1 BY -1:
     RUN re-move-clmnFin-Doc-List ( cur-clmn-numFin-Doc-List[INTEGER(ENTRY (jjFin-Doc-List, v-order-col1))] , 2).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE Fin-Doc-List do:
  RUN re-move-clmnFin-Doc-List ( 2, 21).
END.
ON ctrl-cursor-left OF BROWSE Fin-Doc-List do:
  RUN re-move-clmnFin-Doc-List (21, 2).
END.
PROCEDURE re-move-clmnFin-Doc-List:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviFin-Doc-List = 1 TO EXTENT(cur-clmn-numFin-Doc-List):
    if cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = source-column THEN cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = -1.
  END.
  if Fin-Doc-List:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjFin-Doc-List = source-column - 1 to target-column BY -1:
    DO varmviFin-Doc-List = 1 TO EXTENT(cur-clmn-numFin-Doc-List):
        if cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = varmvjFin-Doc-List THEN DO:
          cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = cur-clmn-numFin-Doc-List[varmviFin-Doc-List] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjFin-Doc-List = source-column + 1 to target-column:
    DO varmviFin-Doc-List = 1 TO EXTENT(cur-clmn-numFin-Doc-List):
      if cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = varmvjFin-Doc-List THEN DO:
        cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = cur-clmn-numFin-Doc-List[varmviFin-Doc-List] - 1.
      END.
    END.
  END.
  DO varmviFin-Doc-List = 1 TO EXTENT(cur-clmn-numFin-Doc-List):
    if cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = -1 THEN cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnFin-Doc-List:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmviFin-Doc-List = 1 TO EXTENT(cur-clmn-numFin-Doc-List):
    if cur-clmn-numFin-Doc-List[varmviFin-Doc-List] = cur-clmn-loc THEN move-elementFin-Doc-List = varmviFin-Doc-List.
  END.
  RUN re-move-clmnFin-Doc-List (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultFin-Doc-List:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlFin-Doc-List = 2 to EXTENT(cur-clmn-numFin-Doc-List):
    RUN re-move-clmnFin-Doc-List (cur-clmn-numFin-Doc-List[varmvlFin-Doc-List], varmvlFin-Doc-List).
  END.
  RUN start-mv-clmnFin-Doc-List.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE conn-avt :
do on error undo, return error return-value :
  define input  parameter p-ri as recid     no-undo .
  define input  parameter p-list         as  character no-undo .
  define variable csum as decimal   no-undo .
  define variable is-plus as logical   no-undo .
  define variable ii as integer   no-undo .
  define variable p-sys-time  as character no-undo .
  find first fin-doc no-lock where recid(fin-doc) = p-ri .
  assign csum = fin-doc.sum-contr - fin-doc.con-sum-contr .
  for each temp_fin-ob : delete temp_fin-ob . end.
  if p-doc-type = 'при':U then do:
    if   fin-doc.fin-doc-type = 'рпп':U
      or fin-doc.fin-doc-type = 'рко':U
      or fin-doc.fin-doc-type = 'апр':U then assign is-plus = yes .
    else
      assign
        is-plus = no
        csum = - csum
      .
  end.
  else do:
    if   fin-doc.fin-doc-type = 'ппп':U
      or fin-doc.fin-doc-type = 'пко':U
      or fin-doc.fin-doc-type = 'апп':U then assign is-plus = yes .
    else
      assign
        is-plus = no
        csum = - csum
      .
  end.
  define variable p-new as character no-undo .
  DO ii = 1 TO NUM-ENTRIES(p-list) :
    find first fin-ob NO-LOCK WHERE RECID( fin-ob ) = INT ( ENTRY( ii, p-list) ) .
    if is-plus = yes and fin-ob.sum-contr > 0 or is-plus = no and fin-ob.sum-contr < 0  then do:
      if p-new = "" then  assign p-new = ENTRY( ii, p-list).
      else  assign p-new = p-new + "," + ENTRY( ii, p-list) .
    end.
    else do:
      CREATE temp_fin-ob .
      BUFFER-COPY fin-ob TO temp_fin-ob .
      assign temp_fin-ob.ri = RECID( fin-ob ) .
      assign
        temp_fin-ob.no-con-sum = temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr
        csum = csum - temp_fin-ob.no-con-sum
      .
    end.
  end.
  assign p-list = p-new .
  DO ii = 1 TO NUM-ENTRIES(p-list) :
    find first fin-ob NO-LOCK WHERE RECID( fin-ob ) = INT ( ENTRY( ii, p-list) ) .
    CREATE temp_fin-ob .
    BUFFER-COPY fin-ob TO temp_fin-ob .
    assign temp_fin-ob.ri = RECID( fin-ob ) .
    if csum > 0 then do:
      if csum > temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr then do:
        assign
          temp_fin-ob.no-con-sum = temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr
          csum = csum - temp_fin-ob.no-con-sum
        .
      end.
      else do:
        assign
          temp_fin-ob.no-con-sum = csum
          csum = 0
        .
      end.
    END.
    else if csum < 0 then do:
      if csum < temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr then do:
        assign
          temp_fin-ob.no-con-sum = temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr
          csum = csum - temp_fin-ob.no-con-sum
        .
      end.
      else do:
        assign
          temp_fin-ob.no-con-sum = csum
          csum = 0
        .
      end.
    END.
  END.
  define variable all-sum-contr as decimal   no-undo .
  define variable all-sum-base as decimal   no-undo .
  define variable all-sum-rubl as decimal   no-undo .
  define variable all-sum-doc as decimal   no-undo .
  for each temp_fin-ob :
    if temp_fin-ob.no-con-sum = 0 then next.
    create fin-connect .
    assign
      fin-connect.connect-code   = next-value( s-fin-connect, ub  )
      fin-connect.host-code      = v-cntxt-host-code-obj
      fin-connect.fin-doc-code   = fin-doc.fin-doc-code
      fin-connect.fin-ob-code    = temp_fin-ob.doc-code
      fin-connect.contract-code  = temp_fin-ob.contract-code
      fin-connect.curr-code      = temp_fin-ob.curr-code
      fin-connect.base-rate      = temp_fin-ob.base-rate
      fin-connect.base-scale     = temp_fin-ob.base-scale
      fin-connect.contract-curr  = temp_fin-ob.contract-curr
      fin-connect.contract-rate  = temp_fin-ob.contract-rate
      fin-connect.contract-scale = temp_fin-ob.contract-scale
      fin-connect.exch-rate      = temp_fin-ob.exch-rate
      fin-connect.exch-scale     = temp_fin-ob.exch-scale
      fin-connect.status_        = 'тек':U
      fin-connect.sum-contr      = temp_fin-ob.no-con-sum
      fin-connect.sum-rubl       = round(fin-connect.sum-contr * fin-connect.contract-rate / fin-connect.contract-scale,2)
      fin-connect.sum-base       = fin-connect.sum-rubl * fin-connect.base-scale / fin-connect.base-rate
      fin-connect.sum-doc        = fin-connect.sum-rubl * fin-connect.exch-scale / fin-connect.exch-rate
      fin-connect.sum-contr-ob   = fin-connect.sum-contr
      fin-connect.sum-rubl-ob    = fin-connect.sum-rubl
      fin-connect.sum-base-ob    = fin-connect.sum-base
    .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output fin-connect.user-db-num
  ,output fin-connect.user-name
  ,output fin-connect.fact-date
  ,output p-sys-time
  ,output fin-connect.fact-time
  )  .
    find first fin-ob exclusive-lock where fin-ob.host-code = v-cntxt-host-code-obj and fin-ob.doc-code = temp_fin-ob.doc-code .
    assign
      fin-ob.con-sum-contr = fin-ob.con-sum-contr + fin-connect.sum-contr
      fin-ob.con-sum-base  = fin-ob.con-sum-base  + fin-connect.sum-base
      fin-ob.con-sum-rubl  = fin-ob.con-sum-rubl  + fin-connect.sum-rubl
      fin-ob.con-sum-doc   = fin-ob.con-sum-doc   + fin-connect.sum-doc
      all-sum-contr        = all-sum-contr + fin-connect.sum-contr
      all-sum-base         = all-sum-base  + fin-connect.sum-base
      all-sum-rubl         = all-sum-rubl  + fin-connect.sum-rubl
      all-sum-doc          = all-sum-doc   + fin-connect.sum-doc
    .
    if fin-ob.sum-contr > 0 then do:
      if fin-ob.sum-contr > fin-ob.con-sum-contr then assign fin-ob.con-stat = 1 .
      else                                            assign fin-ob.con-stat = 2 .
    end.
    else do:
      if fin-ob.sum-contr < fin-ob.con-sum-contr then assign fin-ob.con-stat = 1 .
      else                                            assign fin-ob.con-stat = 2 .
    end.
  end.
  if all-sum-contr <> 0 then do:
    find current fin-doc exclusive-lock .
    if is-plus then do:
      assign
        fin-doc.con-sum-contr = fin-doc.con-sum-contr + all-sum-contr
        fin-doc.con-sum-base  = fin-doc.con-sum-base  + all-sum-base
        fin-doc.con-sum-rubl  = fin-doc.con-sum-rubl  + all-sum-rubl
        fin-doc.con-sum-doc   = fin-doc.con-sum-doc   + all-sum-doc
      .
      if fin-doc.sum-contr > fin-doc.con-sum-contr then assign fin-doc.con-stat = 1 .
      else                                              assign fin-doc.con-stat = 2 .
    end.
    else do:
      assign
        fin-doc.con-sum-contr = fin-doc.con-sum-contr - all-sum-contr
        fin-doc.con-sum-base  = fin-doc.con-sum-base  - all-sum-base
        fin-doc.con-sum-rubl  = fin-doc.con-sum-rubl  - all-sum-rubl
        fin-doc.con-sum-doc   = fin-doc.con-sum-doc   - all-sum-doc
      .
      if fin-doc.sum-contr > fin-doc.con-sum-contr then assign fin-doc.con-stat = 1 .
      else                                              assign fin-doc.con-stat = 2 .
    end.
  end.
  end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sum-fin-doc sum-fin-ob sch-code RADIO-find-cli cli-code cli-type
          RADIO-find-doc s-curr-code sch-date cli-name Curr-Types Sel-Client
          Sel-Contr date-1 Sel-Status date-2 mark-num-2 mark-num curr-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-conn-add B-conn-view B-oplat-list B-Help RECT-status RECT-1
         B-conn-doc B-view-doc B-del-doc B-conn-fo B-view-fo Fin-Ob-List
         Fin-Doc-List B-mark-2 B-unmark-2 B-allmark-2 sum-fin-doc B-mark
         B-unmark B-allmark B-oplat sum-fin-ob BUTTON-cli sch-code
         RADIO-find-cli cli-code cli-type RADIO-find-doc BUTTON-curr
         s-curr-code sch-date cli-name Curr-Types Sel-Client Sel-Contr date-1
         Sel-Status B-date date-2 mark-num-2 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE find-cli :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_clients for clients .
  if p-obj-type <> 'орг':U and p-obj-type <> 'чел':U then do:
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = p-obj-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = p-obj-type and buf_clients.obj-code = p-obj-code no-error.
  if not available buf_clients then do:
    if p-obj-code = 0 then assign p-obj-code = ? .
    if p-obj-code = ? then do:
      assign  cli-name = ""  cli-code = ?  cli-type  = "" .
      display cli-name       cli-code      cli-type   with frame Dialog-Frame.
    end.
    else do:
        apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign cli-name  = buf_clients.obj-name  cli-code  = p-obj-code  cli-type  = buf_clients.obj-type.
  display cli-name    cli-code     cli-type   with frame Dialog-Frame.
  run proc-find-cli in this-procedure(no, input cli-code, input cli-type ) no-error.
  if error-status:error then return no-apply.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  if available buf_fin-ob then assign v-doc-rec = recid (buf_fin-ob) .
  assign frame Dialog-Frame:title = "Планирование платежей.  Фирма: (" + string(v-cntxt-host-code-obj) + ")":U + chr(32) + clients.obj-name  .
  if Sel-Contr = "all" and Sel-Client = "all"  then RUN OpenBrAllContr( p-open-query, p-find-next, p-find-condition) .
  else                                              RUN OpenBrSelContr( p-open-query, p-find-next, p-find-condition) .
  run proc-mark in this-procedure .
END PROCEDURE.
PROCEDURE OpenBr1 :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  if available buf_fin-doc then assign v-doc-rec1 = recid (buf_fin-doc) .
  assign frame Dialog-Frame:title = "Планирование платежей.  Фирма: (" + string(v-cntxt-host-code-obj) + ")":U + chr(32) + clients.obj-name  .
  if Sel-Contr = "all" and Sel-Client = "all"  then RUN OpenBr1AllContr( p-open-query, p-find-next, p-find-condition) .
  else                                              RUN OpenBr1SelContr( p-open-query, p-find-next, p-find-condition) .
  run proc-mark1 in this-procedure .
END PROCEDURE.
PROCEDURE OpenBr1AllContr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .
  case sort-column-name1 :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name1 .
  end case.
  for each temp-fin-doc : assign temp-fin-doc.del = yes . end.
  if Curr-types = "all" then do:
    case Sel-Status :
      when "all"  then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "FOR EACH buf_fin-doc"
      parameter-4-27 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0  " + " " + where-phrase-27) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 ', p-host-code) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + substitute(', first temp-contr1'))
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0  " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-27 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0
    ,first temp-contr1
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 ', p-host-code) + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "FOR EACH buf_fin-doc"
      parameter-4-27 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0  " + " " + where-phrase-27) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 ', p-host-code) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + substitute(', first temp-contr1') + " " + p-find-condition)
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "new"  then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
if p-open-query then do:
  assign
    l-filter-open-29 = false
  .
  if flt-rec-29 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-29 as character no-undo .
    define variable  parameter-3-29 as character no-undo .
    define variable  parameter-4-29 as character no-undo .
    define variable  parameter-5-29 as character no-undo .
    define variable  parameter-6-29 as character no-undo .
    define variable  parameter-7-29 as character no-undo .
      assign
      parameter-3-29 =
                              "FOR EACH buf_fin-doc"
      parameter-4-29 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U " + " " + where-phrase-29) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + substitute(', first temp-contr1'))
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          )
      .
      assign
        l-filter-open-29 = true
      .
    end.
    if l-filter-open-29 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-29 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U
    ,first temp-contr1
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-4-29 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " ":u + where-phrase-29 + " ":u + p-find-condition + " " + ""
      parameter-5-29 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-3-29 =  "FOR EACH buf_fin-doc"
      parameter-4-29 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U " + " " + where-phrase-29) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + substitute(', first temp-contr1') + " " + p-find-condition)
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "fact" then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-31  as logical   no-undo .
define variable  l-filter-open-31    as logical   .
define variable  flt-rec-31       as recid     no-undo .
define variable  filter-name-31      as character no-undo .
define variable  where-phrase-31     as character no-undo .
define variable  sort-phrase-31      as character no-undo .
define variable  where-phrase-rus-31 as character no-undo .
define variable  sort-phrase-rus-31  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-31
  ,output filter-name-31
  ,output where-phrase-31
  ,output sort-phrase-31
  ,output where-phrase-rus-31
  ,output sort-phrase-rus-31
  ).
if p-open-query then do:
  assign
    l-filter-open-31 = false
  .
  if flt-rec-31 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-31 as character no-undo .
    define variable  parameter-3-31 as character no-undo .
    define variable  parameter-4-31 as character no-undo .
    define variable  parameter-5-31 as character no-undo .
    define variable  parameter-6-31 as character no-undo .
    define variable  parameter-7-31 as character no-undo .
      assign
      parameter-3-31 =
                              "FOR EACH buf_fin-doc"
      parameter-4-31 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U " + " " + where-phrase-31) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + substitute(', first temp-contr1'))
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-31 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U " + " " + where-phrase-31 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
                          )
      .
      assign
        l-filter-open-31 = true
      .
    end.
    if l-filter-open-31 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-31 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U
    ,first temp-contr1
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-4-31 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " ":u + where-phrase-31 + " ":u + p-find-condition + " " + ""
      parameter-5-31 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-3-31 =  "FOR EACH buf_fin-doc"
      parameter-4-31 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U " + " " + where-phrase-31) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + substitute(', first temp-contr1') + " " + p-find-condition)
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    end.
  end.
  else do:
    case Sel-Status :
      when "all"  then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
if p-open-query then do:
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH buf_fin-doc"
      parameter-4-33 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-33) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code ) + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + substitute(', first temp-contr1'))
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-33 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = curr-code
    ,first temp-contr1
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code ) + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH buf_fin-doc"
      parameter-4-33 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-33) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code ) + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + substitute(', first temp-contr1') + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "new"  then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
if p-open-query then do:
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH buf_fin-doc"
      parameter-4-35 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-35) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + substitute(', first temp-contr1'))
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-35 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U and buf_fin-doc.curr-code = curr-code
    ,first temp-contr1
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH buf_fin-doc"
      parameter-4-35 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> 'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-35) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + substitute(', first temp-contr1') + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "fact" then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
if p-open-query then do:
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH buf_fin-doc"
      parameter-4-37 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-37) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + substitute(', first temp-contr1'))
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-37 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U and buf_fin-doc.curr-code = curr-code
    ,first temp-contr1
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-3-37 =  "FOR EACH buf_fin-doc"
      parameter-4-37 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-37) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + substitute(', first temp-contr1') + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    end.
  end.
  REPOSITION Fin-Doc-List to recid v-doc-rec1 No-ERROR.
END PROCEDURE.
PROCEDURE OpenBr1SelContr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .
  case sort-column-name1 :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name1 .
  end case.
  for each temp-fin-doc : assign temp-fin-doc.del = yes . end.
  if Curr-types = "all" then do:
    case Sel-Status :
      when "all"  then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH buf_fin-doc"
      parameter-4-39 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 " + " " + where-phrase-39) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 ', p-host-code ) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code))
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-39 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2
    ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 ', p-host-code ) + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH buf_fin-doc"
      parameter-4-39 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 " + " " + where-phrase-39) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 ', p-host-code ) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code) + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "new"  then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
if p-open-query then do:
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH buf_fin-doc"
      parameter-4-41 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> 'факт':U " + " " + where-phrase-41) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code))
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> 'факт':U " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-41 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> 'факт':U
    ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-3-41 =  "FOR EACH buf_fin-doc"
      parameter-4-41 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> 'факт':U " + " " + where-phrase-41) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code) + " " + p-find-condition)
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "fact" then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-43  as logical   no-undo .
define variable  l-filter-open-43    as logical   .
define variable  flt-rec-43       as recid     no-undo .
define variable  filter-name-43      as character no-undo .
define variable  where-phrase-43     as character no-undo .
define variable  sort-phrase-43      as character no-undo .
define variable  where-phrase-rus-43 as character no-undo .
define variable  sort-phrase-rus-43  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-43
  ,output filter-name-43
  ,output where-phrase-43
  ,output sort-phrase-43
  ,output where-phrase-rus-43
  ,output sort-phrase-rus-43
  ).
if p-open-query then do:
  assign
    l-filter-open-43 = false
  .
  if flt-rec-43 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-43 as character no-undo .
    define variable  parameter-3-43 as character no-undo .
    define variable  parameter-4-43 as character no-undo .
    define variable  parameter-5-43 as character no-undo .
    define variable  parameter-6-43 as character no-undo .
    define variable  parameter-7-43 as character no-undo .
      assign
      parameter-3-43 =
                              "FOR EACH buf_fin-doc"
      parameter-4-43 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ =  'факт':U " + " " + where-phrase-43) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code))
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-43 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ =  'факт':U " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          )
      .
      assign
        l-filter-open-43 = true
      .
    end.
    if l-filter-open-43 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-43 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ =  'факт':U
    ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-4-43 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " ":u + where-phrase-43 + " ":u + p-find-condition + " " + ""
      parameter-5-43 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-3-43 =  "FOR EACH buf_fin-doc"
      parameter-4-43 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ =  'факт':U " + " " + where-phrase-43) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, 'факт':U, chr(34)) + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code) + " " + p-find-condition)
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    end.
  end.
  else do:
    case Sel-Status :
      when "all"  then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-45  as logical   no-undo .
define variable  l-filter-open-45    as logical   .
define variable  flt-rec-45       as recid     no-undo .
define variable  filter-name-45      as character no-undo .
define variable  where-phrase-45     as character no-undo .
define variable  sort-phrase-45      as character no-undo .
define variable  where-phrase-rus-45 as character no-undo .
define variable  sort-phrase-rus-45  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-45
  ,output filter-name-45
  ,output where-phrase-45
  ,output sort-phrase-45
  ,output where-phrase-rus-45
  ,output sort-phrase-rus-45
  ).
if p-open-query then do:
  assign
    l-filter-open-45 = false
  .
  if flt-rec-45 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-45 as character no-undo .
    define variable  parameter-3-45 as character no-undo .
    define variable  parameter-4-45 as character no-undo .
    define variable  parameter-5-45 as character no-undo .
    define variable  parameter-6-45 as character no-undo .
    define variable  parameter-7-45 as character no-undo .
      assign
      parameter-3-45 =
                              "FOR EACH buf_fin-doc"
      parameter-4-45 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-45) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code ) + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code))
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-45 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          )
      .
      assign
        l-filter-open-45 = true
      .
    end.
    if l-filter-open-45 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-45 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = curr-code
    ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-4-45 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code ) + " ":u + where-phrase-45 + " ":u + p-find-condition + " " + ""
      parameter-5-45 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-3-45 =  "FOR EACH buf_fin-doc"
      parameter-4-45 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-45) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code ) + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code) + " " + p-find-condition)
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "new"  then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-47
  ,output filter-name-47
  ,output where-phrase-47
  ,output sort-phrase-47
  ,output where-phrase-rus-47
  ,output sort-phrase-rus-47
  ).
if p-open-query then do:
  assign
    l-filter-open-47 = false
  .
  if flt-rec-47 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-47 as character no-undo .
    define variable  parameter-3-47 as character no-undo .
    define variable  parameter-4-47 as character no-undo .
    define variable  parameter-5-47 as character no-undo .
    define variable  parameter-6-47 as character no-undo .
    define variable  parameter-7-47 as character no-undo .
      assign
      parameter-3-47 =
                              "FOR EACH buf_fin-doc"
      parameter-4-47 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   <> 'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-47) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code))
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   <> 'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          )
      .
      assign
        l-filter-open-47 = true
      .
    end.
    if l-filter-open-47 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-47 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   <> 'факт':U and buf_fin-doc.curr-code = curr-code
    ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-3-47 =  "FOR EACH buf_fin-doc"
      parameter-4-47 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   <> 'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-47) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code) + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "fact" then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-49  as logical   no-undo .
define variable  l-filter-open-49    as logical   .
define variable  flt-rec-49       as recid     no-undo .
define variable  filter-name-49      as character no-undo .
define variable  where-phrase-49     as character no-undo .
define variable  sort-phrase-49      as character no-undo .
define variable  where-phrase-rus-49 as character no-undo .
define variable  sort-phrase-rus-49  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-49
  ,output filter-name-49
  ,output where-phrase-49
  ,output sort-phrase-49
  ,output where-phrase-rus-49
  ,output sort-phrase-rus-49
  ).
if p-open-query then do:
  assign
    l-filter-open-49 = false
  .
  if flt-rec-49 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-49 as character no-undo .
    define variable  parameter-3-49 as character no-undo .
    define variable  parameter-4-49 as character no-undo .
    define variable  parameter-5-49 as character no-undo .
    define variable  parameter-6-49 as character no-undo .
    define variable  parameter-7-49 as character no-undo .
      assign
      parameter-3-49 =
                              "FOR EACH buf_fin-doc"
      parameter-4-49 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   =  'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-49) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code))
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-49 =
          (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   =  'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          )
      .
      assign
        l-filter-open-49 = true
      .
    end.
    if l-filter-open-49 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-49 = false then do:
    OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
      where  buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   =  'факт':U and buf_fin-doc.curr-code = curr-code
    ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
       by buf_fin-doc.doc-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec1 = recid( buf_fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Doc-List:handle:get-buffer-handle(1) = (buffer buf_fin-doc:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u +  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input rowid(buf_fin-doc)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer buf_fin-doc:handle)
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ) no-error.
      .
      assign
        v-doc-rec1 = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-3-49 =  "FOR EACH buf_fin-doc"
      parameter-4-49 =
        (
          if (" buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   =  'факт':U and buf_fin-doc.curr-code = curr-code " + " " + where-phrase-49) <> ""
          then  substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, 'факт':U, curr-code , chr(34)) + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code) + " " + p-find-condition)
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-doc.doc-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Doc-List:handle
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec1 = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    end.
  end.
  REPOSITION Fin-Doc-List to recid v-doc-rec1 No-ERROR.
END PROCEDURE.
PROCEDURE OpenBrAllContr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.
  for each temp-fin-ob : assign temp-fin-ob.del = yes . end.
  if sel-date then do:
    if Curr-types = "all" then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-51  as logical   no-undo .
define variable  l-filter-open-51    as logical   .
define variable  flt-rec-51       as recid     no-undo .
define variable  filter-name-51      as character no-undo .
define variable  where-phrase-51     as character no-undo .
define variable  sort-phrase-51      as character no-undo .
define variable  where-phrase-rus-51 as character no-undo .
define variable  sort-phrase-rus-51  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-51
  ,output filter-name-51
  ,output where-phrase-51
  ,output sort-phrase-51
  ,output where-phrase-rus-51
  ,output sort-phrase-rus-51
  ).
if p-open-query then do:
  assign
    l-filter-open-51 = false
  .
  if flt-rec-51 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-51 as character no-undo .
    define variable  parameter-3-51 as character no-undo .
    define variable  parameter-4-51 as character no-undo .
    define variable  parameter-5-51 as character no-undo .
    define variable  parameter-6-51 as character no-undo .
    define variable  parameter-7-51 as character no-undo .
      assign
      parameter-3-51 =
                              "FOR EACH buf_fin-ob"
      parameter-4-51 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2 " + " " + where-phrase-51) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, 'факт':U, chr(34), date-1, date-2) + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + substitute(', first temp-contr'))
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-51 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2 " + " " + where-phrase-51 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          )
      .
      assign
        l-filter-open-51 = true
      .
    end.
    if l-filter-open-51 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-51 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2
    ,first temp-contr
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-4-51 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, 'факт':U, chr(34), date-1, date-2) + " ":u + where-phrase-51 + " ":u + p-find-condition + " " + ""
      parameter-5-51 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-3-51 =  "FOR EACH buf_fin-ob"
      parameter-4-51 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2 " + " " + where-phrase-51) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, 'факт':U, chr(34), date-1, date-2) + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + substitute(', first temp-contr') + " " + p-find-condition)
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    else do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-53  as logical   no-undo .
define variable  l-filter-open-53    as logical   .
define variable  flt-rec-53       as recid     no-undo .
define variable  filter-name-53      as character no-undo .
define variable  where-phrase-53     as character no-undo .
define variable  sort-phrase-53      as character no-undo .
define variable  where-phrase-rus-53 as character no-undo .
define variable  sort-phrase-rus-53  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-53
  ,output filter-name-53
  ,output where-phrase-53
  ,output sort-phrase-53
  ,output where-phrase-rus-53
  ,output sort-phrase-rus-53
  ).
if p-open-query then do:
  assign
    l-filter-open-53 = false
  .
  if flt-rec-53 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-53 as character no-undo .
    define variable  parameter-3-53 as character no-undo .
    define variable  parameter-4-53 as character no-undo .
    define variable  parameter-5-53 as character no-undo .
    define variable  parameter-6-53 as character no-undo .
    define variable  parameter-7-53 as character no-undo .
      assign
      parameter-3-53 =
                              "FOR EACH buf_fin-ob"
      parameter-4-53 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  " + " " + where-phrase-53) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34), date-1, date-2) + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + substitute(', first temp-contr'))
      parameter-6-53 = if sort-phrase-53 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-53
        )
      parameter-7-53 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-53 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  " + " " + where-phrase-53 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          )
      .
      assign
        l-filter-open-53 = true
      .
    end.
    if l-filter-open-53 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-53 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2
    ,first temp-contr
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-4-53 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34), date-1, date-2) + " ":u + where-phrase-53 + " ":u + p-find-condition + " " + ""
      parameter-5-53 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-3-53 =  "FOR EACH buf_fin-ob"
      parameter-4-53 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  " + " " + where-phrase-53) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34), date-1, date-2) + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + substitute(', first temp-contr') + " " + p-find-condition)
      parameter-6-53 = if sort-phrase-53 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-53
        )
      parameter-7-53 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  else do:
    if Curr-types = "all" then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-55  as logical   no-undo .
define variable  l-filter-open-55    as logical   .
define variable  flt-rec-55       as recid     no-undo .
define variable  filter-name-55      as character no-undo .
define variable  where-phrase-55     as character no-undo .
define variable  sort-phrase-55      as character no-undo .
define variable  where-phrase-rus-55 as character no-undo .
define variable  sort-phrase-rus-55  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-55
  ,output filter-name-55
  ,output where-phrase-55
  ,output sort-phrase-55
  ,output where-phrase-rus-55
  ,output sort-phrase-rus-55
  ).
if p-open-query then do:
  assign
    l-filter-open-55 = false
  .
  if flt-rec-55 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-55 as character no-undo .
    define variable  parameter-3-55 as character no-undo .
    define variable  parameter-4-55 as character no-undo .
    define variable  parameter-5-55 as character no-undo .
    define variable  parameter-6-55 as character no-undo .
    define variable  parameter-7-55 as character no-undo .
      assign
      parameter-3-55 =
                              "FOR EACH buf_fin-ob"
      parameter-4-55 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 " + " " + where-phrase-55) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 ', p-host-code, p-fo-type, 'факт':U, chr(34)) + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + substitute(', first temp-contr'))
      parameter-6-55 = if sort-phrase-55 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-55
        )
      parameter-7-55 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-55 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 " + " " + where-phrase-55 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
                          )
      .
      assign
        l-filter-open-55 = true
      .
    end.
    if l-filter-open-55 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-55 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0
    ,first temp-contr
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-4-55 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 ', p-host-code, p-fo-type, 'факт':U, chr(34)) + " ":u + where-phrase-55 + " ":u + p-find-condition + " " + ""
      parameter-5-55 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-3-55 =  "FOR EACH buf_fin-ob"
      parameter-4-55 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 " + " " + where-phrase-55) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 ', p-host-code, p-fo-type, 'факт':U, chr(34)) + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + substitute(', first temp-contr') + " " + p-find-condition)
      parameter-6-55 = if sort-phrase-55 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-55
        )
      parameter-7-55 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    else do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-57  as logical   no-undo .
define variable  l-filter-open-57    as logical   .
define variable  flt-rec-57       as recid     no-undo .
define variable  filter-name-57      as character no-undo .
define variable  where-phrase-57     as character no-undo .
define variable  sort-phrase-57      as character no-undo .
define variable  where-phrase-rus-57 as character no-undo .
define variable  sort-phrase-rus-57  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-57
  ,output filter-name-57
  ,output where-phrase-57
  ,output sort-phrase-57
  ,output where-phrase-rus-57
  ,output sort-phrase-rus-57
  ).
if p-open-query then do:
  assign
    l-filter-open-57 = false
  .
  if flt-rec-57 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-57 as character no-undo .
    define variable  parameter-3-57 as character no-undo .
    define variable  parameter-4-57 as character no-undo .
    define variable  parameter-5-57 as character no-undo .
    define variable  parameter-6-57 as character no-undo .
    define variable  parameter-7-57 as character no-undo .
      assign
      parameter-3-57 =
                              "FOR EACH buf_fin-ob"
      parameter-4-57 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code " + " " + where-phrase-57) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34)) + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + substitute(', first temp-contr'))
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-57 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
                          )
      .
      assign
        l-filter-open-57 = true
      .
    end.
    if l-filter-open-57 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-57 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code
    ,first temp-contr
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34)) + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-3-57 =  "FOR EACH buf_fin-ob"
      parameter-4-57 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code " + " " + where-phrase-57) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34)) + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + substitute(', first temp-contr') + " " + p-find-condition)
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  REPOSITION Fin-Ob-List to recid v-doc-rec No-ERROR.
END PROCEDURE.
PROCEDURE OpenBrSelContr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.
  for each temp-fin-ob : assign temp-fin-ob.del = yes . end.
  if sel-date then do:
    if Curr-types = "all" then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-59  as logical   no-undo .
define variable  l-filter-open-59    as logical   .
define variable  flt-rec-59       as recid     no-undo .
define variable  filter-name-59      as character no-undo .
define variable  where-phrase-59     as character no-undo .
define variable  sort-phrase-59      as character no-undo .
define variable  where-phrase-rus-59 as character no-undo .
define variable  sort-phrase-rus-59  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-59
  ,output filter-name-59
  ,output where-phrase-59
  ,output sort-phrase-59
  ,output where-phrase-rus-59
  ,output sort-phrase-rus-59
  ).
if p-open-query then do:
  assign
    l-filter-open-59 = false
  .
  if flt-rec-59 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-59 as character no-undo .
    define variable  parameter-3-59 as character no-undo .
    define variable  parameter-4-59 as character no-undo .
    define variable  parameter-5-59 as character no-undo .
    define variable  parameter-6-59 as character no-undo .
    define variable  parameter-7-59 as character no-undo .
      assign
      parameter-3-59 =
                              "FOR EACH buf_fin-ob"
      parameter-4-59 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2   " + " " + where-phrase-59) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, 'факт':U, chr(34), date-1, date-2) + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code))
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-59 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2   " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
                          )
      .
      assign
        l-filter-open-59 = true
      .
    end.
    if l-filter-open-59 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-59 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2
    ,first temp-contr where temp-contr.id = buf_fin-ob.contract-code
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-4-59 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, 'факт':U, chr(34), date-1, date-2) + " ":u + where-phrase-59 + " ":u + p-find-condition + " " + ""
      parameter-5-59 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-3-59 =  "FOR EACH buf_fin-ob"
      parameter-4-59 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2   " + " " + where-phrase-59) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, 'факт':U, chr(34), date-1, date-2) + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code) + " " + p-find-condition)
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    else do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-61  as logical   no-undo .
define variable  l-filter-open-61    as logical   .
define variable  flt-rec-61       as recid     no-undo .
define variable  filter-name-61      as character no-undo .
define variable  where-phrase-61     as character no-undo .
define variable  sort-phrase-61      as character no-undo .
define variable  where-phrase-rus-61 as character no-undo .
define variable  sort-phrase-rus-61  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-61
  ,output filter-name-61
  ,output where-phrase-61
  ,output sort-phrase-61
  ,output where-phrase-rus-61
  ,output sort-phrase-rus-61
  ).
if p-open-query then do:
  assign
    l-filter-open-61 = false
  .
  if flt-rec-61 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-61 as character no-undo .
    define variable  parameter-3-61 as character no-undo .
    define variable  parameter-4-61 as character no-undo .
    define variable  parameter-5-61 as character no-undo .
    define variable  parameter-6-61 as character no-undo .
    define variable  parameter-7-61 as character no-undo .
      assign
      parameter-3-61 =
                              "FOR EACH buf_fin-ob"
      parameter-4-61 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  " + " " + where-phrase-61) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34), date-1, date-2) + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code))
      parameter-6-61 = if sort-phrase-61 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-61
        )
      parameter-7-61 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-61 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  " + " " + where-phrase-61 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-61
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ,input parameter-6-61
                          ,input parameter-7-61
                          )
      .
      assign
        l-filter-open-61 = true
      .
    end.
    if l-filter-open-61 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-61 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2
    ,first temp-contr where temp-contr.id = buf_fin-ob.contract-code
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-61 = (if p-find-next then "true":u else "false":u )
      parameter-4-61 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34), date-1, date-2) + " ":u + where-phrase-61 + " ":u + p-find-condition + " " + ""
      parameter-5-61 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-61)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-61 = (if p-find-next then "true":u else "false":u )
      parameter-3-61 =  "FOR EACH buf_fin-ob"
      parameter-4-61 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  " + " " + where-phrase-61) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34), date-1, date-2) + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code) + " " + p-find-condition)
      parameter-6-61 = if sort-phrase-61 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-61
        )
      parameter-7-61 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-61)
                          ,input no-lock
                          ,input parameter-3-61
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ,input parameter-6-61
                          ,input parameter-7-61
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  else do:
    if Curr-types = "all" then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-63  as logical   no-undo .
define variable  l-filter-open-63    as logical   .
define variable  flt-rec-63       as recid     no-undo .
define variable  filter-name-63      as character no-undo .
define variable  where-phrase-63     as character no-undo .
define variable  sort-phrase-63      as character no-undo .
define variable  where-phrase-rus-63 as character no-undo .
define variable  sort-phrase-rus-63  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-63
  ,output filter-name-63
  ,output where-phrase-63
  ,output sort-phrase-63
  ,output where-phrase-rus-63
  ,output sort-phrase-rus-63
  ).
if p-open-query then do:
  assign
    l-filter-open-63 = false
  .
  if flt-rec-63 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-63 as character no-undo .
    define variable  parameter-3-63 as character no-undo .
    define variable  parameter-4-63 as character no-undo .
    define variable  parameter-5-63 as character no-undo .
    define variable  parameter-6-63 as character no-undo .
    define variable  parameter-7-63 as character no-undo .
      assign
      parameter-3-63 =
                              "FOR EACH buf_fin-ob"
      parameter-4-63 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2  " + " " + where-phrase-63) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 ', p-host-code, p-fo-type, 'факт':U, chr(34)) + " " + where-phrase-63
          else "true"
        )
      parameter-5-63 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code))
      parameter-6-63 = if sort-phrase-63 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-63
        )
      parameter-7-63 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-63 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2  " + " " + where-phrase-63 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-63
                          ,input parameter-4-63
                          ,input parameter-5-63
                          ,input parameter-6-63
                          ,input parameter-7-63
                          )
      .
      assign
        l-filter-open-63 = true
      .
    end.
    if l-filter-open-63 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-63 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2
    ,first temp-contr where temp-contr.id = buf_fin-ob.contract-code
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-63 = (if p-find-next then "true":u else "false":u )
      parameter-4-63 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 ', p-host-code, p-fo-type, 'факт':U, chr(34)) + " ":u + where-phrase-63 + " ":u + p-find-condition + " " + ""
      parameter-5-63 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-63)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-63
                          ,input parameter-5-63
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-63 = (if p-find-next then "true":u else "false":u )
      parameter-3-63 =  "FOR EACH buf_fin-ob"
      parameter-4-63 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  'факт':U and buf_fin-ob.con-stat <> 2  " + " " + where-phrase-63) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 ', p-host-code, p-fo-type, 'факт':U, chr(34)) + " " + where-phrase-63
          else "true"
        )
      parameter-5-63 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code) + " " + p-find-condition)
      parameter-6-63 = if sort-phrase-63 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-63
        )
      parameter-7-63 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-63)
                          ,input no-lock
                          ,input parameter-3-63
                          ,input parameter-4-63
                          ,input parameter-5-63
                          ,input parameter-6-63
                          ,input parameter-7-63
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    else do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-65  as logical   no-undo .
define variable  l-filter-open-65    as logical   .
define variable  flt-rec-65       as recid     no-undo .
define variable  filter-name-65      as character no-undo .
define variable  where-phrase-65     as character no-undo .
define variable  sort-phrase-65      as character no-undo .
define variable  where-phrase-rus-65 as character no-undo .
define variable  sort-phrase-rus-65  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-65
  ,output filter-name-65
  ,output where-phrase-65
  ,output sort-phrase-65
  ,output where-phrase-rus-65
  ,output sort-phrase-rus-65
  ).
if p-open-query then do:
  assign
    l-filter-open-65 = false
  .
  if flt-rec-65 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-65 as character no-undo .
    define variable  parameter-3-65 as character no-undo .
    define variable  parameter-4-65 as character no-undo .
    define variable  parameter-5-65 as character no-undo .
    define variable  parameter-6-65 as character no-undo .
    define variable  parameter-7-65 as character no-undo .
      assign
      parameter-3-65 =
                              "FOR EACH buf_fin-ob"
      parameter-4-65 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code  " + " " + where-phrase-65) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34)) + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code))
      parameter-6-65 = if sort-phrase-65 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-65
        )
      parameter-7-65 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-65 =
          (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code  " + " " + where-phrase-65 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input parameter-3-65
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ,input parameter-6-65
                          ,input parameter-7-65
                          )
      .
      assign
        l-filter-open-65 = true
      .
    end.
    if l-filter-open-65 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-65 = false then do:
    OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
      where  buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code
    ,first temp-contr where temp-contr.id = buf_fin-ob.contract-code
       by buf_fin-ob.pay-date descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-ob )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Fin-Ob-List:handle:get-buffer-handle(1) = (buffer buf_fin-ob:handle) then do:
      assign
      parameter-2-65 = (if p-find-next then "true":u else "false":u )
      parameter-4-65 =
        "where ":u +  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34)) + " ":u + where-phrase-65 + " ":u + p-find-condition + " " + ""
      parameter-5-65 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input rowid(buf_fin-ob)
                          ,input logical(parameter-2-65)
                          ,input no-lock
                          ,input (buffer buf_fin-ob:handle)
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-65 = (if p-find-next then "true":u else "false":u )
      parameter-3-65 =  "FOR EACH buf_fin-ob"
      parameter-4-65 =
        (
          if (" buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = 'факт':U  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code  " + " " + where-phrase-65) <> ""
          then  substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, 'факт':U, curr-code , chr(34)) + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code) + " " + p-find-condition)
      parameter-6-65 = if sort-phrase-65 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by buf_fin-ob.pay-date descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-65
        )
      parameter-7-65 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Fin-Ob-List:handle
                          ,input logical(parameter-2-65)
                          ,input no-lock
                          ,input parameter-3-65
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ,input parameter-6-65
                          ,input parameter-7-65
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  REPOSITION Fin-Ob-List to recid v-doc-rec No-ERROR.
END PROCEDURE.
PROCEDURE proc-check-contract :
  define buffer b_fin-ob for fin-ob .
  define buffer b_fin-doc for fin-doc .
  define variable num-cont as integer   no-undo .
  define variable is-del as logical   no-undo .
  define variable obj-type as character no-undo .
  define variable obj-code as integer no-undo .
  assign num-cont = - 1 .
  for each temp-fin-ob :
    find first b_fin-ob no-lock where recid(b_fin-ob) = temp-fin-ob.ri .
    if num-cont = - 1 then
      assign
        num-cont = b_fin-ob.contract-code
        obj-type = b_fin-ob.obj-type
        obj-code = b_fin-ob.obj-code
      .
    else do:
      if obj-code <> 0 then do:
        if obj-type <> b_fin-ob.obj-type or obj-code <> b_fin-ob.obj-code then assign obj-code = 0 .
      end.
      if num-cont <> b_fin-ob.contract-code then do:
        message
          "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") относится к другому договору, чем предыдущие док-ты!"
        view-as alert-box.
        return error .
      end.
    end.
    if b_fin-ob.con-stat = 2 then do:
      message
        "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") уже полностью связано с платежем! Если хотите связать заново, то удалите сначала старую связь"
      view-as alert-box.
      return error .
    end.
  end.
  for each temp-fin-doc :
    find first b_fin-doc no-lock where recid(b_fin-doc) = temp-fin-doc.ri .
    if num-cont = - 1 then
      assign
        num-cont = b_fin-doc.contract-code
      .
    else do:
      if obj-code <> 0 then do:
        if obj-type <> b_fin-doc.obj-type or obj-code <> b_fin-doc.obj-code then assign obj-code = 0 .
      end.
      if num-cont <> b_fin-doc.contract-code then do:
        message
          "Платеж № " b_fin-doc.prn-doc-code " от " b_fin-doc.doc-date " относится к другому договору, чем предыдущие док-ты!"
        view-as alert-box.
        return error .
      end.
    end.
    if b_fin-ob.con-stat = 2  then do:
      message
        "Платеж № " b_fin-doc.prn-doc-code " от " b_fin-doc.doc-date " уже полностью связан с фин. обяз.! Если хотите связать заново, то удалите сначала старую связь"
      view-as alert-box.
      return error .
    end.
  end.
  if sysconf.fin-calc = 1 and obj-code = 0 then do:
    message
      substitute ("По фирме &1 ведется раздельный учет по объектам с поставщиками. Нельзя связать платежи и ФО с разных объектов.",sysconf.host-code)
    view-as alert-box.
    return error .
  end.
END PROCEDURE.
PROCEDURE proc-find-cli :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer   no-undo .
  define input parameter p-type as character no-undo .
  display "  /  /":U @ sch-date "":U @ sch-code  with frame Dialog-Frame.
  assign p-type = chr(34) + p-type + chr(34).
  if RADIO-find-doc = 1 then do:
    if RADIO-find-cli = 1 then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.payer-code = &1 and buf_fin-ob.payer-type = &2 ", p-code, p-type)) .
    else                       run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.receiver-code = &1 and buf_fin-ob.receiver-type = &2 ", p-code, p-type)) .
  end.
  else do:
    if RADIO-find-cli = 1 then run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.payer-code = &1 and buf_fin-doc.payer-type = &2 ", p-code, p-type)) .
    else                       run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.receiver-code = &1 and buf_fin-doc.receiver-type = &2 ", p-code, p-type)) .
  end.
  apply "entry":u to cli-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-cli-name :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .
  display "  /  /":U @ sch-date "":U @ sch-code 0 @ cli-code "":U @ cli-type with frame Dialog-Frame.
  assign p-code = replace(p-code, chr(39), chr(39) + chr(39)) .
  if RADIO-find-doc = 1 then do:
    if RADIO-find-cli = 1 then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.payer-name begins '&1' ", p-code)) .
    else                       run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.receiver-name begins '&1' ", p-code)) .
  end.
  else do:
    if RADIO-find-cli = 1 then run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.payer-name begins '&1' ", p-code)) .
    else                       run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.receiver-name begins '&1' ", p-code)) .
  end.
  apply "entry":u to cli-name in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-code :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .
  display "  /  /":U @ sch-date 0 @ cli-code "":U @ cli-type "":U @ cli-name with frame Dialog-Frame.
  assign p-code = replace(p-code, chr(39), chr(39) + chr(39)) .
  if RADIO-find-doc = 1 then do:
    if p-code = '""' then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.prn-doc-code = '' " )).
    else                  run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.prn-doc-code begins '&1' ", p-code)).
  end.
  else do:
    if p-code = '""' then run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.prn-doc-code = '' " )).
    else                  run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.prn-doc-code begins '&1' ", p-code)).
  end.
  apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
  define input parameter p-next as logical no-undo.
  define input parameter par-date as date    no-undo .
  display "":U @ sch-code 0 @ cli-code "":U @ cli-type "":U @ cli-name  with frame Dialog-Frame.
  define variable var-datechr as character no-undo .
  assign var-datechr = string(day(par-date)) + chr(47) + string(month(par-date)) + chr(47) + string(year(par-date)) .
  if RADIO-find-doc = 1 then run OpenBr  in this-procedure (input false, input p-next,input substitute("and buf_fin-ob.pay-date = &1 ", var-datechr)) .
  else                       run OpenBr1 in this-procedure (input false, input p-next,input substitute("and buf_fin-doc.doc-date = &1 ", var-datechr)) .
  apply "entry":u to sch-date in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-mark :
  assign
    sum-fin-ob = 0
    num-fin-ob = 0
  .
  GET FIRST Fin-Ob-List NO-LOCK .
  DO WHILE AVAILABLE(buf_fin-ob):
    find first temp-fin-ob where temp-fin-ob.ri = recid( buf_fin-ob ) no-error .
    if available temp-fin-ob then do:
      assign
        num-fin-ob = num-fin-ob + 1
        temp-fin-ob.del = no
      .
      assign
        sum-fin-ob = sum-fin-ob + get-free-sum(buffer buf_fin-ob)
      .
    end.
    GET next Fin-Ob-List NO-LOCK .
  end.
  for each temp-fin-ob where temp-fin-ob.del = yes : delete temp-fin-ob . end.
  if num-fin-ob = 0 then hide mark-num in frame Dialog-Frame.
  else                   display num-fin-ob @ mark-num  with frame Dialog-Frame.
  display sum-fin-ob  with frame Dialog-Frame.
end.
PROCEDURE proc-mark1 :
  assign
    sum-fin-doc = 0
    num-fin-doc = 0
  .
  GET FIRST Fin-Doc-List NO-LOCK .
  DO WHILE AVAILABLE(buf_fin-doc):
    find first temp-fin-doc where temp-fin-doc.ri = recid( buf_fin-doc ) no-error .
    if available temp-fin-doc then do:
      assign
        num-fin-doc = num-fin-doc + 1
        temp-fin-doc.del = no
      .
      assign
        sum-fin-doc = sum-fin-doc + get-free-sum1(buffer buf_fin-doc)
      .
    end.
    GET next Fin-Doc-List NO-LOCK .
  end.
  for each temp-fin-doc where temp-fin-doc.del = yes : delete temp-fin-doc . end.
  if num-fin-doc = 0 then hide mark-num-2 in frame Dialog-Frame.
  else                   display num-fin-doc @ mark-num-2  with frame Dialog-Frame.
  display sum-fin-doc  with frame Dialog-Frame.
end.
FUNCTION contract-gen RETURNS CHARACTER
  ( input p-contract-code as integer ) :
  define variable rr as character no-undo .
  define buffer buf_contract for contract.
  find first buf_contract no-lock where  buf_contract.host-code      = p-host-code  and buf_contract.contract-code  = p-contract-code no-error.
  if available buf_contract then   rr = buf_contract.usl-opl .
  else rr = "".
  RETURN rr.
END FUNCTION.
FUNCTION contract-id RETURNS CHARACTER
  ( input p-contract-code as integer ) :
  define variable rr as character no-undo .
  define buffer buf_contract for contract.
  find first buf_contract no-lock where  buf_contract.host-code      = p-host-code and buf_contract.contract-code  = p-contract-code  no-error.
  if available buf_contract then   rr = buf_contract.contract-prn-code.
  else rr = "".
  RETURN rr.
END FUNCTION.
FUNCTION get-curr-sum RETURNS decimal
  ( input p-cur as integer, input p-doc-curr as integer, input p-cur-contr as integer, input p-sum-contract as decimal, input p-sum-rubl as decimal, input p-sum-base as decimal, input p-sum-doc as decimal ) :
  define variable sum as decimal   no-undo .
  if p-cur = p-cur-contr then assign sum = p-sum-contract .
  else do:
    if p-cur = 1 then assign sum = p-sum-base .
    else do:
      if p-cur = p-doc-curr then assign sum = p-sum-doc .
      else do:
        if p-cur = 0 then assign sum = p-sum-rubl .
        else assign sum = ? .
      end.
    end.
  end.
  RETURN sum .
END FUNCTION.
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer ) :
define variable var-curr-name as character no-undo.
define buffer buf_currency for currency.
  find first buf_currency no-lock where buf_currency.curr-code = curr-code no-error .
  if available buf_currency then assign var-curr-name = buf_currency.curr-abbr .
RETURN var-curr-name.
END FUNCTION.
FUNCTION get-free-sum RETURNS decimal
  ( BUFFER loc-fin-ob FOR fin-ob ) :
  define variable sum as decimal   no-undo .
  if s-curr-code = loc-fin-ob.contract-curr then assign sum = loc-fin-ob.sum-contract - loc-fin-ob.con-sum-contr .
  else do:
    if s-curr-code = 1 then assign sum = loc-fin-ob.sum-base - loc-fin-ob.con-sum-base .
    else do:
      if s-curr-code = loc-fin-ob.curr-code then assign sum = loc-fin-ob.sum-doc - loc-fin-ob.con-sum-doc .
      else do:
        if s-curr-code = 0 then assign sum = loc-fin-ob.sum-rubl - loc-fin-ob.con-sum-rubl .
        else assign sum = ? .
      end.
    end.
  end.
  RETURN sum .
END FUNCTION.
FUNCTION get-free-sum1 RETURNS decimal
  ( BUFFER loc-fin-doc FOR fin-doc ) :
  define variable sum as decimal   no-undo .
  if s-curr-code = 0 then assign sum = loc-fin-doc.sum-rubl - loc-fin-doc.con-sum-rubl .
  else do:
    if s-curr-code = 1 then assign sum = loc-fin-doc.sum-base - loc-fin-doc.con-sum-base .
    else do:
      if s-curr-code = loc-fin-doc.curr-code then assign sum = loc-fin-doc.sum-doc - loc-fin-doc.con-sum-doc .
      else do:
        if s-curr-code = loc-fin-doc.contract-curr then assign sum = loc-fin-doc.sum-contr - loc-fin-doc.con-sum-contr .
        else assign sum = ? .
      end.
    end.
  end.
  if p-doc-type = 'при':U then do:
    if loc-fin-doc.fin-ext-doc-type = 'апп':U or
       loc-fin-doc.fin-ext-doc-type = 'пко':U or
       loc-fin-doc.fin-ext-doc-type = 'ппп':U then assign sum = - sum .
  end.
  else do:
    if loc-fin-doc.fin-ext-doc-type = 'апр':U or
       loc-fin-doc.fin-ext-doc-type = 'рко':U or
       loc-fin-doc.fin-ext-doc-type = 'рпп':U then assign sum = - sum .
  end.
  RETURN sum .
END FUNCTION.
FUNCTION get-ostat RETURNS decimal
  ( input p-sum1 as decimal, input p-sum2 as decimal ) :
  RETURN p-sum1 - p-sum2 .
END FUNCTION.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input typ as integer ) :
  define variable ret as character no-undo .
  assign ret = "" .
  define buffer b_fin-ob for fin-ob.
  define buffer b_fin-doc for fin-doc.
  if typ = 0 then do:
    find first temp-fin-ob where temp-fin-ob.ri = par-recid no-error .
    if available temp-fin-ob then
      assign
        ret = "*"
        temp-fin-ob.del = no
      .
  end.
  else do:
    find first temp-fin-doc where temp-fin-doc.ri = par-recid no-error .
    if available temp-fin-doc then
      assign
        ret = "*"
        temp-fin-doc.del = no
      .
  end.
  RETURN ret .
END FUNCTION.
