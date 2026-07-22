block-level on error undo, throw.
/*

$Revision: 75002dd41ced, 247, rls $
$Author: SSlivenko $
$Date: Tue Sep 08 15:20:05 2015 +0400 $
$Workfile: get-rkpf.p $
$Archive: str/get-rkpf.p $

Сканирование файлов с касс r-keeper по директории и пробразование .dbf файла в .d файл

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/05
Author: Bakhtadze Natalya
Creation date: 01/21/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-in_ as character no-undo .
define input parameter p-spl as character no-undo .
define input parameter p-sav   as character no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo init yes.

define variable vss-revision    as character no-undo init "$Revision: 75002dd41ced, 247, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Sep 08 15:20:05 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-rkpf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-rkpf.p $":U .
define variable vss-description as character no-undo init "Сканирование файлов с касс r-keeper по директории".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ str/get-chkf.i }
{ str/r-keepdf.i "NEW SHARED" "temp" }
{ gbl/cur-time.i }
{ str/r-keepth.i "short" }

DEFINE VARIABLE v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-need-save               as logical                  no-undo .
define variable v-command-string1         as character                no-undo .
define variable v-command-string2         as character                no-undo .
define variable path-d                    as character                no-undo .
define variable path-a                    as character                no-undo .
define variable v-dbf-files               as logical                  no-undo  extent 13.
define variable v-chk-files               as logical                  no-undo  extent 7.
define variable v-not-get-all             as logical                  no-undo .
define variable v-not-get-files           as character                no-undo .
define variable v-result                  as character                no-undo .
define variable ii                        as integer                  no-undo .
define variable v-seq-num                 as integer                  no-undo .
define variable file-no-ext               as character                no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_cd-doc for ub.cd-doc.

define temp-table temp-string no-undo
field f_string as character
field f_id     as integer
index pi
is unique primary
f_id
.
/*сначалa попробум выяснить осталось ли что еще не разборанного*/
/*
b-str-deleted
file-name
id
imp-date
imp-time
imp-user
name
status_
*/

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Проверка необходимости ПОВТОРНОЙ ОБРАБОТКИ чеков, которые не удалось разобрать ранее..."
                      )
                                  ).


find last buf_cd-doc exclusive-lock where
         buf_cd-doc.obj-type = p-obj-type
     and buf_cd-doc.obj-code = p-obj-code
     and buf_cd-doc.pos-type = {&cd-type-r-keeper}
     and buf_cd-doc.doc-type = '' no-wait no-error.
if not available buf_cd-doc
and not locked(buf_cd-doc) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "НЕТ ранее неразобранных нуждающихся в ПОВТОРНОЙ ОБРАБОТКЕ чеков&1" +
                          "можно импортировать более поздние данные....."
                          , {&new-line}
                        )
                                    ).
end.
else do:
  if buf_cd-doc.charkey_one <> "":U then do:

    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Есть неразобранные ранее нуждающиеся в ПОВТОРНОЙ ОБРАБОТКЕ чеки&1" +
                            "дата и время первоначальной загрузки &2 &3&1&1"
                            , {&new-line}
                            , string(buf_cd-doc.datekey_one, "99/99/9999")
                            , string(buf_cd-doc.key#_one, "hh:mm:ss")
                          )
                                      ).

    do ii = 1 to num-entries({&chk-used-files}):
      assign
      path = p-sav + "/" + entry(ii, {&chk-used-files}) + "_" + buf_cd-doc.doc-code + ".d"
      file-no-ext = entry(ii, {&chk-used-files})
      .
      run gbl/filename.p (
                    input path
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!При ПОВТОРНОЙ ОБРАБОТКЕ ранее неразобранных чеков при чтении файла &1 произошла ошибка при получении полного пути файлу: &2"
                                , path
                                , return-value
                              )
                                          ).
        assign
        p-view-log = yes
        .
        input stream DirStream close.
        return.
      end.
      /*обработаем один .d файл - сложим все записи в temp-таблицу*/
      run str/get-rkep.p (
                    input parparentproc
                    ,input p-log-handle
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input p-host-code
                    ,input p-pos-type
                    ,input path
                    ,input file-no-ext
                    ,input - integer(buf_cd-doc.doc-code)
                    ,input-output p-view-log
                    ) no-error .

    end. /*do ii*/
    run str/get-rkep.p (
                  input parparentproc
                  ,input p-log-handle
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input p-host-code
                  ,input p-pos-type
                  ,input "":U /*пустота означает что все файлы уже перекачаны во временные таблицы и мы должны только записать в БД*/
                  ,input file-no-ext
                  ,input - integer(buf_cd-doc.doc-code) /*- означает что это обработка только чеков*/
                  ,input-output p-view-log
                  ) no-error .

    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При обработке файла &1 произошла ошибка:&2&3 &4"
                              , path
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
  find last buf_cd-doc exclusive-lock where
          buf_cd-doc.obj-type = p-obj-type
      and buf_cd-doc.obj-code = p-obj-code
      and buf_cd-doc.pos-type = {&cd-type-r-keeper}
      and buf_cd-doc.doc-type = '':U no-wait no-error.
    /*второй этап -обработка основного массива*/
    /*не начнется если что-то плохо*/
    if not available buf_cd-doc
    and not locked buf_cd-doc then.
    else do:
      if buf_cd-doc.charkey_one <> "":U then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Не удалось ПОЛНОСТЬЮ ПОВТОРНО ОБРАБОТАТЬ ранее неразобранные чеки:&1" +
                                "дата и время первоначальной загрузки &2 &3&1&1" +
                                "дальнейшее чтение чеков с касс невозможно&1&1" +
                                "!!!!!!!!ИЗ ДИРЕКТОРИИ &4 ЗАПРЕЩЕНО УДАЛЯТЬ ФАЙЛЫ С СУФФИКСОМ &5,&1" +
                                "ОНИ БУДУТ ИСПОЛЬЗОВАНЫ ДЛЯ ПОВТОРНОЙ ОБРАБОТКИ ЧЕКОВ!!!!!!!!!!"
                                , {&new-line}
                                , string(buf_cd-doc.datekey_one, "99/99/9999")
                                , string(buf_cd-doc.key#_one, "hh:mm:ss")
                                , p-sav
                                , buf_cd-doc.doc-code
                              )
                                          ).
        assign
        p-view-log = yes
        .
        return .

      end.
    end.
  end. /*if buf_cd-doc.charkey_one <> "":U then do:*/
  else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "НЕТ ранее неразобранных нуждающихся в ПОВТОРНОЙ ОБРАБОТКЕ чеков&1" +
                            "можно импортировать более поздние данные....."
                            , {&new-line}
                          )
                                      ).


  end.
end.


assign
v-not-get-all = no
v-not-get-files = "":u
.
for each temp-ACHECK:
  delete temp-acheck.
end.
for each temp-AdCHECK:
  delete temp-adcheck.
end.
for each temp-ApCHECK:
  delete temp-apcheck.
end.
for each temp-ArCHECK:
  delete temp-archeck.
end.
for each temp-AvCHECK:
  delete temp-avcheck.
end.
for each temp-categ:
  delete temp-categ.
end.
for each temp-charges:
  delete temp-charges.
end.
for each temp-control:
  delete temp-control.
end.
for each temp-menu:
  delete temp-menu.
end.
for each temp-modify:
  delete temp-modify.
end.
for each temp-money:
  delete temp-money.
end.
for each temp-personal:
  delete temp-personal.
end.
for each temp-reasons:
  delete temp-reasons.
end.

if search(p-in_ + p-spl + {&slash-char} + "finish.mrk") = ? then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Отсутствует сигнальный файл finish.mrk в директории &1:&2чтение чеков невозможно"
                          , (p-in_ + p-spl)
                          , {&new-line}
                        )
                                    ).
  assign
  p-view-log = yes
  .
  return .
end.


input stream DirStream from os-dir ( p-in_ + p-spl ) .
REPEAT :
  import stream DirStream file path atr.
  if length(file) > 4
  AND ( substring( file, length(file) - 3, 4 ) = ".dbf" )
  AND can-do( "f", atr )  /* see "os-dir" help : f - Regular file or FIFO pipe */
  AND lookup(substring( file, 1, length(file) - 4 ), {&all-used-files}) > 0
  then do:
    if v-seq-num = 0 then
    assign
    v-seq-num  = next-value(s-file-num-2, {&db-name_schema})
    path-a     = p-in_ + p-spl + "/" + "_" + string(v-seq-num) + ".d"
    .
    /*преобразуем в .d файл*/
    assign
    path-d = path
    file-no-ext = file
    substring(file-no-ext, length(file) - 3, 4) = "":U
    substring( path-d, length(path-d) - 3, 4 ) = ".d"
    v-command-string1 = "dbf.exe":U + {&space-char}  + "1" + {&space-char}  + /*тип .d файла - для версии 9 должен быть 1*/
                        "1"   + {&space-char} + /*bit-order  для процессора intel 1*/
                          path
    v-command-string2 = " > "
    .
    run syn-dbf in this-procedure (
                                    INPUT v-command-string1
                                    ,INPUT v-command-string2
                                    ,input path-d
                                    ,input substitute("Конвертация файла &1 из .dbf формата в .d формат":U
                                                      , path)

                                    ) no-error .
    if error-status:error then do:
      assign
      v-result = ?.
    end.
    else v-result = "":U.
    find first temp-string no-lock no-error .
    if not available temp-string
    or trim(trim(temp-string.f_string), {&double-quote}) <> "Data Conversion Complete":U
    or v-result = ?
    then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При конвертации файла &1 из формата .dbf в формат .d произошла ошибка:&2&3 &4"
                              , path
                              , {&new-line}
                              , (if error-status:error
                                  then error-status:get-message(1)
                                  else "":U)
                              , (if error-status:error
                                  then return-value
                                  else temp-string.f_string)
                            )
                                        ).
      assign
      p-view-log = yes
      .
      if v-result <> ? then do:
        for each temp-string no-lock where
                temp-string.f_id > 1 :
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input temp-string.f_string
                                            ).

        end.
      end.
    end.
    else do:
      /*если все хорошо взведем флажок*/
      assign
      v-dbf-files[lookup(file-no-ext, {&all-used-files})] = yes
      no-error
      .
    end.
    run gbl/filename.p (
                  input path
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                              , path
                              , return-value
                            )
                                        ).
      assign
      p-view-log = yes
      .
      input stream DirStream close.
      return.
    end.
    /*обработаем один .dbf файл - сложим все записи в temp-таблицу*/
    run str/get-rkep.p (
                  input parparentproc
                  ,input p-log-handle
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input p-host-code
                  ,input p-pos-type
                  ,input path-d
                  ,input file-no-ext
                  ,input v-seq-num
                  ,input-output p-view-log
                  ) no-error .
    os-copy
    value( path )
    value( p-sav + "/" + v-file-name-no-ext + "_" + string(v-seq-num) +  ".dbf" ) .
    if os-error > 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "Ошибка при копировании файла &1 в директорию архива &2"
                              , path, p-sav
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
    else do:
        os-delete value( path ) .
    end.
     /*перенесем получившийся файл  в save*/
    os-copy
    value( path-d )
    value( p-sav + "/" + v-file-name-no-ext + "_" + string(v-seq-num) +  ".d" ) .
    if os-error > 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "Ошибка при копировании файла &1 в директорию архива &2"
                              , path-d
                              , p-sav
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
    else do:
        os-delete value( path-d ) .
    end.
  end. /*if .dbf file*/
END . /*REPEAT*/
input stream DirStream close.
/*проверим все ли файлы на месте*/
OS-DELETE value(p-in_ + p-spl + {&slash-char} + "finish.mrk").
do ii = 1 to num-entries({&all-used-files}):
  if v-dbf-files[ii] = no then do:
    assign
    v-not-get-all = yes
    v-not-get-files = v-not-get-files +
                      (if v-not-get-files = "":u then "":U else {&new-line} ) +
                       entry(ii, {&all-used-files}) + ".dbf"
    .
  end.
end.

if v-not-get-all then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файлов .dbf с кассы &1 в директории &2&3НЕ БЫЛИ ПОЛУЧЕНЫ НЕОБХОДИМЫЕ ФАЙЛЫ:&3&4"
                          , {&cd-type-r-keeper}
                          , (p-in_ + p-spl)
                          , {&new-line}
                          ,  v-not-get-files
                           )
                                    ).
  assign
  p-view-log = yes
  .
  return .
end.

find first buf_cd-doc exclusive-lock where
        buf_cd-doc.obj-type = p-obj-type
    and buf_cd-doc.obj-code = p-obj-code
    and buf_cd-doc.pos-type = {&cd-type-r-keeper}
    and buf_cd-doc.doc-type = '':U
    and buf_cd-doc.doc-code = string(v-seq-num) no-error.

 run cur-time in this-procedure(output v-today, output v-time).

if not available buf_cd-doc then do:
  create
  buf_cd-doc.
  assign
  buf_cd-doc.obj-type = p-obj-type
  buf_cd-doc.obj-code = p-obj-code
  buf_cd-doc.pos-type = {&cd-type-r-keeper}
  buf_cd-doc.doc-type = '':U
  buf_cd-doc.doc-code = string(v-seq-num)
  buf_cd-doc.datekey_one  = v-today
  buf_cd-doc.key#_one  = v-time
  buf_cd-doc.charkey_one   = "":U
  no-error
  .
  release buf_cd-doc.
end.


run str/get-rkep.p (
              input parparentproc
              ,input p-log-handle
              ,input p-obj-type
              ,input p-obj-code
              ,input p-host-code
              ,input p-pos-type
              ,input "":U /*пустота означает что все файлы уже перекачаны во временные таблицы и мы должны только записать в БД*/
              ,input file-no-ext
              ,input v-seq-num
              ,input-output p-view-log
              ) no-error .

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка:&2&3 &4"
                          , path
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                        )
                                    ).
  assign
  p-view-log = yes
  .
end.

procedure syn-dbf :
/*командная строка*/
DEFINE INPUT PARAMETER Cmd AS CHAR No-UNDO.
DEFINE INPUT PARAMETER Cmd2 AS CHAR No-UNDO.
define input parameter path-d as character no-undo .
/*сообщение которое пользователь будет видеть на экране во время выполнения команды*/
DEFINE INPUT PARAMETER mess AS CHAR NO-UNDO.
/*результат команды возвращенный вызванной программой через файл*/
/*файл в котором надо искать результат*/
define variable  err-file as character no-undo .
define variable ii as integer no-undo .


do
on error undo, return error
:
  /* создается временный командный файл для выполнения команды */
  define variable bat-file as character no-undo.
  define variable out-file as character no-undo .
  run gbl/_tmpfile.p ("", "bat", output bat-file) .

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess                        ).

  assign
  err-file = bat-file
  substring( err-file, length(err-file) - 3, 4 ) = ".err"
  out-file = bat-file
  substring( out-file, length(out-file) - 3, 4 ) = ".d"
  .
  OS-DELETE value(err-file).
  OS-DELETE value(out-file).

  output to value(bat-file).
  cmd2 = cmd2 + substitute("&1", out-file).

  PUT  UNFORMATTED
  cmd {&space-char}
  err-file {&space-char}
  cmd2 SKIP.
  output close.

  OS-COMMAND silent value(bat-file).

  /* время ожидания в секундах */
  define variable v-time-count as integer no-undo .
  define variable v-err-file-found as logical no-undo .

  /* запуск внешней команды */
  /* в цикле ждем появляения файла ошибок в течение 5 минут */
  REPEAT WHILE v-time-count < 300 :
    assign
      v-time-count = v-time-count + 1
    .
    pause 1 no-message .

    assign
      FILE-INFO :FILE-NAME = err-file
    .
    IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
      input from value(err-file).
      for each temp-string:
        delete temp-string.
      end.
      REPEAT :
        ii = ii + 1.
        create temp-string.
        assign
        temp-string.f_id = ii .
        import unformatted temp-string.f_string no-error .
      end.
      input close.
      assign
        v-err-file-found = true
      .
      leave .
    end.
  END.

  if v-err-file-found <> true then do:
    OS-DELETE value(bat-file).
    OS-DELETE value(out-file).
    OS-DELETE value(err-file).
    return error substitute(vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
                            "Не найден файл с результатом выполнения задания &1 &2 &3"
                            , cmd
                            , err-file
                            , cmd2
                            ).
  end.
  OS-DELETE value(bat-file).
  OS-DELETE value(err-file).
  OS-RENAME value(out-file) value(path-d).

  if os-error > 0 then do:
    OS-DELETE value(out-file).
    return error substitute(vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
                            "Не удалось переименовать файл  конвертации из &1 в &2"
                            , out-file
                            , path-d
                            ).
  end.
end. /*doe*/

end procedure. /* syn-dbf */