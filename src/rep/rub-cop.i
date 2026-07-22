/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

преобразование дробной цены в строку

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

assign
  {2} = trim( substitute( "&1 &2 &3 &4":U
                         ,substring( string( {1} , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                         ,"{3}":U
                         ,substring( string( {1} , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                         ,"{4}":U
                         )
            )
  .

/* $Workfile$ e n d */
