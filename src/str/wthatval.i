/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

чтение значения атрибута документа МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/11/08
Author: Polina Gridchina
Creation date: 04/11/08

Input:

Output:

*/

&scop proc-name wthcalib_wthat-val
{&run_proc_wthcalib} (  input {1} ,       /* doc-code   */
                        input {2} ,       /* attr-code  */
                       output {3} ,       /* attr-value */
                       output {4} ) {5} . /* type       */

/* $Workfile$   E n d */