/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Операции с именами файлов и директорий

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/18/03
Author: Bakhtadze Natalya
Creation date: 06/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function corr-file-name returns character (
 input p-file-name as character)
 .

DEFINE variable v-corr-file-name as character no-undo.
DEFINE VARIABLE ii as integer no-undo .

DEFINE VARIABLE v-char-name-list as character no-undo .

assign
v-corr-file-name = p-file-name
.
do ii = 1 to length({&file-name-invalid-char}):
  assign
  v-corr-file-name = replace(
                                v-corr-file-name
                               , substr({&file-name-invalid-char}, ii, 1 )
                               , entry(ii, {&file-name-invalid-char-name})
                           )
  .


end.


return v-corr-file-name.

end function.

/* $Workfile$ e n d */