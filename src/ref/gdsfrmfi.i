/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение информации о товаре

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Используется в программах просмотра товара на экране, в карточке товара

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE get-fields:
define buffer buf_widget for tt-widget.
for each buf_widget:
  if buf_widget.tbl-name = {&table_goods} then do:
    buf_widget.wh:screen-value = string(buffer temp-goods:buffer-field(buf_widget.fld-name):buffer-value, buf_widget.custom-format).
  end.
end.
END PROCEDURE.

PROCEDURE set-fields:
define buffer buf_widget for tt-widget.
for each buf_widget:
  if buf_widget.tbl-name = {&table_goods} then do:
    buffer temp-goods:buffer-field(buf_widget.fld-name):buffer-value = buf_widget.wh:input-value.
  end.
end.
END PROCEDURE.

/* $Workfile$ e n d */