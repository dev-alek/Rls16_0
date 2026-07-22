block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 10/06/05
Author: Svetlana Chernova
Creation date: 10/06/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.schet-fact-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление счета-фактуры".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.schet-fact-doc.doc-code, ub.schet-fact-doc.doc-date, ub.schet-fact-doc.status_) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
  define buffer buf_factur-connect  for ub.factur-connect.
  define buffer buf_schet-fact-line for ub.schet-fact-line.
  define buffer buf_fin-ob  for ub.fin-ob.
  define buffer buf_fin-doc for ub.fin-doc.
  define buffer buf_trn-doc for ub.trn-doc.

  define variable  p-sys-date     as date      no-undo .
  define variable  p-sys-time     as character no-undo .
  define variable  p-sys-time-int as integer   no-undo .

  for each buf_factur-connect exclusive-lock
    where buf_factur-connect.db-num          = ub.schet-fact-doc.db-num
      and buf_factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
  :
    delete buf_factur-connect .
  end.
  for each buf_schet-fact-line exclusive-lock
     where buf_schet-fact-line.db-num   = ub.schet-fact-doc.db-num
       and buf_schet-fact-line.doc-code = ub.schet-fact-doc.doc-code
  :
    delete buf_schet-fact-line .
  end.
  if ub.schet-fact-doc.in-doc-type <> "" then do:
    case ub.schet-fact-doc.in-doc-type :
      when {&SFEDT_Fin_Ob} then do:  /* по ФО */
        find first buf_fin-ob exclusive-lock where buf_fin-ob.host-code = ub.schet-fact-doc.host-code and  buf_fin-ob.doc-code = ub.schet-fact-doc.in-doc-code no-error .
        if available buf_fin-ob then do:
          assign
            buf_fin-ob.factur-date      = ?
            buf_fin-ob.cr-factur        = no
            buf_fin-ob.need-factur      = 1
          .
        end.
      end.
      when {&SFEDT_Trn_doc} then do:     /* по накладной */
        find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = ub.schet-fact-doc.in-doc-code no-error .
        if available buf_trn-doc then do:
          assign
            buf_trn-doc.factur-date      = ?
            buf_trn-doc.cr-factur        = no
            buf_trn-doc.need-factur      = 1
          .
        end.
      end.
      when {&SFEDT_Fin_Doc} then do:     /* по платежу */
        find first buf_fin-doc exclusive-lock where buf_fin-doc.host-code = ub.schet-fact-doc.host-code and  buf_fin-doc.fin-doc-code = int(ub.schet-fact-doc.in-doc-code) no-error .
        if available buf_fin-doc then do:
          assign
            buf_fin-doc.factur-date      = ?
            buf_fin-doc.cr-factur        = no
            buf_fin-doc.need-factur      = 1
          .
        end.
      end.
    end.
  end.

  if not g#news and ( g#db-num <> 0 or ub.schet-fact-doc.db-num <> g#db-num) then do:
    /* отправляем команду по новостям */
    define variable v-list-db as character no-undo .
    if g#db-num <> 0 then assign v-list-db = "0" .
    else                  assign v-list-db = string(ub.schet-fact-doc.db-num) .
    run nws/cmd-del.p
      ( input {&table_schet-fact-doc}
       ,input (buffer ub.schet-fact-doc:handle)
       ,input v-list-db
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
end.