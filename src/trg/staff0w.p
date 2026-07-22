block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: staff0w.p $
$Archive: trg/staff0w.p $

Триггер на изменение таблицы staff-attr

Автор: Белоусов Илья Александрович
Дата создани : 01/11/07
Author: Ilia Belousov
Creation date: 01/11/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.staff-attr old old-staff-attr.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staff0w.p $":U .
define variable vss-archive     as character no-undo init "$Archive: trg/staff0w.p $":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы staff-attr".


{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

  define variable v-vid-action as integer   no-undo.
  define variable v-vid-param  as longchar  no-undo.
  define variable v-vid-name   as character no-undo .

  { str/initiator.i }
  
if ub.staff-attr.attr-code =  "CashierQRCode" then do:
  find first ub.staff no-lock where ub.staff.staff-code = ub.staff-attr.staff-code and
    ub.staff.role = ub.staff-attr.role and
    ub.staff.role-level = ub.staff-attr.role-level and
    (ub.staff.date-end > today or ub.staff.date-end = ?) no-error .
  if available (ub.staff) then 
  do:
    find first ub.clients NO-LOCK WHERE ub.clients.obj-type = {&prs} and ub.clients.obj-code = ub.staff.psn-code no-error .
    run get-staff-name ( ub.clients.obj-name, ub.clients.obj-code, ub.clients.stts, output v-vid-name ) .
  end.  

  run trg/userlog.p (
    input 'run-proc'
    , input ('Изменен QR-code для пользователя: "'   
    + v-vid-name +  '"' + {&delim-key} + "QR-code" )
    , input ( buffer ub.staff-attr :handle )
    , input v-vid-action
    , input v-vid-param
    ) no-error.

end.    

PROCEDURE get-staff-name :
  define input parameter p-obj-name as character no-undo .
  define input parameter p-psn-code as integer no-undo .
  define input parameter p-stts as integer no-undo .
  define output parameter p-name as character no-undo .

  do
    on error undo, return error return-value
    :
    define buffer buf_person for ub.person.
    
    find first buf_person no-lock where
      buf_person.psn-code = p-psn-code no-error.
    p-name = substitute("&1 &2 &3"
      , p-obj-name
      , (if available buf_person then buf_person.name1 else '')
      , (if available buf_person then buf_person.name2 else '')
      ).

(IF (p-stts = integer({&current-status-int}))
THEN p-name
ELSE (substring (p-name,1, 25) +
                FILL ({&space-char}, 25 - LENGTH (substring (p-name, 1, 25)) )) +
                {&deleted-stat_}).
  end.

END PROCEDURE.
end. /* main-block */
