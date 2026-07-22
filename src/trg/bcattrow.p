block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибутов бар-кода по обьъектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/02/09
Author: Bakhtadze Natalya
Creation date: 06/02/09

*/

TRIGGER PROCEDURE FOR WRITE OF ub.bar-code-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибутов бар-кода по обьъектам".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u~
                              ,ub.bar-code-obj-attr.obj-type~
                              ,ub.bar-code-obj-attr.obj-code~
                              ,ub.bar-code-obj-attr.b-code~
                              ,ub.bar-code-obj-attr.attr-code~
                              )" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/check-bc.i }
{ ref/bc-oattr.i }
{ trg/bcattroh.i trig ub.bar-code-obj-attr ub.bar-code-obj-attr }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news then do:
    run check-use-bar-code in this-procedure ( input ub.bar-code-obj-attr.b-code) no-error.
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
  end.
  if not g#news
  and not g#db-num = 0 then do:
    define variable attr-type as character no-undo . /*тип атрибута*/
    define variable attr-format as character no-undo .  /* формат атрибута*/
    define variable attr-label as character no-undo .         /*лабел атрибута */
    define variable attr-range as integer no-undo .  /*область действия*/
    define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
    define variable attr-output-display as logical no-undo .  /*виден в броусе*/
    define variable attr-other as char no-undo .
    define variable v-obj-db-num as integer no-undo .

    run bc-oattr_name (
    input  ub.bar-code-obj-attr.attr-code
    ,output attr-type
    ,output attr-format
    ,output attr-label
    ,output attr-range
    ,output attr-user-can-edit
    ,output attr-output-display
    ,output attr-other
    ) .
    if attr-range = integer({&object-int}) then do:
      { gbl/objdbnum.i ub.bar-code-obj-attr.obj-type ub.bar-code-obj-attr.obj-code v-obj-db-num }
      if v-obj-db-num <> g#db-num then do:
         undo main-block, return error substitute("Нельзя заводить атрибут бар-кода <&1>, в контексте объекта в чужой УБД", ub.bar-code-obj-attr.attr-code).
      end.
    end.
  end.
  run str/callnews.p
    (input {&table_bar-code-obj-attr}
    ,input (buffer ub.bar-code-obj-attr:handle)
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно маршрутизировать bar-code-attr для отправки в новости" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo main-block, return error return-value .
  end.
  run bc-attrh_write-bar-code-obj-attr-trigger in this-procedure  (
                                        input new(ub.bar-code-obj-attr)
                                      ,input integer({&hn-update})
                                      ,input (if g#news
                                              then {&hn-source-db}
                                              else (if g#esys
                                                    then {&hn-source-esys}
                                                    else "":U
                                                    )
                                              )
                                      ,input (if g#news
                                              then string(g#news-source-db)
                                              else (if g#esys
                                                    then string(g#esys-source-esys)
                                                    else  "":U)
                                              )
                                    ) .

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_bar-code-obj-attr}
        , input ( buffer ub.bar-code-obj-attr:handle )
    ) no-error.
    if error-status :error
    then do:
        undo main-block, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.