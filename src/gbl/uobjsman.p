block-level on error undo, throw.
/*

$Revision: d076eddfa1e9, 1505, rls $
$Author: SMMolotkov $
$Date: Thu Aug 30 10:41:48 2018 +0300 $
$Workfile: uobjsman.p $
$Archive: gbl/uobjsman.p $

Выбор объетов

Автор: Рубан Дмитрий
Дата создания: 17/08/18
Author: Molotkov Sergey
Creation date: 17/08/18

    
*/ 
define variable vss-revision       as character no-undo init "$Revision: d076eddfa1e9, 1505, rls $":U .
    define variable vss-author         as character no-undo init "$Author: SMMolotkov $":U .
    define variable vss-date           as character no-undo init "$Date: Thu Aug 30 10:41:48 2018 +0300 $":U .
    define variable vss-workfile       as character no-undo init "$Workfile: uobjsman.p $":U .
    define variable vss-archive        as character no-undo init "$Archive: gbl/uobjsman.p $":U .
    define variable vss-description    as character no-undo init "Экранные триггеры промо-акций". 
define input  parameter parparentproc   as handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  {gbl/userobjs.i} 
  define output parameter table for userobjs_temp-user-obj .
    

{ gbl/uobjsman.i
    parparentproc
    p-db-num
    p-user-id
    p-host-code-obj
    p-obj-type 
    p-obj-code 
    p-user-select
  }