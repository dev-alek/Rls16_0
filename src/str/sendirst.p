block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendirst.p $
$Archive: str/sendirst.p $

Подготовка остатков по основному БК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

{ str/defc-gds.i }

define input  parameter p-parameter   as character no-undo .
define output parameter table for cash-gds .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendirst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendirst.p $":U .
define variable vss-description as character no-undo init "Подготовка остатков по основному БК":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define variable inp-b-code as integer no-undo .
define variable p-obj-code as integer no-undo .
define variable cr as integer no-undo .
define variable l-terminal-prt as logical no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods    for ub.goods.
define buffer buf_gds-prt  for ub.gds-prt.
define buffer buf_clients  for ub.clients.

assign
inp-b-code = integer(entry(1, p-parameter, {&delim-par}))
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
no-error
.
if error-status:error then return error substitute("Неверно задан входной параметр").

FIND buf_bar-code WHERE buf_bar-code.b-code = inp-b-code NO-LOCK no-error .
if not available buf_bar-code then do:
  undo, return error substitute("Не найден бар-код &1"
                               , inp-b-code).
end.
find first buf_goods no-lock where
          buf_goods.gds-code = buf_bar-code.gds-code no-error.
if not available buf_goods then do:
  undo, return error substitute("Не найден товар для бар-кода &1 (код товара &2)"
                                , inp-b-code
                                , buf_bar-code.gds-code).
end.

{ gbl/prtat.i
  buf_bar-code.node-code
  'terminal-prt=request':u
  l-terminal-prt
  no-error
}
if error-status :error
then do:
  undo, return error substitute("Ошибка при определении терминальности признака")
    .
end.
if not l-terminal-prt then do:
  undo, return error substitute("Запрошен нетерминальный бар-код &1 (код признака &2)"
                                , inp-b-code
                                , buf_bar-code.node-code).

end.

_shop:
FOR EACH buf_clients no-lock where
        buf_Clients.db-num = G#db-num
    and buf_clients.obj-type = {&shop}
   and
   (p-obj-code = 0
   or
   buf_clients.obj-code = p-obj-code):
   run term-prt in this-procedure ( buffer buf_bar-code
                                   ,input buf_clients.obj-type
                                   ,input buf_clients.obj-code
                                   ,input buf_goods.artic
                                   ,input buf_goods.prod-type
                                   ,input buf_goods.prod-code) no-error.
end.


PROCEDURE term-prt.
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .

define variable for-fact-qnty as decimal no-undo .
define variable for-free-qnty as decimal no-undo .

define buffer b-g-p for ub.gds-prt.
define buffer buf_prt-obj for ub.prt-obj.
/*найдем код признака*/


FIND FIRST buf_prt-obj WHERE
        buf_prt-obj.obj-type = {&shop}
    AND buf_prt-obj.obj-code = p-obj-code
    AND buf_prt-obj.prod-type = p-prod-type
    AND buf_prt-obj.prod-code = p-prod-code
    AND buf_prt-obj.artic = p-artic
    AND buf_prt-obj.prt-code = buf_bar-code.node-code NO-LOCK NO-ERROR .
if available buf_prt-obj then do:
  assign
  for-fact-qnty  = buf_prt-obj.fact-qnty
  for-free-qnty  = buf_prt-obj.free-qnty
  .
end.
else do:
  assign
  for-fact-qnty  = 0
  for-free-qnty  = 0
  .
end.
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
if not avail cash-gds then do:
  create cash-gds.
  assign
  cash-gds.crf = cr + 1
  cr = cr + 1
  cash-gds.gds-code = buf_bar-code.gds-code
  cash-gds.b-code = buf_bar-code.b-code
  cash-gds.fact-qnty = for-fact-qnty
  cash-gds.free-qnty = for-free-qnty
  cash-gds.obj-type = p-obj-type
  cash-gds.obj-code = p-obj-code
  .
end.
END PROCEDURE.