/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перенос во временнудю таблицу строк произвольного файла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/07
Author: Bakhtadze Natalya
Creation date: 12/12/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rul/tempstrn.i }

define stream instream{&vssseq}.


procedure copy-file-to-temp-string :
define input parameter p-file-name as character no-undo .
define variable ss as character no-undo .

  do
  on error undo, return error
  :
    input stream instream{&vssseq} from value(p-file-name).
    repeat:
      import stream instream{&vssseq}
      unformatted ss.
      run temp-string_write in this-procedure ( input ss).

    end.
    input stream instream{&vssseq}  close.
  end.

end procedure. /* display-file */


/* $Workfile$ e n d */