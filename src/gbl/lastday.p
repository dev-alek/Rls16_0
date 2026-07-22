block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lastday.p $
$Archive: gbl/lastday.p $

Возвращает последний день текущего года/месяца по входной дате.

Автор: Чернова Светлана Александровна
Дата создания: 04/13/06
Author: Svetlana Chernova
Creation date: 04/13/06

Author:  VGC - Черных Виктор Георгиевич.
Created: 05.06.1995.

*/

define  input parameter in-date as date    no-undo. /* входная дата */
define output parameter lastday as integer no-undo. /* последний день текущего года/месяца */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: lastday.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: gbl/lastday.p $":U.
define variable vss-description as character no-undo initial "Возвращает последний день текущего года/месяца по входной дате":U.

{ cmp/vssrevis.i }

define variable tt_date as date no-undo.

do on error undo, return error :
  assign tt_date = date( month( in-date ), 28, year( in-date ) ) + 4.
  assign lastday = day( tt_date - day( tt_date ) ).
end.
