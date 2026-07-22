/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вычисление последней даты в заданом месяце

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE LastDate:

    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.

    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).

END PROCEDURE.