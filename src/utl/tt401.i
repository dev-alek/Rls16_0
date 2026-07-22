/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вспомагательные таблицы дл€ закачки в 401.xsd

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 02/05/09
Author: Svetlana Chernova
Creation date: 02/05/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp_ord-doc no-undo
field line-num as integer
field doc-code as character
field doc-date as date
field ext-doc-type as character  /* не передают */
field cli-type as character      /* не передают */
field cli-code as integer
field obj-type as character
field obj-code as integer
field wrkr  as integer          /* не передают */
field agnt  as integer          /* не передают */
field boss  as integer          /* не передают */
field creid as character        /* не передают */
field ps    as character
field host-code     as integer  /* не передают */
field contract-code as integer
field pay-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field corr-doc-code as character
field status_       as character
field ship-date as date

index pi
line-num
doc-code
.

define temp-table temp_ord-line no-undo
field line-num as integer
field doc-code    as character
field artic       as character        /* не передают */
field prod-type   as character        /* не передают */
field prod-code   as integer          /* не передают */
field gds-code    as integer
field fact-qnty   as decimal
field price-rubl  as decimal
field price-cli   as decimal
field vat-pc      as decimal
index pi
doc-code
line-num
gds-code
.

/* $Workfile$ e n d */