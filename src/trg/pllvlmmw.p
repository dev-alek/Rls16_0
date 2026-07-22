block-level on error undo, throw.
/*

$Revision: f7f4e950f623, 0, rls $
$Author: expertek $
$Date: 2024/03/14 08:03:47 $
$Workfile: pl-lvlmmw.p $
$Archive: trg/pl-lvlmmw.p $

Триггер на запись таблицы поясов по резервуару на объекте

Автор: Ростовцев Александр Михайлович
Дата создания: 14/03/2024
Author: Aleksandr Rostovtsev
Creation date: 03/14/2024

*/

trigger procedure for write of ub.pl-level-mm new buffer newb old buffer oldb.

define variable vss-revision    as character no-undo initial "$Revision: f7f4e950f623, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: 2012/10/22 17:03:47 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: pl-lvlw.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: trg/pl-lvlw.p $":U.
define variable vss-description as character no-undo initial "Триггер на запись таблицы поясов по резервуару на объекте":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3',newb.obj-type,newb.obj-code,newb.pl-code)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

Main-Block:
do on error   undo Main-Block, return error return-value
   on end-key undo Main-Block, return error return-value
   on stop    undo Main-Block, return error return-value :

  run str/callnews.p ( input "pl-level-mm", input ( buffer newb :handle ) ).

end. /* Main-Block */
