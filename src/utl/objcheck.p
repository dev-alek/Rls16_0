block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: objcheck.p $
$Archive: utl/objcheck.p $

Проверка целостности всех товаров на объекте

Автор: Чернова Светлана Александровна
Дата создания: 06/23/08
Author: Svetlana Chernova
Creation date: 06/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: objcheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/objcheck.p $":U .
define variable vss-description as character no-undo init "Проверка целостности всех товаров на объекте".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-ind       as integer no-undo .
define variable v-ind-error as integer no-undo .
define variable v-today     as date    no-undo.
define variable v-time      as integer no-undo.

/* для показа процесса закрытия документа */
def frame a
  v-ind       label "Просмотрено товаров" skip
  v-ind-error label "Ошибок" skip
  ub.gds-obj.obj-type label "Объект"
  ub.gds-obj.obj-code no-label  skip
  ub.gds-obj.artic label "Артикул"
  ub.gds-obj.prod-type no-label
  ub.gds-obj.prod-code no-label  skip
  with view-as dialog-box side-labels three-d
  title "Проверка товаров"
  .
view frame a .

do
on error undo, return error return-value
:
  for each ub.gds-obj no-lock
    where ub.gds-obj.obj-type = p-obj-type
      and ub.gds-obj.obj-code = p-obj-code
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      display
        v-ind
        v-ind-error
        ub.gds-obj.obj-type
        ub.gds-obj.obj-code
        ub.gds-obj.artic
        ub.gds-obj.prod-type
        ub.gds-obj.prod-code
        with frame a .
    end.

    /* проверяем целостность товара */
    { gbl/gdscheck.i
      ub.gds-obj.obj-type
      ub.gds-obj.obj-code
      ub.gds-obj.artic
      ub.gds-obj.prod-type
      ub.gds-obj.prod-code
      ?
      "'return':u"
      no-error
    }
    if error-status :error
    then do:
      output to gdscheck.txt append .
      export return-value .
      output close .

      assign
        v-ind-error = v-ind-error + 1
      .

      output to gdscheck.err append .
      export gds-obj.obj-type gds-obj.obj-code gds-obj.artic gds-obj.prod-type gds-obj.prod-code .
      output close .
    end.
  end.


  output to objcheck.txt append .
  export "Проверен объект" p-obj-type p-obj-code .
  run cur-time in this-procedure ( output v-today
                                , output v-time
                                ).
  export "Дата" v-today "Время" string(v-time, "hh:mm") .
  export "Просмотрено товаров" v-ind .
  export "Найдено ошибок" v-ind-error .
  export " ".
  output close .

  /* возвращаем общее количество ошибок */
  return string(v-ind-error) .
end.