/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание атрибутов

Автор: Чернова Светлана Александровна
Дата создания: 08/29/08
Author: Svetlana Chernova
Creation date: 08/29/08

Create: Перваков Михаил Сергеевич


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer

  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .

define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer

  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .

/* $Workfile$ e n d */