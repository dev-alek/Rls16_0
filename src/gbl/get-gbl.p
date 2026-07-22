block-level on error undo, throw.
/*

$Revision: 6eb2e10e43c1, 3410, rls $
$Author: DRuban $
$Date: 2023/08/17 10:18:56 $
$Workfile: get-gbl.p $
$Archive: gbl/get-gbl.p $

Получение глобальных переменных в статический объект gbl-var

Автор: Морозов Александр Сергеевич
Дата создания: 04/10/18
Author: Mikhail Pervakov
Creation date: 04/10/18

*/

{ cmp/trg-def.i  }


define variable objGblVar as class Ibs.Th.Gbl.gbl-var.


objGblVar = new Ibs.Th.Gbl.gbl-var().

objGblVar:InitObj(g#auto, g#news-source-db, g#db-num, g#userid, g#passwd, g#esys).
