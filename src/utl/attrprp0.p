block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: attrprp0.p $
$Archive: utl/attrprp0.p $

Сохранение свойств для атрибута

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/07
Author: Bakhtadze Natalya
Creation date: 05/27/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input parameter        p-table-name as character no-undo .
define input parameter        p-templ-rl-root as integer no-undo .
define temp-table tt-attr-prop no-undo like ub.attr-prop
field full-prop-name as character
.
DEFINE INPUT PARAMETER TABLE FOR tt-attr-prop.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: attrprp0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/attrprp0.p $":U .
define variable vss-description as character no-undo init "Сохранение свойств для атрибута".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_file  for ub._file.
define buffer buf_field  for ub._field.
define buffer buf_attr-prop for ub.attr-prop.

if p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  for each tt-attr-prop
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    if tt-attr-prop.prop-code = '':u then next.
    find first buf_attr-prop where
              buf_attr-prop.table-name = p-table-name
          and buf_attr-prop.templ-rl-root = tt-attr-prop.templ-rl-root
          and buf_attr-prop.node-code = tt-attr-prop.node-code no-error .
    if not available buf_attr-prop then do:
       create buf_attr-prop.
       assign
       buf_attr-prop.table-name = {&table_dis-card-property}
       buf_attr-prop.templ-rl-root = tt-attr-prop.templ-rl-root
       buf_attr-prop.prop-code = tt-attr-prop.prop-code
       buf_attr-prop.upper-prop-code = tt-attr-prop.upper-prop-code
       buf_attr-prop.node-code = tt-attr-prop.node-code
       buf_attr-prop.upper-node-code = tt-attr-prop.upper-node-code no-error .
       .
    end.
    assign
    buf_attr-prop.property-value = tt-attr-prop.property-value.
  end.
  for each buf_attr-prop
  where buf_attr-prop.templ-rl-root = p-templ-rl-root
    and buf_attr-prop.table-name = {&table_dis-card-property}
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    find first tt-attr-prop where
              tt-attr-prop.templ-rl-root = buf_attr-prop.templ-rl-root
          and tt-attr-prop.table-name = p-table-name
          and tt-attr-prop.node-code = buf_attr-prop.node-code  no-error .
    if not available tt-attr-prop then do:
      delete buf_attr-prop.
    end.
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Запись свойств таблицы атриубтов &1&2" +
                          "код &3&2&4"
                          ,p-table-name
                          ,{&new-line}
                          ,p-templ-rl-root
                          ,p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.