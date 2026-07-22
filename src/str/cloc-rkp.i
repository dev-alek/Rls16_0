/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие потока и сопутствующие операции для кассы R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

output stream IBMStream close.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1", (out + fname + '.txt')
                        )
                                       ).


/* $Workfile$ e n d */