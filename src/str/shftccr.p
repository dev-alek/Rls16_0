block-level on error undo, throw.
/*

$Revision: 82660c506036, 2990, rls $
$Author: DRuban $
$Date: Ср апр 06 16:23:43 2022 +0300 $
$Workfile: shftccr.p $
$Archive: str/shftccr.p $

Создание открытия кассовой смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/06
Author: Bakhtadze Natalya
Creation date: 01/19/06

*/

DEFINE INPUT PARAMETER p-obj-type   like ub.shift-cash.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code   like ub.shift-cash.obj-code no-undo.
DEFINE INPUT PARAMETER p-cash-num   like ub.cash-desk.cash-num no-undo.
DEFINE INPUT PARAMETER p-shift-date like ub.shift-cash.shift-date no-undo.
DEFINE INPUT PARAMETER p-shift-num  like ub.shift-cash.shift-num no-undo.
/*номер как ввели на кассе*/
DEFINE INPUT PARAMETER p-src-shift-name like ub.shift-cash.z-status no-undo.
/*номер в BO то что привзяан к shift-obj*/
DEFINE INPUT PARAMETER p-shift-name like ub.shift-cash.z-status no-undo.
define input parameter p-shift-open-time as integer no-undo .
DEFINE INPUT PARAMETER v-z-num      like ub.shift-cash.z-num no-undo.
DEFINE INPUT PARAMETER act-mess     as character no-undo.
DEFINE OUTPUT PARAMETER v-recid     as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision: 82660c506036, 2990, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:43 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shftccr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/shftccr.p $":U .
define variable vss-description as character no-undo init "Создание записи кассовой смены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/getcshft.i }

define variable v-src-shift-name as character no-undo .
define variable v-shift-name as character no-undo .

define buffer buf_shift-cash for ub.shift-cash.
do
on error undo, return error
:
  if p-shift-num = ? THEN DO:
    IF P-SHIFT-NAME <> ? then do:
      run get-shift-num  in this-procedure (
                                            input  p-obj-type
                                            ,input  p-obj-code
                                            ,input  p-shift-date
                                            ,input  p-shift-name
                                            ,output p-shift-num ) no-error .
      if p-shift-num = 0 then return error substitute("Не удалось определить порядок смены:&1&2&3 смена от &4 № смены &5"
                                                , p-obj-type
                                                , p-obj-code
                                                , {&new-line}
                                                , p-shift-date
                                                , p-shift-name) .
    end.
  END.
  FIND FIRST buf_shift-cash No-LOCK WHERE
            buf_shift-cash.obj-type = p-obj-type
        AND buf_shift-cash.obj-code = p-obj-code
        AND buf_shift-cash.cash-num = p-cash-num
        AND buf_shift-cash.shift-date = p-shift-date
        AND buf_shift-cash.shift-num = p-shift-num  No-ERROR.
  if not available buf_shift-cash
  and p-shift-name <> ?
  and p-src-shift-name = ?
  then do:
    /*на кассе открылась раньше чем в BO - сейчас открываем в BO*/
    _shift-cash:
    for each buf_shift-cash no-lock where
            buf_shift-cash.obj-type = p-obj-type
        and buf_shift-cash.obj-code = p-obj-code
        AND buf_shift-cash.cash-num = p-cash-num
        AND buf_shift-cash.shift-date = p-shift-date
        AND buf_shift-cash.shift-num = 0:
      if buf_shift-cash.status_ =  {&sht-closed} then NEXT _shift-cash.
      if buf_shift-cash.src-shift-name = p-shift-name
      and v-shift-name = '':U
      then do:
        LEAVE _shift-cash.
      end.
    end.
    if available buf_shift-cash then do:
      find current buf_shift-cash exclusive-lock .
      assign
      buf_shift-cash.shift-name = p-shift-name
      buf_shift-cash.shift-num = p-shift-num
      v-recid = recid(buf_shift-cash).
      .
      run process-all-check in this-procedure ( input p-shift-date
                                              , input p-shift-name
                                              , input p-shift-num) no-error.
      return.
    end.
  end.
  if act-mess                   ne {&receipt-in}
  then
     run process-all-check in this-procedure ( input p-shift-date
                                             , input p-shift-name
                                             , input p-shift-num) no-error.
  if avail buf_shift-cash then do:
    if buf_shift-cash.status_ = {&sht-closed}
    AND not act-mess = {&cash-desk-on}
    and (p-src-shift-name = ?
        or p-src-shift-name = buf_shift-cash.src-shift-name)
    then do:
        v-recid = recid(buf_shift-cash).
/*        return error.*/
          return. /*по треб назаркиной */
    end.
    else do:
      assign
      v-src-shift-name = buf_shift-cash.src-shift-name
      v-shift-name = buf_shift-cash.shift-name
      v-recid = recid(buf_shift-cash).
      if (p-shift-name <> ?
      and p-shift-name <> v-shift-name ) then do:
        find current buf_shift-cash exclusive-lock .
        assign
        v-shift-name      = (if p-shift-name <> ?
                              then p-shift-name
                              else v-shift-name)
        .
        assign
        buf_shift-cash.shift-name = v-shift-name
        buf_shift-cash.src-shift-name = v-src-shift-name
        .
        return.
      end.
    end.
  end.
  find first buf_shift-cash no-lock where
          buf_shift-cash.obj-type = p-obj-type
     and buf_shift-cash.obj-code = p-obj-code
     and buf_shift-cash.cash-num = p-cash-num
     and buf_shift-cash.z-num = v-z-num
     and buf_shift-cash.shift-date = p-shift-date
     and buf_shift-cash.shift-num = p-shift-num
     and buf_shift-cash.src-shift-name = (if p-src-shift-name <> ? then p-src-shift-name else '')
     no-error .

  if available buf_shift-cash then do:
     if p-src-shift-name <> ?
     and buf_shift-cash.opened = {&receipt-in}
     and buf_shift-cash.shift-open-time > p-shift-open-time then do:
       assign
       v-recid = recid(buf_shift-cash).
       find current buf_shift-cash exclusive-lock .
       assign
       buf_shift-cash.shift-open-time = p-shift-open-time
       .
     end.
     return.
  end.
  return-value = '':U.
  find first buf_shift-cash no-lock where
          buf_shift-cash.obj-type = p-obj-type
      and buf_shift-cash.obj-code = p-obj-code
      and buf_shift-cash.cash-num = p-cash-num
      and buf_shift-cash.shift-date = p-shift-date
      and buf_shift-cash.shift-num = (if p-shift-num = ? then 0 else p-shift-num)
      and buf_shift-cash.src-shift-name = (if p-src-shift-name <> ? then p-src-shift-name else '') no-error .
 if not available buf_shift-cash then do:
    create buf_shift-cash.
    assign
    buf_shift-cash.obj-type = p-obj-type
    buf_shift-cash.obj-code = p-obj-code
    buf_shift-cash.cash-num = p-cash-num
    buf_shift-cash.z-num = v-z-num
    buf_shift-cash.shift-date = p-shift-date
    buf_shift-cash.shift-num = (if p-shift-num = ? then 0 else p-shift-num)
    buf_shift-cash.src-shift-name = (if p-src-shift-name <> ? then p-src-shift-name else '')
    buf_shift-cash.shift-name = (if p-shift-name <> ? then p-shift-name else '')
    buf_shift-cash.shift-open-time = (if p-shift-open-time <> ? then p-shift-open-time else buf_shift-cash.shift-open-time)
    buf_shift-cash.sale-date = buf_shift-cash.shift-date
    buf_shift-cash.status_ = {&sht-current}
    buf_shift-cash.opened = act-mess
    v-recid = recid(buf_shift-cash)
    no-error
    .
    if error-status:error then do:
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    release buf_shift-cash no-error.
    if error-status:error then do:
    v-recid = ?.
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
  end.
  else do:
    if      buf_shift-cash.opened     ne {&receipt-in}
       and act-mess                   eq {&receipt-in}
    then do:
       find current buf_shift-cash exclusive-lock.
       assign
          buf_shift-cash.opened = act-mess
          buf_shift-cash.shift-open-time = (if p-shift-open-time <> ? then p-shift-open-time else buf_shift-cash.shift-open-time)
       .
    end.
    v-recid = recid(buf_shift-cash).
  end.
end. /*doe*/

procedure process-all-check :
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-name as character no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define buffer buf_chk-doc for ub.chk-doc.

  do
  on error undo, return error
  :
  _chk-doc:
  for each buf_chk-doc Exclusive-lock where
          buf_chk-doc.obj-type = p-obj-type
      and buf_chk-doc.obj-code = p-obj-code
      and buf_chk-doc.shift-date = p-shift-date
      and buf_chk-doc.shift-num = 0
      and (buf_chk-doc.out-code = ? or buf_chk-doc.out-code = '':U)
   on error undo, next _chk-doc
   on stop undo, next _chk-doc:
      if buf_chk-doc.src-shift-name = p-shift-name then do:
        assign
        buf_chk-doc.shift-num = p-shift-num
        buf_chk-doc.shift-name = p-shift-name
        buf_chk-doc.office = replace(buf_chk-doc.office, {&shift-err}, '':U)
        buf_chk-doc.office = replace(buf_chk-doc.office, {&comma-char} + {&comma-char}, {&comma-char})
        buf_chk-doc.office = trim(buf_chk-doc.office, {&comma-char})
        buf_chk-doc.correct = (if buf_chk-doc.office = {&gds-goods}
                               or buf_chk-doc.office = {&gds-office}
                               then yes
                               else no)
        .
      end.
    end.
  end.

end procedure. /* process-all-check */