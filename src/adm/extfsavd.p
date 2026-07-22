block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extfsavd.p $
$Archive: adm/extfsavd.p $

Сохранение на диск файла, хранящегося в БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/17/06
Author: Bakhtadze Natalya
Creation date: 08/17/06

*/

define input parameter p-db-num like ub.ext-file.db-num no-undo .
define input parameter p-from-db-num like ub.ext-file.from-db-num no-undo .
define input parameter p-file-num like ub.ext-file.file-num no-undo .
define input parameter p-dir-path as character no-undo .
/*
если p-dir-path = ?  то надо спросить у пользовател
*/
define input-output parameter p-override as integer no-undo .
/*
0 спросит  у пользователя что делать если такой файл есть
1  переписать если такой файл есть
2  переписать ВСЕ и больше не спрашавать если такой файл есть
3  оставить старый файл если такой файл есть
4  оставить ВСЕ старые файлы если такие файлы есть
5  прекращение
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extfsavd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/extfsavd.p $":U .
define variable vss-description as character no-undo init "Сохранение на диск файла, хранящегося в БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
define stream sinp .
{ gbl/binfile.i  &stream-name=sinp }

{ gbl/fileslsh.i }

define variable v-full-path-name as character no-undo .
define variable v-md5-signature as character no-undo .
define variable v-dir-type as character no-undo .
define variable v-can-write as logical no-undo .
define variable choice as integer no-undo .
define variable v-is-temp-file as logical no-undo .
define buffer buf_ext-file for ub.ext-file.



do
on error undo, return error return-value
:

   find first buf_ext-file  exclusive-lock where
            buf_Ext-file.db-num = p-db-num
        and buf_Ext-file.from-db-num = p-from-db-num
        and buf_Ext-file.file-num = p-file-num no-error .
  if not available buf_Ext-file then do:
    undo, return error substitute("Не найден файл, сохраненный в БД:&1БД &2 № файла &3"
                          , {&new-line}
                          , p-db-num
                          , p-file-num).
  end.
  if p-dir-path = ? then do:
     run gbl/dir-sel.p (
                      output p-dir-path
                    , output v-dir-type
                    , output v-can-write
                          )
      .
    if p-dir-path = ? then do:
      return.
    end.
    if not v-can-write then do:
        message
        substitute("Вы не имеете прав на запись в выбранный каталог &1", p-dir-path)
        view-as alert-box error .
        return error.
    end.
  end.
  file-info:file-name = p-dir-path.
  if file-info:file-type = ?
  or index( file-info:file-type, "D" ) = 0 then do:
    assign
    v-full-path-name = p-dir-path
    v-is-temp-file = yes
    .
  end.
  else do:
  assign
  v-full-path-name = entry(1, buf_ext-file.file-name, ">")
  v-full-path-name = prepare-path(v-full-path-name)
  v-full-path-name = p-dir-path + {&slash-char} +
                     entry(num-entries(v-full-path-name, {&slash-char})
                           , v-full-path-name
                           , {&slash-char}
                          )
  .
  end.
  assign
  file-info:file-name = v-full-path-name.
  if file-info:full-pathname <> ? then do:
    if p-override = 0
    then do:
      run gbl/daskfile.w (
                    input "Дальнейшие действия"
                   ,input v-full-path-name
                   ,input file-info:file-size
                   ,input file-info:file-mod-date
                   ,input file-info:file-mod-time
                   ,input buf_ext-file.file-name /*p-new-file-name*/
                   ,input buf_Ext-file.file-size
                   ,input buf_Ext-file.update-sys-date
                   ,input buf_Ext-file.update-sys-time-int
                   ,input 4 /*p-default-button*/
                   ,input 6  /*p-cancell-button*/
                   ,output choice).
      if choice = 6
      then do:
        p-override = choice.
        return.
      end.
    end.
    if choice = 2
    or choice = 4
    or choice = 5
    then do:
      p-override = choice.
    end.
    if choice = 3
    or choice = 4 then do:
      return.
    end.
  end.
  if file-info:full-pathname = ?
  or (p-override = 1
  or p-override = 2
  or (p-override = 5
      and  (buf_Ext-file.update-sys-date > file-info:file-mod-date
            or
            (buf_Ext-file.update-sys-date = file-info:file-mod-date
            and buf_Ext-file.update-sys-time-int >= file-info:file-mod-time)
            )
     )
  )
  or v-is-temp-file = yes
  then do:
    run binfile_write-from-db in this-procedure (
       input p-db-num
      ,input  p-from-db-num
      ,input  p-file-num
      ,input  v-full-path-name
      ) .
    /*проверим md5*/
    run gbl/md5.p (
        input  v-full-path-name
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if buf_ext-file.crc-field <> v-md5-signature then do:
      if p-dir-path = ? then do:
        message
        substitute("!!!Сохраненный файл &1 имеет неверную сигнатуру md5 - удаляется с диска"
              , v-full-path-name )
        view-as alert-box error .
        .
        os-delete value(v-full-path-name).
        return error .
      end.
      else do:
        return error  substitute("!!!Сохраненный файл &1 имеет неверную сигнатуру md5 - удаляется"
              , v-full-path-name ).
      end.
    end.
  end.
end. /*doe*/