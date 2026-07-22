/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вспомогательные таблицы для импорта инвентаризаций  из BC

Автор: Чернова Светлана Александровна
Дата создания: 02/10/09
Author: Svetlana Chernova
Creation date: 02/10/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp_trn-doc no-undo
field line-num as integer
field doc-code as character
field doc-date as date
field ext-doc-type as character
field cli-type as character        /* не присылают */
field cli-code as integer
field obj-type as character
field obj-code as integer
field wrkr as integer             /* не присылают */
field agnt as integer             /* не присылают */
field boss as integer             /* не присылают */
field creid as character          /* не присылают */
field ps as character
field host-code as integer        /* не присылают */
field contract-code as integer
index pi line-num doc-code .

define temp-table temp_gds-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field line-qnty   as integer
index pi
doc-code
line-num
gds-code
.

define temp-table temp_mark-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field excisemark  as character
field rowid-part  as rowid
index pi
doc-code
line-num
gds-code
.

define temp-table temp_grp-line no-undo
field line-num    as integer
field doc-code    as character
field depart-code   as integer
field class-code    as integer
field subclass-code as integer
index pi
doc-code
line-num
depart-code
class-code
subclass-code
.