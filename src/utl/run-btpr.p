block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: run-btpr.p $
$Archive: utl/run-btpr.p $

Процедура запуска обработки отложенных заданий из интерфейса

Автор: Перваков Михаил Сергеевич
Дата создания: 06/21/00
Author: Mikhail Pervakov
Creation date: 06/21/00

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-install      as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-btpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/run-btpr.p $":U .
define variable vss-description as character no-undo init "Процедура запуска обработки отложенных заданий из интерфейса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable lok as logical   no-undo .

do
on error undo, return error
:
  assign
    lok = false
  .

  if p-install = false
  then do:
    find first BatchProcess no-lock
      where batchprocess.bp_status = {&btpr-normal}
      no-error .

    if not available BatchProcess then do:
      message
        "Все отложенные задания выполнены или выполняются." skip
        "Вы хотите запустить обработку отложенных заданий?" skip
        view-as alert-box information buttons yes-no update lok .
    end.
    else do:
      message
        "Существуют невыполненные отложенные задания." skip
        "Вы действительно хотите запустить обработку отложенных заданий?" skip
        "Это может занять много времени." skip
        view-as alert-box information buttons yes-no update lok .
    end.
    if lok <> true then do:
      return . /* --->>>--- */
    end.
  end.

  def frame a
    "Обработка отложенных заданий..."
    with view-as dialog-box side-labels three-d
    .
  view frame a .

  run trg/batch_pr.p
    (input parparentproc
    ) .

  if p-install = false
  then do:
    message
      "Обработка отложенных заданий завершена." skip
      view-as alert-box information buttons yes-no update lok .
  end.
end.