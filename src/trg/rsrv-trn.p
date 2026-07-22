block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирование по партиям

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

Должна вызываться в trn-docw.p при следующих условиях:
  if g#news
  and ub.trn-doc.doc-type <> {&income}
  and ( ( ub.trn-doc.status_ = {&permitted}
          and not(g#obj-active)
        )
        or
        ( ub.trn-doc.status_ = {&fact}
          and g#obj-active
        )
      )
        or
        ( lookup(ub.trn-doc.doc-type, {&expense_write-off_return_inventory}) > 0
          and ub.trn-doc.status_ = {&fact}
          and g#obj-active
        )
      )
  then do:
    run trg/rsrv-trn.p (input ub.trn-doc.doc-code).
  end.
*/
using ibs.th.str.alcohol.*.

define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Резервирование по партиям".

define variable chg-qnty      as   decimal no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/partrqst.i }
{ str/lib-trn.i  }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }

define variable unrv-code as character no-undo .
define buffer buf_parts for ub.parts .

/* свойства товара */
define variable l-goods-twounit as logical no-undo .

main-block :
do transaction
on error undo, return error
:
  find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = p-doc-code
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  for each ub.doc-line no-lock
    where ub.doc-line.doc-code = p-doc-code
  on error undo main-block, return error
  :
    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      no-error .
    if not available ub.goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    /* определяется, что товар учитывается в двух единицах измерения */
    { gbl/gdsat.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      "'twounit=request':u"
      l-goods-twounit
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.goods.gds-type = {&gds-goods} then do:
      /** востанавливаем картину с parts и архивами (резерв) при работе новостей
          (аналог работы doc-lina.p и gds-dtla.p) **/
      for each ub.parts
        where ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.prod-type = ub.doc-line.prod-type
            /* Старый возврат не востанавливается */
          and ub.parts.in-code <> ub.parts.out-code
      on error undo main-block, return error
      :
        if can-do({&expense_write-off},ub.trn-doc.doc-type)
        or (ub.trn-doc.doc-type = {&inventory}
            and ub.parts.fact-qnty < 0)
        then do:
          assign
            unrv-code = {&free-code}
          .
        end.
        else do:
          assign
            unrv-code = {&output-code}
          .
        end.

        if /* not(ub.trn-doc.doc-type = {&return}
               and ub.trn-doc.internal = yes
              )   /* sv */

        and */ ub.parts.in-code <> ub.parts.out-code
        and ub.parts.in-code <> {&oldret-code} then do:
          /* todo - удалить ссылка на препроцессинг oldret-code
                    это был застарелый славиков возврат
           */

          /* Если это не застарелый возврат и не внутренний */
          run partcopy in this-procedure
            (input  true      /* p-free-output-copy */
            ,input  unrv-code /* p-out-code         */
            ,buffer ub.parts  /* buf_orig_parts     */
            ,buffer buf_parts /* buf_parts          */
            ,input ""
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании партии" skip
              "Объект" ub.parts.obj-type ub.parts.obj-code skip
              "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
              "Партия" ub.parts.in-code ub.parts.part-code skip
              "Резерв" unrv-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty - abs(ub.parts.qnty)
            buf_parts.fact-qnty = buf_parts.qnty
          .
          if l-goods-twounit = true then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty - abs(ub.parts.cli-qnty)
            .
          end.

          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0 then do:
            if l-goods-twounit = true then do:
              if buf_parts.cli-qnty <> 0 then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при удалении партии" skip
                  "Объект" buf_parts.obj-type buf_parts.obj-code skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
      end.
    end. /* if ub.goods.gds-type = {&gds-goods}  */
  end.
end.