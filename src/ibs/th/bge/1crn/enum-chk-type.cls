/*

$Revision: 79dbeab10a26, 2672, rls $
$Author: Ostroukhov $
$Date: Вт ноя 17 10:53:20 2020 +0300 $
$Workfile: enum-chk-type.cls $
$Archive: ibs/th/bge/1crn/enum-chk-type.cls $

коды типов чеков согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 10/11/17
Author: Molotkov Sergey
Creation date: 10/11/17

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-chk-type:
  define enum
    ensale     =  1 /* продажа */
    encashment =  2 /* инкассация */
    enfund     =  3 /* кассовый фонд */
    enreturn   =  6 /* возврат */
    enannu     =  8 /* &rcpt-annu  = Аннуляция */
    enzrep     = 12 /* &rcpt-z-rep = Z отчет (12) */
    enclose    = 13 /* Закрытие Смены */
    enOpen     = 40 /* Открытие Смены */
  .
  define enum           
    entranscancell  = 14 /* &rcpt-trans-cancell  = сброс топливной транзакции */
    enoverflow      = 15 /* &rcpt-overflow       = переливы */
    entranstransfer = 16 /* &rcpt-trans-transfer = перевод транзакции */
    entechrefuell   = 17 /* &rcpt-tech-refuell   = тех. пролив. */
  .
end enum .

