/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Суммы товара в текущих продажных ценах на момент закрытия документа

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/22/02

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure r-crsa :

  define input parameter  p-doc-code       like ub.doc-line.doc-code  no-undo .
  define input parameter  p-artic          like ub.doc-line.artic     no-undo .
  define input parameter  p-prod-type      like ub.doc-line.prod-type no-undo .
  define input parameter  p-prod-code      like ub.doc-line.prod-code no-undo .
  define input  parameter p-curr-r-b       as character no-undo .
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .

  define variable vss-description as character no-undo initial "r-crsa-01: суммы товара в текущих продажных ценах на момент закрытия документа".

  define buffer buf_gds-dtl  for ub.gds-dtl .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-gds-dtl-fact-qnty       as decimal   no-undo .
    define variable v-total-gds-dtl-fact-qnty as decimal   no-undo .

    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> {&inventory} then do:
        if buf_trn-doc.doc-type = {&income}
        or buf_trn-doc.doc-type = {&return}
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.

      assign
        v-total-gds-dtl-fact-qnty = v-total-gds-dtl-fact-qnty
                                  + v-gds-dtl-fact-qnty
      .

      /* определяем текущую продажную цену на момент закрытия документа */
      define variable v-gds-code      as integer   no-undo .
      define variable v-prt-b-code    like ub.bar-code.b-code no-undo .
      define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .

      { gbl/gds-code.i
        p-artic
        p-prod-type
        p-prod-code
        v-gds-code
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода товара" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      { gbl/gdsbcode.i
        v-gds-code
        buf_gds-dtl.prt-code
        v-prt-b-code
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара" v-gds-code  skip
          "Код признака" buf_gds-dtl.prt-code skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable parrecid-prl as recid     no-undo .
      { str/out-vatp.i def " " " " " " -prl " " }

      { gbl/bcodepls.i
        buf_gds-dtl.obj-type
        buf_gds-dtl.obj-code
        v-prt-b-code
        0
        buf_trn-doc.fact-order
        parrecid-prl
        v-cli-base-rate
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске строки переоценки для бар-кода" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Бар-код" v-prt-b-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if parrecid-prl <> ? then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.

      define variable v-fact-qnty         as decimal   no-undo .
      define variable v-cur-base          as decimal   no-undo .
      define variable v-cur-VAT-base      as decimal   no-undo .
      define variable v-cur-SLT-base      as decimal   no-undo .
      define variable v-cur-road-tax-base as decimal   no-undo .
      define variable v-cur-excise-base   as decimal   no-undo .

      assign
        v-fact-qnty         = v-fact-qnty
                            + v-gds-dtl-fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = {&r-b-base}
                               then price-base-with-tax-sale-prl
                               else price-rubl-with-tax-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = {&r-b-base}
                               then vat-base-sale-prl
                               else vat-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = {&r-b-base}
                               then slt-base-sale-prl
                               else slt-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = {&r-b-base}
                               then road-tax-base-sale-prl
                               else road-tax-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = {&r-b-base}
                               then excise-base-sale-prl
                               else excise-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
      .
    end.

    assign
      p-fact-qnty = v-fact-qnty
    .

    define variable v-base-rate                 like ub.curr-accnt.exch-rate no-undo .
    define variable v-base-scale                like ub.curr-accnt.exch-scale no-undo .
  assign
    v-base-rate  = buf_trn-doc.base-rate
    v-base-scale = buf_trn-doc.base-scale
  .


    if p-curr-r-b = {&r-b-base} then do:
      assign
        p-sum-base       = v-cur-base
        p-sum-rubl       = v-cur-base     * v-base-rate / v-base-scale
        p-vat-base       = v-cur-VAT-base
        p-vat-rubl       = v-cur-VAT-base * v-base-rate / v-base-scale
        p-slt-base       = v-cur-SLT-base
        p-slt-rubl       = v-cur-SLT-base * v-base-rate / v-base-scale
        p-road-tax-base  = v-cur-road-tax-base
        p-road-tax-rubl  = v-cur-road-tax-base * v-base-rate / v-base-scale
        p-excise-base    = v-cur-excise-base
        p-excise-rubl    = v-cur-excise-base * v-base-rate / v-base-scale
        p-transport-base = 0
        p-transport-rubl = 0
        p-other-base     = 0
        p-other-rubl     = 0
      .
    end.
    else do:
      assign
        p-sum-base       = v-cur-base     / v-base-rate * v-base-scale
        p-sum-rubl       = v-cur-base
        p-vat-base       = v-cur-VAT-base / v-base-rate * v-base-scale
        p-vat-rubl       = v-cur-VAT-base
        p-slt-base       = v-cur-SLT-base / v-base-rate * v-base-scale
        p-slt-rubl       = v-cur-SLT-base
        p-road-tax-base  = v-cur-road-tax-base / v-base-rate * v-base-scale
        p-road-tax-rubl  = v-cur-road-tax-base
        p-excise-base    = v-cur-excise-base / v-base-rate * v-base-scale
        p-excise-rubl    = v-cur-excise-base
        p-transport-base = 0
        p-transport-rubl = 0
        p-other-base     = 0
        p-other-rubl     = 0
      .
    end.
  end.

end procedure. /* r-crsa */


/* $Workfile$ e n d */