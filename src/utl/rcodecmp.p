block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcodecmp.p $
$Archive: utl/rcodecmp.p $

Утилита сравнения директорий версии

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

У пользователя запрашивается три директории
Сравниваются директории 1 (старые файлы) и директория 2 (новые файлы)
затем в директорию 3 выкладываются все новые файлы,
которые отсутствуют в директории старых файлов
и командный файл для удаления всех файлов,
которые имеются в директории старых файлов и
отсутствуют в директории новых файлов.

Файлы с расширением *.r считаются *.r кодами Progress и для их сравнени
используется внутренняя контрольная сумма Progress.
Таким образом на сравнение *.r кодов Progress будет влиять только текст
исходной программы и не будет влиять дата компиляции.

Для сравнения остальных файлов используется контрольная сумма md5

Михаил Перваков - 03/27/02
*/

define input parameter p-dir1 as character no-undo .
define input parameter p-dir2 as character no-undo .
define input parameter p-dir3 as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcodecmp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rcodecmp.p $":U .
define variable vss-description as character no-undo init "Утилита сравнения директорий версии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/filelist.i }
{ gbl/waitfram.i }

define stream slog .

define variable v-diff-file       as character no-undo .
define variable v-delbat-file     as character no-undo .
define variable v-total-diff      as integer   no-undo .
define variable v-total-delold    as integer   no-undo .
define variable v-dir-1-signature as character no-undo .
define variable v-dir-2-signature as character no-undo .

do
on error undo, return error return-value
:
  run check-input-parameters in this-procedure .

  run filelist-clear in this-procedure .

  if  search(p-dir1 + {&slash-char} + 'dfcrc.txt':u) <> ?
  and search(p-dir2 + {&slash-char} + 'dfcrc.txt':u) <> ?
  then do:
    run gbl/md5.p
      (input  p-dir1 + {&slash-char} + 'dfcrc.txt':u /* p-file-name     */
      ,output v-dir-1-signature                      /* p-md5-signature */
      ) .
    run gbl/md5.p
      (input  p-dir2 + {&slash-char} + 'dfcrc.txt':u /* p-file-name     */
      ,output v-dir-2-signature                      /* p-md5-signature */
      ) .
    if v-dir-1-signature <> v-dir-2-signature
    then do:
      message
        "Отличаются структуры баз данных использованных для компиляции кодов" skip
        "Невозможно произвести сравнение *.r кодов" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  run waitfram-show in this-procedure
    (input substitute("Чтение файлов из директории &1 (старые файлы)", p-dir1)
    ) .

  run filelist-init in this-procedure
    (input p-dir1 /* p-dir-name       */
    ,input false  /* p-filter-ext     */
    ,input ""     /* p-ext-list       */
    ,input ""     /* p-dir-short-name */
    ) .

  run waitfram-show in this-procedure
    (input substitute("Чтение файлов из директории &1 (новые файлы)", p-dir2)
    ) .

  run filelist-init in this-procedure
    (input p-dir2 /* p-dir-name       */
    ,input false  /* p-filter-ext     */
    ,input ""     /* p-ext-list       */
    ,input ""     /* p-dir-short-name */
    ) .

  run waitfram-show in this-procedure
    (input substitute("Чтение файлов из директории &1", p-dir3)
    ) .

  run filelist-init in this-procedure
    (input p-dir3 /* p-dir-name       */
    ,input false  /* p-filter-ext     */
    ,input ""     /* p-ext-list       */
    ,input ""     /* p-dir-short-name */
    ) .

  run waitfram-show in this-procedure
    (input substitute("Проверка отсутствия файлов в директории &1", p-dir3)
    ) .

  run clear-dir3 in this-procedure .

  run check-empty-dir3 in this-procedure .

  /* создание пустых журнальных файлов */
  run clear-log-files in this-procedure .

  run waitfram-show in this-procedure
    (input substitute("Копирование новый файлов в директорию &1", p-dir3)
    ) .

  run copy-new-files in this-procedure .

  run waitfram-show in this-procedure
    (input substitute("Создание командного файла удаления старых файлов")
    ) .

  run delete-old-files in this-procedure .

  run waitfram-hide in this-procedure .

  run display-message-finished in this-procedure .

end.


procedure clear-log-files :

  do
  on error undo, return error return-value
  :
    assign
      v-diff-file   = p-dir3 + '/':u + '!newfile.txt'
      v-delbat-file = p-dir3 + '/':u + '!delfile.bat'
    .
    output stream slog to value(v-diff-file) .
    output stream slog close .
    output stream slog to value(v-delbat-file) .
    output stream slog close .

  end.

end procedure. /* clear-log-files */


procedure clear-dir3 :

  do
  on error undo, return error return-value
  :
    define variable v-ok as logical   no-undo .

    define buffer buf_temp-filelist for temp-filelist .
    find first buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir3
      no-error .
    if available buf_temp-filelist
    then do:
      message
        "Директория" p-dir3 "содержит файлы." skip
        "Файлы будут удалены." skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        undo, return error .
      end.

      for each buf_temp-filelist
        where buf_temp-filelist.directory-name = p-dir3
      on error undo, return error return-value
      :
        os-delete value(buf_temp-filelist.full-name) .
        delete buf_temp-filelist .
      end.
    end.
  end.

end procedure. /* clear-dir3 */


procedure check-empty-dir3 :

  define buffer buf_temp-filelist for temp-filelist .

  do
  on error undo, return error return-value
  :
    run filelist-init in this-procedure
      (input p-dir3 /* p-dir-name       */
      ,input false  /* p-filter-ext     */
      ,input ""     /* p-ext-list       */
      ,input ""     /* p-dir-short-name */
      ) .
    find first buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir3
      no-error .
    if available buf_temp-filelist
    then do:
      message
        "Директория" p-dir3 "содержит файлы" skip
        "которые не могут быть удалены автоматически." skip
        "Невозможно продолжить сравнение файлов." skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* check-empty-dir3 */


procedure copy-new-files :

  do
  on error undo, return error return-value
  :
    define variable v-new-check-sum as character no-undo .
    define variable v-old-check-sum as character no-undo .

    define buffer new_temp-filelist for temp-filelist .
    define buffer old_temp-filelist for temp-filelist .

    for each new_temp-filelist
      where new_temp-filelist.directory-name = p-dir2
    on error undo, return error
    :
      run waitfram-show in this-procedure
        (input substitute("Проверка файла &1", new_temp-filelist.full-name)
        ) .

      if new_temp-filelist.file-extension = "r"
      then do:
        assign
          rcode-info :file-name = new_temp-filelist.full-name
        .
        assign
          v-new-check-sum = string(rcode-info :crc-value)
        .
      end.
      else do:
        run gbl/md5.p
          (input  new_temp-filelist.full-name /* p-file-name     */
          ,output v-new-check-sum             /* p-md5-signature */
          ) .
      end.

      find first old_temp-filelist no-lock
        where old_temp-filelist.directory-name = p-dir1
          and old_temp-filelist.file-name      = new_temp-filelist.file-name
        no-error .
      if available old_temp-filelist
      then do:
        if old_temp-filelist.file-extension = "r"
        then do:
          assign
            rcode-info :file-name = old_temp-filelist.full-name
          .
          assign
            v-old-check-sum = string(rcode-info :crc-value)
          .
        end.
        else do:
          run gbl/md5.p
            (input  old_temp-filelist.full-name /* p-file-name     */
            ,output v-old-check-sum             /* p-md5-signature */
            ) .
        end.
      end.
      else do:
        assign
          v-old-check-sum = ?
        .
      end.

      if v-old-check-sum = ?
      or v-new-check-sum <> v-old-check-sum
      then do:
        assign
          v-total-diff = v-total-diff + 1
        .
        output stream slog to value(v-diff-file) append .
        put stream slog unformatted new_temp-filelist.file-name + {&space-char}
          + string(v-new-check-sum) + {&new-line}
          .
        output stream slog close .

        os-copy
          value(new_temp-filelist.full-name)
          value(p-dir3 + '/':u + new_temp-filelist.file-name)
          .
      end.
    end.
  end.

end procedure. /* copy-new-files */


procedure delete-old-files :

  do
  on error undo, return error return-value
  :
    define buffer old_temp-filelist for temp-filelist .
    define buffer new_temp-filelist for temp-filelist .

    for each old_temp-filelist
      where old_temp-filelist.directory-name = p-dir1
        and old_temp-filelist.file-name     <> '!delfile.bat'
        and old_temp-filelist.file-name     <> '!newfile.txt'
    on error undo, return error
    :
      find first new_temp-filelist no-lock
        where new_temp-filelist.directory-name = p-dir2
          and new_temp-filelist.file-name      = old_temp-filelist.file-name
        no-error .
      if not available new_temp-filelist
      then do:
        assign
          v-total-delold = v-total-delold + 1
        .
        output stream slog to value(v-delbat-file) append .
        put stream slog unformatted 'del ':u + old_temp-filelist.file-name + {&new-line} .
        output stream slog close .
      end.
    end.
  end.

end procedure. /* delete-old-files */


procedure display-message-finished :

  do
  on error undo, return error return-value
  :
    if v-total-diff   <> 0
    or v-total-delold <> 0
    then do:
      message
        "Сравнение директорий закончено" skip
        "Старая директория" p-dir1 skip
        "Новая директория" p-dir2 skip
        "Недостающие файлы скопированы в директорию" p-dir3 skip
        "Обнаружено новых файлов" v-total-diff skip
        "Список новых файлов находится в " v-diff-file skip
        "Необходимо удалить старых файлов" v-total-delold skip
        "Командный файл удаления файлов" v-delbat-file skip
        view-as alert-box information .
    end.
    else do:
      message
        "Сравнение директорий закончено" skip
        "Старая директория" p-dir1 skip
        "Новая директория" p-dir2 skip
        "Различий не обнаружено" skip
        view-as alert-box information .
    end.
  end.

end procedure. /* display-message-finished */


procedure check-input-parameters :

  do
  on error undo, return error return-value
  :
    /* проверяем, что указанные пути существуют и являются директориями */

    assign
      file-info :file-name = p-dir1
    .
    if file-info :file-type = ?
    or index(file-info :file-type, 'D':U ) = 0
    then do:
      message
        "Неправильный путь" skip
        "Директория" p-dir1 skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      file-info :file-name = p-dir2
    .
    if file-info :file-type = ?
    or index(file-info :file-type, 'D':U ) = 0
    then do:
      message
        "Неправильный путь" skip
        "Директория" p-dir2 skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      file-info :file-name = p-dir3
    .
    if file-info :file-type = ?
    or index(file-info :file-type, 'D':U ) = 0
    then do:
      message
        "Неправильный путь" skip
        "Директория" p-dir3 skip
        view-as alert-box error .
      undo, return error return-value .
    end.

  end.

end procedure. /* check-input-parameters */