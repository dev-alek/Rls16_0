block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ассортиментной матрицы заголовка

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.assortment-matrix OLD old_assortment-matrix.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ассортиментной матрицы заголовка ".
{ cmp/vssrevis.i "substitute('&1', ub.assortment-matrix.asmt-id ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }

define buffer buf_c-assortment-matrix   for ub.c-assortment-matrix.
define buffer buf_old_assortment-matrix for ub.assortment-matrix.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .


main-block :
do transaction
on error undo main-block, return error
:
run cur-time in this-procedure(output v-date, output v-time).
if ub.assortment-matrix.asmt-status <> 0 then do:
   for each ub.assortment-matrix-goods exclusive-lock where
            ub.assortment-matrix-goods.asmt-id      =  ub.assortment-matrix.asmt-id  and
            ub.assortment-matrix-goods.db-num       =  ub.assortment-matrix.db-num :
   assign
     ub.assortment-matrix-goods.asmg-status = ub.assortment-matrix.asmt-status
   .
   end.
end.
if not g#news then do:
    if ub.assortment-matrix.asmt-db-num-create = ? then do:
        assign
            ub.assortment-matrix.asmt-date-create    = v-date
            ub.assortment-matrix.asmt-time-create    = v-time
            ub.assortment-matrix.asmt-db-num-create  = g#db-num
            ub.assortment-matrix.asmt-who-create     = g#userid
            ub.assortment-matrix.db-num              = g#db-num
        .
    end.
      assign
        ub.assortment-matrix.asmt-date-update     = v-date
        ub.assortment-matrix.asmt-time-update     = v-time
        ub.assortment-matrix.asmt-db-num-update   = g#db-num
        ub.assortment-matrix.asmt-who-update      = g#userid
      .

      if ub.assortment-matrix.obj-type <> "" and ub.assortment-matrix.obj-type <> ? then do:
          { gbl/objdbnum.i
          ub.assortment-matrix.obj-type
          ub.assortment-matrix.obj-code
          ub.assortment-matrix.db-num-obj }
          end.
      else
          assign
            ub.assortment-matrix.db-num-obj = 0
          .
  end.


/* ИСТОРИЯ */
    run cur-time in this-procedure(output v-date, output v-time).
    if old_assortment-matrix.asmt-db-num-create <> ? then do:
        create buf_c-assortment-matrix.
        buffer-copy old_assortment-matrix to buf_c-assortment-matrix
        assign
          buf_c-assortment-matrix.chip-num        = next-value (s-ref-obj-corr-chip, {&db-name_schema})
          buf_c-assortment-matrix.casm-date-his   = v-date
          buf_c-assortment-matrix.casm-time-his   = v-time
          buf_c-assortment-matrix.corr-user-db-num = g#db-num
          buf_c-assortment-matrix.corr-user-name   = g#userid
        .
    end.

/* Отправка по новостям */
  if /* g#db-num = 0 or ( g#db-num <> 0 and g#news = false ) */ true   then do:
      run str/callnews.p
        (input "assortment-matrix"
        ,input (buffer ub.assortment-matrix:handle)
        ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при передаче в новости" skip
          return-value skip
          view-as alert-box error .
          return error.
      end.
  end.
  if g#db-num = 0 and g#news then do:    /* прием в ГБД */
     /* если не шаблон надо проверить наличие такого же на объекте */
     if ub.assortment-matrix.asmt-type = {&type-assmatr-obj} and ub.assortment-matrix.asmt-status = 0 then do:
        find first buf_old_assortment-matrix no-lock where
                   buf_old_assortment-matrix.asmt-status = 0 and
                    not (
                    buf_old_assortment-matrix.asmt-id   = ub.assortment-matrix.asmt-id and
                    buf_old_assortment-matrix.db-num    = ub.assortment-matrix.db-num ) and

                   buf_old_assortment-matrix.obj-type    = ub.assortment-matrix.obj-type and
                   buf_old_assortment-matrix.obj-code    = ub.assortment-matrix.obj-code and
                   buf_old_assortment-matrix.asmt-type    = ub.assortment-matrix.asmt-type no-error .
        if available buf_old_assortment-matrix then do:
           assign
             ub.assortment-matrix.asmt-status = 1
             ub.assortment-matrix.asmt-des = trim(ub.assortment-matrix.asmt-des) + " " + " СПН поменял статус , так как есть на объекте АМ:" +
            string(buf_old_assortment-matrix.asmt-id) + " " +
            buf_old_assortment-matrix.asmt-name
           .
            run str/callnews.p
              (input "assortment-matrix"
              ,input (buffer ub.assortment-matrix:handle)
              ) no-error .
            if error-status:error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при передаче в новости (2)" skip
                return-value skip
                view-as alert-box error .
                return error.
            end.
       end.
     end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_assortment-matrix}
        , input ( buffer ub.assortment-matrix:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.