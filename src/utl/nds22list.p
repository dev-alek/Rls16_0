/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ручной запуск утилиты для BTS-2205 без корректировки ставок (только лог).

Автор: Ростовцев А.М.
Дата создания: 13.01.2026
Author: 
Creation date: 

*/

/*&if defined(manual) = 0 &then*/
/*{ utl/runpro.i }             */
/*&endif                       */

{ utl/runpro.i}

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Jan 19 2026 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: nds22list.p.p $":U .
define variable vss-archive     as character no-undo init "$Archive: FixProc/nds22list.p $".
define variable vss-description as character no-undo init "Ручной запуск утилиты для BTS-2205 без корректировки ставок (только лог).".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i }

find first sys-ctrl no-lock . 

define stream sProt.
output stream sProt to value("utl_2205_" + string(sys-ctrl.db-num) + ".txt").

{utl/nds22corr.i}

output stream sProt close.

MESSAGE "Успешно!" VIEW-AS ALERT-BOX.


