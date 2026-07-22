block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-grpi.p $
$Archive: ref/h-grpi.p $

Процедура для записи истории по ОБЪЕКТУ добавляемые в группу

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-grpi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-grpi.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по ОБЪЕКТУ добавляемые в группу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define parameter buffer buf_obj-grp-obj-price for ub.obj-grp-obj-price .
define input-output  parameter p-sec as integer   no-undo .

p-sec = next-value (s-corr-chip, {&db-name_schema}) .

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:
find first ub.grp-obj-price exclusive-lock where
           ub.grp-obj-price.gop-id      = buf_obj-grp-obj-price.gop-id and
           ub.grp-obj-price.gop-db-num  = buf_obj-grp-obj-price.gop-db-num
          .

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-obj-grp-obj-price.
      BUFFER-COPY buf_obj-grp-obj-price TO ub.c-obj-grp-obj-price
      assign
        ub.c-obj-grp-obj-price.chip-num           = p-sec
        ub.c-obj-grp-obj-price.corr-time          = start-time
        ub.c-obj-grp-obj-price.corr-user-db-num   = g#db-num
        ub.c-obj-grp-obj-price.corr-user-name     = g#userid
        ub.c-obj-grp-obj-price.corr-date          = v-today
    .

      find first ub.c-grp-obj-price no-lock where
                 ub.c-grp-obj-price.chip-num    = ub.c-obj-grp-obj-price.chip-num and
                 ub.c-grp-obj-price.gop-id      = ub.c-obj-grp-obj-price.gop-id and
                 ub.c-grp-obj-price.gop-db-num  = ub.c-obj-grp-obj-price.gop-db-num
                 no-error .
      if not available ub.c-grp-obj-price then do:

            if available ub.grp-obj-price then do :
                create ub.c-grp-obj-price.
                BUFFER-COPY ub.grp-obj-price TO ub.c-grp-obj-price
                assign
                  ub.c-grp-obj-price.chip-num           = ub.c-obj-grp-obj-price.chip-num
                  ub.c-grp-obj-price.corr-time          = start-time
                  ub.c-grp-obj-price.corr-user-db-num   = g#db-num
                  ub.c-grp-obj-price.corr-user-name     = g#userid
                  ub.c-grp-obj-price.corr-date          = v-today
              .
            end.
      end.
find first ub.grp-obj-price no-lock where
          ub.grp-obj-price.gop-id      = buf_obj-grp-obj-price.gop-id and
          ub.grp-obj-price.gop-db-num  = buf_obj-grp-obj-price.gop-db-num
          .

  run str/callnews.p
    (input "grp-obj-price"
    ,input (buffer ub.grp-obj-price:handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости grp-obj-price" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.

end.