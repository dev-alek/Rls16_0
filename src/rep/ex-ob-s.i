/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок оборотки

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 07/04/02 10:37

*/
{&PutExcel}
  p3 {&tabulation}
  p4 {&tabulation}
  &if '{2}' <> 'bi-' &then gds-zap-gds-name &endif {&tabulation}
  p6 {&tabulation}
  &if '{2}' <> 'bi-' &then gds-zap-type     &endif                 {&tabulation}
  &if '{2}' <> 'bi-' &then excel-sum({2}gds-zap-other   )   &endif {&tabulation} /*скидка*/
  excel-qnty({2}ostatok-start[1])  {&tabulation}
  excel-sum({2}ostatok-start[2])  {&tabulation}
  excel-sum({2}ostatok-start[5])  {&tabulation}
  excel-sum({2}ostatok-start[8])  {&tabulation}
  excel-sum({2}ostatok-start[3])  {&tabulation}
  excel-sum({2}ostatok-start[6])  {&tabulation}
  excel-sum({2}ostatok-start[9])  {&tabulation}
  excel-qnty({2}Prih         [1])  {&tabulation}
  excel-sum({2}Prih         [2])  {&tabulation}
  excel-sum({2}Prih         [5])  {&tabulation}
  excel-sum({2}Prih         [8])  {&tabulation}
  excel-sum({2}Prih         [3])  {&tabulation}
  excel-sum({2}Prih         [6])  {&tabulation}
  excel-sum({2}Prih         [9])  {&tabulation}
  excel-qnty({2}RAsh         [1])  {&tabulation}
  excel-sum({2}RAsh         [2])  {&tabulation}
  excel-sum({2}RAsh         [5])  {&tabulation}
  excel-sum({2}RAsh         [8])  {&tabulation}
  excel-sum({2}RAsh         [3])  {&tabulation}
  excel-sum({2}RAsh         [6])  {&tabulation}
  excel-sum({2}RAsh         [9])  {&tabulation}
  excel-qnty({2}KAssa        [1])  {&tabulation}
  excel-sum({2}KAssa        [2])  {&tabulation}
  excel-sum({2}KAssa        [5])  {&tabulation}
  excel-sum({2}KAssa        [8])  {&tabulation}
  excel-sum({2}KAssa        [3])  {&tabulation}
  excel-sum({2}KAssa        [6])  {&tabulation}
  excel-sum({2}KAssa        [9])  {&tabulation}
  excel-qnty({2}Inv          [1])  {&tabulation}
  excel-sum({2}Inv          [2])  {&tabulation}
  excel-sum({2}Inv          [5])  {&tabulation}
  excel-sum({2}Inv          [8])  {&tabulation}
  excel-sum({2}Inv          [3])  {&tabulation}
  excel-sum({2}Inv          [6])  {&tabulation}
  excel-sum({2}Inv          [9])  {&tabulation}
  excel-qnty({2}Overturn     [1])  {&tabulation}
  excel-sum({2}Overturn     [2])  {&tabulation}
  excel-sum({2}Overturn     [5])  {&tabulation}
  excel-sum({2}Overturn     [8])  {&tabulation}
  excel-sum({2}Overturn     [3])  {&tabulation}
  excel-sum({2}Overturn     [6])  {&tabulation}
  excel-sum({2}Overturn     [9])  {&tabulation}
  excel-qnty({2}Ostatok-end  [1])  {&tabulation}
  excel-sum({2}Ostatok-end  [2])  {&tabulation}
  excel-sum({2}Ostatok-end  [5])  {&tabulation}
  excel-sum({2}Ostatok-end  [8])  {&tabulation}
  excel-sum({2}Ostatok-end  [3])  {&tabulation}
  excel-sum({2}Ostatok-end  [6])  {&tabulation}
  excel-sum({2}Ostatok-end  [9])  {&tabulation}
  skip.
/* $Workfile$ e n d */