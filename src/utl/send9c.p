block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : send9c.p
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

define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .

for each buf_place no-lock where buf_place.status_ <> {&deleted-status}
                             and if testId <> ? then rowid(buf_place) = testId else true:

  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&thref-proc_ref-event}
    " buffer buf_place:handle "
    " buffer buf_place:handle "
    ''
    ''
    no-error
  }
    if error-status :error
      then
    do:
      return error substitute( "Ошибка маршрутизации записи в машину правил&1&2&1&3"
        , {&new-line}
        , return-value
        , error-status :get-message ( 1 ) ).
    end.

  if testId <> ? then
    put stream vProtTest unformatted "Текущая топология по " buf_place.pl-code " отправлена" skip. 
end.

if testId = ? then
  message "Текущая топология отправлена" view-as alert-box.


