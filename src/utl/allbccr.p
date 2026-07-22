block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: allbccr.p $
$Archive: utl/allbccr.p $

Программа создания бар-кодов для всех партий свободной зоны товаров, которые продаются по партиям

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/20/00

*/

define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter p-install      as logical   no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: allbccr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/allbccr.p $":U .
define variable vss-description as character no-undo init "Программа создания бар-кодов для всех партий свободной зоны товаров, которые продаются по партиям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/userobjs.i }

run init-temphost .

define variable v-num as integer no-undo .

{ gbl/getcntxt.i get }
if p-install
then do:
  assign
    v-num = 1
  .
end.
else do:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Создание бар-кодов для партий товаров," + {&new-line}
      + "Которые продаются по партиям"
    ,input "|^"
    ,input "Все объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).
end.


case v-num :
  when 1
  then do:
    for each temp-obj
    :
      run process-object in this-procedure
        (input temp-obj.obj-type
        ,input temp-obj.obj-code
        ).
    end.
  end.
  when 2
  then do:
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объекты не выбраны"
        view-as alert-box information .
      return .
    end.

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run process-object in this-procedure
        (input buf_userobjs_temp-user-obj.obj-type
        ,input buf_userobjs_temp-user-obj.obj-code
        ).
    end.
  end.
  when 3
  then do:
    /* отмена */
    return .
  end.
end case .


if p-install = false
then do:
  message
    "Создание бар-кодов партий закончено" skip
    view-as alert-box information .
end.

return .


procedure process-object :

  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  output to allbccr.txt append .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  export
    string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
    p-obj-type skip
    p-obj-code skip
    .
  output close .

  if p-install = false
  then do:
    run waitfram-show in this-procedure
      (input "Объект " + string(p-obj-type) + " " + string(p-obj-code)
      ).
  end.

  define variable v-ind as integer   no-undo .

  for each ub.gds-obj no-lock
    where ub.gds-obj.obj-type = p-obj-type
      and ub.gds-obj.obj-code = p-obj-code
  :

    if p-install = false
    then do:
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input "Объект " + string(p-obj-type) + " " + string(p-obj-code) + ". "
          + "Обработано " + string(v-ind) + ". "
          ).
      end.
    end.

    if ub.gds-obj.cash-parts = true
    then do:
      run str/gdsbccr.p
        (input gds-obj.obj-type
        ,input gds-obj.obj-code
        ,input gds-obj.artic
        ,input gds-obj.prod-type
        ,input gds-obj.prod-code
        ).
    end.
  end.

  if p-install = false
  then do:
    run waitfram-hide in this-procedure .
  end.


end procedure. /* process-object */