/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по кассирам/продавцам

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

чтобы можно было больше не обраща€сь к базе выводить на любую кассу

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE cash-cash no-undo
FIELD stts like ub.clients.stts
FIELD psn-code like ub.person.psn-code
FIELD cash-code as integer
FIELD slr-code  as integer
FIELD superviser as integer
FIELD cash-name like ub.clients.obj-name
FIELD psswd as character   /*пароль кассира*/
FIELD s-psswd as character /*пароль продавца-официанта*/
FIELD ident-type as integer /*тип идентифицирующего носител€*/
                                                                /*
                                                                0Ц  магнитна€  карта
                                                                1 Ц ключ “ћ
                                                                2 Ц смарт карта
                                                                3 Ц радио карта
                                                                4 Ц штрих код

                                                                */
/*при разборке новостей елси запись удал€етс€ то ставитс€ yes*/
index icli IS PRIMARY psn-code
index icash cash-code stts
index islr  slr-code stts
.

/* $Workfile$ e n d */