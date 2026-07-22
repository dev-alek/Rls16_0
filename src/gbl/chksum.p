block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chksum.p $
$Archive: gbl/chksum.p $

Проверить контрольные суммы файлов системы

Автор: Перваков Михаил Сергеевич
Дата создания: 11/05/04
Author: Mikhail Pervakov
Creation date: 11/05/04

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chksum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/chksum.p $":U .
define variable vss-description as character no-undo init "Проверить контрольные суммы файлов системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }



define temp-table temp-file no-undo
  field file-name      as character
  field check-sum      as character
  field is-error       as logical
  field error-message  as character
  index xpk is primary unique file-name
  index xie is-error
  .

define stream sinp .

define variable v-error-log-file-name as character no-undo initial "chksum.err":u .

define variable v-chk-sum-file      as character no-undo .
define variable v-chk-sum-signature as character no-undo .
define variable v-compile-date      as date      no-undo .
define variable v-file-finished     as logical   no-undo .
define variable v-full-path         as character no-undo .
define variable v-path              as character no-undo .
define variable v-file-name         as character no-undo .
define variable v-file-name-no-ext  as character no-undo .
define variable v-file-name-ext     as character no-undo .
define variable v-check-sum         as character no-undo .

/*CHECK_SUM_VERSION_1_0 BEGIN*/
/*COMPILE_DATE 05/11/2004*/
/*2cashpay.r 7507*/
/*2DOS.EXE 0117F8C974CAE406195CF2825DCFA454*/
/*2strdef.r 38769*/
/*CHECK_SUM_VERSION_1_0 END*/


define variable v-key   as character no-undo .
define variable v-value as character no-undo .

do
on error undo, return error return-value
:
  assign
    v-chk-sum-file = search("exe/chksum.txt")
  .

  if v-chk-sum-file = ""
  or v-chk-sum-file = ?
  then do:
    message
      "Не найден файл, содержащий информацию о контрольной сумме файлов" skip
      "Файл" "exe/chksum.txt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run gbl/md5.p
    (input  v-chk-sum-file
    ,output v-chk-sum-signature
    ) .

  define variable v-ok as logical   no-undo .
  message
    "Произвести проверку целостности кодов системы" skip
    "Контрольный файл" v-chk-sum-file skip
    "Версия контрольного файла" v-chk-sum-signature skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.

  input stream sinp from value(v-chk-sum-file) .

  import stream sinp v-key v-value .
  if v-key <> 'CHECK_SUM_VERSION_1_0'
  or v-value <> 'BEGIN'
  then do:
    message
      "Файл" v-chk-sum-file skip
      "Строка 1" skip
      "Неправильная подпись файла" v-key skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* считываем дату */
  import stream sinp v-key v-value .
  if v-key <> 'COMPILE_DATE'
  then do:
    message
      "Файл" v-chk-sum-file skip
      "Строка 2" skip
      "Должна быть указана дата компиляции" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-compile-date = date(v-value)
  .

  assign
    v-file-finished = false
  .

  repeat
  :
    assign
      v-key   = ''
      v-value = ''
    .

    import stream sinp v-key v-value .

    run waitfram-show in this-procedure
      (input substitute("Считывание контрольной суммы файла &1", v-key)
      ) .

    if  v-key = 'CHECK_SUM_VERSION_1_0'
    and v-value = 'END'
    then do:
      assign
        v-file-finished = true
      .
    end.
    else do:
      create temp-file .
      assign
        temp-file.file-name = v-key
        temp-file.check-sum = v-value
        is-error            = false
        error-message       = ""
      .
    end.
  end.

  run waitfram-hide in this-procedure .


  input stream sinp close .

  if v-file-finished = false
  then do:
    message
      "Файл" v-chk-sum-file skip
      "Отсутствует строка завершения файла" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  check_file:
  for each temp-file
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Проверка контрольной суммы файла &1", temp-file.file-name)
      ) .

    assign
      v-check-sum = ''
    .

    run gbl/filename.p
      (input  temp-file.file-name
      ,output v-full-path
      ,output v-path
      ,output v-file-name
      ,output v-file-name-no-ext
      ,output v-file-name-ext
      ) no-error  .
    if error-status :error
    then do:
      assign
        temp-file.is-error      = true
        temp-file.error-message = "Не найден файл"
      .
      next check_file .
    end.

    if v-file-name-ext = "r"
    then do:
      assign
        rcode-info :file-name = v-full-path
        v-check-sum           = string(rcode-info :crc-value)
      .
    end.
    else do:
      run gbl/md5.p
        (input  v-full-path
        ,output v-check-sum
        ) no-error .
      if error-status :error
      then do:
        assign
          temp-file.is-error      = true
          temp-file.error-message = substitute("Ошибка при определении контрольной суммы файла"
                                              + {&new-line} + "&1"
                                              + {&new-line} + "&2"
                                              ,error-status :get-message(1)
                                              ,return-value
                                              )
        .
        next check_file .
      end.
    end.

    if v-check-sum <> temp-file.check-sum
    then do:
      assign
        temp-file.is-error      = true
        temp-file.error-message = substitute("Несовпадение контрольной суммы"
                                              + {&new-line} + "Должна быть сумма &1"
                                              + {&new-line} + "Определена сумма &2"
                                              ,temp-file.check-sum
                                              ,v-check-sum
                                              )
      .
    end.
  end.

  run waitfram-hide in this-procedure .

  find first temp-file
    where temp-file.is-error = true
    no-error .
  if available temp-file
  then do:

    output stream sinp to value(v-error-log-file-name) .

    export stream sinp "Проверка целостности кодов системы" .
    export stream sinp "Контрольный файл" v-chk-sum-file .
    export stream sinp "Версия контрольного файла" v-chk-sum-signature .
    export stream sinp "Дата компиляции" string(v-compile-date, '99/99/9999':u) .
    export stream sinp "Дата проверки целостности" string(today, '99/99/9999':u) .
    export stream sinp "Время проверки целостности" string(time, 'HH:MM:SS':u) .

    define variable v-ind as integer   no-undo .

    assign
      v-ind = 0
    .

    for each temp-file
      where temp-file.is-error = true
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      export stream sinp temp-file.file-name temp-file.error-message .
    end.

    export stream sinp "Проверка целостности кодов системы закончена" .

    output stream sinp close .

    message
      "При проверке контрольных сумм файлов обнаружены ошибки" skip
      "Ошибок" v-ind skip
      "Список ошибок выведен в файл" v-error-log-file-name skip
      view-as alert-box error .

    define variable v-user-action as character no-undo .
    define variable v-printed     as logical   no-undo .

    run gbl/prnfilen.w
      (input  "Отчёт о проверке целостности системы"
      ,input  0
      ,input  v-error-log-file-name
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
  end.
  else do:
    message
      "При проверке контрольных сумм файлов ошибок не обнаружено" skip
      view-as alert-box information  .
  end.
end.