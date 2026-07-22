block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ТРиггер на запись строки документа на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/07
Author: Bakhtadze Natalya
Creation date: 01/22/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cd-doc-line.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ТРиггер на запись строки документа на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                                    ,ub.cd-doc-line.obj-type
                                    ,ub.cd-doc-line.obj-code
                                    ,ub.cd-doc-line.pos-type
                                    ,ub.cd-doc-line.doc-type
                                    ,ub.cd-doc-line.doc-code
                                    ,ub.cd-doc-line.line-num
                                          ) " }
{ cmp/trg-def.i  }

do
on error undo, return error
:
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_cd-doc-line}
        , input ( buffer ub.cd-doc-line:handle )
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