/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение двоичного файла во временную таблицу и обратно в кодировке base64

Автор: Перваков Михаил Сергеевич
Дата создания: 05/12/06
Author: Mikhail Pervakov
Creation date: 05/12/06

Параметр - имя потока для чтения файла

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-binfile-converter-program as character no-undo initial 'exe/base64.exe':U .

define temp-table temp-ext-file-line no-undo like ub.ext-file-line
  .

method public void binfile_read (p-db-num       as integer, 
p-from-db-num  as integer,
p-file-num     as integer,
p-file-name    as character):

  define variable v-temp-file-name        as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-input-full-pathname   as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-read-line             as character no-undo .
  define variable v-line-num              as integer   no-undo .
  define variable v-command-line          as character no-undo .

  define buffer buf_temp-ext-file-line for temp-ext-file-line .

  do
  on error undo, return error return-value
  :
    binfile_clear(input p-db-num
      ,input p-from-db-num
      ,input p-file-num
      ) .

    /* получаем уникальное имя временного файла */
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .

    /* создаем пустой временный файл */
    
    RUN gbl/_tmpfile.p ( "report", ".txt", OUTPUT v-temp-file-name ) .


    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .

    assign
      file-info :file-name    = p-file-name
      v-input-full-pathname   = file-info :full-pathname
    .

    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
    if v-temp-full-pathname = ? then v-temp-full-pathname = v-temp-file-name .
    assign
      v-command-line = substitute('&1 -e "&2" &3':U
                                      ,v-convert-full-pathname
                                      ,v-input-full-pathname
                                      ,v-temp-full-pathname
                                      )
    .

    os-command silent value(v-command-line) .

    /* считать временный текстовый файл во временную таблицу */

    input stream {&stream-name} from value(v-temp-full-pathname) .

    assign
      v-line-num = 0
    .

    repeat
    :
      assign
        v-read-line = '':U
      .

      import stream {&stream-name} unformatted v-read-line .

      if v-read-line <> '':U
      then do:
        /* создать запись строки */
        assign
          v-line-num  = v-line-num + 1
        .

        create buf_temp-ext-file-line .
        assign
          buf_temp-ext-file-line.db-num       = p-db-num
          buf_temp-ext-file-line.from-db-num  = p-from-db-num
          buf_temp-ext-file-line.file-num     = p-file-num
          buf_temp-ext-file-line.line-num     = v-line-num
          buf_temp-ext-file-line.sub-line-num = 0
          buf_temp-ext-file-line.line-text    = v-read-line
        .
      end.
    end.

    input stream {&stream-name} close .

    /* удалить временный текстовый файл */

    os-delete value(v-temp-full-pathname) .

  end.

end method. /* binfile_read */

method public void binfile_clear (p-db-num       as integer, 
p-from-db-num  as integer,
p-file-num     as integer):

  define buffer buf_temp-ext-file-line  for temp-ext-file-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-ext-file-line
      where buf_temp-ext-file-line.db-num   = p-db-num
        and buf_temp-ext-file-line.from-db-num = p-from-db-num
        and buf_temp-ext-file-line.file-num = p-file-num
    on error undo, return error return-value
    :
      delete buf_temp-ext-file-line .
    end.
  end.

end method. /* binfile_clear */

  
/* $Workfile$ e n d */