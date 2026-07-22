/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет архивов по финобязательствам

Автор: Чернова Светлана Александровна
Дата создания: 08/03/07
Author: Svetlana Chernova
Creation date: 08/03/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libofarh_taskclco
{&run_proc_libofarh}
(input {1}  /*parhost-code       */
,input {2}  /*parfin-ob-doc-code */
,input {3}  /*paruser-name       */
,input {4}  /*parmode            */
,input {5}  /*parcheck-order*/
,output {6}  /*parпересчет*/
) {7}
.
/* $Workfile$ e n d */