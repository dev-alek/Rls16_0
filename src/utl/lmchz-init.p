block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация модуля ЛМ ЧЗ

Автор: Белова Марина Михайловна
Дата создания: 17/02/25
Author: Marina Belova
Creation date: 17/02/25

*/
using ibs.th.skt.ControlledClients.GisMtOffline.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-param-run as char no-undo.
 /* (string(buf_ext-file.db-num) + {&delim-par} +
         string(buf_ext-file.from-db-num) + {&delim-par} +
         string(buf_Ext-file.file-num)*/                                                                                       
                                             
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание автоматического задания".
{ cmp/vssrevis.i }
{ utl/search.i  class }

define variable thGisMtOff as class GisMtOffline no-undo .      

thGisMtOff =  new GisMtOffline() no-error.
thGisMtOff:ProcInit() no-error.
if error-status:error then
run write-to-log in p-log-handle (
     substitute("Ошибка запуска инициализации ЛМЧЗ. Утилита &1"
                 , program-name(1)
                 )). 
else 
run write-to-log in p-log-handle (
     substitute("Запущена инициализация ЛМЧЗ. Утилита &1"
                 , program-name(1)
                 )).
                 
delete object thGisMtOff no-error.

 
