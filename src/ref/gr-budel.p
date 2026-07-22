block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gr-budel.p $
$Archive: ref/gr-budel.p $

Удаление группы покупателей для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/
define input  parameter parparentproc  as handle no-undo .
define input  parameter p-db-num  like ub.buyer-group.bgr-db-num no-undo .
define input  parameter p-id      like ub.buyer-group.bgr-id     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-budel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-budel.p $":U .
define variable vss-description as character no-undo init "Удаление группы покупателей для ценообразовани".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/bib-ad.i   }

define variable v-sec as integer   no-undo .
find first ub.buyer-group no-lock where
           ub.buyer-group.bgr-db-num = p-db-num    and
           ub.buyer-group.bgr-id     = p-id
           no-error .
if v-cntxt-db-num <> 0 then do :
   if ub.buyer-group.bgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , удалять в текущей БД нельзя !" , ub.buyer-group.bgr-db-num ) .
      return error substitute(" Группа создана в другой БД (&1) , удалять нельзя !" , ub.buyer-group.bgr-db-num ).
   end.
end.

find first ub.buyer-group exclusive-lock where
           ub.buyer-group.bgr-db-num = p-db-num    and
           ub.buyer-group.bgr-id     = p-id
           no-error .

run waitfram-show ("Ждите...") .

  ub.buyer-group.stts = 1.
  for each  ub.buyer-in-buyer-group exclusive-lock where
            ub.buyer-in-buyer-group.bgr-db-num = p-db-num    and
            ub.buyer-in-buyer-group.bgr-id     = p-id :
        run bib-del (
           input   ub.buyer-in-buyer-group.bgr-db-num
          ,input   ub.buyer-in-buyer-group.bgr-id
          ,input   ub.buyer-in-buyer-group.bbg-obj-code
          ,input   ub.buyer-in-buyer-group.bbg-obj-type
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid
          ,input-output   v-sec
          ) .

  end.
run waitfram-hide .