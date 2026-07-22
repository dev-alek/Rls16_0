block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gr-qudel.p $
$Archive: ref/gr-qudel.p $

Удаление группы покупателей для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/
define input  parameter parparentproc  as handle no-undo .
define input  parameter p-db-num  like ub.qnty-group.qgr-db-num no-undo .
define input  parameter p-id      like ub.qnty-group.qgr-id     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-qudel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-qudel.p $":U .
define variable vss-description as character no-undo init "Удаление группы покупателей для ценообразовани".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/qiq-ad.i   }

find first ub.qnty-group exclusive-lock where
           ub.qnty-group.qgr-db-num = p-db-num    and
           ub.qnty-group.qgr-id     = p-id
           no-error .
run waitfram-show ("Ждите...") .

  ub.qnty-group.stts = 1 .

  for each  ub.qnty-in-qnty-group exclusive-lock where
            ub.qnty-in-qnty-group.qgr-db-num = p-db-num    and
            ub.qnty-in-qnty-group.qgr-id     = p-id :

        run qiq-del (
           input   ub.qnty-in-qnty-group.qgr-db-num
          ,input   ub.qnty-in-qnty-group.qgr-id
          ,input   ub.qnty-in-qnty-group.ggr-qnty
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

  end.
run waitfram-hide .