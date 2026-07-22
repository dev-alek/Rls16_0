/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Итоги в отчете по бонусам

Автор: Шальнев Иван Сергеевич
Дата создания: 13/08/10
Author: Ivan Shalnev
Creation date: 13/08/10

Дата создания: 13/08/10
*/

For each tmp-itog no-lock
  on error undo , next
  break
  &if  "{&b1}" <> "1"   &then BY {&b1} &endif
  &if  "{&b2}" <> "1"   &then By {&b2} &endif
  By ({&id-clients1})
  &if  "{&b3}" <> ""   &then By {&b3} &endif
  By ({&id-goods1})
  :

  &if  "{&b1}" <> "1" &then   if first-of( {&b1} )         Then DO : run print-header (1, {&b1} ). end. &endif
  &if  "{&b2}" <> "1" &then   if first-of( {&b2} )         Then DO : run print-header (2, {&b2} ). end. &endif
  assign
    v-bonus       [2] = tmp-itog.bonus
    s-kassa       [2] = tmp-itog.sum-kassa
    s-bonus-dohod [2] = tmp-itog.sum-bonus-dohod
    s-nacenka     [2] = tmp-itog.sum-nacenka / tmp-itog.bn-col
    .
    run display-str.
  &if "{&b2}" <> "1" &then if last-of( {&b2} )         Then DO : run print-footer ( 2 ,{&b2}). end. &endif
  &if "{&b1}" <> "1" &then if last-of( {&b1} )         Then DO : run print-footer ( 1, {&b1}). end. &endif
End. /* For each tmp-itog */



 /* $Workfile$ e n d */