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

define temp-table tt-widget  no-undo like ub.custom-labels
field wh as widget-handle
field whl as widget-handle
.

PROCEDURE gdsfrmfi-to:
DEFINE INPUT PARAMETER v-gdsfrmfi as char no-undo.
DEFINE INPUT PARAMETER loc-mode as logical no-undo.
DEFINE OUTPUT PARAMETER v-dop-inf as char no-undo.
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE VARiable jj as integer no-undo init 1.
/*расположение зависит от статических виджетов*/
define variable startrow as decimal no-undo init 19.5.
define variable startcolumn as decimal no-undo init 5.
define variable col-size as decimal no-undo init 50.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf_widget for tt-widget.
IF v-gdsfrmfi = "" then do:
  return.
end.
create widget-pool "gdsfrmfi" persistent no-error.
wph = yes.
if error-status:error then return.
for each buf_widget:
  delete buf_widget.
end.
DO ii = 1 to NUm-ENTRIES(v-gdsfrmfi):
  find first buf_custom-labels no-lock where
          buf_custom-labels.language = "{&language}"
      and buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-gdsfrmfi}
      and buf_custom-labels.tbl-name = entry(1, entry(ii, v-gdsfrmfi), ".")
      and buf_custom-labels.fld-name = entry(2, entry(ii, v-gdsfrmfi), ".") no-error .
  if available buf_custom-labels then do:
    create buf_widget.
    buffer-copy buf_custom-labels to buf_widget
    .
    create TEXT buf_widget.whl in widget-pool "gdsfrmfi"
    assign
    frame = frame {&frame-name}:handle
    DATA-TYPE = {&abl-datatype-character}
    FORMAT = substitute("X(&1)", length(buf_widget.custom-label))
    screen-value = buf_widget.custom-label
    row = startrow + round(jj / 2, 0)
    column = startcolumn + (if jj mod 2 = 0 then col-size else 1)
    height-chars = 1
    visible = true
    .
    view buf_widget.whl.
    case buf_widget.widget-type:
       when  "fill-in" then do:
          create fill-in buf_widget.wh in widget-pool "gdsfrmfi"
          assign
          frame = frame {&frame-name}:handle
          side-label-handle = buf_widget.whl
          DATA-TYPE = buf_widget.fld-data-type
          FORMAT = buf_widget.CUSTOM-FORMAT
          row = startrow + ROUND(jj / 2, 0)
          column = buf_widget.whl:column + buf_widget.whl:width-chars + 1
          height-chars = 1
          width-chars = minimum(buf_widget.widget-width, ((frame {&frame-name}:width-chars )) - (buf_widget.whl:column + buf_widget.whl:width-chars + 1))
          sensitive = loc-mode
          visible = true
          tooltip = buf_widget.custom-tooltip
          .
       end.
       when "combo-box" then do:
          create combo-box buf_widget.wh in widget-pool "gdsfrmfi"
          assign
          frame = frame {&frame-name}:handle
          side-label-handle = buf_widget.whl
          DATA-TYPE = buf_widget.fld-data-type
          FORMAT = buf_widget.CUSTOM-FORMAT
          row = startrow + ROUND(jj / 2, 0)
          column = buf_widget.whl:column + buf_widget.whl:width-chars + 1
          delimiter = {&new-line}
          list-items = buf_widget.widget-list-items
          inner-lines = num-entries(buf_widget.widget-list-items, {&new-line})
          subtype = "DROP-DOWN-LIST"
          width-chars = minimum(buf_widget.widget-width, ((frame {&frame-name}:width-chars )) - (buf_widget.whl:column + buf_widget.whl:width-chars + 1))
          sensitive = loc-mode
          visible = true
          tooltip = buf_widget.custom-tooltip
          .

       end.
    end case.
    jj = jj + 1.
    release buf_widget.
    if jj = 5 then LEAVE.
  end.
END.
END PROCEDURE.

PROCEDURE gdsfrmfi-description:
define variable v-ok as logical no-undo .
run ref/cstmlabs.w ( input parparentproc
                     ,input {&add-fields}
                     ,input {&uf-gdsfrmfi}
                     ,input no
                     ,input 4
                     ,output v-ok
                     ) no-error.
if v-ok then do:
  message
  "Изменения вступят в силу при следующем входе в карточку товара"
  view-as alert-box warning.
end.

END PROCEDURE.

/* $Workfile$ e n d */