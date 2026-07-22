block-level on error undo, throw.
define input  parameter iParentProc as widget-handle no-undo .
define input  parameter iGdsCode    as integer       no-undo .
define output parameter oId         as recid         no-undo init ? .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
 define new shared temp-table tmprecid
    field Frecid as recid init ?
    field fnum as character
    field fTable as character
 index num  fnum Frecid
 index itable is primary unique fTable Frecid
 .
define variable fSelect as logical no-undo format "*/" column-label "".
function isSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
    return available tmprecid.
 end.
function setSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then do:
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
       if available tmprecid
       then
          delete tmprecid.
       else do:
          create tmprecid.
          assign
             tmprecid.fTable = iBuffer:TABLE
             tmprecid.Frecid = iBuffer:recid
          .
       end.
    end.
    return available tmprecid.
 end.
 procedure rid-keep :
     run gbl/rid-keep.p (input table tmprecid) no-error.
 end.
 procedure rid-rest :
      run gbl/rid-rest.p (output table tmprecid) no-error.
 end.
define variable vFilter as character no-undo.
define variable vTitle  as character no-undo.
define variable vOk as logical no-undo .
find first ub.Code no-lock where ub.Code.parent = "DTSeasons" and ub.Code.CodeValue <> ? no-error .
if available (ub.Code) then vOk = true .
assign
  vFilter = if iGdsCode = 0 or iGdsCode = ? or not vOk then ""
            else ("and code.codeValue = " + quoter(iGdsCode))
  vTitle = if vFilter = "" then "Сезоны ДТ" else substitute("&1&3&2", "Сезоны ДТ", vFilter, chr(4))
.
run ref/codelay.p
  (input  iParentProc
  ,input  'ВЫБОР':U
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
