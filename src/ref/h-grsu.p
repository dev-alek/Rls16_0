block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-grsu.p $
$Archive: ref/h-grsu.p $

Процедура для записи истории по ОБЪЕКТУ добавляемые в группу

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-grsu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-grsu.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по ОБЪЕКТУ добавляемые в группу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define parameter buffer buf_sum-in-sum-group for ub.sum-in-sum-group .
define input-output  parameter p-sec as integer   no-undo .

p-sec = next-value (s-corr-chip, {&db-name_schema}) .

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:
find first ub.sum-group exclusive-lock where
      ub.sum-group.sgr-id      = buf_sum-in-sum-group.sgr-id and
      ub.sum-group.sgr-db-num  = buf_sum-in-sum-group.sgr-db-num
      no-error .

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-sum-in-sum-group.
      BUFFER-COPY buf_sum-in-sum-group TO ub.c-sum-in-sum-group
      assign
        ub.c-sum-in-sum-group.chip-num           = p-sec
        ub.c-sum-in-sum-group.corr-time          = start-time
        ub.c-sum-in-sum-group.corr-user-db-num   = g#db-num
        ub.c-sum-in-sum-group.corr-user-name     = g#userid
        ub.c-sum-in-sum-group.corr-date          = v-today
    .

      find first ub.c-sum-group no-lock where
                 ub.c-sum-group.chip-num    = ub.c-sum-in-sum-group.chip-num and
                 ub.c-sum-group.sgr-id      = ub.c-sum-in-sum-group.sgr-id and
                 ub.c-sum-group.sgr-db-num  = ub.c-sum-in-sum-group.sgr-db-num
                 no-error .
      if not available ub.c-sum-group then do:

            if available ub.sum-group then do :
                create ub.c-sum-group.
                BUFFER-COPY ub.sum-group TO ub.c-sum-group
                assign
                  ub.c-sum-group.chip-num           = ub.c-sum-in-sum-group.chip-num
                  ub.c-sum-group.corr-time          = start-time
                  ub.c-sum-group.corr-user-db-num   = g#db-num
                  ub.c-sum-group.corr-user-name     = g#userid
                  ub.c-sum-group.corr-date          = v-today
              .
            end.
      end.

  find first ub.sum-group no-lock where
      ub.sum-group.sgr-id      = buf_sum-in-sum-group.sgr-id and
      ub.sum-group.sgr-db-num  = buf_sum-in-sum-group.sgr-db-num
       .
  run str/callnews.p
    (input "sum-group"
    ,input (buffer ub.sum-group:handle)
    ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче в новости sum-group" skip
        return-value skip
        view-as alert-box error .
        return error.
    end.

end.