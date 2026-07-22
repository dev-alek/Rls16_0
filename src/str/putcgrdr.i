/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод данных по правилам скидок - на группу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putcgrdr.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.

CASE p-pos-type:
  when {&cd-type-maria} then do:
    run putc-dr-maria in this-procedure ( buffer buf_cash-desk
                                        ,input v-template-list-group ).
  end.
END CASE .
END PROCEDURE .

/* $Workfile$ e n d */