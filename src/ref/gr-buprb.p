block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gr-buprb.p $
$Archive: ref/gr-buprb.p $

Назначение покупателей из списка клиентов.

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

define input  parameter parparentproc  as handle no-undo .
define input  parameter p-db-num  like ub.buyer-group.bgr-db-num no-undo .
define input  parameter p-id      like ub.buyer-group.bgr-id  no-undo .
define output parameter p-rec-id as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-buprb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-buprb.p $":U .
define variable vss-description as character no-undo init "Назначение покупателей из списка клиентов.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/cli-list.i cli-list def "new shared" }
{ gbl/waitfram.i }
{ ref/bib-ad.i   }

define variable v-err as integer   no-undo  init 0.
define variable v-sec as integer   no-undo .

run str/cli-list.w
( input parparentproc ,
  input v-cntxt-host-code-obj ,
  input v-cntxt-obj-type ,
  input v-cntxt-obj-code
  ) .
  run waitfram-show ("Ждите...") .

  for each cli-list :
      /*  find first ub.buyer-in-buyer-group no-lock where
                  ub.buyer-in-buyer-group.stts = 0 and
                  ub.buyer-in-buyer-group.bbg-obj-code = cli-list.obj-code and
                  ub.buyer-in-buyer-group.bbg-obj-type = cli-list.obj-type no-error .
        if available ub.buyer-in-buyer-group then do:
            v-err = v-err + 1.
            next.
        end. */

        run bib-add (
           input   p-db-num
          ,input   p-id
          ,input   cli-list.obj-code
          ,input   cli-list.obj-type
          ,input   0
          ,input   p-db-num
          ,input   v-cntxt-userid
          ,input-output   v-sec
           ) .

  end.
  run waitfram-hide .

if v-err > 0 then message "Клиентов не добавлено : " v-err skip "Эти клиенты прикреплены к другим группам" view-as alert-box information .