block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-grph.p $
$Archive: ref/h-grph.p $

Процедура для записи истории по ФИРМЕ добавляемые в группу

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-grph.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-grph.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по ФИРМЕ добавляемые в группу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define parameter buffer buf_host-grp-obj-price for ub.host-grp-obj-price .
define input-output  parameter p-sec as integer   no-undo .

p-sec = next-value (s-corr-chip, {&db-name_schema}) .

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:
  find first ub.grp-obj-price exclusive-lock where
             ub.grp-obj-price.gop-id      = buf_host-grp-obj-price.gop-id and
             ub.grp-obj-price.gop-db-num  = buf_host-grp-obj-price.gop-db-num
            .

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-host-grp-obj-price.
      BUFFER-COPY buf_host-grp-obj-price TO ub.c-host-grp-obj-price
      assign
        ub.c-host-grp-obj-price.chip-num           = p-sec
        ub.c-host-grp-obj-price.corr-time          = start-time
        ub.c-host-grp-obj-price.corr-user-db-num   = g#db-num
        ub.c-host-grp-obj-price.corr-user-name     = g#userid
        ub.c-host-grp-obj-price.corr-date          = v-today
    .

      find first ub.c-grp-obj-price no-lock where
                 ub.c-grp-obj-price.chip-num    = ub.c-host-grp-obj-price.chip-num and
                 ub.c-grp-obj-price.gop-id      = ub.c-host-grp-obj-price.gop-id and
                 ub.c-grp-obj-price.gop-db-num  = ub.c-host-grp-obj-price.gop-db-num
                 no-error .
      if not available ub.c-grp-obj-price then do:
            find first ub.grp-obj-price no-lock where
                      ub.grp-obj-price.gop-id      = ub.c-host-grp-obj-price.gop-id and
                      ub.grp-obj-price.gop-db-num  = ub.c-host-grp-obj-price.gop-db-num
                      no-error .

            if available ub.grp-obj-price then do :
                create ub.c-grp-obj-price.
                BUFFER-COPY ub.grp-obj-price TO ub.c-grp-obj-price
                assign
                  ub.c-grp-obj-price.chip-num           = ub.c-host-grp-obj-price.chip-num
                  ub.c-grp-obj-price.corr-time          = start-time
                  ub.c-grp-obj-price.corr-user-db-num   = g#db-num
                  ub.c-grp-obj-price.corr-user-name     = g#userid
                  ub.c-grp-obj-price.corr-date          = v-today
              .
            end.
      end.

  find first ub.grp-obj-price no-lock where
             ub.grp-obj-price.gop-id      = buf_host-grp-obj-price.gop-id and
             ub.grp-obj-price.gop-db-num  = buf_host-grp-obj-price.gop-db-num
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