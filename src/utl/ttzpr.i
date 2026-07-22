/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вспомогательные таблицы дл€ импорта накладных из BC

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 02/10/09
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
field contract-code as integer    /* не присылают */
field pay-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field vat-type as character

index pi line-num doc-code .

define temp-table temp_doc-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field artic       as character     /* не присылают */
field prod-type   as character     /* не присылают */
field prod-code   as integer       /* не присылают */
field fact-qnty   as decimal
field price-rubl  as decimal
field price-cli   as decimal
field vat-pc      as decimal
field cons-vat-pc as decimal
field line-num-str as integer /* пор€док чтени€ из xml */ /* не присылают */
index pi
doc-code
line-num
gds-code
.