block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы истории атрибутов внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 02/12/05
Author: Pavel Khnykin
Creation date: 02/12/05

*/

trigger procedure for write of ub.c-ext-artic-attr new buffer new-c-ext-artic-attr old buffer old-c-ext-artic-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                        , new-c-ext-artic-attr.cli-type
                        , new-c-ext-artic-attr.cli-code
                        , new-c-ext-artic-attr.gds-code
                        , new-c-ext-artic-attr.attr-code
                        , new-c-ext-artic-attr.chip-num
                        ) "
}
{ cmp/trg-def.i  }

main-block:
do on error  undo main-block , return error return-value
   on endkey undo main-block , return error return-value
   on stop   undo main-block , return error return-value
   :
   run str/callnews.p
        ( input "c-ext-artic-attr"
        , input ( buffer new-c-ext-artic-attr :handle)
        ) no-error .
   if error-status:error then do:
     if error-status :get-message(1) <> "" then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры callnews.p" skip
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error .
     end.
     undo main-block, return error return-value.
   end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-ext-artic-attr}
        , input ( buffer new-c-ext-artic-attr:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.