/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

очистка директории от временных файлов после macroxlt

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/01/09
Author: Bakhtadze Natalya
Creation date: 10/01/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure prnexldl_clear:
define input parameter p-txl-file-name as character no-undo .
define variable v-template-file-name as character no-undo .
define variable v-vb-file-name as character no-undo .
define variable v-data-header-filename as character no-undo .
define variable v-data-filename as character no-undo .
if search( p-txl-file-name ) <> ? then do:
  input stream temp-stream from value( p-txl-file-name ).
  repeat
  :
      import stream temp-stream v-template-file-name   .
      import stream temp-stream v-vb-file-name         .
      import stream temp-stream v-data-header-filename .
      os-delete value(v-data-header-filename).
      import stream temp-stream v-data-filename        .
      os-delete value(v-data-filename).
  end.
  input stream temp-stream close.
  os-delete value( p-txl-file-name ).
end.
end procedure .

/* $Workfile$ e n d */