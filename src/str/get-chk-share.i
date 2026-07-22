define {1} shared variable base-cass as int no-undo.
define {1} shared variable right-curs as log no-undo.
define {1} shared variable curr-list as char no-undo.
define {1} shared variable pay-list as character no-undo.
define {1} shared variable nal as integer no-undo.
define {1} shared variable kassa-rub-code      as  integer  no-undo .
define {1} shared variable unq-artc as logical no-undo init no. /*настройка - уникальный цифровой артикул + ДОПБК = артикулу*/
define {1} shared variable val-abbr as character no-undo.
define {1} shared variable val-cass as character no-undo.
define {1} shared variable val-shop as character no-undo.
define {1} shared variable pay-val as character no-undo.
define {1} shared variable pay-cass as character no-undo.
define {1} shared variable pay-shop as character no-undo.
define {1} shared variable nal-rub as integer no-undo.
define {1} shared variable abbr as character no-undo.
define {1} shared variable pay-nal as integer no-undo.
define {1} shared variable cass-card as character no-undo.
define {1} shared variable trade-card as character no-undo.
define {1} shared variable curr-card as character no-undo.
define {1} shared variable not-nal as integer no-undo. /* Безнал опл р_убли , то "rubl" */
define {1} shared variable lll as int no-undo initial 0. /*счетчик принятых чеков*/
define {1} shared variable ibmspool as character no-undo . /*тип спула IBM*/
define {1} shared variable ibmgroup as logical no-undo init yes. /*настройка - читать чеки с продажей по группам - касса IBM*/
define {1} SHARED variable specgrp as character no-undo init '':U. /*настройка - спец суммовые групп касса IBM IBm-XML*/

define {1} shared variable varscales-pref as character no-undo .
define {1} shared variable varpgscales-pref as character no-undo .

&if "{1}" = "new" &then
{ str/sclspref.i varscales-pref varpgscales-pref }
&endif

define {1} SHARED temp-table chk_doc no-undo
field doc-code as char
field chk-date as date
field chk-time as int
field chk-num as int
field g-lines as int
field p-lines as int
.
