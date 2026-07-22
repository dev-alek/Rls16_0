block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: ob-sumtp.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/ob-sumtp.p $":U .
def var vss-description as character no-undo init "    ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define temp-table temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int.
define output PARAMETER TABLE FOR temp#sum-type .
create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ie':U temp#sum-type.xi = 1 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ee':U temp#sum-type.xi = 2 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ep':U temp#sum-type.xi = 3 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'es':U temp#sum-type.xi = 4 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 're':U temp#sum-type.xi = 5 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'rs':U temp#sum-type.xi = 6 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'we':U temp#sum-type.xi = 7 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'vt':U temp#sum-type.xi = 8 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'iv':U temp#sum-type.xi = 9 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ev':U temp#sum-type.xi = 10. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'rv':U temp#sum-type.xi = 11. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'em':U temp#sum-type.xi = 12. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'wm':U temp#sum-type.xi = 12. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'im':U temp#sum-type.xi = 13. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ot':U temp#sum-type.xi = 14.
create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ap':U temp#sum-type.xi = 15 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'pc':U temp#sum-type.xi = 16 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ie':U temp#sum-type.xi = 101 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ee':U temp#sum-type.xi = 102 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ep':U temp#sum-type.xi = 103 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'es':U temp#sum-type.xi = 104 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 're':U temp#sum-type.xi = 105 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'rs':U temp#sum-type.xi = 106 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'we':U temp#sum-type.xi = 107 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'vt':U temp#sum-type.xi = 108 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'iv':U temp#sum-type.xi = 109 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ev':U temp#sum-type.xi = 110. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'rv':U temp#sum-type.xi = 111. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'em':U temp#sum-type.xi = 112. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'wm':U temp#sum-type.xi = 112. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'im':U temp#sum-type.xi = 113. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ot':U temp#sum-type.xi = 114.
create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ap':U temp#sum-type.xi = 115 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'pc':U temp#sum-type.xi = 116 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ie':U temp#sum-type.xi = 201 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ee':U temp#sum-type.xi = 202 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ep':U temp#sum-type.xi = 203 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'es':U temp#sum-type.xi = 204 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 're':U temp#sum-type.xi = 205 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'rs':U temp#sum-type.xi = 206 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'we':U temp#sum-type.xi = 207 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'vt':U temp#sum-type.xi = 208 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'iv':U temp#sum-type.xi = 209 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ev':U temp#sum-type.xi = 210. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'rv':U temp#sum-type.xi = 211. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'em':U temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'wm':U temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'im':U temp#sum-type.xi = 213. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ot':U temp#sum-type.xi = 214.
create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ap':U temp#sum-type.xi = 215 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'pc':U temp#sum-type.xi = 216 .
return .
