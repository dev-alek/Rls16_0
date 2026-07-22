/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура шифрования парол

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/15/06


Создана на основе текста программы pswd-enc.p

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure {&proc-name} :

  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.

end procedure.

/* $Workfile$ e n d */