block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : send1c.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Thu Mar 15 18:52:18 MSK 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


{ cmp/trg-def.i  }
{ cmp/library.i  }
{ utl/tt-test-1c.i}


if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
    then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
    then run str/lib-trn4.p persistent no-error .


define temp-table tt-fin like ub.fin-doc.
define var v-doc-code as char no-undo.

if testId ne ? then
do:
  find first ub.fin-doc where rowid(ub.fin-doc) = testId no-lock no-error.
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер фин.документа"
.

update v-doc-code with frame frame1.

find first ub.fin-doc where ub.fin-doc.fin-doc-code = integer(v-doc-code) no-error.
end.

if not available (ub.fin-doc)
  then do:
    message "Документ не найден: номер " v-doc-code view-as alert-box.
    return.
  end.


buffer-copy fin-doc except fin-doc.status_ to tt-fin  assign tt-fin.status_ = "накл". /* для имитации изменения статуса на факт */

    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_fin-doc}
      " buffer tt-fin:handle "
      " buffer ub.fin-doc:handle "
      ''
      ''
      no-error
    }
if error-status:error 
then do:
  message return-value view-as alert-box.
end.
else do:
  if testId ne ? then
    put stream vProtTest unformatted "Фин.документ " fin-doc.prn-doc-code " отправлен" skip. 
  else
    message fin-doc.prn-doc-code " отправлен" view-as alert-box.
end.
