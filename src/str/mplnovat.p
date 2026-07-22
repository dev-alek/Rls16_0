block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mplnovat.p $
$Archive: str/mplnovat.p $

Методы расчета переоценок для множ прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 02/20/06
Author: Svetlana Chernova
Creation date: 02/20/06

{&pr-calc-cost-novat-gr}
{&pr-calc-wbill-novat}
{&pr-calc-old-novat}
{&pr-calc-old}
{&pr-calc-cost-wbill}
{&pr-calc-cost-wbill-novat}
{&pr-calc-undo} - откат цены


*/

define temp-table x_obj-group no-undo like ub.clients  .

define input parameter  p-price-type as character no-undo .
define input parameter  table for x_obj-group .
define input parameter  p-b-code     as integer   no-undo .
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define input parameter  p-disc       as decimal no-undo .
define input parameter  p-doc-num    as character no-undo .
define input parameter  v-vat-pc     like doc-line.vat-pc     no-undo.
define input parameter  v-slt-pc     like doc-line.slt-pc     no-undo.

define output parameter p-calc-base   as decimal    no-undo .
define output parameter p-calc-rubl   as decimal    no-undo .
define output parameter p-price-base  as decimal    no-undo .
define output parameter p-price-rubl  as decimal    no-undo .
define output parameter p-road-tax-base as decimal  no-undo .
define output parameter p-road-tax-rubl as decimal  no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mplnovat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/mplnovat.p $":U .
define variable vss-description as character no-undo init "Процедура определения прод цены и дор налога по различным схемам".
{ cmp/vssrevis.i     }
{ cmp/trg-def.i      }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ gbl/clntattr.i     }
{ cmp/croslist.i     }
{ str/hvrdtax.i      }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ str/lastincs.i     }

&glob  start-proc  do on error undo  ~
, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }

define buffer buf_trn-doc       for ub.trn-doc  .
define buffer buf_goods         for ub.goods    .
define buffer buf_gds-obj       for ub.gds-obj  .
define buffer buff-price-list-a for ub.price-list.           /* для поиска пред переоценки и вызова prl-vat */
define buffer buf_parts         for ub.parts .
define buffer buf_last_last-price-doc for ub.price-doc  .

define variable l-price-novat as decimal no-undo .
define buffer buf_doc-line for ub.doc-line .
define buffer buf2_trn-doc for ub.trn-doc  .

define variable v-total-price-base as decimal init 0 no-undo .
define variable v-total-price-rubl as decimal init 0 no-undo .

define variable v-total-road-tax-base as decimal init 0 no-undo .
define variable v-total-road-tax-rubl as decimal init 0 no-undo .
define variable v-all-total-road-tax-base as decimal init 0 no-undo .
define variable v-all-total-road-tax-rubl as decimal init 0 no-undo .

define variable v-total-avrg-qnty     as decimal init 0 no-undo .
define variable v-total-avrg-base as decimal no-undo .
define variable v-total-avrg-rubl as decimal no-undo .

define variable v-last-in-code  like ub.gds-obj.in-code  no-undo .
define variable v-last-obj-type like ub.gds-obj.obj-type no-undo .
define variable v-last-obj-code like ub.gds-obj.obj-code no-undo .

define variable v-bar-code like ub.bar-code.b-code no-undo .

define variable parrecid as recid no-undo.                                           /*для вызова prl-vat.p*/
define variable price-rubl-with-tax-saleprl    like doc-line.price-rubl no-undo.     /*для вызова prl-vat.p*/
define variable price-base-with-tax-saleprl    like doc-line.price-base no-undo.     /*для вызова prl-vat.p*/
define variable price-rubl-without-tax-saleprl like doc-line.price-rubl no-undo.     /*для вызова prl-vat.p*/
define variable price-base-without-tax-saleprl like doc-line.price-base no-undo.     /*для вызова prl-vat.p*/
define variable vat-base-saleprl               like doc-line.price-base no-undo.     /*для вызова prl-vat.p*/
define variable vat-rubl-saleprl               like doc-line.price-rubl no-undo.     /*для вызова prl-vat.p*/
define variable vat-base-buyerprl              like doc-line.price-base no-undo.     /*для вызова prl-vat.p*/
define variable vat-rubl-buyerprl              like doc-line.price-rubl no-undo.     /*для вызова prl-vat.p*/
define variable slt-base-saleprl               like doc-line.price-base no-undo.     /*для вызова prl-vat.p*/
define variable slt-rubl-saleprl               like doc-line.price-rubl no-undo.     /*для вызова prl-vat.p*/
define variable road-tax-base-saleprl          like doc-line.road-tax   no-undo.     /*для вызова prl-vat.p*/
define variable road-tax-rubl-saleprl          like doc-line.road-tax   no-undo.     /*для вызова prl-vat.p*/
define variable excise-base-saleprl            like doc-line.price-base no-undo.     /*для вызова prl-vat.p*/
define variable excise-rubl-saleprl            like doc-line.price-rubl no-undo.     /*для вызова prl-vat.p*/
define variable discnt-base-saleprl            like gds-dtl.discnt-base no-undo.     /*для вызова prl-vat.p*/
define variable discnt-rubl-saleprl            like gds-dtl.discnt-rubl no-undo.     /*для вызова prl-vat.p*/

define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-cur-dn2 as character no-undo .
define variable v-cur-pr2 as decimal no-undo .
define variable v-cur-rt2 as decimal no-undo .
define variable v-cur-ex2 as decimal no-undo .

define variable v-log as logical no-undo .


define variable p-obj-type    as character no-undo .
define variable p-obj-code    as integer   no-undo .

define variable l-slt like price-list.slt-pc no-undo .
define variable l-vat like price-list.vat-pc no-undo .

define variable par-type    as character no-undo .

define variable v-tax-road as decimal no-undo .

find first buf_goods no-lock
  where buf_goods.artic     = p-artic
    and buf_goods.prod-type = p-prod-type
    and buf_goods.prod-code = p-prod-code
  no-error .
if not available buf_goods then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найден товар" skip
    "Артикул" p-artic p-prod-type p-prod-code skip
    view-as alert-box .
  undo, return error .
end.

find first x_obj-group no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.
p-obj-type = x_obj-group.obj-type.
p-obj-code = x_obj-group.obj-code.

{ gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code  }
/* Определим текущую цену бар-кода ( корневого признака ) по переоценке  */  /* v-bar-code ???  */
{ gbl/bcodeprc.i
    p-obj-type
    p-obj-code
    p-b-code
    0
    0
    v-cur-dn
    v-cur-pr
    v-cur-rt
    v-cur-ex }
define buffer buff_price-lista for ub.price-list.

  find first buff_price-lista no-lock where
             buff_price-lista.doc-num = v-cur-dn and
             buff_price-lista.price-type = "" and
             buff_price-lista.b-code = p-b-code no-error .

  if v-cur-dn = ?  or not available buff_price-lista then do:
    { gbl/bcodeprc.i
        p-obj-type
        p-obj-code
        v-bar-code
        0
        0
        v-cur-dn
        v-cur-pr
        v-cur-rt
        v-cur-ex }
        p-b-code = v-bar-code .
  end.


run main-road-tax in this-procedure
  ( input p-obj-type,
    input p-obj-code,
    input p-artic   ,
    input p-prod-type,
    input p-prod-code,
    input-output p-road-tax-base,
    input-output p-road-tax-rubl )
   .

assign
    v-total-avrg-qnty  = 0
    v-total-price-base = 0
    v-total-price-rubl = 0
    v-total-road-tax-base =  0
    v-total-road-tax-rubl =  0
    v-all-total-road-tax-base =  0
    v-all-total-road-tax-rubl =  0
          .




case p-price-type :
   /* средняя учетная с налогами + учетная из текущей накладной */
  when {&pr-calc-cost-wbill}  then do:
    if buf_goods.gds-type = {&gds-goods} then do:
      /*
        возвращается средняя учетная цена положительных партий свободной зоны по объекту
        не учитываются партии зарезервированные за незакрытыми документами
      */
      for each x_obj-group ,
      each buf_parts no-lock
        where  buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and ( buf_parts.out-code  = {&free-code}
              or buf_parts.out-code  = p-doc-num  )
      on error undo, return error
      :
        assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.

      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = ( v-total-avrg-base / v-total-avrg-qnty ) * (1 + p-disc / 100)
          p-price-rubl = ( v-total-avrg-rubl / v-total-avrg-qnty ) * (1 + p-disc / 100)
        .
      end.
      else do:
          run last-incom-S in this-procedure
          ( input   p-artic ,
            input   p-prod-type,
            input   p-prod-code ,
            output  v-last-in-code,
            output  v-last-obj-type,
            output  v-last-obj-code ).

            find first buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = v-last-obj-type
                and buf_gds-obj.obj-code  = v-last-obj-code
                and buf_gds-obj.artic     = p-artic
                and buf_gds-obj.prod-type = p-prod-type
                and buf_gds-obj.prod-code = p-prod-code
              no-error .
            if available buf_gds-obj then do:
              assign
                p-price-base = buf_gds-obj.last-base * (1 + p-disc / 100)
                p-price-rubl = buf_gds-obj.last-rubl * (1 + p-disc / 100)
              .
            end.

      end.
    end.
    else do:
      /* для услуг - возвращаем учетную цену услуги */
          run last-incom-S in this-procedure
          ( input   p-artic ,
            input   p-prod-type,
            input   p-prod-code ,
            output  v-last-in-code,
            output  v-last-obj-type,
            output  v-last-obj-code ).

      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = v-last-obj-type
          and buf_gds-obj.obj-code  = v-last-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = ( buf_gds-obj.price-base ) * (1 + p-disc / 100)
          p-price-rubl = ( buf_gds-obj.price-rubl ) * (1 + p-disc / 100)
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
    end.
 /* message "рассчиталась " p-price-rubl.*/
  end.

/*-Учетная по свободной зоне---------------------------------------------------------------------------------------------*/
  when {&pr-calc-cost-novat-gr} then do:
     assign
          v-total-avrg-qnty  = 0
          v-total-price-base = 0
          v-total-price-rubl = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .

      /*
        возвращается средняя учетная цена положительных партий свободной зоны по объекту
        не учитываются партии зарезервированные за незакрытыми документами
        если gen-mrgn = "group-margin"  то учитываем партии текущего документа
      */
      for each x_obj-group,
          each buf_parts no-lock
        where (
              buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = {&free-code}  /* только партии свободной зоны */
          and buf_parts.qnty      > 0             /* только положительные партии  */
          ) or
          (   buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = p-doc-num  /*  партии текущего документа */
          )
      on error undo, return error
      :

         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
         { str/in-vatp.i calc-parts buf_parts. buf_trn-doc. g }

        assign
          v-total-price-base    =  v-total-price-base +
                      ( (price-base-with-tax-loc
                      - vat-base-loc
                      - road-tax-base-loc )
                      * buf_parts.fact-qnty)

          v-total-price-rubl    =  v-total-price-rubl +
                       ( (price-rubl-with-tax-loc
                       - road-tax-rubl-loc
                       - vat-rubl-loc)
                       * buf_parts.fact-qnty)

          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
            /*message "цена уч по партии " price-rubl-without-tax-loc skip  "кол-во" buf_parts.fact-qnty skip
            buf_parts.out-code.
            */
      end.
          if v-total-avrg-qnty > 0 then  DO:
              Assign
                  p-calc-base     =  v-total-price-base / v-total-avrg-qnty
                  p-calc-rubl     =  v-total-price-rubl / v-total-avrg-qnty
                  p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                  p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                  p-price-base    =  p-calc-base
                                      * (1 + p-disc / 100)
                                      * (1 + v-vat-pc / 100 )
                                      * (1 + v-slt-pc / 100 )
          + p-road-tax-base
                  p-price-rubl    = ( p-calc-rubl )
                                     * (1 + p-disc / 100)
                                     * (1 + v-vat-pc / 100)
                                     * (1 + v-slt-pc / 100)
                                     + p-road-tax-rubl
                  .
            /* message "средяя уч цена с  учетом всех накруток "
             skip p-calc-rubl skip
             "% наценки " p-disc    skip
             "% НДС " v-vat-pc  skip
             "% НСП " v-slt-pc  skip
             "road-tax " p-road-tax-rubl skip
             "= "  p-price-rubl
             .
              */
             End.

            if v-total-avrg-qnty <= 0 then do:
                run last-incom-S in this-procedure
                ( input   p-artic ,
                  input   p-prod-type,
                  input   p-prod-code ,
                  output  v-last-in-code,
                  output  v-last-obj-type,
                  output  v-last-obj-code ).

                      /* состав последнего прихода */
                      find buf2_trn-doc where buf2_trn-doc.doc-code  = v-last-in-code no-lock no-error .
                      find buf_doc-line where     buf_doc-line.doc-code = v-last-in-code
                                      and buf_doc-line.artic     = p-artic
                                      and buf_doc-line.prod-type = p-prod-type
                                      and buf_doc-line.prod-code = p-prod-code no-lock no-error.
                      if available buf_doc-line then do :
                      { str/in-vatp.i calc buf_doc-line. buf2_trn-doc. g}

                      Assign
                          p-calc-base   =  price-base-without-tax-loc
                          p-calc-rubl   =  price-rubl-without-tax-loc
                          p-price-rubl  =  price-rubl-without-tax-loc
                                * (1 + p-disc / 100 )
                                * (1 + v-vat-pc / 100 )
                                * (1 + v-slt-pc / 100 )
                                + road-tax-rubl-loc

                          p-price-base  = price-base-without-tax-loc
                                * (1 + p-disc / 100 )
                                * (1 + v-vat-pc / 100 )
                                * (1 + v-slt-pc / 100 )
                                + road-tax-base-loc

                          p-road-tax-rubl =  road-tax-rubl-loc
                          p-road-tax-base =  road-tax-base-loc
                          .

                      end.
                    end.
            end.
/*---по накладной--------------------------------------------------------------------------------------------------------*/
/* внешней */
  when {&pr-calc-wbill-novat} then DO:
          find buf2_trn-doc where buf2_trn-doc.doc-code  = p-doc-num no-lock no-error .
          find buf_doc-line where      buf_doc-line.doc-code = p-doc-num
                          and buf_doc-line.artic     = p-artic
                          and buf_doc-line.prod-type = p-prod-type
                          and buf_doc-line.prod-code = p-prod-code no-lock no-error.
          if available buf_doc-line then do :
          { str/in-vatp.i calc buf_doc-line. buf2_trn-doc. g}
          if p-road-tax-rubl =  ? and  p-road-tax-base = ?  then
          assign
              p-road-tax-base =  road-tax-base-loc
              p-road-tax-rubl =  road-tax-rubl-loc
              .

          Assign
              p-calc-base   =  price-base-with-tax-loc
              p-calc-rubl   =  price-rubl-with-tax-loc
              p-price-base  =   (price-base-with-tax-loc -
                    vat-base-loc -
                    road-tax-base-loc )
                    * (1 + p-disc / 100 )
                    * (1 + (v-vat-pc / 100))
                    * (1 + (v-slt-pc / 100))
                    + p-road-tax-base

              p-price-rubl  = (price-rubl-with-tax-loc -
                    vat-rubl-loc -
                    road-tax-rubl-loc )
                    * (1 + p-disc / 100 )
                    * (1 + (v-vat-pc / 100))
                    * (1 + (v-slt-pc / 100))
                    + p-road-tax-rubl

              .
          end.
  End.
 /* внутренней */
  when {&pr-calc-wbill-novat} + "Other":U then DO:
          find buf2_trn-doc where buf2_trn-doc.doc-code  = p-doc-num no-lock no-error .
          find buf_doc-line where     buf_doc-line.doc-code = p-doc-num
                          and buf_doc-line.artic     = p-artic
                          and buf_doc-line.prod-type = p-prod-type
                          and buf_doc-line.prod-code = p-prod-code no-lock no-error.
          if available buf_doc-line then do :
         { str/out-vatp.i doc-line buf_doc-line. buf2_trn-doc. g }
          if p-road-tax-rubl =  ? and  p-road-tax-base = ?  then
          assign
              p-road-tax-base =  road-tax-base-sale
              p-road-tax-rubl =  road-tax-rubl-sale
              .

          Assign
              p-calc-base   =  price-base-without-tax-sale
              p-calc-rubl   =  price-rubl-without-tax-sale

              p-price-base  =   price-base-without-tax-sale
                    * (1 + p-disc / 100 )
                    * (1 + (v-vat-pc / 100))
                    * (1 + (v-slt-pc / 100))
                    + p-road-tax-base

              p-price-rubl  = price-rubl-without-tax-sale
                    * (1 + p-disc / 100 )
                    * (1 + (v-vat-pc / 100))
                    * (1 + (v-slt-pc / 100))
                    + p-road-tax-rubl
              .
          end.
  End.
/*-----------------------------------------------------------------------------------------------------------------------*/
when {&pr-calc-old-novat}  then do:
      /* ищем предыдущий прайс-лист для этого объекта */
      if v-cur-dn = ? then do:
        message "Нет Акта переоценки для товара :" buf_goods.artic buf_goods.gds-name
                "- расчет от старой цены продажи невозможен."
                view-as alert-box question buttons OK-Cancel update v-log.
                return error .
                end.

      else do :
        find first buff-price-list-a where
                   buff-price-list-a.doc-num = v-cur-dn and
                   buff-price-list-a.price-type = "" and
                   buff-price-list-a.b-code = p-b-code
                   no-lock no-error .


        if available buff-price-list-a then do:
            l-vat = buff-price-list-a.vat-pc.
            l-slt = buff-price-list-a.slt-pc.
        end.

        if not available buff-price-list-a
            Then  parrecid = ?.
            Else  DO :
            parrecid = recid(buff-price-list-a) .
                    /* расшифровка цены из последней переоценки */
            run prl-vat in this-procedure ( input   parrecid               ,
            output  price-rubl-with-tax-saleprl    ,
            output  price-base-with-tax-saleprl    ,
            output  price-rubl-without-tax-saleprl ,
            output  price-base-without-tax-saleprl ,
            output  vat-base-saleprl               ,
            output  vat-rubl-saleprl               ,
            output  vat-base-buyerprl              ,
            output  vat-rubl-buyerprl              ,
            output  slt-base-saleprl               ,
            output  slt-rubl-saleprl               ,
            output  road-tax-base-saleprl          ,
            output  road-tax-rubl-saleprl          ,
            output  excise-base-saleprl            ,
            output  excise-rubl-saleprl            ,
            output  discnt-base-saleprl            ,
            output  discnt-rubl-saleprl             ) no-error .
            End.
          if p-road-tax-rubl =  ? and  p-road-tax-base = ?  then
          assign
              p-road-tax-base =  road-tax-base-saleprl
              p-road-tax-rubl =  road-tax-rubl-saleprl
              .
          Assign
              p-calc-rubl   =  if var-pr-r-b = "rubl"  then  v-cur-pr else 0
              p-calc-base   =  if var-pr-r-b = "base" then   v-cur-pr else 0
              p-price-base  =  ( price-base-with-tax-saleprl
                    - road-tax-base-saleprl)
                    / (1 + (l-slt / 100))
                    / (1 + (l-vat / 100))
                    * (1 + p-disc    / 100 )
                    * (1 + (v-vat-pc / 100))
                    * (1 + (v-slt-pc / 100))
                    + p-road-tax-base

              p-price-rubl  =   (price-rubl-with-tax-saleprl
                    - road-tax-rubl-saleprl)
                    / (1 + (l-slt / 100))
                    / (1 + (l-vat / 100))
                    * (1 + p-disc    / 100 )
                    * (1 + (v-vat-pc / 100))
                    * (1 + (v-slt-pc / 100))
                    + p-road-tax-rubl
              .
  end.
end.
when {&pr-calc-old}  then do:
      /* ищем предыдущий прайс-лист для этого объекта */
      if v-cur-dn = ? then do:
        message "Нет Акта переоценки для товара :" buf_goods.artic buf_goods.gds-name
                "- расчет от старой цены продажи невозможен."
                view-as alert-box question buttons OK-Cancel update v-log.
                return error .
                end.

      else do :
        find first buff-price-list-a where
                   buff-price-list-a.doc-num = v-cur-dn and
                   buff-price-list-a.price-type = "" and
                   buff-price-list-a.b-code = p-b-code
                   no-lock no-error .

        if available buff-price-list-a then do:
            l-vat = buff-price-list-a.vat-pc.
            l-slt = buff-price-list-a.slt-pc.
        end.

        if not available buff-price-list-a
            Then  parrecid = ?.
            Else  DO :
            parrecid = recid(buff-price-list-a) .
                    /* расшифровка цены из последней переоценки */
            run prl-vat in this-procedure ( input   parrecid               ,
            output  price-rubl-with-tax-saleprl    ,
            output  price-base-with-tax-saleprl    ,
            output  price-rubl-without-tax-saleprl ,
            output  price-base-without-tax-saleprl ,
            output  vat-base-saleprl               ,
            output  vat-rubl-saleprl               ,
            output  vat-base-buyerprl              ,
            output  vat-rubl-buyerprl              ,
            output  slt-base-saleprl               ,
            output  slt-rubl-saleprl               ,
            output  road-tax-base-saleprl          ,
            output  road-tax-rubl-saleprl          ,
            output  excise-base-saleprl            ,
            output  excise-rubl-saleprl            ,
            output  discnt-base-saleprl            ,
            output  discnt-rubl-saleprl             ) no-error .
            End.
          if p-road-tax-rubl =  ? and  p-road-tax-base = ?  then
          assign
              p-road-tax-base =  road-tax-base-saleprl
              p-road-tax-rubl =  road-tax-rubl-saleprl
              .
          Assign
              p-calc-rubl   =  if var-pr-r-b = "rubl"  then  v-cur-pr else 0
              p-calc-base   =  if var-pr-r-b = "base" then   v-cur-pr else 0
              p-price-base  =   price-base-with-tax-saleprl  * (1 + p-disc    / 100 )
              p-price-rubl  =   price-rubl-with-tax-saleprl  * (1 + p-disc    / 100 )
              .
  end.
end.
when {&pr-calc-no}  then do:
      /* ищем предыдущий прайс-лист для этого объекта */
      if v-cur-dn = ? then do:
          assign
              p-road-tax-base =  0
              p-road-tax-rubl =  0
              p-calc-rubl   =  0
              p-calc-base   =  0
              p-price-base  =  0
              p-price-rubl  =  0
              .
      end.
      else do :
        find first buff-price-list-a where
                   buff-price-list-a.doc-num    = v-cur-dn and
                   buff-price-list-a.price-type = ""       and
                   buff-price-list-a.b-code     = p-b-code
                   no-lock no-error .
        if available buff-price-list-a then do:
            l-vat = buff-price-list-a.vat-pc .
            l-slt = buff-price-list-a.slt-pc .
        end.

        if not available buff-price-list-a
            then  parrecid = ? .
            else  do :
            parrecid = recid ( buff-price-list-a ) .
/* расшифровка цены из последней переоценки */
            run prl-vat in this-procedure
                ( input   parrecid                       ,
                  output  price-rubl-with-tax-saleprl    ,
                  output  price-base-with-tax-saleprl    ,
                  output  price-rubl-without-tax-saleprl ,
                  output  price-base-without-tax-saleprl ,
                  output  vat-base-saleprl               ,
                  output  vat-rubl-saleprl               ,
                  output  vat-base-buyerprl              ,
                  output  vat-rubl-buyerprl              ,
                  output  slt-base-saleprl               ,
                  output  slt-rubl-saleprl               ,
                  output  road-tax-base-saleprl          ,
                  output  road-tax-rubl-saleprl          ,
                  output  excise-base-saleprl            ,
                  output  excise-rubl-saleprl            ,
                  output  discnt-base-saleprl            ,
                  output  discnt-rubl-saleprl            )
                  no-error .
          end.

          if p-road-tax-rubl =  ? and  p-road-tax-base = ?  then
          assign
              p-road-tax-base =  road-tax-base-saleprl
              p-road-tax-rubl =  road-tax-rubl-saleprl
             .
          assign
              p-calc-rubl   =  if available buff-price-list-a then buff-price-list-a.price-sale else price-rubl-with-tax-saleprl
              p-calc-base   =  if available buff-price-list-a then buff-price-list-a.price-sale else price-base-with-tax-saleprl
              p-price-base  =  price-base-with-tax-saleprl  * (1 + p-disc / 100 )
              p-price-rubl  =  price-rubl-with-tax-saleprl  * (1 + p-disc / 100 )
             .
  end.
end.

  /* Отмена цен */
  when {&pr-calc-undo} then do:
    /* ищем предпоследний прайс-лист для этого объекта */
    if v-cur-pr = ? then do:
      message "Нет Акта переоценки для товара :" buf_goods.artic buf_goods.gds-name
              "- откат цены невозможен."
              view-as alert-box .
      return error .
    end.
    else do:
    v-cur-pr2 = ?.
    find first buf_last_last-price-doc no-lock where
               buf_last_last-price-doc.doc-num = v-cur-dn no-error .
    if available buf_last_last-price-doc then do:
    /* ??? */
        { gbl/bcodeprc.i
          buf_last_last-price-doc.obj-type
          buf_last_last-price-doc.obj-code
          v-bar-code
          0
          buf_last_last-price-doc.fact-order
          v-cur-dn2
          v-cur-pr2
          v-cur-rt2
          v-cur-ex2 }

    end.
    if v-cur-pr2 = ? then do:
      message "Нет предпоследнего Акта переоценки для товара :" buf_goods.artic buf_goods.gds-name
              "- откат цены невозможен."
              view-as alert-box.
              return error .
      end.
      else do:
        assign
          p-calc-base     =   v-cur-pr
          p-calc-rubl     =   v-cur-pr
          p-price-base    =   v-cur-pr2
          p-price-rubl    =   v-cur-pr2
          p-road-tax-base =   v-cur-rt2
          p-road-tax-rubl =   v-cur-rt2
          .
          /* тут нада пересчитать если rb base */
      end.
    end.
  end.

end case.

/* Изменился ли tax-road ? */
if var-pr-r-b = "rubl" then
run compare_road-tax in this-procedure (input-output p-road-tax-rubl,  input v-bar-code, input  p-obj-type,  input p-obj-code,  input yes ).
else
run compare_road-tax in this-procedure (input-output p-road-tax-base,  input v-bar-code, input  p-obj-type,  input p-obj-code,  input yes ).
 /* */


/* если цена не задана, то возвращаем неопределенную цену */
if p-price-base = 0 then do:
  assign
    p-price-base = ?
  .
end.

if p-price-rubl = 0 then do:
  assign
    p-price-rubl = ?
  .
end.

/* message "рассчитанная цена" skip p-price-rubl. */

/* проверяем что либо обе цены заданы, либо обе цены не заданы */
if (p-price-base = ?) <> (p-price-rubl = ?) then do:
  message
    vss-workfile vss-revision vss-description skip
    "Цена в одной из валют не задана" skip
    "p-price-base" p-price-base skip
    "p-price-rubl" p-price-rubl skip
    view-as alert-box error .
  undo, return error .
end.

{ str/alt-calc.i "proc-ver" }