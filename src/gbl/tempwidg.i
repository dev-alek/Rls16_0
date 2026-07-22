/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/10/08
Author: Bakhtadze Natalya
Creation date: 07/10/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-tempwidg-index as integer no-undo .

DEFINE TEMP-TABLE temp-widget
FIELD NAME_ AS CHARACTER
FIELD LENGTH_ AS DECIMAL
FIELD index_ AS INTEGER
FIELD HANDLE_ AS HANDLE
FIELD format_ AS CHARACTER
FIELD width_ AS DECIMAL
field section_ as character
field visible_ as integer
field column_ as decimal
field row_ as decimal
field data-type_ as character
field character_ as character
field date_ as date
field decimal_ as decimal
field integer_ as decimal
field logical_ as logical
INDEX pi IS UNIQUE PRIMARY
NAME_
INDEX iindex
INDEX_
index isection
section_
.


procedure tempwidg_create-record :
define input parameter p-handle as widget-handle no-undo .

define buffer buf_temp-widget for temp-widget.

do
on error undo, return error
:
  find first buf_temp-widget where
            buf_temp-widget.name = p-handle:name no-error.
  if not available buf_temp-widget then do:
    create buf_temp-widget.
    assign
    buf_temp-widget.name = p-handle:name
    buf_temp-widget.index_ = v-tempwidg-index + 1
    buf_temp-widget.handle_ = p-handle
    v-tempwidg-index = v-tempwidg-index + 1
    .
  end.
end.

end procedure. /* tempwidg */

procedure tempwidg_write-character :
define input parameter p-name as character no-undo .
define input parameter p-character as character no-undo .
define buffer buf_temp-widget for temp-widget.

do
on error undo, return error
:
  find first buf_temp-widget where
            buf_temp-widget.name = p-name no-error.
  if available buf_temp-widget then do:
    assign
    buf_temp-widget.character_ = p-character
    buf_temp-widget.data-type_ = {&abl-datatype-character}
    .
  end.
end.
end procedure.

procedure tempwidg_write-logical :
define input parameter p-name as character no-undo .
define input parameter p-logical as logical no-undo .
define buffer buf_temp-widget for temp-widget.

do
on error undo, return error
:
  find first buf_temp-widget where
            buf_temp-widget.name = p-name no-error.
  if available buf_temp-widget then do:
    assign
    buf_temp-widget.logical_ = p-logical
    buf_temp-widget.data-type_ = {&abl-datatype-logical}
    .
  end.
end.
end procedure.



/* $Workfile$ e n d */