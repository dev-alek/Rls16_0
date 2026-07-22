block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-grqu.p $
$Archive: ref/h-grqu.p $

Процедура для записи истории по ОБЪЕКТУ добавляемые в группу

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-grqu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-grqu.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по ОБЪЕКТУ добавляемые в группу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define parameter buffer buf_qnty-in-qnty-group for ub.qnty-in-qnty-group .
define input-output  parameter p-sec as integer   no-undo .

p-sec = next-value (s-corr-chip, {&db-name_schema}) .

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:
find first ub.qnty-group exclusive-lock where
           ub.qnty-group.qgr-id      = buf_qnty-in-qnty-group.qgr-id and
           ub.qnty-group.qgr-db-num  = buf_qnty-in-qnty-group.qgr-db-num
           no-error .

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-qnty-in-qnty-group.
      BUFFER-COPY buf_qnty-in-qnty-group TO ub.c-qnty-in-qnty-group
      assign
        ub.c-qnty-in-qnty-group.chip-num           = p-sec
        ub.c-qnty-in-qnty-group.corr-time          = start-time
        ub.c-qnty-in-qnty-group.corr-user-db-num   = g#db-num
        ub.c-qnty-in-qnty-group.corr-user-name     = g#userid
        ub.c-qnty-in-qnty-group.corr-date          = v-today
    .

      find first ub.c-qnty-group no-lock where
                 ub.c-qnty-group.chip-num    = ub.c-qnty-in-qnty-group.chip-num and
                 ub.c-qnty-group.qgr-id      = ub.c-qnty-in-qnty-group.qgr-id and
                 ub.c-qnty-group.qgr-db-num  = ub.c-qnty-in-qnty-group.qgr-db-num
                 no-error .
      if not available ub.c-qnty-group then do:

            if available ub.qnty-group then do :
                create ub.c-qnty-group.
                BUFFER-COPY ub.qnty-group TO ub.c-qnty-group
                assign
                  ub.c-qnty-group.chip-num           = ub.c-qnty-in-qnty-group.chip-num
                  ub.c-qnty-group.corr-time          = start-time
                  ub.c-qnty-group.corr-user-db-num   = g#db-num
                  ub.c-qnty-group.corr-user-name     = g#userid
                  ub.c-qnty-group.corr-date          = v-today
              .
            end.
      end.


  find first ub.qnty-group no-lock where
               ub.qnty-group.qgr-id      = buf_qnty-in-qnty-group.qgr-id and
               ub.qnty-group.qgr-db-num  = buf_qnty-in-qnty-group.qgr-db-num
              .
  run str/callnews.p
    (input "qnty-group"
    ,input (buffer ub.qnty-group:handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости qnty-group" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.


end.