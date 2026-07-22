block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-ggr.p $
$Archive: utl/exp-ggr.p $

Экспорт групп товаров

Автор: Перваков Михаил Сергеевич
Дата создания: 01/24/03
Author: Mikhail Pervakov
Creation date: 01/24/03

Применен новый формат экспорта

*/

define variable p-install as logical   no-undo init false .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: exp-ggr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/exp-ggr.p $":U .
define variable vss-description as character no-undo initial "Экспорт групп товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ ref/grplib.i   }

define stream sexp .

define variable f-name     as character no-undo .
define variable v-ok       as logical   no-undo .
define variable v-ind      as integer   no-undo .
define variable v-grp-name as character no-undo .

if p-install = false then do:
  assign
    v-ok = false
  .
  message
    "Экспорт групп товаров." skip
    "Продолжить?" skip
    view-as alert-box question buttons ok-cancel update v-ok.
  if v-ok <> true then do:
    return .
  end.
end.

assign
  f-name = 'gds-grp.ggr'
.

if p-install = false then do:
  system-dialog get-file f-name
    filters "Файл групп товаров *.ggr" "*.ggr"
    ask-overwrite
    save-as
    use-filename
    update v-ok
    default-extension "ggr".
  if v-ok <> true then do:
    return .
  end.
end.

output stream sexp to value (f-name) .
export stream sexp "GOODS_GRP_1_0" .
output stream sexp close .

run waitfram-show in this-procedure
  (input "Ждите..."
  ).

for each gds-grp no-lock
  where gds-grp.upper-code <> 0
:
  assign
    v-ind = v-ind + 1
  .
  run grplib-get-full-name in this-procedure (
                                                 input  gds-grp.node-code
                                              ,output v-grp-name
                                              ) .
  run waitfram-show in this-procedure
    (input "Ждите..."
    ).
  output stream sexp to value (f-name) append .
  export stream sexp v-grp-name .
  output stream sexp close .
  run waitfram-hide in this-procedure .
end.

if p-install = false then do:
  message
    "Экспорт групп товаров закончен" skip
    "Экспортировано групп" v-ind skip
    view-as alert-box information .
end.