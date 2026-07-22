block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finencsh.p $
$Archive: ref/finencsh.p $

Ускоренное создание инкасации в банк

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/04/10
Author: Bakhtadze Natalya
Creation date: 04/04/10

*/


define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-host-code   as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-silent      as logical   no-undo .
define input  parameter p-start-ref   as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finencsh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finencsh.p $":U .
define variable vss-description as character no-undo init "Ускоренное создание инкасации в банк".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/clntattr.i }
define temp-table temp-inkassator no-undo
field obj-type as character
field obj-code as integer
field with-db as logical
index pi is unique primary
obj-type obj-code.

define variable loc-doc-rec as recid no-undo .
define variable v-contract-code like ub.fin-doc.contract-code no-undo .
define variable v-ob-doc-code like ub.fin-ob.doc-code no-undo .
define variable v-receiver-type like ub.fin-doc.receiver-type no-undo .
define variable v-receiver-code like ub.fin-doc.receiver-code no-undo .
define variable v-payer-type like ub.fin-doc.payer-type no-undo .
define variable v-payer-code like ub.fin-doc.payer-code no-undo .
define variable v-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define variable v-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define variable v-curr-code like ub.fin-doc.curr-code no-undo .
define variable v-obj-type like ub.fin-doc.obj-type no-undo .
define variable v-obj-code like ub.fin-doc.obj-code no-undo .
define variable v-cor-acc like ub.fin-doc.cor-acc no-undo.
define variable v-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define variable v-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define variable v-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define variable v-mode as character no-undo.
define variable vlog as logical no-undo .
define variable choice as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-contract-type as character no-undo .
define variable v-contract-cli-type like ub.contract.cli-type no-undo .
define variable v-contract-cli-code like ub.contract.cli-code no-undo .
define variable lock-obj as logical no-undo .
define variable loc#log as logical   no-undo .
define variable v-with-db as character no-undo .
define variable v-type as character no-undo .
define buffer buf_clients-attr for ub.clients-attr.



{ gbl/getcntxt.i get }

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-doc_add-def':U
  {&cntxt-firm}
  p-host-code
  '':U
  0
  0
  0
  0
  "p-silent <> true"
  loc#log
}
if not loc#log then return error.
assign
v-mode = {&add-def}
.

assign
v-cor-acc = 0
v-cor-acc1 = 0
v-an-uchet-code = 0
v-cel-nazn-code  = 0
v-contract-code = 0
v-payer-type = "":U
v-payer-code = 0
v-receiver-code-schet = 0
v-payer-code-schet = 0
v-curr-code     = ?
v-obj-type = p-obj-type
v-obj-code = p-obj-code
lock-obj = yes
v-payer-type = {&cmp}
v-payer-code = p-host-code
.


for each buf_clients-attr no-lock where
        buf_clients-attr.attr-code = {&attr-is-inkassator}
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
 :
  run clntattr-value in this-procedure (
                                          input  buf_clients-attr.obj-type
                                          ,input  buf_clients-attr.obj-code
                                          ,input  {&attr-db}
                                          ,output v-with-db
                                          ,output v-type  ) no-error.
  create temp-inkassator.
  assign
  temp-inkassator.obj-type = buf_clients-attr.obj-type
  temp-inkassator.obj-code = buf_clients-attr.obj-code
  temp-inkassator.with-db  = logical(if v-with-db = ""
                                     or v-with-db = ?
                                     then "no"
                                     else v-with-db)
  .
  release temp-inkassator.
end.
/*найдем единствнного инкасатора по этой БД*/
find temp-inkassator where
    temp-inkassator.with-db = yes no-error.
if available temp-inkassator then do:
  assign
  v-receiver-type = temp-inkassator.obj-type
  v-receiver-code = temp-inkassator.obj-code
  .
end.
if v-receiver-code = 0 then do:
  if p-silent then do:
    undo, return error substitute("Не удалось определить организацию-инкассатора").
  end.
  /*если еще не нашли надем есть ли инкасатры привязанные к данной БД*/
  find first temp-inkassator where
              temp-inkassator.with-db = yes no-error.
  if available temp-inkassator then do:
    /*выбр из списка*/
    run select-from in this-procedure ( input yes
                                      , output v-receiver-type
                                      , output v-receiver-code) no-error .
    if v-receiver-code = 0 then do:
      return.
    end.
  end.
end.
if v-receiver-code = 0 then do:
  /*найдем единствнного инкасатора вообще*/
  find temp-inkassator no-error.
  if available temp-inkassator then do:
    assign
    v-receiver-type = temp-inkassator.obj-type
    v-receiver-code = temp-inkassator.obj-code
    .
  end.
end.
if v-receiver-code = 0 then do:
  if p-silent then do:
    undo, return error substitute("Не удалось определить организацию-инкассатора").
  end.
  /*если еще не нашли надем есть ли инкасатры вообще*/
  find first temp-inkassator no-error.
  if available temp-inkassator then do:
    /*выбр из списка*/
    run select-from in this-procedure ( input ?
                                      , output v-receiver-type
                                      , output v-receiver-code) no-error .
    if v-receiver-code = 0 then do:
      return.
    end.
   end.
end.
/*не нашли инкассатора запустим так*/
if v-receiver-code = 0 then do:
  if p-silent then do:
    undo, return error substitute("Не удалось определить организацию-инкассатора").
  end.
  else do:
    message
    "Ни для Вашей БД, ни для системы в целом не найдено ни одной организации, определенной как ИНКАССАТОР" skip
    "Задайте организацию-ИНКАССАТОРА непосредственно в платеже"
    view-as alert-box WARNING.
  end.
END.
run ref/findoci2.w (
               input parParentProc
              ,input p-host-code /*p-curr-host-code*/
              ,input v-mode
              ,input p-host-code /*p-host-code*/
              ,input 0 /*p-fin-doc-code*/
              ,input v-obj-type
              ,input v-obj-code
              ,input "":U /*p-fin-ext-doc-type*/
              ,input v-contract-code
              ,input '':U /*p-ob-doc-code*/
              ,input v-receiver-type
              ,input v-receiver-code
              ,input v-curr-code
              ,input v-cor-acc
              ,input v-cor-acc1
              ,input v-an-uchet-code
              ,input v-cel-nazn-code
              ,input (if lock-obj then "lock-obj":U else '') /*p-other*/
              ,input-output loc-doc-rec
                          ) no-error
        .
if not error-status :error
and p-start-ref
and loc-doc-rec <> ?
then do:
 v-rid-list = string(loc-doc-rec).
 run ref/findocs.w (
               input parparentproc
              ,input p-host-code
              ,input "":U
              ,input "type-object"
              ,input {&all}  /*p-list*/
              ,input p-host-code /*p-host-code*/
              ,input p-obj-type   /*p-obj-type*/
              ,input p-obj-code   /*p-obj-code*/
              ,input "" /*p-status_ */
              ,input {&expense-cash} /*p-fin-doc-type  */
              ,input "":U   /*p-fin-ext-doc-type*/
              ,input ?      /*p-start-date  */
              ,input ?      /*p-end-date  */
              ,input "":U   /* p-trn-doc-code */
              ,input "":U   /*p-receiver-type */
              ,input 0      /* p-receiver-code */
              ,input "":U   /* p-receiver-r-schet */
              ,input "":U   /*p-PAYER-type */
              ,input 0      /* p-PAYER-code */
              ,input "":U   /* p-PAYER-r-schet */
              ,input ?      /*p-curr-code*/
              ,input 0      /* p-receiver-code-schet */
              ,input 0      /* p-payer-code-schet */
              ,input 0      /*p-contract-code*/
              ,input 0      /*p-cor-acc  */
              ,input 0      /*p-cor-acc1 */
              ,input 0      /*p-an-uchet-code */
              ,input 0      /*p-cel-nazn-code */
              ,input-output v-rid-list).


end.

procedure select-from :
define input  parameter p-with-db as logical   no-undo .
define output parameter p-inkassator-obj-type as character no-undo .
define output parameter p-inkassator-obj-code as integer   no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-sel-codes as character no-undo .
define buffer buf_clients for ub.clients.
for each temp-inkassator where
        p-with-db = ? or temp-inkassator.with-db = p-with-db
:
  find first buf_clients no-lock where
           buf_clients.obj-type = temp-inkassator.obj-type
      and  buf_clients.obj-code = temp-inkassator.obj-code
      .
  assign
  v-codes = v-codes + (if v-codes = ''
                       then ''
                       else {&delim-par} ) +
           temp-inkassator.obj-type + string(temp-inkassator.obj-code)
  v-labels = v-labels + (if v-labels = ''
                       then ''
                       else {&delim-par} ) +
           buf_clients.obj-name.

end.
run gbl/d-list.w ( input "b-sel"
                  ,input "Выберите организацию-инкасатора"
                  ,input v-codes
                  ,input v-labels
                  ,input {&delim-par}
                  ,input "" /*ppresel-codes*/
                  ,output v-sel-codes) no-error.
if error-status:error
or v-sel-codes = ''
then do:
  return "return".
end.
assign
p-inkassator-obj-type = substring(v-sel-codes, 1, 3)
p-inkassator-obj-code = integer(substring(v-sel-codes, 4))
.



 end procedure. /* select-from */