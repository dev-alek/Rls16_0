block-level on error undo, throw.
define input  parameter i-Text  as longchar no-undo.
define input  parameter i-pasword as character no-undo.
define input  parameter i-encrypt as logical   no-undo.
define output parameter o-Text as longchar no-undo.
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filecrypchar.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/filecrypchar.p $":U .
define variable vss-description as character no-undo init "шифрование текста".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure pencrypt :
       define input parameter ip-value-to-enc as character no-undo.
       define output parameter op-char-value  as character no-undo.
  define variable crypto-value           as raw       no-undo.
  do
  on error undo, return error return-value
  :
   assign
      crypto-value  = encrypt(ip-value-to-enc)
      op-char-value = base64-encode(crypto-value)
   no-error.
   if error-status:error then op-char-value = ? .
   end.
end procedure.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure pdecrypt :
     define input  parameter ip-value-to-dec as character no-undo.
     define output parameter op-char-value   as character no-undo.
  define variable decrypt-value          as raw       no-undo.
  define variable long-char-value        as longchar  no-undo.
  do
  on error undo, return error return-value
  :
   assign
      long-char-value = ip-value-to-dec
      op-char-value   = get-string(decrypt(base64-decode(long-char-value)),1)
      long-char-value = ""
   no-error.
   if error-status:error then op-char-value = ? .
   end.
end procedure.
do
on error undo, return error
:
   if i-encrypt = ? then do:
      return error "Не опредлено дейcтвие".
   end.
   security-policy:symmetric-encryption-key = generate-pbe-key(i-pasword).
   if i-encrypt
   then do:
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
run pencrypt in this-procedure (input  i-Text
  ,output o-Text
  )  .
   end.
   else do:
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
run pdecrypt in this-procedure (input  i-Text
  ,output o-Text
  )  .
   end.
end.
