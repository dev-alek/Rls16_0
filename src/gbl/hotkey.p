block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: hotkey.p $
$Archive: gbl/hotkey.p $

Обработка системных горячих клавиш

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/21/01

*/

define input parameter p-action as character no-undo .
define input parameter p-handle as handle    no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: hotkey.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/hotkey.p $":U .
def var vss-description as character no-undo init "Обработка системных горячих клавиш".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error return-value
:
  case p-action :
    when "calc":u then do:
      define variable v-calc-value   as character no-undo .
      define variable v-screen-value as character no-undo .

      if valid-handle(p-handle)
      and can-query(p-handle, "type":u)
      and p-handle :type = "fill-in":u
      and can-query(p-handle, "DATA-TYPE":u)
      and lookup(p-handle :data-type, "INTEGER,DECIMAL":U) > 0
      then do:
        assign
          v-calc-value = entry(1, p-handle :screen-value, '%':u)
        .
        run gbl/d-calc.w
          (input-output v-calc-value
          ,input        p-handle :format
          ) .
        assign
          p-handle :screen-value = v-calc-value
        .
      end.
    end.
  end.
end.