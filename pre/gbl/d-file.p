block-level on error undo, throw.
define input-output parameter p-file-id           as character no-undo .
define input-output parameter p-file-directory    as character no-undo .
define input        parameter p-filter-names      as character no-undo .
define input        parameter p-filter-values     as character no-undo .
define input        parameter p-filter-delimiter  as character no-undo .
define input        parameter p-default-extension as character no-undo .
define input        parameter p-must-exist        as logical   no-undo .
define input        parameter p-save-as           as logical   no-undo .
define input        parameter p-use-filename      as logical   no-undo .
define input        parameter p-title             as character no-undo .
define output       parameter p-choose            as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: d-file.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/d-file.p $":U .
define variable vss-description as character no-undo init "Äטאכמד גûבמנא פאיכא גגמהא ט גûגמהא   ".
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
define variable v-filter-name as character no-undo extent 10 .
define variable v-filter-value as character no-undo extent 10 .
DEFINE VARIABLE ii as integer no-undo .
do ii = 1 to num-entries(p-filter-names, p-filter-delimiter):
  assign
  v-filter-name[ii] = entry(ii, p-filter-names, p-filter-delimiter)
  v-filter-value[ii] = entry(ii, p-filter-values, p-filter-delimiter)
  no-error.
end.
if p-must-exist then do:
  if p-save-as then do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      SAVE-AS
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      SAVE-AS
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
  else do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
end.
else do:
  if p-save-as then do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      SAVE-AS
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      SAVE-AS
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
  else do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      filters v-filter-name[1] v-filter-value[1] ,                   v-filter-name[2] v-filter-value[2] ,                   v-filter-name[3] v-filter-value[3] ,                   v-filter-name[4] v-filter-value[4] ,                   v-filter-name[5] v-filter-value[5] ,                   v-filter-name[6] v-filter-value[6] ,                   v-filter-name[7] v-filter-value[7] ,                   v-filter-name[8] v-filter-value[8] ,                   v-filter-name[9] v-filter-value[9] ,                   v-filter-name[10] v-filter-value[10]
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
end.
if not p-choose then do:
  assign
    p-file-id = ''
  .
end.
