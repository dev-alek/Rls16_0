/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описания и процедуры для действий выполняемых на кассах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/22/06
Author: Bakhtadze Natalya
Creation date: 02/22/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob cd-maria-report-keys   'report45~
;report52~
;report46~
':U

&glob cd-maria-report-labels 'Данные аппаратуры измерения уровня в резервуарах (актуальное состояние)~
;Данные аппаратуры измерения уровня в резервуарах (закрытая смена)~
;Актуальное состояние движения НП в разрезе резервуаров АЗС~
':U




/* $Workfile$ e n d */
