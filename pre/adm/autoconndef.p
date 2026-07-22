block-level on error undo, throw.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable g#auto-pid           as integer   no-undo .
define new shared variable conn-par             as character no-undo .
define new shared variable g#auto-user-id       as character no-undo .
define new shared variable g#auto-user-login    as character no-undo .
define new shared variable g#auto-user-password as character no-undo .
define new shared variable v-socket             as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable auto-window-h     as handle    no-undo .
define new shared variable auto-log-msg-h    as handle    no-undo .
define new shared variable hand-log-msg-h    as handle    no-undo .
define new shared variable log-file-name     as character no-undo initial ? .
define new shared variable add-log-file-name as character no-undo initial ? .
define new shared variable writelogvalue     as character no-undo initial ? .
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
