block-level on error undo, throw.
define input  parameter p-url      as character no-undo .
define output parameter p-chr-uuid as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7045fcb5a0f6, 1396, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jun 28 15:24:33 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: qr2uuid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/qr2uuid.p $":U .
define variable vss-description as character no-undo init "Процедура определения UUID ВСД из QR-кода, напечатанного на ВСД".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
function qrCode2Uuid returns character (input p-url as character) :
define variable v-chr-uuid as character no-undo .
define variable v-ind1     as integer no-undo .
define variable v-ind2     as integer no-undo .
define variable v-str1     as character no-undo .
  assign
    v-ind1 = index(p-url, "&uuid=")
    v-ind2 = index(p-url, "?uuid=")
  .
  if (v-ind1 > 0) or (v-ind2 > 0) then do:
    v-str1 = substring(p-url, maximum(v-ind1, v-ind2) + 6) .
    v-ind1 = index(v-str1, "&") .
    v-chr-uuid = if v-ind1 > 0 then substring(v-str1, 1, v-ind1 - 1) else v-str1 .
  end .
  else v-chr-uuid = "" .
  return v-chr-uuid .
end function .
p-chr-uuid = qrCode2Uuid (p-url) .
