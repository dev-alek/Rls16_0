block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории градуировочной таблицы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/20/06
Author: Dmitry Ukhanov
Creation date: 01/20/06

*/

trigger procedure for delete of ub.c-pl-level.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление истории товара на складском месте":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',ub.c-pl-level.obj-type,ub.c-pl-level.obj-code,ub.c-pl-level.pl-code,ub.c-pl-level.chip-num)" }

Main-Block:
do transaction on error   undo Main-Block, return error
               on end-key undo Main-Block, return error
               on stop    undo Main-Block, return error :
  message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
          "Нельзя удалять запись истории градуировочной таблицы резервуара на объекте!" skip( 1 )
  view-as alert-box error.
  undo Main-Block, return error.
end. /* Main-Block */

