/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Переменные для логирование производства (резервирование)

Автор: Морозов Александр Сергеевич
Дата создания: 07/01/14
Author: Morozov Alexandr
Creation date: 07/01/14

*/


&if defined(fbr-rsrv-log-file-name) = 0 &then
  &glob fbr-rsrv-log-file-name 'fbr-rsrv-errors.txt'
&endif

&if defined(fbr-rsrv-tt-log-file-name) = 0 &then
  &glob fbr-rsrv-tt-log-file-name 'fbr-rsrv-errors-tt.txt'
&endif

define variable v-fbr-log-file-name as character no-undo init {&fbr-rsrv-log-file-name}.
define variable v-fbr-tt-log-file-name as character no-undo init {&fbr-rsrv-tt-log-file-name}.
define temp-table tt-rsrv-err no-undo
  field artic like ub.goods.artic
  field gds-name like ub.goods.gds-name
  field rsrv-qnty like ub.gds-obj.fact-qnty
  field req-qnty like ub.gds-obj.fact-qnty 
.
define stream stm.


/*очистить файлы логирования*/
&if "{1}" = "clear" &then
os-delete value({&fbr-rsrv-log-file-name}) no-error.
os-delete value({&fbr-rsrv-tt-log-file-name}) no-error.
&endif