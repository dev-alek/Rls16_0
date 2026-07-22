block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Простая пересылка товаров на кассу по списку товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
def input param i-obj-code like ub.clients.obj-code no-undo.
def input param p-batch as logical no-undo.
*/

&SCOPED-DEFINE called send-gds
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Простая пересылка товаров на кассу по списку товаров":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i     }

define variable v-cntxt-db-num        as integer   no-undo . /* текущая БД            */
define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */


define variable i-obj-code like ub.clients.obj-code no-undo.
define variable p-batch as logical no-undo .
define variable action     as   character no-undo init "U".
define variable p-other    as character no-undo .
define variable onecash    as int no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
p-batch  = (if entry(2, p-parameter, {&delim-par}) = "yes"
            then yes
            else (if entry(2, p-parameter, {&delim-par}) = "no"
                  then no
                  else ?)
           )
p-other = (if num-entries(p-parameter, {&delim-par}) > 2
           then entry(3, p-parameter, {&delim-par})
           else "":U)
no-error
.

if error-status:error or p-batch = ? then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
if num-entries(p-parameter, {&delim-par}) > 3
   and entry(4, p-parameter, {&delim-par}) ne ""
then
   onecash = int (entry(4, p-parameter, {&delim-par})) no-error.

if not g#news
and not g#auto then do:
run get-userid in parparentproc ( output v-cntxt-userid) .
run get-db-num in parparentproc ( output v-cntxt-db-num) .
end.

{ cmp/gds-list.i gds-list def shared }
define variable v-production-only as logical init false.
for each gds-list :
  { gbl/gdscdat.i
    gds-list.gds-code
    "'production-only=request':u"
    v-production-only
    no-error
  }
  if error-status :error
  then do:
    assign v-production-only = no .
  end.
  if v-production-only
  then do :
    delete gds-list .
  end .
end .
{ str/sendgood.i }