DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-layout-elem-rule NO-UNDO LIKE ub.layout-elem-rule.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-device-type as character no-undo .
define input-output parameter table for tt0-layout-elem-rule.
define input-output parameter table for tt0-rule-call-param.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма для ввода, просмотра и изменения привязок элемента раскладки".
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
FUNCTION get-param-value RETURNS CHARACTER
  ( INPUT p-data-type AS CHARACTER
   ,INPUT p-2-data-type AS character
   ,INPUT p-3-data-type AS CHARACTER
   ,INPUT p-p-index AS INTEGER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
     ) :
define buffer buf_cash-pay for ub.cash-pay.
define variable v-view-value as character no-undo .
if (p-3-data-type = "LIST"
     or
     p-3-data-type = "SORTED-LIST"
     )
and p-p-index = 0 then return '':U.
if p-2-data-type > '' then do:
  case p-2-data-type:
    when 'cash-pay':U
    or
    when 'cash-pay':U + "_null"
    then do:
      if p-2-data-type = 'cash-pay':U + "_null"
      and p-value-character = substitute("&1,&2", 0, 0) then return "Тип касс. платежа не задан".
      else do:
        find first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = integer(entry(1, p-value-character))
              and buf_cash-pay.curr-code = integer(entry(2, p-value-character)) no-error.
        if available buf_cash-pay then return buf_cash-pay.obj-name.
        else return "!!!Неизвестный тип касс.платежа".
      end.
    end.
    when 'chk-doc':U + "_wth-type_null"
    or when 'chk-doc':U + "_wth-type" then do:
      return entry (lookup (string(p-value-integer),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U).
    end.
    when 'discnt-v-type-manual':U then do:
            return entry (lookup (string(p-value-integer), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U).
    end.
    otherwise do:
      if lookup(p-2-data-type, 'gds-discnt-role,subtotal-discnt-role,pay-discnt-role':U) > 0  then do:
         if lookup(p-value-character, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
         end.
         if lookup(p-value-character, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u).
         end.
         if lookup(p-value-character, 'simple-pay,qnty-pay':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u).
         end.
         if lookup(p-value-character, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u).
         end.
         if lookup(p-value-character, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u).
         end.
         if lookup(p-value-character, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u).
         end.
         if lookup(p-value-character, 'cli-grp-pcnt':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'cli-grp-pcnt':u) + 1, ',' + '% скидка на группу клиентов':u).
         end.
      end.
    end.
  end case.
end.
case p-data-type:
  when 'character':U then do:
    return p-value-character.
  end.
  when 'date':U then do:
    return string(p-value-date, "99/99/9999").
  end.
  when 'decimal':U then do:
    return string(p-value-decimal).
  end.
  when 'integer':U then do:
    return string(p-value-integer).
  end.
  when 'logical':U then do:
    return string(p-value-logical).
  end.
end.
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
define variable v-admin as logical no-undo .
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-image-id-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 6"
     SIZE 3 BY 1.
DEFINE BUTTON B-image-id-insen
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 6"
     SIZE 3 BY 1.
DEFINE BUTTON B-image-id-up
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 6"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE E-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 3 NO-UNDO.
DEFINE VARIABLE f-elem-label AS CHARACTER FORMAT "X(256)":U
     LABEL "Label"
     VIEW-AS FILL-IN NATIVE
     SIZE 29.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-elem-tooltip AS CHARACTER FORMAT "X(256)":U
     LABEL "Tooltip"
     VIEW-AS FILL-IN NATIVE
     SIZE 89 BY 1 NO-UNDO.
DEFINE VARIABLE f-image-id-down AS CHARACTER FORMAT "X(256)":U
     LABEL "Изобр. в состоянии DOWN"
     VIEW-AS FILL-IN NATIVE
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE f-image-id-insen AS CHARACTER FORMAT "X(256)":U
     LABEL "Изобр. в состоянии INSENSITIVE"
     VIEW-AS FILL-IN NATIVE
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE f-image-id-up AS CHARACTER FORMAT "X(256)":U
     LABEL "Изобр. в состоянии UP"
     VIEW-AS FILL-IN NATIVE
     SIZE 60 BY 1 NO-UNDO.
DEFINE VARIABLE f-rule-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 98 BY 1 NO-UNDO.
DEFINE QUERY BR-rule-call-param FOR
      tt-rule-call-param SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt0-layout-elem-rule SCROLLING.
DEFINE BROWSE BR-rule-call-param
  QUERY BR-rule-call-param NO-LOCK DISPLAY
      tt-rule-call-param.param-name column-label "Название"
tt-rule-call-param.param-label column-label "Название"
tt-rule-call-param.param-data-type column-label  "Тип!данных"
get-param-value( INPUT tt-rule-call-param.param-data-type
                ,INPUT tt-rule-call-param.param-2-data-type
                ,INPUT tt-rule-call-param.param-3-data-type
                ,INPUT tt-rule-call-param.p-index
                ,INPUT tt-rule-call-param.param-value-character
                ,INPUT tt-rule-call-param.param-value-date
                ,INPUT tt-rule-call-param.param-value-decimal
                ,INPUT tt-rule-call-param.param-value-integer
                ,INPUT tt-rule-call-param.param-value-logical) column-label "Значение"
format "X(255)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.27
         TITLE "Параметры" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-rule-name AT ROW 2 COL 1 NO-LABEL WIDGET-ID 96
     E-des AT ROW 3 COL 1 NO-LABEL WIDGET-ID 98
     f-elem-label AT ROW 6 COL 8 COLON-ALIGNED WIDGET-ID 74
     f-elem-tooltip AT ROW 7 COL 1 WIDGET-ID 92
     f-image-id-up AT ROW 8 COL 31 COLON-ALIGNED WIDGET-ID 78
     B-image-id-up AT ROW 8 COL 95 WIDGET-ID 86
     f-image-id-down AT ROW 9 COL 31 COLON-ALIGNED WIDGET-ID 82
     B-image-id-down AT ROW 9 COL 95 WIDGET-ID 88
     f-image-id-insen AT ROW 10 COL 31 COLON-ALIGNED WIDGET-ID 84
     B-image-id-insen AT ROW 10 COL 95 WIDGET-ID 90
     b-chg AT ROW 11.5 COL 1 WIDGET-ID 94
     BR-rule-call-param AT ROW 12.5 COL 1 WIDGET-ID 300
     SPACE(0.49) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Свойства элемента для раскладки"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       E-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-elem-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-elem-tooltip:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-image-id-down:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-image-id-insen:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-image-id-up:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
  p-ok = yes.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not available tt-rule-call-param then do:
     bell.
     return no-apply.
  end.
  run proc-b-chg in this-procedure no-error.
END.
ON CHOOSE OF B-image-id-down IN FRAME Dialog-Frame
DO:
  define variable v-file-name as character no-undo.
  run proc-file in this-procedure ( output v-file-name ) no-error.
  if not error-status:error then do:
     display
     v-file-name @ f-image-id-down
     with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-image-id-insen IN FRAME Dialog-Frame
DO:
  define variable v-file-name as character no-undo.
  run proc-file in this-procedure ( output v-file-name ) no-error.
  if not error-status:error then do:
     display
     v-file-name @ f-image-id-insen
     with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-image-id-up IN FRAME Dialog-Frame
DO:
define variable v-file-name as character no-undo.
  run proc-file in this-procedure ( output v-file-name ) no-error.
  if not error-status:error then do:
     display
     v-file-name @ f-image-id-up
     with frame Dialog-Frame.
  end.
END.
ON LEAVE OF f-image-id-down IN FRAME Dialog-Frame
DO:
    define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
    ASSIGN
    f-image-id-down.
    IF f-image-id-down <> '' THEN DO:
    run gbl/filename.p ( INPUT f-image-id-down
                        ,OUTPUT v-full-path
                         ,OUTPUT v-path
                         ,OUTPUT v-file-name
                         ,OUTPUT v-file-name-no-ext
                         ,OUTPUT v-file-name-ext) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN DO:
           MESSAGE
           substitute("Ошибка при поиске файла &1&2&3&2&4"
                      , f-image-id-down
                      , chr(10)
                      , error-status:get-message(1)
                      , RETURN-VALUE
                      )
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
       END.
    END.
END.
ON LEAVE OF f-image-id-insen IN FRAME Dialog-Frame
DO:
    define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
    ASSIGN
    f-image-id-insen.
    IF f-image-id-insen <> '' THEN DO:
    run gbl/filename.p ( INPUT f-image-id-insen
                        ,OUTPUT v-full-path
                         ,OUTPUT v-path
                         ,OUTPUT v-file-name
                         ,OUTPUT v-file-name-no-ext
                         ,OUTPUT v-file-name-ext) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN DO:
           MESSAGE
           substitute("Ошибка при поиске файла &1&2&3&2&4"
                      , f-image-id-insen
                      , chr(10)
                      , error-status:get-message(1)
                      , RETURN-VALUE
                      )
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
       END.
    END.
END.
ON LEAVE OF f-image-id-up IN FRAME Dialog-Frame
DO:
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
  ASSIGN
  f-image-id-up.
  IF f-image-id-up <> '' THEN DO:
  run gbl/filename.p ( INPUT f-image-id-up
                      ,OUTPUT v-full-path
                       ,OUTPUT v-path
                       ,OUTPUT v-file-name
                       ,OUTPUT v-file-name-no-ext
                       ,OUTPUT v-file-name-ext) NO-ERROR.
     IF ERROR-STATUS:ERROR THEN DO:
         MESSAGE
         substitute("Ошибка при поиске файла &1&2&3&2&4"
                    , f-image-id-up
                    , chr(10)
                    , error-status:get-message(1)
                    , RETURN-VALUE
                    )
        VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
     END.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-rule-call-param :handle
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), chr(44)).
  end.
  if lookup( p-mode, 'ДОБАВЛЕНИЕ':U + chr(44) + 'ИЗМЕНЕНИЕ':U) = 0 then do:
     message
     substitute("Неверное значение параметра p-mode=&1", p-mode)
     vss-workfile vss-revision vss-description skip
     view-as alert-box error .
     undo, return error .
  end.
  for each buf_tt-rule-call-param:
    delete buf_tt-rule-call-param.
  end.
  for each buf_tt0-rule-call-param:
    create buf_tt-rule-call-param.
    buffer-copy buf_tt0-rule-call-param to buf_tt-rule-call-param.
  end.
   RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-rule-name E-des f-elem-label f-elem-tooltip f-image-id-up
          f-image-id-down f-image-id-insen
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help E-des f-elem-label f-elem-tooltip B-image-id-up
         B-image-id-down B-image-id-insen b-chg BR-rule-call-param
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE BUFFER buf_rule FOR ub.RULE.
ASSIGN
tt-rule-call-param.param-data-type:visible in browse br-rule-call-param = (v-admin = yes)
tt-rule-call-param.param-name:visible in browse br-rule-call-param = (v-admin = yes)
.
find first tt0-layout-elem-rule where tt0-layout-elem-rule.uniq-key-rec = p-uniq-key-rec.
assign
frame Dialog-Frame:title = substitute("Функции для элемента ракладки &1 &2 &3"
                                     , (if p-mode = 'ДОБАВЛЕНИЕ':U then '' else tt0-layout-elem-rule.layout-id)
                                     , title-mode(p-mode)
                                     ,( if v-admin then  "Режим IBS" else ''))
.
FIND FIRST buf_rule NO-LOCK WHERE
          buf_rule.RULE_id = tt0-layout-elem-rule.RULE_id NO-ERROR.
IF AVAILABLE buf_rule THEN DO:
ASSIGN
f-rule-name = buf_rule.NAME
e-des:SCREEN-VALUE IN FRAME Dialog-Frame  = buf_rule.documentation
.
END.
ELSE DO:
ASSIGN
f-rule-name = substitute("!!!Неизвестная функция &1",tt-rule-call-param.RULE_id).
END.
DISPLAY
f-rule-name
tt0-layout-elem-rule.elem-label  @ f-elem-label
tt0-layout-elem-rule.elem-tooltip  @ f-elem-tooltip
tt0-layout-elem-rule.image-id-up  @ f-image-id-up
tt0-layout-elem-rule.image-id-down  @ f-image-id-down
tt0-layout-elem-rule.image-id-insen @ f-image-id-insen
WITH FRAME Dialog-Frame .
ENABLE
B-exit
b-quit
B-Help
b-chg when can-find(first tt-rule-call-param where tt-rule-call-param.call_id = p-uniq-key-rec)
f-image-id-up WHEN p-mode <> 'ПРОСМОТР':U  and p-device-type =  'th-pos-screen':U
f-image-id-down WHEN p-mode <> 'ПРОСМОТР':U and p-device-type = 'th-pos-screen':U
f-image-id-insen WHEN p-mode <> 'ПРОСМОТР':U and p-device-type = 'th-pos-screen':U
f-elem-label
f-elem-tooltip  when  (p-mode <> 'ПРОСМОТР':U) and p-device-type = 'th-pos-screen':U
B-image-id-up WHEN (p-mode <> 'ПРОСМОТР':U)   and p-device-type =  'th-pos-screen':U
B-image-id-down WHEN (p-mode <> 'ПРОСМОТР':U)  and p-device-type = 'th-pos-screen':U
B-image-id-insen WHEN (p-mode <> 'ПРОСМОТР':U) and p-device-type = 'th-pos-screen':U
BR-rule-call-param
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label in frame Dialog-Frame = "&Выход"
  b-quit:column = 1.
  hide b-exit in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
run Openbr in this-procedure.
END PROCEDURE.
PROCEDURE Openbr :
OPEN QUERY br-rule-call-param
FOR EACH tt-rule-call-param WHERE tt-rule-call-param.call_id = tt0-layout-elem-rule.uniq-key-rec
NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
DEFINE VARIABLE v-rec AS Rowid NO-UNDO.
define variable v-param-data-type as character no-undo .
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE tt-rule-call-param  THEN DO:
  RETURN ERROR.
END.
v-param-data-type = tt-rule-call-param.param-data-type +
                    (if tt-rule-call-param.param-2-data-type = '':U
                     then '':U
                     else chr(44)) +
                    tt-rule-call-param.param-2-data-type
                     .
if lookup("READ-ONLY", tt-rule-call-param.param-3-data-type) > 0 then do:
  message
  "Данный параметр задан как READ-ONLY (Только для чтения)" skip
  "Изменения не допускаются"
  view-as alert-box error .
  undo, return error .
end.
CASE  v-param-data-type:
  when 'integer':U then do:
    assign
    v-value-integer = tt-rule-call-param.param-value-integer.
    run gbl/d-integer.w (
           input ?
          ,input (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = 'L':U
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=3\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u
        + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U and p-mode <> 'ДОБАВЛЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-integer
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                      ,INPUT tt-rule-call-param.param-value-character
                                      ,INPUT tt-rule-call-param.param-value-date
                                      ,INPUT tt-rule-call-param.param-value-decimal
                                      ,INPUT v-value-integer
                                      ,INPUT tt-rule-call-param.param-value-logical).
  end.
  when 'decimal':U then do:
    assign
    v-value-decimal = tt-rule-call-param.param-value-decimal.
    run gbl/d-decimal.w (
           input ?
          ,input (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = 'L':U
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=3\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u
        + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U and p-mode <> 'ДОБАВЛЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-decimal
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                      ,INPUT tt-rule-call-param.param-value-character
                                      ,INPUT tt-rule-call-param.param-value-date
                                      ,INPUT v-value-decimal
                                      ,INPUT tt-rule-call-param.param-value-decimal
                                      ,INPUT tt-rule-call-param.param-value-logical).
  end.
  when 'character':U then do:
    assign
    v-value-character = tt-rule-call-param.param-value-character.
    run gbl/d-character.w (
          input ?
         ,input (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = 'L':U
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=4\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u
        + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U and p-mode <> 'ДОБАВЛЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-character
        , output v-ok
            ).
        if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                     ,INPUT v-value-character
                                     ,INPUT tt-rule-call-param.param-value-date
                                     ,INPUT tt-rule-call-param.param-value-decimal
                                     ,INPUT tt-rule-call-param.param-value-integer
                                     ,INPUT tt-rule-call-param.param-value-logical).
  end.
  when 'logical':U then do:
    assign
    v-value-logical = tt-rule-call-param.param-value-logical.
    run gbl/d-logical.w (
          input ?
         ,input  (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = 'L':U
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u
        + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U and p-mode <> 'ДОБАВЛЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-logical
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                     ,INPUT tt-rule-call-param.param-value-character
                                     ,INPUT tt-rule-call-param.param-value-date
                                     ,INPUT tt-rule-call-param.param-value-decimal
                                     ,INPUT tt-rule-call-param.param-value-integer
                                     ,INPUT v-value-logical).
  end.
  when 'date':U then do:
    assign
    v-value-date = tt-rule-call-param.param-value-date.
      run gbl/d-inpday.w
        (input ?
        ,input substitute("Изменение параметра &1", tt-rule-call-param.param-label)
        ,input ""
        ,input-output v-value-date
        ,output v-ok
        ) NO-ERROR.
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                     ,INPUT tt-rule-call-param.param-value-character
                                     ,INPUT v-value-date
                                     ,INPUT tt-rule-call-param.param-value-decimal
                                     ,INPUT tt-rule-call-param.param-value-integer
                                     ,INPUT tt-rule-call-param.param-value-logical).
  end.
  otherwise do:
    assign
    v-value-character = tt-rule-call-param.param-value-character
    v-value-date = tt-rule-call-param.param-value-date
    v-value-decimal = tt-rule-call-param.param-value-decimal
    v-value-integer = tt-rule-call-param.param-value-integer
    v-value-logical = tt-rule-call-param.param-value-logical
    .
    run ref/rule-dtt.p (
                         input parparentproc
                        ,input 'ИЗМЕНЕНИЕ':U
                        ,input tt0-layout-elem-rule.uniq-key-rec
                        ,input tt-rule-call-param.param-data-type
                        ,input tt-rule-call-param.param-2-data-type
                        ,input tt-rule-call-param.param-3-data-type
                        ,input tt-rule-call-param.p-index
                        ,input-output v-value-character
                        ,input-output v-value-date
                        ,input-output v-value-decimal
                        ,input-output v-value-integer
                        ,input-output v-value-logical
                        ,output v-ok
                        ) no-error.
    if not error-status:error
    and v-ok then do:
      RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                       ,INPUT v-value-character
                                       ,INPUT v-value-date
                                       ,INPUT v-value-decimal
                                       ,INPUT v-value-integer
                                       ,INPUT v-value-logical).
    end.
  end.
end case.
ASSIGN
v-rec = Rowid(tt-rule-call-param)
.
run openbr in this-procedure .
REPOSITION br-rule-call-param TO Rowid v-rec NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-rule-call-param TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY" TO br-rule-call-param in frame Dialog-Frame .
APPLY "VALUE-CHANGED" TO br-rule-call-param in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-file :
define output parameter file-name as character no-undo.
define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable glog as logical no-undo .
SYSTEM-DIALOG GET-FILE v_os-file
TITLE "Задайте файл для изображения"
FILTERS
  "Все ico файлы (*.ico) " "*.ico",
  "Все файлы (*.*)"                      "*.*"
INITIAL-FILTER 1
DEFAULT-EXTENSION ".xml"
USE-FILENAME
MUST-EXIST
UPDATE ll_commit
.
IF ll_commit <> YES THEN do:
    RETURN NO-APPLY.
end.
IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
    BELL.
    MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
run gbl/filename.p (
                input  v_os-file
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  return no-apply.
end.
assign
file-name = v-full-path.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
assign
frame Dialog-Frame
f-elem-label
f-elem-tooltip
f-image-id-up
f-image-id-down
f-image-id-insen
.
if f-elem-label = '' then do:
  message
  "Вы не определили лейбл"
  view-as alert-box error .
  undo, return error .
end.
for each buf_tt-rule-call-param:
  find first buf_tt0-rule-call-param where
           buf_tt0-rule-call-param.call_id = buf_tt-rule-call-param.call_id
       and buf_tt0-rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
       and buf_tt0-rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
       and buf_tt0-rule-call-param.order_id = buf_tt-rule-call-param.order_id
       and buf_tt0-rule-call-param.param-name = buf_tt-rule-call-param.param-name
       and buf_tt0-rule-call-param.p-index = buf_tt-rule-call-param.p-index
             .
  buffer-copy buf_tt-rule-call-param to buf_tt0-rule-call-param.
end.
assign
tt0-layout-elem-rule.elem-label = f-elem-label
tt0-layout-elem-rule.elem-tooltip = f-elem-tooltip
tt0-layout-elem-rule.image-id-up = f-image-id-up
tt0-layout-elem-rule.image-id-down = f-image-id-down
tt0-layout-elem-rule.image-id-insen = f-image-id-insen
.
END PROCEDURE.
PROCEDURE set-value :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-param-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
FIND FIRST buf_tt-rule-call-param WHERE
    buf_tt-rule-call-param.call_id = p-call-id
AND buf_tt-rule-call-param.codex_id = p-codex-id
AND buf_tt-rule-call-param.ruleset_id = p-ruleset-id
AND buf_tt-rule-call-param.order_id = p-order-id
AND buf_tt-rule-call-param.param-name = p-param-name
AND buf_tt-rule-call-param.p-index = p-index.
assign
buf_tt-rule-call-param.param-value-character = p-value-character
buf_tt-rule-call-param.param-value-date      = p-value-date
buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
buf_tt-rule-call-param.param-value-integer   = p-value-integer
buf_tt-rule-call-param.param-value-logical   = p-value-logical
.
END PROCEDURE.
