block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gr-sudel.p $
$Archive: ref/gr-sudel.p $

Удаление группы покупателей для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/
define input  parameter parparentproc  as handle no-undo .
define input  parameter p-db-num  like ub.sum-group.sgr-db-num no-undo .
define input  parameter p-id      like ub.sum-group.sgr-id     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-sudel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-sudel.p $":U .
define variable vss-description as character no-undo init "Удаление группы покупателей для ценообразовани".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/sis-ad.i   }

find first ub.sum-group no-lock  where
           ub.sum-group.sgr-db-num = p-db-num    and
           ub.sum-group.sgr-id     = p-id
           no-error .
if v-cntxt-db-num <> 0 then do :
   if ub.sum-group.sgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , удалять ее в текущей БД нельзя !" , ub.sum-group.sgr-db-num ) .
      return .
   end.
end.
find first ub.sum-group exclusive-lock where
           ub.sum-group.sgr-db-num = p-db-num    and
           ub.sum-group.sgr-id     = p-id
           no-error .

run waitfram-show ("Ждите...") .

  ub.sum-group.stts = 1.
  for each  ub.sum-in-sum-group exclusive-lock where
            ub.sum-in-sum-group.sgr-db-num = p-db-num    and
            ub.sum-in-sum-group.sgr-id     = p-id :

        run sis-del (
           input   ub.sum-in-sum-group.sgr-db-num
          ,input   ub.sum-in-sum-group.sgr-id
          ,input   ub.sum-in-sum-group.ssg-summa
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

  end.
run waitfram-hide .