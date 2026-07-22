block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-grtnv.p $
$Archive: ref/h-grtnv.p $

Процедура для записи истории по ОБЪЕКТУ добавляемые в группу

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/

define parameter buffer buf_tnv-in-turnover-group for ub.tnv-in-turnover-group .
define input-output  parameter p-sec as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-grtnv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-grtnv.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по ОБЪЕКТУ добавляемые в группу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:
p-sec = next-value (s-corr-chip, {&db-name_schema}) .
find first ub.turnover-group exclusive-lock where
           ub.turnover-group.tog-id      = buf_tnv-in-turnover-group.tog-id and
           ub.turnover-group.tog-db-num  = buf_tnv-in-turnover-group.tog-db-num
  no-error .
  if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "2"
        view-as alert-box error
      .
      return.
  end.

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-tnv-in-turnover-group.
      BUFFER-COPY buf_tnv-in-turnover-group TO ub.c-tnv-in-turnover-group
      assign
        ub.c-tnv-in-turnover-group.chip-num           = p-sec
        ub.c-tnv-in-turnover-group.corr-time          = start-time
        ub.c-tnv-in-turnover-group.corr-user-db-num   = g#db-num
        ub.c-tnv-in-turnover-group.corr-user-name     = g#userid
        ub.c-tnv-in-turnover-group.corr-date          = v-today
    .

      find first ub.c-turnover-group no-lock where
                 ub.c-turnover-group.chip-num    = ub.c-tnv-in-turnover-group.chip-num and
                 ub.c-turnover-group.tog-id      = ub.c-tnv-in-turnover-group.tog-id and
                 ub.c-turnover-group.tog-db-num  = ub.c-tnv-in-turnover-group.tog-db-num
                 no-error .
      if not available ub.c-turnover-group then do:

            if available ub.turnover-group then do :
                create ub.c-turnover-group.
                BUFFER-COPY ub.turnover-group TO ub.c-turnover-group
                assign
                  ub.c-turnover-group.chip-num           = ub.c-tnv-in-turnover-group.chip-num
                  ub.c-turnover-group.corr-time          = start-time
                  ub.c-turnover-group.corr-user-db-num   = g#db-num
                  ub.c-turnover-group.corr-user-name     = g#userid
                  ub.c-turnover-group.corr-date          = v-today
              .
            end.
      end.
  find first ub.turnover-group exclusive-lock where
             ub.turnover-group.tog-id      = buf_tnv-in-turnover-group.tog-id and
             ub.turnover-group.tog-db-num  = buf_tnv-in-turnover-group.tog-db-num .
  run str/callnews.p
    (input "turnover-group"
    ,input (buffer ub.turnover-group:handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости turnover-group" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
end.