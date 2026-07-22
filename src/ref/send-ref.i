/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Нахождение настройки отслыки на кассу из справочников

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable send-ref as logical no-undo.
&if "{1}" = "" &then
  define variable dops as character no-undo format "X(250)".
  define variable dopst as character no-undo format "X(1)".

  { gbl/conf-rd.i
  "'send-ref'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  dops
  dopst
  no-error
  }
  send-ref = (IF error-status:error or dops <> "yes" then no else yes).

&else

  { gbl/conf-rd.i
  "'send-ref'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  {1}
  {2}
  no-error
  }
  send-ref = (IF error-status:error or {1} <> "yes" then no else yes).

&endif


/* $Workfile$ e n d */

