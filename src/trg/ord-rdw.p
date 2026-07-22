block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись строки поставки

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.ORD-line-rcv.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись строки поставки ".
{ cmp/vssrevis.i "substitute('&1', ub.ORD-line-rcv.rcv-code ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }



main-block :
do transaction
on error undo main-block, return error
:

define buffer buf_goods for ub.goods.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_c-ord-line for ub.c-ord-line  .

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


if ub.ORD-line-rcv.gds-code = 0 or ub.ORD-line-rcv.gds-code = ? then do:
   find first buf_goods no-lock
      where buf_goods.artic     = ub.ord-line-rcv.artic
        and buf_goods.prod-type = ub.ord-line-rcv.prod-type
        and buf_goods.prod-code = ub.ord-line-rcv.prod-code
      no-error .
    if available buf_goods then do:
        ub.ORD-line-rcv.gds-code = buf_goods.gds-code .
    end.
end.

  find first buf_ord-doc-rcv no-lock  where
             buf_ord-doc-rcv.doc-code  =  ub.ord-line-rcv.doc-code and
             buf_ord-doc-rcv.rcv-code  =  ub.ord-line-rcv.rcv-code  no-error .

  if available buf_ord-doc-rcv and buf_ord-doc-rcv.status_ <> {&g___new} then do:
      run cur-time in this-procedure ( output v-today
                                     , output start-time ) .

    create ub.c-ord-line.
    BUFFER-COPY ub.ord-line-rcv  TO ub.c-ord-line
    assign
      ub.c-ord-line.chip-num           = next-value (s-corr-chip, {&db-name_schema})
      ub.c-ord-line.rcv-code           = ub.ord-line-rcv.rcv-code
      ub.c-ord-line.corr-time          = start-time
      ub.c-ord-line.corr-user-db-num   = g#db-num
      ub.c-ord-line.corr-user-name     = g#userid
      ub.c-ord-line.corr-date          = v-today
   .

   if not  can-find ( first ub.c-ord-doc no-lock where
              ub.c-ord-doc.chip-num           = ub.c-ord-line.chip-num and
              ub.c-ord-doc.rcv-code           = ub.c-ord-line.rcv-code and
              ub.c-ord-doc.doc-code           = ub.c-ord-line.doc-code ) then do
     :

        create ub.c-ord-doc.
        BUFFER-COPY buf_ord-doc-rcv  TO ub.c-ord-doc
        assign
          ub.c-ord-doc.chip-num           = ub.c-ord-line.chip-num
          ub.c-ord-doc.corr-time          = start-time
          ub.c-ord-doc.corr-user-db-num   = g#db-num
          ub.c-ord-doc.corr-user-name     = g#userid
          ub.c-ord-doc.corr-date          = v-today
      .

    end.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ORD-line-rcv}
        , input ( buffer ub.ORD-line-rcv:handle )
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