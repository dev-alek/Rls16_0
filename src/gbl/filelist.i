/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с файлами

Автор: Перваков Михаил Сергеевич
Дата создания: 11/01/04
Author: Mikhail Pervakov
Creation date: 11/01/04

CoAuthor: Ilia Belousov - directory & subdirectory list, read file from directory list
Creation date: 11/01/04
CoАвтор Виктор Гюнтнер  - составление списка директорий и считывание файла по списку директорий
Дата создания: 11/01/04

Позволяет считать имена файлов, содержащихся в директории, списке директорий
или в директории со всеми поддиректориями

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define variable v-filelist-total-file-num           as integer      no-undo .
define variable v-filelist-total-dir-num            as integer      no-undo .
define variable v-filelist-main-procedure-handle    as handle       no-undo .
define variable v-filelist-main-procedure-name      as character    no-undo .

define temp-table temp-dirlist no-undo
    field dir-full-name     as character
    field dir-short-name    as character
    field need-process      as logical

    index xpk is primary unique dir-full-name
.

define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  field directory-name   as character
  field full-name        as character
  field dir-short-name   as character
  field need-process     as logical

  index xpk is unique primary full-name
  index xie1 directory-name file-name
  index xie2 directory-name file-name-no-ext
  index xie3 file-name
  index xie4 file-name-no-ext
  index xie5 need-process file-name
  .

define stream dir-list .


procedure filelist-get-file-num :

  define output parameter p-file-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-file-num = v-filelist-total-file-num
    .
  end.

end procedure. /* filelist-get-file-num */

procedure filelist-clear :

  do
  on error undo, return error return-value
  :
    define buffer buf_filelist for temp-filelist .

    assign
      v-filelist-total-file-num = 0
    .

    for each buf_filelist
    on error undo, return error
    :
      delete buf_filelist .
    end.
  end.

end procedure. /* filelist-clear */

procedure filelist-init :

  do
  on error undo, return error
  :
    /* считать все файлы из директории */
    /* будут считаны или все файлы, или файлы имеющие определенное расширение */
    define input parameter p-dir-name       as character no-undo .
    define input parameter p-filter-ext     as logical   no-undo .
    define input parameter p-ext-list       as character no-undo .
    define input parameter p-dir-short-name as character no-undo .

    define buffer buf_temp-filelist for temp-filelist .

    if p-filter-ext = true
       and p-ext-list = ?
    or (p-filter-ext = false
       and p-ext-list <> ?
       and p-ext-list <> "":U
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "p-filter-ext" p-filter-ext skip
        "p-ext-list"   p-ext-list   skip
        view-as alert-box error .
      undo, return error .
    end.

    /* удаляем все файлы с именем этой директории, */
    /* которые могли остаться от предыдущих вызовов */
    for each buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir-name
    on error undo, return error return-value
    :
      delete buf_temp-filelist .
    end.

    /* считываем файлы из директории */
    input stream dir-list from os-dir( p-dir-name ).

    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    define variable v-extension             as character no-undo .
    define variable v-file-name-without-ext as character no-undo .

    repeat
    on error undo, return error
    :

      import stream dir-list v-file v-path v-mask .

      /* проверяем, что найден файл */
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
        /* это обычный файл */
      end.
      else do:
        next . /* --->>>--- */
      end.

      if num-entries(v-file, '.':u) > 1
      then do:
        /* файл имеет расширение */
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        /* файл имеет пустое расширение */
        assign
          v-extension = ''
          v-file-name-without-ext = v-file
        .
      end.

      if p-filter-ext = true
      then do:
        if lookup(v-extension, p-ext-list) = 0
        then do:
          next . /* --->>>--- */
        end.
      end.

      create buf_temp-filelist .
      assign
        buf_temp-filelist.file-name        = v-file
        buf_temp-filelist.directory-name   = p-dir-name
        buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
        buf_temp-filelist.file-extension   = v-extension
        buf_temp-filelist.full-name        = p-dir-name + '/':u + v-file
        buf_temp-filelist.dir-short-name   = p-dir-short-name
      .

      assign
        v-filelist-total-file-num = v-filelist-total-file-num + 1
      .
      if v-filelist-main-procedure-handle <> ?
      then do:
        run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle
          (input "file":U
          , input v-filelist-total-file-num
          , input buf_temp-filelist.full-name
          , input buf_temp-filelist.file-name
          ) no-error.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-subdir-init" skip(1)
            skip "Ошибка при вызове процедуры вывода"
            skip "результатов сканирования каталогов."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.

    input stream dir-list close .

    return.
  end.

end procedure. /* filelist */

procedure filelist-dirlist-init-by-list :

  do
  on error undo, return error
  :
    define input parameter p-root-dir   as character no-undo .
    define input parameter p-dir-list   as character no-undo .
    define input parameter p-filter-ext as logical   no-undo .
    define input parameter p-ext-list   as character no-undo .

    define variable v-num-appdir as integer   no-undo .
    do v-num-appdir = 1 to num-entries(p-dir-list)
    :

      define variable v-curr-dir  as character no-undo .

      assign
        v-curr-dir = entry(v-num-appdir, p-dir-list)
      .

      /* считываем все файлы в указанных директориях */
      run filelist-init in this-procedure
        (input p-root-dir + '/':u + v-curr-dir
        ,input p-filter-ext
        ,input p-ext-list
        ,input v-curr-dir
        ) .
    end.
  end.

end procedure. /* filelist-dirlist-init-by-list */


procedure filelist-dirlist-clear :

  do
  on error undo, return error
  :
    define buffer buf_temp-dirlist for temp-dirlist .

    assign
        v-filelist-total-dir-num = 0
    .
    for each buf_temp-dirlist
    on error undo, return error
    :
      delete buf_temp-dirlist .
    end.
  end.

end procedure. /* filelist-dirlist-clear */

/*==========================================================================

    Cчитатывает только первый уровень подкаталогов.
    Для считывания всего дерева подкаталогов используйте filelist-dirlist-init

    Input:
        p-dir-name   as character - начальный каталог

*/
procedure filelist-dirlist-subdir-init :

define input parameter p-dir-name   as character no-undo .

    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    /* считываем файлы из директории */
    input stream dir-list from os-dir( p-dir-name ).

    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .

    file-in-directory:
    repeat
    on error undo, return error
    :
        import stream dir-list
            v-file
            v-path
            v-mask
        .
        /* проверяем, что найден файл */
        if  v-mask = ?
        or index( v-mask, 'D':u ) = 0
        or v-file = ".":U
        or v-file = "..":U
        then do:
            next file-in-directory. /* --->>>--- */
        end.
        else do:
            find first buf_temp-dirlist
                 where buf_temp-dirlist.dir-full-name    = v-path
            no-error.
            if not available buf_temp-dirlist
            then do:
                create buf_temp-dirlist .
                assign
                    buf_temp-dirlist.dir-full-name    = v-path
                    buf_temp-dirlist.dir-short-name   = v-file
                    buf_temp-dirlist.need-process     = yes
                .
            end.
            assign
                v-filelist-total-dir-num = v-filelist-total-dir-num + 1
            .
            if v-filelist-main-procedure-handle <> ?
            then do:
                run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle (
                      input "dir":U
                    , input v-filelist-total-dir-num
                    , input buf_temp-dirlist.dir-full-name
                    , input buf_temp-dirlist.dir-short-name
                ) no-error.
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "filelist-dirlist-subdir-init"
                        skip(1)
                        skip "Ошибка при вызове процедуры вывода"
                        skip "результатов сканирования каталогов."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    input stream dir-list close .
end.
end procedure. /* filelist-dirlist-subdir-init */


/*==========================================================================
    Cчитатывает всё дерево подкаталогов.
    Для считывания только первого уровня используйте filelist-dirlist-subdir-init

    Input:
        p-dir-name   as character - начальный каталог
*/
procedure filelist-dirlist-init :
define input parameter p-dir-name   as character no-undo .

    define variable v-file  as character no-undo.
    define variable v-path  as character no-undo.
    define variable v-mask  as character no-undo.

    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    /* удаляем все подкаталоги, которые могли остаться от предыдущих вызовов */
    for each buf_temp-dirlist
       where buf_temp-dirlist.dir-full-name begins file-info :full-pathname
    on error undo, return error return-value
    :
        delete buf_temp-dirlist .
    end.
    create buf_temp-dirlist .
    assign
        buf_temp-dirlist.dir-full-name    = file-info :full-pathname
        buf_temp-dirlist.dir-short-name   = file-info :file-name   /*entry( num-entries( v-path, "\/" ) - 1, v-path, "\/" )*/
        buf_temp-dirlist.need-process     = yes
    .
    do
    while available buf_temp-dirlist
    on error undo, return error
    :
        run filelist-dirlist-subdir-init in this-procedure (
            input buf_temp-dirlist.dir-full-name
        ).
        assign
            buf_temp-dirlist.need-process = no
        .
        find first buf_temp-dirlist
             where buf_temp-dirlist.need-process = yes
        no-error.
    end.
end.
end procedure. /* filelist-dirlist-init */


/*==========================================================================
    Установка handle процедуры
    с обработчиком результатов сканирования каталогов

    p-proc-handle    as handle
    p-proc-name      as character
*/
procedure filelist-set-procedure-handle :
define input parameter p-proc-handle    as handle           no-undo.
define input parameter p-proc-name      as character        no-undo.

    define variable v-signature    as character    no-undo.
do
on error undo, return error
:
    if p-proc-handle = ?
    or not valid-handle( p-proc-handle )
    or p-proc-handle :get-signature( p-proc-name ) = ""
    then do:
        assign
            v-filelist-main-procedure-handle = ?
            v-filelist-main-procedure-name   = ""
        .
        undo, return error "filelist-set-procedure-handle: Ошибка передачи handle основной процедуры или имени процедуры обработки результатов сканирования каталогов.".
    end.
    else do:
        assign
            v-signature = p-proc-handle :get-signature( p-proc-name )
        .
        if entry(   1, v-signature )    = "PROCEDURE":U
        and entry( 1, entry(  3, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  3, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  4, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  4, v-signature ), " ":U ) = "INTEGER":U
        and entry( 1, entry(  5, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  5, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  6, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  6, v-signature ), " ":U ) = "CHARACTER":U
        then do:
            assign
                v-filelist-main-procedure-handle = p-proc-handle
                v-filelist-main-procedure-name   = p-proc-name
            .
        end.
        else do:
            assign
                v-filelist-main-procedure-handle = ?
                v-filelist-main-procedure-name   = ""
            .
            undo, return error "filelist-set-procedure-handle: Ошибка задания параметров процедуры обработки результатов сканирования каталогов.".
        end.
    end.
end.
end procedure. /* filelist-set-procedure-handle */

/*==========================================================================
    Очистка handle процедуры
    с обработчиком результатов сканирования каталогов

    Input:
        none
*/
procedure filelist-clear-procedure-handle :
do
on error undo, return error
:
    assign
        v-filelist-main-procedure-handle = ?
        v-filelist-main-procedure-name   = ?
    .
end.
end procedure. /* filelist-clear-procedure-handle */

/* $Workfile$ e n d */

/*==========================================================================
    Очистка и заполнение temp-filelist списком файлов во всех каталогах
    таблицы temp-dirlist.
*/
procedure filelist-build-by-dirlist :

    define buffer buf_temp-dirlist      for temp-dirlist.
do
for buf_temp-dirlist
on error undo, return error
:
    for each buf_temp-dirlist
    on error undo, return error
    :
        run filelist-init in this-procedure (
              input buf_temp-dirlist.dir-full-name
            , input no
            , input "":U
            , input buf_temp-dirlist.dir-short-name
        ).
    end.        /* for each buf_temp-dirlist */
end.
end procedure. /* filelist-build-by-dirlist */

/*==========================================================================*/
procedure filelist-check-dir-exists :
define input parameter p-dir-name   as character        no-undo.
define output parameter p-exists    as logical          no-undo.

do
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :file-type <> ?
    and substring( file-info :file-type, 1, 1 ) = "D":U
    then do:
        assign
            p-exists = yes
        .
    end.
    else do:
        assign
            p-exists = no
        .
    end.
end.
end procedure. /* filelist-check-dir-exists */

/* $Workfile$ e n d */