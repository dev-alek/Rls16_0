block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prch-del.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/prch-del.p $":U .
define variable vss-description as character no-undo init "Выплевывание файлов в прайс-чекер на удаление информации".
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
define variable  out                  as character no-undo .
define variable out2                  as character      no-undo .
DEFINE VARIABLE in_                   as character      no-undo .
DEFINE VARIABLE spl                   as character      no-undo .
DEFINE VARIABLE sav                   as character      no-undo .
DEFINE VARIABLE v-remote              as character      no-undo .
define variable  vv-full-path         as character no-undo .
define variable  vv-path              as character no-undo .
define variable  vv-file-name         as character no-undo .
define variable  vv-file-name2        as character no-undo .
define variable  vv-file-name-no-ext as character no-undo .
define variable  vv-file-name-ext    as character no-undo .
define stream cash-non.
  do
  on error undo, return error return-value
  :
  find first ub.cash-desk no-lock where
             ub.cash-desk.pos-type = 'pricecheck-Servis+':U no-error .
if error-status :error then do:
   message "Нет прайс-чекеров Сервис+" view-as alert-box .
   return .
end.
    run str/get-inis.p (
        input 'маг':U
      , input ub.cash-desk.obj-code
      , input 'pricecheck-Servis+':U
      , input ub.cash-desk.remote
      , input "send":U
      , output out
      , output out2
      , output in_
      , output spl
      , output sav
      , output v-remote
      ) no-error .
    run str/waitp.w (
         input (out + 'cash.upd')
        ,input ( 'Не считана предыдущая информация' )
        ,input ' Подождите 15 сек '
        ,input 'Прайс-чекер не ответил. Если Вы уверены, что с ним нет связи нажмите кнопку!'
        ,input 15
        )
        no-error.
  if  error-status :error then do:
    message  "Прайс-чекер не обработал предыдущую информацию... "  view-as alert-box .
    return .
  end.
  else do:
  run gbl/filename.p (
       input  (out + 'cash.non')
      ,output vv-full-path
      ,output vv-path
      ,output vv-file-name
      ,output vv-file-name-no-ext
      ,output vv-file-name-ext    ) no-error .
      if vv-file-name = "" then do:
          output stream cash-non to value (out + 'cash.non') .
          put stream cash-non unformatted skip.
          output stream cash-non close.
      end.
  run gbl/filename.p (
       input  (out + 'plucash.dat')
      ,output vv-full-path
      ,output vv-path
      ,output vv-file-name
      ,output vv-file-name-no-ext
      ,output vv-file-name-ext    ) no-error .
      if vv-file-name = "" then do:
          output stream cash-non to value (out + 'plucash.dat') .
          put stream cash-non unformatted
          "0,0,0,1,,1,,0,0,0,NOSIZE,,,,,,100,0,,18,1,,0,0"
          skip.
          output stream cash-non close.
      end.
  run gbl/filename.p (
       input  (out + 'bar.dat')
      ,output vv-full-path
      ,output vv-path
      ,output vv-file-name
      ,output vv-file-name-no-ext
      ,output vv-file-name-ext    ) no-error .
      if vv-file-name = "" then do:
          output stream cash-non to value (out + 'bar.dat') .
          put stream cash-non unformatted
          "0,0,NOSIZE,1"
          skip.
          output stream cash-non close.
      end.
  os-rename value( out + 'cash.non') value( out + 'cash.cng').
  message "Файл с заданием cash.cng выложен" view-as alert-box information .
end.
  end.
