block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-gdsd.p $
$Archive: utl/chk-gdsd.p $

Удаляет все записи gds-obj ссылающиеся на несуществующие товары

Автор: Чернова Светлана Александровна
Дата создания: 01/28/09
Author: Svetlana Chernova
Creation date: 01/28/09

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-gdsd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chk-gdsd.p $":U .
define variable vss-description as character no-undo init "Удаляет все записи gds-obj ссылающиеся на несуществующие товары".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define variable lOK as logical no-undo init false .
define variable ideleted as integer no-undo init 0.
define buffer buf_goods for ub.goods .

do
on error undo, return error return-value
:
  message
    "Вы действительно хотите проверить таблицы gds-obj" skip
    "и удалить все записи ссылающиеся на несуществующие товары?"
    view-as alert-box buttons YES-NO update lOK.

  if not lOK then do:
    return .
  end.


  run waitfram-show in this-procedure
    (input "Просмотр товаров на объекте..."
    ).

  for each ub.gds-obj
  :
    run waitfram-show in this-procedure
      (input "Просмотр товаров на объекте " + ub.gds-obj.obj-type + " " + string(ub.gds-obj.obj-code) + ". "
      + "Артикул " + STRING(ub.gds-obj.artic) + ". "
      + "Удалено записей " + STRING(ideleted)
      ).
    process events .

    find first buf_goods no-lock
      where buf_goods.artic     = ub.gds-obj.artic
        and buf_goods.prod-type = ub.gds-obj.prod-type
        and buf_goods.prod-code = ub.gds-obj.prod-code
      no-error .
    if not available buf_goods then do:
      assign
        ideleted = ideleted + 1
      .
      output to chk-gdsd.log append .
      export 'bad ub.goods' ub.gds-obj.artic ub.gds-obj.prod-type ub.gds-obj.prod-code .
      export 'delete gds-obj '.
      export gds-obj .
      delete gds-obj .
      output close .
    end.
  end.

  run waitfram-hide in this-procedure .
end.