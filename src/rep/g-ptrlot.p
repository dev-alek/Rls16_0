block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ptrlot.p $
$Archive: rep/g-ptrlot.p $

Оборотная ведомость по всем типам документов для топливных товаров

Автор: Чернова Светлана Александровна
Дата создания: 09/04/07
Author: Svetlana Chernova
Creation date: 09/04/07

Автор1: Булгаков Андрей Николаевич
Дата создания: 03/25/05

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions */
define input parameter parparentproc as widget-handle no-undo.

define variable vss-revision    as character no-undo initial "$revision: 9 $":u.
define variable vss-author      as character no-undo initial "$author: pervakov $":u.
define variable vss-date        as character no-undo initial "$date: 26.02.06 18:26 $":u.
define variable vss-workfile    as character no-undo initial "$workfile: g-ptrlot.p $":u.
define variable vss-archive     as character no-undo initial "$archive: /ver15_0/rep/g-ptrlot.p $":u.
define variable vss-description as character no-undo initial "Оборотная ведомость по всем типам документов для топливных товаров":u.
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  NEW }

  run rep/d-report.w
( input parparentproc ,
  input "rep/e-ptrlot.w":u ,
  input "Оборотная ведомость для топливных товаров по всем типам документов":u ,
  input 4 ,
  input "":u,
  input "*":u,
  input "":u,
  input "{&v-rubl},{&v-base}":u,
  input "all,{&arc-ot-yes}":u,
  input no
  ).