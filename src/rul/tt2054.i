/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательные таблицы для импорта накладных из BC DKLink

Автор: Хныкин Павел Андреевич
Дата создания: 11/03/09
Author: Pavel Khnykin
Creation date: 11/03/09

*/


define temp-table temp_doc-header no-undo
  field doc-id        as integer
  field action        as character
  field ext-num       as character
  field type          as integer
  field agent-id      as character
  field from-store-id as character
  field to-store-id   as character
  field user_id       as character
  field pprice        as decimal
  field fprice        as decimal
  field pdate         as datetime-tz
  field start-date    as datetime-tz
  field finish-date   as datetime-tz

index doc_header_pi is primary unique
  doc-id
.

define temp-table temp_doc-line no-undo
  field doc-id    as integer
  field pos       as integer
  field action    as character
  field goods-id  as integer
  field store-id  as character
  field bc        as character
  field sn        as character
  field name      as character
  field pcount    as decimal
  field fcount    as decimal
  field pprice    as decimal
  field fprice    as decimal
  field comment   as character

index doc_line_pi is unique primary
  doc-id
  pos
.

define temp-table temp2_doc-line no-undo
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
index pi
doc-code
line-num
gds-code
.

define dataset thdoc for temp_doc-header, temp_doc-line.

/* $Workfile$ e n d */
