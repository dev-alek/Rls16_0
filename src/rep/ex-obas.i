/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусочек оборотки по типам приобр

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/13/03 4:55

*/
 if  p2 > 10  then f_e = 10 .
              else f_e =  0 .

{&PutExcel}
  p3 {&tabulation}
  p4 {&tabulation}
  if f_e = 0 then g1 else p5 {&tabulation}
  p6 {&tabulation}
  gds-zap-type {&tabulation}
  excel-sum({2}gds-zap-other   )  {&tabulation} /*скидка*/
  excel-qnty({2}ostatok-start[1  + f_e ])  {&tabulation}
  excel-sum({2}ostatok-start[2  + f_e ])  {&tabulation}
  excel-sum({2}ostatok-start[5  + f_e ])  {&tabulation}
  excel-sum({2}ostatok-start[8  + f_e ])  {&tabulation}
  .
  {&PutExcel}
  excel-sum({2}ostatok-start[3  + f_e ])  {&tabulation}
  excel-sum({2}ostatok-start[6  + f_e ])  {&tabulation}
  excel-sum({2}ostatok-start[9  + f_e ])  {&tabulation}
  excel-qnty({2}Prih        [1  + f_e ])  {&tabulation}
  excel-sum({2}Prih         [2  + f_e ])  {&tabulation}
  excel-sum({2}Prih         [5  + f_e ])  {&tabulation}
  excel-sum({2}Prih         [8  + f_e ])  {&tabulation}
  excel-sum({2}Prih         [3  + f_e ])  {&tabulation}
  excel-sum({2}Prih         [6  + f_e ])  {&tabulation}
  excel-sum({2}Prih         [9  + f_e ])  {&tabulation}
  .
  {&PutExcel}
  excel-qnty({2}RAsh        [1  + f_e ])  {&tabulation}
  excel-sum({2}RAsh         [2  + f_e ])  {&tabulation}
  excel-sum({2}RAsh         [5  + f_e ])  {&tabulation}
  excel-sum({2}RAsh         [8  + f_e ])  {&tabulation}
  excel-sum({2}RAsh         [3  + f_e ])  {&tabulation}
  excel-sum({2}RAsh         [6  + f_e ])  {&tabulation}
  excel-sum({2}RAsh         [9  + f_e ])  {&tabulation}
  excel-qnty({2}KAssa       [1  + f_e ])  {&tabulation}
  excel-sum({2}KAssa        [2  + f_e ])  {&tabulation}
  excel-sum({2}KAssa        [5  + f_e ])  {&tabulation}
  excel-sum({2}KAssa        [8  + f_e ])  {&tabulation}
  excel-sum({2}KAssa        [3  + f_e ])  {&tabulation}
  excel-sum({2}KAssa        [6  + f_e ])  {&tabulation}
  .
  {&PutExcel}
  excel-sum({2}KAssa        [9  + f_e ])  {&tabulation}
  excel-qnty({2}Inv         [1  + f_e ])  {&tabulation}
  excel-sum({2}Inv          [2  + f_e ])  {&tabulation}
  excel-sum({2}Inv          [5  + f_e ])  {&tabulation}
  excel-sum({2}Inv          [8  + f_e ])  {&tabulation}
  excel-sum({2}Inv          [3  + f_e ])  {&tabulation}
  excel-sum({2}Inv          [6  + f_e ])  {&tabulation}
  excel-sum({2}Inv          [9  + f_e ])  {&tabulation}
  .
  {&PutExcel}

  excel-qnty({2}Overturn    [1  + f_e ])  {&tabulation}
  excel-sum({2}Overturn     [2  + f_e ])  {&tabulation}
  excel-sum({2}Overturn     [5  + f_e ])  {&tabulation}
  excel-sum({2}Overturn     [8  + f_e ])  {&tabulation}
  excel-sum({2}Overturn     [3  + f_e ])  {&tabulation}
  excel-sum({2}Overturn     [6  + f_e ])  {&tabulation}
  excel-sum({2}Overturn     [9  + f_e ])  {&tabulation}
  excel-qnty({2}Ostatok-end [1  + f_e ])  {&tabulation}
  excel-sum({2}Ostatok-end  [2  + f_e ])  {&tabulation}
  excel-sum({2}Ostatok-end  [5  + f_e ])  {&tabulation}
  excel-sum({2}Ostatok-end  [8  + f_e ])  {&tabulation}
  excel-sum({2}Ostatok-end  [3  + f_e ])  {&tabulation}
  excel-sum({2}Ostatok-end  [6  + f_e ])  {&tabulation}
  excel-sum({2}Ostatok-end  [9  + f_e ])  {&tabulation}
  g2
  skip.
/* $Workfile$ e n d */