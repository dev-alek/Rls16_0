block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsolasd.p $
$Archive: utl/gdsolasd.p $

Утилита заполнения полей gds-obj.first-doc gds-obj.last-doc

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: gdsolasd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/gdsolasd.p $":U .
define variable vss-description as character no-undo initial "Редактирование списка количества товара на объекте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/userobjs.i }

define stream slog .

define variable v-object-ind as integer   no-undo .
define variable v-ind        as integer   no-undo .
define variable v-fix-ind    as integer   no-undo .

do
on error undo, return error
:

  define variable v-rid-list as character no-undo .
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer   no-undo .

  define variable lok as logical   no-undo .

  message
    "Процедура инициализации полей:" skip
    "начало товародвижения по объекту" skip
    "конец товародвижения по объекту" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update lok .

  if lok <> true
  then do:
    return .
  end.

  { gbl/getcntxt.i get }

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
    run process-object in this-procedure
      (input buf_userobjs_temp-user-obj.obj-type /* p-obj-type */
      ,input buf_userobjs_temp-user-obj.obj-code /* p-obj-code */
      ) .
  end.

  message
    "Обработка товаров закончена" skip
    "Всего обработано товаров на объекте" v-ind skip
    "Произведена корректировка товаров на объекте" v-fix-ind skip
    view-as alert-box information .
end.


procedure process-object :

  define input parameter p-obj-type  like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code  like ub.gds-obj.obj-code no-undo .

  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_price-list for ub.price-list .
  define buffer buf_price-doc  for ub.price-doc .

  define buffer update_gds-obj for ub.gds-obj .


  do
  on error undo, return error
  :
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    run waitfram-show in this-procedure
      (input "Инициализация дат начала и конца товародвижения по объекту"
      ).

    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error
    :

      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Объект &1 &2. Обработано товаров &3"
                 ,p-obj-type
                 ,p-obj-code
                 ,v-ind
                 )
          ).
      end.

      define variable v-root-b-code like ub.bar-code.b-code no-undo .

      { gbl/gdsbcode.i
        buf_gds-obj.gds-code
        ?
        v-root-b-code
      }

      find first buf_doc-line no-lock
        where buf_doc-line.obj-type  = buf_gds-obj.obj-type
          and buf_doc-line.obj-code  = buf_gds-obj.obj-code
          and buf_doc-line.artic     = buf_gds-obj.artic
          and buf_doc-line.prod-type = buf_gds-obj.prod-type
          and buf_doc-line.prod-code = buf_gds-obj.prod-code
          and buf_doc-line.status_   = {&fact}
        use-index fact-order
        no-error .
      if available buf_doc-line
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-line.doc-code
          .
        if buf_gds-obj.first-doc = ?
        or buf_gds-obj.first-doc > buf_trn-doc.fact-date
        then do:
          assign
            v-fix-ind = v-fix-ind + 1
          .

          do transaction
          on error undo, return error
          :
            find first update_gds-obj exclusive-lock
              where recid(update_gds-obj) = recid(buf_gds-obj)
              .
            assign
              update_gds-obj.first-doc = buf_trn-doc.fact-date
            .
          end.
        end.
      end.

      find first buf_price-list no-lock
        where buf_price-list.obj-type   = buf_gds-obj.obj-type
          and buf_price-list.obj-code   = buf_gds-obj.obj-code
          and buf_price-list.b-code     = v-root-b-code
          and buf_price-list.price-type = ""
          and buf_price-list.fact-order > 0
        use-index fact-close
        no-error .
      if available buf_price-list
      then do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_price-list.doc-num
          .
        if buf_gds-obj.first-doc = ?
        or buf_gds-obj.first-doc > buf_price-doc.fact-date
        then do:
          assign
            v-fix-ind = v-fix-ind + 1
          .
          do transaction
          on error undo, return error
          :
            find first update_gds-obj exclusive-lock
              where recid(update_gds-obj) = recid(buf_gds-obj)
              .
            assign
              update_gds-obj.first-doc = buf_price-doc.fact-date
            .
          end.
        end.
      end.


      find last buf_doc-line no-lock
        where buf_doc-line.obj-type  = buf_gds-obj.obj-type
          and buf_doc-line.obj-code  = buf_gds-obj.obj-code
          and buf_doc-line.artic     = buf_gds-obj.artic
          and buf_doc-line.prod-type = buf_gds-obj.prod-type
          and buf_doc-line.prod-code = buf_gds-obj.prod-code
          and buf_doc-line.status_   = {&fact}
        use-index fact-order
        no-error .
      if available buf_doc-line
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-line.doc-code
          .
        if buf_gds-obj.last-doc = ?
        or buf_gds-obj.last-doc < buf_trn-doc.fact-date
        then do:
          assign
            v-fix-ind = v-fix-ind + 1
          .

          do transaction
          on error undo, return error
          :
            find first update_gds-obj exclusive-lock
              where recid(update_gds-obj) = recid(buf_gds-obj)
              .
            assign
              update_gds-obj.last-doc = buf_trn-doc.fact-date
            .
          end.
        end.
      end.

      find last buf_price-list no-lock
        where buf_price-list.obj-type   = buf_gds-obj.obj-type
          and buf_price-list.obj-code   = buf_gds-obj.obj-code
          and buf_price-list.b-code     = v-root-b-code
          and buf_price-list.price-type = ""
          and buf_price-list.fact-order > 0
        use-index fact-close
        no-error .
      if available buf_price-list
      then do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_price-list.doc-num
          .
        if buf_gds-obj.last-doc = ?
        or buf_gds-obj.last-doc < buf_price-doc.fact-date
        then do:
          assign
            v-fix-ind = v-fix-ind + 1
          .

          do transaction
          on error undo, return error
          :
            find first update_gds-obj exclusive-lock
              where recid(update_gds-obj) = recid(buf_gds-obj)
              .
            assign
              update_gds-obj.last-doc = buf_price-doc.fact-date
            .
          end.
        end.
      end.

    end.

    run waitfram-hide in this-procedure .

  end.

end procedure. /* process-object */