/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории  для спула групп товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/24/04
Author: Bakhtadze Natalya
Creation date: 08/24/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "gds-grp-trig" &then

procedure gds-grph_write-gds-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp for ub.c-gds-grp.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp.
    buffer-copy {2} to buf_c-gds-grp
    assign
    buf_c-gds-grp.node-code           = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-gds-grp.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-gds-grp.corr-time          = v-time
    buf_c-gds-grp.corr-user-db-num   = g#db-num
    buf_c-gds-grp.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-gds-grp.corr-date          = v-date
    .

    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code           = buf_c-gds-grp.node-code
    buf_c-gds-grp-hist.action = p-action
    buf_c-gds-grp-hist.subject = {&table_gds-grp}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.

end procedure.

&endif


&if "{1}" = "gds-grp-attr-trig" &then

procedure gds-grph_write-gds-grp-attr-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp-attr for ub.c-gds-grp-attr.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp-attr.
    buffer-copy {2} to buf_c-gds-grp-attr
    assign
    buf_c-gds-grp-attr.node-code          = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-gds-grp-attr.attr-code          = (if p-new-record then {3}.attr-code else  {2}.attr-code)
    buf_c-gds-grp-attr.host-code          = (if p-new-record then {3}.host-code else  {2}.host-code)
    buf_c-gds-grp-attr.obj-type           = (if p-new-record then {3}.obj-type  else  {2}.obj-type)
    buf_c-gds-grp-attr.obj-code           = (if p-new-record then {3}.obj-code  else  {2}.obj-code)
    buf_c-gds-grp-attr.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-gds-grp-attr.corr-time          = v-time
    buf_c-gds-grp-attr.corr-user-db-num   = g#db-num
    buf_c-gds-grp-attr.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-gds-grp-attr.corr-date          = v-date
    .

    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp-attr to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code           = buf_c-gds-grp-attr.node-code
    buf_c-gds-grp-hist.action = p-action
    buf_c-gds-grp-hist.subject = {&table_gds-grp-attr}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    buf_c-gds-grp-hist.is-del = (p-action = integer({&hn-delete}))
    .
  end.

end procedure.

&endif

procedure gds-grph_write-gds-grp-attr-proc  :
define parameter buffer buf_gds-grp-attr for ub.gds-grp-attr .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp-attr for ub.c-gds-grp-attr.


  do
  on error undo, return error
  :
    if not available buf_gds-grp-attr then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определен атрибут группы товара" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp-attr.
    buffer-copy buf_gds-grp-attr to buf_c-gds-grp-attr
    assign
    buf_c-gds-grp-attr.node-code          = buf_gds-grp-attr.node-code
    buf_c-gds-grp-attr.attr-code          = buf_gds-grp-attr.attr-code
    buf_c-gds-grp-attr.host-code          = buf_gds-grp-attr.host-code
    buf_c-gds-grp-attr.obj-type           = buf_gds-grp-attr.obj-type
    buf_c-gds-grp-attr.obj-code           = buf_gds-grp-attr.obj-code
    buf_c-gds-grp-attr.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-gds-grp-attr.corr-time          = v-time
    buf_c-gds-grp-attr.corr-user-db-num   = g#db-num
    buf_c-gds-grp-attr.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-gds-grp-attr.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp-attr to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.action =  p-action
    buf_c-gds-grp-hist.subject = {&table_gds-grp-attr}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */


&if "{1}" = "gds-grp-obj-trig" &then

procedure gds-grph_write-gds-grp-obj-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp-obj for ub.c-gds-grp-obj.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp-obj.
    buffer-copy {2} to buf_c-gds-grp-obj
    assign
    buf_c-gds-grp-obj.node-code          = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-gds-grp-obj.host-code          = (if p-new-record then {3}.host-code else  {2}.host-code)
    buf_c-gds-grp-obj.obj-type           = (if p-new-record then {3}.obj-type  else  {2}.obj-type)
    buf_c-gds-grp-obj.obj-code           = (if p-new-record then {3}.obj-code  else  {2}.obj-code)
    buf_c-gds-grp-obj.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-gds-grp-obj.corr-time          = v-time
    buf_c-gds-grp-obj.corr-user-db-num   = g#db-num
    buf_c-gds-grp-obj.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-gds-grp-obj.corr-date          = v-date
    .

    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp-obj to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code           = buf_c-gds-grp-obj.node-code
    buf_c-gds-grp-hist.action = p-action
    buf_c-gds-grp-hist.subject = {&table_gds-grp-obj}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.

end procedure.

&endif

procedure gds-grph_write-gds-grp-obj-proc  :
define parameter buffer buf_gds-grp-obj for ub.gds-grp-obj .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp-obj for ub.c-gds-grp-obj.


  do
  on error undo, return error
  :
    if not available buf_gds-grp-obj then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определена группы товара на объекте" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp-obj.
    buffer-copy buf_gds-grp-obj to buf_c-gds-grp-obj
    assign
    buf_c-gds-grp-obj.node-code          = buf_gds-grp-obj.node-code
    buf_c-gds-grp-obj.host-code          = buf_gds-grp-obj.host-code
    buf_c-gds-grp-obj.obj-type           = buf_gds-grp-obj.obj-type
    buf_c-gds-grp-obj.obj-code           = buf_gds-grp-obj.obj-code
    buf_c-gds-grp-obj.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-gds-grp-obj.corr-time          = v-time
    buf_c-gds-grp-obj.corr-user-db-num   = g#db-num
    buf_c-gds-grp-obj.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-gds-grp-obj.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp-obj to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.action =  p-action
    buf_c-gds-grp-hist.subject = {&table_gds-grp-obj}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */


&if "{1}" = "tax-rate-gds-grp-trig" &then

procedure gds-grph_write-tax-rate-gds-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-tax-rate-gds-grp.
    buffer-copy {2} to buf_c-tax-rate-gds-grp
    assign
    buf_c-tax-rate-gds-grp.node-code          = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-tax-rate-gds-grp.tax-code           = (if p-new-record then {3}.tax-code else {2}.tax-code)
    buf_c-tax-rate-gds-grp.host-code          = (if p-new-record then {3}.host-code else  {2}.host-code)
    buf_c-tax-rate-gds-grp.obj-type           = (if p-new-record then {3}.obj-type  else  {2}.obj-type)
    buf_c-tax-rate-gds-grp.obj-code           = (if p-new-record then {3}.obj-code  else  {2}.obj-code)
    buf_c-tax-rate-gds-grp.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-tax-rate-gds-grp.corr-time          = v-time
    buf_c-tax-rate-gds-grp.corr-user-db-num   = g#db-num
    buf_c-tax-rate-gds-grp.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-tax-rate-gds-grp.corr-date          = v-date
    .

    create buf_c-gds-grp-hist.
    buffer-copy buf_c-tax-rate-gds-grp to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code           = buf_c-tax-rate-gds-grp.node-code
    buf_c-gds-grp-hist.action = p-action
    buf_c-gds-grp-hist.subject = {&table_tax-rate-gds-grp}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.

end procedure.

&endif

procedure gds-grph_write-tax-rate-gds-grp-proc  :
define parameter buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp.


  do
  on error undo, return error
  :
    if not available buf_tax-rate-gds-grp then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определена группы товара на объекте" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-tax-rate-gds-grp.
    buffer-copy buf_tax-rate-gds-grp to buf_c-tax-rate-gds-grp
    assign
    buf_c-tax-rate-gds-grp.node-code          = buf_tax-rate-gds-grp.node-code
    buf_c-tax-rate-gds-grp.tax-code           = buf_tax-rate-gds-grp.tax-code
    buf_c-tax-rate-gds-grp.host-code          = buf_tax-rate-gds-grp.host-code
    buf_c-tax-rate-gds-grp.obj-type           = buf_tax-rate-gds-grp.obj-type
    buf_c-tax-rate-gds-grp.obj-code           = buf_tax-rate-gds-grp.obj-code
    buf_c-tax-rate-gds-grp.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
    buf_c-tax-rate-gds-grp.corr-time          = v-time
    buf_c-tax-rate-gds-grp.corr-user-db-num   = g#db-num
    buf_c-tax-rate-gds-grp.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                        )
    buf_c-tax-rate-gds-grp.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-tax-rate-gds-grp to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.action =  p-action
    buf_c-gds-grp-hist.subject = {&table_tax-rate-gds-grp}
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */

/* $Workfile$ e n d */