/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение факт-количества топлива в кг

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/10/07
Author: Dmitry Ukhanov
Creation date: 09/10/07

*/

&scop proc-name lib-trn3_reclcptr
{&run_proc_lib-trn3}
( input {1} /* p-handle-trn-doc */
 ,input {2} /* p-handle-doc-line*/
 ,input {3} /* p-warp-factor    -1 = удаление, +1 = добавление */
 ,input {4} /* p-ext-doc-type   надо будет удалить */
 ,input {5} /* p-chip-num-main  */
) {6} .

/* $Workfile$   E n d */