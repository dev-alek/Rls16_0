block-level on error undo, throw.
define input parameter p-dir-name as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dir-cre.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/dir-cre.p $":U .
def var vss-description as character no-undo init "—оздание заданного каталога".
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
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
  define variable v-ind         as integer   no-undo .
  define variable v-ind1        as integer   no-undo .
  define variable v-dir-name    as character no-undo .
  define variable v-dir-name1   as character no-undo .
  define variable v-char        as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-first-num   as integer   no-undo .
  define variable v-err-mess    as character no-undo .
  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0
  then do:
    return string( "каталог" + chr(32) + p-dir-name + chr(32) + "уже существует." ) .
  end.
  assign
    v-dir-name = replace( p-dir-name, chr(47), chr(92) )
  .
  if substring( v-dir-name, 1, 1 ) = chr(92)
     and substring( v-dir-name, 2, 1 ) = chr(92)
  then do:
    assign
      v-first-num = 5
    .
  end.
  else do:
    if substring( v-dir-name, 2, 1 ) = ":":U
       and substring( v-dir-name, 3, 1 ) = chr(92)
    then do:
      assign
        v-first-num = 2
      .
    end.
    else do:
      return error string( "путь к каталогу должен иметь формат" + chr(10)
                            + chr(92) + chr(92) + " ...":U + chr(92) + " ...":U + chr(10)
                            + "или" + chr(32) + "... :\...":U
                          ).
    end.
  end.
  assign
    v-num-entries = num-entries( v-dir-name, chr(92) )
    v-dir-name1 = "":U
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error
  :
    if v-ind < v-first-num then do:
      assign
        v-dir-name1 = v-dir-name1 + entry(v-ind, v-dir-name, chr(92) ) + chr(92)
      .
    end.
    else do:
      assign
        file-info:file-name = v-dir-name1
      .
      if file-info:file-type <> ?
        and index( file-info:file-type, "D":U ) <> 0
      then do:
        assign
            v-dir-name1 = v-dir-name1 + entry(v-ind, v-dir-name, chr(92) ) + chr(92)
        .
        os-create-dir value( v-dir-name1 ) .
        if os-error <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error string( "Ќе могу создать каталог" + chr(32) + v-dir-name1 + chr(10)
                              + v-err-mess + chr(32) + "(":U + string( os-error ) + ")":U
                            ).
        end.
      end.
      else do:
        return error string( "Ќе могу создать каталог в ресурсе" + chr(32) + v-dir-name1 ).
      end.
    end.
  end.
end.
return .
