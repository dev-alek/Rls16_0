/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение CLOB BLOB во временную таблицу и обратно в кодировке base64

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/08
Author: Bakhtadze Natalya
Creation date: 01/07/08

Параметр - имя потока для чтения файла

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-nws-outline no-undo like ub.nws-outline.
define temp-table temp-ext-file-line no-undo like ub.ext-file-line.

procedure lob_clear :

  define buffer buf_temp-nws-outline  for temp-nws-outline .
  define buffer buf_temp-ext-file-line  for temp-ext-file-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-nws-outline
    on error undo, return error return-value
    :
      delete buf_temp-nws-outline .
    end.
    for each buf_temp-ext-file-line
    on error undo, return error return-value
    :
      delete buf_temp-ext-file-line .
    end.

  end.

end procedure. /* lob_clear */

procedure lob_read :
  define input  parameter p-lob-bh      as handle no-undo .

  define variable v-read-line             as character no-undo format "X(255)".
  define variable v-line-num              as integer   no-undo .
  define variable v-size                  as int64     no-undo .
  define variable v-cursor                as int64     no-undo .
  define variable v-longchar              as longchar  no-undo .
  define variable v-memptr                as memptr    no-undo .

  define buffer buf_temp-ext-file-line for temp-ext-file-line .

  do
  on error undo, return error return-value
  :
    run lob_clear in this-procedure       .
    if p-lob-bh:table = {&table_blob-data} then do:
      COPY-LOB
      from object p-lob-bh:buffer-field("bdata"):buffer-value
      to v-memptr.
    end.
    else do:
      COPY-LOB
      from object p-lob-bh:buffer-field("cdata"):buffer-value
      to v-memptr.
    end.
     v-longchar = BASE64-ENCODE(v-memptr).
     COPY-LOB
     from v-longchar
     to v-memptr.
     v-size = get-size(v-memptr).
     v-longchar = '':U.

    assign
      v-line-num = 0
    .
    repeat while v-cursor < v-size
    :
      assign
        v-read-line = '':U
      .

      v-read-line = GET-STRING ( v-memptr , v-cursor + 1, (if v-line-num * 2048 <= v-size
                                                           then 2048
                                                           else (v-size - (v-line-num - 1)* 2048) ) ).
      create buf_temp-ext-file-line.
      assign
      v-line-num = v-line-num + 1

      v-cursor = v-cursor + length(v-read-line)
      buf_temp-ext-file-line.db-num         = -1
      buf_temp-ext-file-line.file-num       = -1
      buf_temp-ext-file-line.from-db-num    = -1
      buf_temp-ext-file-line.line-num       = v-line-num
      buf_temp-ext-file-line.line-text      = v-read-line
      .
    end.
    set-size(v-memptr) = 0.
  end.

end procedure. /* lob_read */

procedure lob_write :
  define input  parameter p-lob-bh        as handle no-undo .

  define variable v-memptr as memptr no-undo .
  define variable v-memptr1 as memptr no-undo .

  define variable v-read-line             as character no-undo format "X(255)".
  define variable v-line-num              as integer   no-undo .
  define variable v-size                  as int64     no-undo .
  define variable v-cursor                as int64     no-undo .
  define variable v-longchar              as longchar  no-undo .

  define buffer buf_temp-ext-file-line for temp-ext-file-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-ext-file-line
    by buf_temp-ext-file-line.db-num
    by buf_temp-ext-file-line.file-num
    by buf_temp-ext-file-line.from-db-num
    by buf_temp-ext-file-line.line-num
    on error undo, return error return-value
    :
      assign
      v-size = v-size + length(buf_temp-ext-file-line.line-text).
    end.
    if v-size = 0 then return.

    set-size(v-memptr) = v-size.
    set-size(v-memptr1) = integer(8 / 6 * v-size) + 1.
    for each buf_temp-ext-file-line
    by buf_temp-ext-file-line.db-num
    by buf_temp-ext-file-line.file-num
    by buf_temp-ext-file-line.from-db-num
    by buf_temp-ext-file-line.line-num
    on error undo, return error return-value
    :
      PUT-STRING ( v-memptr , v-cursor + 1, length(buf_temp-ext-file-line.line-text) ) = buf_temp-ext-file-line.line-text.
      assign
      v-cursor = v-cursor + length(buf_temp-ext-file-line.line-text).
    end.
    COPY-LOB
    from v-memptr
    to v-longchar.
    v-memptr1 = BASE64-DECODE(v-longchar).
    v-longchar = '':U.
    if p-lob-bh:table = {&table_blob-data} then do:
      COPY-LOB
      from v-memptr1
      to object p-lob-bh:buffer-field("bdata"):buffer-value
      .
    end.
    else do:
      COPY-LOB
      from v-memptr1
      to object p-lob-bh:buffer-field("cdata"):buffer-value
      .
    end.
    set-size(v-memptr) = 0.
    set-size(v-memptr1) = 0.
  end.

end procedure. /* lob_write */

/* $Workfile$ e n d */