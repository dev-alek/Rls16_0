block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h_ttable.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/h_ttable.p $":U .
define variable vss-description as character no-undo init "Скачивание из файла-исходника в переменные".
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
define input parameter   p-file-name as character no-undo .
define output parameter  fill-name   as character no-undo .
define output parameter  workfile_   as character no-undo .
define output parameter  author      as character no-undo .
define output parameter  description as character no-undo .
define output parameter app_help as logical no-undo .
define stream in-stream .
define variable v-temp-char as character no-undo .
define variable i as integer no-undo init 0 .
define variable pp as integer no-undo init 0 .
fill-name = p-file-name.
input stream in-stream from value( p-file-name ) .
repeat :
  import stream In-Stream unformatted v-temp-char no-error .
  i = i + 1.
  v-temp-char = trim (v-temp-char) .
  if v-temp-char begins '$' + "Author" then do:
    author = entry( 2, v-temp-char, " " ) .
  end.
  if v-temp-char begins '$' + "Workfile" then do:
    workfile_ = entry( 2, v-temp-char, " " ) .
  end.
  if v-temp-char begins '$' + "Archive:" then do:
     pp = i .
  end.
  if i  >= pp + 1 and
     i  < pp + 3  and
     pp <> 0           then do:
     if v-temp-char <> ? and v-temp-char <> "" then   description = description + " " + v-temp-char.
  end.
  app_help = false .
  if index (lc(v-temp-char) , "gbl/app_help.i" ) > 0 then
      do:
        app_help = true .
        leave.
     end.
end.
input stream in-stream close.
