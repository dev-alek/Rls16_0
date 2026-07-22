block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур проверки валидности чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/17/08
Author: Bakhtadze Natalya
Creation date: 07/17/08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур проверки валидности чека".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/libchkvl.i }
{ gbl/getsect.i def }
{ str/pos_context.i temp-table libchkvl_context  }

{ str/t-gds.i def chk }
{ str/t-pay.i def chk }
{ str/t-wth.i def chk }
{ str/libbcrcn.i      }
{ ref/chdcmask.i }
{ ref/chdcclim.i }
{ str/getcshft.i libchkvl_ }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */

{ str/pos_context.i dis-card-mask libchkvl_ }
{ str/cspromo-chk.i } /* функции для работы с промоакциями по НП */



define variable log-file-name as character no-undo init "get-chkf.log".
define variable log-file-name0 as character no-undo init "get-chkf.log".

if valid-handle (g#libchkvl)
and g#libchkvl <> this-procedure :handle
and g#libchkvl :get-signature('libchkvl_get-dc-mask-array ':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для проверки валидности чека" skip
    g#libchkvl skip
    g#libchkvl :type skip
    g#libchkvl :file-name skip
    valid-handle(g#libchkvl) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libchkvl = this-procedure :handle
  .
end.


on delete of this-procedure do:

  assign
    g#libchkvl = ?
  .
end. 
        

procedure libchkvl_get-dc-mask-array :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_libchkvl_dis-card-mask for libchkvl_dis-card-mask.
for each buf_libchkvl_dis-card-mask:
  delete buf_libchkvl_dis-card-mask.
end.
_maska:
for each buf_dis-card-mask no-lock where
    buf_Dis-card-mask.stts              = integer({&current-status-int})
by buf_Dis-card-mask.host-code
by buf_Dis-card-mask.obj-type
by buf_Dis-card-mask.obj-code
by buf_Dis-card-mask.rank
:
  if buf_dis-card-mask.host-code <> 0
  And buf_dis-card-mask.host-code <> p-host-code then next _maska.
  if (buf_dis-card-mask.obj-type <> "":U
  AND buf_dis-card-mask.obj-type <> p-obj-type)
  or (buf_dis-card-mask.obj-code <> 0
  and buf_dis-card-mask.obj-code <> p-obj-code)
  then NEXT _maska.
  if buf_dis-card-mask.use-on = integer({&dcm-only-cd}) then NEXT _Maska.
  create buf_libchkvl_dis-card-mask.
  buffer-copy buf_dis-card-mask to
  buf_libchkvl_dis-card-mask.
end. /*for each _maska*/
end.

function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer):
if p-chk-type > 200 then p-chk-type = p-chk-type - 100.
if p-chk-type > 100 then p-chk-type = p-chk-type - 100.
case p-chk-type:
  when integer({&rcpt-sale})
  or
  when integer({&rcpt-ord-sale})
  or
  when integer({&cd-fund})
  or
  when integer({&cd-drawer})
    then do:
    return 1.
  end.
  when integer({&rcpt-return})
  or
  when integer({&rcpt-return-write-off})
  or
  when integer({&rcpt-ord-return})
  or
  when integer({&encashment})
  or
  when integer({&cd-expense})
  then do:
    return -1.
  end.
  when integer({&rcpt-annu})
  or
  when integer({&rcpt-ord-annu})
  or
  when integer({&rcpt-inventory})
  or
  when integer({&rcpt-z-rep})
  or
  when integer({&rcpt-write-off})
  or
  when integer({&rcpt-trans-cancell})
  or
  when integer({&rcpt-overflow})
  or
  when integer({&rcpt-trans-transfer})
  or
  when integer({&rcpt-tech-refuell})
  or
  when integer({&rcpt-shft-close})
  or
  when integer({&rcpt-shft-open})
  or
  when integer({&pay-transfer})
  then do:
    return 0.
  end.
end case.
end function.



FUNCTION libchkvl_direct-sign returns logical ( input p-chk-type as integer
                                               ,input p-qnty as decimal):
/*todo*/
return yes.
end.


procedure libchkvl_get-cash-shift :
define input parameter p-context-bh as handle no-undo .
define parameter buffer buf_shift-cash for ub.shift-cash.
define input parameter p-cash-num as integer no-undo .

define input parameter p-shift-date as date no-undo .
define input parameter p-shift-name as character no-undo .
define input parameter p-z-number as integer no-undo .
define input parameter p-chk-date as date no-undo .
define input parameter p-chk-time as integer no-undo .
define input parameter p-shift-open-time as integer no-undo .


DEFINE VARIABLE current-cas-shift-num      as   integer               no-undo .
DEFINE VARIABLE current-cas-shift-name     as   character             no-undo .
DEFINE VARIABLE current-cas-shift-date     as   date                  no-undo .
DEFINE VARIABLE current-cas-shift-status_  as   char                  no-undo .
DEFINE VARIABLE current-shift-status_      as   character             no-undo init {&sht-current}.
define variable vrecid as recid no-undo .

{ str/pos_context.i "vars" v- }
&scop prefix v-


define buffer buf_shift-obj for ub.shift-obj.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  { str/pos_context.i "vars=temp-table" v- p-context-bh:: }

  if {&prefix}p-log-file-name <> ""
  or {&prefix}p-log-file-name <> ? then do:
    log-file-name = {&prefix}p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.

  if {&prefix}shift-on then do:
  /*если пришел чек от новой кассы  или чек с новой сменой
  ищем запись о кассовой смене для данного чека*/
    _sc:
    for each  buf_shift-cash Exclusive-LOCK WHERE
              (buf_shift-cash.obj-type = {&prefix}obj-type
          AND buf_shift-cash.obj-code = {&prefix}obj-code
          AND buf_shift-cash.cash-num = p-cash-num
          AND buf_shift-cash.shift-date = p-shift-date
          AND buf_shift-cash.src-shift-name = p-shift-name)
      or
              (buf_shift-cash.obj-type = {&prefix}obj-type
          AND buf_shift-cash.obj-code = {&prefix}obj-code
          AND buf_shift-cash.cash-num = p-cash-num
          AND buf_shift-cash.shift-date = p-shift-date
          AND buf_shift-cash.shift-name = p-shift-name) :

      if BUF_shift-cash.src-shift-name = p-shift-name
      or BUF_shift-cash.shift-name = p-shift-name
      then do:
        /*это первый чек по смене -мы уже читали*/
        IF buf_shift-cash.shift-date = p-chk-date
        and BUF_shift-cash.shift-open-time = p-chk-time
        and BUF_shift-cash.src-shift-name = p-shift-name
        and p-z-number = ?
        and buf_shift-cash.opened = {&receipt-in}
        then  do:
          LEAVE _sc.
        end.
        /*эту смену мы уже закрыли*/
        IF BUF_shift-cash.shift-close-date = p-chk-date
        and BUF_shift-cash.shift-close-time = p-chk-time
        and (BUF_shift-cash.src-shift-name = p-shift-name
            or
            (BUF_shift-cash.shift-name = p-shift-name
            and
            buf_shift-cash.opened <> {&receipt-in})
            or
            (BUF_shift-cash.shift-name = p-shift-name
            and
            BUF_shift-cash.src-shift-name <> p-shift-name)
          )
        and (p-z-number <> ?
            and
            buf_shift-cash.status_ = {&sht-closed})
        then  do:
          LEAVE _sc.
        end.
        if buf_shift-cash.opened <> {&receipt-in}
        and buf_shift-cash.shift-num <> ? then do:
          find first buf_shift-obj no-lock where
                    buf_shift-obj.obj-type = {&prefix}obj-type
                AND buf_shift-obj.obj-code = {&prefix}obj-code
                AND buf_shift-obj.shift-date = buf_shift-cash.shift-date
                and buf_shift-obj.shift-num = buf_shift-cash.shift-num No-ERROR.
          if available buf_shift-obj and
          buf_shift-obj.status_ = {&fact} then next _sc.
        end.
        /*кажется набрели на нужную*/
        leave _sc.
      end.
    end.
  
     /*если в БО есть запись о кассовой смене запоминаем в переменные чтобы сравнива
     с этими переменными последующие приходящие чеки мы отследили когда придет чек со
     сменой, о которой мы не знаем*/
     IF AVAIL buf_shift-cash
     and buf_shift-cash.shift-num <> 0
     and buf_shift-cash.shift-num <> ?
     and buf_shift-cash.opened eq {&receipt-in}
     then
     assign
     current-cas-shift-num  = buf_shift-cash.shift-num
     current-cas-shift-name = p-shift-name
     current-cas-shift-date = buf_shift-cash.shift-date
     current-cas-shift-status_ = buf_shift-cash.status_
     .
     else do:
       /*если нет записи о кассовой смене - то создаем ее с текущим статусом*/
       run str/shftccr.p (
                        input {&prefix}obj-type
                       ,input {&prefix}obj-code
                       ,input p-cash-num
                       ,input p-shift-date
                       ,input (if not {&prefix}shift-on then ? else p-shift-name)
                       ,input p-shift-name
                       ,input (if not {&prefix}shift-on then ? else integer(p-shift-name))
                       ,input (if p-z-number <> ?
                               then p-shift-open-time
                               else (if p-chk-date = p-shift-date then p-chk-time else ?)
                               )
                       ,input p-z-number
                       ,input {&receipt-in}
                       ,output vrecid) no-error.
       if error-status:error then do:
         if valid-handle( {&prefix}p-log-handle) then do:
           run write-log-and-file in {&prefix}p-log-handle (
                 input 1
               , input log-file-name
               , input 1
               , input substitute( "!!!Произошла ошибка при попытке создания записи кассовой смены для кассы &1: смена N&2 за &3"
                                   , p-cash-num
                                   , p-shift-name
                                   , string(p-shift-date, "99/99/9999")
                                 )
                                                 ).
           {&prefix}view-log = yes.
         end.
       end.
       else do:
         FIND FIRST buf_shift-cash WHERE recid(buf_shift-cash) = vrecid.
         assign
         current-cas-shift-name = p-shift-name
         current-cas-shift-num = buf_shift-cash.shift-num
         current-cas-shift-date = p-shift-date
         current-cas-shift-status_ = {&sht-current}
         .
       end.
     end.
     if avail buf_shift-cash then do:
       /*включены глобальные смены на объекте*/
       if {&prefix}shift-on then do:
         if current-cas-shift-num  = ? then do:
           run libchkvl_get-shift-num  in this-procedure (
                                                  input  {&prefix}obj-type
                                                 ,input  {&prefix}obj-code
                                                 ,input  current-cas-shift-date
                                                 ,input  current-cas-shift-name
                                                 ,output current-cas-shift-num ) no-error .
         end.
         if current-cas-shift-num <> ? then do:
           FIND FIRST buf_shift-obj NO-LOCK WHERE
                       buf_shift-obj.obj-type = {&prefix}obj-type AND
                       buf_shift-obj.obj-code = {&prefix}obj-code AND
                       buf_shift-obj.shift-date = current-cas-shift-date AND
                       buf_shift-obj.shift-num = current-cas-shift-num No-ERROR.
         end.
         else release buf_shift-obj.
         if avail buf_shift-obj then
         current-shift-status_ = buf_shift-obj.status_.
         /*если нет записи о смене объекта считаем что БО просто опаздывает 0 торговля на кассах началась*/
         else
         current-shift-status_ = {&sht-current}.
       end.
       if p-z-number <> ?  then do:
         /*пришел чек закрытия смены - закроем кассовую смену в БО*/
         assign
         buf_shift-cash.status_ = {&sht-closed}
         buf_shift-cash.z-num = p-z-number
         buf_shift-cash.closed = {&receipt-in}
         buf_shift-cash.shift-num = (if buf_shift-cash.shift-num = ?
                                 and not can-find(first ub.shift-cash where
                                                       ub.shift-cash.obj-type = buf_shift-cash.obj-type
                                                   and  ub.shift-cash.obj-code = buf_shift-cash.obj-code
                                                   and  ub.shift-cash.cash-num = current-cas-shift-num
                                                   and  ub.shift-cash.shift-date = buf_shift-cash.shift-date
                                                   and  ub.shift-cash.shift-num = buf_shift-cash.shift-num
                                                   and  ub.shift-cash.src-shift-name = buf_shift-cash.src-shift-name
                                                   and  recid(ub.shift-cash) <> recid(buf_shift-cash)
                                                   )
                                 then current-cas-shift-num
                                 else buf_shift-cash.shift-num)
         buf_shift-cash.shift-name = if buf_shift-cash.shift-num <> ?
                                     then current-cas-shift-name
                                     else buf_shift-cash.shift-name
         buf_shift-cash.shift-open-time  = (if buf_shift-cash.shift-open-time > p-shift-open-time
                                             then p-shift-open-time
                                             else buf_shift-cash.shift-open-time)
         buf_shift-cash.shift-close-date = (if buf_shift-cash.shift-close-date = ?
                                             or buf_shift-cash.shift-close-date < p-chk-date
                                             then p-chk-date
                                             else buf_shift-cash.shift-close-date)
         buf_shift-cash.shift-close-time = (if buf_shift-cash.shift-close-time = 0
                                             or (buf_shift-cash.shift-close-date = p-chk-date
                                                 and
                                                 buf_shift-cash.shift-close-time < p-chk-time)
                                             then p-chk-time
                                             else buf_shift-cash.shift-close-time)
         .
       end.
     end. /*if avail shift-cash*/
  end. /*p-shift-on*/
end.

end procedure. /* libchkvl_get-cash-shift */


procedure libchkvl_chk-gds-wro :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-src-qnty as decimal no-undo .
define input parameter p-wro-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .

main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  if (p-wro-code <> ?
      and p-wro-code <> 0 )
      or
    p-chk-type = integer({&rcpt-return-write-off})
    or
    p-chk-type = integer({&rcpt-write-off})
    then do:

    if (lookup(string(p-chk-type), {&sale-out-receipt-codes}) > 0
    and p-wro-code < 0)
    or 
    (lookup(string(p-chk-type), {&sale-in-receipt-codes}) > 0
    and p-wro-code > 0 and p-src-qnty <> 0)
    or
    (p-chk-type = integer({&rcpt-return-write-off})
    and (p-wro-code = 0
        or
        p-wro-code = ?)
      )
    or
    (p-chk-type = integer({&rcpt-write-off})
    and (p-wro-code = 0
        or
        p-wro-code = ?)
      )
    then do:

    &scop receipt-code string(p-chk-type)
    &scop wro-code string(if p-wro-code <> ? then p-wro-code else 0 )
      p-mess = substitute("&1В товарной строке №&2 тип списания &3 не соответствует типу чека&4 &1"
                            , {&new-line}
                            , p-line-num
                            , {&wro-name}
                            , {&receipt-name}
                          ).
    end.
    else do:
      p-valid = yes.
    end.
  end.
  else do:
    p-valid = yes.
  end.
end. /*doe*/

end procedure. /* libchkvl_chk-gds-wro */


procedure libchkvl_unit-type-qnty :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-unit-type as character no-undo .
define input parameter p-unit-cli-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-src-qnty as decimal no-undo .
define input parameter p-min-rate as decimal no-undo .
define input parameter p-max-rate as decimal no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  if LOOKUP( {&serial}, p-unit-type ) > 0  AND abs(p-src-qnty) <> 1 then do:
    p-mess = p-mess + {&new-line} + substitute("Товар по коду &1 - серийный, кол-во должно быть=1", p-src-code).
    p-chr-err = p-chr-err + {&comma-char} + {&serial-err}.
  end.
  if LOOKUP( {&serial}, p-unit-type ) > 0
  AND ( p-in-code = "" ) then do:
    p-mess =  substitute("Товар по коду &1 нельзя продавать БЕЗ учета серийного номера"
                        , p-src-code  ).
    p-chr-err = p-chr-err + {&comma-char} + {&serial-err}.
  end.
  if (LOOKUP( {&serial}, p-unit-type ) > 0
  OR LOOKUP( {&twounit}, p-unit-type ) > 0 )
  AND NOT libchkvl_direct-sign(p-chk-type, p-src-qnty)
   then do:
    p-mess =  substitute("Не может быть строки аннуляции или отмены для товара по коду &2 с типом единицы измерения &1"
                        , p-unit-type
                        ,p-src-code).
    p-chr-err = p-chr-err + {&comma-char} + (if LOOKUP( {&serial}, p-unit-type ) > 0
                                             then {&serial-err}
                                             else {&amount-err}).
  end.
  /*проверка соответствия количества (кратности веса) 1 штуке*/
  if lookup({&twounit}, p-unit-type) > 0  and (p-min-RATE = 0 or p-max-RATE = 0 )  then do:
    p-mess = substitute("Товар по коду &1 в справочнике имеет неверные значения полей КОЛИЧЕСТВО ДРОБНОГО В ШТУКЕ"
                         , p-src-code).
    p-chr-err = p-chr-err + {&comma-char} + {&amount-err}.
  end.
  if (lookup({&twounit}, p-unit-type) > 0 AND (abs(p-src-qnty) < p-min-RATE or abs(p-src-qnty) > p-max-RATE)) OR
      (lookup({&altunit}, p-unit-type) > 0 AND NOT abs(p-src-qnty) = 1) then do:
    p-mess =  substitute("Товар по коду &1 не может быть продан с несоответствием количеств по основной и дополнительной единицам измерения"
                         , p-src-code ).

    p-chr-err = p-chr-err + {&comma-char} + {&amount-err}.
  end.
  p-chr-err = trim(p-chr-err, {&comma-char}).
  if p-chr-err = "" then
  p-valid = yes.
end. /*doe*/

end procedure. /* libchkvl_unit-type-qnty */


procedure libchkvl_part-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-unit-type as character no-undo .
define input parameter p-unit-cli-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-part-code as character no-undo .
define input parameter p-cashparts as logical no-undo .
define input parameter p-src-qnty as decimal no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:


  if LOOKUP({&serial}, p-unit-type) = 0 then do:
    if p-cashparts and p-in-code = "" then do:
      p-mess = substitute("Партионный товар по коду &1 не может быть продан БЕЗ учета N партии"
                          , p-src-code).
      p-chr-err = p-chr-err + {&comma-char} + {&prt-err} .
    end.
    if NOT p-cashparts AND NOT (p-in-code = "" AND p-part-code = "") then do:
      p-mess = substitute("НЕПартионный товар по коду &1 не может быть продан по коду партии"
                              , p-src-code
                            ) .
      p-chr-err = p-chr-err + {&comma-char} + {&prt-err}.
    end.
  end. /*if LOOKUP({&serial}, units.type) = 0 then do:*/
  if lookup(p-unit-type, {&pieces}) > 0
  AND ( p-src-qnty - TRUNCATE( p-src-qnty , 0 ) <> 0) then do:
     p-mess =substitute("Штучный товар по коду &1 не может быть продан с дробным количеством"
                        , p-src-code
                            ).
    p-chr-err = p-chr-err + {&comma-char} + {&amount-err}.
  end.
  p-chr-err = trim(p-chr-err, {&comma-char}).
  if p-chr-err = "" then
  p-valid = yes.
end. /*doe*/

end procedure. /* libchkvl_part-valid */


procedure libchkvl_prt-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-doc-prt as logical no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-empty-scale as logical no-undo .
define input parameter p-root-node-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:


  if p-doc-prt then do: /* есть разбиение по признакам */
    if not p-empty-scale
    AND  can-find( first ub.gds-prt where ub.gds-prt.upper-code = p-node-code ) then do:
      p-mess = substitute("Товар по коду &1 не может быт продан БЕЗ признаков"
                         , p-src-code
                            ).
      p-chr-err = p-chr-err  + {&comma-char} + {&dtl-err}.
    end.
  end.
  else do:
    if p-root-node-code <> p-node-code then do:
      p-mess = substitute("Товар по коду &1 не может быть продан c признаками на объекте, где они выключены"
                          , p-src-code
                            ) .
      p-chr-err = p-chr-err + {&comma-char}  + {&dtl-err}.
    end.
  end.
  p-chr-err = trim(p-chr-err, {&comma-char}).
  if p-chr-err = "" then
  p-valid = yes.
end.

end procedure. /* libchkvl_prt-valid */


procedure libchkvl_fbr-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-is-catering as logical no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-src-price as decimal no-undo .
define input parameter p-src-discnt as decimal no-undo .
define input parameter p-write-off-code as integer no-undo .
define input-output parameter p-depart-type as character no-undo .
define input-output parameter p-depart-code as integer no-undo .
define output parameter p-null-price as logical no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .

define variable v-depart-code as integer no-undo .
define variable v-depart-type as character no-undo .

define variable v-modificator-null-price as logical no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-is-catering
  and (
     p-pos-type = {&cd-type-MAGIA-XML}
  or p-pos-type = {&cd-type-ibm}
  or p-pos-type = {&cd-type-ibm-xml}
  or p-pos-type = {&cd-type-r-keeper}
  or p-pos-type = {&cd-type-ibs-th}
  or p-pos-type = {&cd-type-ncr-as-r}

  )
  then do:
    find first buf_fbr-gds-obj no-lock where
                buf_fbr-gds-obj.obj-type = p-obj-type
            AND buf_fbr-gds-obj.obj-code = p-obj-code
            AND buf_fbr-gds-obj.gds-code = p-gds-code no-error .
    if p-depart-code > 0 then v-depart-code = p-depart-code.
    else do:  
      
      if available buf_fbr-gds-obj
      AND (buf_fbr-gds-obj.is-menu
           or
           buf_fbr-gds-obj.is-semi-finished)
      then do:
/*          if p-pos-type = {&cd-type-IBM}      */
/*          or p-pos-type = {&cd-type-IBM-XML}  */
/*          or p-pos-type = {&cd-type-IBS-TH}   */
/*          or p-pos-type = {&cd-type-ncr-as-r} */
/*          or p-pos-type = {&cd-type-MAGIA-XML}*/
/*          then do:                            */
            assign
            v-depart-code = buf_fbr-gds-obj.fbr-obj-code
            v-depart-type = {&shop}
            .
/*          end.*/
          
      
          if v-depart-code = ?
          or v-depart-code = 0  then do:
            p-mess = substitute("Произведенный товар по кодом &1 продан без ссылки  на ОБЪЕКТ  ПРОИЗВОДСТВА (кухню)"
                                , p-src-code
                                  ) .
            p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.
          end.
      end.
    end.
    if available buf_fbr-gds-obj
    and (buf_fbr-gds-obj.is-modificator
        and
        buf_fbr-gds-obj.is-null-price) then do:
      assign
      v-modificator-null-price = yes.
    end.
    else  do:
      assign
      v-modificator-null-price = no.
    end.
    &scop wro-code STRING(if p-write-off-code <> ? then p-write-off-code else 0)
    if {&wro-is-modificator} then do:
      if not v-modificator-null-price then do:
        p-mess = substitute("Указанный в чеке товар-модификатор по коду &1 с 0 ценой (&2) не имеет соответствующих признаков в атрибутах РЕСТОРАН &3&4"
                            , p-src-code
                            ,p-obj-type
                            ,p-obj-code
                              ) .
        p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.
      end.
      if p-src-price <> 0
      or p-src-discnt <> 0 then do:
        p-mess = substitute("Указанный в чеке товар-модификатор по коду &1 с 0 ценой (&2) имеет в чеке НЕНУЛЕВУЮ ЦЕНУ &4 или СКИДКУ &5"
                            , p-src-code
                            ,p-obj-type
                            ,p-obj-code
                              ) .
        p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.
      end.
    end.
  end.
  else do: /*if p-is-catering*/
    assign
    v-depart-code = 0
    v-depart-type = ''
    .
  end.
  if v-depart-code <> ? and
      v-depart-code <> 0
  and v-depart-code <> p-obj-code    then do:
    find first buf_shop no-lock where
              buf_shop.obj-code = v-depart-code no-error .
    if not available buf_shop then do:
      assign
      v-depart-code = 0
      p-mess = substitute("Не найдена кухня &1&2, произведшая товар  с кодом &3"
                          ,{&shop}
                          ,p-obj-code
                          ,p-src-code
                            ) .
      p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.
    end.
    else do:
      assign
      v-depart-code = (if v-depart-code = ? then 0 else v-depart-code)
      v-depart-type = {&shop}
      .
    end.
  end.
  
  if p-src-price = 0
  and not {&wro-is-modificator}
  and not v-modificator-null-price
  and not p-chk-type = integer({&rcpt-inventory})
  and not p-pos-type = {&cd-type-autotank}
  and not p-pos-type = {&cd-type-ibm-xml}
  and not p-pos-type = {&cd-type-ibm}
  and not p-pos-type = {&cd-type-magia-xml}
  then do:
    p-mess = substitute("Товар с кодом &1: цена = 0"
                        ,p-src-code
                          ) .
    p-chr-err = p-chr-err + {&comma-char}  + {&summa-err}.
  end.
  assign
  p-depart-code = v-depart-code
  p-depart-type = v-depart-type
  p-chr-err = trim(p-chr-err, {&comma-char}).
  if p-chr-err = "" then
  p-valid = yes.


end. /*doe*/

end procedure. /* libchkvl_fbr-valid */



procedure libchkvl_place-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-loc1 as character no-undo .
define input parameter p-src-pl-code as integer no-undo .
define output parameter p-pl-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .

define variable v-loc1-setted as logical no-undo .
define variable v-src-pl-code-setted as logical no-undo .
define buffer buf_place for ub.place.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  assign
  v-loc1-setted = p-loc1 <> '':U
                  and
                  p-loc1 <> ?
  v-src-pl-code-setted = p-src-pl-code <> ?
                          and
                          p-src-pl-code <> 0
  .
  if v-loc1-setted
  or v-src-pl-code-setted then do:
    find first buf_place no-lock where
              buf_place.obj-type = p-obj-type
          and buf_place.obj-code = p-obj-code
          and (buf_place.loc1 = p-loc1 or not v-loc1-setted)
          and (buf_place.pl-code = p-pl-code or not v-src-pl-code-setted)
    no-error.
    if not available buf_place then do:
      p-mess = substitute("Товар с кодом &1: указано неверное складское место &2 или резервуар &3"
                          ,p-src-code
                          ,p-loc1
                          ,p-src-pl-code
                            ) .
      p-chr-err = p-chr-err + {&comma-char}  + {&amount-err}.
    end.
    else do:
       p-pl-code = buf_place.pl-code.
    end.
  end.
  if p-chr-err = "" then
  p-valid = yes.
  end. /*doe*/
end procedure. /* libchkvl_fbr-valid */

procedure libchkvl_petrol-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-unit-type as character no-undo .
define input parameter p-pump as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup(string(p-chk-type), {&petrol-receipt-codes}) > 0
  and LOOKUP({&petrolium}, p-unit-type) = 0
  then do:
&scop receipt-code string(p-chk-type)

      p-mess = substitute("Чек типа &2, но товар с кодом &1 не топливный&2"
                           , {&receipt-name}
                          ,p-src-code
                            ) .
      p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.

  end.
  IF  p-pump > 0
  and LOOKUP({&petrolium}, p-unit-type) = 0 then do:
      p-mess = substitute("Номер ТРК > 0, но товар с кодом &1 не топливный&2"
                          ,p-src-code
                            ) .
      p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.
  end.
  IF p-pump = 0
  and LOOKUP({&petrolium}, p-unit-type) > 0
  AND LOOKUP({&pieces}, p-unit-type) = 0 then do:
    p-mess = substitute("Товар с кодом &1 топливо, но номер ТРК = 0"
                        ,p-src-code
                          ) .
    p-chr-err = p-chr-err + {&comma-char}  + {&goods-err}.
  end.
  if p-chr-err = "" then
  p-valid = yes.
end.

end procedure. /* libchkvl_petrol-valid */

procedure libchkvl_create-context :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-context-bh as handle no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-conf-par as character no-undo .
define variable v-par-type as character no-undo .

define buffer buf_sysconf for ub.sysconf.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.

{ str/pos_context.i "vars" v- }
&scop prefix v-

define buffer buf_libchkvl_dis-card-mask for libchkvl_dis-card-mask.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-obj-type <> {&shop} then do:
    undo, return error substitute("Неверный тип объекта = &1", p-obj-type).
  end.
  for each buf_libchkvl_dis-card-mask:
    delete buf_libchkvl_dis-card-mask.
  end.
  p-context-bh:empty-temp-table().
  { gbl/curr-r-b.i v-r-b }
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { str/sclspref.i v-sclspref v-scpgpref }
  v-scpgpref-pre = v-scpgpref.
  define variable v-ii as integer no-undo .
  do v-ii = 1 to num-entries(v-scpgpref):
    entry(v-ii, v-scpgpref-pre) = substring(entry(v-ii, v-scpgpref-pre), 1, 2).
  end.

  v-conf-par = "".
  { gbl/conf-rd.i
  "'is-cdinv'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-conf-par
  v-par-type
  NO-ERROR
  }
  assign
  v-is-cdinv = logical(v-conf-par)
  no-error .

  { gbl/conf-rd.i
  "'is-ptrl'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-conf-par
  v-par-type
  NO-ERROR
  }
  assign
  v-is-ptrl = logical(v-conf-par)
  no-error .

  { gbl/conf-rd.i
  "'is-wth'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-conf-par
  v-par-type
  NO-ERROR
  }
  assign
  v-is-wth = logical(v-conf-par)
  no-error .


  find first buf_sysconf no-lock where
          buf_sysconf.host-code = v-host-code.
  .
  assign
  v-base-code = buf_sysconf.base-code.
  find first buf_shop no-lock where
            buf_shop.obj-code = p-obj-code no-error .
  assign
  v-obj-code = p-obj-code

  v-obj-type = {&shop}
  v-doc-prt = buf_shop.doc-prt
  v-shift-on = buf_shop.shift-on
  v-is-catering = buf_shop.is-catering
  .

  find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        AND  buf_clients.obj-code = p-obj-code.
  assign
  v-db-num = buf_clients.db-num
  .
  v-rnd-znak = 2.


{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk} then v-rnd-znak = thbjattr_thbj-attr.property-value-integer .
end.
empty temp-table thbjattr_thbj-attr.

  find first buf_Cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
  { gbl/conf-rd.i
    "'iscredit'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-conf-par
    v-par-type
    no-error
  }
  if error-status:error
  or not available buf_cash-pay
  or buf_cash-pay.is-credit = no
  or v-conf-par <> "yes"
  then do:
      assign
      v-cre-pay = 0
      .
  end.
  else do:
    assign
    v-cre-pay = buf_sysconf.credit-pay
    .
  end.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  {&attr-get-chk}
      ,input  '' /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
    delete object v-tth.
    undo, return error  substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value ).
  end.
  for each thbjattr_thbj-attr  where
          thbjattr_thbj-attr.obj-type = p-obj-type
      and thbjattr_thbj-attr.obj-code = p-obj-code
      and thbjattr_thbj-attr.upper-prop-code = {&attr-get-chk}
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    case thbjattr_thbj-attr.prop-code:
      when {&attr-get-chk_cas-shft} then do:
        v-cas-shft = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_cas-curs} then do:
        /*найдем параметр - брать курсы из спула или из BO*/
        v-cas-curs = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_hnum} then do:
        v-hnum = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_t-shft} then do:
        /*найдем параметр - использовать время пересменки*/
        v-t-shft = thbjattr_thbj-attr.property-value-integer.
      end.
      when {&attr-get-chk_v-shft} then do:
        /*найдем параметр - использовать виртуальные смены*/
        v-v-shft = thbjattr_thbj-attr.property-value-integer.
      end.
      when {&attr-get-chk_dc-mask} then do:
        v-dc-mask = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_card-by-mask} then do:
        v-card-by-mask = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_ptrl-check} then do:
        v-ptrl-check = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_annu-check} then do:
        v-annu-check = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_z-check} then do:
        v-z-check = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_is-100-discnt} then do:
        v-is-100-discnt = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-get-chk_zero-cashier} then do:
        v-zero-cashier = thbjattr_thbj-attr.property-value-integer.
      end.

    end case.
  end.
  if v-dc-mask or v-card-by-mask then do:
    run libchkvl_get-dc-mask-array in this-procedure (
                                                      input v-host-code
                                                    , input p-obj-type
                                                    , input p-obj-code).
  end.
  p-context-bh:buffer-create().
  { str/pos_context.i "vars=temp-table" p-context-bh:: v- }
  p-context-bh:buffer-release().
  delete object v-tth.
end.

end procedure. /* libchkvl_create-context */


procedure libchkvl_getcheck :
define input parameter p-context-bh as handle no-undo . /*контекс разбора - таблица pos_context.i */
define input parameter p-wmode as character no-undo . /*прием чеков {&add-def} или ручное создание/редактирование {&update}*/
define input parameter p-edit-mode as character no-undo . /*ручное добавление {&add-def} редактирование {&update}*/
define input parameter p-close-check as logical no-undo .
define input parameter p-get-cash-shift as logical no-undo .
define input parameter p-netto as decimal no-undo .
define input parameter p-lng-sub-d as integer no-undo .
define input parameter p-sub-d as decimal no-undo .
define input parameter p-discnt-id as integer no-undo .
define input-output parameter p-prev-code like ub.chk-doc.doc-code no-undo .

{ str/pos_context.i "vars" v- }
&scop prefix v-

/*
chk-doc.correct
chk-gds.is-error
chk-pay.is-error
chk-discnt.is-error
Предполагается что в момент ее запуска заполнены все необходимые поля во всех структурах чека
чек должен быть девственно чистым - почти новым!! об этом должна позаботиться вызывающая программа

assign
chk-doc.netto = 0
chk-doc.tot-doc = 0
chk-doc.discnt = 0
chk-doc.sub-discnt = 0
chk-doc.correct = ?
.

надо удалить все вторичные скидки и скидки коррекции а также скидку на чек - процентную в шапке чека
for each chk-discnt where
          chk-discnt.doc-code = chk-doc.doc-code:
   if chk-discnt.record-type = 0 and chk-discnt.line-num > 0
    AND (chk-discnt.line-type = integer({&discnt-sub-total}) or
          chk-discnt.line-type = integer({&discnt-total}) or
          chk-discnt.line-type = integer({&discnt-receipt}) or
          chk-discnt.line-type = integer({&discnt-gds-without-discnt}) or
          chk-discnt.line-type = integer({&discnt-payment}) or

        ) then NEXT.
   delete chk-discnt.
end.

*/

DEFINE VARIABLE var-pcnt-discnt            as   recid                 no-undo .
DEFINE VARIABLE CorrValue                  as   decimal               no-undo .
define variable corr-sign                  as   integer               no-undo .
DEFINE VARIABLE str-dec                    as   decimal               no-undo .
DEFINE VARIABLE temp-d                     as   decimal               no-undo .
DEFINE VARIABLE cashparts                  like ub.gds-obj.cash-parts    no-undo .
DEFINE VARIABLE iserr                      like ub.chk-gds.is-error      no-undo .
DEFINE VARIABLE var-gds-for-discnt         as decimal                 no-undo .
DEFINE VARIABLE v-discnt-sum               as decimal                 no-undo .
DEFINE VARIABLE netto-for-tot-d-pcnt       as decimal                 no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE v-price-from-check           like ub.chk-gds.price-base    no-undo .
DEFINE VARIABLE v-units-rate                 as   decimal               no-undo .
DEFINE VARIABLE v-units-dpcnt                as   decimal               no-undo .
DEFINE VARIABLE v-b-c                        like ub.bar-code.b-code       no-undo .
DEFINE VARIABLE v-bc-buf                     as   character             no-undo .
DEFINE VARIABLE v-bc-buf2                    as   character             no-undo .
define variable v-is-null-price              as logical no-undo .
define variable accum-pay                    as decimal                 no-undo .
define variable accum-count                  as integer                 no-undo .
define variable accum-pay-count              as integer                 no-undo .
define variable v-rb                         as logical                 no-undo .
define variable v-card-correct               as logical                 no-undo .
define variable v-write-off-sum              as decimal                 no-undo .
/*тип чека - т или у*/
define variable main-gds-type                like ub.goods.gds-type no-undo .
define variable v-doc-rec                    as recid                   no-undo .
define variable v-d-card                     like ub.dis-card.d-card    no-undo .
define variable v-src-d-card                 like ub.chk-doc.src-d-card no-undo .
define variable v-found                      as logical                 no-undo .
define variable v-descr                      as character               no-undo .
define variable v-is-correct                 as logical                 no-undo .
define variable v-th-mask                    as logical                 no-undo .
define variable v-short-number               like ub.dis-card.d-card    no-undo .
define variable v-is-petrol-check            as logical                 no-undo .
define variable v-is-annu-check              as logical                 no-undo .
define variable v-cashier-psn-code           like ub.person.psn-code    no-undo .
define variable v-seller-psn-code            like ub.person.psn-code    no-undo .
define variable v-is-inventory               as logical                 no-undo .
define variable v-is-z-rep                   as logical                 no-undo .
define variable v-is-shft-open-close         as logical                 no-undo .
define variable v-is-ord-check               as logical                 no-undo .
define variable v-bc-rcnz-only-bc            as logical                 no-undo .
define variable v-d-mask                     as character no-undo .
define variable v-kriv-z-qnty                as logical                 no-undo .

DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
/*счетчик скидок*/
DEFINE VARIABLE var-discnt-id             as   integer               no-undo .
DEFINE VARIABLE NoExchRate                 as   logical init FALSE    no-undo .
DEFINE VARIABLE r-bar-code                 like ub.bar-code.b-code       no-undo .
define variable v-fttwd as logical no-undo .
define variable v-pos-type-int               as integer                 no-undo .
define variable v-is-petrol-promo            as logical                 no-undo .

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable mask_s-c as character no-undo .
define variable v-tth as handle no-undo .
define variable vSumRound as decimal no-undo.
define variable iii as integer no-undo .
define variable v-promo-sum as decimal no-undo.

define buffer buf_chk-discnt for ub.chk-discnt.
define buffer for-gds for ub.chk-gds.
define buffer for-goods for ub.goods.
define buffer for-bar for ub.bar-code.
define buffer b1-gds-prt for ub.gds-prt .     /* исп-ся в  */
define buffer buf_shop for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_libchkvl_dis-card-mask for libchkvl_dis-card-mask.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf0_chk-discnt for ub.chk-discnt.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_units for ub.units.
define buffer buf_marking-chk for ub.marking-chk .
define buffer buf_chk-gds-attr for ub.chk-gds-attr .

&glob display-message  if valid-handle({&prefix}p-log-handle) then run write-log-and-file in {&prefix}p-log-handle ( ~
              input 1 ~
            , input log-file-name ~
            , input 1 ~
            , input ~{&my-message~} )


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-prev-code = "":U then return.
  FIND buf_chk-doc share-lock WHERE
        buf_chk-doc.doc-code = p-prev-code NO-ERROR.
  if not avail buf_chk-doc then do:
    return.
  end.
run adm/shattri.p (
    input "get":U
    ,input  chk-doc.obj-type
    ,input  chk-doc.obj-code
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_mask_s-c} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then mask_s-c = v-value-character.
else mask_s-c = "".
delete object v-tth no-error.

  define buffer buf66_chk-discnt for ub.chk-discnt.
  find first buf66_chk-discnt no-lock where
            buf66_chk-discnt.doc-code = p-prev-code
        and buf66_chk-discnt.record-type = 2 no-error.
  if available buf66_chk-discnt then do:
    message
    "Попытка повторного вызова процедуры getcheck зовите программистов"
    view-as alert-box error .
    run gbl/inidebug.p .
  end.
  if buf_chk-doc.prev-chk-type = ? then do:
    buf_chk-doc.prev-chk-type = 0.
  end.
  var-discnt-id = p-discnt-id.
  { str/pos_context.i "vars=temp-table" v- p-context-bh:: }
  if {&prefix}p-log-file-name <> ""
  and {&prefix}p-log-file-name <> ? then do:
     log-file-name = {&prefix}p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  /*предварительно установим так int тип кассы - если мы разбираем подбором файлов , которые уже давно валяются в директории,
  а не считаны с определенной кассы в данный момент - то нам придется это переопределеить!!!
  */
  &scop pos-type-char-code {&prefix}pos-type
  v-pos-type-int = {&pos-type-int-code}.

  for each t-gds :
    delete t-gds.
  end.
  for each t-pay :
    delete t-pay.
  end.
  /*удаление суммового чека по настройке ibmgroup = yes*/
  if not {&prefix}ibmgroup AND
    (
    LOOKUP({&amount}, for-chk-type ) > 0 and
    LOOKUP({&gds-goods}, for-chk-type ) = 0 AND
    LOOKUP({&gds-office}, for-chk-type ) = 0 AND
    LOOKUP({&goods-err}, for-chk-type ) = 0 AND
    LOOKUP("0":U, for-chk-type ) = 0
    )  then do:
    /*чисто суммовой чек - пусть даже и ошибочный*/
    _sum-chk:
    do
    on error undo, return error
    :
      for each buf_chk-gds where
              buf_chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-gds.
      end.
      for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-pay.
      end.
      for each buf_chk-discnt where
              buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-discnt.
      end.
      for each buf_chk-gds-pay where
              buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-gds-pay.
      end.
      delete buf_chk-doc.
      p-prev-code = "":U.
      {&prefix}ll = {&prefix}ll - 1.
      return.
    end.
  end. /*удаление суммового чека по настройке ibmgroup = yes*/
  if lookup(string(buf_chk-doc.chk-type) , {&petrol-receipt-codes}) > 0 then do:
    v-is-petrol-check = yes.
  end.
  if lookup(string(buf_chk-doc.chk-type), {&annu-receipt-codes}) > 0 then do:
    assign
    v-is-annu-check = yes.
  end.
  if lookup(string(buf_chk-doc.chk-type), {&ord-receipt-codes}) > 0 then do:
    assign
    v-is-ord-check = yes.
  end.
  if buf_chk-doc.chk-type = integer({&rcpt-inventory}) then do:
    assign
    v-is-inventory = yes.
  end.
  if buf_chk-doc.chk-type = integer({&rcpt-z-rep}) then do:
    assign
    v-is-z-rep = yes.
    if buf_chk-doc.z-number = 0 then do:
&scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Нет сведений о № z-отчета&2" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                            )
      {&display-message}.
    end.
  end.
  if    buf_chk-doc.chk-type = integer({&rcpt-shft-close})
     or buf_chk-doc.chk-type = integer({&rcpt-shft-open}) 
  then do:
    assign
    v-is-shft-open-close = yes.
  end.
  /*проверка и дообработка шапки чека*/
  if {&prefix}hnum then do:
    find first buf_shop no-lock where
          buf_shop.obj-code = buf_chk-doc.obj-code
      and buf_shop.obj-type = {&shop} no-error .
    if not available buf_shop
    or buf_shop.db-num <> g#db-num
    then do:
      assign

      for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
      {&prefix}view-log = yes
      buf_chk-doc.correct = no
      .
&scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Нет сведений о магазине &3 или он принадлежит другой БД&2" + ~
                              "(номер магазина получен из спула в соответствии с настройками)&2" +  ~
                              "ЧЕК БУДЕТ ПРИПИСАН К МАГАЗИНУ &4 ДЛЯ ВОЗМОЖНОСТИ ПОСЛЕДУЮЩЕГО УДАЛЕНИЯ" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , buf_chk-doc.obj-code ~
                              , {&prefix}obj-code)

      {&display-message}.

      buf_chk-doc.obj-code = {&prefix}obj-code.
      for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error :
        buf_chk-pay.obj-code = {&prefix}obj-code.
      end.
      for each buf_chk-discnt where
              buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error :
        buf_chk-discnt.obj-code = {&prefix}obj-code.
      end.
    end.
  end. /*if {&prefix}hnum then do:*/

  if buf_chk-doc.pay-desk <> 0 then do:
    find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
        AND buf_cash-desk.obj-code = buf_chk-doc.obj-code
        AND buf_cash-desk.pos-type = {&prefix}pos-type no-error .
  end.
  if buf_chk-doc.pay-desk = 0
  or not available buf_cash-desk
  or buf_cash-desk.is-del then do:
    if can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = 0
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = {&cd-type-autotank}
                    )
          and can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = buf_chk-doc.pay-desk
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = {&cd-type-autotank}
                    and buf_chk-doc.pay-desk > 0 )
    then do:
      v-pos-type-int = integer({&cd-type-autotank-int}).

    end.
    else do:
      find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
          AND buf_cash-desk.obj-code = buf_chk-doc.obj-code no-error.
      if available buf_cash-desk then do:
        &scop pos-type-char-code buf_cash-desk.pos-type
        v-pos-type-int = {&pos-type-int-code}.
      end.
      else do:
        v-pos-type-int = integer({&cd-type-unknown-int}).
      end.
      assign
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      {&prefix}view-log = yes
      buf_chk-doc.correct = no
      .
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.pay-desk ~
                            , {&prefix}pos-type)
      {&display-message}.
    end.
  end.
  if v-is-z-rep = yes
  and available buf_cash-desk then do:
    entry(1, buf_chk-doc.doc-num2, {&delim-par}) = buf_cash-desk.registration-code + {&comma-char} +  buf_cash-desk.serial-code .
  end.
  assign
  buf_chk-doc.shift-date = if {&prefix}t-shft < 0 AND buf_chk-doc.chk-time < abs({&prefix}t-shft)
                        then (buf_chk-doc.chk-date - 1)
                        else (if buf_chk-doc.src-shift-date = ?
                              then buf_chk-doc.chk-date
                              else
                                  (If p-wmode = {&update}
                                    then
                                          (if index(buf_chk-doc.ps, "shift!") = 0
                                          then buf_chk-doc.src-shift-date
                                          else buf_chk-doc.shift-date)
                                    else
                                          buf_chk-doc.src-shift-date
                                    )
                              )
  .
  if {&prefix}cas-shft then do:
    /*если включены смены на кассах*/
    /*смена объекта в БО соответствующая смене чека уже закрыта или
    в спуле нет смены*/
    if buf_chk-doc.shift-name = ''
    or trim(buf_chk-doc.shift-name, '0') = '':U
      then /*тогда чек ошибочен*/ do:
      assign
      for-chk-type = for-chk-type + {&shift-err} + {&comma-char}
      buf_chk-doc.shift-date = 01/01/1990
      buf_chk-doc.correct = no
      .
    end.
    else do:
      if {&prefix}v-shft > 0 then do:
        run str/v-shftg.p (
                            buffer buf_chk-doc
                            ,input {&prefix}parparentproc
                            ,input {&prefix}p-log-handle
                            ,input p-wmode
                            ,input {&prefix}obj-code   /*пок здесь в обратном порядке*/
                            ,input {&prefix}obj-type
                            ,input {&prefix}v-shft
                            ,input {&prefix}t-shft
                            ,input {&shift-err}
                            ,input-output for-chk-type
                            ,input-output {&prefix}view-log
                    ).
      end. /* if v-shft > 0*/
      if {&prefix}shift-on then do:
        /*в поле .shift-num должен положить порядковый номер смены*/
        if  (p-wmode = {&update} and  index(buf_chk-doc.ps, "shift!") = 0)
        or  p-wmode = {&add-def}
        then do:
          run libchkvl_get-shift-num in this-procedure (
                                                input buf_chk-doc.obj-type
                                              ,input buf_chk-doc.obj-code
                                              ,input buf_chk-doc.shift-date
                                              ,input buf_chk-doc.shift-name
                                              ,output buf_chk-doc.shift-num) no-error .
          if error-status:error
          or buf_chk-doc.shift-num = ?
          or buf_chk-doc.shift-num = 0 then do:
          assign
          for-chk-type = for-chk-type + {&shift-err} + {&comma-char}
          buf_chk-doc.shift-num = 0
          buf_chk-doc.correct = no
          .
          end.
        end.
      end. /*if l-shift-on then do:*/
      if (p-wmode = {&update} and index(buf_chk-doc.ps, "shift!") = 0)
      or p-wmode = {&add-def}
      then do:
        assign
        shift-name_ = (if p-wmode = {&update}
                        then (if p-edit-mode = {&add-def}
                            then buf_chk-doc.shift-name
                            else buf_chk-doc.src-shift-name)
                        else buf_chk-doc.src-shift-name)
        .
        if {&prefix}cas-shft then do:
          if p-get-cash-shift then do:
            { str/libchkvl_get-cash-shift.i
            p-context-bh
            buf_shift-cash
            buf_chk-doc.pay-desk
            buf_chk-doc.src-shift-date
            shift-name_
            ?
            buf_chk-doc.chk-date
            buf_chk-doc.chk-time
            0
            no-error
            }
          end.
        end. /*if cas-shft then do:*/
      end.
    end. /*  if buf_chk-doc.shift-name = '' */
  end. /* if cas-shft*/
  if (buf_chk-doc.src-d-card <> ? and buf_chk-doc.src-d-card <> "":U)
  or buf_chk-doc.d-card <> "":U
  then do:
    if v-is-petrol-check
    or v-is-inventory
    or v-is-z-rep
    or v-is-shft-open-close
    then do:
&scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message   substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Не может быть указана дисконтная карта в чеке типа &3" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , ~{&receipt-name~} ~
                            )
      {&display-message}.
      assign
      for-chk-type = for-chk-type + {&card-err} + {&comma-char}
      {&prefix}view-log = yes
      buf_chk-doc.correct = no
      .
    end.  /*petrol*/
    else do:
      if buf_chk-doc.src-d-card = "-0":U then do:
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2 В чеке имеются строки продажи на разные дисконтные карты&2&3" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            ,(if p-wmode = ~{&update~} ~
                              then "Введите ПРАВИЛЬНЫЙ НОМЕР дисконтной карты в поле <ДК В ЧЕКЕ>" ~
                              else ~{&new-line~} ))
        {&display-message}.
        assign
        for-chk-type = for-chk-type + {&card-err} + {&comma-char}
        {&prefix}view-log = yes
        buf_chk-doc.correct = no
        .
      end. /*buf_chk-doc.src-d-card = "-0":U */
      else do:
        v-d-card = (if buf_chk-doc.d-card = "":U
                    and buf_chk-doc.src-d-card <> ?
                    and buf_chk-doc.src-d-card <> '':U
                    then buf_chk-doc.src-d-card
                    else buf_chk-doc.d-card).
        v-src-d-card = buf_chk-doc.src-d-card.
        FIND FIRST buf_dis-card NO-LOCK where
                  buf_dis-card.d-card = v-d-card  NO-ERROR.
        if not available buf_dis-card then do:
          if ({&prefix}dc-mask or {&prefix}card-by-mask) then do:
            _maska:
            for each buf_libchkvl_dis-card-mask no-lock
            by buf_libchkvl_Dis-card-mask.rank:
              assign
              v-found = yes
              v-descr = "":U
              v-short-number = '':U
              v-is-correct = no
              .
              if {&prefix}card-by-mask then do:
                assign
                v-short-number = card-by-mask (buf_libchkvl_dis-card-mask.cli-mask, buf_libchkvl_dis-card-mask.cc-run, v-src-d-card)
                no-error
                .
                if error-status:error then do:
                  assign
                  for-chk-type = for-chk-type + {&card-err} + {&comma-char}
                  {&prefix}view-log = yes
                  buf_chk-doc.correct = no
                  .
                  leave _maska.
                end.
                v-d-mask = buf_libchkvl_dis-card-mask.cli-mask.
              end. /*if {&prefix}card-by-mask then do:*/
              if v-short-number = '':U then do:
                if {&prefix}dc-mask then do:
                  assign
                  v-is-correct = check-by-mask (buf_libchkvl_dis-card-mask.mask, v-src-d-card, output v-descr)
                  no-error
                  .
                  if error-status:error then do:
                    assign
                    for-chk-type = for-chk-type + {&card-err} + {&comma-char}
                    {&prefix}view-log = yes
                    buf_chk-doc.correct = no
                    .
                  end.
                  v-d-mask = buf_libchkvl_dis-card-mask.mask.
                end.
              end.
              if v-is-correct or v-short-number <> '':U then do:
                find first buf_dis-card no-lock where
                          buf_dis-card.d-card = (if v-short-number <> '':U then v-short-number else buf_libchkvl_dis-card-mask.mask) no-error .
                if available buf_dis-card
                and buf_dis-card.type = buf_libchkvl_dis-card-mask.type
                and buf_dis-card.emitent-host-code = buf_libchkvl_dis-card-mask.emitent-host-code
                then do:
                  assign
                  buf_chk-doc.src-d-card = (if buf_chk-doc.src-d-card = ? or
                                        buf_chk-doc.src-d-card = '':U
                                        then v-d-card else buf_chk-doc.src-d-card)
                  buf_chk-doc.d-card = buf_dis-card.d-card
                  v-th-mask = yes
                  buf_chk-doc.d-mask = v-d-mask
                  .
                  LEAVE _maska.
                end.
              end. /*if v-is-correct or v-short-number <> '':U then do:*/
            end. /*for each _maska*/
            if not available buf_dis-card then do:
              assign
              for-chk-type = for-chk-type + {&card-err} + {&comma-char}
              {&prefix}view-log = yes
              buf_chk-doc.correct = no
              .
  &scop my-message  substitute("!!!Чек &1 - ошибочный.&2&3" ~
                                      , buf_chk-doc.doc-code ~
                                      , ~{&new-line~} ~
                                      , if not v-found  ~
                                        then substitute("Для карты &1 не определено ни одной действующей маски", v-d-card) ~
                                        else substitute("Карта &1 не соответствует ни одной действующей маске", v-d-card))
              {&display-message}.
            end.
          end.  /*if {&prefix}dc-mask or {&prefix}card-by-mask*/
          else do:
            if  v-src-d-card <> v-d-card then do:
              FIND FIRST buf_dis-card NO-LOCK where
                        buf_dis-card.d-card = v-src-d-card  NO-ERROR.
            end.
          end.
        end. /*if not avail buf_dis-card */
        if avail buf_dis-card
        then find first buf_dis-card-type No-LOCK WHERE
                          buf_dis-card-type.type = buf_dis-card.type
                    AND  buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code
                    AND  buf_dis-card-type.host-code = 0
                    AND  buf_dis-card-type.obj-type = "":U
                    AND  buf_dis-card-type.obj-code = 0 NO-ERROR.
        else release buf_dis-card-type.

        IF NOT avail buf_dis-card
        or NOT avail buf_dis-card-type
        OR (buf_dis-card.emitent-host-code <> {&prefix}host-code and buf_dis-card.emitent-host-code <> 0)
        or (lookup(string({&prefix}obj-code), buf_dis-card-type.DCBYSHOP) > 0  and buf_dis-card.issue-code <> {&prefix}obj-code)
        then do:
          assign
          for-chk-type = for-chk-type + {&card-err} + {&comma-char}
          {&prefix}view-log = yes
          buf_chk-doc.correct = no
          .
  &scop my-message  substitute( ~
                                  "!!!Чек &1 - ошибочный. &2 Нет сведений о карте клиента &3 или карта выдана другим магазином" ~
                                  , buf_chk-doc.doc-code ~
                                  , ~{&new-line~} ~
                                  , buf_chk-doc.src-d-card )
          {&display-message}.
        end.
        if avail buf_dis-card
        and buf_dis-card.emitent-host-code = 0
        and buf_dis-card.credit-card then do:
          assign
          for-chk-type = for-chk-type + {&card-err} + {&comma-char}
          {&prefix}view-log = yes
          buf_chk-doc.correct = no
          .
  &scop my-message  substitute( ~
                                  "!!!Чек &1 - ошибочный. &2 Глобальная карта &3 не может быть кредитной" ~
                                  , buf_chk-doc.doc-code ~
                                  , ~{&new-line~} ~
                                  , buf_chk-doc.d-card )
          {&display-message}.
        end.
        if p-wmode <> {&update} then do:
          if avail buf_dis-card
          and buf_dis-card.mask-card = yes
          and not v-th-mask
          AND (buf_dis-card.cli-type <> buf_chk-doc.src-cli-type
              OR
              buf_dis-card.cli-code <> (if buf_chk-doc.src-cli-code > 999999999
                                  then (buf_chk-doc.src-cli-code - 1000000000)
                                  else buf_chk-doc.src-cli-code)) then do:
  &scop my-message  substitute( ~
                                    "!!!Чек &1 - ошибочный. &2 Маска карты &3 соответствует другому клиенту" ~
                                    , buf_chk-doc.doc-code ~
                                    , ~{&new-line~} ~
                                    , buf_chk-doc.d-card )
            {&display-message}.
            assign
            for-chk-type = for-chk-type + {&card-err} + {&comma-char}
            {&prefix}view-log = yes
            buf_chk-doc.correct = no
            .
          end.
        END. /*if p-wmode <> {&update} then do:*/
      end. /*else if buf_chk-doc.src-d-card = "-0":U */
      if avail buf_dis-card
      and buf_dis-card.status_ <> {&current-status} then do:
        IF p-wmode = {&update} then do:
          if buf_dis-card.status_ = {&nonused-status}
          or buf_dis-card.status_ = {&chown-status}
          then do:
  &scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный.&2Карта &3 имеет статус &4&2" + ~
                                "&5&2" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_dis-card.d-card ~
                                , buf_dis-card.status_  ~
                                , (if buf_dis-card.status_ = ~{&nonused-status~} ~
                                  then "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА и подлежит ПОЛНОМУ И ОКОНЧАТЕЛЬНОМУ УДАЛЕНИЮ" ~
                                  else "карта будет доступна по окончании процесса смены владельца") ~
                              )
            {&display-message}.
            assign
            for-chk-type = for-chk-type + {&card-err} + {&comma-char}
            {&prefix}view-log = yes
            buf_chk-doc.correct = no
            .
          end.
          else do:
  &scop my-message substitute( ~
                              "!!!Чек &1 - потенциально ошибочный.&2Карта &3 имеет статус &4 - если карта накопительная,&2" + ~
                              "то при пересчете % скидки или категории клиента МОЖЕТ ВОЗНИКНУТЬ СИТУАЦИЯ когда пересчет&2" + ~
                              "будет осуществляться для ДРУГОЙ карты, перевыпущенной к данной, и имеющей статус &5" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , buf_dis-card.d-card ~
                              , buf_dis-card.status_  ~
                              , ~{&current-status~}  ~
                            )
            {&display-message}.
          end.
        end. /*IF p-wmode = {&update} then do:*/
        else do:
          assign
          for-chk-type = for-chk-type + {&card-err} + {&comma-char}
          {&prefix}view-log = yes
          buf_chk-doc.correct = no
          .
  &scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Карта &3 имеет статус &4" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_dis-card.d-card ~
                                , buf_dis-card.status_ ~
                              )
          {&display-message}.
        end. /*else IF p-wmode = {&update} then do:*/
      end.
    end. /*не petrol*/
    if LOOKUP({&card-err}, for-chk-type) = 0 then do:
      assign
      buf_chk-doc.d-card = (if buf_chk-doc.d-card = "":u
                        then buf_chk-doc.src-d-card
                        else buf_chk-doc.d-card)
      buf_chk-doc.cli-type = (if avail buf_dis-card
                          then buf_dis-card.cli-type
                          else buf_chk-doc.cli-type)
      buf_chk-doc.cli-code = (if avail buf_dis-card
                          then buf_dis-card.cli-code
                          else buf_chk-doc.cli-code)
      v-card-correct  = yes
      .
    end.
    if ((buf_chk-doc.src-d-card <> "":U
        and buf_chk-doc.src-d-card <> ?
        and buf_chk-doc.src-d-pcnt <> 0.0
        )
        or
        buf_chk-doc.src-d-pcnt <> 0.0 ) AND
        p-sub-d = 0 and not v-is-petrol-check
    then do:        
      /*тогда запишем скидку процентную*/
      create buf0_chk-discnt.
      assign
      buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
      buf0_chk-discnt.record-type = 0
      buf0_chk-discnt.discnt-id = (var-discnt-id + 1)
      buf0_chk-discnt.line-num = p-lng-sub-d
      buf0_chk-discnt.time-oper = buf_chk-doc.chk-time
      buf0_chk-discnt.line-type = integer({&discnt-receipt})
      buf0_chk-discnt.line-sign = yes
      buf0_chk-discnt.pass-discnt = integer({&discnt-p-auto})
      buf0_chk-discnt.value-type = integer({&discnt-v-pcnt})
      buf0_chk-discnt.discnt-type = (if buf_chk-doc.d-card <> "":U
                                then integer({&discnt-t-d-card})
                                else integer({&discnt-t-sum})
                                )
      buf0_chk-discnt.src-d-card = buf_chk-doc.src-d-card
      buf0_chk-discnt.d-card     = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then  buf_chk-doc.d-card else buf0_chk-discnt.d-card 
      buf0_chk-discnt.discnt-value-pcnt = buf_chk-doc.src-d-pcnt
      buf0_chk-discnt.object-line-num = 0
      buf0_chk-discnt.pay-desk = buf_chk-doc.pay-desk
      buf0_chk-discnt.obj-code = buf_chk-doc.obj-code
      buf0_chk-discnt.obj-type = buf_chk-doc.obj-type
      buf0_chk-discnt.chk-date = buf_chk-doc.chk-date
      buf0_chk-discnt.chk-time = buf_chk-doc.chk-time
      var-discnt-id = var-discnt-id + 1
      var-pcnt-discnt = recid(buf0_chk-discnt)
      .      
    end.
  end. /*if (buf_chk-doc.src-d-card <> ? and buf_chk-doc.src-d-card <> "":U)*/
  if {&prefix}pos-type <> {&cd-type-IPC-Servispl} then do:
    if buf_chk-doc.cashier = 0
    and (buf_chk-doc.chk-type = integer({&rcpt-annu})
          or
          buf_chk-doc.chk-type = integer({&rcpt-write-off})
          )
    and {&prefix}pos-type = {&cd-type-magia-xml} then do:
      buf_chk-doc.cashier = {&prefix}zero-cashier.
      /*если в magii была отмена ЗАКАЗА - кассира еще нет */
    end.
    assign
    v-cashier-psn-code = gbclcode-is-this-db-role ( input {&role-cashier}, input g#db-num, input buf_chk-doc.cashier, input buf_chk-doc.chk-date)
    .
    if v-cashier-psn-code = 0
    and buf_chk-doc.chk-type <> integer({&rcpt-z-rep})
    and buf_chk-doc.chk-type <> integer({&rcpt-shft-close})
    and buf_chk-doc.chk-type <> integer({&rcpt-shft-Open})
    then do:
      assign
      for-chk-type = for-chk-type + {&staff-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
&scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Нет сведений о кассире &3" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , buf_chk-doc.cashier ~
                            )
      {&display-message}.
    end.
    else do:
      assign
      buf_chk-doc.cashier-psn-code = v-cashier-psn-code
      .
    end.
    if buf_chk-doc.sales-man > 0 then do:
      assign
      v-seller-psn-code = gbclcode-is-this-db-role ( input {&role-seller}
                                                      ,input g#db-num
                                                    , input ( buf_chk-doc.sales-man - (
                                                                                    if {&prefix}pos-type = {&cd-type-magia-XML}
                                                                                    or {&prefix}pos-type = {&cd-type-magia-XML}
                                                                                    THEN 10000
                                                                                    ELSE 0)
                                                              )
                                                      , input buf_chk-doc.chk-date
                                                            ) no-error .
      if v-seller-psn-code = 0 then do:
        assign
        for-chk-type = for-chk-type + {&staff-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = YES
        .
&scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Нет сведений о продавце(официанте) &3&2&4" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_chk-doc.sales-man - (if {&prefix}pos-type = ~{&cd-type-magia-XML~} ~
                                                      or {&prefix}pos-type = ~{&cd-type-magia-XML~} ~
                                                      then 10000 ~
                                                      else 0) ~
                                ,(if {&prefix}pos-type = ~{&cd-type-magia-XML~} or {&prefix}pos-type = ~{&cd-type-magia-XML~} ~
                                  then substitute('Для кассы типа &1 код продавца (официанта) = [код в IBS TH] + 10000', ~{&cd-type-magia-XML~}) ~
                                  else '':u) ~
                              )
        {&display-message}.
      end.
      else do:
        assign
        buf_chk-doc.salesman-psn-code = v-seller-psn-code
        .
      end.
    end. /*if buf_chk-doc.sales-man > 0 then do:*/
  end. /*if {&prefix}pos-type <> {&cd-type-IPC-Servispl} then do:*/
  /*если валюта кассы не совпадает с  р_у_блями то найдем курс валюты кассы по отношению к нац валюте */
  if {&prefix}base-code = 0 then do:
    assign
    buf_chk-doc.base-rate = 1.
  end.
  if {&prefix}r-b = {&r-b-base}
  and {&prefix}base-code <> 0 then do:
    if buf_chk-doc.cash-rate = 0
    or buf_chk-doc.cash-rate = ?
    or buf_chk-doc.cash-rate = 1 then do:
      if available buf_curr-shop then release buf_curr-shop.

      run libchkval_get-curr-shop in this-procedure ( input {&prefix}obj-type
                                                     ,input {&prefix}obj-code
                                                     ,input {&prefix}base-code
                                                     ,input buf_chk-doc.chk-date
                                                     ,input buf_chk-doc.chk-time
                                                     ,buffer buf_curr-shop) no-error.
      if available buf_curr-shop then do:
        assign
        buf_chk-doc.cash-rate = buf_curr-shop.exch-rate
        buf_chk-doc.cash-scale = buf_curr-shop.exch-scale
        buf_chk-doc.base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        if NOT NoExchRate then do:
&scop my-message  substitute( ~
                                  "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                                  , buf_chk-doc.doc-code ~
                                  , ~{&new-line~} ~
                                  , buf_chk-doc.obj-type ~
                                  , buf_chk-doc.obj-code ~
                                  , buf_chk-doc.chk-date  ~
                                )
          {&display-message}.
          NoExchRate = TRUE .
        end.
        assign
        for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
      end.
    end.
  end. /*if {&prefix}r-b = {&r-b-base} and {&prefix}base-code <> 0 then do:*/
  if {&prefix}r-b = {&r-b-rubl}
  and {&prefix}base-code <> 0 then do:
    if buf_chk-doc.base-rate = 0
    or buf_chk-doc.base-rate = ?
    or buf_chk-doc.base-rate = 1 then do:
      if available buf_curr-shop then release buf_curr-shop.
      run libchkval_get-curr-shop in this-procedure ( input {&prefix}obj-type
                                                     ,input {&prefix}obj-code
                                                     ,input {&prefix}base-code
                                                     ,input buf_chk-doc.chk-date
                                                     ,input buf_chk-doc.chk-time
                                                     ,buffer buf_curr-shop) no-error.
      if available buf_curr-shop then do:
        assign
        buf_chk-doc.base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        if NOT NoExchRate then do:
&scop my-message  substitute( ~
                                  "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                                  , buf_chk-doc.doc-code ~
                                  , ~{&new-line~} ~
                                  , buf_chk-doc.obj-type ~
                                  , buf_chk-doc.obj-code  ~
                                  , buf_chk-doc.chk-date  ~
                                )
          {&display-message}.
          NoExchRate = TRUE .
        end.
        assign
        for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
      end.
    end.
  end. /*if {&prefix}r-b = {&r-b-rubl} */
  /*завершена проверка шапки*/
  /*проверка и дообработка строк чека*/
  buf_chk-doc.doc-qnty = 0.
  for each buf_chk-gds where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
  BY buf_chk-gds.LINE-NUM
            :
    assign
    accum-count = accum-count + 1
    buf_chk-gds.is-error = ?
    buf_chk-gds.d-card   = ( if buf_chk-doc.src-d-card = buf_chk-gds.src-d-card
                          and v-card-correct
                          then buf_chk-doc.d-card
                          else buf_chk-gds.d-card)
    buf_chk-gds.cli-type = ( if buf_chk-doc.src-cli-type = buf_chk-gds.src-cli-type
                          and v-card-correct
                          then buf_chk-doc.cli-type
                          else buf_chk-gds.cli-type)
    buf_chk-gds.cli-code = ( if buf_chk-doc.src-cli-code = buf_chk-gds.src-cli-code
                          and v-card-correct
                          then buf_chk-doc.cli-code
                          else buf_chk-gds.cli-code)
    .
    if buf_chk-gds.sales-man = 0
    or buf_chk-gds.sales-man = ? then do:
      assign
      buf_chk-gds.sales-man = buf_chk-doc.sales-man
      buf_chk-gds.salesman-psn-code = buf_chk-doc.salesman-psn-code
      .
    end. /*if buf_chk-gds.sales-man = 0*/
    else do:
      v-seller-psn-code = 0.
      assign
      v-seller-psn-code = gbclcode-is-this-db-role (  input {&role-seller}
                                                      ,input g#db-num
                                                      ,input ( buf_chk-gds.sales-man - (
                                                                if {&prefix}pos-type = {&cd-type-magia-XML}
                                                                or {&prefix}pos-type = {&cd-type-magia-XML}
                                                                THEN 10000
                                                                ELSE 0))
                                                      ,input buf_chk-doc.chk-date
                                                                ) no-error .
      if v-seller-psn-code = 0 then do:
        assign
        for-chk-type = for-chk-type + {&staff-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = YES
        .
&scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Нет сведений о продавце(официанте) &3&2Строка &4&2&5" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_chk-gds.sales-man ~
                                , buf_chk-gds.line-num  ~
                                ,(if {&prefix}pos-type = ~{&cd-type-magia-XML~} or {&prefix}pos-type = ~{&cd-type-magia-XML~} ~
                                  then substitute('Для кассы типа &1 код продавца (официанта) = [код в IBS TH] + 10000', ~{&cd-type-magia-XML~}) ~
                                  else '':u) ~
                              )
        {&display-message}.
      end. /*if not avail person then do:*/
      else do:
        assign
        buf_chk-doc.salesman-psn-code = (IF buf_chk-doc.SALESMAN-PSN-CODE = 0
                                      OR buf_chk-doc.SALESMAN-PSN-CODE = ?
                                      THEN v-seller-psn-code
                                      ELSE (if buf_chk-doc.salesman-psn-code <> v-seller-psn-code
                                            then 0
                                            else buf_chk-doc.SALESMAN-PSN-CODE)
                                    )
        .
      end.
    end. /* buf_chk-gds.sales-man <> 0*/
    CASE buf_chk-gds.grp-code:
      when 0 then do: /*товары*/
        assign
        v-units-rate = 1
        v-units-dpcnt = 0
        v-bc-buf = entry(1, buf_chk-gds.src-code, {&delim-par})
        v-price-from-check = buf_chk-gds.src-price
        v-bc-buf     = (if buf_chk-gds.b-code <> 0
                        and ({&prefix}pos-type = {&cd-type-IBM-XML}
                            or
                            {&prefix}pos-type = {&cd-type-ibs-th}
                            or
                            {&prefix}pos-type = {&cd-type-ibs-th-mob}
                            or
                            {&prefix}pos-type = {&cd-type-autotank}
                            )
                        then string(buf_chk-gds.b-code)
                        else v-bc-buf)
        .

if p-wmode = {&update} then do:
if p-edit-mode = {&add-def} then do:
          assign
          v-bc-buf = string(entry(1, buf_chk-gds.src-code, {&delim-par}))
          v-bc-rcnz-only-bc = (string(buf_chk-gds.b-code) = entry(1, buf_chk-gds.src-code, {&delim-par}))
          .
end.
if p-edit-mode = {&update} then do:

          assign
          v-bc-buf = string(buf_chk-gds.b-code)
          v-bc-rcnz-only-bc = yes
          .
end.
end. /*if p-wmode = {&update} then do:*/
if p-wmode = {&update} then do:
{ str/bc-rcnz.i
  {&prefix}parparentproc
  v-bc-buf
  v-price-from-check
  {&prefix}obj-type
  {&prefix}obj-code
  yes
  v-bc-rcnz-only-bc
  {&prefix}sclspref
  {&prefix}scpgpref
  varresult
  vartype-bc
  varweight
  buf_bar-code
  buf_prod-bc
  buf_place
  no-error
}
end.
else do:
{ str/bc-rcnz.i
  {&prefix}parparentproc
  v-bc-buf
  v-price-from-check
  {&prefix}obj-type
  {&prefix}obj-code
  " ( if g#auto then no else yes ) "
  no
  {&prefix}sclspref
  {&prefix}scpgpref
  varresult
  vartype-bc
  varweight
  buf_bar-code
  buf_prod-bc
  buf_place
  no-error
}
end.
if avail buf_bar-code then do:
  if buf_bar-code.stts_ <> integer({&hn-delete}) then do:
    if p-wmode = {&update} then do:
      assign
      v-units-rate = (if buf_chk-gds.src-qnty = 0
                      then  buf_bar-code.cli-base-rate
                      else buf_chk-gds.doc-qnty / buf_chk-gds.src-qnty)
      iserr = no
      .
    end.
    else do:
      assign
      v-units-rate = buf_bar-code.cli-base-rate
      iserr = no
      .
    end.
          { gbl/gdsbcode.i buf_bar-code.gds-code buf_bar-code.node-code r-bar-code no-error}
          if error-status:error then v-b-c = ?.
          else do:
            if buf_bar-code.in-code = "":U and buf_bar-code.part-code = "":U then do:
                assign
                v-b-c = r-bar-code
                .
            end.
            else do:
              { gbl/gdspcode.i buf_bar-code.gds-code buf_bar-code.node-code buf_bar-code.in-code buf_bar-code.part-code r-bar-code }
                assign
                v-b-c = (if error-status:error
                      then ?
                      else r-bar-code)
                .
            end.
            end. /*not error-status:error */
          end. /*stts_ = 0*/
          else do: /*stts_ <> 0*/
            assign
            v-b-c = ?
            iserr = yes
            .
&scop my-message substitute( ~
                                "!!!Чек &1 - ошибочный. &2 В чеке имеется бар-код &3 помеченный для удаления:&4&5" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , v-bc-buf      ~
                                , ~{&new-line~} ~
                                , string(varresult, "X(80)") ~
                              )
            {&display-message}.
          end. /*stts_ <> 0*/
        end. /*if avail buf_bar-code then do:*/
        else do: /*not avail buf_bar-code*/
          if mask_s-c <> "" then do :
              iii_ :
              do iii = 1 to num-entries(mask_s-c) :
                if length(v-bc-buf) = (num-entries(entry(iii, mask_s-c), '*') - 1) then do :
                  v-bc-buf2 = entry(1, entry(iii, mask_s-c), '*') + v-bc-buf.
                  if p-wmode = {&update} then do:
                    { str/bc-rcnz.i
                      {&prefix}parparentproc
                      v-bc-buf2
                      v-price-from-check
                      {&prefix}obj-type
                      {&prefix}obj-code
                      yes
                      v-bc-rcnz-only-bc
                      {&prefix}sclspref
                      {&prefix}scpgpref
                      varresult
                      vartype-bc
                      varweight
                      buf_bar-code
                      buf_prod-bc
                      buf_place
                      no-error
                    }
                  end.
                  else do:
                    { str/bc-rcnz.i
                      {&prefix}parparentproc
                      v-bc-buf2
                      v-price-from-check
                      {&prefix}obj-type
                      {&prefix}obj-code
                      " ( if g#auto then no else yes ) "
                      no
                      {&prefix}sclspref
                      {&prefix}scpgpref
                      varresult
                      vartype-bc
                      varweight
                      buf_bar-code
                      buf_prod-bc
                      buf_place
                      no-error
                    }
                  end.
                  if avail buf_bar-code then do:
                    v-bc-buf = v-bc-buf2.
                    if buf_bar-code.stts_ <> integer({&hn-delete}) then do:
                      if p-wmode = {&update} then do:
                        assign
                        v-units-rate = (if buf_chk-gds.src-qnty = 0
                                        then  buf_bar-code.cli-base-rate
                                        else buf_chk-gds.doc-qnty / buf_chk-gds.src-qnty)
                        iserr = no
                        .
                    end.
                    else do :
                      assign
                      v-units-rate = buf_bar-code.cli-base-rate
                      iserr = no
                      .
                    end.
                    { gbl/gdsbcode.i buf_bar-code.gds-code buf_bar-code.node-code r-bar-code no-error}
                    if error-status:error then v-b-c = ?.
                    else do:
                      if buf_bar-code.in-code = "":U and buf_bar-code.part-code = "":U then do:
                          assign
                          v-b-c = r-bar-code
                          .
                      end.
                      else do:
                        { gbl/gdspcode.i buf_bar-code.gds-code buf_bar-code.node-code buf_bar-code.in-code buf_bar-code.part-code r-bar-code }
                        assign
                          v-b-c = (if error-status:error
                                then ?
                                else r-bar-code)
                          .
                      end.
                      end. /*not error-status:error */
                    end. /*stts_ = 0*/
                    else do: /*stts_ <> 0*/
                      assign
                      v-b-c = ?
                      iserr = yes
                      .
&scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный. &2 В чеке имеется нераспознанный бар-код &3:&4&5" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , v-bc-buf ~
                              , ~{&new-line~} ~
                              , string(varresult, "X(80)") ~
                            )
          {&display-message}.
                    end. /*stts_ <> 0*/
                    leave iii_ .
                  end. /*if avail buf_bar-code then do:*/
                  else next iii_ .
                end. /*  if length(v-bc-buf) =  */
              end. /* do iii = 1 to num-entries(mask_s-c) */
            end.  /* if mask_s-c <> "" */
        if not available buf_bar-code
        and buf_chk-doc.chk-type <> integer({&income-corr})
        and buf_chk-doc.chk-type <> integer({&expense-corr})
        then do :  
          assign
          v-b-c = ?
          iserr = yes
          .
&scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный. &2 В чеке имеется нераспознанный бар-код &3:&4&5" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , v-bc-buf ~
                              , ~{&new-line~} ~
                              , string(varresult, "X(80)") ~
                            )
          {&display-message}.
        end.
      end.
        if buf_chk-doc.chk-type <> integer({&income-corr})
        and buf_chk-doc.chk-type <> integer({&expense-corr})
        then do :
          { str/setchkt.i prefix=~{&prefix~} }
        end.
        IF v-b-c = ?
        and buf_chk-doc.chk-type <> integer({&income-corr})
        and buf_chk-doc.chk-type <> integer({&expense-corr})
        then
        buf_chk-doc.PS = buf_chk-doc.PS + "@":U +
                    "строка" + {&space-char} + string(buf_chk-gds.LINE-NUM) + {&space-char} +
                    "код = ?" + "@":u
        .
         
        v-price-from-check = buf_chk-gds.SRC-PRICE * abs( buf_chk-gds.src-qnty ) .
                              
        assign
        buf_chk-gds.b-code = ( if v-b-c <> ? then v-b-c else 0)
        buf_chk-gds.is-error = (if buf_chk-gds.is-error = ? then no else buf_chk-gds.is-error) or iserr
        v-kriv-z-qnty =   (if buf_chk-gds.src-qnty = 0
                            and  lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) > 0
                            and buf_chk-gds.src-price <> 0
                            /*для специфических бензиновых чеков
                            определеяем как частное сумма / цена
                            */
                            then  yes
                            else v-kriv-z-qnty)
        buf_chk-gds.doc-qnty = (if buf_chk-gds.src-qnty = 0
                              and  lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) > 0
                              and buf_chk-gds.src-price <> 0
                              /*для специфических бензиновых чеков
                              определеяем как частное сумма / цена
                              */
                              then  buf_chk-gds.src-sum / buf_chk-gds.src-price
                              else round(buf_chk-gds.src-qnty *  v-units-rate, 3)
                              )
        buf_chk-gds.price-base = (if buf_chk-gds.src-qnty = 0
                              then buf_chk-gds.src-price / v-units-rate
                              else (if round(buf_chk-gds.src-price, 2) <> buf_chk-gds.src-price
                                    and v-units-rate = 1
                                    then buf_chk-gds.src-price
                                    else  round( v-price-from-check / abs( buf_chk-gds.doc-qnty ), 2 )
                                    )
                              )
        buf_chk-gds.line-type = (if avail buf_goods
                            then buf_goods.gds-type
                            else "":U)
        .
                         
        if buf_chk-doc.chk-type <> integer({&income-corr})
        and buf_chk-doc.chk-type <> integer({&expense-corr})
        then do :                    
          buf_chk-gds.depart-type = (if buf_chk-gds.depart-code > 0 then {&shop} else "":U) .
        end .
        if buf_chk-doc.chk-type = integer({&income-corr})
        or buf_chk-doc.chk-type = integer({&expense-corr})
        then do :
          buf_chk-gds.b-code = integer(v-bc-buf) .
        end .
        if buf_chk-gds.src-qnty <> 0
        or (buf_chk-gds.doc-qnty <> 0 and v-is-petrol-check)  /*глюки колонки - в src = 0 в doc - нет*/
        then do:
          assign
          buf_chk-gds.discnt =  if buf_chk-gds.src-discnt = buf_chk-gds.src-price
                            then buf_chk-gds.price-base
                            else ( if v-is-petrol-check
                                  then  buf_chk-gds.discnt
                                  else (
                                        if buf_chk-gds.write-off-code <> ?
                                        and buf_chk-gds.write-off-code > 0
                                        then 0
                                        else (
                                              if v-units-rate = 1
                                              then (if (buf_chk-gds.pump > 0)
                                                    then
                                                    (buf_chk-gds.src-discnt  +
                                                      (abs(buf_chk-gds.src-qnty * buf_chk-gds.src-price) - abs(buf_chk-gds.src-sum) )
                                                      / abs(buf_chk-gds.src-qnty)
                                                    )
                                                    else buf_chk-gds.src-discnt
                                                    )
                                              else
                                                  ( ( buf_chk-gds.src-discnt / abs( v-units-rate) +

                                                    ( v-price-from-check / abs( buf_chk-gds.doc-qnty )  - buf_chk-gds.src-price / abs( v-units-rate ) ) +
                                                    ( v-price-from-check / abs( buf_chk-gds.doc-qnty ) - buf_chk-gds.price-base ) )
                                                  )
                                            ))
                                    )          
          
          .                           
          
          /* при акционной цене другое округление */          
          if ChkPromoPrice(buf_chk-gds.doc-code, buf_chk-gds.line-num )               
          then assign 
                 vSumRound = RoundUp(buf_chk-gds.doc-qnty, buf_chk-gds.price-base)
                 buf_chk-gds.discnt = 0
                 .
          else vSumRound = buf_chk-gds.doc-qnty * buf_chk-gds.price-base.
                                         
          assign
          buf_chk-gds.sum-base = vSumRound           
          buf_chk-doc.tot-doc = buf_chk-doc.tot-doc + (if v-is-petrol-check
                                                or v-is-inventory
                                                then 0 else  buf_chk-gds.sum-base)
          buf_chk-doc.discnt = buf_chk-doc.discnt + (if buf_chk-gds.write-off-code <> ?
                                              and buf_chk-gds.write-off-code > 0
                                              then 0
                                              else buf_chk-gds.discnt * buf_chk-gds.doc-qnty)
          buf_chk-doc.netto = buf_chk-doc.tot-doc - buf_chk-doc.discnt
          buf_chk-doc.doc-qnty = buf_chk-doc.doc-qnty + buf_chk-gds.doc-qnty
          /*брутто касса*/
          buf_chk-doc.src-tot-doc = (if buf_chk-doc.tot-doc <> 0
                                then (buf_chk-doc.src-tot-doc + buf_chk-gds.src-sum)
                                else buf_chk-doc.src-tot-doc)
          no-error
          .
          if buf_chk-gds.discnt > buf_chk-gds.price-base then do:
            &scop my-message  substitute( ~
                                        "!!!Чек &1 - ошибочный. &2В строке &3 скидка превысила цену!" ~
                                        , buf_chk-doc.doc-code ~
                                        , ~{&new-line~} ~
                                        , buf_chk-gds.line-num ~
                                      )
            {&display-message}.
            assign
            for-chk-type = for-chk-type + {&discount-err} + {&comma-char}
            buf_chk-doc.correct = no
            {&prefix}view-log = yes
            .
          end.
          
          /* если возвратный чек, то надо вручную создать скидки */
          if buf_chk-doc.chk-type = integer({&rcpt-return}) then 
             SetPromoDisc(buf_chk-gds.doc-code, buf_chk-gds.line-num /*, input-output var-discnt-id*/ ).
               
          if buf_chk-gds.discnt <> 0 or ChkPromoLine(buf_chk-gds.doc-code, buf_chk-gds.line-num )
          then do:
            _chk-discnt-gds:
            for each buf0_chk-discnt where
                      buf0_chk-discnt.doc-code = buf_chk-doc.doc-code and
                      buf0_chk-discnt.line-num = buf_chk-gds.line-num and
                      buf0_chk-discnt.record-type = 0 and
                      buf0_chk-discnt.object-line-num = buf_chk-gds.line-num:
              if not buf0_chk-discnt.line-type = integer({&discnt-gds}) then next _chk-discnt-gds.              
              
              create buf_chk-discnt.
              buffer-copy buf0_chk-discnt to buf_chk-discnt
              assign
              buf_chk-discnt.record-type = 1
              buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
              buf_chk-discnt.discnt-value-pcnt = if buf0_chk-discnt.object-sum <> 0
                                                then buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum * 100
                                                else 0
              buf0_chk-discnt.d-card       = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf0_chk-discnt.d-card
              buf_chk-discnt.d-card       = if buf_chk-discnt.d-card = ? or buf_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf_chk-discnt.d-card
              /*buf0_chk-discnt.discnt-id = (var-discnt-id + 1)
              var-discnt-id = var-discnt-id + 1*/  
              .              
            end.
          end.
        end. /* if buf_chk-gds.src-qnty <> 0 t*/
        if buf_chk-gds.src-qnty <> 0
        or (buf_chk-gds.src-qnty = 0
            and
            buf_chk-gds.doc-qnty <> 0) then do:
          { str/set-tgds.i  }
        end.
        for each buf_marking-chk exclusive-lock where buf_marking-chk.doc-code = chk-gds.doc-code
                                                  and buf_marking-chk.line-num = chk-gds.line-num  
                                                  :
          if v-units-rate = 10
          then do :  
            assign buf_marking-chk.unit = "LEVEL1" .                                       
          end .
          else do :
            assign buf_marking-chk.unit = "UNIT" .
          end .
        end.
      end. /*товарная строка*/
      otherwise do: /*группы*/
        assign
        for-chk-type = for-chk-type + {&amount} + {&comma-char}
        buf_chk-doc.tot-doc = buf_chk-doc.tot-doc + buf_chk-gds.price-base * buf_chk-gds.doc-qnty
        buf_chk-doc.discnt = buf_chk-doc.discnt + buf_chk-gds.discnt * buf_chk-gds.doc-qnty
        buf_chk-doc.netto = buf_chk-doc.netto + ( buf_chk-gds.price-base * buf_chk-gds.doc-qnty ) - buf_chk-gds.src-discnt
        buf_chk-doc.doc-qnty = buf_chk-doc.doc-qnty + buf_chk-gds.doc-qnty
        .
        if buf_chk-gds.src-discnt <> 0 then do:                        
          create buf0_chk-discnt.
          assign
          buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
          buf0_chk-discnt.record-type = 0
          buf0_chk-discnt.discnt-id = (var-discnt-id + 1)
          buf0_chk-discnt.line-num = buf_chk-gds.line-num
          buf0_chk-discnt.time-oper = buf_chk-doc.chk-time
          buf0_chk-discnt.line-type = integer({&discnt-gds})
          buf0_chk-discnt.line-sign =  (buf_chk-gds.src-qnty >= 0 ) Eq (buf_chk-gds.src-discnt > 0 )
          buf0_chk-discnt.pass-discnt = integer({&discnt-p-auto})
          buf0_chk-discnt.value-type = integer({&discnt-v-unknown})
          buf0_chk-discnt.discnt-type = integer({&discnt-t-unknown})
          buf0_chk-discnt.d-card = buf_chk-doc.d-card
          buf0_chk-discnt.d-card = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then buf_chk-doc.d-card else buf0_chk-discnt.d-card 
          buf0_chk-discnt.src-d-card = buf_chk-doc.src-d-card
          buf0_chk-discnt.discnt-value-abs = buf_chk-gds.src-discnt
          buf0_chk-discnt.object-qnty = buf_chk-gds.src-qnty
          buf0_chk-discnt.object-sum = buf_chk-gds.src-sum
          buf0_chk-discnt.discnt-value-pcnt = if buf_chk-gds.src-sum <> 0
                                          then (buf_chk-gds.src-discnt / buf_chk-gds.src-sum) * 100
                                          else 0
          buf0_chk-discnt.object-line-num = buf_chk-gds.line-num
          buf0_chk-discnt.pay-desk = buf_chk-doc.pay-desk
          buf0_chk-discnt.obj-code = buf_chk-doc.obj-code
          buf0_chk-discnt.obj-type = buf_chk-doc.obj-type
          buf0_chk-discnt.chk-date = buf_chk-doc.chk-date
          buf0_chk-discnt.chk-time = buf_chk-doc.chk-time
          buf_chk-gds.discnt = buf_chk-gds.src-discnt / abs( buf_chk-gds.doc-qnty )
          buf_chk-gds.src-discnt = buf_chk-gds.src-discnt / buf_chk-gds.src-qnty
          var-discnt-id = var-discnt-id + 1
          .          
        end.
      end. /*строка группы*/
    end CASE. /*buf_chk-gds.grp-code*/
    if buf_chk-gds.is-error = ? then
    buf_chk-gds.is-error = no.
    if buf_chk-gds.write-off-code <> 0
    and buf_chk-gds.write-off-code <> ?
    and not v-is-petrol-check
    then do:
      assign
      v-write-off-sum = v-write-off-sum + (if buf_chk-gds.write-off-code > 0 then 1 else - 1) *
                        buf_chk-gds.doc-qnty * buf_chk-gds.price-base
      .
    end.
  end. /*for each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code*/
  if ((buf_chk-doc.chk-type = integer({&rcpt-trans-transfer})
  and accum-count <> 2)
  or ((buf_chk-doc.chk-type = integer({&rcpt-trans-cancell})
        or
        buf_chk-doc.chk-type = integer({&rcpt-overflow})
        or
        buf_chk-doc.chk-type = integer({&rcpt-tech-refuell})
        or
        buf_chk-doc.chk-type = integer({&rcpt-unlock-trans})
      )
      and
      accum-count <> 1) )
  or (v-is-z-rep and accum-count <> 0)
  or (v-is-shft-open-close and accum-count <> 0)
  then do:
&scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2Товарных строк - &3&2В чеке типа &4 кол-во товарных строк может быть только  - &5" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , accum-count    ~
                            , ~{&receipt-name~} ~
                            , (if buf_chk-doc.chk-type = integer(~{&rcpt-trans-transfer~}) ~
                                then 2 ~
                                else (if v-is-z-rep or v-is-shft-open-close then 0 else 1)) ~
                          )
    {&display-message}.
    assign
    for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
    buf_chk-doc.correct = no
    {&prefix}view-log = yes
    .
  end.
  /*проверка и дообработка платежей*/
  assign
  v-rb = ?
  accum-pay-count = 0
  .
  for each buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
    run libchkvl_process-chk-pay in this-procedure (
                                           input p-context-bh
                                          ,buffer buf_chk-doc
                                          ,buffer buf_chk-pay
                                          ,input-output noexchrate
                                          ,input-output for-chk-type
                                          ) no-error .

    assign
    accum-pay = accum-pay + (if {&prefix}r-b = {&r-b-base}
                              then buf_chk-pay.tot-base
                              else buf_chk-pay.tot-rubl)
    accum-pay-count = accum-pay-count + 1
    v-rb = ((if {&prefix}r-b = {&r-b-base}
            then buf_chk-pay.tot-base
            else buf_chk-pay.tot-rubl) = buf_chk-pay.tot-sum)
    .
  END. /*for each buf_chk-pay where buf_chk-pay.doc-code = buf_chk-doc.doc-code*/
  if p-netto  <> ? then do:
    if ABS(ABS(p-netto - ACCUM-pay)/ p-netto) > 0.01
    AND accum-pay-count = 1
    AND buf_chk-doc.chk-type = integer({&rcpt-return})
    AND v-rb
    then do:
      find first buf_chk-pay where
                buf_chk-pay.doc-code = buf_chk-doc.doc-code.
      assign
      accum-pay = accum-pay - buf_chk-pay.tot-sum
      buf_chk-pay.tot-sum = p-netto
      accum-pay = accum-pay + buf_chk-pay.tot-sum
      buf_chk-pay.is-error = ?
      .
      run libchkvl_process-chk-pay in this-procedure (
                                             input p-context-bh
                                            ,buffer buf_chk-doc
                                            ,buffer buf_chk-pay
                                            ,input-output noexchrate
                                            ,input-output for-chk-type
                                            ) no-error .
    end.
  end. /*if p-netto  <> ? then do:*/
  if p-wmode = {&update} then do:
    define variable loc#log as logical no-undo .
    if p-edit-mode = {&add-def} then do:
      define variable v-netto-virtual as decimal no-undo .
      assign
      v-netto-virtual = buf_chk-doc.netto
      .
      if (buf_chk-doc.d-card <> "":U or
        buf_chk-doc.src-d-pcnt <> 0 ) AND
        p-sub-d = 0
      then  do:
        v-netto-virtual = v-netto-virtual * (1 - buf_chk-doc.src-d-pcnt / 100).
      end.
      else do:
        if p-sub-d <> 0 then do:
          v-netto-virtual = v-netto-virtual - p-sub-d.
        end.
      end.
      if not v-is-annu-check
      and not v-is-inventory
      and not v-is-z-rep
      and abs(v-netto-virtual -
            (if buf_chk-doc.chk-type = integer({&rcpt-sale})
              or buf_chk-doc.chk-type = integer({&rcpt-write-off})
              then v-write-off-sum
              else 0) - accum-pay) > 0.01 then do:
        message
        substitute(("Сумма нетто по чеку &1 не совпадает с суммой оплат&2" +
        "разница составляет &3&2" +
        "Сумма нетто=&4 Сумма оплат=&5&2" +
        "Вы уверены, что создали правильный чек?")
        , (if v-write-off-sum <> 0 then "(с учетом суммы списания)" else '')
        , {&new-line}
        , abs(v-netto-virtual - accum-pay)
        , v-netto-virtual
        , accum-pay)
        view-as alert-box  question buttons YES-NO update loc#log.
        if not loc#log then return error.
      end.
    end.
  end. /*if p-wmode = {&update} then do:*/
  /*дообработка чека - все суммы полученные из buf_chk-gds и buf_chk-pay  уже заполнены*/
  if (buf_chk-doc.netto = 0
      and not v-is-petrol-check
      and not v-is-annu-check
      and not v-is-inventory
      and not v-is-z-rep
      and not v-is-shft-open-close
      and not v-is-ord-check
      and not ({&prefix}is-100-discnt and accum-pay-count > 0)
      )
  or (buf_chk-doc.netto <> 0 and v-is-petrol-check)
  or (buf_chk-doc.netto <> 0 and v-is-shft-open-close)
  or (buf_chk-doc.doc-qnty <> 0 and buf_chk-doc.chk-type = integer({&rcpt-trans-transfer}))
  or (buf_chk-doc.doc-qnty = 0
      and v-is-petrol-check
      and not (buf_chk-doc.chk-type = integer({&rcpt-trans-transfer})
              or
              buf_chk-doc.chk-type = integer({&rcpt-trans-cancell})
              or
              buf_chk-doc.chk-type = integer({&rcpt-unlock-trans})
              )
      )
  then do:
    assign
    for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
    buf_chk-doc.correct = no
    {&prefix}view-log = yes
    .
&scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message  (if v-is-petrol-check ~
                then (if buf_chk-doc.netto <> 0 ~
                      then substitute( ~
                            "!!!Чек &1 - ошибочный. &2Сумма по чеку <> 0.Чек типа &3" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , ~{&receipt-name~}) ~
                      else   (if buf_chk-doc.doc-qnty <> 0 and buf_chk-doc.chk-type = integer(~{&rcpt-trans-transfer~}) ~
                              then substitute("!!!Чек &1 - ошибочный. &2Кол-во по чеку <> 0.Чек типа &3" ~
                                            , buf_chk-doc.doc-code ~
                                              , ~{&new-line~} ~
                                            , ~{&receipt-name~}) ~
                              else substitute("!!!Чек &1 - ошибочный. &2Кол-во по чеку = 0.Чек типа &3" ~
                                            , buf_chk-doc.doc-code ~
                                            , ~{&new-line~} ~
                                            , ~{&receipt-name~}) ~
                              ) ~
                      ) ~
                else substitute( ~
                            "!!!Чек &1 - ошибочный. &2Сумма по чеку = 0. &2Возможно, это ошибка кассира и Вам следует просто удалить этот чек" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~})  ~
                )
    {&display-message}.
  end.
  /*теперь разберемся со скидками*/
  CorrValue = 0.
  if p-sub-d <> 0 then do:
    def var v-excsum as dec no-undo.
    FOR EACH chk-gds WHERE
              chk-gds.doc-code = chk-doc.doc-code,
        first t-gds where
              t-gds.b-code = chk-gds.b-code and
              t-gds.drc = recid(chk-doc):
      find first ub.bar-code where ub.bar-code.b-code = buf_chk-gds.b-code no-error.
      find first ub.dis-gds-rule where ub.dis-gds-rule.gds-code = ub.bar-code.gds-code and ub.dis-gds-rule.templ-rl-root = 55 no-error.
      find first ub.clients where ub.clients.obj-type = {&prefix}obj-type and ub.clients.obj-code = {&prefix}obj-code no-error.          
      if can-find (first ub.dis-rule no-lock where ub.dis-rule.rule-num = ub.dis-gds-rule.rule-num and
                         ((ub.dis-rule.host-code = 0 and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                      or (ub.dis-rule.host-code = ub.clients.host-code and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                      or (ub.dis-rule.obj-code = {&prefix}obj-code and ub.dis-rule.obj-type = {&prefix}obj-type))
                    ) 
      then do:
        v-excsum = chk-gds.src-sum + v-excsum.
      end.
    end.
    for each buf0_chk-discnt where
              buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
          AND buf0_chk-discnt.record-type = 0 :
      if NOT (buf0_chk-discnt.line-type = integer({&discnt-sub-total}) or
              buf0_chk-discnt.line-type = integer({&discnt-total}) or
              buf0_chk-discnt.line-type = integer({&discnt-receipt}) or
              buf0_chk-discnt.line-type = integer({&discnt-payment})
            ) then NEXT.
      if recid(buf0_chk-discnt) = var-pcnt-discnt then NEXT.
      if abs(buf0_chk-discnt.object-sum) < abs(buf0_chk-discnt.discnt-value-abs)
      and not(abs(abs(buf0_chk-discnt.object-sum) - abs(buf0_chk-discnt.discnt-value-abs)) < 0.2
                    and
                    {&prefix}is-100-discnt)
      then do:
        assign
        for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
&scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Скидка по чеку больше или равна сумме чека&2" + ~
                                "(за вычетом товаров, на которые скидка на итог распределяться не должна)&2" + ~
                                "Чек придется пересоздать руками" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                              )
        {&display-message}.
      end.
      assign
      buf_chk-doc.discnt = buf_chk-doc.discnt + buf0_chk-discnt.discnt-value-abs
      buf_chk-doc.netto = buf_chk-doc.netto - buf0_chk-discnt.discnt-value-abs
      .
      assign
      v-discnt-sum = 0
      .
      /*if lookup({&amount}, for-chk-type)  = 0 and shop.discaloc then do:*/
      /*ВСЕГДА РАЗМАЗЫВАЕМ!!!*/
        _buf_chk-gds:
        FOR EACH buf_chk-gds WHERE
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code AND
                  (buf_chk-gds.line-num <= buf0_chk-discnt.line-num
                  or buf0_chk-discnt.line-type = integer({&discnt-receipt})
                  or buf0_chk-discnt.line-type = integer({&discnt-payment})),
            first t-gds where
                  t-gds.b-code = buf_chk-gds.b-code and
                  t-gds.drc = recid(buf_chk-doc):
          
          if buf_chk-gds.doc-qnty = 0 then do:
            NEXT _buf_chk-gds.
          end.
          v-fttwd = no.
          assign
          v-fttwd = {&prefix}tt-wd-bh:find-first( substitute(' where doc-code = "&1" and record-type = 0 and line-type = &2 and line-num = &3 and discnt-id < &4'
                                                             , buf_chk-gds.doc-code
                                                             , integer({&discnt-gds-without-discnt})
                                                             , buf_chk-gds.line-num
                                                             , buf0_chk-discnt.discnt-id))
          no-error.
          if {&prefix}tt-wd-bh:available
          then do:
            NEXT _buf_chk-gds.
          end.
          if (buf_chk-doc.chk-type = integer({&rcpt-sale})
          or buf_chk-doc.chk-type = integer({&rcpt-return})
          )
          and buf_chk-gds.write-off-code <> ?
          and buf_chk-gds.write-off-code > 0 then do:
            NEXT _buf_chk-gds. /*по списанным в расходе не размазываем*/
          end.

          find first ub.bar-code where ub.bar-code.b-code = buf_chk-gds.b-code no-error.
          find first ub.dis-gds-rule where ub.dis-gds-rule.gds-code = ub.bar-code.gds-code and ub.dis-gds-rule.templ-rl-root = 55 no-error.
          find first ub.clients where ub.clients.obj-type = {&prefix}obj-type and ub.clients.obj-code = {&prefix}obj-code no-error.          
          if can-find (first ub.dis-rule no-lock where ub.dis-rule.rule-num = ub.dis-gds-rule.rule-num and
                             ((ub.dis-rule.host-code = 0 and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                          or (ub.dis-rule.host-code = ub.clients.host-code and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                          or (ub.dis-rule.obj-code = {&prefix}obj-code and ub.dis-rule.obj-type = {&prefix}obj-type))
                        ) 
          then do:
            NEXT _buf_chk-gds.
          end.
          if buf0_chk-discnt.object-sum - v-excsum = 0
          then do:
            v-excsum = v-excsum - buf_chk-gds.doc-qnty. /* все равно применяем скидку, так как другого товара нету */
          end.
          
          if ChkPromoPrice(buf_chk-gds.doc-code, buf_chk-gds.line-num)               
          then 
             var-gds-for-discnt = RoundUp(buf_chk-gds.doc-qnty, (buf_chk-gds.price-base - buf_chk-gds.discnt) ).
          else     
             var-gds-for-discnt = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty.
                 
          assign
          str-dec = if buf0_chk-discnt.object-sum <> 0
                    then (if buf0_chk-discnt.discnt-value-pcnt = 100
                          and buf0_chk-discnt.value-type= integer({&discnt-v-pcnt})
                          then (buf_chk-gds.price-base - buf_chk-gds.discnt)
                          else (buf_chk-gds.price-base - buf_chk-gds.discnt) * (buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum - v-excsum)
                          )
                    else 0          
          /*
          buf_chk-gds.discnt = buf_chk-gds.discnt + round(str-dec, 2)
          t-gds.discnt-sum = t-gds.discnt-sum + buf_chk-gds.doc-qnty * round(str-dec, 2)
          CorrValue = CorrValue + str-dec - round( str-dec, 2 ) ) * buf_chk-gds.doc-qnty
          */
          v-discnt-sum = v-discnt-sum + str-dec * buf_chk-gds.doc-qnty
          buf_chk-gds.discnt = buf_chk-gds.discnt + str-dec
          t-gds.discnt-sum = t-gds.discnt-sum + buf_chk-gds.doc-qnty * str-dec
          .
                
          create buf_chk-discnt.
          buffer-copy buf0_chk-discnt to buf_chk-discnt
          assign
          buf_chk-discnt.record-type = 1
          buf_chk-discnt.object-line-num = buf_chk-gds.line-num
          buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
          buf_chk-discnt.object-sum = var-gds-for-discnt
          buf_chk-discnt.discnt-value-abs =  buf_chk-gds.doc-qnty * str-dec
          buf_chk-discnt.discnt-value-pcnt = if buf_chk-discnt.object-sum <> 0
                                            then (if buf0_chk-discnt.discnt-value-pcnt = 100
                                                  and buf0_chk-discnt.value-type= integer({&discnt-v-pcnt})
                                                  then 100
                                                  else (buf_chk-discnt.discnt-value-abs / buf_chk-discnt.object-sum * 100)
                                                  )
                                            else 0
          .
       
        end. /*for each buf_chk-gds*/
      /*end. /*if lookup({&amount}, for-chk-type)  = 0 and shop.discaloc*/*/
      if abs(v-discnt-sum - buf0_chk-discnt.DISCNT-VALUE-ABS) > 0.0000000001 then do:
      /*это разница между суммой скидок по строкам и скидкой по чеку врез-те округления - учтем ее*/
      /*для этого найдем товарчик и к его скидке прибавим CorrValue приведенную к кол-ву товара*/
        if buf0_chk-discnt.discnt-value-pcnt = 100
        and buf0_chk-discnt.value-type = integer({&discnt-v-pcnt}) then do:
          assign
          buf_chk-doc.discnt = buf_chk-doc.discnt - (buf0_chk-discnt.discnt-value-abs - v-discnt-sum)
          buf_chk-doc.netto = buf_chk-doc.netto + (buf0_chk-discnt.discnt-value-abs - v-discnt-sum)
          .
        end.
        else do:
          assign
          corrvalue = abs(v-discnt-sum) - abs(buf0_chk-discnt.DISCNT-VALUE-ABS)
          corr-sign = (if buf_chk-doc.netto >= 0 then 1 else -1) *  (if buf0_chk-discnt.DISCNT-VALUE-ABS >= 0 then 1 else -1)
          .
          if not v-is-annu-check then
          run libchkvl_set-corr-discnt in this-procedure (
                                                 input p-context-bh
                                                ,buffer buf_chk-doc
                                                ,input CorrValue
                                                ,input no
                                                ,input no
                                                ,input corr-sign
                                                ,input-output v-write-off-sum
                                                ,input-output for-chk-type
                                                ,input-output var-discnt-id
                                                ) .
        end.
      end.
    end. /*for each buf0_chk-discnt*/
  end. /*p-sub-d <> 0 */
  /*это были скидки на итог*/
  /*процентная скидка! на товары клиентов*/
  if var-pcnt-discnt <> ? then do:
    /*этот кусок кода в новом FO для IBM отомрет так как sub-d всегда будет <> 0 */
    assign
    COrrValue = 0
    .
    find first buf_chk-discnt where
                recid(buf_chk-discnt) = var-pcnt-discnt no-error .
    if not avail buf_chk-discnt then do:
    end.
    else  do:
      if NOT can-do( for-chk-type, {&amount} ) then do:
        assign
        netto-for-tot-d-pcnt = 0
        v-discnt-sum = 0
        .
        FOR EACH buf_chk-gds WHERE
                buf_chk-gds.doc-code = buf_chk-doc.doc-code:
          /*не размазываем по списанным*/
          if buf_chk-discnt.line-num > 0 and buf_chk-gds.line-num > buf_chk-discnt.line-num then NEXT.
          if (buf_chk-doc.chk-type = integer({&rcpt-sale})
          or buf_chk-doc.chk-type = integer({&rcpt-return})
          )
          and buf_chk-gds.write-off-code <> ?
          and buf_chk-gds.write-off-code > 0  then NEXT.
          if buf_chk-gds.doc-qnty = 0 then NEXT.
          assign
          str-dec = (buf_chk-gds.price-base - buf_chk-gds.discnt)  / 100 * ( buf_chk-discnt.discnt-value-pcnt )
          var-gds-for-discnt = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          netto-for-tot-d-pcnt = netto-for-tot-d-pcnt + var-gds-for-discnt
          buf_chk-gds.discnt = buf_chk-gds.discnt +  str-dec
          v-discnt-sum = v-discnt-sum + str-dec * buf_chk-gds.doc-qnty
          .
          /*запишем вторичные скидки  - скидки возникшие в результате размазывания*/

          create buf0_chk-discnt.
          buffer-copy buf_chk-discnt to buf0_chk-discnt
          assign
          buf0_chk-discnt.record-type = 1
          buf0_chk-discnt.discnt-value-abs = str-dec * buf_chk-gds.doc-qnty
          buf0_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
          buf0_chk-discnt.object-sum = var-gds-for-discnt
          buf0_chk-discnt.object-line-num = buf_chk-gds.line-num
          buf0_chk-discnt.d-card      = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf0_chk-discnt.d-card
          buf_chk-discnt.d-card      = if buf_chk-discnt.d-card = ? or buf_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf_chk-discnt.d-card
          .          
        END . /* FOR EACH buf_chk-gds WHERE*/
        assign
        buf_chk-doc.discnt = buf_chk-doc.discnt + ( netto-for-tot-d-pcnt / 100 * ( buf_chk-discnt.discnt-value-pcnt ) )
        buf_chk-doc.netto = buf_chk-doc.netto - ( netto-for-tot-d-pcnt / 100 * ( buf_chk-discnt.discnt-value-pcnt ) )
        buf_chk-discnt.discnt-value-abs = netto-for-tot-d-pcnt * buf_chk-discnt.discnt-value-pcnt * 0.01
        buf_chk-discnt.object-sum = netto-for-tot-d-pcnt
        .
        if abs(v-discnt-sum - buf_chk-discnt.DISCNT-VALUE-ABS) > 0.0000000001 then do:
        /*это разница между суммой скидок по строкам и скидкой по чеку врез-те округления - учтем ее*/
        /*для этого найдем товарчик и к его скидке прибавим CorrValue приведенную к кол-ву товара*/
          assign
          corrvalue = abs(v-discnt-sum) - abs(buf_chk-discnt.DISCNT-VALUE-ABS)
          corr-sign = (if buf_chk-discnt.discnt-value-abs >= 0
                        then 1
                        else -1)
          .
          if not v-is-annu-check then
          run libchkvl_set-corr-discnt in this-procedure (
                                                 input p-context-bh
                                                ,buffer buf_chk-doc
                                                ,input CorrValue
                                                ,input no
                                                ,input no
                                                ,input corr-sign
                                                ,input-output v-write-off-sum
                                                ,input-output for-chk-type
                                                ,input-output var-discnt-id
                                                ) .
        end.
      end. /*not amount*/
      else do:
      /*
        assign
        buf_chk-doc.discnt = buf0_chk-discnt - buf_chk-gds.doc-qnty * round( str-dec, 2)
        buf_chk-doc.netto = buf_chk-doc.netto + buf_chk-gds.doc-qnty * round( str-dec, 2)
                  . */
      end.
    end.
  end. /*if var-create-pcnt-discnt then  do:*/
  for each buf0_chk-discnt where
          buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
      and buf0_chk-discnt.record-type  = 4
  :
    if buf0_chk-discnt.line-type = integer({&discnt-gds})
    and buf0_chk-discnt.object-line-num > 0
    then do:
      find first buf_chk-gds no-lock where
                buf_Chk-gds.doc-code = buf_chk-doc.doc-code
            and buf_Chk-gds.line-num = buf0_chk-discnt.object-line-num no-error.
      if not available buf_chk-gds
      /* or (p-wmode = {&update} and decimal(entry(1, buf_chk-gds.src-code, {&delim-par} )) <> buf0_chk-discnt.discnt-value-pcnt) НЕ ПОНЯТНО ОТКУДА ТАКОЕ УСЛОВИЕ, НО МЕШАЕТ РУЧНОМУ ЗАВЕДЕНИЮ БОНУСОВ*/
      then do:
        assign
        buf0_chk-discnt.discnt-value-pcnt = 0
        for-chk-type = for-chk-type + {&discount-err}
        {&prefix}view-log = yes
        buf_chk-doc.correct = no
        .
&scop my-message substitute( ~
                                "!!!Чек &1 - ошибочный.&2Бонус в строке &3 указывает на товар &4 строки &5&2" + ~
                                "но код товара для строки &3 равен &6" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf0_chk-discnt.line-num ~
                                , buf0_chk-discnt.discnt-value-pcnt ~
                                , buf0_chk-discnt.object-line-num ~
                                , (if available buf_chk-gds then  buf_chk-gds.src-code else ~{&question-mark~}) ~
                              )
        {&display-message}.
      end.
      else do:
        if  buf0_chk-discnt.kateg = -1
        or ((buf0_chk-discnt.kateg = 0
              and {&prefix}r-b = {&r-b-rubl}
              )
              or
              (buf0_chk-discnt.kateg = {&prefix}base-code
              and {&prefix}r-b = {&r-b-base})
            )
        then do:
          assign
          buf0_chk-discnt.object-qnty = buf_chk-gds.src-qnty
          buf0_chk-discnt.object-sum = buf_chk-gds.src-sum
          buf0_chk-discnt.discnt-value-pcnt =  buf0_chk-discnt.discnt-value-abs / buf_chk-gds.src-sum * 100
          .
        end. /*if   (buf0_chk-discnt.kateg = 0*/
        create buf_chk-discnt.
        buffer-copy buf0_chk-discnt
        except record-type
        to buf_chk-discnt
        assign
        buf_chk-discnt.record-type = 5
        buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
        buf_chk-discnt.object-sum  = buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
        .
      end. /*avail buf_chk-gds and buf_chk-gds.src-code = chk-discnt.discnt-value-pcnt*/
    end. /*if buf0_chk-discnt.line-type = integer({&discnt-gds}) */
    if buf0_chk-discnt.line-type = integer({&discnt-sub-total})
    or buf0_chk-discnt.line-type = integer({&discnt-gds})
    then do:
      define variable v-cycle as integer no-undo .
      if buf0_chk-discnt.line-type = integer({&discnt-sub-total}) then do:
        assign
        buf0_chk-discnt.object-qnty = 0
        buf0_chk-discnt.object-sum  = 0
        .
      end.
      do v-cycle = 1 to (if buf0_chk-discnt.line-type = integer({&discnt-gds})
                          then 1
                          else 2):
        _buf_chk-gds:
        FOR EACH buf_chk-gds WHERE
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code AND
                  buf_chk-gds.line-num <= buf0_chk-discnt.object-line-num,
            first t-gds where
                  t-gds.b-code = buf_chk-gds.b-code and
                  t-gds.drc = recid(buf_chk-doc):
          if buf_chk-gds.doc-qnty = 0 then do:
              NEXT _buf_chk-gds.
            end.
            if buf0_chk-discnt.line-type = integer({&discnt-gds})
            and decimal(buf_chk-gds.src-code) <> buf0_chk-discnt.discnt-value-pcnt then next _buf_chk-gds.
            if (buf_chk-doc.chk-type = integer({&rcpt-sale})
            or buf_chk-doc.chk-type = integer({&rcpt-return})
            )
            and buf_chk-gds.write-off-code <> ?
            and buf_chk-gds.write-off-code > 0 then do:
              NEXT _buf_chk-gds. /*по списанным в расходе не размазываем*/
            end.
            if v-cycle = 1
            and (buf0_chk-discnt.kateg = -1
                  or
                  ((buf0_chk-discnt.kateg = 0
                  and {&prefix}r-b = {&r-b-rubl}
                  )
                  or
                  (buf0_chk-discnt.kateg = {&prefix}base-code
                  and {&prefix}r-b = {&r-b-base})
                  )
                  )
            then do:
              assign
              buf0_chk-discnt.object-qnty = buf0_chk-discnt.object-qnty + buf_chk-gds.doc-qnty
              buf0_chk-discnt.object-sum  = buf0_chk-discnt.object-sum + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
              buf0_chk-discnt.discnt-value-pcnt = (if buf0_chk-discnt.object-sum = 0
                                              then 0
                                              else buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum   * 100)
              .
            end.
          if (v-cycle = 2 and buf0_chk-discnt.line-type = integer({&discnt-sub-total}))
          then do:
              create buf_chk-discnt.
              buffer-copy buf0_chk-discnt to buf_chk-discnt
              assign
              buf_chk-discnt.record-type = 5
              buf_chk-discnt.object-line-num = buf_chk-gds.line-num
              buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
              buf_chk-discnt.object-sum = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
              buf_chk-discnt.discnt-value-abs  = (if buf0_chk-discnt.object-sum = 0
                                                  then 0
                                                  else buf0_chk-discnt.discnt-value-abs * buf_chk-discnt.object-sum / buf0_chk-discnt.object-sum)
              buf_chk-discnt.discnt-value-pcnt = if buf_chk-discnt.object-sum <> 0
                                                then buf_chk-discnt.discnt-value-abs / buf_chk-discnt.object-sum * 100
                                                else 0
              .
          end. /*if (v-cycle = 2 and buf0_chk-discnt.line-type = integer({&discnt-sub-total}))*/
        end. /*for each buf_chk-gds*/
      end. /*do v-cycle*/
    end. /*if buf0_chk-discnt.line-type = integer({&discnt-sub-total}) */
  end. /*    for each buf0_chk-discnt where */
  if not v-is-annu-check then do:
    assign
    buf_chk-doc.sub-discnt = v-write-off-sum
    buf_chk-doc.tot-doc    = buf_chk-doc.tot-doc - (if buf_chk-doc.chk-type = integer({&rcpt-return})
                                            or buf_chk-doc.chk-type = integer({&rcpt-return-write-off})
                                            then 0
                                            else buf_chk-doc.sub-discnt)

    /*buf_chk-doc.netto      = buf_chk-doc.netto - buf_chk-doc.sub-discnt*/
    buf_chk-doc.netto      = buf_chk-doc.netto -
                        (if (buf_chk-doc.chk-type = integer({&rcpt-return})
                        or buf_chk-doc.chk-type = integer({&rcpt-return-write-off})
                                            )
                                            then 0
                        else buf_chk-doc.sub-discnt)

    .
    if p-netto <> ? then do:
      if (buf_chk-doc.chk-type = integer({&rcpt-write-off})
      or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}) ) then do:
        if p-netto <> ((if lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0
                        then 1
                        else - 1) * (buf_chk-doc.sub-discnt +
                                    (if buf_chk-doc.chk-type = integer({&rcpt-return-write-off})
                                    then buf_chk-doc.discnt
                                    else 0
                                    ))
                      )
          and not v-is-z-rep and not v-pos-type-int = integer({&cd-type-magia-xml-int})
          then do:
&scop my-message  substitute(  ~
                              "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" + ~
                              "Сумма транзакции не совпадает с суммой списания по чеку&4" +  ~
                              "Сумма транзакции = &5, сумма списания по чеку = &6&4" + ~
                              "Обратитесь к администратору Вашей системы"  ~
                              , buf_chk-doc.doc-code ~
                              , buf_chk-doc.chk-num   ~
                              , buf_chk-doc.pay-desk  ~
                              , ~{&new-line~} ~
                              , p-netto ~
                              , buf_chk-doc.sub-discnt ~
                            )
          {&display-message}.
          assign
          for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
          buf_chk-doc.correct = no
          {&prefix}view-log = yes
          .
        end. /*if p-netto <> ((if lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0*/
      end. /*if (buf_chk-doc.chk-type = integer({&rcpt-write-off})*/
      else do:
        if not v-is-petrol-check
        and ((p-netto = 0 and accum-pay <> 0)
        or (p-netto <> 0 and  ABS(ABS(p-netto - ACCUM-pay) / p-netto ) > 0.01))
        and not v-is-z-rep
        and not v-is-ord-check
        then do:
&scop my-message  substitute(   ~
                              "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" + ~
                              "Сумма транзакции не совпадает с суммой оплат по чеку&4" + ~
                              "Сумма транзакции = &5, сумма оплат по чеку = &6&4" +       ~
                              "Обратитесь к администратору Вашей системы"               ~
                              , buf_chk-doc.doc-code                                    ~
                              , buf_chk-doc.chk-num                                     ~
                              , buf_chk-doc.pay-desk                                    ~
                              , ~{&new-line~}                                             ~
                              , p-netto                                                 ~
                              , accum-pay                                               ~
                            )
              {&display-message}.
              assign
              for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
              buf_chk-doc.correct = no
              {&prefix}view-log = yes
              .
        end. /*if not v-is-petrol-check*/
      end. /*else do:*/
    end.
    if (buf_chk-doc.netto >= 0
        and (buf_chk-doc.chk-type = integer({&rcpt-return})
            or
            buf_chk-doc.chk-type = integer({&rcpt-return-write-off})
            )
        and not ({&prefix}is-100-discnt
                  and buf_chk-doc.netto <= (if buf_chk-doc.cash-rate > 1
                                        then 0.001 * buf_chk-doc.cash-rate
                                        else 0.01)
                  and buf_chk-doc.chk-type = integer({&rcpt-return}))
        )
    or (buf_chk-doc.netto < 0
        and (buf_chk-doc.chk-type = integer({&rcpt-sale})
                            or
                            buf_chk-doc.chk-type = integer({&rcpt-write-off}))
        and not ({&prefix}is-100-discnt
                  and abs(buf_chk-doc.netto) < (if buf_chk-doc.cash-rate > 1
                                          then 0.001 * buf_chk-doc.cash-rate
                                          else 0.01)
                  and buf_chk-doc.chk-type = integer({&rcpt-sale}))
        )
    then do:
        assign
        for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
        &scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный&2" + ~
                                "Сумма нетто &3 не соответствует типу чека: &4" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_chk-doc.netto ~
                                , ~{&receipt-name~} ~
                              )
        {&display-message}.
        &undefine receipt-code
    end.
    if (v-is-z-rep
    or  v-is-shft-open-close)
    and buf_chk-doc.discnt <> 0 then do:
    &scop receipt-code string(buf_chk-doc.chk-type)
        assign
        for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
&scop  my-messsage substitute("!!!Чек &1 - ошибочный&2" + ~
                                "В чеке типа &3 не может быть скидок!" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , ~{&receipt-name~}) ~
        {&display-message}.
    end.
    if v-is-petrol-check
    or v-is-inventory
    or v-is-ord-check
    then do:
      if accum-pay <> 0
      or (accum-pay-count <> 0 
            and lookup(string(buf_chk-doc.chk-type), ({&rcpt-tech-refuell} + "," + {&rcpt-unlock-trans} + "," + {&rcpt-trans-transfer} + "," + {&rcpt-trans-cancell})) = 0)
      or (buf_chk-doc.discnt <> 0 and not v-is-ord-check)
      then do:
        assign
        for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
  &scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message substitute("!!!Чек &1 - ошибочный&2" + ~
                              "В чеке типа &3 не может быть платежей и/или скидок!" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , ~{&receipt-name~})
        {&my-message}.
      end.
    end. /*v-is-petrol-check*/
    else do:
      if v-is-z-rep
      or v-is-shft-open-close
      or buf_chk-doc.chk-type = integer({&income-corr}) or buf_chk-doc.chk-type = integer({&expense-corr}) /* Чеки коррекции */
      then do:
      end.
      else do:
        if (
        ((ACCUM-pay  = 0)
        and (buf_chk-doc.sub-discnt = 0
            or
            (buf_chk-doc.chk-type <> integer({&rcpt-sale})
            and
            buf_chk-doc.chk-type <> integer({&rcpt-write-off})
            )
            )
          and not ({&prefix}is-100-discnt
                  and
                  accum-pay-count > 0)
          )
        OR
          (NOT ( (accum-pay > 0) = (buf_chk-doc.netto > 0)) and buf_chk-doc.sub-discnt = 0
            and not ({&prefix}is-100-discnt
                                and accum-pay-count > 0
                                and accum-pay = 0
                                and buf_chk-doc.netto = 0
                                )
          )
        )
        and not
          (abs(abs(accum-pay) - abs(buf_chk-doc.netto)) < 0.01
          and ({&prefix}is-100-discnt
              and accum-pay-count > 0
              and accum-pay = 0
              )
          )
        and not 
          (accum-pay < 0 
           and buf_chk-doc.chk-type = int({&rcpt-return})
           and round(buf_chk-doc.netto,8) = 0
           and {&prefix}is-100-discnt
          )  
        then do:
          assign
          for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
          buf_chk-doc.correct = no
          {&prefix}view-log = yes
          .
          if aCCUM-pay = 0
          and
          (buf_chk-doc.sub-discnt = 0
            or (buf_chk-doc.chk-type <> integer({&rcpt-sale})
                and
                buf_chk-doc.chk-type <> integer({&rcpt-write-off}))
            )
          and not ({&prefix}is-100-discnt and accum-pay-count > 0)
          then do:
&scop my-message  substitute( ~
                                    "!!!Чек &1 - ошибочный&2" + ~
                                    "Сумма оплат = 0" ~
                                    , buf_chk-doc.doc-code ~
                                    , ~{&new-line~} ~
                                  )
            {&display-message}.
          end. /*if aCCUM-pay = 0*/
          else do:
&scop my-message  substitute( ~
                                    "!!!Чек &1 - ошибочный&2" + ~
                                    "Сумма оплат и сумма по товарам имеют разные знаки!" ~
                                    , buf_chk-doc.doc-code ~
                                    , ~{&new-line~} ~
                                  )
            {&display-message}.
          end. /*ACCUM0OPAY <> 0*/
        end.
        else dO:
          if ABS(  ACCUM-pay - buf_chk-doc.netto ) > 0.0000000001 then do:
            if accum-pay = 0
            and {&prefix}is-100-discnt then do:
              assign
              for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
              buf_chk-doc.correct = no
              {&prefix}view-log = yes
              .
&scop  my-message substitute( ~
                                      "!!!Чек &1 - ошибочный&2" + ~
                                      "Сумма нетто <> 0 для чека с 100% скидкой!" ~
                                      , buf_chk-doc.doc-code ~
                                      , ~{&new-line~} ~
                                    )
              {&display-message}.
            end.
            else do:
              assign
              temp-d =  ABS(ACCUM-pay) - ABS(buf_chk-doc.netto)
              corr-sign = 1
              .
              if not v-is-annu-check then
              run libchkvl_set-corr-discnt in this-procedure (
                                                     input p-context-bh
                                                    ,buffer buf_chk-doc
                                                    ,input temp-d
                                                    ,input yes
                                                    ,input yes
                                                    ,input corr-sign
                                                    ,input-output v-write-off-sum
                                                    ,input-output for-chk-type
                                                    ,input-output var-discnt-id
                                                    ) .
            end.
          end.
        end.
        /*проверка сумм из воздуха*/
          FOR EACH t-gds No-LOCK WHERE
                  t-gds.drc = recid(buf_chk-doc):
          if t-gds.doc-qnty <> 0 or abs(t-gds.price-sum - t-gds.discnt-sum) > 0.0005 then do:
            IF  NOT (t-gds.doc-qnty > 0) = (t-gds.price-sum - t-gds.discnt-sum > 0) OR
                NOT (t-gds.doc-qnty < 0) = (t-gds.price-sum - t-gds.discnt-sum < 0) OR
                    ((t-gds.doc-qnty < 0) AND (buf_chk-doc.netto > 0)) OR
                    ((t-gds.doc-qnty > 0) AND (buf_chk-doc.netto < 0))  then do:
              if (abs(t-gds.price-sum - t-gds.discnt-sum) = 0
              AND
              (
              (
                (t-gds.doc-qnty <> 0
                AND t-gds.is-modificator)
                or
                (t-gds.is-null-price and t-gds.b-code <> ?)
              )
              or (t-gds.doc-qnty <> 0
                and
                ({&prefix}is-100-discnt AND ACCUM-PAY-COUNT > 0)
                )
                )
              )
              or (abs(abs(t-gds.price-sum) - abs(t-gds.discnt-sum)) < 0.01
                  and
                  {&prefix}is-100-discnt)
              then do:
                /*для модификаторов это разрешено и режим 100 скидки нам все ухайдакает*/
              end.
              else do:
                assign
                for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
                buf_chk-doc.correct = no
                .
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный&2" +  ~
                            "По товару с бар-кодом &3, проданном &4 строками чека, имеются несоответствия количества и суммы" + ~
                            "&5 либо имеются несоответствия типа чека (продажа/возврат) знаку товарной суммы" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , t-gds.b-code ~
                            , t-gds.num-lines ~
                            , ~{&new-line~} ~
                          )
                {&display-message}.
              end.
            END.
          END.
        END.
        FOR EACH t-pay No-LOCK WHERE
                  t-pay.drc = recid(buf_chk-doc):
          if t-pay.tot-rubl <> 0
          or t-pay.tot-base <> 0
          then do:
            IF (({&prefix}r-b = {&r-b-rubl}
                and
                t-pay.tot-rubl < 0)
              AND (buf_chk-doc.netto > 0)
              )
          OR
          (({&prefix}r-b = {&r-b-base}
              and
              t-pay.tot-base < 0)
              AND (buf_chk-doc.netto > 0)
            )
            or
          (({&prefix}r-b = {&r-b-rubl}
              and
              t-pay.tot-rubl > 0)
              AND (buf_chk-doc.netto < 0)
            )
            or
          (({&prefix}r-b = {&r-b-base}
              and
              t-pay.tot-base > 0)
              AND (buf_chk-doc.netto < 0)
            )
            or
            ((t-pay.tot-rubl >= 0) <> (t-pay.tot-base >= 0))
          then do:
              assign
              for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
              buf_chk-doc.correct = no
              .
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный&2" + ~
                            "По платежу с кодом &3, с &4 строками оплат чека, имеются несоответствия количества и суммы" + ~
                            "&5 либо имеются несоответствия типа чека (продажа/возврат) знаку суммы платежа" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , t-pay.pay-code ~
                            , t-pay.num-lines ~
                            , ~{&new-line~} ~
                          )
              {&display-message}.
            END.
          END. /*if t-pay.tot-rubl <> 0 */
        END.
      end. /*else do: not v-is-z-rep*/
    end. /*not v-is-petrol-check and not annu and not inventory*/
  end. /*if not v-is-annu-check*/
  
  if ChkGdsPromo(buf_chk-doc.doc-code) then
     v-promo-sum = GetPromoSum(buf_chk-doc.doc-code).
  else v-promo-sum = 0.   
  
  assign
  buf_chk-doc.tot-doc = buf_chk-doc.tot-doc + v-promo-sum
  buf_chk-doc.discnt = buf_chk-doc.discnt + v-promo-sum 
  buf_chk-doc.d-pcnt = if buf_chk-doc.tot-doc = 0
                    then 0
                    else ( buf_chk-doc.discnt / buf_chk-doc.tot-doc * 100 )
  .
  if buf_chk-doc.chk-type = integer({&rcpt-annu})
  or buf_chk-doc.chk-type = integer({&rcpt-ord-sale-closed})
  or buf_chk-doc.chk-type = integer({&rcpt-ord-return-closed})
  or buf_chk-doc.chk-type = integer({&rcpt-ord-return-closed})
  then do:
    assign
    buf_chk-doc.tot-doc = 0
    buf_chk-doc.netto = 0
    buf_chk-doc.discnt = 0
    buf_chk-doc.sub-discnt = 0
    buf_chk-doc.doc-qnty = 0
    .
  end.
  assign
  buf_chk-doc.office = RIGHT-TRIM(for-chk-type, {&comma-char}) +
                       (if not p-close-check
                        then ({&comma-char} + {&ready})
                        else '')
  buf_chk-doc.whole-send-news = v-pos-type-int
  buf_chk-doc.correct =  (if
                      replace(replace(replace(replace(buf_chk-doc.office
                                                    , {&gds-goods}
                                                    , '':U)
                                            , {&gds-office}
                                            , '':U)
                                      , {&ready}
                                      , '':U)
                              , {&comma-char}
                              , '':U) = '':U
                      then (if buf_chk-doc.correct = ?
                            or buf_chk-doc.correct = yes
                            then yes
                            else no)
                      else no)
  .
  /* чеки с пустым полем типа */
  find first ub.chk-gds no-lock where ub.chk-gds.doc-code = buf_chk-doc.doc-code no-error.
  if trim(buf_chk-doc.office) = "" and not available ub.chk-gds then
      buf_chk-doc.office = {&gds-goods}.
  if v-pos-type-int <> integer({&cd-type-magia-xml-int})  then p-prev-code = "" .    /* иной раз помогает */
end. /*doe*/
error-status:error = no.
&undefine display-message
end procedure. /* libchkvl_getcheck */

procedure libchkvl_set-corr-discnt private:
define input parameter p-context-bh as handle no-undo .
define parameter buffer buf_chk-doc for ub.chk-doc.
define input parameter p-corr-value as decimal no-undo .
define input parameter p-fix-discnt as logical no-undo .
define input parameter p-fix-netto  as logical no-undo .
define input parameter p-corr-sign as integer no-undo .
define input-output parameter p-write-off-sum as decimal no-undo .
define input-output parameter for-chk-type as character no-undo .
define input-output parameter p-discnt-id as integer no-undo .

&scop prefix p-context-bh::

&glob display-message  if valid-handle(v-log-handle) then run write-log-and-file in v-log-handle ( ~
              input 1 ~
            , input log-file-name ~
            , input 1 ~
            , input ~{&my-message~} )


DEFINE VARIABLE nd                         as   logical             no-undo .
DEFINE VARIABLE var-gds-for-discnt         as decimal               no-undo .
define variable v-old-discnt               as decimal               no-undo .
define variable v-log-handle as handle no-undo .
define variable v-old-corr-discnt-rank as decimal no-undo.
define variable v-fttwd as logical no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf0_chk-discnt for ub.chk-discnt.
do
on error undo, return error
:
  /*                                    p-corr-value > 0   оплаты > товаров ==> наценка     */

  if p-context-bh::p-log-file-name <> ""
  and p-context-bh::p-log-file-name <> ? then do:
    log-file-name = p-context-bh::p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  v-log-handle = p-context-bh::p-log-handle.

  assign
  nd = yes
  .
  if  LOOKUP({&amount}, for-chk-type ) > 0 then do:
    FOR EACH buf_chk-gds WHERE
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
    by buf_chk-gds.line-num:
      nd = no.
      leave.
    end.
  end.
  else do:
    _repeat:
      FOR EACH buf_chk-gds WHERE
                buf_chk-gds.doc-code = buf_chk-doc.doc-code,
          FIRST t-gds where
                t-gds.b-code = buf_chk-gds.b-code AND
                t-gds.drc = recid(buf_chk-doc)
                :
        v-old-corr-discnt-rank = t-gds.corr-discnt-rank.
        if t-gds.first-line-num = 0
        or t-gds.first-line-num > buf_chk-gds.line-num
        then do:
          t-gds.first-line-num = buf_chk-gds.line-num.
        end.
        if t-gds.was-return and t-gds.doc-qnty <> 0 then do:
        t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 2.
        end.
        v-fttwd = no.
        assign
        v-fttwd = {&prefix}tt-wd-bh:find-first( substitute(' where doc-code = "&1" and record-type = 0 and line-type = &2 and line-num = &3 '
                                                             , buf_chk-gds.doc-code
                                                             , integer({&discnt-gds-without-discnt})
                                                             , buf_chk-gds.line-num
                                                             ))


        no-error
        .
        if v-fttwd then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 3.
        end.
        if t-gds.was-return and t-gds.doc-qnty = 0 then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 4.
        end.
        if buf_chk-gds.price-base < abs(p-corr-value / buf_chk-gds.doc-qnty)
        and not( p-fix-netto = yes and p-corr-value > 0) then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 5.
        end.
        if t-gds.was-write-off  then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 6.
        end.
        if (buf_chk-gds.price-base <= buf_chk-gds.discnt - 0.2) then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 7.
        end.
        if buf_chk-doc.chk-type = integer({&rcpt-return-write-off})
        or buf_chk-doc.chk-type = integer({&rcpt-write-off}) then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 8.
        end.
        if {&prefix}is-100-discnt
        and buf_chk-doc.d-pcnt = 100
        then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 9.
        end.
        if t-gds.corr-discnt-rank = v-old-corr-discnt-rank then do:
          assign
            t-gds.corr-discnt-rank = 0
            t-gds.first-line-num = buf_chk-gds.line-num
          .
        end.
        if t-gds.price-sum = t-gds.discnt-sum then t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 10.
        if buf_chk-gds.discnt <> 0 then do:
        t-gds.corr-discnt-rank = t-gds.corr-discnt-rank - 0.1.
        end.
        if buf_chk-gds.doc-qnty = 1 then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank - 0.1.
        end.
      if t-gds.corr-discnt-rank <= 0
        then do:
          nd = no.
          leave _repeat.
        end.
      END. /*for each buf_chk-gds */
    if not available t-gds
    or t-gds.corr-discnt-rank > 0
    then do:
      find first  t-gds where
              t-gds.drc = recid(buf_chk-doc) use-index icorr-discnt no-error .
    end.
  end.
  /*if available t-gds
  and nd = yes
  and t-gds.corr-discnt-rank / t-gds.num-lines > 2 then do:
    assign
    for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
    nd = yes
    buf_chk-doc.correct = no
    .
&scop my-message  substitute( ~
                        ("!!!Чек &1 - ошибочный. &2 В чеке должна быть хотя бы одна строка, не подвергавшаяся операции ОТМЕНА ТОВАРА,&2" + ~
                          " И/ИЛИ с товаром, на который разрешено начислять скидку на итог/подитог&2" + ~
                          " для того, чтобы на эту строку можно было уложить корректирующую скидку округления &2" + ~
                          "ЕСЛИ ЭТО ВОЗМОЖНО - удалите &3 и создайте новый - без отмененных строк - в пункте меню Сервис/Магазин/Создание чека") ~
                        , buf_chk-doc.doc-code ~
                        , ~{&new-line~} ~
                        , buf_chk-doc.doc-code ~
                      )
    {&display-message}.
    {&prefix}view-log = yes.
  end.*/
  if nd = yes
  and (not available t-gds
  or (available t-gds and t-gds.first-line-num = 0)
  )
  then do:
    assign
    for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
    nd = yes
    buf_chk-doc.correct = no
    .
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2  - не найдена строка чека, на которую можно уложить погрешность по суммам!" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                          )
    {&display-message}.
    {&prefix}view-log = yes.
  end.
  if available t-gds
  and t-gds.first-line-num > 0
  and t-gds.corr-discnt-rank <= 0
  then do:
    find first buf_chk-gds where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
        and buf_chk-gds.line-num = t-gds.first-line-num.
    nd = no.
  end.
  if available t-gds
  and t-gds.first-line-num > 0
  and t-gds.corr-discnt-rank > 0
  then do:
  if t-gds.last-included-in-sale > 0 then  do:
      find first buf_chk-gds where
              buf_chk-gds.doc-code = buf_chk-doc.doc-code
          and buf_chk-gds.line-num = t-gds.last-included-in-sale  use-index ln.
      nd = no.
    end.
    else do:
      assign
      for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
      nd = yes
      buf_chk-doc.correct = no
      .
  &scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный. &2  - не найдена строка чека, на которую можно уложить погрешность по суммам!" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                            )
      {&display-message}.
      {&prefix}view-log = yes.
    end.
  end.
  if not nd then do:
    assign
    var-gds-for-discnt = buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
    v-old-discnt = buf_chk-gds.discnt
    buf_chk-gds.discnt = ( buf_chk-gds.discnt * abs( buf_chk-gds.doc-qnty ) - p-corr-value * p-corr-sign ) /  abs( buf_chk-gds.doc-qnty )
    /*
    p-write-off-sum = (if buf_chk-gds.write-off-code <> ? and buf_chk-gds.write-off-code <> 0
                      then (p-write-off-sum - buf_chk-gds.doc-qnty * (buf_chk-gds.discnt - v-old-discnt))
                      else p-write-off-sum)
      */
    buf_chk-doc.discnt = if p-fix-discnt
                      then (buf_chk-doc.discnt - (IF buf_chk-doc.chk-type = integer({&rcpt-sale})
                                              then p-corr-value
                                              else ( - p-corr-value)) * p-corr-sign)
                      else buf_chk-doc.discnt
    /*если temp-d > 0 значит оплаты больше товаров и скидка по abs должна уменьшиться*/
    /*если temp-d < 0 значит оплаты меньше товаров и скидка по abs должна увеличиться*/

    buf_chk-doc.netto = if p-fix-netto
                    then (buf_chk-doc.netto +  (IF buf_chk-doc.chk-type = integer({&rcpt-sale})
                                            then p-corr-value
                                            else ( - p-corr-value)) * p-corr-sign )
                    else buf_chk-doc.netto
    /*если temp-d > 0 значит оплаты больше товаров и нетто по abs должно увеличится*/
    /*если temp-d < 0 значит оплаты меньше товаров и нетто по abs должно уменьшиться*/

    .
    /*создаем скидку коррекции-округления*/
    create buf0_chk-discnt.
    assign
    buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
    buf0_chk-discnt.line-num = 0
    buf0_chk-discnt.time-oper = buf_chk-doc.chk-time
    buf0_chk-discnt.line-type = integer({&discnt-receipt})
    buf0_chk-discnt.pass-discnt = integer({&discnt-p-auto})
    buf0_chk-discnt.record-type = 2
    buf0_chk-discnt.discnt-id = p-discnt-id + 1
    buf0_chk-discnt.line-sign =  ?
    buf0_chk-discnt.value-type = integer({&discnt-v-abs})
    buf0_chk-discnt.discnt-type = integer({&discnt-t-another})
    buf0_chk-discnt.discnt-value-abs = - p-corr-value * p-corr-sign
    buf0_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
    buf0_chk-discnt.object-sum = var-gds-for-discnt
    buf0_chk-discnt.discnt-value-pcnt = if var-gds-for-discnt <> 0
                                    then (buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum) * 100
                                    else 0
    buf0_chk-discnt.object-line-num = buf_chk-gds.line-num
    buf0_chk-discnt.pay-desk = buf_chk-doc.pay-desk
    buf0_chk-discnt.obj-code = buf_chk-doc.obj-code
    buf0_chk-discnt.obj-type = buf_chk-doc.obj-type
    buf0_chk-discnt.chk-date = buf_chk-doc.chk-date
    buf0_chk-discnt.chk-time = buf_chk-doc.chk-time
    p-discnt-id = p-discnt-id + 1
    .
    if abs(buf0_chk-discnt.discnt-value-abs) > 0.01
    and search("getcheck.dbg") <> ? then do:
      assign
      for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
&scop my-message  substitute( ~
                            "!!!Значение скидки погрешности превышает пороговое (0.01)&1" + ~
                            "   № чека в БД&2" ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.doc-code ~
                          )
      {&display-message}.
    end.
  end.
end. /*doe*/
&undefine display-message
end procedure. /* set-corr-discnt */

procedure libchkvl_process-chk-pay private:
define input parameter p-context-bh as handle no-undo .
define parameter buffer buf_chk-doc for ub.chk-doc.
define parameter buffer buf_chk-pay for ub.chk-pay.
define input-output parameter p-noexchrate as logical no-undo .
define input-output parameter for-chk-type as character no-undo .

DEFINE VARIABLE v-pay_code                   like ub.cash-pay.cdpay-code   no-undo .
DEFINE VARIABLE v-curr_code                  like ub.cash-pay.curr-code    no-undo .
/*вспомогательные хранят значения курса валюты для валюты оплаты не в р_у_б и не в base*/
DEFINE VARIABLE curr-rate                    like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                   like ub.curr-shop.exch-scale  no-undo .
define variable v-get-qnty-method            as character   no-undo .
define variable v-get-qnty-method1           as character   no-undo .
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.

{ str/pos_context.i "vars" v- }
&scop prefix v-

&glob display-message  if valid-handle({&prefix}p-log-handle) then run write-log-and-file in {&prefix}p-log-handle ( ~
              input 1 ~
            , input log-file-name ~
            , input 1 ~
            , input ~{&my-message~} )


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  { str/pos_context.i "vars=temp-table" v- p-context-bh:: }

  if {&prefix}p-log-file-name <> ""
  and {&prefix}p-log-file-name <> ? then do:
    log-file-name = {&prefix}p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  
  if buf_chk-doc.chk-type = integer({&income-corr}) or buf_chk-doc.chk-type = integer({&expense-corr})
  then do :
    assign
      buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum
      buf_chk-pay.exch-date = buf_chk-doc.chk-date
      buf_chk-pay.exch-time = buf_chk-doc.chk-time
      buf_chk-pay.exch-rate = 1
      buf_chk-pay.exch-scale = 1
      buf_chk-pay.calc-rate = 1
    .
    
    return .
  end .

  assign
  buf_chk-pay.is-error = ?
  v-pay_code = buf_chk-pay.pay-code
  v-curr_code = buf_chk-pay.curr-code
  .
  if buf_chk-doc.chk-type = integer({&rcpt-z-rep}) then do:
    if buf_chk-pay.pay-code <> 0 then do:
&scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message  substitute( ~
                          "!!!Чек &1 - ошибочный&2" + ~
                          "В чеке типа &3 не может быть строк оплат" ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , ~{&receipt-name~} ~
                        )
      {&display-message}.
      assign
      buf_chk-pay.is-error = yes
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
    end.
    if buf_chk-pay.curr-code <> 0 then do:
&scop my-message  substitute( ~
                          "!!!Чек &1 - ошибочный&2" + ~
                          "Показания фискальных счетчиков в чеке типа &3&2должны быть в нац. валюте" ~
                          , buf_chk-doc.doc-code ~
                          ,~{&new-line~} ~
                          ,~{&receipt-name~} ~
                        )
      {&display-message}.
      assign
      buf_chk-pay.is-error = yes
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
    end.
  end. /*if buf_chk-doc.chk-type = integer({&rcpt-z-rep}) then do:*/
  else do:
    FIND FIRST buf_cash-pay WHERE
              buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
              buf_cash-pay.curr-code = buf_chk-pay.curr-code NO-LOCK NO-ERROR.
    if NOT available buf_cash-pay then do:
&scop my-message  substitute( ~
                          "!!!Чек &1 - ошибочный&2" +  ~
                          "В базе отсутствует тип кассового платежа c кодом &3 и кодом валюты &4" ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code  ~
                        )
      {&display-message}.
      assign
      buf_chk-pay.is-error = yes
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
    end.
    else do: /*avail buf_cash-pay*/
      if buf_cash-pay.cdpay-code = {&prefix}cre-pay and
          buf_chk-pay.pay-card <> "":U then do:
        if buf_chk-doc.d-card = "" then do:
          assign
          buf_chk-doc.d-card = buf_chk-pay.pay-card
          .
        end.
        else do:
          if buf_chk-doc.d-card <> buf_chk-pay.pay-card then do:
&scop my-message substitute( ~
                          "!!!Чек &1 - ошибочный&2" + ~
                          "Номер дисконтной карты в шапке чека: &3 не равен номеру дисконтной карты &4: по платежу В КРЕДИТ" ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-doc.d-card ~
                          , buf_chk-pay.pay-card ~
                        )
            {&display-message}.
            assign
            buf_chk-pay.is-error = yes
            for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
            buf_chk-doc.correct = no
            {&prefix}view-log = yes
            .
          end.
        end. /*buf_chk-doc.d-card <> "":U */
      end. /*buf_cash-pay.cdpay-code = cre-pay*/
      if buf_cash-pay.is-credit = yes
      and buf_cash-pay.cdpay-code <> {&prefix}cre-pay then do:
&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Нельзя использовать тип кассового платежа c кодом &3 и кодом валюты &4&2" + ~
                          "Данный тип кассового платежа определен как ПЛАТЕЖ В КРЕДИТ, &5") ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code  ~
                          , (if {&prefix}cre-pay = 0 ~
                            then substitute("а такие платежи для фирмы &1 запрещены - настроечный параметр iscredit", {&prefix}host-code) ~
                            else substitute("а  для фирмы &1 используется платеж &2 как платеж В КРЕДИТ - см настройки фирмы в АРМ Администратор", {&prefix}host-code, {&prefix}cre-pay) ~
                            ) ~
                        )
        {&display-message}.
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
      end. /*if buf_cash-pay.is-credit = yes and*/
      if buf_cash-pay.is-credit = yes
      and buf_chk-doc.d-card = "":U then do:
&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Нельзя использовать тип кассового платежа c кодом &3 и кодом валюты &4&2" + ~
                          "Данный тип кассового платежа определен как ПЛАТЕЖ В КРЕДИТ,&2 но в чеке не указана карта клиента") ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                        )
        {&display-message}.
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
      end. /*if buf_cash-pay.is-credit = yes*/
      /*проверим не ведомость ли это*/
      if buf_cash-pay.register > 0
      and buf_chk-doc.d-card = '':U then do:
&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Нельзя использовать тип кассового платежа c кодом &3 и кодом валюты &4&2" + ~
                          "Данный тип кассового платежа определен как ВЕДОМОСТЬ,&2 но в чеке не указана карта клиента") ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                        )
        {&display-message}.
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
      end. /*if buf_cash-pay.register > 0*/
      if available buf_wealth then release buf_wealth.
      if available buf_wth-par then release buf_wth-par.
      v-get-qnty-method = ''.
      if buf_cash-pay.wth-code > 0 then do:
        find first buf_wealth no-lock where
                  buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
        if not available buf_wealth then do:
&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается на несуществующую МЦ с кодом &5")  ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                          , buf_cash-pay.wth-code )

          {&display-message}.
          assign
          buf_chk-pay.is-error = yes
          for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
          buf_chk-doc.correct = no
          {&prefix}view-log = yes
          v-get-qnty-method = ''
          .
        end. /*if not available buf_wealth then do:*/
      end. /*if buf_cash-pay.wth-code > 0 then do:*/
      if available buf_wealth then do:
        if buf_chk-pay.src-val <> 0 then do:
          find first buf_wth-par no-lock where
                    buf_wth-par.wth-code = buf_cash-pay.wth-code
                and ((buf_wth-par.par-val = integer(buf_chk-pay.src-val)
                     and buf_wth-par.par-rate > 1)
                or ( buf_wth-par.par-rate < 1
                    and buf_wth-par.par-val = integer(buf_chk-pay.src-val * 100)
                    )
                     )
                and (
                     buf_chk-pay.par-code = 0
                     or buf_wth-par.par-code  = buf_chk-pay.par-code)
                no-error.
          if not available buf_wth-par then do:
&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается&2на несуществующий номинал &5 для МЦ &6")  ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                          , buf_chk-pay.src-val ~
                          , buf_wealth.wth-name )

            {&display-message}.
            assign
            buf_chk-pay.is-error = yes
            for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
            buf_chk-doc.correct = no
            {&prefix}view-log = yes
            v-get-qnty-method = ''
            .
          end. /*if not available buf_wth-par then do:*/
        end. /*if buf_chk-pay.src-val <> 0 then do:*/
        assign
        v-get-qnty-method1 = (if buf_chk-pay.src-val <> 0
                             then {&wth-qnty-val-qnty}
                             else buf_wealth.get-qnty-method)
        v-get-qnty-method = v-get-qnty-method1
        .
        case v-get-qnty-method1:
          when '' then do:
            assign
            buf_chk-pay.wth-code = 0
            buf_chk-pay.doc-qnty = 0
            buf_chk-pay.par-val = 0
            .
          end.
          when {&wth-qnty-sum} then do:
            /*для наличных - кол-во равно сумме*/
            assign
            buf_chk-pay.doc-qnty = buf_chk-pay.tot-sum
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)
            .
          end.
          when {&wth-qnty-sdoc}  then do:
            /*для карт - кол-во равно 1*/
            assign
            buf_chk-pay.doc-qnty = 1
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)

            .
          end.
          when {&wth-qnty-val-qnty} then do:
            define variable v-qnty as decimal no-undo .
            define variable v-val as integer   no-undo .
            if available buf_wth-par then do:
              assign
              v-qnty = buf_chk-pay.tot-sum / buf_chk-pay.src-val / (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              v-val = buf_chk-pay.tot-sum / buf_chk-pay.src-qnty * (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              buf_chk-pay.doc-qnty = (if v-qnty = buf_chk-pay.src-qnty
                                     then v-qnty
                                     else 0)
              buf_chk-pay.par-val = (if v-val = buf_chk-pay.src-val
                                     then v-val
                                     else 0)
              buf_chk-pay.par-code = (if buf_chk-pay.par-code = 0
                                      then buf_wth-par.par-code
                                      else buf_chk-pay.par-code)
              .
            end.
            else do:
              assign
              buf_chk-pay.doc-qnty = 0
              buf_chk-pay.par-val = 0
              buf_chk-pay.wth-code = 0
              .

&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Для типа кассового платежа c кодом &3 и кодом валюты &4&2 должен быть задан номинал соответствущей МЦ &5")  ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                          , buf_wealth.wth-name ~
                        )
              {&display-message}.
              assign
              buf_chk-pay.is-error = yes
              for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
              buf_chk-doc.correct = no
              {&prefix}view-log = yes
              v-get-qnty-method =''
              .
            end. /*else if available buf_wth-par then do:*/
          end. /*when {&wth-qnty-val-qnty} then do:*/
        end case.
      end. /*if available buf_wealth*/
    end. /*avail buf_cash-pay*/
  end. /*обычные оплаты*/
  CASE ABS(buf_chk-pay.curr-code):
    when 0 then do:
      assign
      buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum
      buf_chk-pay.exch-date = buf_chk-doc.chk-date
      buf_chk-pay.exch-time = buf_chk-doc.chk-time
      buf_chk-pay.exch-rate = 1
      buf_chk-pay.exch-scale = 1
      buf_chk-pay.calc-rate = 1
      .
      if {&prefix}cas-curs and {&prefix}r-b = {&r-b-base} then do:
        assign
        buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_chk-pay.cash-rate .
      end.
      else do:
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input {&prefix}obj-type
                                                     , input {&prefix}obj-code
                                                      ,input {&prefix}base-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop
        then
        buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_curr-shop.exch-rate * buf_curr-shop.exch-scale.
        else do:
          if NOT p-NoExchRate then do:
&scop my-message substitute( ~
                          "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-doc.obj-type ~
                          , buf_chk-doc.obj-code ~
                          , buf_chk-doc.chk-date  ~
                        )
            {&display-message}.
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          {&prefix}view-log = yes
          .
        end.
      end. /* NOT cas-curs*/
    end. /*when buf_chk-pay.curr-code = 0*/
    when {&prefix}base-code then do:
      assign
      buf_chk-pay.tot-base = buf_chk-pay.tot-sum
      .
      if {&prefix}cas-curs then do:
        assign
        buf_chk-pay.tot-rubl = if {&prefix}r-b = {&r-b-base}
                            then buf_chk-pay.tot-sum * buf_chk-doc.cash-rate
                            else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
        buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
        .
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input {&prefix}obj-type
                                                      ,input {&prefix}obj-code
                                                      ,input {&prefix}base-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop then do:
          assign
          buf_chk-pay.exch-date = buf_curr-shop.exch-date
          buf_chk-pay.exch-time = buf_curr-shop.exch-time
          buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
          buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
          .
        end.
        else do:
          if NOT p-NoExchRate then do:
&scop my-message substitute( ~
                          "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-doc.obj-type ~
                          , buf_chk-doc.obj-code ~
                          , buf_chk-doc.chk-date ~
                        )
            {&display-message}.
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          {&prefix}view-log = yes
          .
        end.
      end. /*if cas-curs*/
      else do:
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input {&prefix}obj-type
                                                      ,input {&prefix}obj-code
                                                      ,input {&prefix}base-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop then do:
          assign
          buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          buf_chk-pay.exch-date = buf_curr-shop.exch-date
          buf_chk-pay.exch-time = buf_curr-shop.exch-time
          buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
          buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
          buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          .
        end.
        else do:
          if NOT p-NoExchRate then do:
&scop my-message substitute( ~
                        "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                        , buf_chk-doc.doc-code ~
                        , ~{&new-line~} ~
                        , buf_chk-doc.obj-type ~
                        , buf_chk-doc.obj-code ~
                        , buf_chk-doc.chk-date ~
                      )
            {&display-message}.
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          {&prefix}view-log = yes
          .
        end.
      end. /*NOT {&prefix}cas-curs*/
    end. /*when {&prefix}base-code*/
    otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
      if {&prefix}cas-curs then do:
        assign
        buf_chk-pay.tot-base = if {&prefix}r-b = {&r-b-base}
                            then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
                            else buf_chk-pay.tot-sum
        buf_chk-pay.tot-rubl = if {&prefix}r-b = {&r-b-base}
                            then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate * buf_chk-doc.cash-rate
                            else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
        buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
        .
        if not {&prefix}r-b = {&r-b-base} then do:
          if available buf_curr-shop then release buf_curr-shop.
          run libchkval_get-curr-shop in this-procedure (
                                                         input {&prefix}obj-type
                                                        ,input {&prefix}obj-code
                                                        ,input {&prefix}base-code
                                                        ,input buf_chk-doc.chk-date
                                                        ,input buf_chk-doc.chk-time
                                                        ,buffer buf_curr-shop) no-error.
          if available buf_curr-shop then do:
            assign
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            .
          end.
          else do:
            if NOT p-NoExchRate then do:
&scop my-message substitute( ~
                          "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6" ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , {&prefix}base-code    ~
                          , buf_chk-doc.obj-type ~
                          , buf_chk-doc.obj-code ~
                          , buf_chk-doc.chk-date ~
                        )
              {&display-message}.
              p-NoExchRate = TRUE .
            end.
            assign
            for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
            buf_chk-doc.correct = no
            buf_chk-pay.is-error = yes
            {&prefix}view-log = yes
            .
          end.
          /*определим  для */
          if available buf_curr-shop then release buf_curr-shop.
          run libchkval_get-curr-shop in this-procedure (
                                                         input {&prefix}obj-type
                                                        ,input {&prefix}obj-code
                                                        ,input buf_chk-pay.curr-code
                                                        ,input buf_chk-doc.chk-date
                                                        ,input buf_chk-doc.chk-time
                                                        ,buffer buf_curr-shop) no-error.
          if available buf_curr-shop then do:
            assign
            buf_chk-pay.exch-date = buf_curr-shop.exch-date
            buf_chk-pay.exch-time = buf_curr-shop.exch-time
            buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
            buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
            .
          end.
          else do:
            if NOT p-NoExchRate then do:
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &6 для &3&4 на дату &5" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.obj-type ~
                            , buf_chk-doc.obj-code ~
                            , buf_chk-doc.chk-date ~
                            , buf_chk-pay.curr-code ~
                          )
            {&display-message}.
            end.
            assign
            for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
            buf_chk-doc.correct = no
            buf_chk-pay.is-error = yes
            {&prefix}view-log = yes
            .
          end.
        end. /*if not {&prefix}r-b = {&r-b-base} then do:*/
      end. /*if cas-curs then do:*/
      else do:
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input {&prefix}obj-type
                                                      ,input {&prefix}obj-code
                                                      ,input buf_chk-pay.curr-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.

        if available buf_curr-shop then do:
          assign
          buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          curr-rate = buf_curr-shop.exch-rate
          curr-scale = buf_curr-shop.exch-scale
          buf_chk-pay.exch-date = buf_curr-shop.exch-date
          buf_chk-pay.exch-time = buf_curr-shop.exch-time
          buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
          buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
          buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          .
          FIND LAST buf_curr-shop WHERE
                    buf_curr-shop.obj-type = {&prefix}obj-type
                AND  buf_curr-shop.obj-code = {&prefix}obj-code
                AND  buf_curr-shop.curr-code = {&prefix}base-code
                AND ( ( buf_curr-shop.exch-date = buf_chk-doc.chk-date
                      AND
                      buf_curr-shop.exch-time <= buf_chk-doc.chk-time )
                    OR  buf_curr-shop.exch-date < buf_chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop  then do:
            assign
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum * (curr-rate / curr-scale)  /
                                buf_curr-shop.exch-rate * buf_curr-shop.exch-scale
            .
          end.
          else do:
            if NOT p-NoExchRate then do:
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.obj-type ~
                            , buf_chk-doc.obj-code ~
                            , buf_chk-doc.chk-date ~
                          )
              {&display-message}.
            end.
            assign
            for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
            buf_chk-doc.correct = no
            buf_chk-pay.is-error = yes
            {&prefix}view-log = yes
            .
          end. /*not avail buf_curr-shop*/
        end.
        else do:
          if NOT p-NoExchRate then do:
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-pay.curr-code ~
                            , buf_chk-doc.obj-type ~
                            , buf_chk-doc.obj-code ~
                            , buf_chk-doc.chk-date ~
                          )
            {&display-message}.
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          {&prefix}view-log = yes
          .
        end.
      end.  /*NOT cas-curs*/
    end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
  END CASE.
  { str/set-tpay.i buf_chk-doc buf_chk-pay }
    if t-pay.byval  = 'error' then do:
  &scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" + ~
                              "Для типа кассового платеже с кодом &1 и кодом валюты &2 СМЕШАНЫ строки с пустыми и непустыми номиналами" ~
                              , buf_chk-doc.doc-code ~
                              , buf_chk-doc.chk-num  ~
                              , buf_chk-doc.pay-desk  ~
                              , ~{&new-line~} ~
                              , t-pay.pay-code ~
                              , t-pay.curr-code ~
                            )
      {&display-message}.
      assign
      for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
    end.
    if buf_chk-pay.is-error = ? then
  buf_chk-pay.is-error = no.
end. /*doe*/
&undefine display-message
end procedure. /* process-buf_chk-pay */

procedure libchkval_get-curr-shop :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-curr-code as integer no-undo .
define input parameter p-date as date no-undo .
define input parameter p-time as integer no-undo .
define parameter buffer buf_curr-shop for ub.curr-shop.

find last  buf_curr-shop where
           buf_curr-shop.obj-type = p-obj-type
      AND  buf_curr-shop.obj-code = p-obj-code
      AND  buf_curr-shop.curr-code = p-curr-code
      AND ( ( buf_curr-shop.exch-date = p-date
            AND
            buf_curr-shop.exch-time <= p-time )
          OR  buf_curr-shop.exch-date < p-date ) NO-ERROR .

end procedure. /* libchkval_get-curr-shop */


procedure libchkvl_getwcheck :
define input parameter p-context-bh as handle no-undo . /*контекс разбора - таблица pos_context.i */
define input parameter p-wmode as character no-undo . /*прием чеков {&add-def} или ручное создание/редактирование {&update}*/
define input parameter p-edit-mode as character no-undo . /*ручное добавление {&add-def} редактирование {&update}*/
define input parameter p-close-check as logical no-undo .
define input parameter p-get-cash-shift as logical no-undo .
define input parameter p-netto as decimal no-undo .
define input-output parameter p-mc-prev-code like ub.chk-doc.doc-code no-undo .


{ str/pos_context.i "vars" v- }
&scop prefix v-

define variable v-cashier-psn-code like ub.person.psn-code no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
define variable par-val_ as integer no-undo .
define variable accum-pay as decimal no-undo .
define variable accum-pay-inst as decimal no-undo .
define variable v-pay-code as integer no-undo .
define variable v-wth-code as integer no-undo .
define variable v-is-error as logical no-undo .
define variable v-line-num as integer no-undo .
define variable v-inst-sum as decimal no-undo .
define variable v-curr-code as integer no-undo .
DEFINE VARIABLE curr-rate                    like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                   like ub.curr-shop.exch-scale  no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-get-qnty-method1           as character   no-undo .
define variable v-pos-type-int               as integer                 no-undo .

define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_curr-shop for ub.curr-shop.

&glob display-message  if valid-handle({&prefix}p-log-handle) then run write-log-and-file in {&prefix}p-log-handle ( ~
              input 1 ~
            , input log-file-name ~
            , input 1 ~
            , input ~{&my-message~} )

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if p-mc-prev-code = "":U then return.
  FIND buf_chk-doc share-lock WHERE
        buf_chk-doc.doc-code = p-mc-prev-code NO-ERROR.
  if not avail buf_chk-doc then do:
    return.
  end.
  for each t-wth:
    delete t-wth.
  end.
  { str/pos_context.i "vars=temp-table" v- p-context-bh:: }
  if {&prefix}p-log-file-name <> ""
  and {&prefix}p-log-file-name <> ? then do:
    log-file-name = {&prefix}p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  /*предварительно установим так int тип кассы - если мы разбираем подбором файлов , которые уже давно валяются в директории,
  а не считаны с определенной кассы в данный момент - то нам придется это переопределеить!!!
  */
  &scop pos-type-char-code {&prefix}pos-type
  v-pos-type-int = {&pos-type-int-code}.

  /*проверка и дообработка шапки чека*/
  if buf_chk-doc.pay-desk <> 0 then do:
    find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
        AND buf_cash-desk.obj-code = buf_chk-doc.obj-code
        AND buf_cash-desk.pos-type = {&prefix}pos-type no-error .
  end.
  if buf_chk-doc.pay-desk = 0
  or not available buf_cash-desk
  or buf_cash-desk.is-del then do:
    if can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = 0
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = {&cd-type-autotank}
                    )
          and can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = buf_chk-doc.pay-desk
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = {&cd-type-autotank}
                    and buf_chk-doc.pay-desk > 0 )
    then do:
      v-pos-type-int = integer({&cd-type-autotank-int}).
    end.
    else do:
      find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
          AND buf_cash-desk.obj-code = buf_chk-doc.obj-code no-error.
      if available buf_cash-desk then do:
        &scop pos-type-char-code buf_cash-desk.pos-type
        v-pos-type-int = {&pos-type-int-code}.
      end.
      else do:
        v-pos-type-int = integer({&cd-type-unknown-int}).
      end.
      assign
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      {&prefix}view-log = yes
      buf_chk-doc.correct = no
      .
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.pay-desk ~
                            , {&prefix}pos-type)
      {&display-message}.
    end.
  end.
  if p-edit-mode <> "shift-change" then do:
    assign
    buf_chk-doc.shift-date = if {&prefix}t-shft < 0
                               AND buf_chk-doc.chk-time < abs({&prefix}t-shft)
                               then (buf_chk-doc.chk-date - 1)
                               else (if buf_chk-doc.src-shift-date = ?
                                    then buf_chk-doc.chk-date
                                    else (if p-wmode = {&update}
                                          then
                                                (if index(buf_chk-doc.ps, "shift!") = 0
                                                then buf_chk-doc.src-shift-date
                                                else buf_chk-doc.shift-date)
                                          else  buf_chk-doc.src-shift-date)
                                     )
    .
  end.
  if {&prefix}cas-shft then do:
    /*если включены смены на кассах*/
    /*смена объекта в БО соответствующая смене чека уже закрыта или
    в спуле нет смены*/
    if buf_chk-doc.shift-name = '':U
    or trim(buf_chk-doc.shift-name, '0') = '':U
      then /*тогда чек ошибочен*/ do:
      assign
      for-chk-type = for-chk-type + {&shift-err} + {&comma-char}
      buf_chk-doc.shift-date = 01/01/1990
      buf_chk-doc.correct = no
      .
    end.
    else do:
      if {&prefix}v-shft > 0 then do:
        run str/v-shftg.p (
                            buffer buf_chk-doc
                          ,input {&prefix}parparentproc
                          ,input {&prefix}p-log-handle
                          ,input p-wmode
                          ,input {&prefix}obj-type
                          ,input {&prefix}obj-code
                          ,input {&prefix}v-shft
                          ,input {&prefix}t-shft
                          ,input {&shift-err}
                          ,input-output for-chk-type
                          ,input-output {&prefix}view-log
                            ).

      end. /* if v-shft > 0*/
      if {&prefix}shift-on then do:
        /*в поле .shift-num должен положить порядковый номер смены*/
        if (p-wmode = {&update} and  index(buf_chk-doc.ps, "shift!") = 0)
        or (p-wmode <> {&update})  then do:
          run libchkvl_get-shift-num in this-procedure (
                                               input buf_chk-doc.obj-type
                                              ,input buf_chk-doc.obj-code
                                              ,input buf_chk-doc.shift-date
                                              ,input buf_chk-doc.shift-name
                                              ,output buf_chk-doc.shift-num) no-error .
          if error-status:error
          or buf_chk-doc.shift-num = ?
          or buf_chk-doc.shift-num = 0 then do:
          assign
          for-chk-type = for-chk-type + {&shift-err} + {&comma-char}
          buf_chk-doc.shift-num = 0
          buf_chk-doc.correct = no
          .
          end.
        end.
      end. /*if libchkvl_context.shift-on then do:*/
      if (p-wmode = {&update} and index(buf_chk-doc.ps, "shift!") = 0)
      or p-wmode <> {&update}
      then do:
        assign
        shift-name_ = (if p-wmode = {&update}
                      then  (if p-edit-mode = {&add-def}
                              then buf_chk-doc.shift-name
                              else buf_chk-doc.src-shift-name)
                      else buf_chk-doc.src-shift-name
                      )
        .
        if {&prefix}cas-shft then do:
          if p-get-cash-shift then do:
            { str/libchkvl_get-cash-shift.i
            p-context-bh:handle
            buf_shift-cash
            buf_chk-doc.pay-desk
            buf_chk-doc.src-shift-date
            shift-name_
            ?
            buf_chk-doc.chk-date
            buf_chk-doc.chk-time
            0
            no-error
            }
          end.
        end. /*if {&prefix}cas-shft then do:*/
      end.
    end. /*  if buf_chk-doc.shift-name = 0 */
  end. /* if {&prefix}cas-shft*/
  assign
  v-cashier-psn-code = gbclcode-is-this-db-role ( input {&role-cashier}, input {&prefix}db-num, input buf_chk-doc.cashier, input buf_chk-doc.chk-date)
  no-error
  .
  if v-cashier-psn-code = 0 then do:
    assign
    for-chk-type = for-chk-type + {&staff-err} + {&comma-char}
    buf_chk-doc.correct = no
    {&prefix}view-log = yes
    .
&scop my-message substitute( ~
                            "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о кассире &3" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.cashier ~
                          )
    {&display-message}.
  end.
  else do:
    assign
    buf_chk-doc.cashier-psn-code = v-cashier-psn-code
    .
  end.
  /*проверка и дообработка строк чека*/
  for each buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
    assign
    buf_chk-pay.is-error = no
    accum-pay = accum-pay +  buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
    .
    if available buf_wealth then release buf_wealth.
    if available buf_wth-par then release buf_wth-par.
    FIND FIRST buf_cash-pay WHERE
              buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
              buf_cash-pay.curr-code = buf_chk-pay.curr-code NO-LOCK NO-ERROR.
    if NOT available buf_cash-pay
    or buf_cash-pay.wth-code = 0
    then do:
&scop my-message  substitute( ~
                              "!!!Чек МЦ &1 - ошибочный&2" + ~
                              (if not available buf_cash-pay   ~
                              then "В базе отсутствует тип кассового платежа c кодом &3 и кодом валюты &4" ~
                              else "Типу кассового платежа с кодом &3 и кодом валюты &4 не соответствует МЦ") ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , buf_chk-pay.pay-code ~
                              , buf_chk-pay.curr-code ~
                            )
      {&display-message}.
      assign
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
    end.
    else do:
      assign
      buf_chk-pay.wth-code = buf_cash-pay.wth-code
      .
      v-get-qnty-method = ''.
      find first buf_wealth no-lock where
                buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
      if not available buf_wealth then do:
&scop my-message  substitute( ~
                        ("!!!Чек &1 - ошибочный&2" + ~
                        "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается на несуществующую МЦ с кодом &5")  ~
                        , buf_chk-doc.doc-code ~
                        , ~{&new-line~} ~
                        , buf_chk-pay.pay-code ~
                        , buf_chk-pay.curr-code ~
                        , buf_cash-pay.wth-code )

        {&display-message}.
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        v-get-qnty-method = ''
        .
      end. /*if not available buf_wealth then do:*/
      if available buf_wealth then do:
        if buf_chk-pay.src-val <> 0 then do:
          find first buf_wth-par no-lock where
                    buf_wth-par.wth-code = buf_cash-pay.wth-code
                and ((buf_wth-par.par-rate >= 1 and buf_wth-par.par-val = integer(buf_chk-pay.src-val))
                     or
                     (buf_wth-par.par-rate < 1 and buf_wth-par.par-val = integer(buf_chk-pay.src-val) * 100))

                and (buf_chk-pay.par-code = 0
                     or
                     buf_wth-par.par-code  = buf_chk-pay.par-code)
                no-error.
          if not available buf_wth-par then do:
&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается&2на несуществующий номинал &5 для МЦ &6")  ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                          , buf_chk-pay.src-val ~
                          , buf_wealth.wth-name )

            {&display-message}.
            assign
            buf_chk-pay.is-error = yes
            for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
            buf_chk-doc.correct = no
            {&prefix}view-log = yes
            v-get-qnty-method = ''
            .
          end. /*if not available buf_wth-par then do:*/
        end. /*if buf_chk-pay.src-val <> 0 then do:*/
        assign
        v-get-qnty-method1 = (if buf_chk-pay.src-val <> 0
                              then {&wth-qnty-val-qnty}
                              else buf_wealth.get-qnty-method)
        v-get-qnty-method = v-get-qnty-method1
        .
        case v-get-qnty-method1:
          when '' then do:
            assign
            buf_chk-pay.wth-code = 0
            buf_chk-pay.doc-qnty = 0
            buf_chk-pay.par-val = 0
            .
          end.
          when {&wth-qnty-sum} then do:
            /*для наличных - кол-во равно сумме*/
            assign
            buf_chk-pay.doc-qnty = buf_chk-pay.tot-sum
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)
            .
          end.
          when {&wth-qnty-sdoc}  then do:
            /*для карт - кол-во равно 1*/
            assign
            buf_chk-pay.doc-qnty = 1
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)

            .
          end.
          when {&wth-qnty-val-qnty} then do:
            define variable v-qnty as decimal no-undo .
            define variable v-val as integer   no-undo .
            if available buf_wth-par then do:
              assign
              v-qnty = buf_chk-pay.tot-sum / buf_chk-pay.src-val / (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              v-val = buf_chk-pay.tot-sum / buf_chk-pay.src-qnty * (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              buf_chk-pay.doc-qnty = (if v-qnty = buf_chk-pay.src-qnty
                                     then v-qnty
                                     else 0)
              buf_chk-pay.par-val = (if v-val = buf_chk-pay.src-val
                                     then v-val
                                     else 0)
              buf_chk-pay.par-code = (if buf_chk-pay.par-code = 0
                                      then buf_wth-par.par-code
                                      else buf_chk-pay.par-code)
              .
            end.
            else do:
              assign
              buf_chk-pay.doc-qnty = 0
              buf_chk-pay.par-val = 0
              buf_chk-pay.wth-code = 0
              .

&scop my-message  substitute( ~
                          ("!!!Чек &1 - ошибочный&2" + ~
                          "Для типа кассового платежа c кодом &3 и кодом валюты &4&2 должен быть задан номинал соответствущей МЦ &5")  ~
                          , buf_chk-doc.doc-code ~
                          , ~{&new-line~} ~
                          , buf_chk-pay.pay-code ~
                          , buf_chk-pay.curr-code ~
                          , buf_wealth.wth-name ~
                        )
              {&display-message}.
              assign
              buf_chk-pay.is-error = yes
              for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
              buf_chk-doc.correct = no
              {&prefix}view-log = yes
              v-get-qnty-method =''
              .
            end. /*else if available buf_wth-par then do:*/
          end. /*when {&wth-qnty-val-qnty} then do:*/
        end case.
      end. /*if available buf_wealth*/
      CASE ABS(buf_chk-pay.curr-code):
        when 0 then do:
          assign
          buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum
          buf_chk-pay.exch-date = buf_chk-doc.chk-date
          buf_chk-pay.exch-time = buf_chk-doc.chk-time
          buf_chk-pay.exch-rate = 1
          buf_chk-pay.exch-scale = 1
          buf_chk-pay.calc-rate = 1
          .
          if {&prefix}cas-curs and v-r-b = {&r-b-base} then do:
            assign
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_chk-pay.cash-rate .
          end.
          else do:
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                        , input buf_chk-doc.obj-code
                                                          ,input v-base-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop
            then
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_curr-shop.exch-rate * buf_curr-shop.exch-scale.
            else do:
               &scop my-message substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , buf_chk-doc.obj-type ~
                              , buf_chk-doc.obj-code ~
                              , buf_chk-doc.chk-date  ~
                            )
                {&display-message}.

            end.
          end. /* NOT cas-curs*/
        end. /*when buf_chk-pay.curr-code = 0*/
        when v-base-code then do:
          assign
          buf_chk-pay.tot-base = buf_chk-pay.tot-sum
          .
          if {&prefix}cas-curs then do:
            assign
            buf_chk-pay.tot-rubl = if v-r-b = {&r-b-base}
                                then buf_chk-pay.tot-sum * buf_chk-doc.cash-rate
                                else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
            buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
            .
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                          ,input buf_chk-doc.obj-code
                                                          ,input v-base-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop then do:
              assign
              buf_chk-pay.exch-date = buf_curr-shop.exch-date
              buf_chk-pay.exch-time = buf_curr-shop.exch-time
              buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
              buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
              .
            end.
            else do:

    &scop my-message substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , buf_chk-doc.obj-type ~
                              , buf_chk-doc.obj-code ~
                              , buf_chk-doc.chk-date ~
                            )
                {&display-message}.
            end.
          end. /*if cas-curs*/
          else do:
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                          ,input buf_chk-doc.obj-code
                                                          ,input v-base-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop then do:
              assign
              buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              buf_chk-pay.exch-date = buf_curr-shop.exch-date
              buf_chk-pay.exch-time = buf_curr-shop.exch-time
              buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
              buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
              buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              .
            end.
            else do:

    &scop my-message substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-doc.obj-type ~
                            , buf_chk-doc.obj-code ~
                            , buf_chk-doc.chk-date ~
                          )
                {&display-message}.
            end.
          end. /*NOT {&prefix}cas-curs*/
        end. /*when {&prefix}base-code*/
        otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
          if {&prefix}cas-curs then do:
            assign
            buf_chk-pay.tot-base = if v-r-b = {&r-b-base}
                                then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
                                else buf_chk-pay.tot-sum
            buf_chk-pay.tot-rubl = if v-r-b = {&r-b-base}
                                then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate * buf_chk-doc.cash-rate
                                else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
            buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
            .
            if not v-r-b = {&r-b-base} then do:
              if available buf_curr-shop then release buf_curr-shop.
              run libchkval_get-curr-shop in this-procedure (
                                                            input buf_chk-doc.obj-type
                                                            ,input buf_chk-doc.obj-code
                                                            ,input v-base-code
                                                            ,input buf_chk-doc.chk-date
                                                            ,input buf_chk-doc.chk-time
                                                            ,buffer buf_curr-shop) no-error.
              if available buf_curr-shop then do:
                assign
                buf_chk-pay.tot-base = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
                .
              end.
              else do:
    &scop my-message substitute( ~
                              "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , V-base-code    ~
                              , buf_chk-doc.obj-type ~
                              , buf_chk-doc.obj-code ~
                              , buf_chk-doc.chk-date ~
                            )
                  {&display-message}.
              end.
              /*определим  для */
              if available buf_curr-shop then release buf_curr-shop.
              run libchkval_get-curr-shop in this-procedure (
                                                            input buf_chk-doc.obj-type
                                                            ,input buf_chk-doc.obj-code
                                                            ,input buf_chk-pay.curr-code
                                                            ,input buf_chk-doc.chk-date
                                                            ,input buf_chk-doc.chk-time
                                                            ,buffer buf_curr-shop) no-error.
              if available buf_curr-shop then do:
                assign
                buf_chk-pay.exch-date = buf_curr-shop.exch-date
                buf_chk-pay.exch-time = buf_curr-shop.exch-time
                buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
                buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
                .
              end.
              else do:

    &scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &6 для &3&4 на дату &5" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_chk-doc.obj-type ~
                                , buf_chk-doc.obj-code ~
                                , buf_chk-doc.chk-date ~
                                , buf_chk-pay.curr-code ~
                              )
                {&display-message}.

              end.
            end. /*if not {&prefix}r-b = {&r-b-base} then do:*/
          end. /*if cas-curs then do:*/
          else do:
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                          ,input buf_chk-doc.obj-code
                                                          ,input buf_chk-pay.curr-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.

            if available buf_curr-shop then do:
              assign
              buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              curr-rate = buf_curr-shop.exch-rate
              curr-scale = buf_curr-shop.exch-scale
              buf_chk-pay.exch-date = buf_curr-shop.exch-date
              buf_chk-pay.exch-time = buf_curr-shop.exch-time
              buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
              buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
              buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              .
              FIND LAST buf_curr-shop WHERE
                        buf_curr-shop.obj-type = buf_chk-doc.obj-type
                    AND  buf_curr-shop.obj-code = buf_chk-doc.obj-code
                    AND  buf_curr-shop.curr-code = v-base-code
                    AND ( ( buf_curr-shop.exch-date = buf_chk-doc.chk-date
                          AND
                          buf_curr-shop.exch-time <= buf_chk-doc.chk-time )
                        OR  buf_curr-shop.exch-date < buf_chk-doc.chk-date ) NO-ERROR .
              if available buf_curr-shop  then do:
                assign
                buf_chk-pay.tot-base = buf_chk-pay.tot-sum * (curr-rate / curr-scale)  /
                                    buf_curr-shop.exch-rate * buf_curr-shop.exch-scale
                .
              end.
              else do:

    &scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_chk-doc.obj-type ~
                                , buf_chk-doc.obj-code ~
                                , buf_chk-doc.chk-date ~
                              )
                  {&display-message}.

              end. /*not avail buf_curr-shop*/
            end.
            else do:

    &scop my-message  substitute( ~
                                "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6" ~
                                , buf_chk-doc.doc-code ~
                                , ~{&new-line~} ~
                                , buf_chk-pay.curr-code ~
                                , buf_chk-doc.obj-type ~
                                , buf_chk-doc.obj-code ~
                                , buf_chk-doc.chk-date ~
                              )
                {&display-message}.


            end.
          end.  /*NOT cas-curs*/
        end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
      END CASE.
      { str/set-twth.i buf_chk-doc buf_chk-pay }
    end. /*avail buf_cash-pay*/
  end. /* for each buf_chk-pay */
  if p-netto <> ? then do:
    if  ((p-netto = 0 and accum-pay <> 0)
    or (p-netto <> 0 and  ABS(ABS(p-netto - ACCUM-pay) / p-netto ) > 0.01))
    then do:
  &scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" + ~
                              "Сумма транзакции не совпадает с суммой оплат по чеку&4" + ~
                              "Сумма транзакции = &5, сумма оплат по чеку = &6&4" +  ~
                              "Обратитесь к администратору Вашей системы" ~
                              , buf_chk-doc.doc-code ~
                              , buf_chk-doc.chk-num  ~
                              , buf_chk-doc.pay-desk  ~
                              , ~{&new-line~} ~
                              , p-netto ~
                              , accum-pay ~
                            )
      {&display-message}.
      assign
      for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .
    end.
  end. /*if p-netto <> ? then do:*/
  /*проверка строк чека МЦ на совместность их друг с другом*/
  var-sum-r-b = 0.
  for each t-wth No-LOCK where
          t-wth.drc = recid(buf_chk-doc):
    if t-wth.byval  = 'error' then do:
  &scop my-message  substitute( ~
                              "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" + ~
                              "Для типа кассового платеже с кодом &1 и кодом валюты &2 СМЕШАНЫ строки с пустыми и непустыми номиналами" ~
                              , buf_chk-doc.doc-code ~
                              , buf_chk-doc.chk-num  ~
                              , buf_chk-doc.pay-desk  ~
                              , ~{&new-line~} ~
                              , t-wth.pay-code ~
                              , t-wth.curr-code ~
                            )
      {&display-message}.
      assign
      for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
      buf_chk-doc.correct = no
      {&prefix}view-log = yes
      .

    end.
    if buf_chk-doc.chk-type <> 0 then do:
      if ( (string(buf_chk-doc.chk-type) = {&encashment} or string(buf_chk-doc.chk-type) = {&cd-expense}) AND
        t-wth.sum > 0) OR
        (string(buf_chk-doc.chk-type) = {&cd-fund} AND t-wth.sum < 0)
        then do:
        assign
        for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
        buf_chk-doc.correct = no
        {&prefix}view-log = yes
        .
  &scop receipt-code string(buf_chk-doc.chk-type)
  &scop my-message  substitute( ~
                              "!!!Чек МЦ &1 - ошибочный&2Знак суммы по всем строкам МЦ не соответствует типу чека &3&2" + ~
                              "Код оплаты МЦ: &4 код валюты МЦ &5" ~
                              , buf_chk-doc.doc-code ~
                              , ~{&new-line~} ~
                              , {&receipt-name} ~
                              , t-wth.pay-code ~
                              , t-wth.curr-code ~
                            )
        {&display-message}.
      end. /* ( (string(buf_chk-doc.chk-type) = {&encashment} or string(buf_chk-doc.chk-type) = {&cd-expense}) AND*/
      if string(buf_chk-doc.chk-type) = {&pay-transfer} then do:
        assign
        var-sum-r-b = var-sum-r-b + t-wth.sum-r-b
        .
      end.
    end. /* if buf_chk-doc.chk-type <> 0:*/
  end. /*  for each t-wth No-LOCK where*/
  if string(buf_chk-doc.chk-type) = {&pay-transfer} AND ABS(var-sum-r-b) > 0.05 then do:
    assign
    for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
    buf_chk-doc.correct = no
    {&prefix}view-log = yes
    .
    &scop receipt-code string(buf_chk-doc.chk-type)
&scop my-message  substitute( ~
                            "!!!Чек МЦ &1 - ошибочный&2Знак суммы по всем строкам МЦ не соответствует типу чека &3" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , {&receipt-name} ~
                          )
    {&display-message}.
  end.

  assign
  buf_chk-doc.PS = (if index(buf_chk-doc.ps, 'shift!':U) > 0
                  then '!shift!'
                  else (if index(buf_chk-doc.ps, '!':U) > 0 then '!' else '':U)
                  ) + RIGHT-TRIM(for-chk-type, {&comma-char})
  buf_chk-doc.whole-send-news = v-pos-type-int
  buf_chk-doc.office = RIGHT-TRIM(for-chk-type, {&comma-char}) +
                       (if not p-close-check
                        then ({&comma-char} + {&ready})
                        else '')
  buf_chk-doc.correct = if replace(replace(for-chk-type
                                            , {&ready}
                                            , '':U)
                                    , {&comma-char}
                                    , '') = '':U
                         then (if buf_chk-doc.correct = ?
                               or buf_chk-doc.correct = yes
                               then yes
                               else no)
                        else no
  .
  /* чеки с пустым полем типа */
  find first ub.chk-gds no-lock where ub.chk-gds.doc-code = buf_chk-doc.doc-code no-error.
  if trim(buf_chk-doc.office) = "" and not available ub.chk-gds then
      buf_chk-doc.office = {&gds-goods}.
  p-mc-prev-code = "" .    /* иной раз помогает */
end. /*doe*/
end procedure. /* libchkwl_getwcheck */
