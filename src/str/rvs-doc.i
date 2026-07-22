/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Замена buffer-copy в rvs-doc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

1 - вариант действия.
2 - имя матрицы
3 - префикс базисного вектора матрицы (префикс препроцессинга fld)
4 - префикс таблицы
5 - префикс накатываемого инкремента
6 - префикс откатываемого инкремента

*/


&if "{1}" <> "init"   and
    "{1}" <> "create" and
    "{1}" <> "update" and
    "{1}" <> "delete" &then
   &MESSAGE "Неверный первый параметер при вызове inc-file rzv-doc.i " {1}
&endif
&if "{1}" = "init" &then
 &scop ph-1
 &scop ph-2      =
 &scop ph-3      0
 &scop ph-4
 &scop ph-5
 &scop ph-log
 &scop ps-1      {4}
 &scop ps-2
 &scop ps-3
 &scop ps-4
 &scop sf-1
 &scop sf-2
 &scop sf-3
 &scop sf-4
 &scop prs-1     {3}
 &scop prs-2     undefine
 &scop prs-3     undefine
 &scop prs-4     undefine
&endif
&if "{1}" = "delete" &then
 &scop ph-1
 &scop ph-2      =
 &scop ph-3      - determined(
 &scop ph-4      )
 &scop ph-5
 &scop ph-log
 &scop ps-1      {4}
 &scop ps-2      {4}
 &scop ps-3      {6}
 &scop ps-4
 &scop sf-1
 &scop sf-2
 &scop sf-3
 &scop sf-4
 &scop prs-1     {3}
 &scop prs-2     {3}
 &scop prs-3     {3}
 &scop prs-4     undefine
&endif
&if "{1}" = "create" &then
 &scop ph-1
 &scop ph-2      =
 &scop ph-3      + determined(
 &scop ph-4      )
 &scop ph-5
 &scop ph-log
 &scop ps-1      {4}
 &scop ps-2      {4}
 &scop ps-3      {5}
 &scop ps-4
 &scop sf-1
 &scop sf-2
 &scop sf-3
 &scop sf-4
 &scop prs-1     {3}
 &scop prs-2     {3}
 &scop prs-3     {3}
 &scop prs-4     undefine
&endif
&if "{1}" = "update" &then
 &scop ph-1
 &scop ph-2      =
 &scop ph-3      + determined(
 &scop ph-4      ) - determined(
 &scop ph-5      )
 &scop ph-log
 &scop ps-1      {4}
 &scop ps-2      {4}
 &scop ps-3      {5}
 &scop ps-4      {6}
 &scop sf-1
 &scop sf-2
 &scop sf-3
 &scop sf-4
 &scop prs-1     {3}
 &scop prs-2     {3}
 &scop prs-3     {3}
 &scop prs-4     {3}
&endif
ASSIGN
 {&{2}}
.