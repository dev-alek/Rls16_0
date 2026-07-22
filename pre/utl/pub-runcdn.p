block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
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
def buffer buf_code for ub.code.
define input param iTypeUpd as integer no-undo.
pub-run:
do
on error undo, retry pub-run:
find first buf_code where
           buf_code.parent = "CDN_GisMt"
       and buf_code.code = "CDN_Upd"
        exclusive-lock no-wait no-error.
 if not avail buf_code then do:
        if locked(buf_code) then return.
        else do:
   create buf_code.
   assign
      buf_code.parent = "CDN_GisMt"
      buf_code.code = "CDN_Upd"
      buf_code.codename = "Запущен процесс обновления площадок ГИС МТ"
      buf_code.codeval = string(now)
      .
           validate buf_code no-error.
           if error-status:error then do:
               return .
           end.
        end.
        find current buf_code no-lock no-error.
        publish "runCdn" (iTypeUpd).
end.
else if datetime-tz(buf_code.codeval) < (now - 20 * 60000)
then do:
        buf_code.codeval = string(now).
        validate buf_code no-error.
        if error-status:error then do:
           return .
        end.
        find current buf_code no-lock no-error.
        publish "runCdn" (iTypeUpd).
    end.
    else find current buf_code no-lock no-error.
end.
if retry then do:
    return .
end.
