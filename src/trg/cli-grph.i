/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории  для спула групп клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/24/04
Author: Bakhtadze Natalya
Creation date: 08/24/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "cli-grp-trig" &then

procedure cli-grph_write-cli-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref  as character no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-grp for ub.c-cli-grp.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cli-grp.
    buffer-copy {2} to buf_c-cli-grp
    assign
    buf_c-cli-grp.node-code           = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-cli-grp.chip-num           = next-value (s-cli-grp-chip, {&db-name_schema})
    buf_c-cli-grp.corr-time          = v-time
    buf_c-cli-grp.corr-user-db-num   = g#db-num
    buf_c-cli-grp.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else
                                             g#userid)
                                        )
    buf_c-cli-grp.corr-date          = v-date
    buf_c-cli-grp.is-del             = (p-action = integer({&hn-delete}))
    buf_c-cli-grp.action             =  p-action
    buf_c-cli-grp.subject            = {&table_cli-grp}
    .
  end.

end procedure.

&endif