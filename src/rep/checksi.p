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
*/

{ utl/runpro.i }
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i } 

define variable logFile  as character no-undo.

define buffer buf_clob-bind for ub.clob-bind.
define stream logOutput.

{rep/checksi.i}

message "Отчет сформирован в" search(logFile) "." 
   view-as alert-box.