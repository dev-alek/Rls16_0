/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для экспорта в формате xml

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function xml-doc_replacespecsymbols returns char (input sinput as char).
/* Функция заменяет во входной строке спецсимволы языка xml */
/* внимание - символ & должен заменяться первым */
/* это влияет на окончательный вид строки */
  assign
    sinput = replace(sinput, '&', "&#038;")
    sinput = replace(sinput, '"', "&#034;")
    sinput = replace(sinput, '<', "&#060;")
    sinput = replace(sinput, '>', "&#062;")
    sinput = replace(sinput, chr(10), "&#010;")
  .
  return sinput.
end function.
/* $Workfile$ e n d */