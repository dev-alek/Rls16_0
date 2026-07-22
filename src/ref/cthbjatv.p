block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cthbjatv.p $
$Archive: ref/cthbjatv.p $

Заполнение временной таблицы для показа изменений по таблицам истории настроек объектов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/08
Author: Bakhtadze Natalya
Creation date: 09/29/08

*/

define input parameter p-obj-type like ub.c-thbj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.c-thbj-attr.obj-code no-undo .
define input parameter p-upper-prop-code like ub.c-thbj-attr.upper-prop-code no-undo .
define input parameter p-prop-code like ub.c-thbj-attr.prop-code no-undo .
define input parameter p-corr-user-db-num as integer no-undo .
define input parameter p-chip-num as integer no-undo .
define input parameter p-subject as character no-undo .
define input parameter p-action as integer no-undo .
define input parameter p-silent as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cthbjatv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cthbjatv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории настроек объектов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/tmpchgs.i "SHARED" " " "with-action" }
{ gbl/get-regf.i }

define variable v-mess as character no-undo .
{ ref/cthbjatv.i }
{ gbl/thbjattr.i }
{ gbl/key-rec.i }

define temp-table temp-thbj-attr no-undo
like ub.thbj-attr.

find first current_c-thbj-attr no-lock where
          current_c-thbj-attr.upper-prop-code       = p-upper-prop-code
      AND current_c-thbj-attr.prop-code             = p-prop-code
      AND current_c-thbj-attr.obj-type              = p-obj-type
      AND current_c-thbj-attr.obj-code              = p-obj-code
      AND current_c-thbj-attr.chip-num              = p-chip-num
      AND current_c-thbj-attr.corr-user-db-num = p-corr-user-db-num  no-error .

if not available current_c-thbj-attr then do:
  v-mess = "Неверная ссылка на c-thbj-attr в таблице c-cli-hist".
  run err-mess ( input-output v-mess).
  return error (if p-silent then v-mess else '':U).
end.
create temp-thbj-attr.
assign
temp-thbj-attr.upper-prop-code       = p-upper-prop-code
temp-thbj-attr.prop-code             = p-prop-code
temp-thbj-attr.obj-type              = p-obj-type
temp-thbj-attr.obj-code              = p-obj-code
.
run gen-key-rec in this-procedure ( input {&table_thbj-attr}
                                   ,input (buffer temp-thbj-attr:handle)
                                   ,output v-thbj-attr-uniq-key-rec) .

CASE p-subject:
  when {&table_thbj-attr}
  or when '' then do:
    run thbj-attr-self-proc in this-procedure(input current_c-thbj-attr.action, output p-description) no-error  .
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
END CASE.
if error-status:error then do:
  return error .
end.



PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  p-mess =
  substitute("История параметров объектов IBS TH: &1: щепка &2 БД:&3:Предмет изменений &4"
              ,get-objregion(p-obj-type, p-obj-code)
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
