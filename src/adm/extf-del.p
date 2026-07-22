block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extf-del.p $
$Archive: adm/extf-del.p $

Удаление пакета обновлений

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/06
Author: Bakhtadze Natalya
Creation date: 08/06/06

*/

define parameter buffer buf_ext-file for ub.ext-file.
define input parameter p-tree as logical no-undo .
define input parameter p-status_ as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extf-del.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/extf-del.p $":U .
define variable vss-description as character no-undo init "Удаление пакета обновлений".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ nws/bintrnpr.i }
{ gbl/key-rec.i }

define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer locked_ext-file for ub.ext-file.
define buffer buf_Ext-file-line for ub.ext-file-line.
define buffer buf2_ext-file for ub.ext-file.
define buffer buf_ext-file-par for ub.ext-file-par.
define buffer tree_ext-file for ub.ext-file.


main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*проверим параметры*/
  if buf_ext-file.from-db-num <> g#db-num
  and not g#news
  and not p-tree
  then do:
    undo, return error substitute("Нельзя удалить файл БД &1 (от БД &2) &3№ файла &4&3&5 - он создан в другой БД"
                                    , buf_ext-file.db-num
                                    , buf_ext-file.from-db-num
                                    , {&new-line}
                                    , buf_ext-file.file-num
                                    , buf_ext-file.file-name
                                    ).
  end.
  if buf_ext-file.file-type begins {&table_cash-desk} + {&delim-key}
  and buf_ext-file.file-type <> {&table_cash-desk} + {&delim-key}
  and not p-tree
  then do:
    undo, return error substitute("Нельзя удалить файл БД &1 (от БД &2) &3№ файла &4&3&5 - логи и ответы с касс удаляются ТОЛЬКО вместе с файлом-запросом"
                                    , buf_ext-file.db-num
                                    , buf_ext-file.from-db-num
                                    , {&new-line}
                                    , buf_ext-file.file-num
                                    , buf_ext-file.file-name
                                    ).
  end.
  if p-status_ = '':U
  and buf_ext-file.file-type begins "u" then do:
    find first buf2_ext-file no-lock where
              buf2_ext-file.db-num = buf_ext-file.db-num
         and  buf2_ext-file.from-db-num = buf_ext-file.from-db-num
         and  buf2_ext-file.file-name = buf_ext-file.file-type no-error.
     if available buf2_ext-file then do:
      undo, return error substitute("Нельзя удалить файл БД &1 (от БД &2) &3№ файла &4&3&5" +
                                    "Для удаления файлов пакетов обновлений существует специальный режим"
                                    , buf_ext-file.db-num
                                    , buf_ext-file.from-db-num
                                    , {&new-line}
                                    , buf_ext-file.file-num
                                    , buf_ext-file.file-name
                                    ).
    end.
  end.
  find first locked_ext-file exclusive-lock where recid(locked_Ext-file) = recid(buf_ext-file).

  if locked_Ext-file.file-type = locked_ext-file.file-name then do:
    /*манифест пакета*/
    if p-status_ = '':U
    and buf_ext-file.file-type begins "u" then do:
    for each buf2_ext-file where
          buf2_ext-file.db-num = locked_ext-file.db-num
      and buf2_ext-file.from-db-num = locked_ext-file.from-db-num
      and buf2_ext-file.file-type = locked_ext-file.file-type
    on error undo, return error return-value
    on stop undo, return error return-value :
      for each buf_Ext-file-line where
              buf_Ext-file-line.db-num = locked_Ext-file.db-num
          and buf_Ext-file-line.from-db-num = locked_Ext-file.from-db-num
          and buf_Ext-file-line.file-num = buf2_Ext-file.file-num
      on error undo, return error return-value
      on stop undo, return error return-value :
          delete buf_Ext-file-line.
      end.
      for each buf_ext-file-par where
              buf_ext-file-par.db-num = locked_ext-file.db-num
          and buf_ext-file-par.from-db-num = locked_ext-file.from-db-num
          and buf_ext-file-par.file-num = locked_ext-file.file-num
      on error undo, return error return-value
      on stop undo, return error return-value :
          delete buf_ext-file-par.
      end.
      end. /*for each buf2_ext-file where*/
    end. /*if p-status_ = '':U*/
  end.
  if buf_ext-file.file-type = {&table_cash-desk} + {&delim-key} then do:
    for each buf_ext-file-par no-lock where
            buf_ext-file-par.db-num = buf_ext-file.db-num
        and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-par.file-num = buf_ext-file.file-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
        if buf_ext-file-par.param-type = {&datatype-uniq-key-rec}
        and buf_ext-file-par.param-value begins {&table_ext-file} then do:
          run gen-row-keyr in this-procedure (
                                            input  buf_ext-file-par.param-value /*    p-key-rec    */
                                            ,input  ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
                                            ,input  "ub"
                                            ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                            ,input  EXCLUSIVE-LOCK
                                            ,output v-tbl-row
                                            ,output v-tbl-name   ) no-error.
          if error-status:error then do:
            undo main-block, return error substitute("Ошибка при удалении файла БД &1 (от БД &2) &3№ файла &4&3&5 - не найден связанный файл &6"
                                                    , buf_ext-file.db-num
                                                    , buf_ext-file.from-db-num
                                                    , {&new-line}
                                                    , buf_ext-file.file-num
                                                    , buf_ext-file.file-name
                                                    , buf_ext-file-par.param-value
                                                    ).
          end.
          if v-tbl-row <> ? then do:
          find first tree_ext-file exclusive-lock where
                    rowid(tree_ext-file) = v-tbl-row.
          run adm/extf-del.p (  buffer tree_ext-file
                              ,input yes /*tree*/
                              ,input p-status_ ) no-error.
          if error-status:error then do:
            undo main-block, return error substitute("Ошибка при удалении файла БД &1 (от БД &2) &3№ файла &4&3&5 - ошибка при удалении связанного файла &6"
                                                    , buf_ext-file.db-num
                                                    , buf_ext-file.from-db-num
                                                    , {&new-line}
                                                    , buf_ext-file.file-num
                                                    , buf_ext-file.file-name
                                                    , buf_ext-file-par.param-value
                                                    ).
          end.
        end.
    end.
  end.
  end.
  for each buf_Ext-file-line where
          buf_Ext-file-line.db-num = locked_Ext-file.db-num
      and buf_Ext-file-line.from-db-num = locked_Ext-file.from-db-num
      and buf_Ext-file-line.file-num = locked_Ext-file.file-num
  on error undo, return error return-value
  on stop undo, return error return-value :
    delete buf_Ext-file-line.
  end.
  for each buf_Ext-file-par where
          buf_Ext-file-par.db-num = locked_Ext-file.db-num
      and buf_Ext-file-par.from-db-num = locked_Ext-file.from-db-num
      and buf_Ext-file-par.file-num = locked_Ext-file.file-num
  on error undo, return error return-value
  on stop undo, return error return-value :
    delete buf_Ext-file-par.
  end.
  if not (
          g#db-num = locked_ext-file.db-num
          and
          locked_ext-file.db-num = locked_ext-file.from-db-num
        )
  and not g#news
  and not p-tree
    then do:
      run nws/cmd-del.p
        ( input {&table_ext-file}
        ,input (buffer locked_ext-file:handle)
        ,input string(if g#db-num > 0 then 0 else abs(locked_ext-file.db-num))
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
  delete buf_Ext-file.
end. /*doe*/