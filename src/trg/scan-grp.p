block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка единицы измерения вверх по дереву групп товаров

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

По умолчанию для создаваемой группы единица измерения равна "" .
При заведении первого товара группе будет присвоена единица измерения товара .
Как только в группе товаров появится товар с отличной единицей измерения,
то единице измерения группы товаров будет присвоено неопределенное значение ? .

Mikle Pervakov - переписано без использования рекурсии

*/
define input parameter p-lev   like ub.gds-grp.node-code no-undo .
define input parameter p-unit-base like ub.goods.unit-base   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка единицы измерения вверх по дереву групп товаров".
{ cmp/vssrevis.i }

find first ub.gds-grp share-lock
  where ub.gds-grp.node-code = p-lev
  no-error .
do while available ub.gds-grp
:
  case ub.gds-grp.unit-base:
    when ? or
    when p-unit-base then do:

    end.
    when "" then do:
      do transaction
      on error undo, return error
      :
        assign
          ub.gds-grp.unit-base = p-unit-base
        .
      end.
    end.
    otherwise do:
      do transaction
      on error undo, return error
      :
        assign
          ub.gds-grp.unit-base = ?
        .
      end.
    end.
  end case.

  define variable v-node-code like ub.gds-grp.node-code no-undo .
  assign
    v-node-code = ub.gds-grp.upper-code
  .
  find first ub.gds-grp share-lock
    where ub.gds-grp.node-code = v-node-code
    no-error .
end.