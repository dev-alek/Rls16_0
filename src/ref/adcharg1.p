block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: adcharg1.p $
$Archive: ref/adcharg1.p $

Сохранение изменений в окне Дополнительные расходы

Автор: Чернова Светлана Александровна
Дата создания: 06/09/07
Author: Svetlana Chernova
Creation date: 06/09/07

*/
define input-output parameter p-doc-rec as recid no-undo.
define input  parameter p-gds-code      like  ub.gds-add-charges.gds-code no-undo.
define input  parameter p-algoritm      like  ub.gds-add-charges.algoritm     no-undo.
define input  parameter p-cost-include  like  ub.gds-add-charges.cost-include no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: adcharg1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/adcharg1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в окне Дополнительные расходы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define stream LogStream.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  run ad-char1
      (input-output p-doc-rec
      ,p-gds-code
      ,p-algoritm
      ,p-cost-include
      ) no-error .
      if error-status :error then
      message vss-workfile vss-revision vss-description skip
              return-value skip
              error-status :get-message(1)
              view-as alert-box error
      .
end.

procedure ad-char1 :
  do
  on error undo, return error return-value
  :
define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code     like  ub.gds-add-charges.gds-code no-undo.
define input  parameter p-algoritm     like  ub.gds-add-charges.algoritm      no-undo.
define input  parameter p-cost-include like  ub.gds-add-charges.cost-include  no-undo.

define buffer bufs_gds-add-charges for ub.gds-add-charges.

define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .

{ gbl/curdbnum.i v-db-num }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .

if p-gds-code = 0 or p-gds-code = ? then return .

run cur-time in this-procedure(output v-date, output v-time).
  find first bufs_gds-add-charges exclusive-lock where
            bufs_gds-add-charges.gds-code          = p-gds-code
            no-error .
    if not available bufs_gds-add-charges then do:
        create bufs_gds-add-charges.
        assign
            bufs_gds-add-charges.gds-code           = p-gds-code
        no-error .
        if error-status :error then message "Ошибка при создании записи" error-status :error error-status :get-message(1) .
    end.

if  p-algoritm      <> ? then  bufs_gds-add-charges.algoritm      = p-algoritm      .
if  p-cost-include  <> ? then  bufs_gds-add-charges.cost-include  = p-cost-include  .

      p-doc-rec = recid(bufs_gds-add-charges)    .

 /*  release bufs_gds-add-charges no-error.
  if error-status:error then do:
     message  substitute("Ошибка при сохранении записи  с кодом &1: &2: &3"
                             , p-gds-code
                             , error-status :get-message(1)
                             , return-value
                             )
                             view-as alert-box error .
    undo, return error "":U.

  end. */

end.
end procedure. /* ad-char1 */