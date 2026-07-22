block-level on error undo, throw.
/*

$Revision: 3e87f6d879b9, 3293, rls $
$Author: VSpiridonov $
$Date: 2023/03/29 08:48:06 $
$Workfile: sendkkt.p $
$Archive: str/sendkkt.p $

Отсылка схемы интеграции ККТ

Автор: Шкляр Елена
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

Input:

Output:

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 3e87f6d879b9, 3293, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/03/29 08:48:06 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendkkt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendkkt.p $":U .
define variable vss-description as character no-undo init "Отсылка схемы интеграции ККТ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


define variable p-obj-type as character no-undo .
define variable i-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.
define variable p-value as character no-undo .
   DEFINE VARIABLE v-dop          AS CHARACTER NO-UNDO.
   DEFINE VARIABLE v-ffd-version  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE v-kkt-version  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE v-ffd-version_ AS CHARACTER NO-UNDO.
define stream str-log .
output stream  str-log to value("shema-KKT.log") append.

assign
p-obj-type = entry(1, p-parameter, {&delim-par})
i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action     = entry(3, p-parameter, {&delim-par})
p-value    = entry(4, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).

{ str/cdsnddef.i }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ gbl/cd-attr.i }

  define variable v-chk-act-host-code as integer   no-undo .
  define variable v-log as logical   no-undo .
  
  { gbl/hostcode.i
    {&shop}
    abs(i-obj-code)
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-goods_add-def':U
    {&cntxt-object}
    v-chk-act-host-code
    {&shop}
    abs(i-obj-code)
    0
    0
    0
    true
    v-log
  }
  if not  v-log then
      return .
   
FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           ub.cash-desk.pos-type = {&cd-type-IBM-XML} AND
           ub.cash-desk.obj-code = i-obj-code
            No-error.
IF not avail(cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 схемы интеграции ККТ реализуется только для касс &3 "
                          , (if action = "U" then "Передача" else "Удаление")
                          , {&cd-type-ibm-xml}
                        )
                        ).
  return.
end.


{ str/putc-kkt.i }

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cykkt.i }

/*PROCEDURE SENDING.*/
{ str/cd-sekkt.i }

RUN SENDING no-error.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке схемы интеграции ККТ на кассы &1&2"
                         , p-obj-type, i-obj-code
                        )
                                        ).
end.
output stream str-log close.      




