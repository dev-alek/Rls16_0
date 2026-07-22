block-level on error undo, throw.

/*

$Revision: b1f216c91d59, 3334, rls $
$Author: SSlivenko $
$Date: 2023/05/19 13:37:09 $
$Workfile: gds-ref.p $
$Archive: ref/gds-ref.p $

Справочник товаров и товаров на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter bttns         as character no-undo. /* список включенных батонов */
define input  parameter p-stat        as character no-undo .
/*
взять из сохраненного по польз, ?
"Текущие&+",   {&current},
"Все&!",       {&all},
"Удаленные&-", {&deleted}
 */
define input  parameter p-list        as character no-undo .
/*
взять из сохраненного по польз, ?
"Все",          {&all},
"Производитель",{&producer},
"Группа",       {&group}
*/
define input  parameter p-cond        as character no-undo .
/*
взять из сохраненного по польз, ?
"Все",{&all},
"Объект",{&g___object},
"Факт",{&fact},
"Свободно",{&free}
*/
define input  parameter p-rec         as recid     no-undo .
define input  parameter p-grp         like ub.goods.grp-name   no-undo . /*замена g-producer*/
define input  parameter p-cli-type    like ub.clients.obj-type no-undo .
define input  parameter p-cli-code    like ub.clients.obj-code no-undo .
define input  parameter p-obj-type    like ub.clients.obj-type no-undo .
define input  parameter p-obj-code    like ub.clients.obj-code no-undo .
define input  parameter p-other       as character no-undo .
define output parameter rid-list      as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: b1f216c91d59, 3334, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/05/19 13:37:09 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: gds-ref.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: ref/gds-ref.p $":U .
define variable vss-description as character no-undo initial "Справочник товаров и товаров на объекте".
{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5|&6':u,parparentproc,bttns,p-stat,p-list,p-cond,p-rec),substitute('&1|&2|&3|&4|&5|&6':u,p-grp,p-cli-type,p-cli-code,p-obj-type,p-obj-code,p-other))" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

/*переменные в которые будем устанавливать из ubflt.usr-flt*/
define variable v-stat as character no-undo init {&current}.
define variable v-list as character no-undo init {&all}.
define variable v-cond as character no-undo init {&all}.
define variable v-rep  as recid     no-undo init ?.
define variable v-grp  like ub.goods.grp-name no-undo init "":U.
/*замена g-producer*/
define variable v-producer-type like ub.clients.obj-type no-undo init "":U.
define variable v-producer-code  like ub.clients.obj-code no-undo init 0.
define variable v-obj-type like ub.clients.obj-type no-undo init ?.
define variable v-obj-code like ub.clients.obj-code no-undo init ?.
define variable v-other as character no-undo .

define variable v-no-obj as logical no-undo .
define variable v-gds-name-width as decimal no-undo init 31.
define variable v-grp-name-width as decimal no-undo init 60.

DEF new shared VAR sch-rec AS recid no-undo.
DEF new shared VAR loc-art AS CHAR no-undo.
DEF new shared VAR loc-name AS CHAR no-undo.
DEF new shared VAR loc-code AS CHAR no-undo.
DEF new shared VAR a-n-c AS CHAR no-undo.

define buffer buf_clients  for ub.clients .

rid-list = "".
{ gbl/getcntxt.i get }
run uf-get in this-procedure(
    input  {&uf-gds-ref-p}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 8
then do:
  assign
  v-stat       = entry(1, v-uf-List_, {&delim-par})
  v-list       = entry(2, v-uf-List_, {&delim-par})
  v-cond       = entry(3, v-uf-List_, {&delim-par})
  v-rep        = (if entry(4, v-uf-List_, {&delim-par}) = {&question-mark}
                  then ?
                  else integer(entry(4, v-uf-List_, {&delim-par}))
                  )
  v-grp        = entry(5, v-uf-List_, {&delim-par})
  v-producer-type   = entry(6, v-uf-List_, {&delim-par})
  v-producer-code   = integer(entry(7, v-uf-List_, {&delim-par}))
  v-other      = entry(8, v-uf-List_, {&delim-par})
  no-error
  .
  if v-list = "ptrl"
  or v-list = "lgas"
  or v-list = "ptrlsug"
  or v-list = "only-np"
  then do:
    entry(2, v-uf-list_,  {&delim-par} ) = {&all}.
    v-list =  {&all}. 
  end.
  if num-entries(v-uf-Naim, {&delim-par}) >=4 then do:
    assign
    v-gds-name-width = decimal(entry(3, v-uf-naim,  {&delim-par}))
    v-grp-name-width = decimal(entry(4, v-uf-naim, {&delim-par}))
    no-error .
  end.
end.

assign
p-stat      = (if p-stat = ? then v-stat else p-stat)
p-list      = (if p-list = ? then v-list else p-list)
p-cond      = (if p-cond = ? then v-cond else p-cond)
p-rec       = (if p-rec = ?  then v-rep  else p-rec )
p-grp       = (if p-grp = ?  then v-grp  else p-grp )
p-cli-type  = (if p-cli-type = ? then v-producer-type else p-cli-type)
p-cli-code  = (if p-cli-code = ? then v-producer-code  else p-cli-code)
p-other     = (if p-other = ? then v-other else  p-other)
no-error
.
{ gbl/getcntxt.i get }
if p-obj-type = ?
or p-obj-code = ?
then do:
  assign
    p-obj-type = v-cntxt-obj-type
    p-obj-code = v-cntxt-obj-code
  .
end.

if p-obj-type = "":U
or p-obj-code = 0
or p-obj-type = ?
or p-obj-code = ?
then do:
  if num-entries(v-uf-naim, {&delim-par}) >= 2
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = entry(1, v-uf-Naim, {&delim-par})
        and buf_clients.obj-code = integer(entry(2, v-uf-Naim, {&delim-par}))
      no-error .
    if available  buf_clients
    then do:
      define variable v-object-available as logical   no-undo .
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        buf_clients.obj-type
        buf_clients.obj-code
        v-object-available
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры gbl/usobjava.i" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return no-apply .
      end.

      if v-object-available = true
      then do:
        assign
          p-obj-type = buf_clients.obj-type
          p-obj-code = buf_clients.obj-code
          v-no-obj   = yes
        .
      end.
    end.
  end.
end.

define variable v-user-select     as logical   no-undo .
define variable v-select-obj-type as character no-undo .
define variable v-select-obj-code as integer   no-undo .

if p-obj-type = "":U
or p-obj-code = 0
or p-obj-type = ?
or p-obj-code = ?
then do:
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-select-obj-type
    v-select-obj-code
  }
  if v-user-select <> true
  then do:
    return no-apply .
  end.

  assign
    p-obj-type = v-select-obj-type
    p-obj-code = v-select-obj-code
    v-no-obj   = yes
  .

  assign
    p-other = p-other + {&delim-par} + "no-object"
  .
end.
DO WHILE a-n-c <> "вых":u :
    if p-cond = {&all} then
        run ref/goo-ref.w ( input parparentproc
                       ,bttns
                      ,input-output p-stat
                      ,input-output p-list
                      ,input-output p-cond
                      ,input-output p-rec
                      ,input-output p-grp
                      ,input-output p-cli-type
                      ,input-output p-cli-code
                      ,input-output p-obj-type
                      ,input-output p-obj-code
                      ,input-output v-gds-name-width
                      ,input-output v-grp-name-width
                      ,input-output p-other
                      ,input-output rid-list ).
    else do:
        find first ub.assortment-matrix no-lock where
                  ub.assortment-matrix.obj-code = p-obj-code and
                  ub.assortment-matrix.obj-type = p-obj-type and
                  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) no-error .
        if available ub.assortment-matrix then  /* на объекте есть ассортиментая живая матрица */
        run ref/gam-ref.w ( input parparentproc
                      ,bttns
                      ,input-output p-stat
                      ,input-output p-list
                      ,input-output p-cond
                      ,input-output p-rec
                      ,input-output p-grp
                      ,input-output p-cli-type
                      ,input-output p-cli-code
                      ,input-output p-obj-type
                      ,input-output p-obj-code
                      ,input-output v-gds-name-width
                      ,input-output v-grp-name-width
                      ,input-output p-other
                      ,input-output rid-list ).
        else
        run ref/gob-ref.w ( input parparentproc
                      ,bttns
                      ,input-output p-stat
                      ,input-output p-list
                      ,input-output p-cond
                      ,input-output p-rec
                      ,input-output p-grp
                      ,input-output p-cli-type
                      ,input-output p-cli-code
                      ,input-output p-obj-type
                      ,input-output p-obj-code
                      ,input-output v-gds-name-width
                      ,input-output v-grp-name-width
                      ,input-output p-other
                      ,input-output rid-list ).
    end.
END .

assign
v-uf-list_ = p-stat  + {&delim-par} +
              p-list  + {&delim-par} +
              p-cond  + {&delim-par} +
              (if p-rec = ?
              then {&question-mark}
              else string(p-rec)) + {&delim-par} +
              p-grp  + {&delim-par} +
              p-cli-type + {&delim-par} +
              string(p-cli-code) + {&delim-par} +
              p-other
v-uf-NAIM = p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} +
            string(v-gds-name-width) +  {&delim-par} + string(v-grp-name-width)
.

run uf-set in this-procedure(
    input  {&uf-gds-ref-p}
    ,input  v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .