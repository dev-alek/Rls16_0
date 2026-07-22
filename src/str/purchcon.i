/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тип приобретения для партий накладной по договору

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 08/15/05
*/

&scop proc-name lib-trn3_purchcon
{&run_proc_lib-trn3}
( input {1} /*p-host-code         */
, input {2} /*p-contract-code     */
, output {3} /*purch-code       */
, output {4} /*purch-code-name   */
) {5}.