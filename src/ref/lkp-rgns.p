block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lkp-rgns.p $
$Archive: ref/lkp-rgns.p $

Обертка вызова справочника регионов РФ

Автор: Хныкин Павел Андреевич
Дата создания: 01/16/07
Author: Pavel Khnykin
Creation date: 01/16/07

*/

define input  parameter parparentproc as widget-handle  no-undo .
define input  parameter p-mode        as character      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lkp-rgns.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/lkp-rgns.p $":U .
define variable vss-description as character no-undo init "Обертка вызова справочника регионов РФ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


define variable v-reg-code like ub.regions.reg-code no-undo .
define variable v-mode     as character             no-undo .

do on error undo,  return error :
  case p-mode :
    when "lookup":u then do:
      assign
        v-mode = {&lookup}
      .
    end.
    when "choose":u then do:
      assign
        v-mode = {&choose}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверный параметр p-mode" p-mode
      view-as alert-box error.
      return error.
    end.
  end case.
  run ref/regions.w ( input  parparentproc
                    , input  v-mode
                    , output v-reg-code
                    ).
end.