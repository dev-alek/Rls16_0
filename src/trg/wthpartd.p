block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление партии МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/10/07
Author: Polina Gridchina
Creation date: 05/10/07

Input:

Output:

*/
TRIGGER PROCEDURE FOR DELETE OF ub.wth-parts.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление партии МЦ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                          ,ub.wth-parts.out-code
                          ,ub.wth-parts.wth-code
                          ,ub.wth-parts.w-p-code
                          ,ub.wth-parts.par-code
                          )"  }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define variable rid AS RECID NO-UNDO.
define variable v-mess as character no-undo .
define variable v-ZoneList  as character    no-undo.
DEF BUFFER buf-doc  FOR ub.wth-doc.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

/*    if ub.wth-parts.stts = 1 then do:
      UNDO MAIN-block, return error
        "Архивная партия не может быть удалена."   .
    end.   */
    /*Если партия по документу, то проверяется статус документа*/
    if lookup(wth-parts.out-code,{&WDEDT_List-Zone}) = 0 then do:
      FIND buf-doc NO-LOCK WHERE buf-doc.doc-code = ub.wth-parts.out-code NO-ERROR.
      if available buf-doc
      and buf-doc.status_ = {&fact}
      and not buf-doc.is-del = yes
      then do:
        undo Main-block, return error 'Невозможно удалить партию документа в статусе ' + buf-doc.status_.
      end.
    end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_arh-wth-cli-doc}
        , input ( buffer ub.arh-wth-cli-doc:handle )
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