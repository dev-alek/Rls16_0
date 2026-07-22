block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: auto-diadoc.p $
$Archive: bge/auto-diadoc.p $

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
def var vss-workfile    as character no-undo init "$Workfile: auto-diadoc.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-diadoc.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС Диадок".
{ cmp/vssrevis.i }
 
define variable mi as integer no-undo.
p-list-db = trim(p-list-db,",").
do mi = 1 to num-entries (p-list-db):
/*   vAsyncHelper:AsyncProc("Diadoc" +  string(mi),"utl/proc-diadoc", substitute("&1":U ,entry(mi,p-list-db)),1).*/
     run AddTask in this-procedure ("utl/proc-diadoc", substitute("&1":U ,entry(mi,p-list-db))).

end.

run waitproc(substitute("Получение данных из Диадок. По БД &1.", p-list-db)).

/* $Workfile: auto-diadoc.p $ end */