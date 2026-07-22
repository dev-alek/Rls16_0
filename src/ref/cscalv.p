block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cscalv.p $
$Archive: ref/cscalv.p $

Заполнение временной таблицы для показа изменений по таблицам истории весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/


define input parameter  p-db-num                like  ub.c-scales.db-num             no-undo .
define input parameter  p-scales-num              like  ub.c-scales.scales-num           no-undo .
define input parameter  p-attr-code             like  ub.c-scales.attr-code          no-undo .
define input parameter  p-corr-user-db-num      like  ub.c-scales.corr-user-db-num   no-undo .
define input parameter  p-chip-num              like  ub.c-scales.chip-num           no-undo .
define input parameter  p-subject               like  ub.c-scales.subject            no-undo .
define input parameter p-action   like ub.c-cli-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cscalv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cscalv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории весов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/scl-attr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-scales for ub.c-scales.

{ ref/tmpchgs.i "SHARED" " " "with-action" }

if p-action = integer({&hn-delete}) then return.
find first buf_c-scales no-lock where
          buf_c-scales.db-num   = p-db-num
      AND buf_c-scales.scales-num = p-scales-num
      AND buf_c-scales.chip-num = p-chip-num
      AND buf_c-scales.corr-user-db-num = p-corr-user-db-num   no-error .
if not available buf_c-scales then do:
  return error .
end.

CASE p-subject:
  when {&table_scales} or when "":U then do:
    run scales-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_scales-attr} then do:
    run scales-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_scales-grp} then do:
    run scales-grp-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_scales-gds} then do:
    run scales-gds-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.


procedure scales-proc :
define output parameter p-description as character no-undo .
define buffer current_c-scales for ub.c-scales  .


  do
  on error undo, return error
  :
    find first current_c-scales no-lock where
               current_c-scales.db-num   = p-db-num
           AND current_c-scales.scales-num = p-scales-num
           AND current_c-scales.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales.chip-num = p-chip-num
           no-error .
    if not avail current_c-scales then do:
       v-mess = "Неверная ссылка на c-scales в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list   "address,master,max-gds,unit-base,scales-type,scales-name,scales-num,db-num,remote,to-send,tot-gds"

define variable v-label-param as character no-undo .

v-label-param =
  "address" + {&delim-par} + "Адрес" + {&delim-par} + "" + {&delim-flf}
 + "master" + {&delim-par} + "Главные весы" + {&delim-par} + "" + {&delim-flf}
 + "max-gds" + {&delim-par} + "Максимальная номенклатура" + {&delim-par} + "" + {&delim-flf}
 + "max-plu" + {&delim-par} + "Макс. PLU в тек.момент" + {&delim-par} + "" + {&delim-flf}
 + "unit-base" + {&delim-par} + "Ед.изм" + {&delim-par} + "" + {&delim-flf}
 + "scales-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "scales-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "scales-num" + {&delim-par} + "Номер весов" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "remote" + {&delim-par} + "Удаленные" + {&delim-par} + "" + {&delim-flf}
 + "to-send" + {&delim-par} + "Требуют обновления" + {&delim-par} + "" + {&delim-flf}
 + "tot-gds" + {&delim-par} + "Кол-во PLU" + {&delim-par} + ""
   .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer({&hn-create}))
                                            ,input  (buf_c-scales.action = integer({&hn-delete}))
                                            ,input  buffer current_c-scales:handle
                                            ,input  {&table_scales}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.
end procedure. /* scales-proc */



procedure scales-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-scales-attr for ub.c-scales-attr  .

  do
  on error undo, return error
  :
    find first current_c-scales-attr no-lock where
               current_c-scales-attr.db-num   = p-db-num
           AND current_c-scales-attr.scales-num = p-scales-num
           AND current_c-scales-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales-attr.chip-num = p-chip-num
           AND current_c-scales-attr.attr-code  = buf_c-scales.attr-code
           no-error .
    if not avail current_c-scales-attr then do:
       v-mess = "Неверная ссылка на c-scales-attr в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
    run scl-attr-tooltip in this-procedure (
                input  current_c-scales-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .

&scop fields-name-list   "attr-value,scales-num,db-num"

define variable v-label-param as character no-undo .

v-label-param =
  "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "" + {&delim-flf}
 + "scales-num" + {&delim-par} + "Номер весов" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer({&hn-create}))
                                            ,input  (buf_c-scales.action = integer({&hn-delete}))
                                            ,input  buffer current_c-scales-attr:handle
                                            ,input  {&table_scales-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* scales-attr-proc */


procedure scales-grp-proc :
define output parameter p-description as character no-undo .
define buffer current_c-scales-grp for ub.c-scales-grp  .


  do
  on error undo, return error
  :
    find first current_c-scales-grp no-lock where
               current_c-scales-grp.db-num   = p-db-num
           AND current_c-scales-grp.scales-num = p-scales-num
           AND current_c-scales-grp.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales-grp.chip-num = p-chip-num
           AND current_c-scales-grp.node-code  = buf_c-scales.node-code
           no-error .
    if not avail current_c-scales-grp then do:
       v-mess = "Неверная ссылка на c-scales-grp в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list   "node-code,scales-num,db-num"

define variable v-label-param as character no-undo .

v-label-param =
  "node-code" + {&delim-par} + "Код группы" + {&delim-par} + "" + {&delim-flf}
 + "scales-num" + {&delim-par} + "Номер весов" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer({&hn-create}))
                                            ,input  (buf_c-scales.action = integer({&hn-delete}))
                                            ,input  buffer current_c-scales-grp:handle
                                            ,input  {&table_scales-grp}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* scales-grp-proc */



procedure scales-gds-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .


define buffer current_scales-gds for ub.scales-gds  .
define buffer current_c-scales-gds for ub.c-scales-gds  .
define buffer new_c-scales-gds for ub.c-scales-gds  .


  do
  on error undo, return error
  :
    find first current_c-scales-gds no-lock where
               current_c-scales-gds.db-num   = p-db-num
           AND current_c-scales-gds.scales-num = p-scales-num
           AND current_c-scales-gds.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales-gds.chip-num = p-chip-num
           AND current_c-scales-gds.PLU-code  = buf_c-scales.PLU-code
           no-error .
    if not avail current_c-scales-gds then do:
       v-mess = "Неверная ссылка на c-scales-gds в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list   "b-code,db-num,deadline,obj-code,obj-type,PLU-code,scales-num,to-del,to-send,wt-cart"

define variable v-label-param as character no-undo .

v-label-param =
  "b-code" + {&delim-par} + "Бар-код" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "Номер БД" + {&delim-par} + "" + {&delim-flf}
 + "deadline" + {&delim-par} + "Срок хранения" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PLU-code" + {&delim-par} + "Код PLU" + {&delim-par} + "" + {&delim-flf}
 + "scales-num" + {&delim-par} + "Номер весов" + {&delim-par} + "" + {&delim-flf}
 + "to-del" + {&delim-par} + "Удаление с весов" + {&delim-par} + "" + {&delim-flf}
 + "to-send" + {&delim-par} + "Требует обновления" + {&delim-par} + "" + {&delim-flf}
 + "wt-cart" + {&delim-par} + "Вес упаковки" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer({&hn-create}))
                                            ,input  (buf_c-scales.action = integer({&hn-delete}))
                                            ,input  buffer current_c-scales-gds:handle
                                            ,input  {&table_scales-gds}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* scales-gds-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("История весов  БД&1 весы №2: щепка &3 Предмет изменений &4&5&6"
                        ,p-db-num
                        ,p-scales-num
                        ,p-chip-num
                        ,p-subject
                        ,{&new-line}
                        ,p-mess
                        ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.