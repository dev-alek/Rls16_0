/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд открытия файла

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable ReportFileName as character no-undo initial "report".
define variable was_OK_opened  as logical   no-undo.

system-dialog get-file          ReportFileName
              title             "Укажите путь"
              filters           "Текстовый файл (*.txt)" "*.txt"
              ask-overwrite
              create-test-file
              save-as
              use-filename
              default-extension "txt"
              update            was_OK_opened.
if was_OK_opened <> yes then do: return "Cancel". end.
assign ReportFileName = trim( string( ReportFileName ) ).
output {1} {2} to value ( ReportFileName ) page-size 0 {3} .

/* $Workfile$ e n d */