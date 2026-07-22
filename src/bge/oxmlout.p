block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oxmlout.p $
$Archive: bge/oxmlout.p $

Ручной экспорт в файл OpenXML

Автор: Хныкин Павел Андреевич
Дата создания: 08/16/06
Author: Pavel Khnykin
Creation date: 08/16/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-param              as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlout.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlout.p $":U .
define variable vss-description as character no-undo init "Экспорт в файл OpenXML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/oxml-def.i new }

define variable v-cur-db-num    as integer      no-undo.
define variable v-err-code as integer no-undo .
define variable v-message as character no-undo .

do
on error undo, return error
:
  run bge/oxml-ini.p no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка инициализации переменных для системы OpenXML" skip
      return-value
      view-as alert-box error.
    undo, return error.
  end.
    { gbl/curdbnum.i
        v-cur-db-num
    }

    run write-to-log ( substitute( "Подготовка новых пакетов." ) ).

    run bge/cnewxpck.p (
                      input ""
                    , output v-err-code
    ) no-error .
    if error-status:error
    then do:
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов OpenXML &2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                  )
                      ) .
    end.
    else do:
      assign
        v-message = return-value
      .
      if v-message <> "":U then do:
        run write-to-log ( substitute( "&1", v-message ) ).
      end.
      run write-to-log ( substitute( "Завершена подготовка новых пакетов." ) ).
    end.


    run str/diallog.w (
          input p-mainmenu-handle
        , input this-procedure
        , input "bge/oxmloutx.p":U
        , input substitute("all-unconf,&1", v-cur-db-num )
        , input no
        , input "&Стоп"
        , input "Выгрузка Open XML"
    ).
end.