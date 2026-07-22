block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-request-dir  as character no-undo .
define input parameter p-temp-dir   as character no-undo .
define input parameter p-tempfile   as character no-undo .
define input parameter p-dir-path   as character no-undo .
define input parameter p-is-script as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runtekka.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/runtekka.p $":U .
define variable vss-description as character no-undo init "Запуск дополнительной сессии для коммуникации с кассой МАРИЯ".
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
define variable tempfile     as character no-undo.
define variable tempfile-tsk as character no-undo .
define variable res          as character no-undo .
define variable v-cmdln      as character no-undo .
define variable v-exefile    as character no-undo .
define variable v-inifile    as character no-undo .
define variable err-file     as character no-undo .
define variable bat-file-name as character no-undo .
define variable v-params as character no-undo .
define stream for-task .
do
on error undo, return error return-value
:
  assign
  tempfile-tsk = p-temp-dir  + p-tempfile + '.':U + 'tsk':U
  .
  if p-is-script then do:
    run gbl/_tmpfile.p (
                         input "":U
                       , input "":U
                       , output err-file) .
    p-temp-dir = trim(p-temp-dir, chr(34)).
    assign
    err-file = err-file + ".err":u
    v-params =
              "%" + chr(126) + "1 -param":U + chr(32) + chr(34)
              + p-dir-path + chr(44)
              + err-file + chr(44)
              + tempfile-tsk + chr(44)
              + p-temp-dir + chr(34)
    .
  end.
  else do:
    run gbl/getexini.p
      (output v-exefile
      ,output v-inifile
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении имени выполняемого файла и *.ini файла" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run gbl/_tmpfile.p (
                         input ""
                        ,input ""
                        ,output err-file) .
    p-temp-dir = trim(p-temp-dir, chr(34)).
    assign
    err-file = err-file + ".err":u
    v-cmdln  =
                v-exefile
              + chr(32) + "-ininame":u + chr(32) + v-inifile
              + chr(32) + "-p":U + chr(32) + "exttekka.p":u
              + chr(32) + "-param":U + chr(32) + chr(34)
              + p-dir-path + chr(44)
              + err-file + chr(44)
              + tempfile-tsk + chr(44)
              + p-temp-dir + chr(34)
    .
  end.
  run write-log in p-log-handle (
                                input  1
                                ,input substitute("Выполнение команды &1", v-cmdln     )) .
  if not p-is-script then do:
    run gbl/syn3.p
      (
       input v-cmdln
      ,input err-file
      ,input "Ждите! Идет обмен информацией с ТЭККА..."
      ,output res
      ) no-error .
  end.
  else do:
    assign
    bat-file-name = p-request-dir  + p-tempfile + '.':U + 'bat':U.
    run gbl/syn5.p
      (
       input v-params
      ,input err-file
      ,input bat-file-name
      ,input "Ждите! Идет обмен информацией с ТЭККА..."
      ,output res
      ) no-error .
  end.
  if res <>  "":U
  then do:
    undo, return error substitute("Не  удалось  обменяться информацией с ТЭККА:&1&2", chr(10), res).
  end.
end.
