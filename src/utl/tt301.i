/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 02/04/09
Author: Svetlana Chernova
Creation date: 02/04/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-price-doc no-undo
field line-num as integer
field doc-date as date
field doc-num  as integer
field doc-num-ES as character
field doc-id   as character
field obj-type as character
field obj-code as integer
field cmnt     as character
index pi line-num doc-num
index pi2 doc-num
index pi3 doc-id
.

define temp-table temp-price-list no-undo
field line-num     as integer
field doc-num      as integer
field bar-code     as integer
field gds-code     as integer
field price-sale   as decimal
index pi  doc-num  line-num  bar-code
index pi2 bar-code
.
/* $Workfile$ e n d */