block-level on error undo, throw.
block-level on error undo, throw.
define input parameter p-infile  as character no-undo.
define input parameter p-pasword as character no-undo.
define input parameter p-encrypt as logical   no-undo.
define input parameter p-outfile as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: 15ea7233baa8, 1928, rls $":U .
define variable vss-author      as character no-undo init "$Author: obrezanova $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 12 15:10:05 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filecryp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/filecryp.p $":U .
define variable vss-description as character no-undo init "шифрование файла".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
DEFINE STREAM st-in.
DEFINE STREAM st-out.
DEFINE VARIABLE v-in-string  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-out-string AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-file-name  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .
DO
ON ERROR UNDO, RETURN ERROR
:
   v-file-name = SEARCH(p-infile).
   IF p-encrypt = ? THEN DO:
      RETURN ERROR "Не опредлено дейcтвие".
   END.
   IF p-infile = p-outfile THEN DO:
      RETURN ERROR "Нельзя выходным файлом указывать входной".
   END.
   INPUT  STREAM st-in  FROM VALUE(v-file-name) .
   OUTPUT STREAM st-out TO   VALUE(p-outfile) .
   SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY(p-pasword).
   REPEAT:
      ASSIGN
         v-out-string = ""
         v-in-string  = ""
      .
      IMPORT STREAM st-in UNFORMATTED
         v-in-string
         .
      if p-encrypt THEN DO:
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
run pencrypt in this-procedure (input  v-in-string
  ,output v-out-string
  )  .
      END.
      ELSE DO:
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
run pdecrypt in this-procedure (input  v-in-string
  ,output v-out-string
  )  .
      END.
      PUT STREAM st-out UNFORMATTED
         v-out-string SKIP
         .
   END.
   INPUT  STREAM st-in  CLOSE.
   OUTPUT STREAM st-out CLOSE.
END.
