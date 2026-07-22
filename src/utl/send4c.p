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


define temp-table tt-price-doc like ub.price-doc.
define var v-doc-code as char no-undo.

if testId <> ? then
do:
  find first ub.price-doc where rowid(ub.price-doc) = testId no-lock no-error.
  if not avail ub.price-doc then return.  
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер переоценки"
.

update v-doc-code with frame frame1.

find first ub.price-doc where ub.price-doc.doc-num = v-doc-code no-error.

if not available (ub.price-doc)
  then do:
    message "Документ переоценки не найден: номер " v-doc-code view-as alert-box.
    return.
  end.
end.

buffer-copy ub.price-doc except ub.price-doc.status_ to tt-price-doc  assign tt-price-doc.status_ = "приказ". /* для имитации изменения статуса на акт */

{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_price-doc}
  " buffer tt-price-doc:handle "
  " buffer ub.price-doc:handle "  ''
  ''
  no-error
}
if error-status:error 
then do:
  message return-value view-as alert-box.
end.
else do:
  if testId <> ? then
    put stream vProtTest unformatted 
      "Документ переоценки " ub.price-doc.doc-num " отправлен"
      skip. 
  else
  message ub.price-doc.doc-num " отправлен" view-as alert-box.
end.
