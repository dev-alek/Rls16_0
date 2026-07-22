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


define temp-table tt-rvs like ub.rvs-doc.
define var v-doc-code as char no-undo.

if testId <> ? then
do:
  find first ub.rvs-doc where rowid(ub.rvs-doc) = testId no-lock no-error.
  if not avail ub.rvs-doc then return.  
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер сверки"
.

update v-doc-code with frame frame1.

find first ub.rvs-doc where ub.rvs-doc.rvs-code = v-doc-code no-error.

if not available (ub.rvs-doc)
  then do:
    message "Документ сверки не найден: номер " v-doc-code view-as alert-box.
    return.
  end.
end.

buffer-copy rvs-doc except rvs-doc.status_ to tt-rvs  assign tt-rvs.status_ = "накл". /* для имитации изменения статуса на факт */

{ gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_rvs-doc}
  " buffer tt-rvs:handle "
  " buffer ub.rvs-doc:handle "  ''
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
      "Документ сверки " rvs-doc.rvs-code " отправлен"
      skip. 
  else
    message rvs-doc.rvs-code " отправлен" view-as alert-box.
end.
