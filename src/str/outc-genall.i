/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

открытие потока и сопутствующие операции для различных видов касс -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03


Для различных subject

*/

/*  вставляется в цикл по кассам */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable hSAXWriter as handle no-undo.
define variable Mreq as longchar no-undo.

run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
create sax-writer hSAXWriter.
hSAXWriter:set-output-destination("longchar", Mreq) no-error.
hSAXWriter:formatted = true.
hSAXWriter:encoding = "windows-1251".
               
hSAXWriter:start-document() no-error.
define variable OS-time as character  no-undo.
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" ).
hSAXWriter:start-element("data") no-error.
hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
hSAXWriter:insert-attribute("id",     v-xml-file-name) no-error.
hSAXWriter:insert-attribute("from",   string(v-obj-list))      no-error.
hSAXWriter:insert-attribute("to",     (v-obj-list + "_":U + "касса" + string(for-cash-desk.cash-num))) no-error.
hSAXWriter:insert-attribute("tstamp", string(OS-time))     no-error.
                 
/* $Workfile$ e n d */