block-level on error undo, throw.
/*

$Revision: aa3cb396dbbb, 2685, rls $
$Author: EShklyar $
$Date: Пт дек 18 18:16:04 2020 +0300 $
$Workfile: sendpetrol.p $
$Archive: str/sendpetrol.p $

Толкач пересылки данных по соответствию товаров/кошельков

Автор: Морозов Александр Сергеевич
Дата создания: 02/14/14
Author: Alexandr Morozov
Creation date: 02/14/14

Input:

Output:

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aa3cb396dbbb, 2685, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendpetrol.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendpetrol.p $":U .
define variable vss-description as character no-undo init "Отсылка данных по соответствию товаров/кошельков".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable p-obj-type as character no-undo .
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.

define var choice as integer no-undo.
define var rid-list as char no-undo.
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .


assign
p-obj-type = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action     = entry(3, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).

FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           (ub.cash-desk.pos-type = {&cd-type-IBM}
            AND
            ub.cash-desk.obj-code = p-obj-code)
           OR
           (ub.cash-desk.pos-type = {&cd-type-IBM-XML}
           AND
           ub.cash-desk.obj-code = p-obj-code)
            No-error.
IF not avail(cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 данных по соответствию товаров/кошельков реализуется только для POS &2 или POS &3" 
                          , (if action = "U" then "Передача" else "Удаление")
                          , {&cd-type-ibm}
                          , {&cd-type-ibm-xml}
                        )
                                        ).
  return.
end.
run gbl/d-askw.w (input "Выбор соответствий товаров/кошельков для пересылки",
   input ( (if action = "U"
   then "Переслать на кассу"
   else "Удалить из кассы" ) + {&new-line} +
   "информацию о соответствии товаров/кошельков"
   ),
   input "|",
   input "Все|Отказ от пересылки",
   input "|",
   input 1,
   input 2,
   output choice).

if choice = 2 then return.

    run str/send-petrol.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input p-obj-code
                   ,input p-obj-type
                   ,input action
                   ,input 0
                  , input ""
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке данных по соответствию товаров/кошельков &1&2"
                         , p-obj-type, p-obj-code
                        )
                                        ).
end.








