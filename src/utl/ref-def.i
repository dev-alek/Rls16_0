/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт справочников (определения)

Автор: Булгаков Андрей Николаевич
Дата создания: 09/22/05
Author: Andrew Bulgakoff
Creation date: 09/22/05

*/

&SCOP table   ub.{1}
&SCOP tmp-tbl tt_{1}

DEFINE TEMP-TABLE {&tmp-tbl} NO-UNDO LIKE {&table}.

&IF     "{1}" = "clients"  &THEN
  DEFINE TEMP-TABLE tt_cli-grp    NO-UNDO LIKE ub.cli-grp.
  DEFINE TEMP-TABLE tt_firm       NO-UNDO LIKE ub.firm.
  DEFINE TEMP-TABLE tt_shop       NO-UNDO LIKE ub.shop.
  DEFINE TEMP-TABLE tt_store      NO-UNDO LIKE ub.store.
  DEFINE TEMP-TABLE tt_person     NO-UNDO LIKE ub.person.
&ELSEIF "{1}" = "currency" &THEN
  DEFINE TEMP-TABLE tt_curr-accnt NO-UNDO LIKE ub.curr-accnt.
  DEFINE TEMP-TABLE tt_curr-bank  NO-UNDO LIKE ub.curr-bank.
&ENDIF

/* $Workfile$   E n d */

