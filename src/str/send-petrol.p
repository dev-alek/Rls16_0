block-level on error undo, throw.
/*

$Revision: aa3cb396dbbb, 2685, rls $
$Author: EShklyar $
$Date: Пт дек 18 18:16:04 2020 +0300 $
$Workfile: send-petrol.p $
$Archive: str/send-petrol.p $

Отсылка данных по соответствию товаров/кошельков

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
define input parameter i-obj-code like shop.obj-code no-undo.
define input parameter p-obj-type as character no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
/*выборочно или все!*/
DEFINE INPUT PARAMETER rid-list as char no-undo.
/*список recid cash-pay если selective = yes*/
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aa3cb396dbbb, 2685, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-petrol.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-petrol.p $":U .
define variable vss-description as character no-undo init "Отсылка данных по соответствию товаров/кошельков".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }

{ str/putc-petrol.i }

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-petrol.i }

/*PROCEDURE SENDING.*/
{ str/cd-sepetrol.i }

RUN SENDING no-error.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке данных по соответствию товаров/кошельков &1&2"
                         , p-obj-type, i-obj-code
                        )
                                        ).
end.








