block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-on2.p $
$Archive: utl/bc-on2.p $

Выключение повторных доп.БК

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bc-on2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/bc-on2.p $":U .
define variable vss-description as character no-undo init "Выключение повторных доп.БК".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define buffer b-prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods for ub.goods .
define buffer buf_units for ub.units .


define variable all-bc as integer no-undo .
define variable on-bc  as integer no-undo .
define variable off-bc as integer no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
{ gbl/waitfram.i }

/*
if g#db-num <> 0 then do:
  message "Утилита может работать только в ГБД." view-as alert-box error.
  return.
end.
*/

define variable lok as logical no-undo .

assign
  lok = no
.
message
  "Включение всех выключенных неповторных доп. БК, (кроме весовых)"
  "включение первого из повторных доп. БК, если все они выключены." skip
  "ВНИМАНИЕ - изменения бар-кодов не будут передаваться через новости" skip
  "Данную утилиту необходимо запустить на всех базах данных"
  "и сравнить выключенные бар-коды" skip
  "bc-on2.err - список выключенных бар-кодов" skip
  "bc-on2.txt - список включенных бар-кодов" skip
  "Продолжить?"
  view-as alert-box question buttons OK-Cancel update lok.
if not lok then do:
  return.
end.

run waitfram-show in this-procedure (
 input "Выбор всех бар-кодов..."
  ).

for each ub.prod-bc
:
  assign
    all-bc = all-bc + 1
  .

  run waitfram-show in this-procedure (input "Всего бар-кодов" + STRING( all-bc ) +  ". "
     + "Включено "  + STRING(on-bc) + ". "
     + "Выключено "  + STRING(off-bc) + ". "
    ).

  if can-find (b-prod-bc where b-prod-bc.b-str = prod-bc.b-str and
                   b-prod-bc.bc-on = yes and
                   recid (b-prod-bc) <> recid (prod-bc) no-lock) then do:
    /*проверим что мы работаем не с весовым!!!*/
    /*не нужно их скопом включать!*/
    find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.prod-bc.b-code.
    find first buf_goods No-lock where
                buf_goods.gds-code =buf_bar-code.b-code .
    find first buf_units No-lock where
                buf_units.unit-name = buf_goods.unit-base.
    if lookup({&weight}, buf_units.type) > 0  then do:
      next.
    end.
    if lookup({&pieces}, buf_units.type) > 0  then do:
      l-prod-bc-pgweight = yes.
      { gbl/prodbcat.i
        ub.prod-bc
        "'pgweight=request':u"
        l-prod-bc-pgweight
        no-error
      }
      if l-prod-bc-pgweight then do:
        next.
      end.
    end.
    assign
      off-bc = off-bc + 1
    .

    output to bc-on2.err append .
    export prod-bc.b-str .
    output close .

    if prod-bc.bc-on then do:
      output to bc-on2.err append .
      export prod-bc.b-str "**error must be off" .
      output close .
    end.

    next. /* --->>>--- */
  end.

  if not prod-bc.bc-on then do:
    assign
      on-bc = on-bc + 1
    .
    assign
      prod-bc.bc-on = yes
    .

    output to bc-on2.txt append .
    export prod-bc.b-str .
    output close .
  end.
end.

run waitfram-hide in this-procedure .

message
  "Включение доп. БК закончено."
  view-as alert-box.