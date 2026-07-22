/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок запроса по клиентам по справочнику клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


(
  ( if SupGds = yes AND {1}.sup-gds = yes     then yes else no ) OR
  ( if SupCons = yes AND {1}.sup-cons = yes     then yes else no ) OR
  ( if SupServ = yes AND {1}.sup-serv = yes     then yes else no ) OR
  ( if BuyGds = yes AND {1}.buy-gds = yes     then yes else no ) OR
  ( if BuyCons = yes AND {1}.buy-cons = yes     then yes else no ) OR
  ( if BuyServ = yes AND {1}.buy-serv = yes     then yes else no ) OR
  ( if WLim-kr = yes AND {1}.lim-kr <> 0    then yes else no )
)

/* $Workfile$ e n d */