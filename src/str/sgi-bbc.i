/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение информации по одному товару для ее дальнейшего использования при сборе кодов, привязываемых к кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/05
Author: Bakhtadze Natalya
Creation date: 02/10/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  /*здесь то что для товара надо определить один раз*/

  { gbl/gdsbcode.i {1}.gds-code ? main-b-code no-error }
  if LOOKUP({&petrolium}, ub.units.type) > 0 and
      LOOKUP({&divisional}, ub.units.type) > 0 AND
      {1}.gds-type = {&gds-goods}
  then do:
        petrol-trk = yes.
  end.
  else petrol-trk = no.

  /*конец блока определения того что для твоара надо узнать один раз на все бар-коды*/

/* $Workfile$ e n d */