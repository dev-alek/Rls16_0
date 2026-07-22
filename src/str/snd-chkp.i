/*

$\Revision: 1 $
$Author$
$Date$
$Workfile$
$Archive$

проверка возможно чтения чеков одного объекта из другого объекта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

/*
{1} - код объекта для которого ищем чеки
{2} - тип объекта для которого ищем чеки
{3} - буфер клиентов
{4} - текущий номер БД
{5} - буфер db
{6} - переменная - ответ
{7} - ГРОМКИЙ РЕЖИМ
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{6} = yes.
FIND FIRST {3} NO-LOCK WHERE
                    {3}.obj-code = {1} AND
                    {3}.obj-type = {2}
    No-ERROR.
IF {3}.db-num <> {4} and {4} <> 0 then do:
    if {7} then
    message "Нельзя получить информацию по чекам объекта "  {1} {2}
    "в базе данных N " {4}
    view-as alert-box.
    {6} = no.
end.
else if {4} = 0 AND {3}.db-num <> {4} then do:
    FIND FIRST {5} No-LOCK WHERE {5}.db-num = {3}.db-num No-ERROR.
    if NOT {5}.send-check then do:
        if {7} then
        message "Нельзя получить информацию по чекам объекта "  {1} {2}
        "в базе данных N " {4}
        view-as alert-box.
        {6} = no.
    end.
end.


/* $Workfile$ e n d */