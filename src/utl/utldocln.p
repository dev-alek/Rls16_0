block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: utldocln.p $
$Archive: utl/utldocln.p $

Утилита изменения параметров строки документа, закрытого по факту

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
define input  parameter parparentproc as handle    no-undo .
define parameter buffer buf_doc-line for ub.doc-line .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: utldocln.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/utldocln.p $":U .
define variable vss-description as character no-undo init "Утилита изменения параметров строки документа, закрытого по факту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ cmp/library.i  }

define variable l-single-db     as logical no-undo .
define variable v-alcohol-prod  as logical no-undo.
define variable v-alcohol-value as character no-undo.
define variable v-alcohol-type  as character no-undo.

run check-single-db in this-procedure
  (output l-single-db
  ).

if not available buf_doc-line
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не задана строка документа."
    view-as alert-box error .
  undo, return error .
end.

/* Проверяем значение продажного параметра "Алкогольная продукция" */
v-alcohol-prod = no.
{ gbl/conf-rd.i
  "'alcohol':u"
  "0"
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-alcohol-value
  v-alcohol-type
  no-error
}
if (not error-status:error) and lookup(v-alcohol-value, 'true,yes':u) > 0 then do:
  /* Является ли товар алкогольной продукцией */
  { gbl/gdsat.i
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    "'alcohol-prod=request':u"
    v-alcohol-prod
  }
end.

def var v-num as integer no-undo .

do on error undo, return return-value :
  run str/d-askpar.w (input  recid(buf_doc-line)
                 ,input  l-single-db
                 ,input  v-alcohol-prod
                 ,output v-num
                 ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.

case v-num :
  when 0
  then do:
    return . /* --->>>--- */
  end.
  when 1
  then do:
    run change-VAT-pc in this-procedure .
  end.
  when 2
  then do:
    run change-cst-code in this-procedure .
  end.
  when 3
  then do:
    run change-last-date in this-procedure .
  end.
  when 4
  then do:
    run change-alc-attr in this-procedure .
  end.
  otherwise do:
    message "Нет процедуры для редактирования выбранного атрибута" +
            substitute (" (параметр &1 )", v-num)
      view-as alert-box error.
    return.
  end.
end.


procedure change-VAT-pc :
  /* изменение НДС поставщика */

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error
  :

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      .
    if buf_trn-doc.VAT-type = {&without-VAT}
    or buf_trn-doc.VAT-type = {&no-VAT}
    then do:
      message
        "Накладная" buf_trn-doc.doc-code skip
        "Приходная накладная имеет тип заведения НДС" buf_trn-doc.VAT-type skip
        "Для накладной такого типа заведения НДС нельзя менять процент НДС" skip
        view-as alert-box information .
      return .
    end.

    define variable v-doc-line-VAT-pc as decimal no-undo .

    assign
      v-doc-line-VAT-pc = buf_doc-line.VAT-pc
    .

    /* осуществляем блокировку документа */
    find first trn-doc exclusive-lock
      where trn-doc.doc-code = buf_doc-line.doc-code
      .
    if l-single-db <> true
    then do:
      message
        "Существуют удаленные базы данных" skip
        "Изменение НДС поставщика невозможно" skip
        view-as alert-box information .
      return .
    end.

    { str/in-vatp.i def }

    { str/in-vatp.i calc buf_doc-line. trn-doc. loc }

    define variable s-vat-rubl as character no-undo .

    assign
      s-vat-rubl = string(vat-rubl-loc * buf_doc-line.fact-qnty)
    .

    run gbl/d-prompt.w
      ( 'title=Введите сумму НДС\'
      + 'text1=Артикул '
        + string(buf_doc-line.artic)
        + " " + string(buf_doc-line.prod-type)
        + " " + string(buf_doc-line.prod-code) + '\'
      + 'text2=Сумма в учетн. ценах без НДС ({&abbr_rub}) \'
      + 'format=>>>>>>>>>>>>9.9999999999\'
      + 'type=decimal\'
      ,input-output s-vat-rubl
      ).
    if return-value = 'false':u
    then do:
      return . /* --->>>--- */
    end.


    define variable s-doc-line-VAT-pc as character no-undo .

    /*
                                    Новая Сумма НДС
    Процент НДС =  ------------------------------------------ * 100
                    Старая цена включая НДС - Новая сумма НДС
    */

    assign
      s-doc-line-VAT-pc = string(decimal(s-vat-rubl)
                                / ( buf_doc-line.fact-qnty
                                    *
                                    (price-rubl-without-tax-loc + vat-rubl-loc )
                                    - decimal(s-vat-rubl)
                                  )
                                  * 100
                              )
    .

    run gbl/d-prompt.w
      ( 'title=Введите новый НДС\'
      + 'text1=Артикул '
        + string(buf_doc-line.artic)
        + " " + string(buf_doc-line.prod-type)
        + " " + string(buf_doc-line.prod-code) + '\'
      + 'text2=Введите новый НДС\'
      + 'format=>9.9999999999\'
      + 'type=decimal\'
      ,input-output s-doc-line-VAT-pc
      ).

    if return-value = 'false':u
    then do:
      return . /* --->>>--- */
    end.

    assign
      v-doc-line-VAT-pc = decimal (s-doc-line-VAT-pc)
    .

    if v-doc-line-VAT-pc = buf_doc-line.VAT-pc
    then do:
      message
        "Вы ввели НДС поставщика равный указанному в строке документа." skip
        "Изменение документа не производится."
        view-as alert-box information .
      return . /* --->>>--- */
    end.

    define variable lok as logical no-undo .
    message
      "Вы действительно хотите измененить НДС поставщика?" skip
      "Предыдущий НДС" buf_doc-line.vat-pc skip
      "Новый НДС"      v-doc-line-VAT-pc skip
      view-as alert-box question buttons yes-no update lok .

    if lok <> true
    then do:
      return .
    end.

    run trg/doclnvat.p
      (input buf_doc-line.doc-code   /* p-doc-code   */
      ,input buf_doc-line.artic      /* p-artic      */
      ,input buf_doc-line.prod-type  /* p-prod-type  */
      ,input buf_doc-line.prod-code  /* p-prod-code  */
      ,input v-doc-line-VAT-pc       /* p-new-VAT-pc */
      ).


    { str/in-vatp.i calc buf_doc-line. trn-doc. loc }

    message
      "НДС поставщика изменен." skip
      "Новый процент НДС" buf_doc-line.VAT-pc  skip
      "Новая сумма НДС в БВ"  vat-base-loc * buf_doc-line.fact-qnty skip
      "Новая сумма НДС в {&abbr_rub}" vat-rubl-loc * buf_doc-line.fact-qnty skip
      "После изменения НДС в документах необходимо запустить утилиту" skip
      "Выполнить отложенные задания (BatchProcess), run-btpr.p" skip
      view-as alert-box information .
  end.

end procedure. /* change-VAT-pc */


procedure change-cst-code :

  define buffer buf_parts for ub.parts .

  define variable ind               as integer no-undo .
  define variable v-total-parts     as integer no-undo .
  define variable v-change-ind      as integer no-undo .
  define variable v-parts-cst-code  like buf_parts.cst-code no-undo .
  define variable v-cst-code-format as character no-undo .

  do
  on error undo, return error
  :

    run gbl/fldfrmt.p
      (input  "parts":U
      ,input  "cst-code":U
      ,output v-cst-code-format
      ) .

    /* осуществляем блокировку документа */
    find first trn-doc exclusive-lock
      where trn-doc.doc-code = buf_doc-line.doc-code
      .

    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    :
      assign
        v-total-parts = v-total-parts + 1
      .
    end.

    if v-total-parts = 0
    then do:
      message
        "В строке документа отсутствуют партии"
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box information .
      return .
    end.

    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    :
      assign
        ind              = ind + 1
        v-parts-cst-code = buf_parts.cst-code
      .

      run gbl/d-prompt.w
        ( 'title=':U + "Введите новый ГТД" + '\':U
        + 'text1=':U + "Партия " + str-encode(buf_parts.in-code, "", '\=':U )
          + {&space-char} + str-encode(buf_parts.part-code, "", '\=':U )
          + {&space-char} + string(ind) + " из " + string(v-total-parts) + '\':U
        + 'text2=' + "Артикул " + str-encode(buf_parts.artic, "", '\=':U )
          + {&space-char} + string(buf_parts.prod-type)
          + {&space-char} + string(buf_parts.prod-code) + '\':U
        + 'format=' + v-cst-code-format + '\':U
        + 'type=character':U
        ,input-output v-parts-cst-code
        ).
      if return-value = 'false':U
      then do:
        return . /* --->>>--- */
      end.

      if v-parts-cst-code <> buf_parts.cst-code
      then do:
        assign
          v-change-ind = v-change-ind + 1
        .
      end.

      run trg/partcst.p
        (input v-parts-cst-code       /* p-cst-code  */
        ,input buf_parts.in-code      /* p-in-code   */
        ,input buf_parts.artic        /* p-artic     */
        ,input buf_parts.prod-type    /* p-prod-type */
        ,input buf_parts.prod-code    /* p-prod-code */
        ,input buf_parts.part-code    /* p-part-code */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partcst.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    message
      "Изменение ГТД завершено" skip
      "Изменено" v-change-ind "партий из" v-total-parts skip
      ""  ( if  l-single-db <> true
            and v-change-ind <> 0
            then "Внимание! Существуют удалённые базы данных." + {&new-line}
               + "ГТД будет изменено только в текущей базе данных." + {&new-line}
            else ""
          ) skip
      view-as alert-box information .
  end.

end procedure. /* change-cst-code */


procedure change-last-date :

  define buffer buf_parts for ub.parts .

  define variable v-ind             as integer   no-undo .
  define variable v-change-ind      as integer   no-undo .
  define variable v-total-parts     as integer   no-undo .
  define variable v-parts-last-date as character no-undo .

  do
  on error undo, return error return-value
  :
    /* осуществляем блокировку документа */
    find first trn-doc exclusive-lock
      where trn-doc.doc-code = buf_doc-line.doc-code
      .

    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    :
      assign
        v-total-parts = v-total-parts + 1
      .
    end.

    if v-total-parts = 0
    then do:
      message
        "В строке документа отсутствуют партии"
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box information .
      return .
    end.

    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    :
      assign
        v-ind             = v-ind + 1
        v-parts-last-date = string(buf_parts.last-date, '99/99/9999':u)
      .

      run gbl/d-prompt.w
        ( 'title=':U + "Введите срок годности" + '\':U
        + 'text1=':U + "Партия " + str-encode(buf_parts.in-code, "", '\=':U )
          + {&space-char} + str-encode(buf_parts.part-code, "", '\=':U )
          + {&space-char} + string(v-ind) + " из " + string(v-total-parts) + '\':U
        + 'text2=' + "Артикул " + str-encode(buf_parts.artic, "", '\=':U )
          + {&space-char} + string(buf_parts.prod-type)
          + {&space-char} + string(buf_parts.prod-code) + '\':U
        + 'format=99/99/9999\':U
        + 'type=date':U
        ,input-output v-parts-last-date
        ).
      if return-value = 'false':U
      then do:
        return . /* --->>>--- */
      end.

      if v-parts-last-date <> string(buf_parts.cst-code)
      then do:
        assign
          v-change-ind = v-change-ind + 1
        .
      end.

      define variable v-gds-code as integer   no-undo .

      { gbl/gds-code.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        v-gds-code
      }

      run trg/partlast.p
        (input  buf_parts.in-code       /* p-in-code   */
        ,input  v-gds-code              /* p-gds-code  */
        ,input  buf_parts.part-code     /* p-part-code */
        ,input  date(v-parts-last-date) /* p-last-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partlast.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    message
      "Изменение срока годности завершено" skip
      "Изменено" v-change-ind "партий из" v-total-parts skip
      ""  ( if  l-single-db <> true
            and v-change-ind <> 0
            then "Внимание! Существуют удалённые базы данных." + {&new-line}
               + "Срок годности будет изменено только в данной базе данных." + {&new-line}
            else ""
          ) skip
      view-as alert-box information .

  end.

end procedure. /* change-last-date */


procedure change-alc-attr :

  define variable v-part-recid as recid no-undo.

  define buffer buf_goods for ub.goods.

  do on error undo, return :
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      .
    run str/parts-l.w
      (input parparentproc
      ,input buf_doc-line.obj-type     /* v-obj-type   */
      ,input buf_doc-line.obj-code     /* v-obj-code   */
      ,input buf_goods.gds-code        /* p-gds-code   */
      ,input buf_doc-line.doc-code     /* p-doc-code   */
      ,input 'update-alc-attr':u       /* p-edit-mode  */
      ,input {&parts-l_parts-document} /* p-r-parts    */
      ,input {&parts-l_object-current} /* p-one-all    */
      ,input {&parts-l_call-document}  /* p-call-point */
      ,output v-part-recid             /* part-recid   */
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры parts-l.w" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* change-alc-attr */


procedure check-single-db :
  define output parameter p-single-db as logical no-undo .

  do
  on error undo, return error
  :
    assign
      p-single-db = true
    .

    find first ub.db no-lock
      where ub.db.db-num <> 0
      no-error .
    if available ub.db
    then do:
      assign
        p-single-db = false
      .
    end.
  end.

end procedure. /* check-single-db */