/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Call-back процедура для обеспечения запуска механизмов список с презуапещнным макро

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/14/06
Author: Bakhtadze Natalya
Creation date: 06/14/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/listhist.i macro-list " " }

PROCEDURE request-create-macro-list-hist :
DEFINE INPUT PARAMETER p-child-handle AS HANDLE NO-UNDO.
define buffer buf_macro-list-hist for macro-list-hist.

for each buf_macro-list-hist :

   RUN proc-create-macro-list-hist IN p-child-handle (
                                                       input buf_macro-list-hist.list-table
                                                      ,input buf_macro-list-hist.id
                                                      ,input buf_macro-list-hist.line
                                                      ,input buf_macro-list-hist.hist-mode
                                                      ,input buf_macro-list-hist.des
                                                      ,input buf_macro-list-hist.option_
                                                      ,input buf_macro-list-hist.item_
                                                      ,input buf_macro-list-hist.status_
                                                       ) no-error .
end.
end procedure.

/* $Workfile$ e n d */