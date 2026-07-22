block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gr-oudel.p $
$Archive: ref/gr-oudel.p $

Удаление группы покупателей для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/
define input  parameter parparentproc  as handle no-undo .
define input  parameter p-db-num  like ub.turnover-group.tog-db-num no-undo .
define input  parameter p-id      like ub.turnover-group.tog-id     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-oudel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-oudel.p $":U .
define variable vss-description as character no-undo init "Удаление группы покупателей для ценообразования".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/oio-ad.i   }

find first ub.turnover-group exclusive-lock where
           ub.turnover-group.tog-db-num = p-db-num    and
           ub.turnover-group.tog-id     = p-id
           no-error .
if v-cntxt-db-num <> 0 then do :
   if ub.turnover-group.tog-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , удалять ее в текущей БД нельзя !" , ub.turnover-group.tog-db-num ) .
      return .
   end.
end.

run waitfram-show ("Ждите...") .

  ub.turnover-group.stts = 1.
  for each  ub.tnv-in-turnover-group exclusive-lock where
            ub.tnv-in-turnover-group.tog-db-num = p-db-num    and
            ub.tnv-in-turnover-group.tog-id     = p-id :

        run oio-del (
           input   ub.tnv-in-turnover-group.tog-db-num
          ,input   ub.tnv-in-turnover-group.tog-id
          ,input   ub.tnv-in-turnover-group.ttg-summa
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

  end.
run waitfram-hide .