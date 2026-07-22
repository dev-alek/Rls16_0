block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: auto-nws.p $
$Archive: bge/auto-nws.p $

Работа с ФГИС меркурий

Автор: Сливенко Сергей
Дата создания: 05/28/18
Author: Slivenko Sergey
Creation date: 05/28/18

*/
{utl/asuncprocauto.i}
define input  parameter p-list-db       as character no-undo .

def var vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-nws.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС Диадок".
{ cmp/vssrevis.i }

define variable mi as integer no-undo.
if p-list-db eq "*"
then do:
   run bge\auto-nws-db.p(output p-list-db).
end.


define variable mDB as character no-undo.
do mi = 1 to num-entries (p-list-db):
   mDB = entry(mi,p-list-db).
   if     mdb ne ""
      and mdb ne ?
   then do:
      run AddTask in this-procedure ("utl/proc-nws", mdb).
   end.
end.

run waitproc in this-procedure  (substitute("Обработка новостей. По БД &1.", p-list-db)).

/* $Workfile: auto-nws.p $ end */