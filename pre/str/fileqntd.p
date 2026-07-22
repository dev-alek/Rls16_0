block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: fileqntd.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/fileqntd.p $":U .
def var vss-description as character no-undo init "Подсчет количества файлов с учетом поддиректорий".
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
define input parameter  DirPath as character no-undo.
define input parameter shablon as character no-undo .
define output parameter fileqnty as integer no-undo .
define output parameter BadRetFlag as log no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE VARIABLE file as character no-undo .
DEFINE VARIABLE path as character no-undo .
DEFINE VARIABLE atr as character no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-flag as logical no-undo .
input from os-dir ( DirPath ) .
REPEAT :
    import file path atr.
    if can-do( "f", atr ) then do:
        assign
        fileqnty = fileqnty + 1
        .
    end.
    if can-do( "d", atr) and (file = ".":U or file = "..") then do:
      if shablon = "*":U then do:
      end.
      else do:
        do ii = 1 to num-entries(shablon):
          if file begins entry(ii, shablon) then do:
            run str/fileqntd.p (path, shablon, output jj, output v-flag).
            assign
            fileqnty = fileqnty + jj
            .
          end.
        end.
      end.
    end.
END .
input close.
if fileqnty > 500 then
    BadRetFlag = TRUE.
else
    BadRetFlag = FALSE .
