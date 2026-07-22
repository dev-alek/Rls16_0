/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории  для спула групп блюд

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/08/05
Author: Bakhtadze Natalya
Creation date: 08/08/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "fbr-gds-grp-trig" &then

procedure fbr-gds-grph_write-fbr-gds-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-fbr-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-fbr-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.
define buffer buf_c-fbr-gds-grp for ub.c-fbr-gds-grp.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-gds-grp.
    buffer-copy {2} to buf_c-fbr-gds-grp
    assign
    buf_c-fbr-gds-grp.obj-type           = (if p-new-record then {3}.obj-type else {2}.obj-type)
    buf_c-fbr-gds-grp.obj-code           = (if p-new-record then {3}.obj-code else {2}.obj-code)
    buf_c-fbr-gds-grp.node-code           = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-fbr-gds-grp.chip-num           = next-value (s-fbr-gds-grp-chip, {&db-name_schema})
    buf_c-fbr-gds-grp.corr-time          = v-time
    buf_c-fbr-gds-grp.corr-user-db-num   = g#db-num
    buf_c-fbr-gds-grp.corr-user-name     = (if g#news
                                            then {&nts-user}
                                            else (if g#esys
                                                  then {&esys-user}
                                                  else g#userid)
                                            )
    buf_c-fbr-gds-grp.corr-date          = v-date
    .

    create buf_c-fbr-gds-grp-hist.
    buffer-copy buf_c-fbr-gds-grp to buf_c-fbr-gds-grp-hist
    assign
    buf_c-fbr-gds-grp-hist.obj-type           = buf_c-fbr-gds-grp.obj-type
    buf_c-fbr-gds-grp-hist.obj-code           = buf_c-fbr-gds-grp.obj-code
    buf_c-fbr-gds-grp-hist.node-code           = buf_c-fbr-gds-grp.node-code
    buf_c-fbr-gds-grp-hist.action = p-action
    buf_c-fbr-gds-grp-hist.subject = {&table_fbr-gds-grp}
    buf_c-fbr-gds-grp-hist.is-news = g#news
    buf_c-fbr-gds-grp-hist.source-type = p-source-type
    buf_c-fbr-gds-grp-hist.source-ref = p-source-ref
    .
  end.

end procedure.

&endif


&if "{1}" = "fbr-gds-grp-attr-trig" &then

procedure fbr-gds-grph_write-fbr-gds-grp-attr-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-fbr-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-fbr-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.
define buffer buf_c-fbr-gds-grp-attr for ub.c-fbr-gds-grp-attr.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-gds-grp-attr.
    buffer-copy {2} to buf_c-fbr-gds-grp-attr
    assign
    buf_c-fbr-gds-grp-attr.obj-type           = (if p-new-record then {3}.obj-type  else {2}.obj-type)
    buf_c-fbr-gds-grp-attr.obj-code           = (if p-new-record then {3}.node-code else {2}.obj-code)
    buf_c-fbr-gds-grp-attr.node-code          = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-fbr-gds-grp-attr.attr-code          = (if p-new-record then {3}.attr-code else  {2}.attr-code)
    buf_c-fbr-gds-grp-attr.chip-num           = next-value (s-fbr-gds-grp-chip, {&db-name_schema})
    buf_c-fbr-gds-grp-attr.corr-time          = v-time
    buf_c-fbr-gds-grp-attr.corr-user-db-num   = g#db-num
    buf_c-fbr-gds-grp-attr.corr-user-name     = (if g#news
                                            then {&nts-user}
                                            else (if g#esys
                                                  then {&esys-user}
                                                  else g#userid)
                                            )
    buf_c-fbr-gds-grp-attr.corr-date          = v-date
    .

    create buf_c-fbr-gds-grp-hist.
    buffer-copy buf_c-fbr-gds-grp-attr to buf_c-fbr-gds-grp-hist
    assign
    buf_c-fbr-gds-grp-hist.obj-type            = buf_c-fbr-gds-grp-attr.obj-type
    buf_c-fbr-gds-grp-hist.obj-code            = buf_c-fbr-gds-grp-attr.obj-code
    buf_c-fbr-gds-grp-hist.node-code           = buf_c-fbr-gds-grp-attr.node-code
    buf_c-fbr-gds-grp-hist.action = p-action
    buf_c-fbr-gds-grp-hist.subject = {&table_fbr-gds-grp-attr}
    buf_c-fbr-gds-grp-hist.is-news = g#news
    buf_c-fbr-gds-grp-hist.source-type = p-source-type
    buf_c-fbr-gds-grp-hist.source-ref = p-source-ref
    buf_c-fbr-gds-grp-hist.is-del = (p-action = integer({&hn-delete}))
    .
  end.

end procedure.

&endif

procedure fbr-gds-grph_write-fbr-gds-grp-attr-proc  :
define parameter buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.
define buffer buf_c-fbr-gds-grp-attr for ub.c-fbr-gds-grp-attr.


  do
  on error undo, return error
  :
    if not available buf_fbr-gds-grp-attr then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определен атрибут группы блюд" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-gds-grp-attr.
    buffer-copy buf_fbr-gds-grp-attr to buf_c-fbr-gds-grp-attr
    assign
    buf_c-fbr-gds-grp-attr.obj-type           = buf_fbr-gds-grp-attr.obj-type
    buf_c-fbr-gds-grp-attr.obj-code           = buf_fbr-gds-grp-attr.obj-code
    buf_c-fbr-gds-grp-attr.node-code          = buf_fbr-gds-grp-attr.node-code
    buf_c-fbr-gds-grp-attr.attr-code          = buf_fbr-gds-grp-attr.attr-code
    buf_c-fbr-gds-grp-attr.chip-num           = next-value (s-fbr-gds-grp-chip, {&db-name_schema})
    buf_c-fbr-gds-grp-attr.corr-time          = v-time
    buf_c-fbr-gds-grp-attr.corr-user-db-num   = g#db-num
    buf_c-fbr-gds-grp-attr.corr-user-name     = (if g#news
                                            then {&nts-user}
                                            else (if g#esys
                                                  then {&esys-user}
                                                  else g#userid)
                                            )
    buf_c-fbr-gds-grp-attr.corr-date          = v-date
    .
    create buf_c-fbr-gds-grp-hist.
    buffer-copy buf_c-fbr-gds-grp-attr to buf_c-fbr-gds-grp-hist
    assign
    buf_c-fbr-gds-grp-hist.action =  p-action
    buf_c-fbr-gds-grp-hist.subject = {&table_fbr-gds-grp-attr}
    buf_c-fbr-gds-grp-hist.is-news = g#news
    buf_c-fbr-gds-grp-hist.source-type = p-source-type
    buf_c-fbr-gds-grp-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */


/* $Workfile$ e n d */