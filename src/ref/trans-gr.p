block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trans-gr.p $
$Archive: ref/trans-gr.p $

Процедура перехода Покупателя из группы в группу на основе его оборота

Автор: Чернова Светлана Александровна
Дата создания: 02/16/06
Author: Svetlana Chernova
Creation date: 02/16/06

*/
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trans-gr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/trans-gr.p $":U .
define variable vss-description as character no-undo init "Процедура перехода Покупателя из группы в группу на основе его оборота".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

DEFINE BUFFER buf_buyer-group FOR ub.buyer-group.
DEFINE BUFFER buf_buyer-in-buyer-group FOR ub.buyer-in-buyer-group.

DEFINE BUFFER old_buyer-group FOR ub.buyer-group.
DEFINE BUFFER old_buyer-in-buyer-group FOR ub.buyer-in-buyer-group.

DEFINE BUFFER new_buyer-group FOR ub.buyer-group.
DEFINE BUFFER new_buyer-in-buyer-group FOR ub.buyer-in-buyer-group.

define buffer buf_global-state for ub.global-state  .
    find first  buf_global-state no-lock no-error .
            if  not available buf_global-state or buf_global-state.pl-use-grp-buy = false then return .
        /* buf_global-state.pl-use-oborot-buy   ???  */

/* текущее состояние покупателя */
define variable old-b-id       as integer   no-undo .
define variable old-b-db-num   as integer   no-undo .
define variable summ-tr as decimal   no-undo .
define variable new-b-id       as integer   no-undo .
define variable new-b-db-num   as integer   no-undo .
define variable v-num as integer   no-undo .
define variable v-sec as integer   no-undo .

    assign
      old-b-id      = 0
      old-b-db-num  = 0
      summ-tr       = 0
      new-b-id      = 0
      new-b-db-num  = 0
      v-num         = 0
    .


for each  buf_buyer-in-buyer-group  no-lock where
          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code and
          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
          buf_buyer-in-buyer-group.stts = 0 ,
    first buf_buyer-group no-lock where
          buf_buyer-group.bgr-db-num = buf_buyer-in-buyer-group.bgr-db-num and
          buf_buyer-group.bgr-id     = buf_buyer-in-buyer-group.bgr-id and
          buf_buyer-group.gop-id     > 0 and
          buf_buyer-group.stts       = 0
    :
    assign
      old-b-id      = buf_buyer-group.bgr-id
      old-b-db-num  = buf_buyer-group.bgr-db-num
      summ-tr       = buf_buyer-group.oborot
      new-b-id      = buf_buyer-group.gop-id
      new-b-db-num  = buf_buyer-group.gop-db
      v-num         = v-num + 1
    .
end.

if v-num > 1 then do:
    message
   "Внимание ! Покупатель "
   p-cli-code
   p-cli-type
   " привязан к " v-num  " группам Покупателей (в статусе ТЕКУЩИЙ)"  view-as alert-box .
end.

if new-b-id = 0 then return .  /* ----> перехода нет */



/* оборот покупателя по всем объектам */
define variable current-oborot as decimal   no-undo .
define buffer buf_turnover-buyer-main for ub.turnover-buyer-main  .

current-oborot = 0 .
for each buf_turnover-buyer-main no-lock where
         buf_turnover-buyer-main.cli-code = p-cli-code and
         buf_turnover-buyer-main.cli-type = p-cli-type
:
    current-oborot = current-oborot + buf_turnover-buyer-main.sum-doc-rubl-itog .
end.

/* переходим */
if current-oborot >= summ-tr then do:
    find first new_buyer-in-buyer-group exclusive-lock where
        new_buyer-in-buyer-group.bgr-id       = new-b-id       and
        new_buyer-in-buyer-group.bgr-db-num   = new-b-db-num   and
        new_buyer-in-buyer-group.bbg-obj-code = p-cli-code     and
        new_buyer-in-buyer-group.bbg-obj-type = p-cli-type     no-error .
        if available new_buyer-in-buyer-group then do:
            assign
              new_buyer-in-buyer-group.stts         = 0
            .
        end.
        else do:
        create new_buyer-in-buyer-group.
        assign
          new_buyer-in-buyer-group.bgr-id       = new-b-id
          new_buyer-in-buyer-group.bgr-db-num   = new-b-db-num
          new_buyer-in-buyer-group.bbg-obj-code = p-cli-code
          new_buyer-in-buyer-group.bbg-obj-type = p-cli-type
          new_buyer-in-buyer-group.stts         = 0
        .
        end.
        run ref/h-grbuy.p (buffer new_buyer-in-buyer-group , input-output v-sec )  .
         release new_buyer-in-buyer-group.
        find first old_buyer-in-buyer-group exclusive-lock where
                    old_buyer-in-buyer-group.bgr-id       = old-b-id       and
                    old_buyer-in-buyer-group.bgr-db-num   = old-b-db-num   and
                    old_buyer-in-buyer-group.bbg-obj-code = p-cli-code     and
                    old_buyer-in-buyer-group.bbg-obj-type = p-cli-type     .
        assign
          old_buyer-in-buyer-group.stts         = 1
        .
        run ref/h-grbuy.p (buffer old_buyer-in-buyer-group , input-output v-sec )  .
        release old_buyer-in-buyer-group.
        run ref/trans-gr.p ( p-cli-type ,p-cli-code)  .
end.

return .
