block-level on error undo, throw.
&scope minvalue 1000000000

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 120b44b64ef4, 1863, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed May 08 13:02:45 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: set-range-bcgb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/set-range-bcgb.p $":U .
define variable vss-description as character no-undo init "Установка диапазона дя товаров с 1с".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
define variable mParams as character no-undo.
define buffer bufcode-range    for code-range.
define variable mMax as int64 no-undo.
mParams = trim(session:parameter,'"').

 
  if dynamic-current-value( "s-bcgb-code", "ub" ) > {&minvalue} then return.
  define variable conf-par as character no-undo.
  define variable mode-erprn as logical no-undo.
  define variable par-type as character no-undo.
    { gbl/conf-rd.i
    "'is-erpRN'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    NO
    conf-par
    par-type
    no-error
    }
    
    if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
    if not mode-erprn then return.
    find first sys-ctrl no-lock no-error. 
    disable triggers for load of code-range. 
    find code-range no-lock
        where code-range.range-type = {&gbl-bc-code}
        and code-range.db-num     = sys-ctrl.db-num
        and code-range.stts       = "a":U
      no-error 
    .
    if     available code-range 
       and code-range.first-code >= {&minvalue} 
    then return.
    find code-range exclusive-lock
        where code-range.range-type = {&gbl-bc-code}
        and code-range.db-num     = sys-ctrl.db-num
        and code-range.stts       = "a":U
      no-error 
    .
    create bufcode-range.
    buffer-copy code-range to bufcode-range 
    assign
       bufcode-range.last-code  = if code-range.last-code > {&minvalue} then code-range.last-code else 2000000000
       bufcode-range.first-code = {&minvalue}.
    assign   
       code-range.last-code     = {&minvalue} - 1
       code-range.stts          = "u":U
       .
    if code-range.first-code eq  1
    then 
       code-range.first-code = 100000.    
    dynamic-current-value( "s-bcgb-code", "ub" ) = {&minvalue}.
    finally:
       quit.         
    end finally.
    
