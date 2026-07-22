block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-grbuy.p $
$Archive: ref/h-grbuy.p $

Процедура для записи истории по покупателям в группе покупателей

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-grbuy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-grbuy.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по покупателям в группе покупателей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define parameter buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group .
define input-output  parameter p-sec as integer   no-undo .

if p-sec = 0 or p-sec = ? then
   p-sec = next-value (s-corr-chip, {&db-name_schema}) .

find first ub.c-buyer-in-buyer-group no-lock where
        ub.c-buyer-in-buyer-group.chip-num           = p-sec     and
        ub.c-buyer-in-buyer-group.corr-user-db-num   = g#db-num  and
        ub.c-buyer-in-buyer-group.bbg-obj-type       = buf_buyer-in-buyer-group.bbg-obj-type     and
        ub.c-buyer-in-buyer-group.bbg-obj-code       = buf_buyer-in-buyer-group.bbg-obj-code     and
        ub.c-buyer-in-buyer-group.bgr-id             = buf_buyer-in-buyer-group.bgr-id  and
        ub.c-buyer-in-buyer-group.bgr-db-num         = buf_buyer-in-buyer-group.bgr-db-num no-error .
        if available ub.c-buyer-in-buyer-group then  p-sec = next-value (s-corr-chip, {&db-name_schema}) .

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-buyer-in-buyer-group.
      BUFFER-COPY buf_buyer-in-buyer-group TO ub.c-buyer-in-buyer-group
      assign
        ub.c-buyer-in-buyer-group.chip-num           = p-sec
        ub.c-buyer-in-buyer-group.corr-time          = start-time
        ub.c-buyer-in-buyer-group.corr-user-db-num   = g#db-num
        ub.c-buyer-in-buyer-group.corr-user-name     = g#userid
        ub.c-buyer-in-buyer-group.corr-date          = v-today
    .

      find first ub.c-buyer-group no-lock where
                 ub.c-buyer-group.chip-num    = ub.c-buyer-in-buyer-group.chip-num and
                 ub.c-buyer-group.bgr-id      = ub.c-buyer-in-buyer-group.bgr-id and
                 ub.c-buyer-group.bgr-db-num  = ub.c-buyer-in-buyer-group.bgr-db-num
                 no-error .
      if not available ub.c-buyer-group then do:
            find first ub.buyer-group no-lock where
                       ub.buyer-group.bgr-id      = ub.c-buyer-in-buyer-group.bgr-id and
                       ub.buyer-group.bgr-db-num  = ub.c-buyer-in-buyer-group.bgr-db-num
                       no-error .
            /* создание шапки для просмотра истории по линии */
            if available ub.buyer-group then do :
                create ub.c-buyer-group.
                BUFFER-COPY ub.buyer-group TO ub.c-buyer-group
                assign
                  ub.c-buyer-group.chip-num           = ub.c-buyer-in-buyer-group.chip-num
                  ub.c-buyer-group.corr-time          = start-time
                  ub.c-buyer-group.corr-user-db-num   = g#db-num
                  ub.c-buyer-group.corr-user-name     = g#userid
                  ub.c-buyer-group.corr-date          = v-today
              .
            end.
      end.
end.