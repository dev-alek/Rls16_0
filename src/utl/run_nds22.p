/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автозапуск утилиты nds22.p для BTS-2056.

Автор: Ростовцев А.М.
Дата создания: 16.09.2025
Author: 
Creation date: 

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Oct 29 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run_fix_bts-2056.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/run_fix_bts-2056.p $".
define variable vss-description as character no-undo init "Автозапуск утилиты для BTS-2056.".

{utl/nds22.i &mode="auto"}
