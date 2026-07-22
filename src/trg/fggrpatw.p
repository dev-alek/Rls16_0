block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибутов группы блюд

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/08/05
Author: Bakhtadze Natalya
Creation date: 08/08/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.fbr-gds-grp-attr OLD oldb.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибутов группы блюд".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
              ,ub.fbr-gds-grp-attr.obj-type
              ,ub.fbr-gds-grp-attr.obj-code
              ,ub.fbr-gds-grp-attr.node-code
              ,ub.fbr-gds-grp-attr.attr-code

              ) " }
{ cmp/trg-def.i }
{ ref/fgrpattr.i }
{ gbl/cur-time.i }
{ trg/fgdsgrph.i fbr-gds-grp-attr-trig oldb ub.fbr-gds-grp-attr }

define variable p-news as logical no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run fbr-grp-attr-news in this-procedure(input ub.fbr-gds-grp-attr.attr-code,
                                          output p-news) no-error.
  if p-news then
  run str/callnews.p
    ( input {&table_fbr-gds-grp-attr}
     ,input (buffer ub.fbr-gds-grp-attr:handle)
    ) .

  if not g#news then do:
    run fbr-gds-grph_write-fbr-gds-grp-attr-trigger  in this-procedure (
                                                                input new(ub.fbr-gds-grp-attr)
                                                               ,input "":U /*p-source-type*/
                                                               ,input "":U /*p-source-ref*/
                                                               ,input (if new(ub.fbr-gds-grp-attr)
                                                                       then integer({&Hn-create})
                                                                       else integer({&hn-update})
                                                                      )
                                                              ).

  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-gds-grp-attr}
        , input ( buffer ub.fbr-gds-grp-attr:handle )
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