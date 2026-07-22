block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-alldocs-handle     as handle           no-undo.
define input parameter v-trn-doc-recid      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 51d0b788d6e0, 3546, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:17 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/doc-prn.p $":U .
define variable vss-description as character no-undo init "Печать складского документа.".
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
    define temp-table temp_trn-doc-code no-undo
        field doc-code as character
        index pi is primary unique doc-code
    .
    define variable lok as logical no-undo .
define buffer buf_trn-doc               for trn-doc.
define buffer buf_temp_trn-doc-code     for temp_trn-doc-code.
define variable i as integer   no-undo .
define variable v-kol as integer   no-undo .
do
on error undo, return error
:
assign
  i = 0
  v-kol = num-entries (v-trn-doc-recid) .
.
    repeat i = 1 to v-kol :
      find first  buf_trn-doc no-lock
          where recid( buf_trn-doc ) = int64(entry(i,v-trn-doc-recid)) no-error
      .
      if available  buf_trn-doc then do:
      create buf_temp_trn-doc-code .
      assign
          buf_temp_trn-doc-code.doc-code = buf_trn-doc.doc-code
      .
      end.
    end.
    run rep/d-docm.w (
          input p-mainmenu-handle
        , input p-alldocs-handle
        , input table buf_temp_trn-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
            skip "Ошибка печати документа."
            skip (1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.
