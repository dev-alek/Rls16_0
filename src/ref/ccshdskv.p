block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ccshdskv.p $
$Archive: ref/ccshdskv.p $

Заполнение временной таблицы для показа изменений по таблицам истории кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/


define input parameter  p-db-num                like  ub.c-cash-desk.db-num             no-undo .
define input parameter  p-obj-code              like  ub.c-cash-desk.obj-code           no-undo .
define input parameter  p-pos-type              like  ub.c-cash-desk.pos-type           no-undo .
define input parameter  p-cash-num              like  ub.c-cash-desk.cash-num           no-undo .
define input parameter  p-attr-code             like  ub.c-cash-desk.attr-code          no-undo .
define input parameter  p-corr-user-db-num      like  ub.c-cash-desk.corr-user-db-num   no-undo .
define input parameter  p-chip-num              like  ub.c-cash-desk.chip-num           no-undo .
define input parameter  p-subject               like  ub.c-cash-desk.subject            no-undo .
define input parameter p-action   like ub.c-cli-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ccshdskv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ccshdskv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории кассы".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cd-attr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-cash-desk for ub.c-cash-desk.

{ ref/tmpchgs.i "SHARED" " " "with-action" }

if p-action = integer({&hn-delete}) then return.
find first buf_c-cash-desk no-lock where
          buf_c-cash-desk.db-num   = p-db-num
      AND buf_c-cash-desk.obj-code = p-obj-code
      AND buf_c-cash-desk.pos-type = p-pos-type
      AND buf_c-cash-desk.cash-num = p-cash-num
      AND buf_c-cash-desk.chip-num = p-chip-num
      AND buf_c-cash-desk.corr-user-db-num = p-corr-user-db-num
      no-error .
if not available buf_c-cash-desk then do:
  return error .
end.

CASE p-subject:
  when {&table_cash-desk} or when "":U then do:
    run cash-desk-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_cash-desk-attr} then do:
    run cash-desk-attr-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.


procedure cash-desk-proc :
define output parameter p-description as character no-undo .

define buffer current_c-cash-desk for ub.c-cash-desk  .


  do
  on error undo, return error
  :
    find first current_c-cash-desk no-lock where
               current_c-cash-desk.db-num   = p-db-num
           AND current_c-cash-desk.obj-code = p-obj-code
           AND current_c-cash-desk.pos-type = p-pos-type
           AND current_c-cash-desk.cash-num = p-cash-num
           AND current_c-cash-desk.corr-user-db-num = p-corr-user-db-num
           AND current_c-cash-desk.chip-num = p-chip-num
           no-error .
    if not avail current_c-cash-desk then do:
       v-mess = "Неверная ссылка на c-cash-desk в таблице c-cash-desk".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    define variable v-label-param as character no-undo .

    &scop fields-name-list  "addr-path,autonomy,cash-num,cash-on,cash-os,db-num,is-del,obj-code,pos-type,remote,version,registration-code,serial-code"

v-label-param =
  "addr-path" + {&delim-par} + "Адрес/путь к кассе" + {&delim-par} + "" + {&delim-flf}
 + "autonomy" + {&delim-par} + "Автономность" + {&delim-par} + "" + {&delim-flf}
 + "cash-num" + {&delim-par} + "Номер кассы" + {&delim-par} + "" + {&delim-flf}
 + "cash-on" + {&delim-par} + "Вкл/выкл" + {&delim-par} + "" + {&delim-flf}
 + "cash-os" + {&delim-par} + "ОС" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "is-del" + {&delim-par} + "Касса удалена" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Магазин" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "remote" + {&delim-par} + "Удаленная" + {&delim-par} + "" + {&delim-flf}
 + "version" + {&delim-par} + "Версия ПО" + {&delim-par} + "" + {&delim-flf}
 + "registration-code" + {&delim-par} + "Регистр.№" + {&delim-par} + "" + {&delim-flf}
 + "serial-code" + {&delim-par} + "Сер.№" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cash-desk.action = integer({&hn-create}))
                                            ,input  (buf_c-cash-desk.action = integer({&hn-delete}))
                                            ,input  buffer current_c-cash-desk:handle
                                            ,input  {&table_cash-desk}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
 end.
end procedure. /* cash-desk-proc */



procedure cash-desk-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-cash-desk-attr for ub.c-cash-desk-attr  .


  do
  on error undo, return error
  :
    find first current_c-cash-desk-attr no-lock where
               current_c-cash-desk-attr.db-num   = p-db-num
           AND current_c-cash-desk-attr.obj-code = p-obj-code
           AND current_c-cash-desk-attr.pos-type = p-pos-type
           AND current_c-cash-desk-attr.cash-num = p-cash-num
           AND current_c-cash-desk-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-cash-desk-attr.chip-num = p-chip-num
           AND current_c-cash-desk-attr.attr-code  = buf_c-cash-desk.attr-code
           no-error .
    if not avail current_c-cash-desk-attr then do:
       v-mess = "Неверная ссылка на c-cash-desk-attr в таблице c-cash-desk".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    run cd-attr-tooltip in this-procedure (
                 input  current_c-cash-desk-attr.upper-attr-code
                ,input  current_c-cash-desk-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .


&scop fields-name-list  "cash-num,db-num,obj-code,pos-type,attr-code,upper-attr-code,attr-value"
&scop fields-label-list  "Номер кассы,БД,Магазин,Тип,Атрибут,Секция,Значение атрибута"
&scop fields-function-list ",,,,,"

    define variable v-label-param as character no-undo .

v-label-param =
  "cash-num" + {&delim-par} + "Номер кассы" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Магазин" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "upper-attr-code" + {&delim-par} + "Секция" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cash-desk.action = integer({&hn-create}))
                                            ,input  (buf_c-cash-desk.action = integer({&hn-delete}))
                                            ,input  buffer current_c-cash-desk-attr:handle
                                            ,input  {&table_cash-desk-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* cash-desk-attr-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("История кассы  БД&1 маг&2 тип &3 касса №4: щепка &5 Предмет изменений &6&7&8"
                 , p-db-num
                 , p-obj-code
                 , p-pos-type
                 , p-cash-num
                 , p-chip-num
                 , p-subject
                 , {&new-line}
                 , p-mess).

    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.