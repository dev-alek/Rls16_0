block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: file2blb.p $
$Archive: gbl/file2blb.p $

Копирование файла <-> BLOB

Автор: Чернова Светлана Александровна
Дата создания: 01/15/08
Author: Svetlana Chernova
Creation date: 01/15/08

*/

define input parameter p-mode      as character no-undo .
/*
{&lookup} - возвращает поля первичного ключа clob-data

{&add-def} - если поля первичного ключа clob-data заполнены то дописывает новый blob-bind а blob-data не трогает

{&update}
p-blob-mode = "override"
для имеющегося clob-bind ищет clob-data и проверяет нет ли у него связи с другим владельцем (другой blob-bind)
если другой владелец есть то создает свой clob-data

p-blob-mode = "add-new"
для имеющегося clob-bind ищет clob-data и проверяет изменился ли crc
если да то сохраняет clob-data
если нет - не сохраняет

{&deletion}
p-blob-mode = "leave"
ищет clob-bind и удаляет его clob-data не трогает рекомендуется использовать только для resource-type = {&lob-gate} или {&lob-upgrade}

p-blob-mode = "delete"
ищет clob-bind и соответствующий clob-data удаляет clob-bind и clob-data


*/

define input parameter p-blob-mode as character no-undo .
define input parameter p-bh        as handle no-undo.
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field as character no-undo .
define input parameter p-descr as character no-undo .
define input-output parameter p-part-num as integer no-undo .
define input parameter p-resource-type as character no-undo .
/*если создается новый кусок данных то передавать можно ?  */
define input-output parameter p-blob-db-num as integer no-undo .
/*если создается новый кусок данных то передавать можно 0  */
define input-output parameter p-int64-id as int64 no-undo .
define input parameter p-file as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: file2blb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/file2blb.p $":U .
define variable vss-description as character no-undo init "Копирование файла в blob".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }

define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-uniq-key-rec            as character no-undo .
define variable v-md5-signature           as character no-undo .
define variable v-part-num as integer no-undo .
define variable glog as logical no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-blob-db-num as integer no-undo .
define variable v-longchar1 as longchar no-undo .
define variable v-longchar2 as longchar no-undo .
define variable v-file-size as integer no-undo .
define variable v-save-blob as logical no-undo .
define buffer buf_blob-data for ub.blob-data.
define buffer other_blob-data for ub.blob-data.
define buffer other_blob-bind for ub.blob-bind.
define buffer self_blob-bind for ub.blob-bind.

FUNCTION is-abs-path returns logical ( input p-path-string as character):
if index(p-path-string, ":") > 0
or p-path-string begins ({&slash-char} + {&slash-char})
or p-path-string begins ({&back-slash-char} + {&back-slash-char})
or (index(p-path-string, {&slash-char}) = 0
and index(p-path-string, {&back-slash-char}) = 0) then return yes.
return no.
end function.


do
on error undo, return error
:
if p-mode <> {&lookup}   and
   p-mode <> {&deletion}  then do:

    run gbl/filename.p (
                   input p-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .

  if error-status:error then do:
    return error substitute("Не удается найти файл &1", p-file).
  end.
end.

if p-resource-type = {&lob-res-data} then do:
  run gen-key-rec in this-procedure ( input p-bh:table
                                    ,input p-bh
                                    ,output v-uniq-key-rec) no-error .

  if error-status:error then do:
    return error return-value .
  end.

  glog = p-bh:find-current( exclusive-lock) no-error.
  if error-status:error
  or not glog
  then do:
    undo, return error substitute("Не удалось заблокировать &1 для записи файла &2  в blob&3&4&3&5"
                                  ,v-uniq-key-rec
                                  ,p-file
                                  ,{&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).
  end.
end.
else do:
  v-uniq-key-rec = p-uniq-key-rec.
end.

case p-mode :
  when {&lookup} then do:
    find first self_blob-bind  no-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field
        and self_blob-bind.part-num = p-part-num
        no-error.
    if not available self_blob-bind then do:
      undo, return error substitute("Не найдена ссылка на blob для &1 &2 номер части &3"
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    find first buf_blob-data  no-lock where
            buf_blob-data.db-num = self_blob-bind.db-num
        and buf_blob-data.int64-id = self_blob-bind.int64-id no-error.
    if not available buf_blob-data then do:
      undo, return error substitute("Не найден blob БД &1 id &2 для &3 &4 номер части &5"
                                    ,self_blob-bind.db-num
                                    ,self_blob-bind.int64-id
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    assign
    p-blob-db-num = self_blob-bind.db-num
    p-int64-id = self_blob-bind.int64-id
    .
    v-full-path = string(session :temp-directory) + 'tempBlob.jpg' .
    COPY-LOB
      FROM  OBJECT buf_blob-data.bdata
      TO    FILE   v-full-path
      No-convert
      NO-ERROR .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка"
        view-as alert-box error
      .

     os-command silent value( 'start ' + v-full-path ) .

    return '':U.
  end.
  when {&add-def} then do:
    run gbl/md5.p (
                            input  v-full-path    /* p-file-name     */
                            ,output v-md5-signature /* p-md5-signature */
                            ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3&4&5&4&6"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).

    end.
    assign
    file-info:file-name = v-full-path.
    v-file-size = file-info:file-size.
    if v-file-size > 100000000 then do:
      undo, return error substitute("Слишком большой файл &1 (> 100000000Б)", v-full-path).
    end.
    if not (p-blob-db-num = ?
            and
            p-int64-id = 0) then do:
      find first buf_blob-data  share-lock where
              buf_blob-data.db-num = p-blob-db-num
          and buf_blob-data.int64-id = p-int64-id no-error.
      if not available buf_blob-data then do:
        undo, return error substitute("Не найден blob БД &1 id &2"
                                      ,p-blob-db-num
                                      ,p-int64-id).
      end.
    end.
    find last self_blob-bind  no-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field no-error.
    if available self_blob-bind then do:
      assign
      v-part-num = self_blob-bind.part-num + 1.
    end.
    else do:
      v-part-num = 1.
    end.
    if not available buf_blob-data then do:
      create buf_blob-data.
      assign
      buf_blob-data.int64-id   = next-value( s-blob-int64, {&db-name_schema})
      buf_blob-data.db-num = g#db-num
      buf_blob-data.crc-field  = v-md5-signature
      buf_blob-data.file-size  = v-file-size
      buf_blob-data.resource-type = p-resource-type
      .
      buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file).
      COPY-LOB
      FROM  FILE v-full-path
      TO  OBJECT buf_blob-data.bdata
      No-convert
      NO-ERROR .
      if error-status:error then do:
        if error-status :error then do:
          v-longchar1 = '':U.
          v-longchar2 = '':U.
          undo, return error substitute("Ошибка при записи файла в БД&1:&2&3"
                                        , v-full-path
                                        , {&new-line}
                                        , error-status:get-message(1) ).
        end.
      end.
    end. /*if not available buf_blob-data then do:*/
    create self_blob-bind.
    assign
    self_blob-bind.uniq-key-rec = v-uniq-key-rec
    self_blob-bind.field-name = p-field
    self_blob-bind.part-num = v-part-num
    self_blob-bind.resource-type = p-resource-type
    self_blob-bind.db-num = buf_blob-data.db-num
    self_blob-bind.int64-id = buf_blob-data.int64-id
    self_blob-bind.descr = p-descr
    p-part-num = self_blob-bind.part-num
    p-blob-db-num = self_blob-bind.db-num
    p-int64-id = self_blob-bind.int64-id
    .
    release self_blob-bind no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении связи BLOB с записью-владельцем &4 &5 &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).

    end.
    release buf_blob-data no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении BLOB для &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).

    end.
  end.
  when {&update} then do:
    if p-blob-mode <> "override"
    and p-blob-mode <> "add-new" then do:
      undo, return error  substitute("Неверное значение параметра p-clob-mode = &1", p-blob-mode).
    end.
    v-save-blob = yes.
    run gbl/md5.p (
                            input  v-full-path    /* p-file-name     */
                            ,output v-md5-signature /* p-md5-signature */
                            ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3&4&5&4&6"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).

    end.
    assign
    file-info:file-name = v-full-path.
    v-file-size = file-info:file-size.
    if v-file-size > 100000000 then do:
      undo, return error substitute("Слишком большой файл &1 (> 100000000Б)", v-full-path).
    end.

    find first self_blob-bind  exclusive-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field
        and self_blob-bind.part-num = p-part-num
        no-error.
    if not available self_blob-bind then do:
      undo, return error substitute("Не найдена ссылка на blob для &1 &2 номер части &3"
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    find first buf_blob-data  share-lock where
            buf_blob-data.db-num = self_blob-bind.db-num
        and buf_blob-data.int64-id = self_blob-bind.int64-id no-error.
    if not available buf_blob-data then do:
      undo, return error substitute("Не найден blob БД &1 id &2 для &3 &4 номер части &5"
                                    ,self_blob-bind.db-num
                                    ,self_blob-bind.int64-id
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    if p-blob-mode = "override" then do:
      for each other_blob-bind no-lock where
                other_blob-bind.db-num = self_blob-bind.db-num
            and other_blob-bind.int64-id = self_blob-bind.int64-id:
        if not (other_blob-bind.uniq-key-rec = self_blob-bind.uniq-key-rec
                and
                other_blob-bind.field-name = self_blob-bind.field-name
                and
                other_blob-bind.part-num = self_blob-bind.part-num
                ) then leave.
      end.
    end.
    if available other_blob-bind
    or p-blob-mode = "add-new"
    then do:
        /*уже связан с другим владельцем - менять нельзя нужно создать свой*/
      create buf_blob-data.
      assign
      buf_blob-data.int64-id   = next-value( s-blob-int64, {&db-name_schema})
      buf_blob-data.db-num = g#db-num
      buf_blob-data.crc-field  = v-md5-signature
      buf_blob-data.file-size  = v-file-size
      buf_blob-data.resource-type = p-resource-type
      v-save-blob = yes
      .
      buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file)
      .
    end.
    else do:
      if buf_blob-data.crc-field = v-md5-signature
      and buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file) then do:
        v-save-blob = no.
      end.
      if v-save-blob then do:
        assign
        buf_blob-data.crc-field  = v-md5-signature
        buf_blob-data.file-size  = v-file-size
        buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file)
        .
      end.
    end.
    if v-save-blob then do:
      COPY-LOB
      FROM  FILE v-full-path
      TO  OBJECT buf_blob-data.bdata
      No-convert
      NO-ERROR .
      if error-status :error then do:
        undo, return error substitute("Ошибка при записи файла в БД&1:&2&3"
                                      , v-full-path
                                      , {&new-line}
                                      , error-status:get-message(1) ).
      end.
      assign
      self_blob-bind.resource-type = p-resource-type
      self_blob-bind.db-num = buf_blob-data.db-num
      self_blob-bind.int64-id = buf_blob-data.int64-id
      self_blob-bind.descr = p-descr
      p-part-num = self_blob-bind.part-num
      p-blob-db-num = self_blob-bind.db-num
      p-int64-id = self_blob-bind.int64-id
      .
    end.
    release self_blob-bind no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении связи BLOB с записью-владельцем &4 &5 &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).

    end.
    release buf_blob-data no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении BLOB для &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).

    end.
  end.
  when {&deletion} then do:
    if p-blob-mode <> "delete"
    and p-blob-mode <> "leave" then do:
      undo, return error  substitute("Неверное значение параметра p-blob-mode = &1", p-blob-mode).
    end.
    find first self_blob-bind  exclusive-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field
        and self_blob-bind.part-num = p-part-num
        no-error.
    if not available self_blob-bind then do:
      undo, return error substitute("Не найдена ссылка на blob для &1 &2 номер части &3"
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    assign
    v-blob-db-num = self_blob-bind.db-num
    v-int64-id = self_blob-bind.int64-id
    .
    delete self_blob-bind no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при удалении связи BLOB с записью-владельцем &4 &5 &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
    end.

    if p-blob-mode = "delete" then do:
      find first buf_blob-data exclusive-lock where
                buf_blob-data.db-num = v-blob-db-num
           and  buf_blob-data.int64-id  = v-int64-id.
      delete buf_blob-data no-error. /*no-error потому что должны проверить что нет других ссылко на blob-data*/
      if error-status:error then do:
        undo, return error substitute("&1 &2 &3Ошибки при удалении BLOB для &6&7&6&8"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,v-uniq-key-rec
                                      ,p-field
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value ).
      end.
    end.
    assign
    p-part-num = ?
    p-blob-db-num = ?
    p-int64-id = 0
    .
  end.
  otherwise do:
    undo, return error  substitute("Неверное значение параметра p-mode = &1", p-mode).

  end.
end case.

end. /*doe*/