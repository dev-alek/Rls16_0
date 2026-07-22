block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: auto-merc-asunc.p $
$Archive: bge/auto-merc-asunc.p $

Работа с ФГИС меркурий

Автор: Сливенко Сергей
Дата создания: 05/28/18
Author: Slivenko Sergey
Creation date: 05/28/18

*/

{utl/asuncprocauto.i}
define input  parameter iStart as datetime-tz no-undo.
define input  parameter p-list-db       as character no-undo .

def var vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-merc-asunc.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-merc-asunc.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС Меркурий".
{ cmp/vssrevis.i }

run addtask in this-procedure ("utl/proc-merc", substitute("&1":U ,p-list-db),iStart).
if num-entries (p-list-db) > 30
then
   run waitproc in this-procedure (substitute("Получение данных из Меркурий. По &1 БД .",num-entries (p-list-db))).
else
   run waitproc in this-procedure (substitute("Получение данных из Меркурий. По БД &1.",p-list-db)).
 
   
/* $Workfile: auto-merc-asunc.p $ end */