block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdcthisv.p $
$Archive: ref/cdcthisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории типов ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/

define input parameter p-emitent-host-code  like ub.c-dis-card-type.emitent-host-code no-undo .
define input parameter p-type               like ub.c-dis-card-type.type no-undo .
define input parameter p-chip-num like ub.c-cli-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-dis-card-type.corr-user-db-num no-undo .
define input parameter p-obj-type like ub.c-dis-card-type.obj-type no-undo .
define input parameter p-obj-code like ub.c-dis-card-type.obj-code no-undo .
define input parameter p-host-code like ub.c-dis-card-type.host-code no-undo .
define input parameter p-subject like ub.c-dis-card-type.subject no-undo .
define input parameter p-action   like ub.c-dis-card-type.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdcthisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cdcthisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории ДК".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ rul/calldscr.i }
{ ref/disdctru.i }
{ ref/dct-attr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess  as character no-undo .

define buffer buf_c-dis-card-type for ub.c-dis-card-type.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-dis-card-type no-lock where
          buf_c-dis-card-type.emitent-host-code = p-emitent-host-code
      AND buf_c-dis-card-type.type              = p-type
      AND buf_c-dis-card-type.host-code         = p-host-code
      AND buf_c-dis-card-type.obj-type          = p-obj-type
      AND buf_c-dis-card-type.obj-code          = p-obj-code
      AND buf_c-dis-card-type.chip-num = p-chip-num
      AND buf_c-dis-card-type.corr-user-db-num = p-corr-user-db-num  no-error .
if not available buf_c-dis-card-type then do:
  return error .
end.
CASE p-subject:
  when {&table_dis-card-type} then do:
    run dis-card-type-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-card-type-attr} then do:
    run dis-card-type-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-card-mask} then do:
    run dis-card-mask-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_rp-by-call} then do:
    run rp-by-call-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_rule-by-call} then do:
    run rule-by-call-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_rule-call-param} then do:
    run rule-call-param-proc in this-procedure(output p-description) no-error .
  end.

  when {&table_dis-dct-rule} then do:
    run dis-dct-rule-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_hist-nws-option} then do:
    run hist-nws-option-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.

procedure dis-card-type-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-card-type for ub.c-dis-card-type  .

  do
  on error undo, return error return-value
  :
    find first current_c-dis-card-type no-lock where
               current_c-dis-card-type.emitent-host-code = p-emitent-host-code
           AND current_c-dis-card-type.type              = p-type
           AND current_c-dis-card-type.host-code         = p-host-code
           AND current_c-dis-card-type.obj-type          = p-obj-type
           AND current_c-dis-card-type.obj-code          = p-obj-code
           AND current_c-dis-card-type.chip-num          = p-chip-num
           AND current_c-dis-card-type.corr-user-db-num  = p-corr-user-db-num no-error .
    if not avail current_c-dis-card-type then do:
       v-mess = "Неверная ссылка на c-dis-card-type в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
       return error.
    end.

&scop fields-name-list ~
         "card-media,cardname-sent,d-pcnt-byshop,dc-pfx,dcbyshop,dflt-cash-pcnt,dflt-credit-card," + ~
         "dflt-d-pcnt-method,dflt-debet-card,dflt-pcnt,dflt-pcnt-kat,dflt-staff-card,emitent-host-code,fiscal-pay,host-code,lim-kr,mixed-pay," + ~
         "obj-code,obj-type,pay-code,type"

define variable v-label-param as character no-undo .

v-label-param =
  "card-media" + {&delim-par} + "Тип носителя карты" + {&delim-par} + "" + {&delim-flf}
 + "cardname-sent" + {&delim-par} + "На кассу в поле ИМЯ" + {&delim-par} + "" + {&delim-flf}
 + "custom-sent" + {&delim-par} + "На кассу в настраиваемом поле" + {&delim-par} + "" + {&delim-flf}
 + "d-pcnt-byshop" + {&delim-par} + "Скидка по объектам" + {&delim-par} + "" + {&delim-flf}
 + "dc-pfx" + {&delim-par} + "Префикс карты" + {&delim-par} + "" + {&delim-flf}
 + "dcbyshop" + {&delim-par} + "Только СВОИ карты" + {&delim-par} + "" + {&delim-flf}
 + "dflt-credit-card" + {&delim-par} + "Кредитная карта" + {&delim-par} + "" + {&delim-flf}
 + "dflt-d-pcnt-method" + {&delim-par} + "Тип скидки" + {&delim-par} + "" + {&delim-flf}
 + "dflt-debet-card" + {&delim-par} + "Дебетовая карта" + {&delim-par} + "" + {&delim-flf}
 + "dflt-staff-card" + {&delim-par} + "Карта персонала" + {&delim-par} + "" + {&delim-flf}
 + "emitent-host-code" + {&delim-par} + "Код фирмы-эмитента" + {&delim-par} + "" + {&delim-flf}
 + "fiscal-pay" + {&delim-par} + "Фискальный платеж" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Своя организация (код)" + {&delim-par} + "" + {&delim-flf}
 + "lim-kr" + {&delim-par} + "Лимит кредита по умолчанию" + {&delim-par} + "" + {&delim-flf}
 + "mixed-pay" + {&delim-par} + "Смешанная оплата" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта учета" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "pay-code" + {&delim-par} + "Касс.платеж" + {&delim-par} + "" + {&delim-flf}
 + "service-db-num" + {&delim-par} + "№ обслуживающей БД" + {&delim-par} + "" + {&delim-flf}
 + "type" + {&delim-par} + "Тип карты" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-card-type:handle
                                            ,input  {&table_dis-card-type}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* dis-card-proc */


procedure dis-card-type-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .

define buffer current_c-dis-card-type-attr for ub.c-dis-card-type-attr  .

  do
  on error undo, return error return-value
  :
    find first current_c-dis-card-type-attr no-lock where
               current_c-dis-card-type-attr.emitent-host-code = p-emitent-host-code
           AND current_c-dis-card-type-attr.type = p-type
           AND current_c-dis-card-type-attr.host-code = p-host-code
           AND current_c-dis-card-type-attr.obj-type = p-obj-type
           AND current_c-dis-card-type-attr.obj-code = p-obj-code
           AND current_c-dis-card-type-attr.chip-num = p-chip-num
           AND current_c-dis-card-type-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-dis-card-type-attr.attr-code = buf_c-dis-card-type.attr-code
           no-error .
    if not avail current_c-dis-card-type-attr then do:
       v-mess = "Неверная ссылка на c-dis-card-type-attr в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.
    run dct-attr-tooltip in this-procedure (
                input  string(current_c-dis-card-type-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .

&scop fields-name-list "attr-value,obj-type,obj-code,host-code,attr-code,type,emitent-host-code"

define variable v-label-param as character no-undo .

v-label-param =
  "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "type" + {&delim-par} + "Тип карты" + {&delim-par} + "" + {&delim-flf}
 + "emitent-host-code" + {&delim-par} + "Код фирмы-эмитента" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-card-type-attr:handle
                                            ,input  {&table_dis-card-type-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* dis-card-type-attr-proc */

function view-cc-run returns character ( input p-cc-run-chr as character):
if p-cc-run-chr = '' then p-cc-run-chr = {&dcm-cc-algo-no}.
&scop dcm-cc-algo-code p-cc-run-chr
return  {&dcm-cc-algo-name}.
end.
function view-use-on returns character ( input p-use-on-chr as character):
if p-use-on-chr = '' then p-use-on-chr = {&dcm-cd-th}.
&scop use-on-cd-code p-use-on-chr
return  {&use-on-cd-name}.
end.


procedure dis-card-mask-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-card-mask for ub.c-dis-card-mask  .

  do
  on error undo, return error
  :
    find first current_c-dis-card-mask no-lock where
               current_c-dis-card-mask.chip-num = p-chip-num
           AND current_c-dis-card-mask.corr-user-db-num = p-corr-user-db-num
           AND current_c-dis-card-mask.mask-num = buf_c-dis-card-type.mask-num
           no-error .
    if not avail current_c-dis-card-mask then do:
       v-mess = "Неверная ссылка на c-dis-card-mask в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "emitent-host-code,host-code,cli-code,cli-mask,cli-type,mask,mask-num,obj-code,obj-type,rank,stts,cc-run,use-on,type"

              define variable v-label-param as character no-undo .

v-label-param =
  "emitent-host-code" + {&delim-par} + "Код фирмы-эмитента" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "cli-code" + {&delim-par} + "Код контрагента" + {&delim-par} + "" + {&delim-flf}
 + "cli-mask" + {&delim-par} + "Маска КОРОТКОГО №" + {&delim-par} + "" + {&delim-flf}
 + "cli-type" + {&delim-par} + "Тип контрагента" + {&delim-par} + "" + {&delim-flf}
 + "mask" + {&delim-par} + "Маска" + {&delim-par} + "" + {&delim-flf}
 + "mask-num" + {&delim-par} + "Номер маски" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "rank" + {&delim-par} + "Ранг (приоритет)" + {&delim-par} + "" + {&delim-flf}
 + "stts" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "cc-run" + {&delim-par} + "Алгоритм КЦ" + {&delim-par} + "view-cc-run" + {&delim-flf}
 + "use-on" + {&delim-par} + "Используется на" + {&delim-par} + "view-use-on" + {&delim-flf}
 + "type" + {&delim-par} + "Тип карты" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-card-mask:handle
                                            ,input  {&table_dis-card-mask}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* dis-card-mask-proc */


procedure rp-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rp-by-call for ub.c-rp-by-call .

  do
  on error undo, return error
  :
    find first current_c-rp-by-call no-lock where
               current_c-rp-by-call.chip-num = buf_c-dis-card-type.chip-num
           AND current_c-rp-by-call.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
           AND current_c-rp-by-call.call_id = buf_c-dis-card-type.uniq-key-rec no-error .
    if not avail current_c-rp-by-call then do:
       v-mess = "Неверная ссылка на c-rp-by-call в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "call_id,call#_id,profile_id"

define variable v-label-param as character no-undo .

v-label-param =
  "call_id" + {&delim-par} + "Точка вызова" + {&delim-par} + "calldscr" + {&delim-flf}
 + "call#_id" + {&delim-par} + "Уник.идент.точки вызова" + {&delim-par} + "" + {&delim-flf}
 + "profile_id" + {&delim-par} + "Профайл" + {&delim-par} + "" .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-rp-by-call:handle
                                            ,input  {&table_rp-by-call}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* rp-by-call-proc */

procedure rule-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-by-call for ub.c-rule-by-call .

  do
  on error undo, return error
  :
    find first current_c-rule-by-call no-lock where
               current_c-rule-by-call.chip-num = buf_c-dis-card-type.chip-num
           AND current_c-rule-by-call.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
           AND current_c-rule-by-call.call_id = buf_c-dis-card-type.uniq-key-rec no-error .
    if not avail current_c-rule-by-call then do:
       v-mess = "Неверная ссылка на c-rule-by-call в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "call_id,call#_id,profile_id,can-calc,can-run,codex_id,ruleset_id,order_id,algo-des,rule_id,is_dynamic"

define variable v-label-param as character no-undo .

v-label-param =
  "call_id" + {&delim-par} + "Точка вызова" + {&delim-par} + "calldscr" + {&delim-flf}
 + "call#_id" + {&delim-par} + "Уник.идент.точки вызова" + {&delim-par} + "" + {&delim-flf}
 + "profile_id" + {&delim-par} + "Профайл" + {&delim-par} + ""  + {&delim-flf}
 + "can-calc" + {&delim-par} + "Включено" + {&delim-par} + ""  + {&delim-flf}
 + "can-run" + {&delim-par} + "Может быть включено" + {&delim-par} + ""  + {&delim-flf}
 + "codex_id" + {&delim-par} + "Кодекс" + {&delim-par} + ""  + {&delim-flf}
 + "ruleset_id" + {&delim-par} + "Набор правил" + {&delim-par} + ""  + {&delim-flf}
 + "order_id" + {&delim-par} + "Порядок вызова" + {&delim-par} + ""  + {&delim-flf}
 + "rule_id" + {&delim-par} + "№ правила" + {&delim-par} + ""  + {&delim-flf}
 + "algo-des" + {&delim-par} + "Описание правила" + {&delim-par} + ""  + {&delim-flf}
 + "is_dynamic" + {&delim-par} + "Отключаемое" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-rule-by-call:handle
                                            ,input  {&table_rule-by-call}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.


end procedure. /* rule-by-call-proc */

procedure rule-call-param-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-call-param for ub.c-rule-call-param .

  do
  on error undo, return error
  :
    find first current_c-rule-call-param no-lock where
               current_c-rule-call-param.chip-num = buf_c-dis-card-type.chip-num
           AND current_c-rule-call-param.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
           AND current_c-rule-call-param.call_id = buf_c-dis-card-type.uniq-key-rec no-error .
    if not avail current_c-rule-call-param then do:
       v-mess = "Неверная ссылка на c-rule-call-param в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "call_id,call#_id,profile_id,codex_id,ruleset_id,order_id,rule_id,~
param-des,param-data-type,param-label,param-mode,param-name,param-num,param-value-character,~
param-value-date,param-value-decimal,param-value-integer,param-value-logical"

define variable v-label-param as character no-undo .

v-label-param =
  "call_id" + {&delim-par} + "Точка вызова" + {&delim-par} + "calldscr" + {&delim-flf}
 + "call#_id" + {&delim-par} + "Уник.идент.точки вызова" + {&delim-par} + "" + {&delim-flf}
 + "profile_id" + {&delim-par} + "Профайл" + {&delim-par} + ""  + {&delim-flf}
 + "codex_id" + {&delim-par} + "Кодекс" + {&delim-par} + ""  + {&delim-flf}
 + "ruleset_id" + {&delim-par} + "Набор правил" + {&delim-par} + ""  + {&delim-flf}
 + "order_id" + {&delim-par} + "Порядок вызова" + {&delim-par} + ""  + {&delim-flf}
 + "rule_id" + {&delim-par} + "№ правила" + {&delim-par} + ""  + {&delim-flf}
 + "param-des" + {&delim-par} + "Описание параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-data-type" + {&delim-par} + "Тип данных" + {&delim-par} + ""  + {&delim-flf}
 + "param-2-data-type" + {&delim-par} + "Тип данных2" + {&delim-par} + ""  + {&delim-flf}
 + "param-3-data-type" + {&delim-par} + "Тип данных3" + {&delim-par} + ""  + {&delim-flf}
 + "param-label" + {&delim-par} + "Лейбл параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-mode" + {&delim-par} + "Мода параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-name" + {&delim-par} + "Имя параметра" + {&delim-par} + ""  + {&delim-flf}
 + "p-index" + {&delim-par} + "Индекс" + {&delim-par} + ""  + {&delim-flf}
 + "param-num" + {&delim-par} + "№ параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-character" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-date" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-decimal" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-integer" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-logical" + {&delim-par} + "Значение параметра" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-rule-call-param:handle
                                            ,input  {&table_rule-call-param}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.


end procedure. /* rule-call-param-proc */

procedure dis-dct-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .

define buffer current_c-dis-dct-rule for ub.c-dis-dct-rule  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-dis-dct-rule no-lock where
               current_c-dis-dct-rule.type = p-type
           and current_c-dis-dct-rule.emitent-host-code = p-emitent-host-code
           AND current_c-dis-dct-rule.chip-num = p-chip-num
           AND current_c-dis-dct-rule.corr-user-db-num = p-corr-user-db-num    no-error .
    if not avail current_c-dis-dct-rule then do:
       v-mess = "Неверная ссылка на c-dis-dct-rule в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    run disdctru-name in this-procedure (
                input  current_c-dis-dct-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .

&scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role,host-code,obj-type,obj-code"

define variable v-label-param as character no-undo .

v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Место использ" + {&delim-par} + "cd-type-name-f" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Тип шаблона" + {&delim-par} + "disdctru-get-disc-label"  + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disdctru-get-disc-role-label" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par}  + ""
 .
  run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-dct-rule:handle
                                            ,input  {&table_dis-dct-rule}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* dis-dct-rule-proc */

FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS character ) :
&SCOPED-DEFINE hn-option-val-code p-hn-option
  RETURN {&hn-option-val-name}.   /* Function return value. */

END FUNCTION.

function cd-type-name-f returns character ( input p-cd-type-code as character):
if p-cd-type-code = '':U then return '':U.
&scop cd-type-code p-cd-type-code
return {&cd-type-name}.
end function.


procedure hist-nws-option-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-hist-nws-option for ub.c-hist-nws-option .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:


    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-dis-card-type}
          AND buf_c-table-bind.chip-num-rec     = buf_c-dis-card-type.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-dis-card-type".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-hist-nws-option no-lock where
               curr_c-hist-nws-option.subject-group = {&table_c-dc-hist}
           AND curr_c-hist-nws-option.charkey_one = buf_c-dis-card-type.type
           AND curr_c-hist-nws-option.host-code = buf_c-dis-card-type.emitent-host-code
           AND curr_c-hist-nws-option.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-hist-nws-option.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-hist-nws-option then do:
      v-mess = "Неверная ссылка на c-hist-nws-option в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    assign
    p-description = substitute("&1 (для БД &2)", curr_C-hist-nws-option.option-descr, curr_C-hist-nws-option.db-num).


&scop fields-name-list "option-descr,db-num,hn-id,table-name,subject-group,get-hist-form-nws,hist-from-prim,hist-to-nws,nws-to-hist,smart-nws,nws-to-cd"
define variable v-label-param as character no-undo .

v-label-param =
  "option-descr" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "hn-id" + {&delim-par} + "ID" + {&delim-par} + "" + {&delim-flf}
 + "table-name" + {&delim-par} + "Таблица/Сущность" + {&delim-par} + "" + {&delim-flf}
 + "subject-group" + {&delim-par} + "Группа данных" + {&delim-par} + "" + {&delim-flf}
 + "get-hist-from-nws" + {&delim-par} + "Прием истории из другой УБД" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "hist-from-prim" + {&delim-par} + "Запись истории при непосред.изменении" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "hist-to-nws" + {&delim-par} + "Пересылка ист. в другие БД" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "nws-to-hist" + {&delim-par} + "Создание ист. при приеме по СПН" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "smart-nws" + {&delim-par} + "Оптимизированная маршрутизация" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "nws-to-cd" + {&delim-par} + "Активация посылки на кассу при приеме из СПН" + {&delim-par} + "get-hn-label"
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer({&hn-create}))
                                            ,input  (buf_c-dis-card-type.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-hist-nws-option:handle
                                            ,input  {&table_hist-nws-option}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
  end.
end procedure.



PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  p-mess =
  substitute("История типов ДК: Эмитент &1 тип &2: щепка &6 БД:&7 фирма: &3 объект: &4&5 Предмет изменений &8"
              ,p-emitent-host-code
              ,p-type
              ,p-host-code
              ,p-obj-type
              ,p-obj-code
              ,p-chip-num
              ,p-corr-user-db-num
              ,p-subject) + {&new-line} + p-mess
              .
  CASE p-silent:
    when yes then do:
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.