block-level on error undo, throw.
DEFINE INPUT PARAMETER pcase as integer no-undo.
DEFINE INPUT PARAMETER g-cond as char no-undo.
DEFINE INPUT PARAMETER g-list as char no-undo.
DEFINE INPUT PARAMETER g-stat as char no-undo.
DEFINE INPUT PARAMETER flt-rec as recid no-undo.
DEFINE OUTPUT PARAMETER loc#log as logical no-undo.
DEFINE OUTPUT PARAMETER loc-contin as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsrepos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdsrepos.p $":U .
define variable vss-description as character no-undo init "mess для Справочник товаров.".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE VARIABLE choice as integer no-undo.
CASE pcase:
  WHEN 1 then do:
    loc#log = yes.
    if flt-rec <> ? then do:
      loc#log = no.
      message "Поиск ПО ВСЕМ товарам." skip(1)
      "ТОВАР НАЙДЕН." skip (2)
      "Но фильтр по кнопке <<ФИЛЬТР>> : включен"
      " - поэтому найденный товар не виден." skip (2)
      "Выключите фильтр"
      view-as alert-box Warning.
    end.
    else do:
      message "Поиск ПО ВСЕМ товарам." skip(1)
      "ТОВАР НАЙДЕН." skip (2)
      "Но сейчас включено : " skip
      "Справочник : " g-list skip
      "Статус : " g-stat skip
      "Фильтр Все/Объект/Факт/Свободно: " g-cond skip
      " - поэтому найденный товар не виден." skip (2)
      "Переключить" skip
      "Справочник, Статус и Фильтр в положение 'Все' ?"
      view-as alert-box question buttons OK-Cancel update loc#log.
    end.
  END.
  WHEN 2 then do:
    loc-contin = yes.
    if flt-rec <> ? then do:
      loc-contin = no.
      message "Поиск ПО ВСЕМ товарам." skip(1)
      "ТОВАР НАЙДЕН." skip (2)
      "Но фильтр по кнопке <<ФИЛЬТР>> : включен" skip
      " - поэтому найденный товар не виден." skip (2)
      "Выключите фильтр"
      view-as alert-box Warning.
      loc-contin = ?.
    end.
    else do:
      run gbl/d-askw.w (input "Поиск ПО ВСЕМ товарам",
                   input ("ТОВАР НАЙДЕН ." + chr(10) + chr(10) + "Но сейчас включено :" + chr(10) +
                          "Справочник : " + g-list + chr(10) + "Статус : " + g-stat +
                          chr(10) + "Фильтр : " + g-cond + chr(10) + " - поэтому найденный товар не виден."
                          ),
                   input "|",
                   input ("Продолжать искать|Переключить Справочник, Статус и Фильтр в положение ВСЕ|Отменить"),
                   Input "||",
                   input 2,
                   input 3,
                   output choice).
      if choice = 1 then loc-contin = yes.
      else if choice = 2 then loc-contin = no.
      else loc-contin = ?.
    end.
  END.
END CASE.
