block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: allgdsat.p $
$Archive: utl/allgdsat.p $

Инициализация атрибутов товара на объекте

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $".
define variable vss-author      as character no-undo initial "$Author: expertek $".
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $".
define variable vss-workfile    as character no-undo initial "$Workfile: allgdsat.p $".
define variable vss-archive     as character no-undo initial "$Archive: utl/allgdsat.p $".
define variable vss-description as character no-undo initial "Инициализация атрибутов товара на объекте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }


do
on error undo, return error return-value
:
  define variable v-total-ind as integer   no-undo .

  define variable v-num as integer no-undo .
  { gbl/getcntxt.i get }
  run gbl/d-askw.w
    (input "Вопрос"
    ,input vss-description + {&new-line}
        + "Результат работы программы записывается в файлы:" + {&new-line} + {&new-line}
        + "allgdsoat.txt - значения атрибутов," + {&new-line}
        + "allgdsoat.obj - список обработанный объектов."
    ,input "|^"
    ,input "Все^confirm|Выбрать|Отмена"
    ,input "Все объекты|"
        + "Выбрать объекты|"
        + "Не запускать утилиту"
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num :
    when 1
    then do:
      for each ub.db no-lock
      ,each ub.clients no-lock
        where ub.clients.db-num = ub.db.db-num
      on error undo, return error return-value
      :
        run initialize-gds-obj in this-procedure
          (input clients.obj-type
          ,input clients.obj-code
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
          "Объект не выбран"
          view-as alert-box information .
        return .
      end.

      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

      for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
        run initialize-gds-obj in this-procedure
          (input buf_userobjs_temp-user-obj.obj-type
          ,input buf_userobjs_temp-user-obj.obj-code
          ).
      end.
    end.
  end.

  if v-total-ind <> 0
  then do:
    message
      "Инициализация атрибутов закончена" skip
      "Обработано объектов" v-total-ind skip
      view-as alert-box information .
  end.
end.


procedure initialize-gds-obj :
  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  output to allgdsoat.obj append .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  export p-obj-type p-obj-code string(v-today) string(v-time, "HH:MM") .
  output close .

  assign
    v-total-ind = v-total-ind + 1
  .

  run waitfram-show in this-procedure
    (input substitute("Инициализация атрибута <Переоценка включена> на объекте &1 &2"
                     ,p-obj-type
                     ,p-obj-code
                     )
    ) .

  run initialise-ov-on
    (input p-obj-type
    ,input p-obj-code
    ).

  run waitfram-show in this-procedure
    (input substitute("Инициализация атрибута <Инвентаризация включена> на объекте &1 &2"
                     ,p-obj-type
                     ,p-obj-code
                     )
    ) .

  run initialise-inv-on
    (input p-obj-type
    ,input p-obj-code
    ).

  run waitfram-hide in this-procedure .

end procedure. /* initialize-gds-obj */


procedure initialise-ov-on :
  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .


  /* очистка информации о товарах, на которые включена переоценка */
  /* см. код программы gdsobjat.i */
  for each ub.gds-obj exclusive-lock
    where ub.gds-obj.obj-type = p-obj-type
      and ub.gds-obj.obj-code = p-obj-code
      and ub.gds-obj.ov-on    = true
  :
    assign
      ub.gds-obj.ov-on = false
    .
  end.

  for each ub.price-doc exclusive-lock
    where price-doc.status_  = {&permitted}
      and price-doc.obj-type = p-obj-type
      and price-doc.obj-code = p-obj-code
  :
    for each price-list
      where price-list.doc-num = price-doc.doc-num
    :
      output to allgdsoat.txt append .
      export
        ub.price-list.obj-type
        ub.price-list.obj-code
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        "ov-on"
        .
      output close .

      define variable l-ov-on as logical no-undo .
      { gbl/gdsobjat.i
        ub.price-list.obj-type
        ub.price-list.obj-code
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        "'ov-on=true':u"
        l-ov-on
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания признака товара на объекте" skip
          "obj-type " ub.price-list.obj-type  skip
          "obj-code " ub.price-list.obj-code  skip
          "artic    " ub.price-list.artic     skip
          "prod-type" ub.price-list.prod-type skip
          "prod-code" ub.price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        /* undo, return no-apply . */
      end.
    end.
  end.

end procedure. /* initialise-ov-on */
procedure initialise-inv-on :
  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .


  /* очистка информации о товарах, которые находятся в инвентаризации */
  /* см. код программы gdsobjat.i */
  for each ub.gds-obj exclusive-lock
    where ub.gds-obj.obj-type = p-obj-type
      and ub.gds-obj.obj-code = p-obj-code
      and ub.gds-obj.inv-on    = true
  :
    assign
      ub.gds-obj.inv-on = false
    .
  end.

  for each ub.trn-doc exclusive-lock
    where ub.trn-doc.obj-type     = p-obj-type
      and ub.trn-doc.obj-code     = p-obj-code
      and ub.trn-doc.internal     = no
      and ub.trn-doc.doc-type     = {&inventory}
      and ub.trn-doc.ext-doc-type = {&TDEDT_Inv}
      and ub.trn-doc.status_      = {&permitted}
      and ub.trn-doc.flag_        = true
      or  ub.trn-doc.obj-type     = p-obj-type
      and ub.trn-doc.obj-code     = p-obj-code
      and ub.trn-doc.internal     = no
      and ub.trn-doc.doc-type     = {&inventory}
      and ub.trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
      and ub.trn-doc.status_      = {&wayb}
      and ub.trn-doc.flag_        = no
      or  ub.trn-doc.obj-type     = p-obj-type
      and ub.trn-doc.obj-code     = p-obj-code
      and ub.trn-doc.internal     = no
      and ub.trn-doc.doc-type     = {&inventory}
      and ub.trn-doc.ext-doc-type = {&TDEDT_Peresort}
      and ub.trn-doc.status_      = {&wayb}
      and ub.trn-doc.flag_        = no

  :
    for each ub.doc-line
      where doc-line.doc-code = trn-doc.doc-code
    :
      output to allgdsoat.txt append .
      export
        ub.doc-line.obj-type
        ub.doc-line.obj-code
        ub.doc-line.artic
        ub.doc-line.prod-type
        ub.doc-line.prod-code
        "inv-on"
        .
      output close .

      define variable l-inv-on as logical no-undo .
      { gbl/gdsobjat.i
        ub.doc-line.obj-type
        ub.doc-line.obj-code
        ub.doc-line.artic
        ub.doc-line.prod-type
        ub.doc-line.prod-code
        "'inv-on=true':u"
        l-inv-on
        no-error
      }
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания признака товара на объекте" skip
          "obj-type " ub.doc-line.obj-type  skip
          "obj-code " ub.doc-line.obj-code  skip
          "artic    " ub.doc-line.artic     skip
          "prod-type" ub.doc-line.prod-type skip
          "prod-code" ub.doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        /* undo, return no-apply . */
      end.
    end.
  end.


end procedure. /* initialise-inv-on */