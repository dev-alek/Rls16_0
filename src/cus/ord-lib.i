/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

библиотека процедур для заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/02
Author: Svetlana Chernova
Creation date: 03/02/02

*/
/*
&scop  start-proc  do on error undo : ~
  if return-value <> "" or  error-status:error then ~
  message SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) view-as alert-box TITLE "start-proc".
*/

&scop  start-proc do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "def" &then
{ str/lib-calc.i }
define variable   custvalue     as character initial ? no-undo.
define variable   custtype      as character initial ? no-undo.
define variable   prtvalue      as character initial ? no-undo.
define variable   prttype       as character initial ? no-undo.
define variable   partsvalue    as character initial ? no-undo.
define variable   partstype     as character initial ? no-undo.
define variable   vat-sumvalue  as character initial ? no-undo.
define variable   vat-sumtype   as character initial ? no-undo.
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   exctaxcdvalue as character initial ? no-undo.
define variable   vattaxcdvalue as character initial ? no-undo.
define variable   measfactvalue as character initial ? no-undo.
define variable   measfacttype  as character initial ? no-undo.
define variable   temp-mes      as character initial ? no-undo.
define variable   varroad-tax-label as character no-undo.
define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable   dops          as character           no-undo format "X(250)".
define variable   dopst         as character           no-undo format "X(1)".
define variable   dop-slt       as character           no-undo format "X(250)".
define variable   dop-slt-st    as character           no-undo format "X(1)".
define variable   sum-vat       like ub.ord-line.sum-vat format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
define variable   varrvs-place        as   logical       no-undo.
define variable   var-code-temp like ub.place.pl-code no-undo.
define variable   rvs-recid     as recid           no-undo.
define variable   road-tax-cli  like ub.doc-line.road-tax initial 0 no-undo.
define variable   parprice-sale like ub.price-list.price-sale no-undo.

define var  pargds-code            like ub.goods.gds-code        no-undo.
define var  parobj-type            like ub.clients.obj-type      no-undo.
define var  parobj-code            like ub.clients.obj-code      no-undo.
define var  parext-gds-type        as   character      initial ? no-undo.
define var  parcli-qnty-input      as   logical        initial ? no-undo.  /*Может ли быть задано данное поле в интерфейсе*/
define var  pardensity-input       as   logical        initial ? no-undo.
define var  parcli-base-rate-input as   logical        initial ? no-undo.
define var  pardoc-qnty-input      as   logical        initial ? no-undo.
define var  parfact-qnty-input     as   logical        initial ? no-undo.
define var  parprice-cli-input     as   logical        initial ? no-undo.
define var  parbase-price-input    as   logical        initial ? no-undo.
define var  parbase-price-my       as   logical        initial ? no-undo.
define var  partax-3-input         as   logical        initial ? no-undo.
define var  parcli-qnty-calc       as   character      initial ? no-undo. /*Какие поля пересчитываются после изменения данного поля*/
define var  pardensity-calc        as   character      initial ? no-undo.
define var  parcli-base-rate-calc  as   character      initial ? no-undo.
define var  pardoc-qnty-calc       as   character      initial ? no-undo.
define var  parfact-qnty-calc      as   character      initial ? no-undo.
define var  parprice-cli-calc      as   character      initial ? no-undo.
define var  parbase-price-calc     as   character      initial ? no-undo.
define var  partax-3-calc          as   character      initial ? no-undo.
define var  parround               as   integer        initial ? no-undo. /*округление при вычислении ведомого количества*/
&endif

&if "{1}"  = "last-price" &then
procedure last-price :
/* Последняя цена прихода по товару по фирме */
{&start-proc}
define input parameter  p-host-code     as integer no-undo .
define input parameter  p-artic         like ub.doc-line.artic  no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type  no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code  no-undo .
define input parameter  p-cli-code      like ub.ord-doc.cli-code  no-undo .
define input parameter  p-cli-type      like ub.ord-doc.cli-type  no-undo .
define input parameter  p-cli-base-rate like ub.ord-line.cli-base-rate no-undo .
define input parameter  p-curr-code  as integer   no-undo .
define output parameter p-price-base like ub.doc-line.price-base no-undo .
define output parameter p-price-rubl like ub.doc-line.price-rubl no-undo .
define output parameter p-price-cli  like ub.doc-line.price-cli  no-undo .

define buffer buf-lib-doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds .
define buffer buf_trn-doc for ub.trn-doc  .

define variable vp-curr-code  like ub.trn-doc.exch-code.
define variable vp-exch-rate  like ub.trn-doc.exch-rate.
define variable vp-exch-scale like ub.trn-doc.exch-scale.
define variable v-last-in-code   like ub.doc-line.doc-code  no-undo .
define variable v-last-obj-type  like ub.clients.obj-type no-undo .
define variable v-last-obj-code  like ub.clients.obj-code no-undo .
define variable v-cli-base-rate as decimal   no-undo .

 find first buf_cli-gds no-lock where
            buf_cli-gds.cli-type   = p-cli-type    and
            buf_cli-gds.cli-code   = p-cli-code    and
            buf_cli-gds.host-code  = p-host-code   and
            buf_cli-gds.artic      = p-artic       and
            buf_cli-gds.prod-type  = p-prod-type   and
            buf_cli-gds.prod-code  = p-prod-code
            no-error .
if available buf_cli-gds then do:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = buf_cli-gds.in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = buf_cli-gds.in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
else do:
  /* если нет цены по конрагенту то берется последняя цена по фирме */
    { trg/lastindc.i
      p-host-code
      p-artic
      p-prod-type
      p-prod-code
      v-last-in-code
      v-last-obj-type
      v-last-obj-code
    }
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = v-last-in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = v-last-in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
    if available buf-lib-doc-line then do:
      assign
        v-cli-base-rate = buf-lib-doc-line.cli-base-rate
        p-price-base = buf-lib-doc-line.price-base
        p-price-rubl = buf-lib-doc-line.price-rubl
        p-price-cli  = (if vp-curr-code = 0 then buf-lib-doc-line.price-rubl else buf-lib-doc-line.price-base) * p-cli-base-rate
      .
      if v-cli-base-rate <> p-cli-base-rate
      then do:
          p-price-cli  = p-price-cli / v-cli-base-rate  .
      end.
       if p-curr-code <> vp-curr-code then do:
          p-price-cli  = p-price-rubl  .
      end.
    end.
    Else do:
      assign
        p-price-base = 0
        p-price-rubl = 0
        p-price-cli  = 0
      .
    end.
  end.
end procedure. /* last-price */
&endif

&if "{1}" = "excel" &then
 Assign
 artic#           = chWorkSheet{2}:Range ("A" + T):Value
 prod-type#       = chWorkSheet{2}:Range ("B" + T):Value
 prod-code#       = chWorkSheet{2}:Range ("C" + T):Value  no-error.
  Find FIRST TMP#zakaz   where
    TMP#zakaz.artic           = artic#      and
    TMP#zakaz.prod-type       = prod-type#  and
    TMP#zakaz.prod-code       = prod-code#  no-error.

  if not available TMP#zakaz  THEN  CREATE TMP#zakaz .
  ASSIGN
    TMP#zakaz.artic           = chWorkSheet{2}:Range ("A" + T):Value
    TMP#zakaz.prod-type       = chWorkSheet{2}:Range ("B" + T):Value
    TMP#zakaz.prod-code       = chWorkSheet{2}:Range ("C" + T):Value
    TMP#zakaz.cli-art         = chWorkSheet{2}:Range ("E" + T):Value
    TMP#zakaz.price-cli       = chWorkSheet{2}:Range ("F" + T):Value
    TMP#zakaz.qnty            = chWorkSheet{2}:Range ("G" + T):Value
    TMP#zakaz.initial-qnty    = chWorkSheet{2}:Range ("G" + T):Value no-error .

  if error-status :error then do:
      message "Файл не соответствует заданному формату." view-as alert-box error .
      return error .
  end.

  FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = TMP#zakaz.prod-type AND
                                 ub.goods.prod-code = TMP#zakaz.prod-code AND
                                 ub.goods.artic     = TMP#zakaz.artic   NO-ERROR.

   if error-status :error then return error .


&endif

&if "{1}" = "btn-dtl" &then
  find current TMP#zakaz no-lock no-error  .
  if error-status :error or  not avail TMP#zakaz   then do:
       message "Не выбрана строка заказа" .
       return.
       end.
  find first ub.goods no-lock where ub.goods.prod-type = tmp#zakaz.prod-type and
                                 ub.goods.prod-code = tmp#zakaz.prod-code and
                                 ub.goods.artic     = tmp#zakaz.artic   no-error.

      run cus/ord-p.p
      ( parParentProc
      , ?
      , recid(TMP#zakaz)
      , recid(goods)
      , (If t-action = "lkp":U then  {&Lookup}  else {&prt-def} )
      , input TMP#zakaz.qnty
      , input TMP#zakaz.cli-qnty
      ) .



&endif


&if "{1}"  = "leave-qnty" &then
ON LEAVE OF {2}.cli-qnty IN FRAME {&frame-name}
DO:
define variable varprt-obj_free-qnty like ub.prt-obj.free-qnty no-undo.
/*Если кол-во в ед.пост товара получается дробное, то ошибка.*/
IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-cli
                    and LOOKUP({&pieces}, ub.units.type) > 0 )  AND
   TRUNC(input frame {&frame-name} {2}.cli-qnty, 0)
   <>    input frame {&frame-name} {2}.cli-qnty
   THEN DO:
      MESSAGE "Единица изм поставщика " ub.goods.unit-cli " - штучная." skip
              "Кол-во должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN NO-APPLY.
  END.


if ub.goods.qnty-cart <> 0 then do:
  if input frame {&frame-name} {2}.cli-qnty / ub.goods.qnty-cart -
  truncate ( input frame {&frame-name} {2}.cli-qnty / ub.goods.qnty-cart , 0 ) <> 0 then do:
     /* не влазит в упаковку */
      g#log = yes.
      message "Товар рекомендуется выписывать упаковками." skip (2)
              "Округлить до целого числа упаковок ?"
               view-as alert-box question buttons yes-no update g#log .

      if g#log then do:
        if round (input frame {&frame-name} {2}.cli-qnty / ub.goods.qnty-cart, 0) = 0 then do:
          display
              ub.goods.qnty-cart @ {2}.cli-qnty
              with frame {&frame-name}.
        end.
        else do:
          display
            round ( input frame {&frame-name} {2}.cli-qnty / ub.goods.qnty-cart, 0) * ub.goods.qnty-cart @ {2}.cli-qnty
            with frame {&frame-name}.
        end.
      end.
  end.
end.


 &if "{2}" <> "b-ord-gds-dtl" &then
 if {2}.cli-base-rate:sensitive in frame dialog-frame then do:
    assign
      KK = input frame {&frame-name} {2}.cli-base-rate
      {2}.cli-base-rate = input frame {&frame-name} {2}.cli-base-rate.
    .
    end.
 else do:
    if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
    kk = ub.goods.cli-base-rate.
    else KK = b-ord-line.cli-base-rate.
  end.
&else
   KK = b-ord-line.cli-base-rate.
&endif
  if lookup('cli-base-rate',parcli-qnty-calc) = 0 then do:
  assign
    tot-cli = input frame {&frame-name} {2}.price-cli * input frame {&frame-name} {2}.cli-qnty
    {2}.qnty = ( input frame {&frame-name} {2}.cli-qnty ) * kk .

    DISPLAY  tot-cli {2}.qnty   WITH FRAME {&frame-name}.

     &if "{2}" = "tmp#zakaz" &then
       {2}.cli-base-rate = kk .
       DISPLAY   {2}.cli-base-rate WITH FRAME {&frame-name}.
     &endif

  apply "leave" to {2}.qnty .
  DISPLAY  tot-cli {2}.qnty WITH FRAME {&frame-name}.
  run ass-var in this-procedure .
  end.
END.

ON LEAVE OF {2}.qnty IN FRAME {&frame-name}
DO:
  &if "{2}" = "tmp#zakaz" &then
  define variable t-sum like tmp#zakaz.qnty no-undo .
  t-sum = 0.
  for each tmp#zakaz-dtl where
      tmp#zakaz-dtl.artic     = tmp#zakaz.artic and
      tmp#zakaz-dtl.prod-type = tmp#zakaz.prod-type and
      tmp#zakaz-dtl.prod-code = tmp#zakaz.prod-code  :
      t-sum = t-sum + tmp#zakaz-dtl.qnty.
   end.
   if t-sum > tmp#zakaz.qnty then do:
      MESSAGE "Количество по признакам больше чем по строке товара ! " skip t-sum
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      return no-apply.
   end.
  &endif
/*Если кол-во в базовых единицах товара получается дробное, то ошибка.*/
 IF CAN-FIND(FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base
                    and LOOKUP({&pieces}, ub.units.type) > 0)  AND
   TRUNC(input frame {&frame-name} {2}.qnty, 0)
   <>    input frame {&frame-name} {2}.qnty
   THEN DO:
      MESSAGE "Базовая единица товара " ub.goods.unit-base " - штучная." skip
              "Кол-во по факту должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN no-apply.
  END.


 if pardoc-qnty-input = true then do:
    if lookup('cli-base-rate',parcli-qnty-calc) > 0 then do:
     assign
        kk = (input frame {&frame-name} {2}.qnty) / (input frame {&frame-name} {2}.cli-qnty )
     .
     if kk  = ? then kk = 1.
     b-ord-line.cli-base-rate = kk  .
    end.
    else do:
        if b-ord-line.cli-base-rate = 0 or b-ord-line.cli-base-rate = ? then
          kk = ub.goods.cli-base-rate .
          else KK = b-ord-line.cli-base-rate .
        assign
            {2}.cli-qnty = input frame {&frame-name} {2}.qnty / kk
            tot-cli = input frame {&frame-name} {2}.price-cli * input frame {&frame-name} {2}.cli-qnty
            .
            DISPLAY  tot-cli {2}.cli-qnty   WITH FRAME {&frame-name}.

            &if "{2}" = "tmp#zakaz" &then
                {2}.cli-base-rate = kk .
                DISPLAY   {2}.cli-base-rate WITH FRAME {&frame-name}.
            &endif
       end.
  run ass-var in this-procedure .
  end.
END.


ON LEAVE OF {2}.price-base IN FRAME {&frame-name} /* Цена */
DO:

if input frame {&frame-name} {2}.price-base > 5000 and base-code = 1 then
  message "Внимание !!!" skip (2)
                  "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
                  "Вы не ошиблись ?".
if {2}.price-base <> input frame {&frame-name} {2}.price-base then
  assign
    {2}.price-rubl = input frame {&frame-name} {2}.price-base * loc-base-rate / loc-base-scale
    {2}.price-cli  = {2}.price-rubl / loc-exch-rate * loc-exch-scale *
    &if "{2}" = "tmp#zakaz"  &then {2}.cli-base-rate
                             &else loc-cli-base-rate
    &endif
    .
    DISPLAY
    {2}.price-RUBL
    {2}.price-cli
    WITH FRAME {&frame-name} .

 run ass-var in this-procedure  .
END.

ON LEAVE OF {2}.price-rubl IN FRAME {&frame-name} /* Цена */
DO:
if {2}.price-rubl <> input frame {&frame-name} {2}.price-rubl then
  assign
    {2}.price-base = input frame {&frame-name} {2}.price-rubl / loc-base-rate * loc-base-scale
    {2}.price-cli  = input frame {&frame-name} {2}.price-rubl / loc-exch-rate * loc-exch-scale /
    &if "{2}" = "tmp#zakaz"  &then {2}.cli-base-rate
                             &else loc-cli-base-rate
    &endif

    .
    DISPLAY
    {2}.price-base
    {2}.price-cli
    WITH FRAME {&frame-name} .
    run ass-var in this-procedure .
END.

ON LEAVE OF {2}.price-cli IN FRAME {&frame-name} /* Цена */
DO:
if {2}.price-cli <> input frame {&frame-name} {2}.price-cli then
  assign
    tot-cli = input frame {&frame-name} {2}.price-cli *  input frame {&frame-name} {2}.cli-qnty
    .
 run ass-var in this-procedure .
END.


&if "{2}" = "tmp#zakaz" &then
ON LEAVE OF {2}.cli-base-rate IN FRAME {&frame-name} /* коэффициент */
DO:
  run proc-c-b-r in this-procedure .
END.

procedure proc-c-b-r:
 assign frame {&frame-name}  {2}.cli-base-rate.
 if lookup ("doc-qnty", parcli-base-rate-calc) > 0 then do:
    apply "leave" to {2}.cli-qnty in frame {&frame-name} .
    end.

 if lookup ("cli-qnty", parcli-base-rate-calc) > 0 then do:
    apply "leave" to {2}.qnty in frame {&frame-name} .
    end.
 run ass-var in this-procedure .
END procedure.

ON LEAVE OF {2}.excise ,
            {2}.other-base ,
            {2}.other-rubl,
            {2}.road-tax ,
            {2}.transport-base ,
            {2}.transport-rubl ,
            {2}.sum-vat
            IN FRAME {&frame-name}
do:
  run ass-var in this-procedure .
end.

on leave of {2}.sum-vat in frame {&frame-name} do:
/* пересчет суммы по проценту */
   if input frame {&frame-name} {2}.sum-vat <> {2}.sum-vat then do:
     if input frame {&frame-name} {2}.price-cli <> 0 and
        input frame {&frame-name} {2}.sum-vat >=
        (input frame {&frame-name} {2}.cli-qnty * input frame {&frame-name} {2}.price-cli -
         (if vat_type = {&inc-vat} then input frame {&frame-name} {2}.sum-vat else 0))
        then do:
        message "НДС не может быть больше 99.999...%" skip
                "НДС:"  input frame {&frame-name} {2}.sum-vat skip
                "Сумма:" input frame {&frame-name} {2}.cli-qnty * input frame {&frame-name} {2}.price-cli
                view-as alert-box error.
        display {2}.sum-vat with frame {&frame-name}.
        return no-apply.
     end.
     else do:
       if input frame {&frame-name} {2}.sum-vat = 0.00 then do:
          g#log = no.
          message "Вы хотите установить НДС в 0?"
          view-as alert-box question buttons yes-no update g#log.
          if g#log = yes then do:
             assign frame {&frame-name} {2}.sum-vat.
             run calc-vat-pc in this-procedure .
             /* ? */
          end.
          else do:
              display {2}.sum-vat with frame {&frame-name}.
              return no-apply.
          end.
       end.
       else do:
          assign frame {&frame-name} {2}.sum-vat.
          run calc-vat-pc in this-procedure .
          /**/
       end.
     end.
   end.

end.

procedure calc-vat-pc:
  {2}.vat-pc = (input frame {&frame-name} {2}.sum-vat / (input frame {&frame-name} {2}.cli-qnty * input frame {&frame-name} {2}.price-cli
           * ( 1 - (if slt_type = {&inc-slt} then (input frame {&frame-name} {2}.slt-pc / (100 + input frame {&frame-name} {2}.slt-pc)) else 0))
          - (if vat_type =  {&inc-VAT} then input frame {&frame-name} {2}.sum-vat else 0))) * 100.
  run ass-var in this-procedure .
end procedure.

ON LEAVE OF {2}.vat-pc OR
   LEAVE OF {2}.SLT-pc IN FRAME {&frame-name} DO:
   if input frame {&frame-name} {2}.vat-pc <> {2}.vat-pc or
      input frame {&frame-name} {2}.slt-pc <> {2}.slt-pc then do:
      if vat-sumvalue <> "yes" then do:
         IF INDEX(input frame {&frame-name} {2}.vat-pc, dops) = 0 then do:
            message "Неверное значение НДС:" input frame {&frame-name} {2}.vat-pc  SKIP
                    "Разрешенные значения: " dops "."
                    view-as alert-box.
            display {2}.vat-pc with frame {&frame-name}.
            return no-apply.
         end.
         IF INDEX(input frame {&frame-name} {2}.slt-pc, dop-slt) = 0 then do:
            message "Неверное значение НсП."   SKIP
                    "Разрешенные значения: " dop-slt "."
                    view-as alert-box.
            display {2}.slt-pc with frame {&frame-name}.
            return no-apply.
         end.
      end.
      assign frame {&frame-name} {2}.vat-pc
             frame {&frame-name} {2}.slt-pc.
      run ass-var in this-procedure .
   end.
END.

procedure disp-total:
define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.
/* еще ничего не определнено */
if  loc-base-rate =  0  and
    loc-base-scale = 0  and
    loc-exch-rate  = 0  and
    loc-exch-scale = 0  then return.
if vat_type = "" or vat_type = ? then do:
assign
     vat_type   = {&inc-vat}
     slt_type   = {&without-slt}
.
end.

  /*Расчет поля <<сумма НДС>>*/
  { str/in-vat.i
    "'zakaz':u"
    loc-base-rate
    loc-base-scale
    loc-exch-rate
    loc-exch-scale
    vat_type
    slt_type
    {2}.artic
    {2}.prod-type
    {2}.prod-code
    {2}.price-cli
    {2}.cli-base-rate
    {2}.price-rubl
    "input frame {&frame-name} {2}.vat-pc"
    "input frame {&frame-name} {2}.slt-pc"
    "input frame {&frame-name} {2}.road-tax"
    "input frame {&frame-name} {2}.transport-rubl"
    "input frame {&frame-name} {2}.other-rubl"
    varprice-cli-dt
    varprice-cli-unit-base-dt
    varprice-road-tax-dt
    varprice-other-exp-dt
    varprice-transport-exp-dt
    varprice-without-abs-dt
    varprice-slt-dt
    varprice-no-slt-dt
    varprice-vat-dt
    varprice-no-vat-slt-dt
    varprice-rubl-dt
    varprice-road-tax-rubl-dt
    varprice-other-exp-rubl-dt
    varprice-transport-exp-rubl-dt
    varprice-without-abs-rubl-dt
    varprice-slt-rubl-dt
    varprice-no-slt-rubl-dt
    varprice-vat-rubl-dt
    varprice-no-vat-slt-rubl-dt
    varprice-base-dt
    varprice-road-tax-base-dt
    varprice-other-exp-base-dt
    varprice-transport-exp-base-dt
    varprice-without-abs-base-dt
    varprice-slt-base-dt
    varprice-no-slt-base-dt
    varprice-vat-base-dt
    varprice-no-vat-slt-base-dt
    no-error
    }
    if error-status:error then do:
      return error substitute( "Ошибка при пересчете линии заказа . &1" , return-value ) .
    end.
/*
message
                               vss-include-info{&vssseq} skip
                               vss-workfile vss-revision vss-description skip

        "loc-base-rate                       " loc-base-rate         skip
        "loc-base-scale                      " loc-base-scale        skip
        "loc-exch-rate                       " loc-exch-rate         skip
        "loc-exch-scale                      " loc-exch-scale        skip
        "vat_type                            " vat_type              skip
        "slt_type                            " slt_type              skip
        "{2}.artic                           " {2}.artic             skip
        "{2}.prod-type                       " {2}.prod-type         skip
        "{2}.prod-code                       " {2}.prod-code         skip

        "-----------------" skip

        "{2}.price-cli                       " {2}.price-cli         skip
        "{2}.cli-base-rate                   " {2}.cli-base-rate     skip
        "{2}.price-rubl                      " {2}.price-rubl        skip
        "{2}.price-base                      " {2}.price-base        skip
        "{2}.vat-pc                          " {2}.vat-pc            skip
        "{2}.slt-pc                          " {2}.slt-pc            skip
        "{2}.road-tax                        " {2}.road-tax                 skip
        "{2}.transport-rubl                  " {2}.transport-rubl           skip
        "{2}.other-rubl                      " {2}.other-rubl               skip
        "-----------------"  skip

        "var  price-cli-dt                     " varprice-cli-dt              skip
        "var  price-cli-unit-base-dt           " varprice-cli-unit-base-dt    skip
        "var  price-road-tax-dt                " varprice-road-tax-dt         skip
        "var  price-other-exp-dt               " varprice-other-exp-dt        skip
        "var  price-transport-exp-dt           " varprice-transport-exp-dt    skip
        "var  price-without-abs-dt             " varprice-without-abs-dt      skip
        "var  price-slt-dt                     " varprice-slt-dt              skip
        "var  price-no-slt-dt                  " varprice-no-slt-dt           skip
        "var  price-vat-dt                     " varprice-vat-dt              skip
        "var  price-no-vat-slt-dt              " varprice-no-vat-slt-dt       skip
        "var  price-rubl-dt                    " varprice-rubl-dt             skip
        "var  price-road-tax-rubl-dt           " varprice-road-tax-rubl-dt      skip
        "var  price-other-exp-rubl-dt          " varprice-other-exp-rubl-dt     skip
        "var  price-transport-exp-rubl-dt      " varprice-transport-exp-rubl-dt skip
        "var  price-without-abs-rubl-dt        " varprice-without-abs-rubl-dt   skip
        "var  price-slt-rubl-dt                " varprice-slt-rubl-dt           skip
        "var  price-no-slt-rubl-dt             " varprice-no-slt-rubl-dt        skip
        "var  price-vat-rubl-dt                " varprice-vat-rubl-dt           skip
        "var  price-no-vat-slt-rubl-dt         " varprice-no-vat-slt-rubl-dt    skip skip
        "var  price-base-dt                    " varprice-base-dt               skip skip
        "var  price-road-tax-base-dt           " varprice-road-tax-base-dt      skip skip
        "var  price-other-exp-base-dt          " varprice-other-exp-base-dt     skip skip
        "var  price-transport-exp-base-dt      " varprice-transport-exp-base-dt skip
        "var  price-without-abs-base-dt        " varprice-without-abs-base-dt   skip
        "var  price-slt-base-dt                " varprice-slt-base-dt           skip
        "var  price-no-slt-base-dt             " varprice-no-slt-base-dt             skip
        "var  price-vat-base-dt                " varprice-vat-base-dt                skip
        "var  price-no-vat-slt-base-dt         " varprice-no-vat-slt-base-dt         skip

       .
  */

   assign
    {2}.sum-vat    = varprice-vat-dt  * input frame {&frame-name} {2}.cli-qnty
    {2}.sum-slt    = varprice-slt-dt
    {2}.road-tax   = if var-report-r-b = "rubl" then   varprice-road-tax-rubl-dt else varprice-road-tax-base-dt
    {2}.other-base = varprice-other-exp-base-dt
    {2}.other-rubl = varprice-other-exp-rubl-dt
    {2}.price-rubl = varprice-rubl-dt
    {2}.price-base = varprice-base-dt
    {2}.price-cli  = varprice-cli-dt
     .
end procedure.
&endif


procedure ass-var :
 {&start-proc}
&if "{2}" = "loc-line-rcv" &then
if {2}.qnty:sensitive in frame dialog-frame         then {2}.qnty           = input frame {&frame-name} {2}.qnty         .
if {2}.cli-qnty:sensitive in frame dialog-frame     then {2}.cli-qnty       = input frame {&frame-name} {2}.cli-qnty     .
if {2}.price-base:sensitive  in frame dialog-frame  then {2}.price-base     = input frame {&frame-name} {2}.price-base   .
if {2}.price-rubl:sensitive in frame dialog-frame   then {2}.price-rubl     = input frame {&frame-name} {2}.price-rubl   .
if {2}.price-cli:sensitive  in frame dialog-frame   then {2}.price-cli      = input frame {&frame-name} {2}.price-cli    .
if {2}.cli-base-rate:sensitive in frame dialog-frame then {2}.cli-base-rate = input frame {&frame-name} {2}.cli-base-rate.
 loc-store-type =  loc-doc-rcv.obj-type .
 loc-store-code =  loc-doc-rcv.obj-code .

&endif

 assign
    pargds-code =  ub.goods.gds-code
    parobj-type =  loc-store-type
    parobj-code =  loc-store-code
 .
{ str/kndinpin.i
pargds-code
loc-cli-type
loc-cli-code
parobj-type
parobj-code
parext-gds-type
parcli-qnty-input
pardensity-input
parcli-base-rate-input
pardoc-qnty-input
parfact-qnty-input
parprice-cli-input
parbase-price-input
partax-3-input
parcli-qnty-calc
pardensity-calc
parcli-base-rate-calc
pardoc-qnty-calc
parfact-qnty-calc
parprice-cli-calc
parbase-price-calc
partax-3-calc
parround
no-error
}
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "1"
  view-as alert-box error
.
/*если серийный делаем заказ в ед пост. */

if  parext-gds-type =  {&gds-serial} then
  do:
   assign
    parcli-qnty-input   = true
    parprice-cli-input  = true
   .

  end.
/*
message
vss-include-info{&vssseq} skip
vss-workfile vss-revision vss-description skip

"pargds-code                     "        pargds-code                       skip
       " parobj-type                    "         parobj-type                       skip
       " parobj-code                    "         parobj-code                       skip
       " parext-gds-type                "         parext-gds-type                   skip
       " parcli-qnty-input              "         parcli-qnty-input                 skip
       " pardensity-input               "         pardensity-input                  skip
       " parcli-base-rate-input         "         parcli-base-rate-input            skip
       " pardoc-qnty-input              "         pardoc-qnty-input                 skip
       " parfact-qnty-input             "         parfact-qnty-input                skip
       " parprice-cli-input             "         parprice-cli-input                skip
       " parbase-price-input            "         parbase-price-input               skip
       " partax-3-input                 "         partax-3-input                    skip
       " parcli-qnty-calc               "         parcli-qnty-calc                  skip
       " pardensity-calc                "         pardensity-calc                   skip
       " parcli-base-rate-calc          "         parcli-base-rate-calc             skip
       " pardoc-qnty-calc               "         pardoc-qnty-calc                  skip
       " parfact-qnty-calc              "         parfact-qnty-calc                 skip
       " parprice-cli-calc              "         parprice-cli-calc                 skip
       " parbase-price-calc             "         parbase-price-calc                skip
       " partax-3-calc                  "         partax-3-calc                     skip
       " parround                       "         parround                          skip

       .
  */
if g#type =  {&o-f} then
assign
parbase-price-my = false
parbase-price-input = false
parprice-cli-input  = false
.
else
assign
  parbase-price-my = true
.

 &if "{2}"  = "tmp#zakaz" &then
run tax-name in this-procedure (input {&road-tax}, output varroad-tax-label) no-error.
assign
  {2}.road-tax:label in frame {&frame-name} = varroad-tax-label
   .

 &endif

if parbase-price-calc = 'cli-price' then do:
 assign  frame {&frame-name} {&ass-f} {2}.price-rubl {2}.price-base .
 assign
    {2}.sum-rubl = input frame {&frame-name} {2}.price-rubl  * input frame {&frame-name} {2}.qnty
    {2}.sum-base = {2}.price-base  * input frame {&frame-name} {2}.qnty
    {2}.sum-cli  = {2}.price-cli   * input frame {&frame-name} {2}.cli-qnty
    tot-rubl     = input frame {&frame-name} {2}.price-rubl * input frame {&frame-name} {2}.qnty
    tot-base     = {2}.price-base * input frame {&frame-name} {2}.qnty
    tot-cli      = {2}.price-cli  * input frame {&frame-name} {2}.cli-qnty
    .
end.
else do:
 &if "{2}"  = "tmp#zakaz" &then
   assign  frame {&frame-name} {&ass-f}.
 &endif
 assign
    {2}.sum-rubl = {2}.price-rubl  * input frame {&frame-name} {2}.qnty
    {2}.sum-base = {2}.price-base  * input frame {&frame-name} {2}.qnty
    {2}.sum-cli  = input frame {&frame-name} {2}.price-cli   * input frame {&frame-name} {2}.cli-qnty
    tot-rubl     = {2}.price-rubl * input frame {&frame-name} {2}.qnty
    tot-base     = {2}.price-base * input frame {&frame-name} {2}.qnty
    tot-cli      = input frame {&frame-name} {2}.price-cli  * input frame {&frame-name} {2}.cli-qnty
    .
end.
  &if "{2}"  <> "tmp#zakaz" &then
  DISPLAY
    {2}.price-rubl
    {2}.price-base
    {2}.price-cli
    tot-cli
    tot-rubl
    tot-base WITH FRAME {&frame-name}.
  &endif

 &if "{2}"  = "tmp#zakaz" &then
 assign
    {2}.sum-excise          = input frame {&frame-name} {2}.excise         * input frame {&frame-name} {2}.qnty
    {2}.sum-other-base      = input frame {&frame-name} {2}.other-base     * input frame {&frame-name} {2}.qnty
    {2}.sum-other-rubl      = input frame {&frame-name} {2}.other-rubl     * input frame {&frame-name} {2}.qnty
    {2}.sum-road-tax        = input frame {&frame-name} {2}.road-tax       * input frame {&frame-name} {2}.qnty
    {2}.sum-transport-base  = input frame {&frame-name} {2}.transport-base * input frame {&frame-name} {2}.qnty
    {2}.sum-transport-rubl  = input frame {&frame-name} {2}.transport-rubl * input frame {&frame-name} {2}.qnty
    .
run disp-total in this-procedure .

 enable
      {2}.qnty           when pardoc-qnty-input = true
      {2}.cli-qnty       when parcli-qnty-input = true
      {2}.price-base
      {2}.price-rubl     when parbase-price-input = true
      {2}.price-cli      when parprice-cli-input  = true
      {2}.road-tax       when partax-3-input = true
      {2}.cli-base-rate  when parcli-base-rate-input = true
      {2}.unit-cli       when parcli-base-rate-input = true
      r-units            when parcli-base-rate-input = true
     with frame {&frame-name} .
disable
      {2}.qnty when pardoc-qnty-input = false
      {2}.cli-qnty when parcli-qnty-input = false
      {2}.price-base
      {2}.price-rubl when parbase-price-input = false
      {2}.price-cli  when parprice-cli-input  = false
      {2}.road-tax   when partax-3-input = false
      {2}.cli-base-rate  when parcli-base-rate-input = false
      {2}.unit-cli when parcli-base-rate-input = false
      r-units when parcli-base-rate-input = false
     with frame {&frame-name} .
 if loc-doc-type = {&o-f}  Then do:
    display
        {2}.qnty
        {2}.cli-qnty
        {2}.unit-cli
        {2}.cli-base-rate
        with frame {&frame-name} .
        hide     {2}.price-rubl        {2}.price-base in frame {&frame-name} .
      end.
      else do:
      display
            {2}.qnty
            {2}.cli-qnty
            {2}.price-rubl
            {2}.price-base
            {2}.price-cli
            {2}.sum-rubl
            {2}.sum-base
            {2}.sum-cli
            {2}.sum-excise
            {2}.sum-other-base
            {2}.sum-other-rubl
            {2}.sum-road-tax
            {2}.sum-transport-base
            {2}.sum-transport-rubl
            {2}.unit-cli
            {2}.cli-base-rate
            {2}.sum-vat
            {2}.sum-slt
            {2}.vat-pc
            {2}.slt-pc
      with frame {&frame-name} .
      end.
      Hide tot-cli  tot-rubl tot-base in FRAME {&frame-name}.
  run edoc-nn-proc in this-procedure .
&endif
&if "{2}" = "loc-line-rcv" &then
  assign  frame {&frame-name}
    {2}.qnty
    {2}.cli-qnty
    {2}.price-base
    {2}.price-rubl
    {2}.price-cli
    {2}.cli-base-rate
 .
  assign
 {2}.price-base:screen-value = string({2}.price-base)
 {2}.price-rubl:screen-value = string({2}.price-rubl)
 {2}.price-cli:screen-value  = string({2}.price-cli )

  .
 run disp-total in this-procedure  no-error .
 if error-status :error then do:
    message error-status :error error-status :get-message(1) .
    return.
    end.

 enable
      {2}.qnty when pardoc-qnty-input = true
      {2}.cli-qnty when parcli-qnty-input = true
      {2}.price-base     when parbase-price-input = true and     loc-doc-type = "out":u
      {2}.price-rubl     when parbase-price-input = true and     loc-doc-type = "out":u
      {2}.price-cli      when parprice-cli-input  = true and     loc-doc-type = "out":u
      {2}.vat-pc         when parbase-price-input = true and     loc-doc-type = "out":u
      {2}.slt-pc         when parbase-price-input = true and     loc-doc-type = "out":u
      {2}.cli-base-rate  when parcli-base-rate-input = true
     with frame {&frame-name} .
disable
      {2}.qnty when pardoc-qnty-input = false
      {2}.cli-qnty when parcli-qnty-input = false
      {2}.price-base when parbase-price-input = false or          loc-doc-type = "in":u
      {2}.price-rubl when parbase-price-input = false or          loc-doc-type = "in":u
      {2}.vat-pc when parbase-price-input = false or          loc-doc-type = "in":u
      {2}.slt-pc when parbase-price-input = false or          loc-doc-type = "in":u
      {2}.price-cli  when parprice-cli-input  = false or          loc-doc-type = "in":u
      {2}.cli-base-rate  when parcli-base-rate-input = false
     with frame {&frame-name} .
      if loc-doc-type = {&o-f}  Then do:
      display
            {2}.qnty
            {2}.cli-qnty
            {2}.cli-base-rate
            with frame {&frame-name} .
            end.
      else do:
      display
            {2}.qnty
            {2}.cli-qnty
            {2}.price-rubl
            {2}.price-base
            {2}.price-cli
            {2}.cli-base-rate
            with frame {&frame-name} .
      end.


      Hide tot-cli  tot-rubl tot-base in FRAME {&frame-name}.
&endif
 end. /* start-proc */
end procedure. /* ass-var */

PROCEDURE apply-focus-next-entry :
{&start-proc}
  define input parameter p-widget-handle as handle no-undo .
  do with frame {&frame-name} :
      &If "{2}" =  "b-ord-gds-dtl"  &then
      if {2}.cli-qnty :handle = p-widget-handle then apply "entry":u to {2}.price-cli .
      &endif

      &If "{2}" =  "tmp#zakaz"  &then

      if {2}.cli-qnty :handle = p-widget-handle then do:
         if tmp#zakaz.cli-base-rate:sensitive then
            apply "entry":u to tmp#zakaz.cli-base-rate   in frame {&frame-name} .
         if tmp#zakaz.price-cli:sensitive then
            apply "entry":u to tmp#zakaz.price-cli   in frame {&frame-name} .
         if tmp#zakaz.price-rubl:sensitive then
            apply "entry":u to tmp#zakaz.price-rubl  in frame {&frame-name} .
         if tmp#zakaz.price-base:sensitive then
            apply "entry":u to tmp#zakaz.price-base  in frame {&frame-name} .
         end.
      if {2}.qnty :handle = p-widget-handle then  do:
         if tmp#zakaz.cli-base-rate:sensitive then
            apply "entry":u to tmp#zakaz.cli-base-rate   in frame {&frame-name} .
         if tmp#zakaz.price-rubl:sensitive then
            apply "entry":u to tmp#zakaz.price-rubl  in frame {&frame-name} .
         if tmp#zakaz.price-base:sensitive then
            apply "entry":u to tmp#zakaz.price-base  in frame {&frame-name} .
         if tmp#zakaz.price-cli:sensitive  then
            apply "entry":u to tmp#zakaz.price-cli   in frame {&frame-name} .
         end.

      &endif
  end. /* do with frame */
end.
END PROCEDURE.

&If "{2}" =  "tmp#zakaz"  &then
ON  RETURN OF tmp#zakaz.cli-qnty IN FRAME  {&frame-name}
DO:
  run apply-focus-next-entry in this-procedure  (input  tmp#zakaz.cli-qnty :handle ) .
  return no-apply .
END.

ON  RETURN OF tmp#zakaz.qnty IN FRAME  {&frame-name}
DO:
  run apply-focus-next-entry in this-procedure  (input  tmp#zakaz.qnty :handle ) .
  return no-apply .
END.
&endif

&endif

&if "{2}" = "loc-line-rcv" &then
procedure disp-total:
define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.
/* еще ничего не определнено */
if  loc-base-rate =  0  and
    loc-base-scale = 0  and
    loc-exch-rate  = 0  and
    loc-exch-scale = 0  then return.

if vat_type = "" or vat_type = ? then do:
assign
     vat_type   = {&inc-vat}
     slt_type   = {&without-slt}
.
end.

  /*Расчет поля <<сумма НДС>>*/
  { str/in-vat.i
    "'zakaz':u"
    loc-base-rate
    loc-base-scale
    loc-exch-rate
    loc-exch-scale
    vat_type
    slt_type
    {2}.artic
    {2}.prod-type
    {2}.prod-code
    {2}.price-cli
    {2}.cli-base-rate
    {2}.price-rubl
    {2}.vat-pc
    {2}.slt-pc
    {2}.road-tax
    {2}.transport-rubl
    {2}.other-rubl
    varprice-cli-dt
    varprice-cli-unit-base-dt
    varprice-road-tax-dt
    varprice-other-exp-dt
    varprice-transport-exp-dt
    varprice-without-abs-dt
    varprice-slt-dt
    varprice-no-slt-dt
    varprice-vat-dt
    varprice-no-vat-slt-dt
    varprice-rubl-dt
    varprice-road-tax-rubl-dt
    varprice-other-exp-rubl-dt
    varprice-transport-exp-rubl-dt
    varprice-without-abs-rubl-dt
    varprice-slt-rubl-dt
    varprice-no-slt-rubl-dt
    varprice-vat-rubl-dt
    varprice-no-vat-slt-rubl-dt
    varprice-base-dt
    varprice-road-tax-base-dt
    varprice-other-exp-base-dt
    varprice-transport-exp-base-dt
    varprice-without-abs-base-dt
    varprice-slt-base-dt
    varprice-no-slt-base-dt
    varprice-vat-base-dt
    varprice-no-vat-slt-base-dt
    no-error
    }
    if error-status:error then do:
      return error "Ошибка при пересчете линии ПОСТАВКИ".
    end.
/*
 message
    vss-include-info{&vssseq} skip
    vss-workfile vss-revision vss-description skip
    333

"loc-base-rate                       " loc-base-rate         skip
        "loc-base-scale                      " loc-base-scale        skip
        "loc-exch-rate                       " loc-exch-rate         skip
        "loc-exch-scale                      " loc-exch-scale        skip
        "vat_type                            " vat_type              skip
        "slt_type                            " slt_type              skip
        "{2}.artic                           " {2}.artic             skip
        "{2}.prod-type                       " {2}.prod-type         skip
        "{2}.prod-code                       " {2}.prod-code         skip

        "-----------------" skip

        "{2}.price-cli                       " {2}.price-cli         skip
        "{2}.cli-base-rate                   " {2}.cli-base-rate     skip
        "{2}.price-rubl                      " {2}.price-rubl        skip
        "{2}.vat-pc                          " {2}.vat-pc            skip
        "{2}.slt-pc                          " {2}.slt-pc            skip
        "{2}.road-tax                        " {2}.road-tax                 skip
        "{2}.transport-rubl                  " {2}.transport-rubl           skip
        "{2}.other-rubl                      " {2}.other-rubl               skip
        "-----------------"  skip


        "varprice-cli-unit-base-dt           " varprice-cli-unit-base-dt    skip
        "varprice-road-tax-dt                " varprice-road-tax-dt         skip
        "varprice-other-exp-dt               " varprice-other-exp-dt        skip
        "varprice-transport-exp-dt           " varprice-transport-exp-dt    skip
        "varprice-without-abs-dt             " varprice-without-abs-dt      skip
        "varprice-slt-dt                     " varprice-slt-dt              skip
        "varprice-no-slt-dt                  " varprice-no-slt-dt           skip
        "varprice-vat-dt                     " varprice-vat-dt              skip
        "varprice-no-vat-slt-dt              " varprice-no-vat-slt-dt       skip

        "varprice-road-tax-rubl-dt           " varprice-road-tax-rubl-dt      skip
        "varprice-other-exp-rubl-dt          " varprice-other-exp-rubl-dt     skip
        "varprice-transport-exp-rubl-dt      " varprice-transport-exp-rubl-dt skip
        "varprice-without-abs-rubl-dt        " varprice-without-abs-rubl-dt   skip
        "varprice-slt-rubl-dt                " varprice-slt-rubl-dt           skip
        "varprice-no-slt-rubl-dt             " varprice-no-slt-rubl-dt        skip
        "varprice-vat-rubl-dt                " varprice-vat-rubl-dt           skip
        "varprice-no-vat-slt-rubl-dt         " varprice-no-vat-slt-rubl-dt    skip skip

        "varprice-road-tax-base-dt           " varprice-road-tax-base-dt      skip skip
        "varprice-other-exp-base-dt          " varprice-other-exp-base-dt     skip skip
        "varprice-transport-exp-base-dt      " varprice-transport-exp-base-dt skip
        "varprice-without-abs-base-dt        " varprice-without-abs-base-dt   skip
        "varprice-slt-base-dt                " varprice-slt-base-dt           skip
        "varprice-no-slt-base-dt             " varprice-no-slt-base-dt             skip
        "varprice-vat-base-dt                " varprice-vat-base-dt                skip
        "varprice-no-vat-slt-base-dt         " varprice-no-vat-slt-base-dt         skip
         skip skip
         "----------------------------------------------------"  skip
        "varprice-cli-dt                     " varprice-cli-dt              skip
        "varprice-rubl-dt                    " varprice-rubl-dt             skip
        "varprice-base-dt                    " varprice-base-dt
       .
  */
  assign
    {2}.sum-vat    = varprice-vat-dt  * input frame {&frame-name} {2}.cli-qnty
    {2}.sum-slt    = varprice-slt-dt
    {2}.road-tax   = if var-report-r-b = "rubl" then   varprice-road-tax-rubl-dt else varprice-road-tax-base-dt
    {2}.other-base = varprice-other-exp-base-dt
    {2}.other-rubl = varprice-other-exp-rubl-dt
    {2}.price-rubl = varprice-rubl-dt
    {2}.price-base = varprice-base-dt
    {2}.price-cli  = varprice-cli-dt
     .

end procedure.
&endif


&if "{1}" = "create-ord-line" &then
procedure create-ord-line :
define input parameter  p-doc-code       like ub.ord-doc.doc-code         no-undo .
define input parameter  p-line-num       like ub.ord-line.line-num        no-undo .
define input parameter  p-artic          like ub.ord-line.artic           no-undo .
define input parameter  p-prod-code      like ub.ord-line.prod-code       no-undo .
define input parameter  p-prod-type      like ub.ord-line.prod-type       no-undo .
define input parameter  p-cli-base-rate  like ub.ord-line.cli-base-rate   no-undo .
define input parameter  p-qnty           like ub.ord-line.qnty            no-undo .
define input parameter  p-unit-cli       like ub.ord-line.unit-cli        no-undo .

 do
 on error undo, return error return-value
 :
 define variable p-cli-qnty               like ub.ord-line.cli-qnty        no-undo .

 define buffer bbb_ord-doc for ub.ord-doc  .
 define buffer tt-goods for ub.goods       .

 find first bbb_ord-doc where bbb_ord-doc.doc-code = p-doc-code no-lock no-error .
 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.

 find first tt-goods where
      tt-goods.artic             =   p-artic          and
      tt-goods.prod-code         =   p-prod-code      and
      tt-goods.prod-type         =   p-prod-type      no-lock no-error .

 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.

find first ub.ord-line where ub.ord-line.artic     = tt-goods.artic     and
                          ub.ord-line.prod-type = tt-goods.prod-type and
                          ub.ord-line.prod-code = tt-goods.prod-code and
                          ub.ord-line.doc-code  = p-doc-code   exclusive-lock    no-error.
if not available ub.ord-line then do:
  create  ub.ord-line.
end.
      assign
        ub.ord-line.gds-code       = tt-goods.gds-code
        ub.ord-line.doc-code       = p-doc-code
        ub.ord-line.line-num       = p-line-num
        ub.ord-line.artic          = p-artic
        ub.ord-line.prod-code      = p-prod-code
        ub.ord-line.prod-type      = p-prod-type
        ub.ord-line.cli-base-rate  = p-cli-base-rate
        ub.ord-line.qnty           = p-qnty
        ub.ord-line.cli-qnty       = ub.ord-line.qnty  / ub.ord-line.cli-base-rate
        ub.ord-line.unit-cli       = p-unit-cli
    .

 if ub.ord-line.price-rubl = 0 or ub.ord-line.price-rubl = ? then
 run last-price in this-procedure (
      input  bbb_ord-doc.host-code ,
      input  ub.ord-line.artic ,
      input  ub.ord-line.prod-type ,
      input  ub.ord-line.prod-code ,
      input  bbb_ord-doc.cli-code  ,
      input  bbb_ord-doc.cli-type  ,
      input  ub.ord-line.cli-base-rate ,
      input  bbb_ord-doc.exch-code ,
      output ub.ord-line.price-base ,
      output ub.ord-line.price-rubl ,
      output ub.ord-line.price-cli   )
      no-error  .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
/* Налоги текущие на сейчас */
{ gbl/pftxvalg.i   tt-goods.gds-code  {&vat-tax-code}  ?  bbb_ord-doc.host-code  bbb_ord-doc.obj-type  bbb_ord-doc.obj-code  ub.ord-line.vat-pc  no-error }
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

     ub.ord-line.sum-rubl = ub.ord-line.qnty * ub.ord-line.price-rubl .
     ub.ord-line.sum-base = ub.ord-line.qnty * ub.ord-line.price-base .
     ub.ord-line.sum-cli  = ub.ord-line.cli-qnty * ub.ord-line.price-cli .

 end. /* do */
end procedure. /* create-ord-line */
&endif

&if "{1}" = "create-chain" &then
procedure create-chain :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-type as character no-undo .
define input  parameter p-rel-doc-code as character no-undo .
define input  parameter p-rel-doc-type as character no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-ps as character no-undo .
define variable v-db-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
  find first ub.sys-ctrl no-lock .
  v-db-num = ub.sys-ctrl.db-num .

  find first ub.ord-chain no-lock where
    ub.ord-chain.doc-code     = p-doc-code     and
    ub.ord-chain.doc-type     = p-doc-type     and
    ub.ord-chain.rel-type     = p-type         and
    ub.ord-chain.rel-doc-code = p-rel-doc-code and
    ub.ord-chain.rel-doc-type = p-rel-doc-type   no-error .
  if available ub.ord-chain then return .
  create ub.ord-chain.
  assign
    ub.ord-chain.doc-code     = p-doc-code
    ub.ord-chain.doc-type     = p-doc-type
    ub.ord-chain.ps           = p-ps
    ub.ord-chain.rel-doc-code = p-rel-doc-code
    ub.ord-chain.rel-doc-type = p-rel-doc-type
    ub.ord-chain.rel-id       = next-value( s-ord-ch, {&db-name_schema} )
    ub.ord-chain.db-num       = v-db-num
    ub.ord-chain.rel-type     = p-type
    .

  end.
end procedure. /* create-chain */
&endif
/* $Workfile$ e n d */