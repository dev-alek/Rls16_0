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
{ str/trdcalib.i }
{ utl/tt-test-1c.i}

if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
  then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
  then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
  then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
  then run str/lib-trn4.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
  then run str/trdcalib.p persistent no-error .


define temp-table tt-trn like ub.trn-doc.
define var      v-doc-code as char      no-undo.
define variable varvalue   as character no-undo .
define variable vartype    as character no-undo .

if testId ne ? then
do:
  find first ub.trn-doc where rowid(ub.trn-doc) = testId no-lock no-error.
  v-doc-code = ub.trn-doc.doc-code.  
end.
else
do:
DEFINE FRAME frame1
  v-doc-code format "x(15)"
  with view-as dialog-box
  title "Введите номер документа (накл., инв., перес."
  .

update v-doc-code with frame frame1.
end.

find first ub.trn-doc where ub.trn-doc.doc-code = v-doc-code no-error.

if not available (ub.trn-doc)
  then 
do:
  message "Документ инвентаризации не найден: номер " v-doc-code view-as alert-box.
  return.
end.

buffer-copy trn-doc except trn-doc.status_ to tt-trn  assign 
  tt-trn.status_ = "накл". /* для имитации изменения статуса на факт */

  { gbl/rum-runa.i
  ?
  this-procedure:handle
  ?
  {&edoc-proc_event_trn-doc}
  " buffer tt-trn:handle "
  " buffer ub.trn-doc:handle "  ''
  ''
  no-error
}
if error-status:error 
  then 
do:
  message return-value view-as alert-box.
end.
else 
do:
{ str/tdat-val.i
     trn-doc.doc-code
     {&trdcattr-is-lgas}
     varvalue
     vartype
     no-error
   }
   
  if varvalue = "yes" then 
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "techlosses",
      (buffer trn-doc:handle),
      ?,
      ?) no-error.
    if error-status:error 
      then 
    do:
      message return-value view-as alert-box.
    end.
  end.
if testId ne ? then
  put stream vProtTest unformatted "Документ " v-doc-code " отправлен" skip. 
else
  message trn-doc.doc-code " отправлен" view-as alert-box.
end.


