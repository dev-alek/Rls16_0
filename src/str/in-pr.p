block-level on error undo, throw.
/*

$Revision: aa9f57929aa3, 2828, rls $
$Author: VRukavishnikov $
$Date: Пн ноя 15 13:32:14 2021 +0300 $
$Workfile: in-pr.p $
$Archive: str/in-pr.p $

Генерация переоценки

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

Генерация переоценки при фактическом закрытии приходной накладной (внешней, внутренней, из производства)

   Режимы генерации:

   cost-price - переоценка нулевого остатка для новых товаров

   - если этих товаров нет в наличии
   - если на них нет продажной цены
   - если количество в ПН не 0

   after-margin - подготовка переоценки со стандартными (из справочника) наценками

   - включается настройкой gen-mrgn = after
   - переоценка генерируется незакрыта

   before-margin - назначение цен продажи со стандартными наценками до закрытия ПН

   - включается настройкой gen-mrgn = before
   - переоценка генерируется закрытой на АКТ
   - переоцениваются в т.ч. ненулевые остатки
   - может вызываться после или вместо режима cost-price

*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-doc-rec      as recid no-undo .      /* recid TRN_DOC */
define input parameter gen-mode       as character no-undo .  /* режим генерации переоценки */

define variable vss-revision    as character no-undo init "$Revision: aa9f57929aa3, 2828, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 15 13:32:14 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-pr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/in-pr.p $":U .
define variable vss-description as character no-undo init "Генерация переоценки при фактическом закрытии приходной накладной".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-rec,gen-mode)" }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/lib-log.i      }
/*может вызываться в автоматическом режиме поэтому определения оставляем а вызов значений делаем СВОЙ*/
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ str/lvldsc.i       }
{ cmp/trg-def.i      }

define variable line-mode    as character no-undo . /* проверить выше */
define variable line-rec     as recid     no-undo . /* проверить выше */
define variable var-pr-r-b   as character no-undo .
define variable v-log-handle as handle    no-undo .
define variable v-str        as character no-undo .
{ gbl/get-lgh.i  v-log-handle }
{ gbl/curr-r-b.i  var-pr-r-b }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/croslist.i     }
{ gbl/clntattr.i     }
{ ref/grpobj.i       }
{ ref/gdsoattr.i     }
{ str/hvrdtax.i      }
{ trg/check-bc.i }
{ str/alt-calc.i "main-road-tax" }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/doc-code.i }
{ str/trdcalib.i }
{ str/pr-lattr.i }
/* Переменные и буфера  в in-pr.p */
/*
{ gbl/getcntxt.i get } - закоментарено потому что определение значений по-другому - в автоматическом режиме может вызываться!!
{ str/getctxtp.i get }
*/
{ gbl/waitfram.i }
{ str/get-pr.i def }
{ gbl/lineattr.i }
{ str/specattr.i }

define buffer buf1_parts for ub.parts  .
FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
END FUNCTION.
define variable g#log as logical   no-undo .
{ str/alt-calc.i func }
{ str/alt-calc.i proc }


define buffer b1-doc-line    for ub.doc-line .
define variable doc-code      like ub.trn-doc.doc-code  no-undo . /* для вызова pr-calc.i */
define variable cost-base     as decimal no-undo .  /* для вызова g d savrg  .p (в p r - c a l c.i) */
define variable cost-rubl     as decimal no-undo .  /* для вызова g d savrg  .p (в p r - c a l c.i) */
define variable v-price-base  as decimal no-undo .  /* для вызова g d snovat .p */
define variable v-price-rubl  as decimal no-undo.   /* для вызова g d snovat .p */
define variable tt-price-sale as decimal no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-base   as decimal no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-rubl   as decimal no-undo.   /* для вызова g d snovat .p */
define variable v-parts as logical   no-undo init false .
define variable tt-price-prodwihvat as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-prod-vat         as decimal no-undo.   /* для вызова g d s n o v a t . p */


define variable v-root-b-code like ub.bar-code.b-code no-undo .
define variable pr-list-rec   as recid                no-undo .
define variable calc-rec      as recid                no-undo.

/* метод округления */
define variable par-type       as character          no-undo . /* тип параметра конфигурации        */
define variable v-round-method as character          no-undo . /* способ округления                 */
define variable v-round-base   as decimal            no-undo . /* база для округления / коэффициент */

/* проверка стеклопосуды */
define var p-new-road-tax as decimal no-undo .
define variable p-flag as logical init false no-undo .
define variable v-name-tax as character no-undo .

define variable par-disc-mar as logical no-undo .
define variable v-ret as logical no-undo .

define variable v-plt-id     as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable par-pr-nakl as logical   no-undo .
define variable v-rest-last as decimal   no-undo .
define variable v-rest-qnty as decimal   no-undo .
define variable v-rest-sale as decimal   no-undo .
define variable v-sale-base as decimal   no-undo .
define variable is-after-margin-parts as logical   no-undo .
define variable  par-gen-mrgn-ie-parts as character no-undo .
define variable  par-gen-mrgn-iv-parts as character no-undo .
define variable  par-gen-mrgn-im-parts as character no-undo .

define variable v-last-price-sale   as decimal   no-undo .
define variable v-last-calc-method  as character no-undo .

define variable attr-marg-pr-paraf   as character no-undo init "0".
define variable v-type               as character no-undo .

define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo .
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo .
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo .
define variable p-type-rmethod        as logical   no-undo .
{ str/alt-calc.i proc-ver }
{ str/alt-calc.i pr-list in-pr }
{ str/alt-calc.i ver-pr-equ-dq }
define variable v1-b-code as integer   no-undo .
define variable new-rec as recid no-undo .
define variable v-msg as character no-undo .
define buffer n1_price-list for ub.price-list  .

/*-----------------------------------------------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  find ub.trn-doc where recid (ub.trn-doc) = p-doc-rec no-lock.   /* ПН */
  if  ub.trn-doc.doc-type <> {&income}   then do:
    /* 5.08  автоматическая переоценка создается только для документов внеш прихода */
    /* 13.09 вернули назад */
    return.
  end.
/*НЕЛЬЗЯ ДЕЛАТЬ g e t c n t x t . i get!!!  вызывается в авто режиме!!!!*/
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  run get-userid in parparentproc ( output v-cntxt-userid).
  assign
  v-cntxt-obj-type = ub.trn-doc.obj-type
  v-cntxt-obj-code = ub.trn-doc.obj-code
  v-cntxt-host-code-obj = ub.trn-doc.host-code
  v-cntxt-level = {&cntxt-object}
  .
  assign
  v-cntxp-db-num = v-cntxt-db-num
  v-cntxp-userid = v-cntxt-userid
  v-cntxp-curr-host-code = v-cntxt-host-code-obj
  v-cntxp-level = v-cntxt-level
  v-cntxp-obj-type = v-cntxt-obj-type
  v-cntxp-obj-code = v-cntxt-obj-code
  .

  { str/getctxtp.i get-no-cntxt }

 define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  ub.trn-doc.host-code
        ,input  ub.trn-doc.obj-type
        ,input  ub.trn-doc.obj-code
      ) no-error .
          if error-status :error then do:
              v-msg = vss-workfile + " " + vss-revision  + " " + vss-description + "~n" +
                      error-status :get-message(1) + "~n" +
                      return-value + "~n" +
                      "chec-par"
                      .
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.

          end.
    { gbl/partmrgn.i
        parparentproc
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        par-gen-mrgn-ie-parts
        par-gen-mrgn-iv-parts
        par-gen-mrgn-im-parts
      no-error }
   if error-status :error then do:
      run waitfram-hide in this-procedure no-error.
      return error substitute( 'На объекте &1 &2  не определен ГТПЛ для автопереоценок.'
                                ,ub.trn-doc.obj-type
                                ,ub.trn-doc.obj-code
                              ).
   end.

    is-after-margin-parts = false .
    if  par-gen-mrgn-ie-parts = {&typeprice_after-margin} or
        par-gen-mrgn-iv-parts = {&typeprice_after-margin} or
        par-gen-mrgn-im-parts = {&typeprice_after-margin} then do:

        is-after-margin-parts = true .
    end.

if ( gen-mode = "cost-price" or
     gen-mode = "before-margin"  ) and  ub.trn-doc.is-back-date = true  then do:
  /* автоматическая переоценка для cost-price не создается с задним числом  */
  return.
end.

if not ( par-pr-parex = "yes" and
         par-pr-notls = "yes" ) and
         gen-mode = "after-margin-parts" then do:
/* автопереоценки по партиям не создаются если не разрешены сохранения партий в переоценке */
         return .
 end.

  run waitfram-show in this-procedure ( "Расчет продажной цены... " ) .
  if gen-mode = "before-internal" then gen-mode = "before-margin" . /* на всякий случай старый код обработаем */

  cre-pr:
  do on error undo cre-pr, return error:
    gds-dtl:
    for each ub.gds-dtl where
        ub.gds-dtl.doc-code = ub.trn-doc.doc-code ,
       first ub.doc-line no-lock where
                ub.doc-line.doc-code  = ub.gds-dtl.doc-code and
                ub.doc-line.artic     = ub.gds-dtl.artic and
                ub.doc-line.prod-type = ub.gds-dtl.prod-type and
                ub.doc-line.prod-code = ub.gds-dtl.prod-code ,
      first ub.goods no-lock where
                ub.goods.artic     = ub.gds-dtl.artic and
                ub.goods.prod-type = ub.gds-dtl.prod-type and
                ub.goods.prod-code = ub.gds-dtl.prod-code
        by ub.doc-line.line-num
        on error undo cre-pr, return error:

        run ver-modificator-price-is-null (
            input    ub.goods.artic        ,
            input    ub.goods.prod-type    ,
            input    ub.goods.prod-code    ,
            input    ub.trn-doc.obj-type   ,
            input    ub.trn-doc.obj-code   ,
            output   v-ret ).
        if v-ret = false then next.

      if ub.gds-dtl.fact-qnty = 0 then do:
        /* такую строку можно закрывать, авт. переоценки не будет */
        next gds-dtl. /* --->>>--- */
      end.
      find ub.units where
          ub.units.unit-name = ub.goods.unit-base no-lock.
      if lookup ({&petrolium}, ub.units.type) <> 0 then do:
        /* для топлива не генерим */
        next gds-dtl.  /* --->>>--- */
      end.

      /* находим главный код */
      { gbl/gdsbcode.i
        ub.goods.gds-code
        ?
        v-root-b-code }
      /* находим цену главного кода */
      { gbl/bcodeprc.i
        gds-dtl.obj-type
        gds-dtl.obj-code
        v-root-b-code
        0
        0
        gp-doc-num
        gp-price-sale
        gp-road-tax
        gp-excise
        no-error }
      /* проверяем, что товар в найденной переоценке не имеет спеццен (неосновные можно)
        после первого же найденного вылетаем */
      if gen-mode = "before-margin" or
         gen-mode = "after-margin"  then do:
          for each ub.price-list where
                   ub.price-list.doc-num    = gp-doc-num and
                   ub.price-list.artic      = ub.goods.artic and
                   ub.price-list.prod-type  = ub.goods.prod-type and
                   ub.price-list.prod-code  = ub.goods.prod-code and
                   ub.price-list.main-price = no ,
              first ub.bar-code no-lock where
                    ub.bar-code.b-code = ub.price-list.b-code and
                    ub.bar-code.unit-cli = ub.goods.unit-base
          :
              next gds-dtl   .
          end.
         /* Пропускаем все, что продаются по партиям */
         if is-after-margin-parts = true and
            gen-mode = "after-margin"   then do:
            /* эти выносим в отдельную переоценку */
            find first ub.gds-obj no-lock where
                  ub.gds-obj.gds-code = ub.goods.gds-code and
                  ub.gds-obj.obj-type = ub.trn-doc.obj-type and
                  ub.gds-obj.obj-code = ub.trn-doc.obj-code and
                  ub.gds-obj.cash-parts = true
            no-error .
            if available ub.gds-obj then
               next gds-dtl.  /* --->>>--- */
           end.

        end.

      /* проверяем, что товар в найденной переоценке только товары прод по партиям     */
      if  gen-mode = "after-margin-parts"  then do:
         find first ub.gds-obj no-lock where
              ub.gds-obj.gds-code = ub.goods.gds-code and
              ub.gds-obj.obj-type = ub.trn-doc.obj-type and
              ub.gds-obj.obj-code = ub.trn-doc.obj-code and
              ub.gds-obj.cash-parts = false  no-error .
            if available ub.gds-obj then
               next gds-dtl.  /* --->>>--- */

          for each ub.price-list where
                   ub.price-list.doc-num    = gp-doc-num and
                   ub.price-list.artic      = ub.goods.artic and
                   ub.price-list.prod-type  = ub.goods.prod-type and
                   ub.price-list.prod-code  = ub.goods.prod-code and
                   ub.price-list.main-price = no ,
              first ub.bar-code no-lock where
                    ub.bar-code.b-code = ub.price-list.b-code and
                    ub.bar-code.in-code  = "" and
                    ub.bar-code.unit-cli = ub.goods.unit-base
          :
              next gds-dtl   .
          end.
      end.


      if gen-mode = "cost-price" then do:
        { str/get-pr.i calc ub.gds-dtl.obj-type ub.gds-dtl.obj-code ub.goods.gds-code ub.gds-dtl.prt-code }

        if v-cntxp-no-eq /* запрещен приход при отсутствии цен */ and
          gp-price-sale = ? then do:
          v-msg = "Артикул: " + ub.goods.artic + "~n" +
                  "Производитель: " + ub.goods.prod-type + " " + string(ub.goods.prod-code) + "~n" +
                  ub.goods.gds-name + "~n" +
                  "Продажная цена отсутствует." + "~n" + "~n" +
                  "Для " + v-cntxt-obj-type + " " + string(v-cntxt-obj-code) + " запрещено закрывать такой приход." + "~n" +
                  "Сделайте переоценку по этой накладной.".
          if not g#news and
             not g#auto and
             not g#esys
          then
             message v-msg view-as alert-box error.

          undo cre-pr, return error v-msg.
        end.
        find ub.prt-obj where
            ub.prt-obj.obj-type  = ub.gds-dtl.obj-type and
            ub.prt-obj.obj-code  = ub.gds-dtl.obj-code and
            ub.prt-obj.prod-type = ub.gds-dtl.prod-type and
            ub.prt-obj.prod-code = ub.gds-dtl.prod-code and
            ub.prt-obj.artic     = ub.gds-dtl.artic and
            ub.prt-obj.prt-code  = ub.gds-dtl.prt-code no-error.
        if
          ( var-pr-r-b = "rubl" and ub.gds-dtl.price-rubl = gp-price-sale ) or
          ( var-pr-r-b = "base" and ub.gds-dtl.price-base = gp-price-sale )
        then do:
          /* цены совпадают, переоценки не требуется */
          next . /* --->>>--- */
        end.
        if available ub.prt-obj and
          ub.prt-obj.fact-qnty <> 0 or
          gp-price-sale <> ? then do:
          /* если по товару есть остаток или уже установлена цена, переоценивать нельзя */
          if v-cntxp-price-calc then do:
            if gp-price-sale <> ? then do:
              v-msg = "Артикул: " + ub.goods.artic + "~n" +
                      "Производитель: " + ub.goods.prod-type + " " + string(ub.goods.prod-code) + "~n" +
                      ub.goods.gds-name + "~n" +
                      "Приходная цена отличается от продажной." + "~n" + "~n" +
                      "Для " + v-cntxt-obj-type + " " + string(v-cntxt-obj-code) + " запрещено закрывать такой приход." + "~n" +
                      "Сделайте переоценку по этой накладной.".
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.
            end.
            else do:
              v-msg = "Артикул: " + ub.goods.artic + "~n" +
                      "Производитель: " + ub.goods.prod-type + " " + string(ub.goods.prod-code) + "~n" +
                      ub.goods.gds-name + "~n" +
                      "Продажная цена отсутствует, но остаток ненулевой." + "~n" + "~n" +
                      "Для " + v-cntxt-obj-type + " " + string(v-cntxt-obj-code) + " запрещено закрывать приход, " +
                      "если приходные цены отличаются от продажных." + "~n" +
                      "Сделайте переоценку по этой накладной.".
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.
            end.
            undo cre-pr, return error v-msg.
          end.
          /* переоценку делать по этому товару нельзя - идем дальше */
          next . /* --->>>--- */
        end.
      end.

      /* делаем документ переоценки */
      if not available ub.price-doc then do:
        /* найти ГТПЛ */
        run find-main-plt in this-procedure
            (input v-cntxt-obj-type
            ,input v-cntxt-obj-code
            ,output v-plt-id
            ,output v-plt-db-num
            ,output v-round-method
            ,output v-round-base) no-error .

          if error-status :error then   do:
            undo cre-pr, return error "Ошибка поиска ГТПЛ".
          end.
        /* Создать ДНЦ */
          run create_new_price-doc-forming (
                input   v-cntxt-obj-type
              , input   v-cntxt-obj-code
              , output  v-pdf-db-num
              , output  v-pdf-id
              , output  v-plt-db-num
              , output  v-plt-id     ) no-error .
        find first  ub.price-doc-forming exclusive-lock where
                    ub.price-doc-forming.plt-id       = v-plt-id       and
                    ub.price-doc-forming.plt-db-num   = v-plt-db-num   and
                    ub.price-doc-forming.pdf-id       = v-pdf-id       and
                    ub.price-doc-forming.pdf-db       = v-pdf-db-num   no-error .
          if error-status :error then   do:
            undo cre-pr, return error "Ошибка создания ДНЦ " + error-status :get-message(1) .
          end.

        assign
            ub.price-doc-forming.out-code     = ub.trn-doc.doc-code
       .

        create ub.price-doc .
        define variable l-d-n   like ub.price-doc.doc-num no-undo .
        run doc-code in this-procedure
         ( input "main",
           input v-cntxt-obj-type,
           input v-cntxt-obj-code,
           input ?,
           output ub.price-doc.doc-num )
           no-error.
          l-d-n = ub.price-doc.doc-num.
        if error-status:error then do:
          v-msg = "Ошибка при генерации номера документа" + "~n" +
                  return-value.
          if not g#news and
             not g#auto and
             not g#esys
          then
             message v-msg view-as alert-box error.         

          undo cre-pr, return error v-msg.
        end.
        assign
          ub.price-doc.plt-id     = v-plt-id
          ub.price-doc.plt-db-num = v-plt-db-num
          ub.price-doc.pdf-id     = v-pdf-id
          ub.price-doc.pdf-db     = v-pdf-db-num
          ub.price-doc.doc-date   = ub.trn-doc.doc-date
          ub.price-doc.fact-num   = 0
          ub.price-doc.host-code  = v-cntxt-host-code-obj
          ub.price-doc.cr-db-num  = v-cntxt-db-num
          ub.price-doc.obj-code   = ub.trn-doc.obj-code
          ub.price-doc.obj-type   = ub.trn-doc.obj-type
          ub.price-doc.rest-base  = 0
          ub.price-doc.rest-last  = 0
          ub.price-doc.rest-qnty  = ?
          ub.price-doc.rest-sale  = 0
          ub.price-doc.sale-base  = 0
          ub.price-doc.out-code   = ub.trn-doc.doc-code
          l-d-n                   = ub.price-doc.doc-num
          .
        case gen-mode :
          when "cost-price" then do:
            /* примечание без @ - автоматически уже не будет изменено */
            ub.price-doc.PS = "Цены продажи новых товаров по ПН № " + ub.trn-doc.doc-code + " устанавливаются = приходным.".
            { str/tdat-wrt.i
              ub.price-doc.doc-num
              {&trdcattr-first-price}
              'yes'
             }
            run  pdoc-forming-attr (
                 ub.price-doc.plt-id     ,
                 ub.price-doc.plt-db-num ,
                 ub.price-doc.pdf-id     ,
                 ub.price-doc.pdf-db     ,
                 {&trdcattr-first-price} ,
                 'yes' ) .
          end.
          when "after-margin" then do:
            /* примечание с @ - автоматически будет приписано Число строк в акте */
            ub.price-doc.PS = "@  Стандартная торговая наценка подготовлена для ПН № " + ub.trn-doc.doc-code.
          end.
          when "after-margin-parts" then do:
            /* примечание с @ - автоматически будет приписано Число строк в акте */
            ub.price-doc.PS = "По партиям , подготовлена для ПН № " + ub.trn-doc.doc-code.
          end.

          when "before-margin" then do:
            /* примечание без @ - автоматически уже не будет изменено */
            ub.price-doc.PS = "Принудительная стандартная торговая наценка закрыта до ПН № " + ub.trn-doc.doc-code.
          end.
        end case .
      end.
      run cre-pr-list ( input  v-root-b-code,
                        input  ub.price-doc.doc-num,
                        output pr-list-rec)
                        no-error .
      if error-status :error then do:
        undo cre-pr, return error.
      end.

      find first ub.price-list where
                 ub.price-list.doc-num    = ub.price-doc.doc-num and
                 ub.price-list.price-type = "" and
                 ub.price-list.b-code     = v-root-b-code
                 no-error .
      if error-status :error then do:
        undo cre-pr, return error substitute(" Не найдена запись в переоценке № &1 по бар-коду &2" ,price-doc.doc-num ,v-root-b-code ).
        end.


      find first b1-doc-line where
                b1-doc-line.doc-code   = ub.trn-doc.doc-code   and
                b1-doc-line.artic      = ub.price-list.artic     and
                b1-doc-line.prod-type  = ub.price-list.prod-type and
                b1-doc-line.prod-code  = ub.price-list.prod-code no-lock no-error .

      ub.price-list.road-tax   = if avail b1-doc-line then  b1-doc-line.road-tax  else ? .
      Assign
        p-flag  = false
        p-new-road-tax = ub.price-list.road-tax
        .
      run compare_road-tax
                        ( input-output p-new-road-tax ,
                          input ub.price-list.b-code     ,
                          input ub.price-list.obj-type   ,
                          input ub.price-list.obj-code   ,
                          input no ) .
      if p-new-road-tax <> ub.price-list.road-tax Then do:
        p-flag = true .
      End.
      doc-code = ub.trn-doc.doc-code.
      case gen-mode :
        when "cost-price" then do:
          assign
            ub.price-list.doc-qnty   = 0
            ub.price-list.fact-order = 0
            ub.price-list.price-sale = if var-pr-r-b = "rubl" then gds-dtl.price-rubl else gds-dtl.price-base
            .
        end.
        when "after-margin-parts"  then do:
            /* для after-margin возможны партии из ПН , если товар продается по партиям */

         find first ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = ub.goods.gds-code and
                    ub.gds-obj.obj-type = ub.price-doc.obj-type and
                    ub.gds-obj.obj-code = ub.price-doc.obj-code and
                    ub.gds-obj.cash-parts = true no-error .
          if available ub.gds-obj then do:
          v-parts = true .
          line-mode = "calc":u.
          par-pr-nakl = false .
          if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then par-pr-nakl = par-pr-nakl-ie .
          if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Perem} then par-pr-nakl = par-pr-nakl-iv .
          if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Prvo}  then par-pr-nakl = par-pr-nakl-im .
              if par-pr-parex = "yes" and
                 par-pr-notls = "yes" then do:
                  run calc-pr-list
                    ( input v-root-b-code,
                      input ub.price-doc.doc-num,
                      input {&pr-calc-no},
                      input ?,
                      input v-round-method,
                      input v-round-base,
                      input ?,
                      input ?,
                      input ?,
                      input ?,
                      output calc-rec
                    ) no-error.
              end.

              if var-pr-r-b = "rubl"
                  then  ub.price-list.price-sale = b1-doc-line.price-rubl.
                  else  ub.price-list.price-sale = b1-doc-line.price-base.

              for each ub.parts no-lock where
                       ub.parts.out-code  = b1-doc-line.doc-code and
                       ub.parts.artic     = b1-doc-line.artic and
                       ub.parts.prod-code = b1-doc-line.prod-code and
                       ub.parts.prod-type = b1-doc-line.prod-type :

                    { gbl/partbcod.i
                       ub.parts
                       v1-b-code }

                  run cre-pr-list
                      ( input  v1-b-code,
                        input  ub.price-doc.doc-num ,
                        output new-rec) no-error.

                  if ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}  then do:
                  run gds-attr-margin-value
                  ( input   ub.gds-obj.gds-code ,
                    input   v-cntxt-obj-type   ,
                    input   v-cntxt-obj-code ,
                    output  p-prc-min            ,
                    output  p-prc-max            ,
                    output  loc-grp-increase-pc  ,
                    output  loc-grp-round-method ,
                    output  loc-grp-round-base   ,
                    output  p-value-margin       ,
                    output  p-type-margin        ,
                    output  p-value-increase     ,
                    output  p-type-increase      ,
                    output  p-value-rmethod      ,
                    output  p-type-rmethod
                    ) no-error .
                  find first n1_price-list exclusive-lock where
                             n1_price-list.doc-num    = ub.price-doc.doc-num and
                             n1_price-list.price-type = "" and
                             n1_price-list.b-code     = v1-b-code no-error .
                      if available n1_price-list then do:
                          run lineattr-value-parts (
                               input b1-doc-line.doc-code
                              ,input ub.gds-obj.gds-code
                              ,input ub.parts.part-code
                              ,input ub.parts.in-code
                              ,input {&lineattr-parts_price-sale}
                              ,output n1_price-list.price-sale ) no-error .
                          run ggoattr-value (
                             input   goods.grp-code
                            ,input   v-cntxt-host-code-obj
                            ,input   ub.price-list.obj-type
                            ,input   ub.price-list.obj-code
                            ,input   {&ggoattr-marg-pr-paraf}
                            ,output  attr-marg-pr-paraf
                            ,output  v-type ) no-error .
                          if n1_price-list.price-sale = 0 or n1_price-list.price-sale = ? then do:
                             n1_price-list.price-sale = ub.gds-obj.price-sale .
                          end.
                          if attr-marg-pr-paraf = ? or attr-marg-pr-paraf = "" then attr-marg-pr-paraf = "0" .
                          n1_price-list.price-sale = n1_price-list.price-sale * ( 1 + decimal (attr-marg-pr-paraf) / 100 ).
                          { str/pr-99.i
                            n1_price-list.price-sale
                            loc-grp-round-method
                            loc-grp-round-base
                          }
                          ub.price-list.price-sale = n1_price-list.price-sale .
                      end.
                   end.
                   else do:
                        run calc-pr-list
                          ( input v1-b-code,
                            input ub.price-doc.doc-num,
                            input {&pr-calc-goods},
                            input ?,
                            input v-round-method,
                            input v-round-base,
                            input ?,
                            input ?,
                            input ?,
                            input ?,
                            output calc-rec
                          )
                          no-error.
                          find first ub.price-list no-lock where recid( ub.price-list) =  calc-rec no-error .
                          if available ub.price-list then do:
                              assign
                               v-last-price-sale  = ub.price-list.price-sale
                               v-last-calc-method = ub.price-list.calc-method
                              .
                          end.
                   end.

              end.
          /* главному коду присвоим последнее значение*/
             find first ub.price-list exclusive-lock where
                        ub.price-list.doc-num   = ub.price-doc.doc-num  and
                        ub.price-list.main-price = true   and
                        ub.price-list.artic     = b1-doc-line.artic     and
                        ub.price-list.prod-code = b1-doc-line.prod-code and
                        ub.price-list.prod-type = b1-doc-line.prod-type no-error .
             if available ub.price-list then do:
                assign
                  ub.price-list.price-sale  = v-last-price-sale
                  ub.price-list.calc-method = v-last-calc-method
                .
             end.
          end.

        end.
        when "after-margin"  or
        when "before-margin" then do:
          /* нужно посчитать цену способом из ub.goods */
          define variable p-line-mode as character no-undo .
          p-line-mode = line-mode .
          line-mode = "calc":u.
          par-pr-nakl = false .
          if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then par-pr-nakl = par-pr-nakl-ie .
          if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Perem} then par-pr-nakl = par-pr-nakl-iv .
          if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Prvo}  then par-pr-nakl = par-pr-nakl-im .

          if    b1-doc-line.new-price-sale > 0
            and b1-doc-line.new-price-sale <> ?
            and par-pr-nakl = yes
            and ub.trn-doc.ext-doc-type <> {&tdedt_Pri_Perem}
          then do:
              run calc-npricesale-doc-line
                ( input v-root-b-code,
                  input ub.price-doc.doc-num,
                  input b1-doc-line.doc-code ,
                  input b1-doc-line.new-price-sale ,
                  output calc-rec
                )
                no-error.
          end.
          else if gds-dtl.new-price-sale > 0
              and gds-dtl.new-price-sale <> ?
              and par-pr-nakl = yes
              and ub.trn-doc.ext-doc-type = {&tdedt_Pri_Perem}
          then do:
              run calc-npricesale-doc-line
                ( input v-root-b-code,
                  input ub.price-doc.doc-num,
                  input gds-dtl.doc-code ,
                  input gds-dtl.new-price-sale ,
                  output calc-rec
                )
                no-error.
          end.
          else do:
              run calc-pr-list
                ( input v-root-b-code,
                  input ub.price-doc.doc-num,
                  input {&pr-calc-goods},
                  input ?,
                  input v-round-method,
                  input v-round-base,
                  input ?,
                  input ?,
                  input ?,
                  input ?,
                  output calc-rec
                )
                no-error.
          end.
          if error-status :error then do:
            line-mode = p-line-mode .
            undo cre-pr, return error.
          end.
          line-mode = p-line-mode .
        end.
      end case.

    end. /* for each */

    find first ub.price-doc  exclusive-lock  where ub.price-doc.doc-num = l-d-n no-error .
    if available ub.price-doc then do:
       if v-parts = true then do:
          ub.price-doc.PS = "По ПН № " + ub.trn-doc.doc-code + " Создана переоценка цены = продажная цена партий".
       end.

      /* проверка параметра pr-equ-dq */
      run ver-pr-equ-dq  ( input ub.price-doc.doc-num, input 1, input "" ) no-error .
      if error-status :error then do:
            v-msg = vss-workfile + " " + vss-revision  + " " + vss-description + "~n" +
                    "Ошибка при удалении строки переоценки " + "~n" +
                    ub.price-doc.doc-num  + "~n" +
                    error-status :get-message(1).
            if not g#news and
               not g#auto and
               not g#esys
            then
               message v-msg view-as alert-box information.

            undo cre-pr, return error v-msg.
      end.

      /* может его и не быть, если нечего было переоценивать */
      if p-flag = true then  do:
        run tax-name (input {&road-tax} ,output v-name-tax ).
        ub.price-doc.PS = ub.price-doc.PS + "  Компонент цены '" + string(v-name-tax) +  "' изменен с прошлой переоценки ." .
      end.

      case gen-mode :
        when "cost-price" then do:
          assign
            ub.price-doc.out-code   = ub.trn-doc.doc-code
            ub.price-doc.fact-date  = ub.trn-doc.fact-date
            ub.price-doc.fact-time  = ub.trn-doc.fact-time
            ub.price-doc.shift-date = ub.trn-doc.shift-date
            ub.price-doc.shift-num  = ub.trn-doc.shift-num
            ub.price-doc.shift-name = ub.trn-doc.shift-name
            ub.price-doc.status_    = {&act-overvalue}
            .
        end.

        when "after-margin" then do:
          assign
            ub.price-doc.status_ = {&g___new}
            .
        end.
        when "after-margin-parts" or
        when "before-margin" then do:
          assign
            ub.price-doc.fact-date  = ub.trn-doc.fact-date
            ub.price-doc.fact-time  = ub.trn-doc.fact-time
            ub.price-doc.shift-date = ub.trn-doc.shift-date
            ub.price-doc.shift-num  = ub.trn-doc.shift-num
            ub.price-doc.shift-name = ub.trn-doc.shift-name
            ub.price-doc.status_    = {&g___new}
            .
          /* расчет и закрытие переоценки до АКТ */

          run str/pr-stat.p (  input parParentProc
                             , input v-log-handle
                             , input "close-act"
                             , input ub.price-doc.doc-num
                             , input ub.trn-doc.doc-code
                             , input true
                             , input false  ) no-error .
          if error-status :error then do:
              v-msg = vss-workfile + " " + vss-revision  + " " + vss-description + "~n" +
                      error-status :get-message(1) + "~n" +
                      return-value + "~n" +
                      "Расчет и закрытие переоценки до АКТ"
                      .
              if not g#news and
                 not g#auto and
                 not g#esys
              then
                 message v-msg view-as alert-box error.

              undo cre-pr, return error v-msg.
          end.
        end.
      end case .

      define variable tt as recid  no-undo .
      tt =  recid (price-doc) .

      if not can-find (first ub.price-list where ub.price-list.doc-num = l-d-n no-lock ) then do:
         v-msg = "Обратите ВНИМАНИЕ !!! В документе  переоценки " + l-d-n + " нет ни одной строки. " + "~n" +
                 "документ удаляется " + caps({&g___new}).
         if not g#news and
            not g#auto and
            not g#esys
         then
            message v-msg view-as alert-box error.

          undo cre-pr, return.
      end.
      assign
        v-rest-last =  ub.price-doc.rest-last
        v-rest-sale =  ub.price-doc.rest-sale
        v-sale-base =  ub.price-doc.sale-base
        v-rest-qnty =  ub.price-doc.rest-qnty
      .
      release ub.price-doc no-error.  /* чтоб при повторном вызове с другим параметром не писала в тот же документ */
      if error-status :error then do:
        undo cre-pr, return error.
      end.

      /* доСоздать ДНЦ и строки и ДЕНОРМ.ЦЕНЫ по всем + переоценки по другим объектам группы */
      run create-dfc in this-procedure (
          input v-plt-id
         ,input v-plt-db-num
         ,input v-pdf-id
         ,input v-pdf-db-num
         ,input l-d-n
         ,input ub.trn-doc.base-rate
         ,input ub.trn-doc.base-scale
         ) .

define buffer test_price-doc for ub.price-doc  .
      if  gen-mode =  "cost-price" or
          gen-mode = "before-margin" or
          gen-mode = "after-margin-parts"
        then  do:
           /*  переоценки до АКТ */
            find first test_price-doc no-lock where test_price-doc.doc-num = l-d-n no-error .
            if available test_price-doc then do:
                run str/pr-stat.p
                  ( input parParentProc,
                    input v-log-handle ,
                    input "act",
                    input l-d-n,
                    input ub.trn-doc.doc-code ,
                    input true ,
                    input true ).
                /* Синхронизация c ub.gds-obj  ( p r - t o t . p )  */
                  find first test_price-doc exclusive-lock where
                              test_price-doc.doc-num = l-d-n
                              no-error .
                  if available test_price-doc then do:
                      assign
                        test_price-doc.rest-last = v-rest-last
                        test_price-doc.rest-qnty = v-rest-qnty
                        test_price-doc.rest-sale = v-rest-sale
                        test_price-doc.sale-base = v-sale-base
                      .
                  end.
            end.
/*            TODO печать ценников на новый товар 2 раза */
            run str/pr-pr.p ( parParentProc , tt ).
      end.
    end.
  end.
  run waitfram-hide in this-procedure.
end.



PROCEDURE exp-prt:
/* ------------------------------------------------------------------------------------------------------------------------
   разворачивание неосновных цен по главной цене
   ------------------------------------------------------------------------------------------------------------------------*/
define input  parameter g-code  like ub.goods.gds-code    no-undo.
define input  parameter old-num like ub.price-doc.doc-num no-undo. /* номер старой переоценки */
define input  parameter new-num like ub.price-doc.doc-num no-undo. /* номер новой переоценки */
define output parameter new-rec as recid               no-undo.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-price-list for ub.price-list.


find buf-goods no-lock where
     buf-goods.gds-code = g-code.

/* Добавлять имеющиеся неосновные цены */
exp-alt:
do on error undo exp-alt, return error:

{ str/alt-calc.i pr-altex old-num new-num }
  if par-pr-parex = "yes" and
     par-pr-notls = "yes" then do:
      { str/alt-calc.i pr-parex old-num new-num }
  end.

end.
END PROCEDURE.


procedure ver-par-disc-mar :
 do
 on error undo, return error return-value
 :
define input parameter   p-obj-type    like ub.clients.obj-type no-undo .
define input parameter   p-obj-code    like ub.clients.obj-type no-undo .
define input parameter   p-node-code   like ub.goods.grp-code no-undo .
define output parameter  par-disc-mar  as logical no-undo .


define variable p-host-code       as integer no-undo .
define variable p-prc-min         as decimal no-undo .
define variable p-prc-max         as decimal no-undo .
define variable p-increase-pc     as decimal no-undo .
define variable p-round-method    as character no-undo .
define variable p-base            as decimal no-undo .
define variable p-value-margin    as integer  no-undo.
define variable p-type-margin     as logical no-undo .
define variable p-value-increase  as integer  no-undo.
define variable p-type-increase   as logical no-undo .
define variable p-value-rmethod   as integer  no-undo.
define variable p-type-rmethod    as logical no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .

 par-disc-mar = false .
{ gbl/hostcode.i p-obj-type p-obj-code p-host-code }

empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
  ,input {&attr-overval}
  ,input  "pr-discm"
  ,output par-pr-discm
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

if trim(par-pr-discm) = "" then return .

run grp-obj-margin-value
( input   p-node-code ,
  input   p-obj-type  ,
  input   p-obj-code  ,
  output  p-prc-min  ,
  output  p-prc-max  ,
  output  p-increase-pc,
  output  p-round-method ,
  output  p-base         ,
  output  p-value-margin    ,
  output  p-type-margin,
  output  p-value-increase,
  output  p-type-increase  ,
  output  p-value-rmethod,
  output  p-type-rmethod

  ) .

if p-type-margin = false  then return.

par-disc-mar = true  .

 end. /* do */
end procedure. /* ver-par-disc-mar */


procedure create-dfc :
define input  parameter v-plt-id      as integer   no-undo .
define input  parameter v-plt-db-num  as integer   no-undo .
define input  parameter v-pdf-id      as integer   no-undo .
define input  parameter v-pdf-db-num  as integer   no-undo .
define input  parameter v-doc-num     as character no-undo .
define input  parameter p-base-rate   as decimal   no-undo .
define input  parameter p-base-scale  as decimal   no-undo .

define buffer red_price-doc for ub.price-doc  .
define buffer red_price-list for ub.price-list  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-all for ub.price-all  .

define variable v-price-calc-base  as decimal   no-undo .
define variable v-price-calc-doc   as decimal   no-undo .
define variable v-price-calc-rubl  as decimal   no-undo .
define variable v-price-prev-base  as decimal   no-undo .
define variable v-price-prev-doc   as decimal   no-undo .
define variable v-price-prev-rubl  as decimal   no-undo .
define variable v-price-sale-base  as decimal   no-undo .
define variable v-price-sale-doc   as decimal   no-undo .
define variable v-price-sale-rubl  as decimal   no-undo .
define variable v-road-tax-base    as decimal   no-undo .
define variable v-road-tax-doc     as decimal   no-undo .
define variable v-road-tax-rubl    as decimal   no-undo .
define variable v-excise-base      as decimal   no-undo .
define variable v-excise-doc       as decimal   no-undo .
define variable v-excise-rubl      as decimal   no-undo .
define variable v-type as character no-undo .
define variable v-code as integer   no-undo .
define variable v-prev-doc-code as character no-undo .

define variable v-status as integer   no-undo .
  do
  on error undo, return error return-value
  :
run waitfram-show in this-procedure ( "Создание документа формирования цены... " ) .
find first red_price-doc no-lock where
           red_price-doc.doc-num = v-doc-num
           no-error .
find first buf_price-doc-forming exclusive-lock where
           buf_price-doc-forming.plt-id     = v-plt-id      and
           buf_price-doc-forming.plt-db-num = v-plt-db-num  and
           buf_price-doc-forming.pdf-id     = v-pdf-id      and
           buf_price-doc-forming.pdf-db     = v-pdf-db-num
           no-error .
/* На этом объекте переоценка создалась ее создавать не надо а цены-ден надо  */
assign
  v-type = red_price-doc.obj-type
  v-code = red_price-doc.obj-code
.

assign
   buf_price-doc-forming.name = trim ( trim (red_price-doc.ps, "@" ))
   buf_price-doc-forming.stts = integer({&pdf-new})
   v-status = ( if red_price-doc.status_ = {&g___new} then integer({&pdf-new}) else integer({&pdf-fact}) )
.

/* 1. по подготовленной переоценке */
for each red_price-list no-lock  where red_price-list.doc-num = v-doc-num :
if var-pr-r-b = "rubl" then do:
 v-price-calc-rubl  = red_price-list.price-calc .
 v-price-calc-base  = v-price-calc-rubl / p-base-rate * p-base-scale .
 v-price-calc-doc   = red_price-list.price-calc .

 v-price-prev-rubl  = red_price-list.price-prev  .
 v-price-prev-base  = v-price-prev-rubl / p-base-rate * p-base-scale .
 v-price-prev-doc   = red_price-list.price-prev  .

 v-price-sale-rubl  = red_price-list.price-sale  .
 v-price-sale-base  = v-price-sale-rubl / p-base-rate * p-base-scale .
 v-price-sale-doc   = red_price-list.price-sale  .

 v-road-tax-rubl    = red_price-list.road-tax    .
 v-road-tax-base    = v-road-tax-rubl   / p-base-rate * p-base-scale .
 v-road-tax-doc     = red_price-list.road-tax    .

 v-excise-rubl      = red_price-list.excise      .
 v-excise-base      = v-excise-rubl     / p-base-rate * p-base-scale .
 v-excise-doc       = red_price-list.excise      .
 end.
else do:
 v-price-calc-base  = red_price-list.price-calc .
 v-price-calc-rubl  = v-price-calc-base * p-base-rate / p-base-scale .
 v-price-calc-doc   = red_price-list.price-calc .

 v-price-prev-base  = red_price-list.price-prev  .
 v-price-prev-rubl  = v-price-prev-base * p-base-rate / p-base-scale .
 v-price-prev-doc   = red_price-list.price-prev  .

 v-price-sale-base  = red_price-list.price-sale  .
 v-price-sale-rubl  = v-price-sale-base * p-base-rate / p-base-scale .
 v-price-sale-doc   = red_price-list.price-sale  .

 v-road-tax-base    = red_price-list.road-tax    .
 v-road-tax-rubl    = v-road-tax-base   * p-base-rate / p-base-scale .
 v-road-tax-doc     = red_price-list.road-tax    .

 v-excise-base      = red_price-list.excise      .
 v-excise-rubl      = v-excise-base     * p-base-rate / p-base-scale .
 v-excise-doc       = red_price-list.excise      .
end.

    /* 2. Создадим ДНЦ */
    create buf_price-doc-forming-gds.
    assign
       buf_price-doc-forming-gds.pdf-db            = v-pdf-db-num
       buf_price-doc-forming-gds.pdf-id            = v-pdf-id
       buf_price-doc-forming-gds.plt-db-num        = v-plt-db-num
       buf_price-doc-forming-gds.plt-id            = v-plt-id
       buf_price-doc-forming-gds.line-num          = red_price-list.line-num
       buf_price-doc-forming-gds.artic             = red_price-list.artic
       buf_price-doc-forming-gds.prod-code         = red_price-list.prod-code
       buf_price-doc-forming-gds.prod-type         = red_price-list.prod-type
       buf_price-doc-forming-gds.b-code            = red_price-list.b-code
       buf_price-doc-forming-gds.calc-method       = red_price-list.calc-method
       buf_price-doc-forming-gds.d-pcnt            = red_price-list.d-pcnt
       buf_price-doc-forming-gds.end-date          = ?
       buf_price-doc-forming-gds.end-shift-date    = ?
       buf_price-doc-forming-gds.end-shift-name    = ?
       buf_price-doc-forming-gds.end-shift-num     = ?
       buf_price-doc-forming-gds.end-sys-date      = ?
       buf_price-doc-forming-gds.end-sys-time      = ?
       buf_price-doc-forming-gds.have-end-period   = int(false)
       buf_price-doc-forming-gds.have-start-period = int(false)
       buf_price-doc-forming-gds.price-calc-base   =  v-price-calc-base
       buf_price-doc-forming-gds.price-calc-doc    =  v-price-calc-doc
       buf_price-doc-forming-gds.price-calc-rubl   =  v-price-calc-rubl
       buf_price-doc-forming-gds.price-prev-base   =  v-price-prev-base
       buf_price-doc-forming-gds.price-prev-doc    =  v-price-prev-doc
       buf_price-doc-forming-gds.price-prev-rubl   =  v-price-prev-rubl
       buf_price-doc-forming-gds.price-sale-base   =  v-price-sale-base
       buf_price-doc-forming-gds.price-sale-doc    =  v-price-sale-doc
       buf_price-doc-forming-gds.price-sale-rubl   =  v-price-sale-rubl
       buf_price-doc-forming-gds.road-tax-base     =  v-road-tax-base
       buf_price-doc-forming-gds.road-tax-doc      =  v-road-tax-doc
       buf_price-doc-forming-gds.road-tax-rubl     =  v-road-tax-rubl
       buf_price-doc-forming-gds.excise-base       =  v-excise-base
       buf_price-doc-forming-gds.excise-doc        =  v-excise-doc
       buf_price-doc-forming-gds.excise-rubl       =  v-excise-rubl
       buf_price-doc-forming-gds.vat-pc            = red_price-list.vat-pc
       buf_price-doc-forming-gds.slt-pc            = red_price-list.slt-pc
       buf_price-doc-forming-gds.start-date        = ?
       buf_price-doc-forming-gds.start-shift-date  = ?
       buf_price-doc-forming-gds.start-shift-name  = ?
       buf_price-doc-forming-gds.start-shift-num   = ?
       buf_price-doc-forming-gds.start-sys-date    = ?
       buf_price-doc-forming-gds.start-sys-time    = ?
       buf_price-doc-forming-gds.stts              = buf_price-doc-forming.stts
       .
end.
 /* 3. Удалим ее если сможем */
 if red_price-doc.status_ = {&g___new}  then do:
    find first red_price-doc exclusive-lock where
               red_price-doc.doc-num = v-doc-num
               no-error .
    delete red_price-doc.
 end.

/* Для открытой ДНЦ дальше действуем как в ручном создании  */
/* Для закрытых ДНЦ сформировать денорм цены */
    if v-status <> 0 then do:
        run str/diallog.w
            (parparentproc
            , this-procedure
            , 'str/pdf-clos.p':U
            , ( string(recid(buf_price-doc-forming)) + {&delim-par} +
              'yes' + {&delim-par} +
              'no' + {&delim-par} +
              v-type + {&delim-par} +
              string(v-code) + {&delim-par} +
              ( if gen-mode =  "cost-price" then   "cost-price-act"  else {&fact} ) + {&delim-par} +
              ub.trn-doc.doc-code + {&delim-par} +
              'yes' )
            , yes /*p-auto-go*/
            , '':U
            , 'Закрытие ДНЦ') no-error .

        if error-status :error then do:
           if return-value  <> "pr-goods":U  then do:
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "Для закрытых ДНЦ сформировать денорм цены"
                view-as alert-box error
              .
              return error return-value .
           end.
        end.
    end.
run waitfram-hide in this-procedure.

  end.

end procedure. /* create-dfc */

procedure find-main-plt :
define input  parameter p-cntxt-obj-type as character no-undo .
define input  parameter p-cntxt-obj-code as integer   no-undo .
define output parameter p-plt-id         as integer   no-undo .
define output parameter p-plt-db-num     as integer   no-undo .
define output parameter p-round-method   as character no-undo .
define output parameter p-round-base     as decimal   no-undo .

define buffer buf_price-list-type    for ub.price-list-type  .
define buffer result_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :

{ gbl/gtplobj.i
  parparentproc
  p-cntxt-obj-type
  p-cntxt-obj-code
  yes
  p-plt-id
  p-plt-db-num
  no-error }
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Поиск ГТПЛ для переоценок"
    view-as alert-box error
  .


  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer({&pdf-new}) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = p-plt-id     and
             buf_price-list-type.plt-db-num = p-plt-db-num no-error .
  if not available buf_price-list-type then return error substitute("Не найден главный тип прайс-листа  &1 &2" ,p-plt-id ,p-plt-db-num ) .

  /* проверка на подчиненность */
  if buf_price-list-type.under-type-list  = 1 then do:
      find first result_price-list-type no-lock where
                result_price-list-type.stts = integer({&pdf-new}) and
                result_price-list-type.main = true  and
                result_price-list-type.plt-id     = buf_price-list-type.plt-main-id and
                result_price-list-type.plt-db-num = buf_price-list-type.plt-main-db-num no-error .
  if not available result_price-list-type then return error substitute("Не найден главный родительский тип прайс-листа  для подчиненного &1 &2" , p-plt-id ,p-plt-db-num ) .
  end.
  else do:
    find first result_price-list-type no-lock where  recid(result_price-list-type) = recid(buf_price-list-type) no-error .
  end.

  assign
    p-plt-id        = result_price-list-type.plt-id
    p-plt-db-num    = result_price-list-type.plt-db-num
    p-round-method  = result_price-list-type.calc-round-method
    p-round-base    = result_price-list-type.calc-round-base
  .

  end.

end procedure. /* find-main-plt */

procedure calc-npricesale-doc-line :
define input  parameter bc    like ub.price-list.b-code no-undo.
define input  parameter d-num like ub.price-doc.doc-num no-undo.
define input  parameter p-doc-num  as character    no-undo.
define input  parameter p-new-sum  as decimal      no-undo .
define output parameter calc-rec   as recid        no-undo. /* recid последней пересчитанной основной цены */

define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer buf-gds-grp    for ub.gds-grp.
define buffer buf-price-doc  for ub.price-doc.
  do
  on error undo, return error return-value
  :
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.

        buf-price-list.price-sale = p-new-sum .
        buf-price-list.price-calc = p-new-sum .
        buf-price-list.calc-method = {&pr-calc-wbill} + " " + p-doc-num .

        calc-rec = recid (buf-price-list).


  run calc-pr-sub (input  buf-bar-code.b-code,
                   input  buf-price-list.doc-num,
                   input  {&pr-calc-no},
                   input  0,
                   input  ? /*{&pr-round-off}????*/ ,
                   input  ?,
                   output calc-rec) no-error.
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  end.

end procedure. /* calc-new-price-sale-doc-line */