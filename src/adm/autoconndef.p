block-level on error undo, throw.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
&glob defonly yes
{ adm/auto-def.i new}

run adm/autoinit.p ( input p-user-login
                    ,input p-user-password
                  ) no-error.
if error-status:error
then
   return error.
run adm/autoconn.p no-error.
if error-status:error
then
   return error.    