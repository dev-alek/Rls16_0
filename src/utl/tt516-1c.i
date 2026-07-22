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
field reason-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field vat-type as character
field price-type as character
field cargo-from as character
field stts as character
field hold-obj-type as character
field hold-obj-code as integer
field ship-num as character
field ship-date as date
field doc-id as character
field out-code as character

index pi line-num doc-code .

define temp-table temp_doc-line no-undo
  field line-num      as integer
  field doc-code      as character
  field gds-code      as integer
  field artic         as character     /* не присылают */
  field prod-type     as character     /* не присылают */
  field prod-code     as integer       /* не присылают */
  field cli-qnty      as decimal
  field doc-qnty      as decimal
  field fact-qnty     as decimal
  field doc-density   as decimal
  field fact-density  as decimal
  field price-rubl    as decimal
  field price-cli     as decimal
  field vat-pc        as decimal
  field cons-vat-pc   as decimal
  field refA          as character
  field refB          as character
  field alc-code      as character
  field alc-type-code as character
  field vsd-uuid      as character
  field part-id       as character
  field importer-th   as character
  field line-num-str  as character /* пор€док чтени€ из xml */ /* не присылают */
index pi
doc-code
line-num
gds-code
index qntyIndex
doc-code
gds-code
alc-code
doc-qnty
.

define temp-table temp_doc-mark no-undo
  field gtin          as character
  field gtin_qnt      as integer
  field upd_id        as character
  field part-id       as character
  field mark          as character
  field gds-code      as integer
  index pi mark.