block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: unloaddc.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/unloaddc.p $":U .
def var vss-description as character no-undo init "Отключение БД участвующих в выгрузке УБД".
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
do
on error  undo, return error error-status :get-message ( error-status :num-messages )
on stop   undo, return error "stop":U
on endkey undo, return error "endkey":U
:
  define variable v-ind as integer no-undo .
  repeat v-ind = 1 to num-dbs:
    if ldbname( v-ind ) <> "ub":U then do:
      disconnect value( ldbname( v-ind ) ) .
    end.
  end.
  repeat v-ind = 1 to num-aliases:
    if alias( v-ind ) = "dst":U
      or alias( v-ind ) = "src":U
      or alias( v-ind ) = "db-orig":U
      or alias( v-ind ) = "db-copy":U
    then do:
      if ldbname( alias( v-ind ) ) = "ub":U then do:
        delete alias value( alias( v-ind ) ) .
      end.
      else do:
        if connected( alias( v-ind ) ) then do:
          disconnect value( alias( v-ind ) ) .
        end.
      end.
    end.
  end.
end.
return.
