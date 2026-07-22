block-level on error undo, throw.
/*

$Revision: 84b48ab2f3b8, 747, rls $
$Author: ASMorozov $
$Date: Mon Aug 08 15:24:07 2016 +0300 $
$Workfile: bin-i.p $
$Archive: nws/bin-i.p $

Прием бинарного файла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/28/06
Author: Bakhtadze Natalya
Creation date: 07/28/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-counter  as integer   no-undo .
define input parameter p-mode as character no-undo .

/*
save-install save-db save-disk save-db-and-run save-disk-and-run
save-install передать файла вместе с шапкой и установить в директорию  - шапка остается в БД строки удаляем
save-dv передать файла вместе с шапкой  и оставить храниться в БД
save-disk - использовать для временных утилит и т.д.
save-db-and-run передать файла вместе с шапкой запустить и оставить храниться в БД
save-disk-and-run - использовать для временных утилит и т.д. и запустить
*/

define input parameter p-file-num as integer no-undo .
define input parameter p-file-name as character no-undo .
define input parameter p-path-type as integer no-undo .
define input parameter p-path as character no-undo .
define input parameter p-md5-signature as character no-undo .
define output parameter p-ok as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: 84b48ab2f3b8, 747, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Aug 08 15:24:07 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bin-i.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/bin-i.p $":U .
define variable vss-description as character no-undo init "Прием бинарного файла".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i  }
define stream sinp .
{ gbl/binfile.i  &stream-name=sinp }
{ cmp/ini-lib.i }
{ gbl/fileslsh.i }
{ nws/bintrnpr.i }

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-full-path-name as character no-undo .
define variable log-file-name as character no-undo init "":U.
define variable v-path as character no-undo .
define variable v-md5-signature as character no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-can-write               as logical no-undo .
define variable v-dir-name                as character no-undo .
define variable v-ini-section as character no-undo .
define variable v-ini-key as character no-undo .
define variable v-ini-path-dir as character no-undo .
define variable v-file-num as integer no-undo .
define variable v-temp-file-name as character no-undo .
define variable v-run-name as character no-undo .
define variable v-res-message as character no-undo .
define variable v-err-num as integer no-undo .
define variable v-err-mess as character no-undo .

define buffer buf_temp-ext-file-line for temp-ext-file-line .
define buffer buf_ext-file-line for ub.ext-file-line.
define buffer buf_ext-file for ub.ext-file.
define temp-table temp-ext-file no-undo like ub.ext-file.
define buffer buf_temp-ext-file for temp-ext-file.
define temp-table temp-ext-file-par no-undo like ub.ext-file-par.
define buffer buf_ext-file-par for ub.ext-file-par .
define buffer buf_temp-ext-file-par for temp-ext-file-par .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run write-to-log in p-log-handle (
        input substitute("Получение бинарного файла &1: режим &2"
                         , p-file-name
                         , p-mode )).
  _counter:
  do counter = 1 to p-counter
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    if counter modulo 10 = 0
    then do:
      run write-to-screen in p-log-handle (substitute("Получено записей &1", counter)) no-error.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      undo main-block, return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
    .
    CASE entry(1, v-rec-name, {&delim-par}) :
      when {&table_ext-file} then do:
        create buf_temp-ext-file .
        run nws-impl in p-imp-handle
          ( input {&table_ext-file}
           ,input (buffer buf_temp-ext-file:handle)
          ) no-error.
        if error-status :error then do:
          undo main-block, return error return-value .
        end.
        if v-err-num > 0 then do:
          delete buf_temp-ext-file.
          next _counter.
        end.
        if p-mode = {&save-install} then do:
          if entry(2, buf_temp-ext-file.file-type, ".") <> "mf":U then do:
            /*это не слылка манифест!!!*/
            v-err-num = 1.
            v-err-mess = substitute( "!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                                "неверная ссылка на манифест пакета обновления&3" +
                                                "Файл обновления принят не будет"
                                                , p-file-name
                                                , p-mode
                                                , {&new-line}).
          end.
          if buf_temp-ext-file.file-type <> buf_temp-ext-file.file-name then do:
            /*если так то это пришел манифест*/
            find first buf_ext-file no-lock where
                    buf_Ext-file.db-num = buf_temp-ext-file.db-num
                and buf_Ext-file.from-db-num = buf_temp-ext-file.from-db-num
                and  buf_Ext-file.file-name = buf_temp-ext-file.file-type no-error.
            if not available buf_Ext-file then do:
              v-err-num = 2.
              v-err-mess = substitute( "!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                                  "в БД отсутствует манифест пакета обновления &4&3" +
                                                  "Файл обновления принят не будет"
                                                  , p-file-name
                                                  , p-mode
                                                  , {&new-line}
                                                  , buf_temp-ext-file.file-type
                                                  ).
            end.
          end. /*if buf_temp-ext-file.file-type <> buf_temp-ext-file.file-name :*/
        end.
        if buf_temp-Ext-file.file-num <> p-file-num
        and (p-mode = {&save-db}
            or
            p-mode = {&save-install}
            or
            p-mode = {&save-db-and-run}
            )
        then do:
           /**/
          v-err-num = 3.
          v-err-mess = substitute("!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                              "номер файла &4 в шапке файла не совпадает с номером файла в команде  - &5&3" +
                                              "Бинарный файл принят/запущен не будет"
                                                    , p-file-name
                                                    , p-mode
                                                    , {&new-line}
                                                    , buf_temp-Ext-file.file-num
                                                    , p-file-num
                                                  ).
        end.
        find first buf_ext-file where
                  buf_Ext-file.db-num = buf_temp-ext-file.db-num
              and buf_Ext-file.from-db-num = buf_temp-ext-file.from-db-num
              and buf_Ext-file.file-num = buf_temp-ext-file.file-num  no-error.
        if not available buf_Ext-file then do:
          create buf_ext-file.
        end.
        buffer-copy
        buf_temp-ext-file to
        buf_ext-file .
      end.
      when {&table_ext-file-line} then do:
        create buf_temp-ext-file-line .
        run nws-impl in p-imp-handle
          ( input {&table_ext-file-line}
           ,input (buffer buf_temp-ext-file-line:handle)
          ) no-error.
        if error-status :error then do:
          undo main-block, return error return-value .
        end.
        if v-err-num > 0 then do:
          delete buf_temp-ext-file-line.
          next _counter.
        end.
        if buf_temp-Ext-file-line.file-num <> p-file-num then do:
           /**/
           v-err-num = 4.
           v-err-mess =  substitute("!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                              "номер файла &4 в строке файла не совпадает с номером файла в команде  - &5&3" +
                                              "Бинарный файл принят/запущен не будет"
                                                    , p-file-name
                                                    , p-mode
                                                    , {&new-line}
                                                    , buf_temp-Ext-file-line.file-num
                                                    , p-file-num
                                                  ).


        end.
        if p-mode = {&save-db}
        or p-mode = {&save-db-and-run}
        then do:
          find first buf_ext-file-line where
                   buf_Ext-file-line.db-num = buf_temp-ext-file-line.db-num
               and buf_Ext-file-line.from-db-num = buf_temp-ext-file-line.from-db-num
               and buf_Ext-file-line.file-num = buf_temp-ext-file-line.file-num
               and buf_Ext-file-line.line-num = buf_temp-ext-file-line.line-num
               and buf_Ext-file-line.sub-line-num = buf_temp-ext-file-line.sub-line-num no-error.
          if not available buf_Ext-file-line then do:
            create buf_Ext-file-line.
          end.
          buffer-copy
          buf_temp-ext-file-line to
          buf_ext-file-line .
        end.
      end.
      when {&table_ext-file-par} then do:
          create buf_temp-ext-file-par .
          run nws-impl in p-imp-handle
            ( input {&table_ext-file-par}
             ,input (buffer buf_temp-ext-file-par:handle)
            ) no-error.
          if error-status :error then do:
            undo main-block, return error return-value .
          end.
          if v-err-num > 0 then do:
            delete buf_temp-ext-file-par.
            next _counter.
          end.
          if buf_temp-ext-file-par.file-num <> p-file-num then do:
            /**/
            v-err-num = 5.
            v-err-mess = substitute("!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                              "номер файла &4 в строке параметров не совпадает с номером файла в команде  - &5&3" +
                                              "Бинарный файл принят/запущен не будет"
                                                      , p-file-name
                                                      , p-mode
                                                      , {&new-line}
                                                      , buf_temp-ext-file-par.file-num
                                                      , p-file-num
                                                    ).


          end.
          find first buf_ext-file-par where
                    buf_ext-file-par.db-num = buf_temp-ext-file-par.db-num
                and buf_ext-file-par.from-db-num = buf_temp-ext-file-par.from-db-num
                and buf_ext-file-par.file-num = buf_temp-ext-file-par.file-num
                and buf_ext-file-par.param-num = buf_temp-ext-file-par.param-num no-error.
          if not available buf_ext-file-par then do:
            create buf_ext-file-par.
          end.
          buffer-copy
          buf_temp-ext-file-par to
          buf_ext-file-par .
      end. /*when ext-file-par*/
    END CASE.
  end. /*do counter*/
  if v-err-num > 0 then do:
    run write-to-log in p-log-handle ( input v-err-mess).
    undo main-block.
  end.
    if (p-mode = {&save-install}
  or p-mode = {&save-disk}
  or p-mode = {&save-disk-and-run}
  )
  and p-path-type = 1 then do:
    assign
    v-full-path-name = prepare-path(p-path) + {&slash-char} + p-file-name
    v-dir-name = p-path
    .
  end.
  if p-mode = {&save-db-and-run}
  then do:
    run gbl/_tmpfile.p (
                      input  't':U
                    ,input  (if num-entries(p-file-name, ".") > 1
                             then entry(num-entries(p-file-name, "."), p-file-name, ".")
                             else  "p")
                    ,output v-temp-file-name
                    ) .
    assign
    v-full-path-name = v-temp-file-name
    .
  end.
  if (p-mode = {&save-install}
  or p-mode = {&save-disk}
  or p-mode = {&save-disk-and-run}
  )
  and p-path-type = 0
  then do:
    /*получаем путь к работающему r-коду - это место установки исходников*/

    run gbl/filename.p (
                   input replace(this-procedure:filename, ".p", ".r")
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      run gbl/filename.p (
                   input (this-procedure:filename)
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
       v-err-mess =  substitute("&1 &2 &3&4Ошибка при определении имени файла &5&4" +
                                          "&6&4&7&4" +
                                          "для определения рабочей директории&4" +
                                          "Бинарный файл принят/запущен не будет"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,(this-procedure:filename)
                                          ,error-status:get-message(1)
                                          ,return-value ).
     run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return.
    end.
    end.
    assign
    v-full-path-name = v-path +  {&slash-char} +
                      prepare-path (p-path) +  {&slash-char} +
                      p-file-name
    v-dir-name =   v-path + {&slash-char} +
                  prepare-path (p-path)
    .
  end.
  if (p-mode = {&save-install}
  or p-mode = {&save-disk}
  or p-mode = {&save-disk-and-run}
  )
  and p-path-type = 2 then do:
    assign
    v-ini-section = entry(1, p-path)
    v-ini-key = entry(2, p-path)
    .

    RUN verify-ini-entry in this-procedure (
                           input v-ini-key
                          ,input v-ini-section
                          ,input substitute("не удалось определить значение параметра ini-файла&1" +
                                            "секция &2 ключ &3"
                                          , {&new-line}
                                          , v-ini-section
                                          , v-ini-key
                                          )
                          ,input yes /*silence*/
                          ,output v-ini-path-dir) no-error.
    if error-status:error then do:
      v-err-mess =  substitute("&2&1&3&1&4&1&5&1&6&1" +

                                         "Бинарный файл принят/запущен не будет"
                ,{&new-line}
                ,vss-workfile
                ,vss-revision
                ,vss-description
                , error-status:get-message(1)
                , return-value
                ).
      run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return ''.
    end.
    assign
    v-full-path-name =  prepare-path ( v-ini-path-dir) + {&slash-char} + p-file-name
    v-dir-name = v-ini-path-dir
    .
  end.
  if not (p-mode = {&save-db}
          or
          p-mode = {&save-db-and-run}
          )
  then do:
    /*проверим наличие директории или создадим и права*/
    FILE-INFO:FILE-NAME = v-dir-name.
    if index(FILE-INFO:file-type, 'F') > 0 then do:
      /* это не директория */
      v-err-mess = substitute("&1 &2 &3&4Путь, указанный как директория для пересылаемого файла &5 - является файлом&6&4" +
                                         "Бинарный файл принят/запущен не будет"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,p-file-name
                                          ,v-dir-name).
      run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return ''.
    end.

    if file-info:FULL-pathname = ? then do:
      run gbl/dir-cre.p ( input v-dir-name)  no-error.
      if error-status:error then do:
        v-err-mess = substitute("&1 &2 &3&4Ошибка при создании директории &5&4" +
                                            "&6&4&7&4" +
                                            "Бинарный файл принят/запущен не будет"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,v-dir-name
                                              , error-status:get-message(1)
                                              , return-value
                                              ).
        run write-to-log in p-log-handle ( input v-err-mess).
        undo main-block, return ''.
      end.
    end.
    v-can-write = index(FILE-INFO:file-type, 'W') > 0.
    if not v-can-write then do:
      v-err-mess = substitute("&1 &2 &3&4Отсутствуют права на запись в директорию &5&4" +
                                           "Бинарный файл принят/запущен не будет"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,v-dir-name).
      run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return ''.
    end.

  end. /*if not (save-db or save-db-and-run or save-db-and-call)*/
  if p-mode = {&save-db}
  or p-mode = {&save-db-and-run}
  then do:
    ASSIGN
    v-run-name = prepare-path(buf_ext-file.FILE-NAME)
    v-run-name = entry(num-entries(v-run-name, {&slash-char})
                            , v-run-name
                            , {&slash-char}
                            ).
  end.
  if p-mode = {&save-disk}
  or p-mode = {&save-install}
  or p-mode = {&save-disk-and-run}
  or p-mode = {&save-db-and-run}
  then do:
    run binfile_write in this-procedure (
       input  buf_temp-ext-file.db-num
      ,input  buf_temp-ext-file.from-db-num
      ,input  p-file-num
      ,input  v-full-path-name
      ) .
    /*проверим md5*/
    run gbl/md5.p (
        input  v-full-path-name
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if v-md5-signature <> p-md5-signature then do:
      os-delete value(v-full-path-name).
      run write-to-log in p-log-handle (
                                         substitute("!!!Принятый файл &1 (режим &2) имеет неверную сигнатуру md5 - удаляется"
                                                , p-file-name
                                                , p-mode
                                                )).
    end.
    assign
    buf_ext-file.file-name = buf_ext-file.file-name + ">" + prepare-path(p-path) + {&slash-char}.
  end.
  if p-mode = {&save-db-and-run}
  or p-mode = {&save-disk-and-run}
  then do:
    define variable v-stop as logical no-undo init yes.
    do on stop undo, next:
      run write-to-log in p-log-handle (
                                         substitute("Запускается принятый файл &1 (режим &2)"
                                                , p-file-name
                                                , p-mode
                                                )).
      run value (v-full-path-name ) (
                                      INPUT parparentproc
                                    , INPUT p-parent-handle
                                    , INPUT p-log-handle
                                    , input (string(buf_ext-file.db-num) + {&delim-par} +
                                             string(buf_ext-file.from-db-num) + {&delim-par} +
                                             string(buf_Ext-file.file-num))
                                  )
      no-error.
      v-stop = no.
    end.
    if error-status:error
    or v-stop then do:
      assign
      v-res-message =  substitute("!!!Ошибка при запуске принятого файла &1 (режим &2)&3&4&3&5&3"
                                                                                  , p-file-name
                                                                                  , p-mode
                                                                                  , {&new-line}
                                                                                  , error-status:get-message(1)
                                                                                  , return-value).

      run write-to-log in p-log-handle (
                                        substitute("!!!Ошибка при запуске принятого файла &1 (режим &2)&3&4&3&5&3"
                                                                                  , p-file-name
                                                                                  , p-mode
                                                                                  , {&new-line}
                                                                                  , error-status:get-message(1)
                                                                                  , return-value)
                                         ).

    end.
    else do:
      assign
      v-res-message =  if return-value = "" then  substitute("OK запуске принятого файла &1 (режим &2)"
                                                             , p-file-name
                                                             , p-mode
                                                            )
                       else return-value.

    end.
    find first buf_ext-file-par where
              buf_ext-file-par.db-num = buf_Ext-file.db-num
          and buf_ext-file-par.from-db-num = buf_Ext-file.from-db-num
          and buf_ext-file-par.file-num = buf_Ext-file.file-num
          and buf_ext-file-par.param-num = 0  no-error.
    if not available buf_ext-file-par then do:
      create  buf_ext-file-par.
      assign
      buf_ext-file-par.db-num = buf_Ext-file.db-num
      buf_ext-file-par.from-db-num = buf_Ext-file.from-db-num
      buf_ext-file-par.file-num = buf_Ext-file.file-num
      buf_ext-file-par.param-num = 0
      buf_ext-file-par.param-type = '':U
      buf_ext-file-par.param-name = v-run-name
      buf_ext-file-par.user-db-num = g#db-num
      .
    end .
    else do:
        run clear-record in this-procedure ( buffer buf_ext-file-par).
    end.
    assign
    buf_ext-file-par.param-name  =  substitute("Результат выполнения принятого файла  &1 (режим &2)"
                                              , p-file-name
                                              , p-mode)
    buf_ext-file-par.param-value =  v-res-message
    .
    run nws/cr-route.p (
                      input {&send-tbl}
                    , input {&table_ext-file-par}
                    , input buffer buf_ext-file-par:handle
                    , input string(g#news-source-db)) no-error.


  end.
  p-ok = yes.
  return '':U.
end. /*doe*/


procedure write-to-log :
define input parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
     run write-to-log in p-parent-handle (input p-message) .
  end.

end procedure. /* write-to-log */

procedure clear-record :
define parameter buffer buf_ext-file-par for ub.ext-file-par.

  do
  on error undo, return error return-value
  :
     assign
     buf_ext-file-par.param-name         = '':U
     buf_ext-file-par.param-value        = '':U
     buf_ext-file-par.param-date-name    = '':U
     buf_ext-file-par.param-date-value   = ?
     buf_ext-file-par.param-int-name     = '':U
     buf_ext-file-par.param-int-value    = 0
     buf_ext-file-par.param-log-name     = '':U
     buf_ext-file-par.param-log-value    = no
     buf_ext-file-par.param-decimal-name     = '':U
     buf_ext-file-par.param-decimal-value    = 0.0

     .
  end.

end procedure. /* clear-record */