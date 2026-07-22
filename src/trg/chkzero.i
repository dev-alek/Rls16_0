/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка установки налога с продаж в строках документа

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure chkzero :

  define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .

  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .

  define variable v-artic     like ub.doc-line.artic     no-undo .
  define variable v-prod-type like ub.doc-line.prod-type no-undo .
  define variable v-prod-code like ub.doc-line.prod-code no-undo .

  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-vat-pc         as decimal   no-undo .
  define variable v-slt-pc         as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-vat-base       as decimal   no-undo .
  define variable v-vat-rubl       as decimal   no-undo .
  define variable v-slt-base       as decimal   no-undo .
  define variable v-slt-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_trn-doc.doc-type <> {&inventory}
    then do:
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = p-doc-code
          and buf_doc-line.fact-qnty = 0
      on error undo, return error
      :
        assign
          v-artic     = buf_doc-line.artic
          v-prod-type = buf_doc-line.prod-type
          v-prod-code = buf_doc-line.prod-code
        .

        run r-sale in this-procedure
          (input  p-doc-code       /* p-doc-code       */
          ,input  v-artic          /* p-artic          */
          ,input  v-prod-type      /* p-prod-type      */
          ,input  v-prod-code      /* p-prod-code      */
          ,output v-fact-qnty      /* p-fact-qnty      */
          ,output v-vat-pc         /* p-vat-pc         */
          ,output v-slt-pc         /* p-slt-pc         */
          ,output v-sum-base       /* p-sum-base       */
          ,output v-sum-rubl       /* p-sum-rubl       */
          ,output v-vat-base       /* p-vat-base       */
          ,output v-vat-rubl       /* p-vat-rubl       */
          ,output v-slt-base       /* p-slt-base       */
          ,output v-slt-rubl       /* p-slt-rubl       */
          ,output v-road-tax-base  /* p-road-tax-base  */
          ,output v-road-tax-rubl  /* p-road-tax-rubl  */
          ,output v-transport-base /* p-transport-base */
          ,output v-transport-rubl /* p-transport-rubl */
          ,output v-other-base     /* p-other-base     */
          ,output v-other-rubl     /* p-other-rubl     */
          ,output v-excise-base    /* p-excise-base    */
          ,output v-excise-rubl    /* p-excise-rubl    */
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете сумм по документу" skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        if v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-vat-base       <> 0
        or v-vat-rubl       <> 0
        or v-slt-base       <> 0
        or v-slt-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            "При нулевом количестве по строке получены ненулевые суммы" skip
            "Тип суммы: Цены по документу" skip
            "v-sum-base"        v-sum-base       skip
            "v-sum-rubl"        v-sum-rubl       skip
            "v-vat-base"        v-vat-base       skip
            "v-vat-rubl"        v-vat-rubl       skip
            "v-slt-base"        v-slt-base       skip
            "v-slt-rubl"        v-slt-rubl       skip
            "v-road-tax-base"   v-road-tax-base  skip
            "v-road-tax-rubl"   v-road-tax-rubl  skip
            "v-excise-base"     v-excise-base    skip
            "v-excise-rubl"     v-excise-rubl    skip
            "v-transport-base"  v-transport-base skip
            "v-transport-rubl"  v-transport-rubl skip
            "v-other-base"      v-other-base     skip
            "v-other-rubl"      v-other-rubl     skip
            view-as alert-box error .
          undo, return error .
        end.

        define variable v-curr-r-b as character no-undo .
        { gbl/curr-r-b.i
          v-curr-r-b
        }

        run r-crsa in this-procedure
          (input  p-doc-code       /* p-doc-code       */
          ,input  v-artic          /* p-artic          */
          ,input  v-prod-type      /* p-prod-type      */
          ,input  v-prod-code      /* p-prod-code      */
          ,input  v-curr-r-b       /* p-curr-r-b       */
          ,output v-fact-qnty      /* p-fact-qnty      */
          ,output v-vat-pc         /* p-vat-pc         */
          ,output v-slt-pc         /* p-slt-pc         */
          ,output v-sum-base       /* p-sum-base       */
          ,output v-sum-rubl       /* p-sum-rubl       */
          ,output v-vat-base       /* p-vat-base       */
          ,output v-vat-rubl       /* p-vat-rubl       */
          ,output v-slt-base       /* p-slt-base       */
          ,output v-slt-rubl       /* p-slt-rubl       */
          ,output v-road-tax-base  /* p-road-tax-base  */
          ,output v-road-tax-rubl  /* p-road-tax-rubl  */
          ,output v-transport-base /* p-transport-base */
          ,output v-transport-rubl /* p-transport-rubl */
          ,output v-other-base     /* p-other-base     */
          ,output v-other-rubl     /* p-other-rubl     */
          ,output v-excise-base    /* p-excise-base    */
          ,output v-excise-rubl    /* p-excise-rubl    */
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете сумм по документу" skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        if v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-vat-base       <> 0
        or v-vat-rubl       <> 0
        or v-slt-base       <> 0
        or v-slt-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            "При нулевом количестве по строке получены ненулевые суммы" skip
            "Тип суммы: Текущие продажные цены" skip
            "v-sum-base"        v-sum-base       skip
            "v-sum-rubl"        v-sum-rubl       skip
            "v-vat-base"        v-vat-base       skip
            "v-vat-rubl"        v-vat-rubl       skip
            "v-slt-base"        v-slt-base       skip
            "v-slt-rubl"        v-slt-rubl       skip
            "v-road-tax-base"   v-road-tax-base  skip
            "v-road-tax-rubl"   v-road-tax-rubl  skip
            "v-excise-base"     v-excise-base    skip
            "v-excise-rubl"     v-excise-rubl    skip
            "v-transport-base"  v-transport-base skip
            "v-transport-rubl"  v-transport-rubl skip
            "v-other-base"      v-other-base     skip
            "v-other-rubl"      v-other-rubl     skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.

  end.

end procedure. /* chkzero */


/* $Workfile$ e n d */