block-level on error undo, throw.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter pardoc-code like ub.chk-pay.doc-code no-undo .
define input parameter pardoc-type as integer no-undo .
define input parameter parchk-type like ub.chk-doc.chk-type no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter parchk-date like ub.chk-doc.chk-date no-undo .
define input parameter parchk-time like ub.chk-doc.chk-time no-undo .
define input parameter parpay-code like ub.chk-pay.pay-code no-undo .
define input parameter parcurr-code like ub.chk-pay.curr-code no-undo .
define input parameter parbase-code like ub.sysconf.base-code no-undo .
define input parameter r-b as character no-undo .
define input parameter parcas-curs as logical no-undo .
define input parameter parline-num like ub.chk-pay.line-num no-undo .
define input parameter parcash-rate as decimal no-undo .
define input parameter parbank-rate as decimal no-undo .
define input parameter parbank-scale as integer no-undo .
define input parameter par-sum as decimal no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkins01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkins01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке оплаты чека МЦ".
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
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE varopl-curs as decimal no-undo .
DEFINE VARIABLE varbase-curs as decimal no-undo .
define variable v-par-code as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-pay  for ub.chk-pay.
if NOT (par-mode = 'ДОБАВЛЕНИЕ':U OR par-mode = 'ИЗМЕНЕНИЕ':U) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.
FIND FIRST buf_chk-doc EXCLUSIVE-LOCK WHERE
           buf_chk-doc.doc-code = pardoc-code No-ERROR No-WAIT.
IF LOCKED buf_chk-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Запись шапки чека МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
end.
IF NOT available buf_chk-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Не найден чек МЦ" pardoc-code
  view-as alert-box error .
end.
if buf_chk-doc.out-code <> ? then do:
  message
  vss-workfile vss-revision vss-description skip
  "Чек МЦ имеет включен в документ" buf_chk-doc.out-code
 "добавление/изменение строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
run trg/chkins02.p (
                  input  pardoc-code
                 ,input  pardoc-type
                 ,input  parchk-type
                 ,input  parobj-type
                 ,input  parobj-code
                 ,input  parchk-date
                 ,input  parchk-time
                 ,input  parpay-code
                 ,input  parcurr-code
                 ,input  parbase-code
                 ,input  r-b
                 ,input  parcas-curs
                 ,input-output  parcash-rate
                 ,input-output  parbank-rate
                 ,input-output  parbank-scale
                 ,input  par-rid
                 ,output varbase-curs
                 ,output varopl-curs
                 ,output v-par-code
               ) no-error.
if error-status:error then return error.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  FIND FIRST buf_chk-pay NO-LOCK WHERE
            buf_chk-pay.doc-code    = pardoc-code   AND
            buf_chk-pay.line-num    = parline-num  NO-ERROR.
  IF AVAIL buf_chk-pay THEN DO:
    MESSAGE
    "Уже есть строка оплат с номером строки" parline-num "в чеке МЦ" pardoc-code
    VIEW-AS ALERT-BOX ERROR.
    var-entry = "line-num":U.
    RETURN ERROR var-entry.
  END.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U and par-sum = 0 then do:
  MESSAGE
  "Сумма МЦ по строчке чека равна 0 - строка " parline-num  "чек МЦ" pardoc-code
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "sum":U.
  RETURN ERROR var-entry.
end.
DO ON ERROR UNDO, return '':U
   On STOP UNDO, return '':U:
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    CREATE buf_chk-pay .
    assign
    buf_chk-pay.doc-code = pardoc-code
    buf_chk-pay.line-num = parline-num
    .
    assign par-rid = recid(buf_chk-pay).
  end.
  else do:
    FIND FIRST buf_chk-pay EXCLUSIVE-LOCK WHERE
              recid(buf_chk-pay) = par-rid No-WAIT No-ERROR.
    if locked buf_chk-pay then do:
      message "Строка чека МЦ занята"
      view-as alert-box error .
      return error '':U.
    end.
    if not avail buf_chk-pay then do:
      message "Не найдена строка чека МЦ"
      view-as alert-box error .
      return error '':U.
    end.
    if (buf_chk-pay.doc-code <> pardoc-code OR
      buf_chk-pay.pay-code <> parpay-code OR
      buf_chk-pay.curr-code <> parcurr-code OR
      buf_chk-pay.line-num <> parline-num OR
      buf_chk-pay.obj-type <> parobj-type OR
      buf_chk-pay.obj-code <> parobj-code ) then dO:
      message
      vss-workfile vss-revision vss-description skip
      "При редактировании чека МЦ"
      "возможно изменить только сумму и курсы валют"
      view-as alert-box ERROR.
      return error '':U.
    end.
  end.
assign
buf_chk-pay.doc-code = pardoc-code
buf_chk-pay.line-num = parline-num
buf_chk-pay.chk-date = buf_chk-doc.chk-date
buf_chk-pay.pay-code = parpay-code
buf_chk-pay.curr-code = parcurr-code
buf_chk-pay.obj-code = parobj-code
buf_chk-pay.obj-type = parobj-type
buf_chk-pay.pay-card = ''
buf_chk-pay.cash-rate = parcash-rate
buf_chk-pay.bank-rate = parbank-rate
buf_chk-pay.bank-scale = parbank-scale
buf_chk-pay.time-oper = (if par-mode = 'ДОБАВЛЕНИЕ':U then parchk-time else buf_chk-pay.time-oper )
buf_chk-pay.tot-sum = par-sum
buf_chk-pay.tot-rubl = 0
buf_chk-pay.tot-base = 0
buf_chk-pay.out-code = ?
.
return '':U.
END.
