DEFINE BUFFER locked_fin-doc FOR ub.fin-doc.
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_firm FOR ub.firm.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-obj-type  like ub.fin-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.fin-doc.obj-code no-undo .
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo .
define input parameter p-ob-doc-code like ub.fin-ob.doc-code no-undo .
define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo .
define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo .
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define input parameter p-other as character no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: 12c0f79a3864, 3013, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoci6.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoci6.w $":U .
define variable vss-description as character no-undo init "Карточка редактирования расходного АПЗ".
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
define variable v-db-num like ub.db.db-num no-undo.
define variable v-view as character no-undo init "full":U.
define variable v-not-uf-set as logical no-undo.
define variable v-copy-mode as logical no-undo .
define variable v-main-sum as character no-undo init "sum-doc":U.
define variable v-main-curr as character no-undo init "":U.
define variable v-rubf          as logical no-undo .
define variable v-exchf         as logical no-undo .
define variable v-basef         as logical no-undo .
define variable v-baseratef     as logical no-undo .
define variable v-contractf     as logical no-undo .
define variable v-contractratef as logical no-undo .
define variable v-limit-access  as integer no-undo .
define variable paramVne as character no-undo .
define buffer X_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer X_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer X_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer X_fin-code-cor-acc1 for ub.fin-code-cor-acc.
define buffer X_currency for ub.currency.
define buffer X_contract-currency for ub.currency.
DEFINE BUFFER X_receiver FOR ub.clients.
DEFINE BUFFER X_payer FOR ub.clients.
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_contract for ub.contract.
define buffer X_fin-ob for ub.fin-ob.
define buffer X_receiver-firm for ub.firm.
define buffer X_receiver-person for ub.person.
define buffer X_clients-obj for ub.clients.
define buffer X_payer-firm for ub.firm.
define buffer X_payer-person for ub.person.
define buffer X_receiver-fin-schet for ub.fin-schet.
define buffer X_receiver-fin-bank for ub.fin-bank.
define buffer X_payer-fin-schet for ub.fin-schet.
define buffer X_payer-fin-bank for ub.fin-bank.
DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-head-position as character no-undo .
define variable v-tab-order as character no-undo.
define variable v-an-uchet-tab-order as character no-undo.
define variable v-sum-curr-tab-order as character no-undo.
define variable v-contract-tab-order as character no-undo init "b-contract-view,":U.
define variable v-sum-doc-tab-order  as character no-undo init "sum-doc,curr-code,b-currency,b-calc,":U.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
function getCliKassa returns logical (input p-type as character, input p-code as integer, input p-attr as character, cashbookId as integer) :
define buffer bf_CashBookRule  for ub.CashBookRule .
define buffer buf_CashBookRule for ub.CashBookRule .
find first bf_CashBookRule no-lock where bf_CashBookRule.CashBookID = cashbookId
  and bf_CashBookRule.Obj-type   = 'всем':U
  and bf_CashBookRule.Obj-code   = 0
  and bf_CashBookRule.Code       = p-attr + "-type"
  no-error.
if available (bf_CashBookRule) then
do:
  if p-type = bf_CashBookRule.RuleValue then
  do:
    find first buf_CashBookRule no-lock where buf_CashBookRule.CashBookID = cashbookId
      and buf_CashBookRule.Obj-type   = 'всем':U
      and buf_CashBookRule.Obj-code   = 0
      and buf_CashBookRule.Code       = p-attr + "-code"
      no-error.
    if available (buf_CashBookRule) then do:
        if p-code = integer(buf_CashBookRule.RuleValue) then return true .
    end.
  end.
end.
return false .
end function .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile: findocip.i $ $Revision: ff8019e24d02, 2996, rls $".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable v-is-auto-obj as logical no-undo .
define variable v-start       as integer no-undo .
define variable v-first-start as logical no-undo init yes.
assign
  v-start = (if p-mode = 'ДОБАВЛЕНИЕ':U then 2 else 1)
  .
DEFINE BUTTON B-an-uchet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-calc
     LABEL "Расчет сумм и курсов"
     SIZE 22 BY 1.
DEFINE BUTTON B-cel-nazn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-contract-view
     LABEL "&Договор"
     SIZE 12 BY 1
     FGCOLOR 4 .
DEFINE BUTTON B-cor-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-cor-acc1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-cashbook
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
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "&История"
     SIZE 10 BY 1.
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-payer-view
     LABEL "П&лательщик"
     SIZE 12 BY 1
     FGCOLOR 4 .
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-receiver
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-receiver-view
     LABEL "П&олучатель"
     SIZE 12 BY 1.
DEFINE BUTTON B-tax
     LABEL "&Налоги"
     SIZE 10 BY 1.
DEFINE VARIABLE f-an-uchet-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE f-cel-nazn-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE f-contract-curr-abbr AS CHARACTER FORMAT "X(3)":U INITIAL "0"
     VIEW-AS FILL-IN
     SIZE 6.3 BY 1 NO-UNDO.
DEFINE VARIABLE f-contract-date AS DATE FORMAT "99/99/9999":U
     LABEL "от"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE f-contract-prn-code AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE f-contract-type AS CHARACTER FORMAT "X(23)":U
     LABEL "тип дог-ра"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE f-cor-acc-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE f-cor-acc1-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE F-credit AS CHARACTER FORMAT "X(256)":U INITIAL "Кредит"
      VIEW-AS TEXT
     SIZE 7.3 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-curr-abbr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-debet AS CHARACTER FORMAT "X(256)":U INITIAL "Дебет"
      VIEW-AS TEXT
     SIZE 6.3 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-cashbook AS CHARACTER FORMAT "X(256)":U INITIAL "Кассовая книга:"
      VIEW-AS TEXT
     SIZE 15 BY .67
     NO-UNDO.
DEFINE VARIABLE f-cashbook AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE f-rest-con-sum AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Своб.ост.(в.д.)"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE RS-view AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 36.5 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      locked_fin-doc SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-tax AT ROW 1 COL 59
     B-print AT ROW 1 COL 69
     B-hist AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     RS-view AT ROW 1.07 COL 22.3 NO-LABEL
     tt-fin-doc.user-name-doc AT ROW 1.97 COL 82.8 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.prn-doc-code AT ROW 2 COL 16.5 COLON-ALIGNED
          LABEL "Номер документа"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     tt-fin-doc.fin-doc-code AT ROW 2 COL 46 COLON-ALIGNED
          LABEL "Внутр. №"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-fin-doc.perm-date AT ROW 2 COL 71.5 COLON-ALIGNED
          LABEL "Дата разр"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-fin-doc.doc-date AT ROW 3 COL 11 COLON-ALIGNED
          LABEL "Дата сост."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-doc.user-name-perm AT ROW 3 COL 22.4 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.obj-type AT ROW 3 COL 39.4 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U
          SIZE 12.6 BY 1
     tt-fin-doc.obj-code AT ROW 3 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1
     B-obj AT ROW 3 COL 59
     tt-fin-doc.fact-date AT ROW 3 COL 71.5 COLON-ALIGNED
          LABEL "Дата факт"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-fin-doc.user-name-fact AT ROW 3 COL 82.8 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.payer-type AT ROW 4 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-fin-doc.payer-code AT ROW 4 COL 4.3 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-fin-doc.payer-okpo AT ROW 4 COL 17.3 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-doc.payer-name AT ROW 4 COL 28.3 COLON-ALIGNED NO-LABEL FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 50 BY 1
          FGCOLOR 4
     B-payer-view AT ROW 4 COL 87
     tt-fin-doc.str-podr-type AT ROW 5 COL 1.3
          LABEL "Структ.подразд."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     tt-fin-doc.str-podr-code AT ROW 5 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-doc.str-podr-name AT ROW 5 COL 53.9 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 43 BY 1
          FGCOLOR 4
     tt-fin-doc.cor-acc-value AT ROW 6 COL 16.3 COLON-ALIGNED
          LABEL "Корсчет"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     B-cor-acc AT ROW 6 COL 33.1
     f-cor-acc-descr AT ROW 6 COL 35.8 COLON-ALIGNED NO-LABEL
     tt-fin-doc.an-uchet-value AT ROW 7 COL 5.3
          LABEL "Код ан. уч."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     B-an-uchet AT ROW 7 COL 33.1
     f-an-uchet-descr AT ROW 7 COL 35.8 COLON-ALIGNED NO-LABEL
     f-contract-curr-abbr AT ROW 7.47 COL 53.3 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     B-contract-view AT ROW 7.5 COL 1
     f-contract-prn-code AT ROW 7.5 COL 12 COLON-ALIGNED NO-LABEL
     f-contract-date AT ROW 7.5 COL 36.6 COLON-ALIGNED
     tt-fin-doc.contract-curr AT ROW 7.5 COL 49.1 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     f-contract-type AT ROW 7.5 COL 72 COLON-ALIGNED
     tt-fin-doc.cor-acc1-value AT ROW 8 COL 16.3 COLON-ALIGNED
          LABEL "Корсчет"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     B-cor-acc1 AT ROW 8 COL 33.1
     f-cor-acc1-descr AT ROW 8 COL 35.8 COLON-ALIGNED NO-LABEL
     tt-fin-doc.cel-nazn-value AT ROW 9 COL 16.3 COLON-ALIGNED
          LABEL "Код цел.назн."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     B-cel-nazn AT ROW 9 COL 33.1
     f-cel-nazn-descr AT ROW 9 COL 35.8 COLON-ALIGNED NO-LABEL
     tt-fin-doc.sum-doc AT ROW 10 COL 6 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          FGCOLOR 4
     f-rest-con-sum AT ROW 10 COL 72.3 COLON-ALIGNED
     tt-fin-doc.curr-code AT ROW 10.03 COL 41.9 COLON-ALIGNED
          LABEL "Вал"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-currency AT ROW 10.03 COL 48.9
     F-curr-abbr AT ROW 10.03 COL 50.9 COLON-ALIGNED NO-LABEL
     B-calc AT ROW 11 COL 1.5
     tt-fin-doc.exch-rate AT ROW 11 COL 34.5 COLON-ALIGNED
          LABEL "Курс пл-жа"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-fin-doc.exch-scale AT ROW 11 COL 44.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-fin-doc.sum-rubl AT ROW 11 COL 72.3 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-fin-doc.base-rate AT ROW 12 COL 34.5 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-fin-doc.base-scale AT ROW 12 COL 44.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-fin-doc.sum-base AT ROW 12 COL 72.1 COLON-ALIGNED
          LABEL "Б.в."
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-fin-doc.contract-rate AT ROW 13 COL 34.5 COLON-ALIGNED
          LABEL "Курс дог."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-fin-doc.contract-scale AT ROW 13 COL 44.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-fin-doc.sum-contr AT ROW 13 COL 72.3 COLON-ALIGNED
          LABEL "в.дог-ра"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     B-receiver AT ROW 13.97 COL 27.4
     tt-fin-doc.receiver-type AT ROW 14 COL 1 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 1", "2":U
          SIZE 13.5 BY 1
     tt-fin-doc.receiver-code AT ROW 14 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-fin-doc.receiver-name AT ROW 14 COL 30.3 COLON-ALIGNED NO-LABEL FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 53 BY 1
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     B-receiver-view AT ROW 14 COL 87
     tt-fin-doc.naznach-plat AT ROW 16 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.5 TOOLTIP "Основание платежа"
          FGCOLOR 4
     tt-fin-doc.PS AT ROW 18.5 COL 1.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 97 BY 1.5 TOOLTIP "Дополнительная информация, не печатающаяся в АПЗ"
     tt-fin-doc.payer-sign1 AT ROW 20 COL 47
          LABEL "От лица ПЛАТЕЛЬЩИКА"
          VIEW-AS FILL-IN
          SIZE 30.9 BY 1
          FGCOLOR 4
     tt-fin-doc.receiver-sign1 AT ROW 21 COL 48
          LABEL "От лица ПОЛУЧАТЕЛЯ"
          VIEW-AS FILL-IN
          SIZE 30.9 BY 1
          FGCOLOR 4
     l-cashbook at row 22.2 col 1 no-label
     f-cashbook at row 22 col 19 no-label
     b-cashbook at row 22 col 61 FGCOLOR 4
     F-debet AT ROW 6.13 COL 1.9 NO-LABEL
     F-credit AT ROW 8 COL 1 NO-LABEL
     "(Примечание (доп.информация, не печатается))" VIEW-AS TEXT
          SIZE 47.1 BY 1 AT ROW 17.5 COL 51
     "Основание платежа" VIEW-AS TEXT
          SIZE 19.4 BY 1 AT ROW 15 COL 1.3
          FGCOLOR 4
     SPACE(78.55) SKIP(6.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расходный АПЗ - Плательщик"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable v-format as integer no-undo .
define variable v-cmp as character no-undo .
define variable v-log as logical no-undo .
buffer-compare tt-fin-doc except payer-sign1
to locked_fin-doc
case-sensitive
save result in v-cmp .
if v-cmp <> "":U
or  entry((if num-entries(locked_fin-doc.payer-sign1, chr(4)) > 1
           then 2
           else 1)
           , locked_fin-doc.payer-sign1, chr(4)
         ) <> tt-fin-doc.payer-sign1
then do:
  message
  "Вы изменили ПЛАТЕЖ, но не сохранили его" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log ) no-error.
run ref/fdoc-prn.p (
        input parparentproc
      , input this-procedure
      , input string(recid(locked_fin-doc))
                      ) no-error.
if error-status:error then return no-apply.
END.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-color-widgets :
define input parameter p-list as character no-undo .
define input parameter p-fg as logical no-undo .
define input parameter p-bg as logical no-undo .
define input parameter p-fgc as integer no-undo .
define input parameter p-bgc as integer no-undo .
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
  do
  on error undo, return error
  :
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if LOOKUP(hh:name, p-list) > 0  then do:
        assign
        hh:fgcolor = (if p-fg then p-fgc else hh:fgcolor)
        hh:bgcolor = (if p-bg then p-bgc else hh:bgcolor)
        .
      end.
      hh = hh:next-sibling.
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile: findocip.i $ $Revision: ff8019e24d02, 2996, rls $".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-buffers :
  DEFINE input parameter X_clients-host-recid as recid no-undo .
  DEFINE input parameter X_firm-recid as recid no-undo .
  DEFINE input parameter X_sysconf-recid as recid no-undo .
  define input parameter X_fin-code-cor-acc-recid as recid no-undo .
  define input parameter X_fin-code-cor-acc1-recid as recid no-undo .
  define input parameter X_fin-code-an-uchet-recid as recid no-undo .
  define input parameter X_fin-code-cel-nazn-recid as recid no-undo .
  define input parameter X_currency-recid as recid no-undo .
  define input parameter X_contract-currency-recid as recid no-undo .
  DEFINE input parameter X_receiver-recid as recid no-undo .
  DEFINE input parameter X_payer-recid as recid no-undo .
  define input parameter X_curr_sysconf-recid as recid no-undo .
  define input parameter X_payer-fin-schet-recid as recid no-undo .
  define input parameter X_payer-fin-bank-recid as recid no-undo .
  define input parameter X_payer-firm-recid as recid no-undo .
  define input parameter X_payer-person-recid as recid no-undo .
  define input parameter X_receiver-fin-schet-recid as recid no-undo .
  define input parameter X_receiver-fin-bank-recid as recid no-undo .
  define input parameter X_receiver-firm-recid as recid no-undo .
  define input parameter X_receiver-person-recid as recid no-undo .
  define input parameter X_contract-recid as recid no-undo .
  define input parameter X_fin-ob-recid as recid no-undo .
  define input parameter X_clients-obj-recid as recid no-undo .
  define input parameter p-f-cor-acc1-descr as character no-undo .
  define input parameter p-f-cor-acc-descr as character no-undo .
  define input parameter p-f-an-uchet-descr as character no-undo .
  define input parameter p-f-cel-nazn-descr as character no-undo .
  do
    on error undo, return error
    :
    find first X_clients-host no-lock where                   recid(X_clients-host)          = X_clients-host-recid no-error  .
    find first X_firm no-lock where                           recid(X_firm)                  = X_firm-recid no-error .
    find first X_sysconf no-lock where                        recid(X_sysconf)               = X_sysconf-recid no-error .
    find first X_fin-code-cor-acc no-lock where               recid(X_fin-code-cor-acc)      = X_fin-code-cor-acc-recid no-error .
    find first X_fin-code-cor-acc1 no-lock where              recid(X_fin-code-cor-acc1)     = X_fin-code-cor-acc1-recid no-error .
    find first X_fin-code-an-uchet no-lock where              recid(X_fin-code-an-uchet)     = X_fin-code-an-uchet-recid no-error .
    find first X_fin-code-cel-nazn no-lock where              recid(X_fin-code-cel-nazn)     = X_fin-code-cel-nazn-recid no-error .
    find first X_currency no-lock where                       recid(X_currency)              = X_currency-recid no-error .
    find first X_contract-currency no-lock where              recid(X_contract-currency)     = X_contract-currency-recid no-error .
    find first X_receiver no-lock where                       recid(X_receiver)              = X_receiver-recid no-error .
    find first X_payer no-lock where                          recid(X_payer)                 = X_payer-recid no-error .
    find first X_curr_sysconf no-lock where                   recid(X_curr_sysconf)          = X_curr_sysconf-recid no-error .
    find first X_payer-fin-schet no-lock where                recid(X_payer-fin-schet)       = X_payer-fin-schet-recid no-error .
    find first X_payer-fin-bank no-lock where                 recid(X_payer-fin-bank)        = X_payer-fin-bank-recid no-error .
    find first X_payer-firm no-lock where                     recid(X_payer-firm)            = X_payer-firm-recid no-error .
    find first X_payer-person no-lock where                   recid(X_payer-person)          = X_payer-person-recid no-error .
    find first X_receiver-fin-schet no-lock where             recid(X_receiver-fin-schet)    = X_receiver-fin-schet-recid no-error .
    find first X_receiver-fin-bank no-lock where              recid(X_receiver-fin-bank)     = X_receiver-fin-bank-recid no-error .
    find first X_receiver-firm no-lock where                  recid(X_receiver-firm)         = X_receiver-firm-recid no-error .
    find first X_receiver-person no-lock where                recid(X_receiver-person)       = X_receiver-person-recid no-error .
    find first X_contract no-lock where                       recid(X_contract)              = X_contract-recid no-error .
    find first X_fin-ob no-lock where                         recid(X_fin-ob)                = X_fin-ob-recid no-error .
    find first X_clients-obj no-lock where                    recid(X_clients-obj)           = X_clients-obj-recid no-error .
    assign
      f-cor-acc1-descr = p-f-cor-acc1-descr
      f-cor-acc-descr  = p-f-cor-acc-descr
      f-an-uchet-descr = p-f-an-uchet-descr
      f-cel-nazn-descr = p-f-cel-nazn-descr
      .
  end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile: findocip.i $ $Revision: ff8019e24d02, 2996, rls $".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fin-doc.doc-date in frame Dialog-Frame
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
on delete-character of tt-fin-doc.doc-date in frame Dialog-Frame
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
on ctrl-d of tt-fin-doc.doc-date in frame Dialog-Frame
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
on ctrl-b of tt-fin-doc.doc-date in frame Dialog-Frame
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
on ctrl-e of tt-fin-doc.doc-date in frame Dialog-Frame
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
on ctrl-f of tt-fin-doc.doc-date in frame Dialog-Frame
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
  if tt-fin-doc.doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-fin-doc.doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date18 :HANDLE
      tt-fin-doc.doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle18 as handle no-undo .
  assign
    v-label-handle18 = tt-fin-doc.doc-date :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to tt-fin-doc.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-2 in menu m-ed-date18 DO:
    apply "ctrl-d":U to tt-fin-doc.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-3 in menu m-ed-date18 DO:
    apply "ctrl-e":U to tt-fin-doc.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-4 in menu m-ed-date18 DO:
    apply "ctrl-f":U to tt-fin-doc.doc-date in frame Dialog-Frame .
  END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
  DO:
    define variable v-obj-type like ub.fin-doc.obj-type no-undo .
    define variable v-obj-code like ub.fin-doc.obj-code no-undo .
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run str/chshobj.w ( tt-fin-doc.host-code
  , tt-fin-doc.obj-type
  , tt-fin-doc.obj-code
  , output v-obj-type
  , output v-obj-code
  ) no-error .
if error-status:error
  or (
  v-obj-type = tt-fin-doc.obj-type
  AND v-obj-code = tt-fin-doc.obj-code)
  or v-obj-code = 0
  or v-obj-type = "":U
  then
do:
  return no-apply.
end.
find first X_clients-obj no-lock where
  X_clients-obj.obj-type = v-obj-type
  AND X_clients-obj.obj-code = v-obj-code .
assign
  tt-fin-doc.obj-type = X_clients-obj.obj-type
  tt-fin-doc.obj-code = X_clients-obj.obj-code
  .
display
  tt-fin-doc.obj-type
  tt-fin-doc.obj-code
  with frame Dialog-Frame.
run check-obj in this-procedure (  input tt-fin-doc.obj-type
  ,input tt-fin-doc.obj-code
  )
  no-error.
END.
ON LEAVE OF tt-fin-doc.obj-code IN FRAME Dialog-Frame
  DO:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if   input frame Dialog-Frame tt-fin-doc.obj-code <> 0 then
do:
  run check-obj in this-procedure (
    input frame Dialog-Frame tt-fin-doc.obj-type
    ,input frame Dialog-Frame tt-fin-doc.obj-code
    )
    no-error.
  if error-status:error then
  do:
    return no-apply.
  end.
end.
END.
ON VALUE-CHANGED OF tt-fin-doc.obj-type IN FRAME Dialog-Frame
  DO:
    assign
      tt-fin-doc.obj-type.
    if   input frame Dialog-Frame tt-fin-doc.obj-code <> 0 then
    do:
      run check-obj in this-procedure (
        input frame Dialog-Frame tt-fin-doc.obj-type
        ,input frame Dialog-Frame tt-fin-doc.obj-code
        )
        no-error.
      if error-status:error then
      do:
        return no-apply.
      end.
    end.
  END.
PROCEDURE check-obj :
  define input parameter p-check-obj-type as character no-undo .
  define input parameter p-check-obj-code as integer no-undo .
  define variable v-obj-db-num as integer no-undo init -1.
  define variable v-cash-book  as integer no-undo .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where
    buf_clients.obj-code = p-check-obj-code
    and buf_clients.obj-type = p-check-obj-type no-error.
  if not available buf_clients then
  do:
    if p-check-obj-code <> ?  then
      message "Неправильный код или тип объекта" .
    apply "entry" to tt-fin-doc.obj-code in frame Dialog-Frame.
    return error.
  end.
  find first X_clients-obj no-lock where recid(X_clients-obj) = recid(buf_clients).
  assign
    tt-fin-doc.obj-type = buf_clients.obj-type
    tt-fin-doc.obj-code = buf_clients.obj-code
    .
  display
    tt-fin-doc.obj-type
    tt-fin-doc.obj-code
    with frame Dialog-Frame.
  if not (tt-fin-doc.obj-type = '' and tt-fin-doc.obj-code = 0) then
  do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  tt-fin-doc.obj-type
  ,input  tt-fin-doc.obj-code
  ,output v-obj-db-num
  )  .
    define variable l-shift-on as logical no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  tt-fin-doc.obj-type
  ,input  tt-fin-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    assign
      tt-fin-doc.shift-flag = (if l-shift-on
                                  and lookup(tt-fin-doc.fin-ext-doc-type, 'пко,рко':U) > 0
                                  and (tt-fin-doc.doc-author = 'manual':U or tt-fin-doc.doc-author = 'auto':U)
                                  and v-obj-db-num = v-cntxt-db-num
                                  then integer('1':U)
                                  else 0)
      .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    define variable mCashBook         as class     ibs.th.ref.cashbookstorage no-undo .
    define variable par-type          as character no-undo .
    define variable v-dpt-option      as character no-undo .
    define variable v-dpt-dflt-name   as character no-undo .
    define variable v-dpt-dflt-type   as character no-undo .
    define variable v-dpt-dflt-code   as integer   no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as INTEGER   no-undo .
    define variable v-value-logical   AS LOGICAL   no-undo .
    define variable v-tth             as handle    no-undo .
    define variable v-naznach-plat    as character no-undo .
    define variable v-enclosure       as character no-undo .
    define variable o-head-position   as character no-undo .
    define variable o-director        as character no-undo .
    define variable o-snr-accnt       as character no-undo .
    define variable o-cashier         as character no-undo .
    define variable v-head-position   as character no-undo .
    define variable v-director        as character no-undo .
    define variable v-snr-accnt       as character no-undo .
    define variable v-cashier         as character no-undo .
    define variable v-hist-code       as character no-undo .
    define variable v-hist-name       as character no-undo .
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_shop    for ub.shop .
    define buffer buf_store   for ub.store .
    define buffer buf_firm    for ub.firm .
    assign
      v-tth = buffer thbjattr_thbj-attr:table-handle .
    mCashBook = new ibs.th.ref.cashbookstorage () .
    v-dpt-option    = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "Struct") .
    v-dpt-dflt-name = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "DptName") .
    v-dpt-dflt-type = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "DptType") .
    v-dpt-dflt-code = integer(mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "DptCode")) .
    o-head-position = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerPosition") .
    o-director      = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerFIO") .
    o-snr-accnt     = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BuhFIO") .
    delete object mCashBook no-error .
    case v-dpt-option:
      when "1" then
        do:
          for first ub.db-attr no-lock where ub.db-attr.db-num = v-cntxt-db-num
          and ub.db-attr.attr-code = 'hist-code':U:
            v-hist-code = ub.db-attr.attr-value .
          end.
          for first ub.db-attr no-lock where ub.db-attr.db-num = v-cntxt-db-num
          and ub.db-attr.attr-code = 'hist-name':U:
            v-hist-name = ub.db-attr.attr-value .
          end.
          if v-hist-code = "" then v-dpt-dflt-code = X_clients-obj.obj-code .
          if v-hist-name = "" then v-dpt-dflt-name = X_clients-obj.obj-name .
          v-dpt-dflt-type = X_clients-obj.obj-type  .
        end.
      when "0" then
        do:
          assign
            v-dpt-dflt-name = ''
            v-dpt-dflt-type = ''
            v-dpt-dflt-code = 0
            .
        end.
      otherwise
      do:
        assign
          v-dpt-dflt-name = v-dpt-dflt-name
          v-dpt-dflt-type = v-dpt-dflt-type
          v-dpt-dflt-code = v-dpt-dflt-code
          .
      end.
    end case.
    find first buf_sysconf no-error .
    case o-head-position:
      when '0':U then
        do:
          v-head-position = buf_sysconf.head-position.
        end.
      when '1':U then
        do:
          v-head-position = "Директор".
        end.
      when '2':U then
        do:
          v-head-position = "Управляющий".
        end.
      otherwise
      do :
        v-head-position = o-head-position.
      end.
    end case.
    find first buf_firm no-lock where
      buf_firm.firm-code = buf_sysconf.host-code.
    case o-director:
      when '1':U then
        do:
          if p-obj-type = 'маг':U then
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then
            do:
              v-director = buf_shop.director.
            end.
          end.
          if p-obj-type = 'скл':U then
          do:
            find first buf_store no-lock where
              buf_store.obj-code = p-obj-code no-error .
            if available buf_store then
            do:
              v-director = buf_store.store-boss.
            end.
          end.
        end.
      when '0':U then
        do:
          v-director = buf_firm.director.
        end.
      otherwise
      do:
        v-director = o-director .
      end.
    end case.
    case o-snr-accnt:
      when '1':U then
        do:
          if p-obj-type = 'маг':U then
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then
            do:
              v-snr-accnt = entry(1,buf_shop.acct,"|").
            end.
          end.
          if p-obj-type = 'скл':U then
          do:
            v-snr-accnt = ''.
          end.
        end.
      when '2':U then
        do:
          v-snr-accnt = buf_sysconf.snr-accnt.
        end.
      otherwise
      do:
        v-snr-accnt = o-snr-accnt .
      end.
    end case.
  FIND FIRST ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = p-obj-type AND
    ub.shift-staff.obj-code   = p-obj-code AND
    ub.shift-staff.shift-date = tt-fin-doc.shift-date AND
    ub.shift-staff.shift-num  = tt-fin-doc.shift-num AND
    ub.shift-staff.staff-role = no and
    ub.shift-staff.psn-num    >= 0 No-ERROR.
  assign
    v-cashier = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
  .
  if tt-fin-doc.fin-ext-doc-type = 'рко':U then
  do:
    assign
      tt-fin-doc.payer-sign1 = v-director
      tt-fin-doc.payer-sign2 = v-snr-accnt
      tt-fin-doc.payer-sign3 = v-cashier
      .
  end.
  if tt-fin-doc.fin-ext-doc-type = 'пко':U then
  do:
    assign
      tt-fin-doc.receiver-sign2 = v-snr-accnt
      tt-fin-doc.receiver-sign3 = v-cashier
      .
  end.
  find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.CashBookId no-error .
  if available (ub.CashBook) then
  do:
    case ub.CashBook.RuleOsnRko:
      when "0" then
        tt-fin-doc.naznach-plat = "Выручка от реализации" .
      when "1" or
      when "2" then
        tt-fin-doc.naznach-plat = "" .
      otherwise
      tt-fin-doc.naznach-plat = ub.CashBook.RuleOsnRko .
    end case .
    case ub.CashBook.RulePril:
      when '0' then
        do:
          tt-fin-doc.enclosure = v-naznach-plat .
        end.
      when '1' then
        do:
          tt-fin-doc.enclosure = "" .
        end.
      otherwise
      tt-fin-doc.enclosure = ub.CashBook.RulePril .
    end case.
    if ub.CashBook.CorrRko <> "" then
    do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrRko
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
      end.
    end.
    if tt-fin-doc.cor-acc = ? or tt-fin-doc.cor-acc = 0 then
    do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
      end.
    end.
    if ub.CashBook.OsnAcct <> "" then
    do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc1-value = ub.fin-code-cor-acc.code-value .
      end.
    end.
  end.
  assign
    tt-fin-doc.str-podr-name = if v-hist-name = "" then v-dpt-dflt-name else v-hist-name
    tt-fin-doc.str-podr-type = v-dpt-dflt-type
    tt-fin-doc.str-podr-code = v-dpt-dflt-code
    .
  display
    tt-fin-doc.str-podr-name
    tt-fin-doc.str-podr-type
    tt-fin-doc.str-podr-code
    tt-fin-doc.enclosure
    tt-fin-doc.naznach-plat
    tt-fin-doc.cor-acc
    tt-fin-doc.cor-acc1
    tt-fin-doc.cor-acc1-value
    tt-fin-doc.cor-acc-value
    with frame Dialog-Frame .
  end.
  else
  do:
    assign
      tt-fin-doc.shift-flag = 0
      .
  end.
END PROCEDURE.
ON CHOOSE OF B-calc IN FRAME Dialog-Frame
  DO:
    run ref/findclci.w (
      INPUT          parParentProc
      ,input          "":U
      ,INPUT          tt-fin-doc.doc-date
      ,INPUT          tt-fin-doc.curr-code
      ,INPUT          v-base-code
      ,INPUT          tt-fin-doc.contract-curr
      ,INPUT-OUTPUT   tt-fin-doc.sum-doc
      ,INPUT-OUTPUT   tt-fin-doc.exch-rate
      ,INPUT-OUTPUT   tt-fin-doc.exch-scale
      ,INPUT-OUTPUT   tt-fin-doc.sum-rubl
      ,INPUT-OUTPUT   tt-fin-doc.sum-base
      ,INPUT-OUTPUT   tt-fin-doc.base-rate
      ,INPUT-OUTPUT   tt-fin-doc.base-scale
      ,INPUT-OUTPUT   tt-fin-doc.sum-contr
      ,INPUT-OUTPUT   tt-fin-doc.contract-rate
      ,INPUT-OUTPUT   tt-fin-doc.contract-scale ) no-error.
    if error-status:error then return no-apply.
    assign
      f-rest-con-sum = tt-fin-doc.sum-contr - tt-fin-doc.con-sum-contr
      .
    display
      tt-fin-doc.sum-rubl
      when v-rubf
      tt-fin-doc.sum-doc
      tt-fin-doc.exch-rate
      when v-exchf
      tt-fin-doc.exch-scale
      when v-exchf
      tt-fin-doc.sum-base
      when v-basef
      tt-fin-doc.base-rate
      when v-baseratef
      tt-fin-doc.base-scale
      when v-baseratef
      tt-fin-doc.sum-contr
      when v-contractf
      tt-fin-doc.contract-rate
      when v-contractratef
      tt-fin-doc.contract-scale
      when v-contractratef
      f-rest-con-sum
      with frame Dialog-Frame .
  END.
ON CHOOSE OF B-receiver IN FRAME Dialog-Frame
  DO:
    define variable ref-list as character no-undo.
    define variable ref-rec  as recid     no-undo.
    define variable v-sum-vat-chr  as character no-undo .
    define variable v-each-vat-chr as character no-undo.
    define variable v-sum-vat      like ub.fin-doc-tax.sum-vat-line-doc no-undo .
    define buffer buf_clients for ub.clients.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run ref/cli-all.w ( parParentProc
  ,"b-sel"
  , tt-fin-doc.receiver-type
  , ?
  , ?
  , (if available X_receiver then recid(X_receiver) else ?)
  , ?
  , "without-obj":U
  , output ref-list) .
if ref-list = "" then
do:
  return no-apply.
end.
ref-rec = integer( ref-list ).
FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
if NOT (buf_clients.obj-type = 'орг':U
  or
  buf_clients.obj-type = 'чел':U ) then
do:
  message
    "Выберите контрагента типа" 'орг':U "или" 'чел':U
    view-as alert-box error .
  return no-apply.
end.
find first X_receiver no-lock where
  recid(X_receiver) = recid(buf_clients).
assign
  tt-fin-doc.receiver-type = buf_clients.obj-type
  tt-fin-doc.receiver-code = buf_clients.obj-code
  tt-fin-doc.receiver-name = buf_clients.obj-name
  .
display
  tt-fin-doc.receiver-type
  tt-fin-doc.receiver-code
  tt-fin-doc.receiver-name
  with frame Dialog-Frame.
CASE X_receiver.obj-type:   when 'чел':U then do:              find first X_receiver-person no-lock where               X_receiver-person.psn-code = X_receiver.obj-code .   end.   when 'орг':U then do:     find first X_receiver-firm no-lock where               X_receiver-firm.firm-code = X_receiver.obj-code .   end. END CASE. assign tt-fin-doc.receiver-sign1  = if X_receiver.obj-type = 'орг':U                              then X_receiver-firm.director                             else X_receiver.obj-name . display tt-fin-doc.receiver-sign1 with frame Dialog-Frame.
find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookId no-error .
if ub.CashBook.cli-code = tt-fin-doc.receiver-code and ub.CashBook.cli-type = tt-fin-doc.receiver-type then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  tt-fin-doc.cor-acc-value  = ub.CashBook.corrPko
  tt-fin-doc.naznach-plat   = ub.CashBook.RuleOsnPko
  .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в том числе НДС" .
  paramVne = "" .
end.
else
do:
  if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Vnecli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч.: без налога (НДС)" .
  paramVne = "vne" .
end.
else do:
  if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Avanscli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч. 22/122 (НДС)" .
  paramVne = "avans" .
end.
else do:
tt-fin-doc.naznach-plat = "".
tt-fin-doc.including = "@, в том числе НДС" .
paramVne = "" .
end.
end.
end.
run proc-create-default-tax in this-procedure .
run change-view in this-procedure(rs-view).
END.
ON LEAVE OF tt-fin-doc.receiver-code IN FRAME Dialog-Frame
  DO:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if   input frame Dialog-Frame tt-fin-doc.receiver-code <> 0 then
do:
  run check-receiver in this-procedure no-error.
  if error-status:error then
  do:
    return no-apply.
  end.
  CASE X_receiver.obj-type:   when 'чел':U then do:              find first X_receiver-person no-lock where               X_receiver-person.psn-code = X_receiver.obj-code .   end.   when 'орг':U then do:     find first X_receiver-firm no-lock where               X_receiver-firm.firm-code = X_receiver.obj-code .   end. END CASE. assign tt-fin-doc.receiver-sign1  = if X_receiver.obj-type = 'орг':U                              then X_receiver-firm.director                             else X_receiver.obj-name . display tt-fin-doc.receiver-sign1 with frame Dialog-Frame.
end.
END.
ON VALUE-CHANGED OF tt-fin-doc.receiver-type IN FRAME Dialog-Frame
  DO:
    assign
      tt-fin-doc.receiver-type.
    if   input frame Dialog-Frame tt-fin-doc.receiver-code <> 0 then
    do:
      run check-receiver in this-procedure no-error.
      if error-status:error then
      do:
        return no-apply.
      end.
      CASE X_receiver.obj-type:   when 'чел':U then do:              find first X_receiver-person no-lock where               X_receiver-person.psn-code = X_receiver.obj-code .   end.   when 'орг':U then do:     find first X_receiver-firm no-lock where               X_receiver-firm.firm-code = X_receiver.obj-code .   end. END CASE. assign tt-fin-doc.receiver-sign1  = if X_receiver.obj-type = 'орг':U                              then X_receiver-firm.director                             else X_receiver.obj-name . display tt-fin-doc.receiver-sign1 with frame Dialog-Frame.
    end.
  END.
PROCEDURE check-receiver :
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where
    buf_clients.obj-code = input frame Dialog-Frame tt-fin-doc.receiver-code
    and buf_clients.obj-type = input frame Dialog-Frame tt-fin-doc.receiver-type no-error.
  if not available buf_clients then
  do:
    if input frame Dialog-Frame tt-fin-doc.receiver-code <> ?  then
      message "Неправильный код или тип " 'ПОЛУЧАТЕЛЯ'.
    apply "entry" to tt-fin-doc.receiver-code in frame Dialog-Frame.
    return error.
  end.
  find first X_receiver no-lock where recid(X_receiver) = recid(buf_clients).
  assign
    tt-fin-doc.receiver-type = buf_clients.obj-type
    tt-fin-doc.receiver-code = buf_clients.obj-code
    tt-fin-doc.receiver-name = buf_clients.obj-name
    .
find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookId no-error .
if ub.CashBook.cli-code = tt-fin-doc.receiver-code and ub.CashBook.cli-type = tt-fin-doc.receiver-type then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  tt-fin-doc.cor-acc-value  = ub.CashBook.corrPko
  tt-fin-doc.naznach-plat   = ub.CashBook.RuleOsnPko
  .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
end.
else
do:
if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Vnecli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
end.
else do:
if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Avanscli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
end.
else do:
tt-fin-doc.naznach-plat = "".
end.
end.
end.
  display
    tt-fin-doc.receiver-type
    tt-fin-doc.receiver-code
    tt-fin-doc.receiver-name
    with frame Dialog-Frame.
END PROCEDURE.
on return of tt-fin-doc.payer-code in frame Dialog-Frame
  do:
    apply "leave" to tt-fin-doc.payer-code in frame Dialog-Frame.
    return no-apply.
  end.
ON LEAVE OF tt-fin-doc.payer-code IN FRAME Dialog-Frame
  DO:
define buffer buf_clients for ub.clients .
assign tt-fin-doc.payer-code .
if tt-fin-doc.payer-code = 0 then leave.
FIND FIRST buf_clients WHERE buf_clients.obj-code = tt-fin-doc.payer-code
and buf_clients.obj-type = tt-fin-doc.payer-type NO-LOCK .
if NOT available (buf_clients) then
do:
  message
    "Выберите контрагента типа" 'орг':U "или" 'чел':U
    view-as alert-box error .
  return no-apply.
end.
find first X_receiver no-lock where
  recid(X_receiver) = recid(buf_clients).
assign
  tt-fin-doc.receiver-type = buf_clients.obj-type
  tt-fin-doc.receiver-code = buf_clients.obj-code
  tt-fin-doc.receiver-name = buf_clients.obj-name
  .
display
  tt-fin-doc.receiver-type
  tt-fin-doc.receiver-code
  tt-fin-doc.receiver-name
  with frame Dialog-Frame.
CASE X_receiver.obj-type:   when 'чел':U then do:              find first X_receiver-person no-lock where               X_receiver-person.psn-code = X_receiver.obj-code .   end.   when 'орг':U then do:     find first X_receiver-firm no-lock where               X_receiver-firm.firm-code = X_receiver.obj-code .   end. END CASE. assign tt-fin-doc.receiver-sign1  = if X_receiver.obj-type = 'орг':U                              then X_receiver-firm.director                             else X_receiver.obj-name . display tt-fin-doc.receiver-sign1 with frame Dialog-Frame.
find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookId no-error .
if ub.CashBook.cli-code = tt-fin-doc.receiver-code and ub.CashBook.cli-type = tt-fin-doc.receiver-type then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  tt-fin-doc.cor-acc-value  = ub.CashBook.corrPko
  tt-fin-doc.naznach-plat   = ub.CashBook.RuleOsnPko
  .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в том числе НДС" .
  paramVne = "" .
end.
else
do:
  if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Vnecli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoVne"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч.: без налога (НДС)" .
  paramVne = "vne" .
end.
else do:
  if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Avanscli", tt-fin-doc.cashbookId) then do:
assign
  tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct
  .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "corrPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.cor-acc-value = ub.CashBookRule.RuleValue .
find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
  and ub.CashBookRule.Obj-type   = 'всем':U
  and ub.CashBookRule.Obj-code   = 0
  and ub.CashBookRule.Code       = "RuleOsnPkoAvans"
  no-error.
if available (ub.CashBookRule) then tt-fin-doc.naznach-plat = ub.CashBookRule.RuleValue .
find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = tt-fin-doc.cor-acc-value
  and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc
  then
do :
  assign
    f-cor-acc-descr    = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc.fin-code
    .
end.
find first X_fin-code-cor-acc1 no-lock where X_fin-code-cor-acc1.code-value = tt-fin-doc.cor-acc1-value
  and X_fin-code-cor-acc1.host-code = tt-fin-doc.host-code
  and X_fin-code-cor-acc1.status_ = integer('0':U)
  no-error .
if available X_fin-code-cor-acc1
  then
do :
  assign
    f-cor-acc1-descr   = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc = X_fin-code-cor-acc1.fin-code
    .
end.
assign
  tt-fin-doc.including = "@, в т.ч. 22/122 (НДС)" .
  paramVne = "avans" .
end.
else do:
tt-fin-doc.naznach-plat = "".
tt-fin-doc.including = "@, в том числе НДС" .
paramVne = "" .
end.
end.
end.
run proc-create-default-tax in this-procedure .
run change-view in this-procedure(rs-view).
END.
ON LEAVE OF tt-fin-doc.an-uchet-value IN FRAME Dialog-Frame
  DO:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  tt-fin-doc.an-uchet-value.
FIND X_fin-code-an-uchet WHERE
  X_fin-code-an-uchet.code-value  = tt-fin-doc.an-uchet-value
  AND     X_fin-code-an-uchet.host-code  = tt-fin-doc.host-code
  AND  X_fin-code-an-uchet.status_ = integer('0':U)
  NO-LOCK NO-error.
if not available X_fin-code-an-uchet
  then
do:
  assign
    tt-fin-doc.an-uchet-value = chr(63)
    f-an-uchet-descr          = "":U
    .
  display
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    with frame Dialog-Frame.
  .
end.
else
do:
  assign
    f-an-uchet-descr = X_fin-code-an-uchet.descr
    .
  display
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    with frame Dialog-Frame.
  .
end.
END.
ON CHOOSE OF B-contract-view IN FRAME Dialog-Frame
  DO:
    define variable g-log as logical no-undo.
    define variable ri    as recid   no-undo .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not avail X_contract then return no-apply.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_lookup':U
    ,input  'firm':U
    ,input  tt-fin-doc.host-code
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
ri = recid( X_contract ).
run str/sh-contr.p ( input parParentProc,  input ri) no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-cashbook IN FRAME Dialog-Frame
  DO:
    define variable v-cb-brw as class ibs.th.ref.cashbookbrw no-undo .
    v-cb-brw = new ibs.th.ref.cashbookbrw ( 'ВЫБОР':U, parparentproc ).
    wait-for  v-cb-brw:ShowDialog() .
    if v-cb-brw:out-list-id > ""
      then
    do :
      find first ub.cashbook no-lock where ub.cashbook.id = int64(v-cb-brw:out-list-id) .
      tt-fin-doc.cashbookId = ub.cashbook.id .
      f-cashbook = ub.CashBook.CashBookName .
      display
        f-cashbook
        with frame Dialog-Frame .
      IF LOOKUP("update_prc-doc-code-mask", THIS-PROCEDURE:INTERNAL-ENTRIES) >  0
        THEN
        run update_prc-doc-code-mask (no).
      run check-obj in this-procedure (   input tt-fin-doc.obj-type
        ,input tt-fin-doc.obj-code
        )
        no-error.
      find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = (if tt-fin-doc.fin-doc-type eq 'рко':U then ub.cashbook.corrRko else ub.cashbook.corrPko)
        and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
        and X_fin-code-cor-acc.status_ = integer('0':U)
        no-error .
      if available X_fin-code-cor-acc
        then
      do :
        assign
          tt-fin-doc.cor-acc-value = X_fin-code-cor-acc.code-value
          f-cor-acc-descr          = X_fin-code-cor-acc.descr
          tt-fin-doc.cor-acc       = X_fin-code-cor-acc.fin-code
          .
      end.
      else
      do:
        if ub.cashbook.corrRko = "" then
        do:
          for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
            and ub.fin-code-cor-acc.host-code = p-curr-host-code :
            tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
            tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
          end.
        end.
      end.
      if ub.CashBook.OsnAcct <> "" then
      do:
        find first X_fin-code-cor-acc no-lock where X_fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
          and X_fin-code-cor-acc.host-code = tt-fin-doc.host-code
          and X_fin-code-cor-acc.status_ = integer('0':U)
          no-error .
        if available X_fin-code-cor-acc
          then
        do :
          assign
            tt-fin-doc.cor-acc1-value = X_fin-code-cor-acc.code-value
            f-cor-acc1-descr          = X_fin-code-cor-acc.descr
            tt-fin-doc.cor-acc1       = X_fin-code-cor-acc.fin-code
            .
        end.
        else
        do:
          assign
            tt-fin-doc.cor-acc1-value = ""
            f-cor-acc1-descr          = ""
            tt-fin-doc.cor-acc1       = ?
            .
        end.
      end.
    end.
    display
      tt-fin-doc.cor-acc-value
      f-cor-acc-descr
      tt-fin-doc.cor-acc
      tt-fin-doc.cor-acc1-value
      f-cor-acc1-descr
      tt-fin-doc.cor-acc1
      with frame Dialog-Frame .
  END.
ON CHOOSE OF B-an-uchet IN FRAME Dialog-Frame
  DO:
    define variable rid-list as character no-undo.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
rid-list = "":U .
run ref/fwcode-3.w (
  parParentProc
  ,"b-sel"
  ,'фирма':U
  ,input (if available X_fin-code-an-uchet then recid(X_fin-code-an-uchet) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then
do:
  FIND FIRST X_fin-code-an-uchet WHERE
    recid( X_fin-code-an-uchet ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-an-uchet.status_ <> integer('0':U) then
  do:
    message
      "Нельзя выбрать удаленный код аналитического учета"
      view-as alert-box error .
    return no-apply.
  end.
  assign
    tt-fin-doc.an-uchet-value = X_fin-code-an-uchet.code-value
    f-an-uchet-descr          = X_fin-code-an-uchet.descr
    tt-fin-doc.an-uchet-code  = X_fin-code-an-uchet.fin-code
    .
  display
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-cel-nazn IN FRAME Dialog-Frame
  DO:
    define variable rid-list as character no-undo.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
rid-list = "":U .
run ref/fwcode-2.w (
  parParentProc
  ,"b-sel"
  ,'фирма':U
  ,input (if available X_fin-code-cel-nazn then recid(X_fin-code-cel-nazn) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then
do:
  FIND FIRST X_fin-code-cel-nazn WHERE
    recid( X_fin-code-cel-nazn ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-cel-nazn.status_ <> integer('0':U) then
  do:
    message
      "Нельзя выбрать удаленный код целевого назначения "
      view-as alert-box error .
    return no-apply.
  end.
  assign
    tt-fin-doc.cel-nazn-value = X_fin-code-cel-nazn.code-value
    f-cel-nazn-descr          = X_fin-code-cel-nazn.descr
    tt-fin-doc.cel-nazn-code  = X_fin-code-cel-nazn.fin-code
    .
  display
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-cor-acc IN FRAME Dialog-Frame
  DO:
    define variable rid-list as character no-undo.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
rid-list = "":U .
run ref/fwcode-1.w (
  parParentProc
  ,"b-sel"
  ,'фирма':U
  ,input (if available X_fin-code-cor-acc then recid(X_fin-code-cor-acc) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then
do:
  FIND FIRST X_fin-code-cor-acc WHERE
    recid( X_fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-cor-acc.status_ <> integer('0':U) then
  do:
    message
      "Нельзя выбрать удаленный корр счет"
      view-as alert-box error .
    return no-apply.
  end.
  assign
    tt-fin-doc.cor-acc-value = X_fin-code-cor-acc.code-value
    f-cor-acc-descr          = X_fin-code-cor-acc.descr
    tt-fin-doc.cor-acc       = X_fin-code-cor-acc.fin-code
    .
  display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-cor-acc1 IN FRAME Dialog-Frame
  DO:
    define variable rid-list as character no-undo.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
rid-list = "":U .
run ref/fwcode-1.w (
  parParentProc
  ,"b-sel"
  ,'фирма':U
  ,input (if available X_fin-code-cor-acc1 then recid(X_fin-code-cor-acc1) else ?)
  ,input p-curr-host-code
  ,output rid-list ).
if rid-list <> "":U then
do:
  FIND FIRST X_fin-code-cor-acc1 WHERE
    recid( X_fin-code-cor-acc1 ) = integer(entry(1, rid-list)) NO-LOCK .
  if X_fin-code-cor-acc1.status_ <> integer('0':U) then
  do:
    message
      "Нельзя выбрать удаленный корр счет"
      view-as alert-box error .
    return no-apply.
  end.
  assign
    tt-fin-doc.cor-acc1-value = X_fin-code-cor-acc1.code-value
    f-cor-acc1-descr          = X_fin-code-cor-acc1.descr
    tt-fin-doc.cor-acc1       = X_fin-code-cor-acc1.fin-code
    .
  display
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    with frame Dialog-Frame .
end.
END.
ON LEAVE OF tt-fin-doc.cor-acc1-value IN FRAME Dialog-Frame
  DO:
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  tt-fin-doc.cor-acc1-value.
FIND X_fin-code-cor-acc1 WHERE
  X_fin-code-cor-acc1.code-value  = tt-fin-doc.cor-acc1-value
  AND      X_fin-code-cor-acc1.host-code  = tt-fin-doc.host-code
  AND X_fin-code-cor-acc1.status_ = integer('0':U)
  NO-LOCK NO-error.
if not available X_fin-code-cor-acc1
  then
do:
  assign
    tt-fin-doc.cor-acc1-value = chr(63)
    f-cor-acc1-descr          = "":U
    .
  display
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    with frame Dialog-Frame.
  .
end.
else
do:
  assign
    f-cor-acc1-descr = X_fin-code-cor-acc1.descr
    .
  display
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    with frame Dialog-Frame.
  .
end.
END.
ON CHOOSE OF B-currency IN FRAME Dialog-Frame
  DO:
    define variable rr          as recid no-undo.
    define variable v-curr-code like ub.fin-doc.curr-code no-undo.
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  v-curr-code = tt-fin-doc.curr-code
  tt-fin-doc.curr-code.
if available X_currency then rr = recid(X_currency).
else rr = ?.
run ref/currency.w (parparentproc, "b-sel", input-output rr ).
if rr <> ? then
do:
  FIND FIRST X_currency WHERE
    recid( X_currency ) = rr NO-LOCK .
  assign
    tt-fin-doc.curr-code = X_currency.curr-code
    f-curr-abbr          = X_currency.curr-abbr
    .
  DISPLAY
    tt-fin-doc.curr-code
    f-curr-abbr
    with frame Dialog-Frame .
end.
if tt-fin-doc.curr-code <> v-curr-code then
do:
  run recalc in this-procedure("curr-code":U) no-error.
  if error-status:error then
  do:
    assign
      tt-fin-doc.curr-code = v-curr-code
      .
    display tt-fin-doc.curr-code
      with frame Dialog-Frame.
  end.
  run hide-view-currency in this-procedure .
end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
  DO:
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
find tt0-fin-doc-tax no-lock where
  tt0-fin-doc-tax.host-code = tt-fin-doc.host-code
  AND tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code no-error .
if not available tt0-fin-doc-tax
  or
  tt0-fin-doc-tax.sum-line-doc = 0
  then
do:
  run proc-create-default-tax  in this-procedure .
  run proc-update-sum-vat-chr in this-procedure (input-output v-start).
end.
run proc-save in this-procedure (yes)  no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
  DO:
    define variable v-rid-list as character no-undo.
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run ref/fincdocs.w
  (
  input parParentProc
  ,input p-curr-host-code
  ,input "":U
  ,input "one":U
  ,input locked_fin-doc.host-code
  ,input ''
  ,input 0
  ,input locked_fin-doc.fin-doc-code
  ,input-output v-rid-list
  )
  .
END.
ON CHOOSE OF B-payer-view IN FRAME Dialog-Frame
  DO:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if available X_payer
  or tt-fin-doc.fin-doc-type = 'рко':U
  or tt-fin-doc.fin-doc-type = 'рпп':U
  or tt-fin-doc.fin-doc-type = 'апр':U
  or p-mode <> 'ДОБАВЛЕНИЕ':U
  then
  run ref/showcli.p
    (input parParentProc
    ,input tt-fin-doc.payer-type
    ,input tt-fin-doc.payer-code
    ).
END.
ON CHOOSE OF B-receiver-view IN FRAME Dialog-Frame
  DO:
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if available X_receiver
  or tt-fin-doc.fin-doc-type = 'пко':U
  or tt-fin-doc.fin-doc-type = 'ппп':U
  or tt-fin-doc.fin-doc-type = 'апп':U
  or p-mode <> 'ДОБАВЛЕНИЕ':U
  then
  run ref/showcli.p
    (input parParentProc
    ,input tt-fin-doc.receiver-type
    ,input tt-fin-doc.receiver-code
    ).
END.
ON CHOOSE OF B-tax IN FRAME Dialog-Frame
  DO:
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
find first tt0-fin-doc-tax no-lock where
  tt0-fin-doc-tax.host-code = tt-fin-doc.host-code
  AND tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code no-error .
if not available tt0-fin-doc-tax
  or
  tt0-fin-doc-tax.sum-line-doc = 0
  then
do:
  run proc-create-default-tax  in this-procedure .
end.
assign
  tt-fin-doc.obj-code
  tt-fin-doc.obj-type = (if tt-fin-doc.obj-code = 0 then "":U else tt-fin-doc.obj-type)
  .
run ref/fndocti.w (
  INPUT parParentProc
  ,input p-curr-host-code
  ,input (if tt-fin-doc.status_ = 'новый':U then p-mode else 'ПРОСМОТР':U)
  ,input tt-fin-doc.host-code
  ,input tt-fin-doc.fin-doc-code
  ,input tt-fin-doc.fin-doc-type
  ,input tt-fin-doc.fin-ext-doc-type
  ,input tt-fin-doc.trn-doc-code
  ,input tt-fin-doc.contract-code
  ,input tt-fin-doc.sum-doc
  ,input tt-fin-doc.curr-code
  ,input tt-fin-doc.base-rate
  ,input tt-fin-doc.base-scale
  ,input tt-fin-doc.exch-rate
  ,input tt-fin-doc.exch-scale
  ,input tt-fin-doc.obj-type
  ,input tt-fin-doc.obj-code
  ,input-output table tt0-fin-doc-tax
  ,input 0
  ).
run proc-update-sum-vat-chr in this-procedure (input-output v-start).
END.
ON LEAVE OF tt-fin-doc.cel-nazn-value IN FRAME Dialog-Frame
  DO:
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  tt-fin-doc.cel-nazn-value.
FIND X_fin-code-cel-nazn WHERE
  X_fin-code-cel-nazn.code-value  = tt-fin-doc.cel-nazn-value
  AND     X_fin-code-cel-nazn.host-code  = tt-fin-doc.host-code
  AND X_fin-code-cel-nazn.status_ = integer('0':U)
  NO-LOCK NO-error.
if not available X_fin-code-cel-nazn
  then
do:
  assign
    tt-fin-doc.cel-nazn-value = chr(63)
    f-cel-nazn-descr          = "":U
    .
  display
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame Dialog-Frame.
  .
end.
else
do:
  assign
    f-cel-nazn-descr          = X_fin-code-cel-nazn.descr
    tt-fin-doc.cel-nazn-value = X_fin-code-cel-nazn.code-value
    .
  display
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame Dialog-Frame.
  .
end.
END.
ON LEAVE OF tt-fin-doc.cor-acc-value IN FRAME Dialog-Frame
  DO:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  tt-fin-doc.cor-acc-value.
FIND X_fin-code-cor-acc WHERE
  X_fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
  AND X_fin-code-cor-acc.host-code  = tt-fin-doc.host-code
  AND  X_fin-code-cor-acc.status_ = integer('0':U)
  NO-LOCK NO-error.
if not available X_fin-code-cor-acc
  then
do:
  assign
    tt-fin-doc.cor-acc-value = chr(63)
    f-cor-acc-descr          = "":U
    .
  display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    with frame Dialog-Frame.
  .
end.
else
do:
  assign
    f-cor-acc-descr = X_fin-code-cor-acc.descr
    .
  display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    with frame Dialog-Frame.
  .
end.
END.
ON LEAVE OF tt-fin-doc.curr-code IN FRAME Dialog-Frame
  DO:
    define variable v-curr-code like ub.fin-doc.curr-code no-undo.
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  v-curr-code = tt-fin-doc.curr-code
  tt-fin-doc.curr-code.
FIND FIRST X_currency WHERE
  X_currency.curr-code = tt-fin-doc.curr-code NO-LOCK NO-error.
if not available X_currency then
do:
  message
    "Нет валюты с кодом"   tt-fin-doc.curr-code
    view-as alert-box error.
  assign
    tt-fin-doc.curr-code = v-curr-code.
  display
    tt-fin-doc.curr-code
    with frame Dialog-Frame.
  .
end.
else
do:
  assign
    f-curr-abbr = X_currency.curr-abbr
    .
  display
    f-curr-abbr
    tt-fin-doc.curr-code
    with frame Dialog-Frame.
  .
  if tt-fin-doc.curr-code <> v-curr-code then
  do:
    run recalc in this-procedure("curr-code":U) no-error.
    if error-status:error then
    do:
      assign
        tt-fin-doc.curr-code = v-curr-code
        .
      display tt-fin-doc.curr-code
        with frame Dialog-Frame.
    end.
    run hide-view-currency in this-procedure .
  end.
end.
END.
ON LEAVE OF tt-fin-doc.doc-date IN FRAME Dialog-Frame
  DO:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable v-doc-date as date    no-undo.
define variable vlog       as logical no-undo .
assign
  v-doc-date = tt-fin-doc.doc-date
  tt-fin-doc.doc-date
  .
if tt-fin-doc.doc-date <> v-doc-date
  and (input frame Dialog-Frame   tt-fin-doc.sum-doc <> 0
  or tt-fin-doc.sum-doc <> 0)
  then
do:
  message
    "Пересчитать суммы документа в соответствии с курсами на новую дату?"
    view-as alert-box QUESTION buttons YEs-NO update vlog.
  if  vlog then
  do:
    run recalc in this-procedure ("doc-date":U) no-error.
    if error-status:error then
    do:
      assign
        tt-fin-doc.doc-date = v-doc-date
        .
      display tt-fin-doc.doc-date
        with frame Dialog-Frame.
    end.
  end.
end.
END.
ON VALUE-CHANGED OF RS-view IN FRAME Dialog-Frame
  DO:
    assign
      RS-view
      .
    assign
      v-not-uf-set = no
      .
    run change-view in this-procedure(rs-view).
  END.
ON LEAVE OF tt-fin-doc.sum-doc IN FRAME Dialog-Frame
  DO:
    define variable v-sum-doc like ub.fin-doc.sum-doc no-undo .
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  v-sum-doc = tt-fin-doc.sum-doc
  tt-fin-doc.sum-doc
  .
if v-sum-doc <> tt-fin-doc.sum-doc then
  run recalc in this-procedure("sum-doc").
END.
PROCEDURE check-sums-rate :
  define variable v-exch-rate  like ub.fin-doc.sum-doc no-undo .
  define variable v-exch-scale like ub.fin-doc.sum-doc no-undo .
END PROCEDURE.
PROCEDURE disable-enable :
  define input parameter p-main-widget as character no-undo.
  define input parameter p-main-curr as character no-undo .
  disable
    tt-fin-doc.sum-doc
    tt-fin-doc.sum-rubl
    tt-fin-doc.sum-base
    tt-fin-doc.base-rate
    tt-fin-doc.base-scale
    tt-fin-doc.exch-rate
    tt-fin-doc.exch-scale
    tt-fin-doc.sum-contr
    tt-fin-doc.contract-rate
    tt-fin-doc.contract-scale
    with frame Dialog-Frame .
  assign
    v-main-sum  = if p-main-widget <> "":U then p-main-widget else v-main-sum
    v-main-curr = if p-main-curr <> "":U then p-main-curr else v-main-curr
    .
  if v-limit-access > 0 then
  do:
    display
      tt-fin-doc.sum-rubl
      when v-rubf
      tt-fin-doc.sum-base
      when v-basef
      tt-fin-doc.exch-rate
      when v-exchf
      tt-fin-doc.exch-scale
      when v-exchf
      tt-fin-doc.base-rate
      when v-basef
      tt-fin-doc.base-scale
      when v-basef
      tt-fin-doc.sum-contr
      when v-contractf
      tt-fin-doc.contract-rate
      when v-contractratef
      tt-fin-doc.contract-scale
      when v-contractratef
      with frame Dialog-Frame.
    return.
  end.
  CASE p-main-widget:
    when "sum-doc" then
      do:
        enable
          tt-fin-doc.sum-doc
          with frame Dialog-Frame.
        APPLY "ENTRY" to tt-fin-doc.sum-doc.
      end.
  END CASE.
  display
    tt-fin-doc.sum-rubl
    when v-rubf
    tt-fin-doc.sum-base
    when v-basef
    tt-fin-doc.exch-rate
    when v-exchf
    tt-fin-doc.exch-scale
    when v-exchf
    tt-fin-doc.base-rate
    when v-basef
    tt-fin-doc.base-scale
    when v-basef
    tt-fin-doc.sum-contr
    when v-contractf
    tt-fin-doc.contract-rate
    when v-contractratef
    tt-fin-doc.contract-scale
    when v-contractratef
    with frame Dialog-Frame.
  CASE rs-view:
    when "full":u then
      do:
        assign
          v-tab-order = "b-exit,b-quit,b-tax,b-print,b-hist,b-help," +  "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view,str-podr-type,str-podr-code,str-podr-name," +                             v-an-uchet-tab-order +  v-sum-curr-tab-order +                             "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat," +                              "PS,payer-sign1,receiver-sign1"
          .
      end.
    when "brief":u then
      do:
        assign
          v-tab-order = "b-exit,b-quit,b-tax,b-print,b-hist,b-help," +                            "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view," +                            v-sum-curr-tab-order +                            "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat," +                            "PS,payer-sign1,receiver-sign1"
          .
      end.
    when "contract":u then
      do:
        assign
          v-tab-order = "b-exit,b-quit,b-tax,b-print,b-hist,b-help," +                               "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view," +                                v-contract-tab-order + v-sum-curr-tab-order +                                 "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat," +                                 "PS,payer-sign1,receiver-sign1"
          .
      end.
  END CASE.
END PROCEDURE.
define new global shared variable g#lib-farh as handle no-undo .
PROCEDURE fill-tables :
  define buffer buf_fin-doc-tax  for ub.fin-doc-tax.
  define buffer buf_fin-doc-attr for ub.fin-doc-attr.
  define buffer buf_fin-ob-tax   for ub.fin-ob-tax.
  define buffer buf_fin-connect  for ub.fin-connect.
  define buffer buf_fin-ob       for ub.fin-ob.
  define buffer buf_payment      for ub.payment.
  if p-mode = 'ДОБАВЛЕНИЕ':U
    AND p-ob-doc-code <> "" then
  do:
    for each buf_fin-ob-tax no-lock where
      buf_fin-ob-tax.host-code = tt-fin-doc.fin-doc-code
      AND buf_fin-ob-tax.doc-code = p-ob-doc-code:
      create tt0-fin-doc-tax.
      buffer-copy buf_fin-ob-tax to tt0-fin-doc-tax.
    end.
    return.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U
    and v-copy-mode = yes then
  do:
    for each buf_fin-doc-tax no-lock where
      buf_fin-doc-tax.host-code = locked_fin-doc.host-code
      AND buf_fin-doc-tax.fin-doc-code = locked_fin-doc.fin-doc-code
      :
      create tt0-fin-doc-tax.
      buffer-copy buf_fin-doc-tax except fin-doc-code to tt0-fin-doc-tax
        assign
        tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
        .
    end.
    for each buf_payment no-lock where
      buf_payment.source-type = 'платеж':U
      AND buf_payment.source-ref = string(locked_fin-doc.fin-doc-code)
      :
      create tt0-payment.
      buffer-copy buf_payment except source-ref to tt0-payment
        assign
        tt0-payment.source-ref = string(tt-fin-doc.fin-doc-code)
        .
    end.
    for each buf_fin-doc-attr no-lock where
      buf_fin-doc-attr.host-code = locked_fin-doc.host-code
      AND buf_fin-doc-attr.fin-doc-code = locked_fin-doc.fin-doc-code
      :
      create tt0-fin-doc-attr.
      buffer-copy buf_fin-doc-attr to tt0-fin-doc-attr
        assign
        tt0-fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code
        .
    end.
  end.
  else
  do:
    for each buf_fin-doc-tax no-lock where
      buf_fin-doc-tax.host-code = tt-fin-doc.host-code
      AND buf_fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
      :
      create tt0-fin-doc-tax.
      buffer-copy buf_fin-doc-tax to tt0-fin-doc-tax.
    end.
    for each buf_payment no-lock where
      buf_payment.source-type = 'платеж':U
      AND buf_payment.source-ref = string(tt-fin-doc.fin-doc-code)
      :
      create tt0-payment.
      buffer-copy buf_payment to tt0-payment.
    end.
    for each buf_fin-doc-attr no-lock where
      buf_fin-doc-attr.host-code = tt-fin-doc.host-code
      AND buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code
      :
      create tt0-fin-doc-attr.
      buffer-copy buf_fin-doc-attr to tt0-fin-doc-attr.
    end.
    for each tt0-fin-doc-attr no-lock where
      tt0-fin-doc-attr.host-code = tt-fin-doc.host-code
      AND tt0-fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code
      :
    end.
  end.
if (valid-handle(g#lib-farh) <> true) then do:   run str/lib-farh.p persistent no-error .   if error-status :error or (valid-handle(g#lib-farh) <> true) then do:     message       "Error starting lib-farh.p" skip       g#lib-farh skip       g#lib-farh :type skip       g#lib-farh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-farh_fautoobj in g#lib-farh
(input tt-fin-doc.host-code
,input tt-fin-doc.fin-doc-code
,output v-is-auto-obj
)
.
  if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Vnecli", tt-fin-doc.cashbookId) then paramVne = "vne" .
  else if getCliKassa(tt-fin-doc.receiver-type, tt-fin-doc.receiver-code, "Avanscli", tt-fin-doc.cashbookId) then paramVne = "avans" .
  else paramVne = "" .
  run proc-update-sum-vat-chr in this-procedure (input-output v-start).
END PROCEDURE.
PROCEDURE hide-view-currency :
  define buffer buf_currency for ub.currency.
  assign
    v-rubf          = no
    v-exchf         = no
    v-basef         = no
    v-baseratef     = no
    v-contractf     = no
    v-contractratef = no
    .
  hide
    tt-fin-doc.sum-rubl in frame Dialog-Frame
    tt-fin-doc.exch-rate
    tt-fin-doc.exch-scale
    tt-fin-doc.sum-base
    tt-fin-doc.base-rate
    tt-fin-doc.base-scale
    tt-fin-doc.sum-contr
    tt-fin-doc.contract-rate
    tt-fin-doc.contract-scale
    in frame Dialog-Frame .
  if tt-fin-doc.curr-code <> 0 then
  do:
    if tt-fin-doc.curr-code:visible then
      display
        tt-fin-doc.exch-rate
        tt-fin-doc.exch-scale
        tt-fin-doc.sum-rubl
        with frame Dialog-Frame.
    assign
      v-rubf  = yes
      v-exchf = yes
      .
  end.
  if v-base-code <> tt-fin-doc.curr-code
    and v-base-code <> 0
    then
  do:
    find first buf_currency no-lock where
      buf_currency.curr-code = v-base-code .
    assign
      tt-fin-doc.sum-base:label = "Б.в.("  + buf_currency.curr-abbr + ")":U
      .
    if tt-fin-doc.curr-code:visible then
      display
        tt-fin-doc.base-rate
        tt-fin-doc.base-scale
        tt-fin-doc.sum-base
        with frame Dialog-Frame.
    assign
      v-basef     = yes
      v-baseratef = yes
      .
  end.
  if tt-fin-doc.contract-code  <> 0 and
    (tt-fin-doc.contract-curr <> 0
    and tt-fin-doc.contract-curr <> tt-fin-doc.curr-code
    and tt-fin-doc.contract-curr <> v-base-code
    )
    then
  do:
    find first buf_currency no-lock where
      buf_currency.curr-code = tt-fin-doc.contract-curr .
    assign
      tt-fin-doc.sum-contr:label = "Вал.дог.("  + buf_currency.curr-abbr + ")":U
      .
    if tt-fin-doc.curr-code:visible then
      display
        tt-fin-doc.sum-contr
        tt-fin-doc.contract-rate
        tt-fin-doc.contract-scale
        with frame Dialog-Frame.
    assign
      v-contractf     = yes
      v-contractratef = yes
      .
  end.
  assign
    v-sum-curr-tab-order = v-sum-doc-tab-order
    .
  run disable-enable in this-procedure (v-main-sum, v-main-curr).
END PROCEDURE.
PROCEDURE recalc :
  define input parameter p-main-widget as character no-undo.
  define variable v-curr-abbr      like ub.currency.curr-abbr no-undo.
  define variable v-contract-rate  like ub.fin-doc.exch-rate no-undo.
  define variable v-contract-scale like ub.fin-doc.exch-scale no-undo.
  if p-main-widget = "curr-code":u then
  do:
    assign
      frame Dialog-Frame
      tt-fin-doc.sum-doc
      .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  tt-fin-doc.host-code
  ,input  tt-fin-doc.doc-date
  ,output tt-fin-doc.base-rate
  ,output tt-fin-doc.base-scale
  )  .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  tt-fin-doc.curr-code
  ,input  tt-fin-doc.doc-date
  ,output tt-fin-doc.exch-rate
  ,output tt-fin-doc.exch-scale
  ,output v-curr-abbr
  )  .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  tt-fin-doc.contract-curr
  ,input  tt-fin-doc.doc-date
  ,output tt-fin-doc.contract-rate
  ,output tt-fin-doc.contract-scale
  ,output v-curr-abbr
  )  .
    if tt-fin-doc.curr-code <> 0
      or tt-fin-doc.curr-code <> v-base-code
      or tt-fin-doc.curr-code <> tt-fin-doc.contract-curr
      then
    do:
      if tt-fin-doc.curr-code <> 0 then
        display
          tt-fin-doc.exch-rate
          tt-fin-doc.exch-scale
          with frame Dialog-Frame.
      assign
        p-main-widget = "sum-doc":U.
    end.
  end.
  if p-main-widget  = "doc-date":U then
  do:
    assign
      frame Dialog-Frame
      tt-fin-doc.sum-doc
      .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  tt-fin-doc.host-code
  ,input  tt-fin-doc.doc-date
  ,output tt-fin-doc.base-rate
  ,output tt-fin-doc.base-scale
  )  .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  tt-fin-doc.curr-code
  ,input  tt-fin-doc.doc-date
  ,output tt-fin-doc.exch-rate
  ,output tt-fin-doc.exch-scale
  ,output v-curr-abbr
  )  .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  tt-fin-doc.contract-curr
  ,input  tt-fin-doc.doc-date
  ,output tt-fin-doc.contract-rate
  ,output tt-fin-doc.contract-scale
  ,output v-curr-abbr
  )  .
    if tt-fin-doc.base-rate:visible in frame Dialog-Frame then
    do:
      display
        tt-fin-doc.base-rate
        tt-fin-doc.base-scale
        with frame Dialog-Frame.
      assign
        p-main-widget = "sum-doc":U.
    end.
    if tt-fin-doc.exch-rate:visible in frame Dialog-Frame then
    do:
      display
        tt-fin-doc.exch-rate
        tt-fin-doc.exch-scale
        with frame Dialog-Frame.
      assign
        p-main-widget = "sum-doc":U.
    end.
    if tt-fin-doc.contract-rate:visible in frame Dialog-Frame then
    do:
      display
        tt-fin-doc.contract-rate
        tt-fin-doc.contract-scale
        with frame Dialog-Frame.
      assign
        p-main-widget = "sum-doc":U.
    end.
  end.
  CASE p-main-widget:
    when "sum-doc" then
      do:
        assign
          frame Dialog-Frame
          tt-fin-doc.exch-rate
          tt-fin-doc.exch-scale
          tt-fin-doc.sum-doc
          .
        CASE tt-fin-doc.curr-code:
          when 0 then
            do:
              assign
                tt-fin-doc.sum-rubl = tt-fin-doc.sum-doc
                tt-fin-doc.sum-base = tt-fin-doc.sum-doc / tt-fin-doc.base-rate * tt-fin-doc.base-scale
                tt-fin-doc.sum-contr = (if tt-fin-doc.contract-curr = 0                                                       then tt-fin-doc.sum-rubl                                                       else tt-fin-doc.sum-rubl / (tt-fin-doc.contract-rate / tt-fin-doc.contract-scale)                                                     )
                .
            end.
          when v-base-code then
            do:
              assign
                tt-fin-doc.sum-rubl = tt-fin-doc.sum-doc * tt-fin-doc.exch-rate / tt-fin-doc.exch-scale
                tt-fin-doc.sum-base = tt-fin-doc.sum-rubl / tt-fin-doc.base-rate * tt-fin-doc.base-scale
                tt-fin-doc.sum-contr = (if tt-fin-doc.contract-curr = 0                                                       then tt-fin-doc.sum-rubl                                                       else tt-fin-doc.sum-rubl / (tt-fin-doc.contract-rate / tt-fin-doc.contract-scale)                                                     )
                .
            end.
          otherwise
          do:
            assign
              tt-fin-doc.sum-rubl = tt-fin-doc.sum-doc * tt-fin-doc.exch-rate / tt-fin-doc.exch-scale
              tt-fin-doc.sum-base = tt-fin-doc.sum-rubl / tt-fin-doc.base-rate * tt-fin-doc.base-scale
              tt-fin-doc.sum-contr = (if tt-fin-doc.contract-curr = 0                                                       then tt-fin-doc.sum-rubl                                                       else tt-fin-doc.sum-rubl / (tt-fin-doc.contract-rate / tt-fin-doc.contract-scale)                                                     )
              .
          end.
        END CASE.
      end.
  END CASE.
  assign
    f-rest-con-sum = tt-fin-doc.sum-contr - tt-fin-doc.con-sum-contr
    .
  display
    f-rest-con-sum
    with frame Dialog-Frame.
  if tt-fin-doc.sum-doc:visible in frame Dialog-Frame then
    display
      tt-fin-doc.sum-doc
      tt-fin-doc.curr-code
      with frame Dialog-Frame.
  if tt-fin-doc.sum-rubl:visible in frame Dialog-Frame then
    display
      tt-fin-doc.sum-rubl
      tt-fin-doc.exch-rate
      tt-fin-doc.exch-scale
      with frame Dialog-Frame.
  if tt-fin-doc.sum-base:visible in frame Dialog-Frame then
    display
      tt-fin-doc.sum-base
      tt-fin-doc.base-rate
      tt-fin-doc.base-scale
      with frame Dialog-Frame.
  if tt-fin-doc.sum-contr:visible in frame Dialog-Frame then
    display
      tt-fin-doc.sum-contr
      tt-fin-doc.contract-rate
      tt-fin-doc.contract-scale
      with frame Dialog-Frame.
  if not v-first-start then
    run proc-update-sum-vat-chr in this-procedure (input-output v-start).
END PROCEDURE.
procedure proc-create-default-tax :
  do
    on error undo, return error
    :
    If p-mode = 'ДОБАВЛЕНИЕ':U then
    do:
      if p-ob-doc-code = "" then
      do:
        find tt0-fin-doc-tax where
          tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
          AND tt0-fin-doc-tax.host-code = tt-fin-doc.host-code no-error .
        if not avail tt0-fin-doc-tax
          and not AMBIGUOUS tt0-fin-doc-tax
          then
        do:
          create tt0-fin-doc-tax.
        end.
        if AMBIGUOUS tt0-fin-doc-tax then return.
        assign
          tt0-fin-doc-tax.fin-doc-code     = tt-fin-doc.fin-doc-code
          tt0-fin-doc-tax.host-code        = tt-fin-doc.host-code
          tt0-fin-doc-tax.line-num         = 1
          tt0-fin-doc-tax.slt-pc           = 0
          tt0-fin-doc-tax.sum-line-doc     = tt-fin-doc.sum-doc
          tt0-fin-doc-tax.sum-slt-line-doc = 0
          tt0-fin-doc-tax.with-slt         = no
          .
        case paramVne:
          when "vne" then do:
          assign
            tt0-fin-doc-tax.sum-vat-line-doc = 0
            tt0-fin-doc-tax.vat-pc           = -1
            tt0-fin-doc-tax.with-vat         = no
            .
          end.
          when "avans" then do:
          assign
            tt0-fin-doc-tax.vat-pc           = 22
            tt0-fin-doc-tax.sum-vat-line-doc = (tt-fin-doc.sum-doc * tt0-fin-doc-tax.vat-pc)/(100 + tt0-fin-doc-tax.vat-pc)
            tt0-fin-doc-tax.with-vat         = yes
            .
          end.
          otherwise do:
          assign
            tt0-fin-doc-tax.sum-vat-line-doc = 0
            tt0-fin-doc-tax.vat-pc           = 0
            tt0-fin-doc-tax.with-vat         = no
            .
          end.
        end case .
        release tt0-fin-doc-tax.
      end.
    end.
  end.
end procedure.
procedure proc-update-sum-vat-chr :
  define input-output parameter p-start as integer no-undo .
  define variable v-sum-vat      like ub.fin-doc-tax.sum-vat-line-doc no-undo .
  define variable v-sum-vat-chr  as character no-undo .
  define variable v-each-vat-chr as character no-undo.
  define variable v-vat-pc       as integer no-undo .
end procedure.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-mode  <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'ПРОСМОТР':U
  and p-mode <> 'КОПИРОВАНИЕ':U
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.
  run fill-main-table in this-procedure no-error .
  if error-status:error then do:
    if return-value = "exit":U then undo, return .
    undo, return error.
  end.
  run fill-tables in this-procedure.
  RUN MYEnable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
if v-not-uf-set = no then
run uf-set in this-procedure(
    input  ('findoci-p':U + chr(4) + 'апр':U)
    ,input  g#userid
    ,input RS-view
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .
RUN disable_UI.
PROCEDURE change-view :
define input parameter p-view as character no-undo.
display
rs-view
with frame Dialog-Frame.
assign
tt-fin-doc.exch-rate frame Dialog-Frame
tt-fin-doc.exch-scale
tt-fin-doc.obj-type
tt-fin-doc.obj-code
tt-fin-doc.sum-doc
tt-fin-doc.prn-doc-code
tt-fin-doc.receiver-name
tt-fin-doc.naznach-plat
tt-fin-doc.payer-sign1
tt-fin-doc.receiver-sign1
tt-fin-doc.PS
.
if p-view = "full" then do:
  assign
  tt-fin-doc.str-podr-code
  tt-fin-doc.str-podr-type
  tt-fin-doc.str-podr-name
  .
end.
hide
f-debet
f-credit
tt-fin-doc.cor-acc1-value
f-cor-acc1-descr
tt-fin-doc.cor-acc-value
f-cor-acc-descr
tt-fin-doc.an-uchet-value
f-an-uchet-descr
tt-fin-doc.cel-nazn-value
f-cel-nazn-descr
B-cor-acc1
B-cor-acc
B-an-uchet
tt-fin-doc.cel-nazn-value
B-cel-nazn
tt-fin-doc.perm-date
tt-fin-doc.user-name-perm
tt-fin-doc.fact-date
tt-fin-doc.user-name-fact
b-exit
B-receiver
b-contract-view
f-contract-date
f-contract-prn-code
f-contract-type
f-contract-curr-abbr
tt-fin-doc.contract-curr
b-payer-view
tt-fin-doc.payer-type
tt-fin-doc.payer-code
tt-fin-doc.payer-okpo
tt-fin-doc.payer-name
tt-fin-doc.str-podr-type
tt-fin-doc.str-podr-code
tt-fin-doc.str-podr-name
IN FRAME Dialog-Frame.
display
F-curr-abbr
b-currency
with frame Dialog-Frame
.
IF AVAILABLE tt-fin-doc THEN
  display
  tt-fin-doc.fin-doc-code
  tt-fin-doc.prn-doc-code
  tt-fin-doc.doc-date
  usrfulnf(tt-fin-doc.user-name-doc) @ tt-fin-doc.user-name-doc
  tt-fin-doc.obj-type
  tt-fin-doc.obj-code
  tt-fin-doc.sum-rubl
  tt-fin-doc.curr-code
  tt-fin-doc.sum-doc
  tt-fin-doc.receiver-code
  tt-fin-doc.receiver-type
  tt-fin-doc.receiver-name
  tt-fin-doc.naznach-plat
  tt-fin-doc.PS
  tt-fin-doc.payer-sign1
  tt-fin-doc.receiver-sign1
  with frame Dialog-Frame
  .
  if tt-fin-doc.perm-date <> ? then
  display
  tt-fin-doc.perm-date
  usrfulnf(tt-fin-doc.user-name-perm) @ tt-fin-doc.user-name-perm
  with frame Dialog-Frame
   .
  if tt-fin-doc.fact-date <> ? then
  display
  tt-fin-doc.fact-date
  usrfulnf(tt-fin-doc.user-name-fact) @ tt-fin-doc.user-name-fact
  with frame Dialog-Frame
  .
ENABLE
b-quit
B-tax
B-print when p-mode <> 'ДОБАВЛЕНИЕ':U
B-hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
RS-view
b-receiver-view
b-payer-view
WITH FRAME Dialog-Frame.
if p-mode <> 'ПРОСМОТР':U then do:
  ENABLE
  B-exit
  tt-fin-doc.prn-doc-code
  tt-fin-doc.doc-date when v-limit-access = 0
  b-calc  when v-limit-access = 0
  b-obj   when not v-is-auto-obj
  tt-fin-doc.obj-type      when not v-is-auto-obj
  tt-fin-doc.obj-code      when not v-is-auto-obj
  tt-fin-doc.PS
  WITH FRAME Dialog-Frame.
  if v-limit-access = 0  then do:
    ENABLE
    tt-fin-doc.curr-code
    B-currency
    tt-fin-doc.sum-doc
    tt-fin-doc.receiver-code when tt-fin-doc.contract-code = 0
    B-receiver               when tt-fin-doc.contract-code = 0
    tt-fin-doc.receiver-type when tt-fin-doc.contract-code = 0
    tt-fin-doc.receiver-name when tt-fin-doc.contract-code = 0
    tt-fin-doc.naznach-plat
    tt-fin-doc.payer-sign1
    tt-fin-doc.receiver-sign1
    WITH FRAME Dialog-Frame.
    end.
end.
else do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
run hide-view-currency in this-procedure.
CASE p-view:
  when "full":U then do:
    assign
    v-tab-order = "b-exit,b-quit,b-tax,b-print,b-hist,b-help," +  "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view,str-podr-type,str-podr-code,str-podr-name," +                             v-an-uchet-tab-order +  v-sum-curr-tab-order +                             "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat," +                              "PS,payer-sign1,receiver-sign1"
    .
    IF AVAILABLE tt-fin-doc THEN
    display
    tt-fin-doc.payer-type
    tt-fin-doc.payer-code
    tt-fin-doc.payer-okpo
    tt-fin-doc.payer-name
    tt-fin-doc.str-podr-type
    tt-fin-doc.str-podr-code
    tt-fin-doc.str-podr-name
    with frame Dialog-Frame
    .
    display
    f-debet
    f-credit
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame Dialog-Frame
    .
    if v-limit-access = 0 then do:
      ENABLE
      tt-fin-doc.str-podr-type
      tt-fin-doc.str-podr-code
      tt-fin-doc.str-podr-name
      WITH FRAME Dialog-Frame.
    end.
    if v-limit-access < 2 then do:
      ENABLE
      B-cor-acc1
      tt-fin-doc.cor-acc1-value
      tt-fin-doc.cor-acc-value
      B-cor-acc
      tt-fin-doc.an-uchet-value
      B-an-uchet
      tt-fin-doc.cel-nazn-value
      B-cel-nazn
      WITH FRAME Dialog-Frame.
    end.
  end.
  when "brief":U then do:
     assign
     v-tab-order = "b-exit,b-quit,b-tax,b-print,b-hist,b-help," +                            "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view," +                            v-sum-curr-tab-order +                            "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat," +                            "PS,payer-sign1,receiver-sign1"
     .
  end.
  when "contract":U then do:
    assign
    v-tab-order = "b-exit,b-quit,b-tax,b-print,b-hist,b-help," +                               "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view," +                                v-contract-tab-order + v-sum-curr-tab-order +                                 "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat," +                                 "PS,payer-sign1,receiver-sign1"
    .
    display
    b-contract-view
    f-contract-date when tt-fin-doc.contract-code <> 0
    f-contract-prn-code when tt-fin-doc.contract-code <> 0
    f-contract-type when tt-fin-doc.contract-code <> 0
    f-contract-curr-abbr when tt-fin-doc.contract-code <> 0
    tt-fin-doc.contract-curr when tt-fin-doc.contract-code <> 0
    with frame Dialog-Frame
    .
    ENABLE
    b-contract-view
    with frame Dialog-Frame.
  end.
END CASE.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY RS-view f-cor-acc-descr f-an-uchet-descr f-contract-curr-abbr
          f-contract-prn-code f-contract-date f-contract-type f-cor-acc1-descr
          f-cel-nazn-descr f-rest-con-sum F-curr-abbr F-debet F-credit
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-doc THEN
    DISPLAY tt-fin-doc.user-name-doc tt-fin-doc.prn-doc-code
          tt-fin-doc.fin-doc-code tt-fin-doc.perm-date tt-fin-doc.doc-date
          tt-fin-doc.user-name-perm tt-fin-doc.obj-type tt-fin-doc.obj-code
          tt-fin-doc.fact-date tt-fin-doc.user-name-fact tt-fin-doc.payer-type
          tt-fin-doc.payer-code tt-fin-doc.payer-okpo tt-fin-doc.payer-name
          tt-fin-doc.str-podr-type tt-fin-doc.str-podr-code
          tt-fin-doc.str-podr-name tt-fin-doc.cor-acc-value
          tt-fin-doc.an-uchet-value tt-fin-doc.contract-curr
          tt-fin-doc.cor-acc1-value tt-fin-doc.cel-nazn-value tt-fin-doc.sum-doc
          tt-fin-doc.curr-code tt-fin-doc.exch-rate tt-fin-doc.exch-scale
          tt-fin-doc.sum-rubl tt-fin-doc.base-rate tt-fin-doc.base-scale
          tt-fin-doc.sum-base tt-fin-doc.contract-rate tt-fin-doc.contract-scale
          tt-fin-doc.sum-contr tt-fin-doc.receiver-type tt-fin-doc.receiver-code
          tt-fin-doc.receiver-name tt-fin-doc.naznach-plat tt-fin-doc.PS
          tt-fin-doc.payer-sign1 tt-fin-doc.receiver-sign1
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-tax B-print B-hist B-Help RS-view
         tt-fin-doc.user-name-doc tt-fin-doc.prn-doc-code tt-fin-doc.doc-date
         tt-fin-doc.obj-type tt-fin-doc.obj-code B-obj tt-fin-doc.payer-name
         B-payer-view tt-fin-doc.str-podr-type tt-fin-doc.str-podr-code
         tt-fin-doc.str-podr-name tt-fin-doc.cor-acc-value B-cor-acc
         tt-fin-doc.an-uchet-value B-an-uchet f-contract-curr-abbr
         B-contract-view tt-fin-doc.contract-curr tt-fin-doc.cor-acc1-value
         B-cor-acc1 tt-fin-doc.cel-nazn-value B-cel-nazn tt-fin-doc.sum-doc
         f-rest-con-sum tt-fin-doc.curr-code B-currency B-calc
         tt-fin-doc.exch-rate tt-fin-doc.exch-scale tt-fin-doc.sum-rubl
         tt-fin-doc.sum-base tt-fin-doc.contract-rate tt-fin-doc.contract-scale
         tt-fin-doc.sum-contr B-receiver tt-fin-doc.receiver-type
         tt-fin-doc.receiver-code tt-fin-doc.receiver-name B-receiver-view
         tt-fin-doc.naznach-plat tt-fin-doc.PS tt-fin-doc.payer-sign1
         tt-fin-doc.receiver-sign1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-main-table :
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
for each tt-fin-doc:
  delete tt-fin-doc.
end.
for each tt0-fin-doc-attr:
  delete tt0-fin-doc-attr.
end.
for each tt0-fin-doc-tax:
 delete tt0-fin-doc-tax.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
or p-mode = 'КОПИРОВАНИЕ':U
then do:
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first locked_fin-doc EXclusive-lock where
                  recid(locked_fin-doc) = p-doc-rec no-wait no-error.
    if locked locked_fin-doc then do:
      message
      substitute("Запись &1 занята", p-fin-doc-code)
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_fin-doc no-lock where
                recid(locked_fin-doc) = p-doc-rec no-error .
      if not available locked_fin-doc then do:
        find first locked_fin-doc no-lock where
                    locked_fin-doc.host-code = p-host-code
                AND locked_fin-doc.fin-doc-code = p-fin-doc-code no-error .
      end.
  end.
  if not available locked_fin-doc then do:
    message
    substitute("&1 &2 &3&4 Не найдена запись &5"
                ,vss-workfile
                ,vss-revision
                ,vss-description
                ,chr(10)
                ,p-fin-doc-code)
    view-as alert-box error .
    undo, return error.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  AND not (locked_fin-doc.status_ = 'новый':U
            or locked_fin-doc.status_ = 'разрешен':U )
  then do:
    message
    substitute("Финансовый документ &1 находится в статусе &2&3Изменение невозможно"
              ,p-fin-doc-code
              ,locked_fin-doc.status_
              ,chr(10))
    view-as alert-box error .
    undo, return error.
  end.
  create tt-fin-doc.
  if p-mode = 'КОПИРОВАНИЕ':U then do:
    buffer-copy locked_fin-doc
    using
    obj-type
    obj-code
    payer-type
    payer-code
    payer-name
    payer-sign1
    payer-okpo
    receiver-type
    receiver-code
    receiver-name
    receiver-sign1
    an-uchet-code
    an-uchet-value
    cel-nazn-code
    cel-nazn-value
    contract-code
    contract-curr
    cor-acc-value
    cor-acc1-value
    cor-acc1
    cor-acc
    curr-code
    naznach-plat
    str-podr-code
    str-podr-name
    str-podr-type
    sum-doc
    CashBookId
    to tt-fin-doc
    assign
    tt-fin-doc.host-code = p-host-code
    .
  end.
  else do:
    buffer-copy locked_fin-doc to tt-fin-doc.
  end.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U
or p-mode = 'КОПИРОВАНИЕ':U then do:
  run ref/finfnoco.p (
                  INPUT parParentProc
                ,INPUT this-procedure:handle
                ,input p-curr-host-code
                ,input (p-mode  + chr(4) + 'manual':U)
                ,input p-host-code
                ,input p-doc-rec
                ,input p-fin-doc-code
                ,input 'апр':U
                ,input 'апр':U
                ,input p-obj-type
                ,input p-obj-code
                ,input p-contract-code
                ,input p-ob-doc-code
                ,input 'орг':U
                ,input p-host-code
                ,input 0
                ,input p-receiver-type
                ,input p-receiver-code
                ,input 0
                ,input p-curr-code
                ,input p-cor-acc
                ,input p-cor-acc1
                ,input p-an-uchet-code
                ,input p-cel-nazn-code
                ,input (if available tt-fin-doc then tt-fin-doc.CashBookId else 0)
                ,input ""
                ,INPUT-OUTPUT table tt-fin-doc
                ,INPUT-OUTPUT table ttc-fin-doc
                ,output table tt0-fin-doc-attr
                ,output v-limit-access ) no-error .
end.
else do:
  run ref/finfnoco.p (
                  INPUT parParentProc
                ,INPUT this-procedure:handle
                ,input p-curr-host-code
                ,input (p-mode  + chr(4) + 'manual':U)
                ,input p-host-code
                ,input p-doc-rec
                ,input tt-fin-doc.fin-doc-code
                ,input 'апр':U
                ,input tt-fin-doc.fin-ext-doc-type
                ,input tt-fin-doc.obj-type
                ,input tt-fin-doc.obj-code
                ,input tt-fin-doc.contract-code
                ,input p-ob-doc-code
                ,input 'орг':U
                ,input p-host-code
                ,input 0
                ,input tt-fin-doc.receiver-type
                ,input tt-fin-doc.receiver-code
                ,input 0
                ,input tt-fin-doc.curr-code
                ,input tt-fin-doc.cor-acc
                ,input tt-fin-doc.cor-acc1
                ,input tt-fin-doc.an-uchet-code
                ,input tt-fin-doc.cel-nazn-code
                ,input tt-fin-doc.CashBookId
                ,input ""
                ,INPUT-OUTPUT table ttc-fin-doc
                ,INPUT-OUTPUT table tt-fin-doc
                ,output table tt0-fin-doc-attr
                ,output v-limit-access ) no-error .
end.
if error-status:error then do:
  if not return-value = "exit" then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
  end.
  undo, return error.
end.
find first tt-fin-doc.
run recalc in this-procedure ( input "curr-code":U).
if p-mode = 'КОПИРОВАНИЕ':U then do:
  assign
  v-copy-mode = yes
  p-mode = 'ДОБАВЛЕНИЕ':U.
  if tt-fin-doc.curr-code = 0  then
  run recalc in this-procedure  ( input "sum-doc").
end.
END PROCEDURE.
PROCEDURE Myenable :
define variable g-log as logical no-undo.
define variable v-inn like ub.firm.inn no-undo .
define variable v-kpp like ub.firm.kpp no-undo .
assign
    tt-fin-doc.sum-rubl :label in frame Dialog-Frame = "Рубли"
.
run uf-get in this-procedure(
    input  ('findoci-p':U + chr(4) + 'апр':U)
    ,input  g#userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and not v-uf-LIst_ = "":U
then do:
    assign
    v-view =  entry(1, v-uf-List_, chr(4))
    .
end.
assign
frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32) + x_clients-host.obj-name
tt-fin-doc.receiver-type:radio-buttons = "Орг" + chr(44) + 'орг':U + chr(44) +
                                         "Чел" + chr(44) + 'чел':U
rs-view:radio-buttons = "&Полн." + chr(44) + "full":U +  chr(44) +
                                    "&Сокращ." + chr(44) + "brief":U + chr(44) +
                                    "&Дог-р" + chr(44) + "contract":U
tt-fin-doc.obj-type:radio-buttons = "Маг" + chr(44) + 'маг':U + chr(44) +
                                    "Скл" + chr(44) + 'скл':U
rs-view = v-view
v-an-uchet-tab-order = (if X_sysconf.is-corr-acc then "cor-acc-value,b-cor-acc," else "":U) +
                       (if X_sysconf.is-an-uchet then "an-uchet-value,b-an-uchet," else "":U) +
                       (if X_sysconf.is-cassa-acc then "cor-acc1-value,b-cor-acc1," else "":U) +
                       (if X_sysconf.is-code-cel-nazn then "cel-nazn-value,b-cel-nazn," else "":U)
v-an-uchet-tab-order = "cor-acc-value,b-cor-acc,"    +
                       "an-uchet-value,b-an-uchet,"   +
                       "cor-acc1-value,b-cor-acc1,"  +
                       "cel-nazn-value,b-cel-nazn,"
v-limit-access = (if p-mode = 'ПРОСМОТР':U then 10 else v-limit-access)
tt-fin-doc.obj-type:screen-value  = (if tt-fin-doc.obj-type = 'маг':U
                                    or tt-fin-doc.obj-type = 'скл':U
                                    then tt-fin-doc.obj-type
                                    else tt-fin-doc.obj-type:screen-value)
.
if p-mode = 'ПРОСМОТР':U and
tt-fin-doc.contract-code = 0 then do:
    assign
    g-log = rs-view:disable(radio-label("contract":U, RS-view:radio-buttons))
    .
    if rs-view = "contract":U then
    assign
    rs-view = "full":U
    v-not-uf-set = yes.
end.
find first X_currency no-lock where
              X_currency.curr-code = tt-fin-doc.curr-code.
assign
f-curr-abbr = X_Currency.curr-abbr.
if p-mode = 'ДОБАВЛЕНИЕ':U and tt-fin-doc.contract-code = 0 then do:
  assign
  tt-fin-doc.receiver-type = (if tt-fin-doc.receiver-type = "":U then 'орг':U else tt-fin-doc.receiver-type)
  .
end.
assign
v-head-position = (if num-entries(tt-fin-doc.payer-sign1, chr(4)) > 1
                    then entry(1, tt-fin-doc.payer-sign1, chr(4))
                    else "":U)
tt-fin-doc.payer-sign1:label  = tt-fin-doc.payer-sign1:label  + " - ":U +
                          v-head-position
tt-fin-doc.payer-sign1 =   (if num-entries(tt-fin-doc.payer-sign1, chr(4)) > 1
                                  then entry(2, tt-fin-doc.payer-sign1, chr(4))
                                  else entry(1, tt-fin-doc.payer-sign1, chr(4)))
.
if p-mode = 'ПРОСМОТР':U then do:
    run proc-color-widgets in this-procedure("f-an-uchet-descr,f-cel-nazn-descr,f-contract-curr-abbr,f-contract-date,f-contract-prn-code,f-contract-rate," +                         "f-contract-scale,f-contract-type,f-cor-acc1-descr,f-cor-acc-descr,base-rate,base-scale,curr-code,exch-rate,exch-scale," +                         "fact-date,fin-doc-code,receiver-code,receiver-type,perm-date,PS,payer-code,payer-type,sum-base,sum-rubl," +                         "user-name-doc,user-name-fact,user-name-perm", no, yes, ?, ?).
    run proc-color-widgets in this-procedure("F-curr-abbr,an-uchet-value,cel-nazn-value,cor-acc1-value,cor-acc-value,doc-date," +                       "naznach-plat,receiver-name,prn-doc-code,payer-name,payer-okpo,payer-sign1,receiver-sign1" +                       "str-podr-code,str-podr-name,str-podr-type,sum-doc", no, yes, ?, ?).
end.
display
tt-fin-doc.exch-rate
tt-fin-doc.exch-scale
tt-fin-doc.sum-doc
(tt-fin-doc.sum-contr - tt-fin-doc.con-sum-contr ) @ f-rest-con-sum
tt-fin-doc.prn-doc-code
tt-fin-doc.receiver-name
tt-fin-doc.naznach-plat
tt-fin-doc.payer-sign1
tt-fin-doc.receiver-sign1
tt-fin-doc.PS
with frame Dialog-Frame
.
if tt-fin-doc.contract-code <> 0 then do:
    find first X_contract-currency no-lock where
              X_contract-currency.curr-code = tt-fin-doc.contract-curr .
    assign
    f-contract-prn-code = X_contract.contract-prn-code
    f-contract-date     = X_contract.contract-date
    f-contract-type     = X_contract.contract-type
    f-contract-curr-abbr = X_contract-currency.curr-abbr
    .
end.
run change-view in this-procedure(rs-view).
VIEW FRAME Dialog-Frame.
if p-mode <> 'ПРОСМОТР':U then APPLY "ENTRY" to tt-fin-doc.prn-doc-code.
END PROCEDURE.
PROCEDURE proc-save :
define input parameter p-save as logical no-undo .
if p-mode = 'ПРОСМОТР':U or not available tt-fin-doc then do:
    return error.
end.
assign
tt-fin-doc.prn-doc-code frame Dialog-Frame
tt-fin-doc.doc-date
tt-fin-doc.obj-code
tt-fin-doc.obj-type
tt-fin-doc.obj-type  = (if tt-fin-doc.obj-code = 0 then "":U else tt-fin-doc.obj-type)
tt-fin-doc.payer-name
tt-fin-doc.str-podr-type
tt-fin-doc.str-podr-code
tt-fin-doc.str-podr-name
tt-fin-doc.cor-acc1 = (if available X_fin-code-cor-acc1
                       then X_fin-code-cor-acc1.fin-code
                       else 0)
tt-fin-doc.cor-acc1-value = (if available X_fin-code-cor-acc1
                       then X_fin-code-cor-acc1.code-value
                       else "":U)
tt-fin-doc.cor-acc  = (if available X_fin-code-cor-acc
                       then X_fin-code-cor-acc.fin-code
                       else 0)
tt-fin-doc.cor-acc-value  = (if available X_fin-code-cor-acc
                       then X_fin-code-cor-acc.code-value
                       else "":U)
tt-fin-doc.an-uchet-code  = (if available X_fin-code-an-uchet
                        then X_fin-code-an-uchet.fin-code
                        else 0)
tt-fin-doc.an-uchet-value  = (if available X_fin-code-an-uchet
                        then X_fin-code-an-uchet.code-value
                        else "":U)
tt-fin-doc.cel-nazn-code  = (if available X_fin-code-cel-nazn
                       then X_fin-code-cel-nazn.fin-code
                       else 0)
tt-fin-doc.cel-nazn-value  = (if available X_fin-code-cel-nazn
                       then X_fin-code-cel-nazn.code-value
                       else "":U)
tt-fin-doc.curr-code
tt-fin-doc.contract-curr
tt-fin-doc.contract-rate
tt-fin-doc.contract-scale
tt-fin-doc.sum-doc
tt-fin-doc.receiver-code
tt-fin-doc.receiver-type
tt-fin-doc.receiver-name
tt-fin-doc.naznach-plat
tt-fin-doc.PS
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign1  =   v-head-position +  chr(4) + tt-fin-doc.payer-sign1
tt-fin-doc.receiver-sign1
.
if not p-save then return.
run check-sums-rate in this-procedure no-error.
if error-status:error then return error.
run ref/findoc0.p (
input-output p-doc-rec
       ,input p-mode
       ,input no
       ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
       ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
       ,input table tt0-fin-doc-tax
       ,input table tt0-fin-doc-attr
       ,input no
       ,input table tt0-payment
) no-error.
if error-status:error then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END PROCEDURE.
