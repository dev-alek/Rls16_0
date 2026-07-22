block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение ДопБК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/16/08
Author: Bakhtadze Natalya
Creation date: 11/16/08

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-silent as logical   no-undo .
/* как отслеживать изменение имени товара для исключения дублей */
define input  parameter dif-pdbc as logical no-undo initial no.
/* запретить в одной БД добавление Доп.БК на товар, если он есть на другом товаре */
define input  parameter pbc-veto  as logical no-undo.
define input  parameter send-ref as logical   no-undo .

define input  parameter p-cdrg-type as character no-undo .
define input  parameter p-ean-type as character no-undo .
define parameter buffer buf_goods for ub.goods.
define input  parameter p-b-code as integer   no-undo .
define input-output  parameter p-b-str as character no-undo .
define output parameter p-recid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение ДопБК".
{ cmp/vssrevis.i }
run trg/prod-bc2.p  (input  parparentproc
                    ,input p-silent /*p-silent*/
                    ,input dif-pdbc /* dif-pdbc */
                    ,input pbc-veto /*pbc-veto*/
                    ,input send-ref
                    ,input p-cdrg-type
                    ,input p-ean-type
                    ,buffer buf_goods
                    ,input p-b-code
                    ,input no 
                    ,input-output p-b-str
                    ,output p-recid
                    ) no-error.
if error-status:error
then 
   return error return-value.
else                       
   return       return-value.