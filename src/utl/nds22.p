/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ручной запуск утилиты nds22.p для BTS-2056.

Автор: Ростовцев А.М.
Дата создания: 16.09.2025
Author: 
Creation date: 

*/

/*&if defined(manual) = 0 &then*/
/*{ utl/runpro.i }             */
/*&endif                       */

{ utl/runpro.i}


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Oct 29 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fix_bts-2056.p $":U .
define variable vss-archive     as character no-undo init "$Archive: FixProc/fix_bts-2056.p $".
define variable vss-description as character no-undo init "Добавление ставки налога 10 на товарах.".

{utl/nds22.i &mode="manual"}

MESSAGE "Успешно!" VIEW-AS ALERT-BOX.


