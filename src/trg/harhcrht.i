/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание записи межфирменного архива hold-time

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure create-hold-time :
define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
define input parameter p-start-date like ub.hold-time.start-date no-undo .

DEFINE VARIABLE v-end-date like ub.hold-time.end-date no-undo .
define buffer buf_hold-time for ub.hold-time .
define buffer last_hold-time for ub.hold-time .


  do
  on error undo, return error
  :
    find last last_hold-time no-lock
      where last_hold-time.cat-code = p-cat-code
      use-index pi
      no-error .

    run gbl/lastdate.p
      (input p-start-date
      ,output v-end-date)
      no-error .
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка поиска последней даты периода" skip
      "Дата начала периода" p-start-date
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.

    create buf_hold-time.
    assign
      buf_hold-time.cat-code       = p-cat-code
      buf_hold-time.time-code      = (if available last_hold-time
                                      then (last_hold-time.time-code + 1)
                                      else 1)
      buf_hold-time.time-type      = {&harh-type-month}
      buf_hold-time.start-date     = p-start-date
      buf_hold-time.end-date       = v-end-date
      buf_hold-time.create-date    = today
      buf_hold-time.update-date    = today
      buf_hold-time.grpupdate-date = today
    .
  end.

end procedure. /* create-hold-time */