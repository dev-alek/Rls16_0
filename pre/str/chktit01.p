block-level on error undo, throw.
define input-output parameter p-rid as recid no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input parameter p-doc-type as integer no-undo .
define input parameter p-chk-type like ub.chk-doc.chk-type no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input parameter p-chk-date like ub.chk-doc.chk-date no-undo .
define input parameter p-chk-time like ub.chk-doc.chk-time no-undo  .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define input parameter p-shift-name like ub.chk-doc.shift-name no-undo .
define input parameter p-pay-desk like ub.chk-doc.pay-desk no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input-output parameter p-cash-rate like ub.chk-doc.cash-rate no-undo .
define input parameter p-cashier like ub.chk-doc.cashier no-undo .
define input parameter p-sales-man like ub.chk-doc.sales-man no-undo .
define input parameter p-d-card like ub.chk-doc.d-card no-undo .
define input parameter p-chk-num like ub.chk-doc.chk-num no-undo .
define input parameter p-z-number like ub.chk-doc.z-number no-undo .
define input parameter p-PS like ub.chk-doc.PS no-undo .
define input parameter p-lines-exist as logical no-undo .
define input parameter r-b as character no-undo .
define input parameter cas-shft as logical no-undo .
define input parameter l-shift-on as logical no-undo .
define input parameter t-shft as integer no-undo .
define input parameter v-shft as integer no-undo .
define input parameter cas-curs as logical no-undo .
define input parameter hnum as logical no-undo .
define output parameter par-chk-type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chktit01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chktit01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в чеке МЦ".
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
DEFINE VARIABLE varcash-rate like ub.curr-shop.exch-rate no-undo .
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error return-value
:
varcash-rate = p-cash-rate.
if lookup(string(p-chk-type), '2,3,4,5,7':U) = 0 then do:
  message
  substitute("Неверный типа чека = &1", p-chk-type)
  view-as alert-box error .
  undo, return error .
end.
run trg/chktit02.p (
                input (if p-mode = 'ДОБАВЛЕНИЕ':U then yes else no)
               ,input p-doc-code
               ,input p-doc-type
               ,input p-host-code
               ,input p-obj-type
               ,input p-obj-code
               ,input p-chk-date
               ,input p-chk-time
               ,input p-shift-date
               ,input p-shift-num
               ,input p-shift-name
               ,input p-pay-desk
               ,input p-pos-type
               ,input-output varcash-rate
               ,input p-cashier
               ,input p-sales-man
               ,input p-d-card
               ,input p-z-number
               ,input p-PS
               ,input p-lines-exist
               ,input r-b
               ,input cas-shft
               ,input l-shift-on
               ,input t-shft
               ,input v-shft
               ,input cas-curs
               ,input hnum
            ) no-error.
if error-status:error then undo, return error return-value.
if return-value <> "":U then do:
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  FIND FIRST buf_chk-doc No-LOCK WHERE
            buf_chk-doc.obj-type = p-obj-type and
            buf_chk-doc.obj-code = p-obj-code and
            buf_chk-doc.chk-date = p-chk-date and
            buf_chk-doc.pay-desk = p-pay-desk and
            buf_chk-doc.chk-time = p-chk-time and
            buf_chk-doc.chk-num  = p-chk-num NO-ERROR .
  if avail buf_chk-doc and not recid(buf_chk-doc) = p-rid then do:
    message  substitute( "Уже есть чек МЦ&1магазин &2&1касса &3&1дата чека &4&1" +
                             "время чека &5&1номер чека на кассе &6"
                             ,p-obj-code
                             ,p-pay-desk
                             ,string(p-chk-date, "99/99/9999")
                             ,string(p-chk-time, "HH:MM")
                             ,p-chk-num )
    view-as alert-box error .
    undo, return error '':U.
  end.
end.
if p-lines-exist and
   not can-find (first ub.chk-pay No-LOCK WHERE
                       ub.chk-pay.doc-code = p-doc-code) then do:
  undo, return error substitute("В чеке МЦ &1 отсутствуют строки&2Сохранение невозможно"
                          , p-doc-code
                          , chr(10)).
end.
if p-mode = 'ДОБАВЛЕНИЕ':U and p-rid = ? then do:
  create buf_chk-doc.
  assign p-rid = recid(buf_chk-doc).
end.
else do:
  FIND FIRST buf_chk-doc EXCLUSIVE-LOCK WHERE
            recid(buf_chk-doc) = p-rid NO-WAIT No-ERROR.
  if locked buf_chk-doc then do:
    undo, return error substitute("Чек МЦ &1 занят", p-doc-code).
  end.
  if not avail buf_chk-doc then do:
    undo, return error substitute("Не найден чек МЦ &1", p-doc-code).
  end.
  if buf_chk-doc.out-code <> ? then do:
    undo, return error substitute("Чек МЦ &1&2Включен в документ&2Изменение невозможно"
                            ,p-doc-code
                            , chr(10)).
  end.
  if p-chk-type <> buf_chk-doc.chk-type AND
     can-find(first ub.chk-pay where ub.chk-pay.doc-code = buf_chk-doc.doc-code) then do:
    message vss-workfile vss-revision vss-description skip
    "Неверный вызов - с изменением типа чека МЦ"
    view-as alert-box error .
    undo, return error '':U.
  end.
end.
assign
buf_chk-doc.doc-code = p-doc-code
buf_chk-doc.obj-type = p-obj-type
buf_chk-doc.obj-code = p-obj-code
buf_chk-doc.chk-type = p-chk-type
buf_chk-doc.chk-date = p-chk-date
buf_chk-doc.chk-time = p-chk-time
buf_chk-doc.src-shift-date = p-shift-date
buf_chk-doc.shift-date = if t-shft < 0 AND buf_chk-doc.chk-time < abs(t-shft)
                      then (buf_chk-doc.chk-date - 1)
                      else (if buf_chk-doc.src-shift-date = ?
                            then buf_chk-doc.chk-date
                            else buf_chk-doc.src-shift-date)
buf_chk-doc.shift-num = p-shift-num
buf_chk-doc.shift-name = p-shift-name
buf_chk-doc.pay-desk = p-pay-desk
buf_chk-doc.cash-rate = if cas-curs then p-cash-rate else varcash-rate
buf_chk-doc.cashier = p-cashier
buf_chk-doc.sales-man = p-sales-man
buf_chk-doc.d-card = p-d-card
buf_chk-doc.chk-num = p-chk-num
buf_chk-doc.z-number = p-z-number
buf_chk-doc.ps = p-ps
buf_chk-doc.correct = yes
buf_chk-doc.office = ?
buf_chk-doc.out-code = ?
buf_chk-doc.tot-doc = 0
buf_chk-doc.netto = 0
buf_chk-doc.discnt = 0
buf_chk-doc.d-pcnt = 0
buf_chk-doc.src-d-pcnt = 0
buf_chk-doc.doc-qnty = 0
buf_chk-doc.src-tot-doc = 0
buf_chk-doc.src-d-mask = ''
buf_chk-doc.d-mask = ''
buf_chk-doc.d-card = ''
buf_chk-doc.src-d-card = ''
buf_chk-doc.src-cli-type = ?
buf_chk-doc.src-cli-code = ?
buf_chk-doc.cli-type = ?
buf_chk-doc.cli-code = ?
buf_chk-doc.doc-num2 = ?
buf_chk-doc.out-2-code = ?
.
if p-mode = 'ДОБАВЛЕНИЕ':U or p-rid <> ? then release buf_chk-doc no-error.
if error-status:error then undo, return error substitute("Ошибка при сохранения чека МЦ:&1&2&1&3", chr(10), error-status:get-message(1) , return-value ).
return '':U.
end.
