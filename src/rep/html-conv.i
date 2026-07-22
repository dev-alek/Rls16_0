/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция для конвертации точки в запятую в html 

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/24/05
Author: Dmitry Ukhanov
Creation date: 05/24/05

*/

function fnc-convert-dot-to-colon returns character 
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.


function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.
    
    
END FUNCTION.