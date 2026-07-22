block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: imp-allc.p $
$Archive: utl/imp-allc.p $

Стандартная конвертация при импорте и вызов импорта

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
define input parameter parparentproc       as handle                 no-undo.
define input parameter parchoice           as integer                no-undo.
define input parameter parInputFileNameOut as character              no-undo.
define input parameter parInputCoding      as character              no-undo.
define input parameter parexch-code        like ub.trn-doc.exch-code no-undo.
define input parameter pardoc-code         like ub.trn-doc.doc-code  no-undo.
define input parameter parcli-type         like ub.trn-doc.cli-type  no-undo. /*поставщик*/
define input parameter parcli-code         like ub.trn-doc.cli-code  no-undo.
define input parameter parhost-code        like ub.trn-doc.host-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-allc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-allc.p $":U .
define variable vss-description as character no-undo init "Стандартная конвертация при импорте и вызов импорта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/waitfram.i }

define variable varlog as logical no-undo.
define variable varInputFileNameConv     as character no-undo.
define variable varfull-pathconv         as character no-undo.
define variable varpathconv              as character no-undo.
define variable varfile-nameconv         as character no-undo.
define variable varfile-name-no-extconv  as character no-undo.
define variable varfile-name-extconv     as character no-undo.
define variable varbatfile-name          as character no-undo.
define variable varexec-file-found       as logical   no-undo.
define variable parexefile               as character no-undo.
define variable parinifile               as character no-undo.
define variable varuser-action           as character no-undo .
define variable varis-printed            as logical   no-undo .
define variable v-sys-key                as character no-undo.

/* время ожидания в секундах */
define variable vartime-count            as integer   no-undo .
system-dialog get-file varInputFileNameConv
       title   "Файл для конвертации"
       filters "Текстовый файл (*.txt)"   "*.txt",
               "Все файлы (*.*)"          "*.*"
       must-exist
       use-filename
       default-extension ".txt"
       update varlog.
if not varlog then return error.
assign
  varInputFileNameConv = trim (string (varInputFileNameConv)) .
run gbl/filename.p (
  input  varInputFileNameConv,
  output varfull-pathconv,
  output varpathconv,
  output varfile-nameconv,
  output varfile-name-no-extconv,
  output varfile-name-extconv
  ) no-error.
if error-status:error then do:
  message
    "Ошибка при вызове процедуры filename.p" skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  undo, return error .
end.

if varfile-name-extconv = "" then do:
  message "Файл без расширения не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if varfile-name-extconv = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if varfile-name-extconv = "erc" then do:
  message "Файл с расширением '.erc' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if varfile-name-extconv = "wrn" then do:
  message "Файл с расширением '.wrn' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if varfile-name-extconv = "tmp" then do:
  message "Файл с расширением '.tmp' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if varfile-name-extconv = "out" then do:
  message "Файл с расширением '.out' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
run gbl/getexini.p (output parexefile,
                output parinifile) no-error.
if error-status:error then do:
  message
    "Ошибка при вызове процедуры getexini.p." skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  undo, return error .
end.
assign
  varbatfile-name = search ('exe/convimp.bat':U).
if varbatfile-name = ? then do:
  message "Не найден файл convimp.bat" view-as alert-box error.
  return error.
end.
{ gbl/currsysk.i
  v-sys-key
  no-error
}
os-delete value(varpathconv + "/" + varfile-name-no-extconv + '.erc') .
os-delete value(varpathconv + "/" + varfile-name-no-extconv + '.tmp') .
os-delete value(varpathconv + "/" + varfile-name-no-extconv + '.out') .
os-command no-wait value( "start  /min " + varbatfile-name  + {&space-char} +
                          varpathconv + "/" + varfile-nameconv                 + {&space-char} +
                          varpathconv + "/" + varfile-name-no-extconv + '.erc' + {&space-char} +
                          varpathconv + "/" + varfile-name-no-extconv + '.tmp' + {&space-char} +
                          varpathconv + "/" + varfile-name-no-extconv + '.out' + {&space-char} +
                          parexefile  + {&space-char} +
                          parinifile  + {&space-char} +
                          v-sys-key
                         ).

/* запуск внешней команды */
/* в цикле ждем появляения файла выполнения внешней программы в течение 5 минут */
assign
  vartime-count = 0
.
repeat
:
  assign
    vartime-count = vartime-count + 1
  .
  pause 1 no-message .
  run waitfram-show in this-procedure
    (input "Ожидание запуска внешней программы. " + string(vartime-count, "HH:MM:SS":U)
    ).

  if search(varpathconv + "/" + varfile-name-no-extconv + '.out') <> ? then  do:
    assign
      varexec-file-found = true
    .
    leave .
  end.
end.

run waitfram-hide in this-procedure .

if varexec-file-found = false then do:
  message
    "Ошибка при вызове внешней программы" skip
    view-as alert-box error .
  undo, return error .
end.
if search(varpathconv + varfile-name-no-extconv + '.erc') <> ? then  do:
  message "Во время конвертации файла произошли ошибки." view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки при преобразовании файла"
    ,input  0
    ,input  varpathconv + varfile-name-no-extconv + '.erc'
    ,input  7
    ,output varuser-action
    ,output varis-printed
    ).
end.

run utl/imp-all.p (input parparentproc,
               input 2,
               input varpathconv + "/" + varfile-name-no-extconv + '.out',
               input ?,
               input parexch-code,
               input pardoc-code,
               input parcli-type,
               input parcli-code,
               input parhost-code) no-error.
if error-status:error then do:
   message "Ошибка при формировании файла import." view-as alert-box error.
   return error.
end.