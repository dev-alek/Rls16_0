block-level on error undo, throw.
define input  parameter iParam as character no-undo.
define output parameter oOK as logical no-undo.

{ cmp/str-glbl.i } 

define variable vBufUserLogin as handle no-undo.
define variable vBufSysCtrl     as handle no-undo.

create buffer vBufSysCtrl for table "sys-ctrl".
vBufSysCtrl:find-first ("" , no-lock) no-error.
         
if vBufSysCtrl:available
then do:
   create buffer vBufUserLogin for table "user-login".
   vBufUserLogin:find-first (substitute ("where user-login.db-num eq &1 and user-login.status_    = {&uls-normal} and (user-login.user-password-set-mjd eq 0 or user-login.user-password-set-mjd eq ?)",
                                         vBufSysCtrl:buffer-field ("db-num"):buffer-value ()
                                        ), 
                             no-lock) no-error.
   oOK = not vBufUserLogin:available.
end.
else
   oOK = true.
delete object vBufSysCtrl.