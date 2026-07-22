block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: runtekka.p $
$Archive: str/runtekka.p $

Запуск дополнительной сессии для коммуникации с кассой МАРИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/25/06
Author: Bakhtadze Natalya
Creation date: 01/25/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-request-dir  as character no-undo .
/*директория где лежат файлы запроса*/
define input parameter p-temp-dir   as character no-undo .
/*директория где лежат файлы объектов*/
define input parameter p-tempfile   as character no-undo .
/*имена файлов для объектов и файла tsk*/
define input parameter p-dir-path   as character no-undo .
/*директория работы с Addin.exe*/
define input parameter p-is-script as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runtekka.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/runtekka.p $":U .
define variable vss-description as character no-undo init "Запуск дополнительной сессии для коммуникации с кассой МАРИЯ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

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
    /*v-exe-file - здесь shared-commandline из ini файла - указываюшая как запустить PROGRESS на том компе где com-port*/

    run gbl/_tmpfile.p (
                         input "":U
                       , input "":U
                       , output err-file) .

    /* формирование командной строки для запуска дополнительной сессии */
    p-temp-dir = trim(p-temp-dir, {&double-quote}).
    assign
    err-file = err-file + ".err":u
    v-params = /*"echo " + chr(126) + "%1" + {&new-line} +
              "pause" + {&new-line} +*/
              "%" + chr(126) + "1 -param":U + {&space-char} + {&double-quote}
              + p-dir-path + {&comma-char}
              + err-file + {&comma-char}
              + tempfile-tsk + {&comma-char}
              + p-temp-dir + {&double-quote}

    .

  end.
  else do:
    /* определяются имена выполняемого файла и *.ini файла */
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

    /* формирование командной строки для запуска дополнительной сессии */
    p-temp-dir = trim(p-temp-dir, {&double-quote}).
    assign
    err-file = err-file + ".err":u
    v-cmdln  =
                v-exefile
              + {&space-char} + "-ininame":u + {&space-char} + v-inifile
              + {&space-char} + "-p":U + {&space-char} + "exttekka.p":u
              + {&space-char} + "-param":U + {&space-char} + {&double-quote}
              + p-dir-path + {&comma-char}
              + err-file + {&comma-char}
              + tempfile-tsk + {&comma-char}
              + p-temp-dir + {&double-quote}
    .

  end.

  run write-log in p-log-handle (
                                input  1 /*p-tab-position*/
                                ,input substitute("Выполнение команды &1", v-cmdln     )) .

  /* запуск второй сессии с ожиданием завершения */
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
    undo, return error substitute("Не  удалось  обменяться информацией с ТЭККА:&1&2", {&new-line}, res).
  end.
end.