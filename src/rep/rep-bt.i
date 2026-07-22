/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

общая часть для e-  отчетов.

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 09/07/05
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" eq "class"
&then
&else
{ cmp/showinf.i      }
&endif
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable vv-exch-rate  as decimal   no-undo .
define variable vv-exch-scale as decimal   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .

if v-cntxt-level = {&cntxt-object} then do:
  { gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
end.
if v-cntxt-level = {&cntxt-firm} then do:
  find first ub.clients no-lock where
             ub.clients.obj-type = {&cmp} and
             ub.clients.obj-code = v-cntxt-host-code-obj no-error .
if error-status :error then v-cntxt-host-name-obj = ? .
   else v-cntxt-host-name-obj = ub.clients.obj-name.

end.
if v-cntxt-level = {&cntxt-object}
or v-cntxt-level = {&cntxt-firm}
then do:
  { gbl/basecode.i v-cntxt-host-code-obj base-code }
  { gbl/exchrate.i base-code today vv-exch-rate vv-exch-scale base-type }
end.


run get-report-num in my-handle ( output g#report-num ).
run get-gds-engl in my-handle ( output g#gds-engl ) .
/* $Workfile$ e n d */