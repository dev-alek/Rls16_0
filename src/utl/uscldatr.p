block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: uscldatr.p $
$Archive: utl/uscldatr.p $

Утилита создания атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/27/06
Author: Bakhtadze Natalya
Creation date: 03/27/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: uscldatr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/uscldatr.p $":U .
define variable vss-description as character no-undo init "Утилита создания атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/gdsoattr.i }
{ gbl/waitfram.i }


DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo.
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
define stream errstream.

message "Вы действительно хотите создать атрибут ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ ДЛЯ ВЕСОВЫХ ТОВАРОВ"
        "для всех объектов текущей БД?"
view-as alert-box QUESTION buttons YES-NO update loc#log.
if not loc#log then return.

output stream errstream to uscdatr.err.

_goods:
FOR EACH ub.goods No-LOCK ,
    FIRST ub.units No-LOCK WHERE
          ub.units.unit-name = ub.goods.unit-base AND
          LOOKUP({&weight}, ub.units.type ) > 0:

  num-rec = num-rec + 1.
  do TRANSACTION on error undo, next _goods on stop undo, next _goods:
    { gbl/sclcdatr.i ub.goods.gds-code "''" 0 ? no no-error }
    /*
    по всем объектам текущей БД
    взять первый существующий
    переписать если такой атрибут уже есть */

  END. /*if avail ub.prod-bc*/
  if not error-status:error then
  num-rec-ok = num-rec-ok + 1.
  ELSE DO:
    PUT stream Errstream UNFORMATTED
    return-value skip.
  end.

  if num-rec modulo 10 = 0 then do:
    run waitfram-show in this-procedure ("Обработано " + string(num-rec) + "  товаров.  Из  них успешно " + string(num-rec-ok)).  /*пробелы не стирать!!!*/
  end.
END.
run waitfram-hide in this-procedure .
output stream errstream close.
message "Утилита по созданию атрибута товара на объекте ВЕСОВОЙ КОД ТОВАРА"
        "работу завершила" SKIP
        "Из " num-rec " товаров в данной БД успешно обработаны " num-rec-ok skip
        string(if num-rec > num-rec-ok then
        "Ошибки ищите в файле uscldatr.err" else "")
view-as alert-box .