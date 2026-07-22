block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-lock no-undo
  field lock-conn-id   as integer   label "Номер Подключения"
  field user-name      as character label "Пользователь"
  field lock-flag      as character label "Флаг"
  field trans-id       as integer   label "Транзакция"
  field trans-txtime   as character
  field trans-state    as character
  field trans-dur      as integer
  field connect-type   as character label "Подключение"
  field connect-time   as character format "x(20)"
  field connect-device as character format "x(40)" label "Устройство"
  .
define input  parameter p-recid     as integer   no-undo .
define output parameter table for temp-lock .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findlk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/findlk.p $":U .
define variable vss-description as character no-undo init "Найти информацию обо всех пользователях, захвативших запись".
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
define variable v-ind as integer no-undo .
do
on error undo, return error return-value
:
  for each _userlock no-lock
    where _userlock._userlock-usr <> ?
  :
    do v-ind = 1 to extent(_userlock._userlock-recid)
    :
      if _userlock._userlock-recid[v-ind] = p-recid
      then do:
        create temp-lock .
        assign
          temp-lock.lock-conn-id = _userlock._userlock-usr
          temp-lock.user-name = _userlock._userlock-name
          temp-lock.lock-flag = _userlock._userlock-flags[v-ind]
        .
      end.
    end.
  end.
end.
