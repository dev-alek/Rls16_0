block-level on error undo, throw.
using Ibs.Th.Rul.Route-data_.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-log.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/lib-log.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы log":U .
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
define new global shared variable g#lib-log as handle no-undo .
if valid-handle (g#lib-log)
and g#lib-log <> this-procedure :handle
and g#lib-log :get-signature('lib-log_clear-fill-option':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с GATE" skip
    g#lib-log skip
    g#lib-log :type skip
    g#lib-log :file-name skip
    valid-handle(g#lib-log) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-log = this-procedure :handle
  .
end.
define variable v-log-handle as handle no-undo .
v-log-handle = this-procedure:handle.
procedure lib-log_set-log-handle :
define input parameter p-log-handle as handle no-undo .
if valid-handle(p-log-handle)
and lookup("write-to-log", p-log-handle:internal-entries) > 0
then do:
 v-log-handle = p-log-handle.
end.
else do:
  v-log-handle = this-procedure:handle.
end.
end procedure.
procedure lib-log_get-log-handle :
define output parameter p-log-handle as handle no-undo .
if valid-handle(v-log-handle)
and lookup("write-to-log", v-log-handle:internal-entries) > 0
then do:
  p-log-handle = v-log-handle.
end.
else do:
  v-log-handle = this-procedure:handle.
  p-log-handle = v-log-handle.
end.
end procedure.
procedure write-to-log :
define input parameter p-mess as character no-undo .
end procedure.
procedure write-log-and-file :
define input parameter p-tabs as integer no-undo .
define input parameter p-log-file as character no-undo .
define input parameter p-int2 as integer no-undo .
define input parameter p-mess as character no-undo .
end procedure.
PROCEDURE get-title :
define output parameter p-title     as character    no-undo.
END PROCEDURE.
PROCEDURE set-title :
define input parameter p-title     as character    no-undo.
END PROCEDURE.
PROCEDURE get-counter-value :
define output parameter p-counter     as integer    no-undo.
END PROCEDURE.
PROCEDURE set-counter-value :
define input parameter p-counter     as integer    no-undo.
END PROCEDURE.
PROCEDURE show-counter :
END PROCEDURE.
PROCEDURE hide-counter :
END PROCEDURE.
PROCEDURE write-counter :
define input parameter p-counter-string     as character    no-undo.
END PROCEDURE.
PROCEDURE get-stop-state :
define output parameter p-stop-state    as logical      no-undo.
END PROCEDURE.
PROCEDURE set-view-log :
define input parameter p-view-log     as logical    no-undo.
END PROCEDURE.
PROCEDURE get-view-log :
define output parameter p-view-log     as logical    no-undo.
END PROCEDURE.
PROCEDURE write-log :
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.
END PROCEDURE.
procedure writelog :
define input parameter p-file-name AS CHAR     NO-UNDO.
define input parameter p-log-level AS INTEGER  NO-UNDO.
define input parameter p-log-string  AS CHAR     NO-UNDO.
end procedure.
PROCEDURE auto2dia-writefile:
define input parameter sFileName AS CHAR     NO-UNDO.
define input parameter iLogLevel AS INTEGER  NO-UNDO.
define input parameter sToWrite  AS CHAR     NO-UNDO.
END PROCEDURE.
