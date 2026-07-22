
/*------------------------------------------------------------------------
    File        : 1Csendplace.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Wed Nov 26 12:34:59 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

{ cmp/str-glbl.i } 
{ cmp/library.i }

define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

define buffer buf_place for ub.place .
/* ***************************  Main Block  *************************** */

for each buf_place no-lock :
  if buf_place.status_ = {&deleted-status} then next .
  
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
  then do:
    message
      error-status:get-message(1) skip
      return-value
    view-as alert-box error .
  end.
end .
oOk = true.
