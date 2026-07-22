block-level on error undo, throw.
/*

$Revision: d7c9134a48bd, 4585, rls $
$Author: Aleksandr Rostovtsev $
$Date: 21.02.2024 $
$Workfile: checksi1056.p $
$Archive: upd/checksi1056.p $

Проверка установленных значений в справочнике СИ на соответствие предельно допустимым значениям
при переходе на «Интеграция с библиотекой ПОкМИ 1.0.5.6»

Автор: Ростовцев Александр
Дата создания: 21.02.2024
Author: Aleksandr Rostovtsev
Creation date: 21.02.2024

Input:

Output:

*/

define input  parameter ipar as character no-undo.
define output parameter oOk as logical no-undo.

define variable vss-revision    as character no-undo init "$Revision: d7c9134a48bd, 4585, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/11/15 11:20:19 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shiftfactordercheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: upd/shiftfactordercheck.p $":U .
define variable vss-description as character no-undo init "Выставление корректного факт ордера".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable logFile  as character no-undo.

define buffer buf_clob-bind for ub.clob-bind.
define stream logOutput.

find first _file where 
           _file._file-name = "pl-level-mm" 
     no-lock no-error. 
if not avail _file then do:
  oOk = false.
  return.
end. 

find first sys-ctrl no-lock no-error.
if     available sys-ctrl
   and sys-ctrl.db-num = 0 then do:
    {rep/checksi.i}
end.

oOk = true.

