block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Процедура запуска выбора из справочника "Сезоны ДТ"

Автор: Ростовцев Александр
Дата создания: 18/09/23
Author: Rostovtsev Aleksandr
Creation date: 18/09/23

*/

define input  parameter iParentProc as widget-handle no-undo .
define input  parameter iGdsCode    as integer       no-undo .
define output parameter oId         as recid         no-undo init ? .

{ gbl/tmprecid.i "new shared"}

define variable vFilter as character no-undo.
define variable vTitle  as character no-undo.
define variable vOk as logical no-undo .

find first ub.Code no-lock where ub.Code.parent = "DTSeasons" and ub.Code.CodeValue <> ? no-error .
if available (ub.Code) then vOk = true .
assign
  vFilter = if iGdsCode = 0 or iGdsCode = ? or not vOk then ""
            else ("and code.codeValue = " + quoter(iGdsCode))
  vTitle = if vFilter = "" then "Сезоны ДТ" else substitute("&1&3&2", "Сезоны ДТ", vFilter, {&delim-par})
.

run ref/codelay.p
  (input  iParentProc
  ,input  {&select}
  ,input  ""
  ,input  "DTSeasons"
  ,input  vTitle
  ) .
run rid-rest.
find tmprecid no-error.
if available tmprecid then 
do:
  oId = tmprecid.frecid.
end.
else 
do:
  find first tmprecid no-error.
  if available tmprecid then
  do:
    return error "Можно выбрать только одну запись ~"Сезона ДТ~".".
  end.
end.
