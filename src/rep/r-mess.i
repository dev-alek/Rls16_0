/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
If Integer({2}) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer({2}) .

     IF ( {1} modulo Temp1 = 0 ) AND ( {1} >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( {1} )) .