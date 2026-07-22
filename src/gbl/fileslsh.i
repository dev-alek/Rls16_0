/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция преобразования пути к каноническому виду с точки зрения slash

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/20/06
Author: Bakhtadze Natalya
Creation date: 08/20/06

*/

&if defined(fileslsh_i) = 0 &then

&glob fileslsh_i


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, {&back-slash-char}, {&slash-char})
v-prepared-path = right-trim(v-prepared-path, {&slash-char})
.
return v-prepared-path.
END FUNCTION.

function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, {&slash-char}, {&back-slash-char})
v-prepared-path = right-trim(v-prepared-path, {&back-slash-char})
.
return v-prepared-path.
END FUNCTION.

function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, {&back-slash-char}):
  v-result = v-result + (if v-ii = 1 then '' else {&back-slash-char}) +
             (if index(entry(v-ii, p-full-path, {&back-slash-char}), {&space-char}) > 0
             then  substitute("&1&2&1", {&double-quote}, entry(v-ii, p-full-path, {&back-slash-char}))
             else entry(v-ii, p-full-path, {&back-slash-char})
             )
  .
end.
return v-result.
end function.


&endif

/* $Workfile$ e n d */