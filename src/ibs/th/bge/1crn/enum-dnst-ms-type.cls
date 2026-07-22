/*

$Revision: 41634926db53, 2860, rls $
$Author: $
$Date: $
$Workfile: $
$Archive: $

коды типов средств измерения (тип прибора) согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 04/12/17
Author: Molotkov Sergey
Creation date: 04/12/17

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-dnst-ms-type:
  define enum
    enare15 = 1 /* ареометр калиброванный при 15 градусах */
    enare20 = 2 /* ареометр калиброванный при 20 градусах */
    endensflow = 3 /* поточный плотномер */
    endenssubm = 4 /* погружной плотномер */
    enchannelfl = 5 /* канал измерения плотности (с поточным плотномером) */
    enchannelno = 6 /* канал измерения плотности (без поточного плотномера) */
  .
end enum .

