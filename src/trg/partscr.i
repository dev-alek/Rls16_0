/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура создания партии

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Параметры:
p-action      определяет реакцию программы в случае,
                если необходимо запросить цену у пользовател
                prompt=enable          задать вопрос о цене
                                       r s r v - d t l . p
                prompt=disable-reject  не задавать вопросов, не создавать партию
                                       r s r v - d t l . p
                prompt=disable-create  не задавать вопросов, создать партию
                                       p a r t s - f . w

check-right
                check-right=true      проверять права на создание партии
                check-right=false     не проверять права на создание партии

/* Используется lineattr */

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

&glob v-partscr-action-chg  "chg":u
&glob v-partscr-action-exit "exit":u
&glob v-partscr-action-quit "quit":u

procedure partscr :
  define input  parameter parparentproc      as widget-handle no-undo.
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-supp-type        as character no-undo .
  define input  parameter p-supp-code        as integer   no-undo .
  define input  parameter p-part-code        as character no-undo .
  define input  parameter p-cst-code         as character no-undo .
  define input  parameter p-ps               as character no-undo .
  define input  parameter p-dop              as character no-undo .
  define input  parameter p-part-reserv-base as decimal   no-undo .
  define input  parameter p-part-reserv-rubl as decimal   no-undo .
  define input  parameter p-vat-type         as character no-undo .
  define input  parameter p-vat-pc           as decimal   no-undo .
  define input  parameter p-slt-type         as character no-undo .
  define input  parameter p-slt-pc           as decimal   no-undo .
  define input  parameter p-change-qnty      as decimal   no-undo .
  define input  parameter p-action           as character no-undo .
  define input  parameter p-cli-qnty         as decimal   no-undo .
  define input  parameter p-last-date        as date      no-undo .
  define input  parameter p-hold-date        as date      no-undo .
  define input  parameter p-pl-code          as integer   no-undo .
  define parameter buffer buf_doc-line       for ub.doc-line .
  define parameter buffer buf_parts          for ub.parts .

  define variable vss-description as character no-undo initial "$Workfile$ $Revision$ Процедура создания партии".

  define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
  define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable v-price-base               like ub.doc-line.price-base no-undo.
  define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable l-fact-qnty              as logical   no-undo .
  define variable v-action                 as character no-undo .
  define variable l-need-create-old-return as logical   no-undo init false .
  define variable l-create-old-return      as logical   no-undo init false .
  
  define variable v-izlcstpr        as character no-undo .
  
  /* свойства товара */
  define variable l-goods-serial           as logical   no-undo .
  define variable l-goods-twounit          as logical   no-undo .
  define variable l-reserv-pl-code         as logical   no-undo .
  define variable l-goods-bottle           as logical   no-undo .

  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .

  define variable v-prompt-price       as character no-undo .
  define variable v-check-right        as logical   no-undo .
  define variable v-ind                as integer   no-undo .
  define variable v-num-entries-action as integer   no-undo .
  define variable v-option             as character no-undo .
  define variable v-type as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-check-right = true
    .

    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-supp-type = ?
    or p-supp-type = ''
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-type имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-supp-code = ?
    or p-supp-code = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-part-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-cst-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-cst-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-ps = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-ps имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-part-reserv-base = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-part-reserv-base < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет отрицательное значение" skip
        "p-part-reserv-base" p-part-reserv-base skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-part-reserv-rubl = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-part-reserv-rubl < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет отрицательное значение" skip
        "p-part-reserv-rubl" p-part-reserv-rubl skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-change-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-change-qnty имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-pl-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-pl-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      v-num-entries-action = num-entries(p-action, {&comma-char})
    .

    do v-ind = 1 to v-num-entries-action
    :
      assign
        v-option = entry(v-ind, p-action, {&comma-char})
      .
      if num-entries(v-option, '=':u) <> 2
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Количество входений в опцию отлично от двух"
          "p-action" p-action skip
          "v-option" v-option skip
          view-as alert-box error .
        undo, return error .
      end.

      case entry(1, v-option, '=':u)
      :
        when 'prompt':u
        then do:
          assign
            v-prompt-price = v-option
          .
        end.
        when 'check-right':u
        then do:
          assign
            v-check-right = logical(entry(2, v-option, '=':u))
          .
        end.
        when 'izlcstpr':u
        then do :
            assign
                v-izlcstpr = v-option
            .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Неизвестная опция"
            "p-action" p-action skip
            "v-option" v-option skip
            view-as alert-box error .
          undo, return error .
        end.
      end case .
    end.

    if lookup(v-prompt-price, 'prompt=enable,prompt=disable-reject,prompt=disable-create':u ) > 0
    then do:
      /* параметр правильный */
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "v-prompt-price" v-prompt-price skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      .

/* Вытащим параметры */
define variable v-negparts as character no-undo .
define variable v-negmanuf as character no-undo .
define variable v-prcshrs0 as character no-undo .
define variable v-prcshrs1 as character no-undo .
define variable v-prdocrs0 as character no-undo .
define variable v-prdocrs1 as character no-undo .

{ gbl/getsect.i run buf_doc-line.obj-type buf_doc-line.obj-code  {&attr-rezerv-obj} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'negparts'  then  v-negparts  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'negmanuf'  then  v-negmanuf  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs0'  then  v-prcshrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs1'  then  v-prcshrs1  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs0'  then  v-prdocrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs1'  then  v-prdocrs1  = thbjattr_thbj-attr.property-value-character.
end.

    if p-cst-code = ?
    then do:
      /* если код ГТД не задан, то он берется из накладной */
      assign
        p-cst-code = (if buf_trn-doc.cst-code <> ?
                      then buf_trn-doc.cst-code
                      else "")
      .
    end.

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/gdsat.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'serial=request':u"
      l-goods-serial
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'serial=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsat.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'twounit=request':u"
      l-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsat.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'bottle=request':u"
      l-goods-bottle
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'bottle=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if  buf_trn-doc.doc-type = {&income}
    and buf_trn-doc.internal = false
    then do:
      if buf_trn-doc.flag_ = no
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        assign
          l-fact-qnty = true
        .
      end.
    end.
    else do:
      define variable conf-par as character no-undo .
      define variable par-type as character no-undo .
      define variable lok      as logical no-undo .

      /* проверяем возможность создания партий */
      /* если товар резервируется по складским местам, то партию создавать нельзя */
      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'place-rsrv=request'"
        l-reserv-pl-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара на объекте" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "place-rsrv=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if l-reserv-pl-code
      then do:
        return
          "Товар на объекте резервируется по складским местам" + {&new-line}
          + "Создание партий запрещено " + {&new-line}
          + "Объект " + string(buf_doc-line.obj-type)
              + " " + string(buf_doc-line.obj-code) + {&new-line}
          + "Артикул " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code) + {&new-line}
          .
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}
      then do:
        /* Для производства, */
        /* внешнего возврата, */
        /* инвентаризации */
        /* разрешено создавать партии независимо от параметра negparts */
      end.
      else do:
        /* возможные значения:
          disable       - запрет порождения отрицательных партий,
          пусто         - отрицательные партии можно порождать
          */

        conf-par  =  v-negparts .

        if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
        then do:
          /* Для внешнего возврата, */
          /* инвентаризации */
          /* разрешено создавать партии старого возврата */
          /* независимо от параметра negparts */
          /* и от признака товара negative-rest */
          if conf-par = "disable"
          or buf_goods.negative-rest = false
          then do:
            if v-prompt-price = 'prompt=enable':u and v-izlcstpr <> 'izlcstpr=enable':u
            then do:
              /* должны вызвать интерфейс ручного редактирования партий */
              /* только в случае если разрешено обращение к пользователю */
              assign
                l-need-create-old-return = true
              .
            end.
          end.
        end.
        else do:
          if conf-par = "disable"
          then do:
            return
              "Порождение отрицательных партий для объекта "
              + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
              + " запрещено (negparts)"
              .
          end.
          if buf_goods.negative-rest = false
          then do:
            /* для товара с отрицательными остатками запрешено и порождение */
            /* отрицательных партий */
            return
              "Для товара " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code)
              + " запрещены отрицательные остатки"
              .
          end.
        end.
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
      /* or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
      or (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and buf_trn-doc.hold-doc-code-child <> "")
      */
      then do:
        return
          "Недопустимо создавать порожденные партии для данного типа документа"
          .
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Prvo}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
      then do:

        /*-*/
        conf-par = v-negmanuf.
        if conf-par = "disable"
        then do:
          return
            "Для документа производства порождение отрицательных партий для объекта "
            + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
            + " запрещено (negmanuf)"
            .
        end.
      end.


      define variable v-reason as character no-undo .
      run partscr_check-valid-supp in this-procedure
        (input  p-supp-type
        ,input  p-supp-code
        ,input  { trg/partsprm.i "supp-type" "buf_trn-doc." }
        ,input  { trg/partsprm.i "supp-code" "buf_trn-doc." }
        ,input  buf_trn-doc.ext-doc-type
        ,output l-create-old-return
        ,output v-reason
        ).
      if v-reason <> ""
      then do:
        return
          v-reason
          .
      end.

      if l-goods-serial = true
      then do:
        if not(buf_trn-doc.doc-type = {&income}
              and buf_trn-doc.internal = false
              and v-prompt-price = 'prompt=disable-create':u
              )
        then do:
          return
            "Порождение партий серийного товара допустимо только во внешнем приходе в интерфейсе партий."
            .
        end.
      end.

      if l-goods-twounit = true
      then do:
        if l-create-old-return
        then do:
          if l-create-old-return
          then do:
            /* для партии старого возврата клиентское количество равно 1 */
            assign
              p-cli-qnty = 1
            .
          end.
        end.
        else do:
          return
            "Для товара с двумя единицами измерения допустимо создание партий во внешнем приходе или партий старого возврата"
            .
        end.
      end.



      if buf_trn-doc.doc-type = {&inventory}
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        if buf_trn-doc.doc-type = {&income}
        and buf_trn-doc.internal = true
        and buf_trn-doc.discnt-type = {&manufactured}
        then do:
          /* внутренний приход по производству */
          assign
            l-fact-qnty = false
          .
        end.
        else do:
          if buf_trn-doc.status_ = {&permitted}
          or (buf_trn-doc.doc-type = {&income}
              and buf_trn-doc.internal = true
            )
          then do:
            assign
              l-fact-qnty = true
            .
          end.
          else do:
            assign
              l-fact-qnty = false
            .
          end.
        end.
      end.
    end.

    find buf_parts
      where buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.in-code   = buf_doc-line.doc-code
        and buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.part-code = p-part-code
      no-error.
    if not available buf_parts
    then do:

      assign
        v-action = ""
      .

      if  ( buf_trn-doc.doc-type = {&income}
            and buf_trn-doc.internal = false
          )
      or  ( buf_trn-doc.doc-type = {&income}
            and buf_trn-doc.internal = true
            and buf_trn-doc.discnt-type = {&manufactured}
          )
      then do:
        /* Для внешнего прихода и прихода по производству
          просто создаем заявленные партии
        */
        assign
          v-action = {&v-partscr-action-exit}
        .
      end.
      else do:
        if v-check-right = true
        then do:
          { gbl/chk-actg.i
            p-db-num
            p-user-id
            {&action-head-code-main}
            'actn_parts_createneg':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_doc-line.obj-type
            buf_doc-line.obj-code
            0
            0
            0
            true
            lok
          }
          if lok <> true
          then do:
            return "Отсутствуют права на создание порожденных партий" .
          end.
        end.

        if l-need-create-old-return
        or l-create-old-return
        then do:
          /* будем вызывать интерфейс ручного редактирования партий */
          /* или уже создается партия старого возврата из интерфейса */
        end.
        else do:
          define variable v-parameter-name as character no-undo .
          define variable v-document-name  as character no-undo .

          if p-part-reserv-base = 0
          or p-part-reserv-rubl = 0
          then do:
            run trg/partplas.p
              (input  buf_doc-line.obj-type  /* p-obj-type        */
              ,input  buf_doc-line.obj-code  /* p-obj-code        */
              ,input  buf_goods.gds-code     /* p-gds-code        */
              ,input  buf_trn-doc.base-rate  /* p-base-rate       */
              ,input  buf_trn-doc.base-scale /* p-base-scale      */
              ,output p-part-reserv-base     /* p-last-price-base */
              ,output p-part-reserv-rubl     /* p-last-price-rubl */
              ) .
          end.

          if buf_trn-doc.discnt-type = {&cash-desk}
          then do:
            assign
              v-action         = {&v-partscr-action-exit}
              v-document-name  = "продажи"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prcshrs0':U
                conf-par  = v-prcshrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prcshrs1':U
                conf-par  = v-prcshrs1
              .
            end.
          end.
          else do:
            assign
              v-action         = ""
              v-document-name  = "документа"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prdocrs0':U
                conf-par  = v-prdocrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prdocrs1':U
                conf-par  = v-prdocrs1
              .
            end.
          end.

          if conf-par = ""
          or conf-par = ?
          then do:
            /* по умолчанию запрещаем порождение партий */
            assign
              conf-par = "disable"
            .
          end.
          case conf-par :
            when "disable"
            then do:
              return
                "Для " + v-document-name + " " + buf_doc-line.doc-code + " порождение отрицательных партий для объекта "
                + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
                + " c учетной ценой "
                + ( if p-part-reserv-base <> 0 then "не равной 0" else "равной 0")
                + " запрещено." + {&new-line}
                + "Параметр " + v-parameter-name + "=" + conf-par + "."
                .
            end.
            when "enable"
            then do:
              assign
                v-action = {&v-partscr-action-exit}
              .
            end.
            when "prompt"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + {&new-line}
                  + "В данном режиме резервирования ручное редактирование невозможно" + {&new-line}
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + {&new-line}
                  .
              end.
              assign
                v-action = ""
              .
            end.
            when "manual"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + {&new-line}
                  + "В данном режиме резервирования ручное редактирование невозможно" + {&new-line}
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + {&new-line}
                  .
              end.
              assign
                v-action = {&v-partscr-action-chg}
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестное значение параметра" v-parameter-name skip
                "conf-par" conf-par skip
                view-as alert-box error .
              return
                "Неизвестное значение параметра " + v-parameter-name
                + " conf-par = " + conf-par
                .
            end.
          end.
        end.
      end.

      if l-need-create-old-return
      then do:
        assign
          v-action = {&v-partscr-action-chg}
        .
      end.

      /* партия создается из интерфейса редактирования партий */
      if v-prompt-price = 'prompt=disable-create':u
      then do:
        assign
          v-action = {&v-partscr-action-exit}
        .
      end.

      if v-action = ""
      then do:
        assign
          v-action = {&v-partscr-action-exit}
        .

        run trg/in-price.w
          (input parparentproc
          ,input-output p-part-reserv-base /* p-price-base */
          ,input-output p-part-reserv-rubl /* p-price-rubl */
          ,output v-action                 /* p-action     */
          ,input  buf_doc-line.obj-type    /* p-obj-type   */
          ,input  buf_doc-line.obj-code    /* p-obj-code   */
          ,input  buf_doc-line.artic       /* p-artic      */
          ,input  buf_doc-line.prod-type   /* p-prod-type  */
          ,input  buf_doc-line.prod-code   /* p-prod-code  */
          ,input  p-supp-type              /* p-supp-type  */
          ,input  p-supp-code              /* p-supp-code  */
          ,input  buf_trn-doc.base-rate    /* p-base-rate  */
          ,input  buf_trn-doc.base-scale   /* p-base-scale */
          ,input  p-change-qnty                 /* p-parts-qnty */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запросе учетной цены" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error .
        end.
      end.
      case v-action :
        when {&v-partscr-action-chg}
        then do:
          /* ручное редактирование партий */
          run str/partsedt.p
            (input parparentproc
            ,buffer buf_doc-line /* buf_doc-line */
            ,input  true         /* l-update     */
            ,input  false        /* l-reserv     */
            ,input  p-change-qnty     /* p-chg-qnty   */
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при редактировании партий" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error .
          end.
        end.
        when {&v-partscr-action-exit}
        then do:
          define variable v-doc-num    like ub.price-list.doc-num    no-undo .
          define variable v-price-sale like ub.price-list.price-sale no-undo .
          define variable v-road-tax   like ub.price-list.road-tax   no-undo .
          define variable v-excise     like ub.price-list.excise     no-undo .

          if  buf_trn-doc.doc-type = {&income}
          and buf_trn-doc.internal = false
          then do:
            /* внешний приход */
          end.
          else do:
            if l-goods-bottle
            then do:

              define variable v-gds-code    like ub.goods.gds-code  no-undo .
              define variable v-root-b-code like ub.bar-code.b-code no-undo .

              { gbl/gds-code.i
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                v-gds-code
              }

              { gbl/gdsbcode.i
                v-gds-code
                ?
                v-root-b-code
              }

              /* определяется корневая цена */
              { gbl/bcodeprc.i
                buf_doc-line.obj-type
                buf_doc-line.obj-code
                v-root-b-code
                v-root-b-code
                0
                v-doc-num
                v-price-sale
                v-road-tax
                v-excise
                no-error
              }
              if v-price-sale = ?
              then do:
                return
                  "Для товара " + string(buf_doc-line.artic)
                  + " " + string(buf_doc-line.prod-type)
                  + " " + string(buf_doc-line.prod-code)
                  + " типа стеклопосуда не задана продажная цена"
                  .
              end.
            end.
            else do:
              assign
                v-road-tax = 0
                v-excise   = 0
              .
            end.
          end.

          define variable v-curr-r-b as character no-undo .
          { gbl/curr-r-b.i
            v-curr-r-b
          }

          if p-dop = "" or p-dop = ? then do:
             /*Если внешний приход и есть атрибут у строки , то считаем от туда */
             if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
                  { gbl/gds-code.i
                    buf_doc-line.artic
                    buf_doc-line.prod-type
                    buf_doc-line.prod-code
                    v-gds-code
                  }

                define variable  v-dop1 as character no-undo .
                define variable  v-dop2 as character no-undo .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   {&lineattr-price-prod} ,
                    output  v-dop1      ,
                    output  v-type )
                    no-error .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   {&lineattr-price-prod-vat} ,
                    output  v-dop2   ,
                    output  v-type )
                    no-error .

                    p-dop = substitute("&1;&2" , v-dop1, v-dop2) .
             end.
             if p-dop = ? then p-dop = "" .
          end.

          create buf_parts .

          assign
            buf_parts.obj-type       = buf_doc-line.obj-type
            buf_parts.obj-code       = buf_doc-line.obj-code
            buf_parts.artic          = buf_doc-line.artic
            buf_parts.prod-type      = buf_doc-line.prod-type
            buf_parts.prod-code      = buf_doc-line.prod-code
            buf_parts.in-code        = buf_doc-line.doc-code
            buf_parts.out-code       = buf_doc-line.doc-code
            buf_parts.part-code      = p-part-code
            buf_parts.cst-code       = p-cst-code
            buf_parts.pl-code        = p-pl-code
            buf_parts.ps             = p-ps
            buf_parts.dop            = p-dop
            buf_parts.doc-type       = buf_trn-doc.doc-type
            buf_parts.status_        = no

            buf_parts.qnty           = 0
            buf_parts.fact-qnty      = 0
            buf_parts.cli-qnty       = 0
            buf_parts.real-qnty      = 0
            buf_parts.transport-base = 0
            buf_parts.transport-rubl = 0
            buf_parts.other-base     = 0
            buf_parts.other-rubl     = 0

            buf_parts.supp-type      = p-supp-type
            buf_parts.supp-code      = p-supp-code
            buf_parts.host-code      = buf_trn-doc.host-code
            buf_parts.last-date      = p-last-date
            buf_parts.hold-date      = p-hold-date

            buf_parts.vat-type       = p-vat-type
            buf_parts.vat-pc         = p-vat-pc
            buf_parts.slt-type       = p-slt-type
            buf_parts.slt-pc         = p-slt-pc

            buf_parts.contract-code  = buf_trn-doc.contract-code
          .
          if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}
          then do:
            if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
            then do:
              assign
                buf_parts.is-supp       = yes
              .
            end.
            else do:
              assign
                buf_parts.is-supp       = no
              .
            end.
            assign
              buf_parts.rsrv-free     = ?
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = buf_trn-doc.purch-code
              buf_parts.exch-code     = buf_trn-doc.exch-code
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.price-cli     = buf_doc-line.price-cli
              buf_parts.price-base    = buf_doc-line.price-base
              buf_parts.price-rubl    = buf_doc-line.price-rubl
            .

            if v-curr-r-b = {&r-b-base}
            then do:
              assign
                buf_parts.road-tax-base = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-rubl = buf_parts.road-tax-base
                                        * buf_trn-doc.base-rate
                                        / buf_trn-doc.base-scale
              .
            end.
            else do:
              assign
                buf_parts.road-tax-rubl = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-base = buf_parts.road-tax-rubl
                                        / buf_trn-doc.base-rate
                                        * buf_trn-doc.base-scale
              .
            end.

            if  l-goods-twounit = false
            and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
            then do:
              { str/in-vat.i
                buf_trn-doc.doc-code
                buf_trn-doc.base-rate
                buf_trn-doc.base-scale
                buf_trn-doc.exch-rate
                buf_trn-doc.exch-scale
                buf_trn-doc.vat-type
                buf_trn-doc.slt-type
                buf_parts.artic
                buf_parts.prod-type
                buf_parts.prod-code
                buf_parts.price-cli
                buf_parts.cli-base-rate
                buf_parts.price-rubl
                buf_parts.vat-pc
                buf_parts.slt-pc
                buf_doc-line.road-tax
                buf_parts.transport-rubl
                buf_parts.other-rubl
                v-price-cli
                v-price-cli-unit-base
                v-price-road-tax
                v-price-other-exp
                v-price-transport-exp
                v-price-without-abs
                v-price-slt
                v-price-no-slt
                v-price-vat
                v-price-no-vat-slt
                v-price-rubl
                v-price-road-tax-rubl
                v-price-other-exp-rubl
                v-price-transport-exp-rubl
                v-price-without-abs-rubl
                v-price-slt-rubl
                v-price-no-slt-rubl
                v-price-vat-rubl
                v-price-no-vat-slt-rubl
                v-price-base
                v-price-road-tax-base
                v-price-other-exp-base
                v-price-transport-exp-base
                v-price-without-abs-base
                v-price-slt-base
                v-price-no-slt-base
                v-price-vat-base
                v-price-no-vat-slt-base
                no-error
              }
              if error-status :error
              then do:
                return error "Ошибка при пересчете линии документа".
              end.
              assign
                buf_parts.price-cli  = v-price-cli
                buf_parts.price-rubl = v-price-rubl
                buf_parts.price-base = v-price-base
              .
            end.
          end.
          else do:
            /* это порожденная партия она не резервируется из какой-либо зоны */
            /* но, тем не менее мы устанавливаем соответствующий rsrv-free */

            /* определяем код валюты r-b для текущей фирмы */
            define variable v-curr-r-b-code as integer no-undo .

            { gbl/r-b-curr.i
              buf_trn-doc.host-code
              v-curr-r-b-code
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры basecode.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.

            assign
              buf_parts.rsrv-free     = (if can-do({&expense_write-off}, buf_trn-doc.doc-type)
                                          or (can-do({&inventory}, buf_trn-doc.doc-type)
                                              and (buf_parts.qnty + p-change-qnty) < 0
                                              )
                                        /* см. ниже это новая buf_parts.fact-qnty < 0 */
                                        then yes
                                        else no
                                      )
              buf_parts.is-supp       = ( if l-create-old-return then yes else no )
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = integer({&repayment-code})
              buf_parts.price-base    = p-part-reserv-base
              buf_parts.price-rubl    = p-part-reserv-rubl
              buf_parts.road-tax-base = 0
              buf_parts.road-tax-rubl = 0
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.exch-code     = 0
              buf_parts.price-cli     = buf_parts.price-rubl
            .
          end.

          validate buf_parts .
        end.
        when {&v-partscr-action-quit}
        then do:
          /* не создаем партию */
        end.
      end case .
    end.

    if available buf_parts
    then do:
      if l-fact-qnty
      then do:
        assign
          buf_parts.fact-qnty = buf_parts.fact-qnty + p-change-qnty
        .
      end.
      else do:
        assign
          buf_parts.qnty      = buf_parts.qnty + p-change-qnty
          buf_parts.fact-qnty = buf_parts.qnty
        .
        if buf_trn-doc.doc-type = {&inventory}
        then do:
          /* порожденная партия инвентаризации может поменять количество */
          /* на противоположный знак */
          assign
            buf_parts.rsrv-free     = ( if buf_parts.qnty < 0
                                        then true
                                        else false
                                      )
          .
        end.
      end.

      if l-goods-twounit = true
      then do:
        if p-cli-qnty <> 0
        then do:
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
          assign
            buf_parts.cli-base-rate = buf_parts.qnty / buf_parts.cli-qnty
          .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        if abs(buf_parts.cli-qnty - p-cli-qnty) < 0.0011
        then do :
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
        end .
      end.

      if l-goods-twounit = false
      then do:
        /* пересчитываем cli-qnty на основании qnty */
        { gbl/qntycalc.i
          "'cli-qnty'"
          buf_parts.cli-base-rate
          buf_parts.cli-qnty
          buf_parts.qnty
          buf_parts.cli-qnty
          buf_parts.qnty
          no-error
        }
        if error-status :error
        then do:
          message
            "Невозможно пересчитать количество по ТТН" skip
            "Документ" buf_parts.out-code skip
            {&Article} buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" + string(buf_parts.part-code) skip
            return-value skip
            view-as alert-box .
          undo, return error .
        end.
      end.

      /* контроль количества */
      if l-goods-serial
      then do:
        if  buf_parts.qnty <> 0
        and buf_parts.qnty <> 1
        then do:
          message
            "Товар серийный." skip
            "Невозможно порождение партии с количеством, отличным от 1."
            view-as alert-box .
          undo, return error .
        end.
      end.
    end.
    return .
  end.

end procedure. /* partscr */


procedure partscr_check-valid-supp :
  define input parameter  p-supp-type         like ub.parts.supp-type no-undo .
  define input parameter  p-supp-code         like ub.parts.supp-code no-undo .
  define input parameter  p-trn-doc-supp-type like ub.parts.supp-type no-undo .
  define input parameter  p-trn-doc-supp-code like ub.parts.supp-code no-undo .
  define input parameter  p-extended-doc-type as character no-undo .
  define output parameter p-old-return        as logical no-undo .
  define output parameter p-reason            as character no-undo .

  assign
    p-old-return = false
    p-reason     = ""
  .

  if p-supp-type <> p-trn-doc-supp-type
  or p-supp-code <> p-trn-doc-supp-code
  then do:
    if p-extended-doc-type = {&TDEDT_Vozvrat_Vnesh}
    or p-extended-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
    or p-extended-doc-type = {&TDEDT_Inv}
    or p-extended-doc-type = {&TDEDT_Peresort}
    then do:
      if p-supp-type = {&prs}
      or p-supp-type = {&cmp}
      then do:
        /* создается партия старого возврата */
        assign
          p-old-return = true
        .
      end.
      else do:
        assign
          p-reason = "Поставщиком партии старого возврата может быть только человек или организация"
        .
        return .
      end.
    end.
    else do:
      assign
        p-reason = "Поставщиком порожденной партии может быть только объект документа"
      .
      return .
    end.
  end.

  return .

end procedure. /* partscr_check-valid-supp */


procedure partscr_get-default-values :

  define parameter buffer buf_doc-line for ub.doc-line .
  define output parameter p-vat-type   as character no-undo .
  define output parameter p-vat-pc     as decimal   no-undo .
  define output parameter p-slt-type   as character no-undo .
  define output parameter p-slt-pc     as decimal   no-undo .

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods for ub.goods .

  define variable v-vat-pc as decimal   no-undo .
  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Код документа" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}
    then do:
      assign
        p-vat-type = buf_trn-doc.vat-type
        p-vat-pc   = buf_doc-line.vat-pc
        p-slt-type = buf_trn-doc.slt-type
        p-slt-pc   = buf_doc-line.slt-pc
      .
    end.
    else do:
      { gbl/hostcode.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        v-host-code
      }
      { gbl/pftxvalg.i
        buf_goods.gds-code
        {&vat-tax-code}
        ?
        v-host-code
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-vat-pc
        no-error
      }
      assign
        p-vat-type = {&inc-vat}
        p-vat-pc   = v-vat-pc
        p-slt-type = {&without-SLT}
        p-slt-pc   = 0
      .
    end.
  end.

end procedure. /* partscr_get-default-values */


/* $Workfile$   E n d */