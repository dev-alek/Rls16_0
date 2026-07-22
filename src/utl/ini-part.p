block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-part.p $
$Archive: utl/ini-part.p $

Инициализация партий на основании складских документов

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/13/06

Интерфейсный модуль.
Задает пользователю вопросы о том, какие зоны он хочет изменять
а затем вызывает процедуру обновления партий

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-part.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-part.p $":U .
define variable vss-description as character no-undo init "Инициализация партий на основании складских документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable l-update-free-zone     as logical no-undo .
define variable l-update-out-zone      as logical no-undo .
define variable l-update-archive-parts as logical no-undo .

assign
  l-update-free-zone = true
.
message
  "Вы хотите обрабатывать свободную зону?" skip
  "free-zone" skip
  view-as alert-box question buttons yes-no update l-update-free-zone.

assign
  l-update-out-zone = true
.
message
  "Вы хотите обрабатывать расходную зону?" skip
  "out-zone" skip
  view-as alert-box question buttons yes-no update l-update-out-zone.

assign
  l-update-archive-parts = true
.
message
  "Вы хотите обрабатывать архивные партии?" skip
  "not free-zone, not out-zone" skip
  view-as alert-box question buttons yes-no update l-update-archive-parts .


define variable lok as logical no-undo .

assign
  lok = false
.
message
  "Инициализация партий по внешним приходам." skip
  "Будут обработаны:" skip
  "партии свободной зоны" l-update-free-zone     skip
  "партии расходной зоны" l-update-out-zone      skip
  "архивные партии"       l-update-archive-parts skip
  "Продолжать?" skip
  view-as alert-box question buttons OK-Cancel update lok.
if lok <> true then do:
  return.
end.

run utl/partini.p
  (input l-update-free-zone
  ,input l-update-out-zone
  ,input l-update-archive-parts
  ).

message
  "Инициализация партий закончена."
  view-as alert-box .