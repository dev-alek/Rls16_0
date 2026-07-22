block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dat_obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dat_obj.p $":U .
define variable vss-description as character no-undo init "Создание списка дат на объектах БД".
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
define temp-table tt-obj-db no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field db-num   like ub.clients.db-num
index pi is primary unique
  obj-type
  obj-code
.
define buffer buf_obj-date  for ub.obj-date.
define buffer buf_clients   for ub.clients.
define buffer buf_tt-obj-db for tt-obj-db.
define variable v-list-file    as character    no-undo.
define variable v-counter      as integer      no-undo.
do
on error undo, return error
:
  assign
    v-counter = 0
  .
  output to "Date1.txt":U .
  empty temp-table buf_tt-obj-db.
  for each buf_obj-date no-lock
  :
    find first buf_tt-obj-db
      where buf_tt-obj-db.obj-type = buf_obj-date.obj-type
        and buf_tt-obj-db.obj-code = buf_obj-date.obj-code
    no-error.
    if not available buf_tt-obj-db
    then do:
      find first buf_clients no-lock
          where buf_clients.obj-type = buf_obj-date.obj-type
            and buf_clients.obj-code = buf_obj-date.obj-code
      no-error.
      if available buf_clients
      then do:
        create buf_tt-obj-db.
        assign
            buf_tt-obj-db.obj-type = buf_clients.obj-type
            buf_tt-obj-db.obj-code = buf_clients.obj-code
            buf_tt-obj-db.db-num   = buf_clients.db-num
        .
      end.
    end.
    display buf_obj-date with width 320 stream-io.
    assign
      v-counter = v-counter + 1
    .
  end.
  put unformatted skip(2) fill('=',200) skip.
  for each buf_tt-obj-db
  :
    display buf_tt-obj-db with width 320 stream-io.
  end.
  output close.
  empty temp-table buf_tt-obj-db.
  if v-counter = 0
  then do:
    message
      "Таблица дат на объекте пуста" skip
    view-as alert-box warning
    title "Даты на объектах".
  end.
  assign
    v-list-file = search( "Date1.txt":U )
  .
  if v-list-file = ?
  then do:
    message
      "Не удалось выгрузить список дат"
      skip "в файл " "Date1.txt":U
    view-as alert-box error
    title "Даты на объектах".
  end.
  else do:
    message
      "Cписок дат на объектах"
      skip "выгружен в файл "
      skip v-list-file
    view-as alert-box information
    title "Даты на объектах".
  end.
end.
