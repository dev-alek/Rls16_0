block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delturn.p $
$Archive: ref/delturn.p $

Удаление оборотов

Автор: Чернова Светлана Александровна
Дата создания: 12/01/05
Author: Svetlana Chernova
Creation date: 12/01/05

*/
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delturn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/delturn.p $":U .
define variable vss-description as character no-undo init "Удаление оборотов ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
{ cmp/obj-list.i new }
run waitfram-show ( "Ждите..." ) .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_clients for ub.clients  .

/* А надо ли ?*/
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical   no-undo .
  { gbl/glstall.i
    v-use-grp-buy
    v-use-oborot-buy
    v-use-qnty-group
    v-use-sum-group
    v-use-add-code
    v-use-sys-date-time
    v-use-shift-date-num
    v-use-cassa
    v-use-val
    v-use-pay-type
    v-use-cash-pay
    v-use-child
    }
  if not ( v-use-grp-buy or v-use-oborot-buy )  then return .


find buf_clients no-lock where
     buf_clients.obj-code = p-cli-code and
     buf_clients.obj-type = p-cli-type no-error .

for each ub.turnover-buyer-main exclusive-lock where ub.turnover-buyer-main.cli-code = p-cli-code and  ub.turnover-buyer-main.cli-type = p-cli-type :
    delete ub.turnover-buyer-main .
end.

run waitfram-hide .