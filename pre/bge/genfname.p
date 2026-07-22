block-level on error undo, throw.
define input parameter p-full-path      as character    no-undo.
define input parameter p-prefix         as character    no-undo.
define input parameter p-user-chars     as character    no-undo.
define input parameter p-extension      as character    no-undo.
define input parameter p-temp-extension as character    no-undo.
define output parameter p-name          as character   no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: genfname.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/genfname.p $":U .
define variable vss-description as character no-undo init "Процедура определения имени для нового файла.".
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
do
on error undo, return error return-value
:
    define variable v-base        as integer   no-undo .
    define variable v-check-name  as character no-undo .
    define variable v-locked      as logical   no-undo.
    define variable v-temp-name   as character      no-undo.
    assign
        file-info :file-name = p-full-path
    .
    if file-info :full-pathname = ?
    then do:
        undo, return error .
    end.
    if index(file-info :file-type, "D") = 0
    then do:
        undo, return error .
    end.
    assign
        p-full-path = file-info :full-pathname
    .
    if p-extension <> ""
    and substring(p-extension, 1, 1) <> '.':u
    then do:
        assign
            p-extension = '.':u + p-extension
        .
    end.
    if p-temp-extension <> ""
    and substring( p-temp-extension, 1, 1 ) <> '.':u
    then do:
        assign
            p-temp-extension = '.':u + p-temp-extension
        .
    end.
    assign
        v-check-name = "something"
        v-locked     = yes
    .
    do
    while v-check-name <> ?
    :
        assign
            v-base = ( time * 1000 + etime ) modulo 100000
        .
        assign
            p-name      = p-full-path
                            + chr(47)
                            + p-prefix
                            + string( v-base,"99999":U )
                            + p-user-chars
                            + p-extension
            v-check-name = search( p-name )
        .
        if v-check-name = ?
        and p-temp-extension <> ""
        then do:
            assign
                v-temp-name  = p-full-path
                                + chr(47)
                                + p-prefix
                                + string( v-base,"99999":U )
                                + p-user-chars
                                + p-temp-extension
                v-check-name = search( v-temp-name )
            .
        end.
    end.
end.
