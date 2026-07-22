block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: movnwsgp.p $
$Archive: utl/movnwsgp.p $

Проталкивание параметров в новости

Автор: Чернова Светлана Александровна
Дата создания: 05/16/08
Author: Svetlana Chernova
Creation date: 05/16/08

*/
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-instal as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: movnwsgp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/movnwsgp.p $":U .
define variable vss-description as character no-undo init "Проталкивание параметров в новости".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
if g#db-num <> 0 then do:
  message "Утилита для ГБД" view-as alert-box error .
  return .
end.

on write of ub.thbj-attr   override do: end.
on delete of ub.thbj-attr  override do: end.

  for each ub.thbj-attr exclusive-lock where
            ub.thbj-attr.upper-prop-code = {&attr-contr-in} or
            ub.thbj-attr.upper-prop-code = {&attr-nakl_par} or
            ub.thbj-attr.upper-prop-code = {&attr-overval}  :
        run str/callnews.p
          (input "thbj-attr"
          ,input (buffer ub.thbj-attr:handle)
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно маршрутизировать thbj-attr для отправки в новости" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
  end.

message "все!" view-as alert-box information .