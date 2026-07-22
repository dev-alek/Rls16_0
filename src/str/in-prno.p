block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: in-prno.p $
$Archive: str/in-prno.p $

Формирование временных переоценок для заполнения прихода  (pr-nakl)

Автор: Чернова Светлана Александровна
Дата создания: 02/20/07
Author: Svetlana Chernova
Creation date: 02/20/07

*/

define input  parameter parParentProc as widget-handle no-undo.
define input  parameter p-doc-code    as character     no-undo .
define input  parameter p-artic       as character     no-undo .
define input  parameter p-prod-type   as character     no-undo .
define input  parameter p-prod-code   as integer       no-undo .
define input  parameter p-doc-price-rubl as decimal   no-undo .
define input  parameter p-doc-price-base as decimal   no-undo .
define input  parameter p-doc-price-rubl-novat as decimal   no-undo .
define input  parameter p-doc-price-base-novat as decimal   no-undo .
define input-output parameter p-price-sale  as decimal       no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-prno.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/in-prno.p $":U .
define variable vss-description as character no-undo init "Формирование временных переоценок для заполнения прихода".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
define variable line-mode as character no-undo .  /*  проверить выше */
define variable line-rec as recid no-undo .       /*  проверить выше */
define variable var-pr-r-b as character no-undo .
define variable v-old-price-sale as decimal   no-undo .
define variable v-str as character no-undo .

{ gbl/curr-r-b.i  var-pr-r-b }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/croslist.i     }
{ gbl/clntattr.i     }
{ ref/grpobj.i       }
{ ref/gdsoattr.i     }
{ str/hvrdtax.i      }
{ str/alt-calc.i "main-road-tax" }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/doc-code.i }
{ str/pr-lattr.i }
{ gbl/lineattr.i }
/* Переменные и буфера  в in-pr.p */
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
{ gbl/waitfram.i }
{ str/get-pr.i def }
{ trg/check-bc.i }
{ str/lvldsc.i   }
{ str/specattr.i }
FUNCTION FNC-BASE-CODE
        return integer (local-bc as integer) .
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
end function.

define variable g#log as logical   no-undo .
{ str/alt-calc.i func }
{ str/alt-calc.i proc }



define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .


define buffer b1-doc-line    for ub.doc-line .

define variable doc-code      like ub.trn-doc.doc-code  no-undo . /* для вызова pr-calc.i */
define variable cost-base     as decimal no-undo .  /* для вызова g d savrg  .p (в p r - c a l c.i) */
define variable cost-rubl     as decimal no-undo .  /* для вызова g d savrg  .p (в p r - c a l c.i) */
define variable v-price-base  as decimal no-undo .  /* для вызова g d snovat .p */
define variable v-price-rubl  as decimal no-undo.   /* для вызова g d snovat .p */
define variable tt-price-sale as decimal no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-base   as decimal no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-rubl   as decimal no-undo.   /* для вызова g d snovat .p */
define variable tt-price-prodwihvat as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-prod-vat         as decimal no-undo.   /* для вызова g d s n o v a t . p */


define variable v-root-b-code like ub.bar-code.b-code   no-undo .
define variable pr-list-rec   as recid               no-undo .
define variable calc-rec      as recid                no-undo.

/* метод округления */
define variable par-type       as character          no-undo . /* тип параметра конфигурации        */
define variable v-round-method as character          no-undo . /* способ округления                 */
define variable v-round-base   as decimal            no-undo . /* база для округления / коэффициент */

define variable rem-gds like  ub.goods.gds-code no-undo .

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

/*-----------------------------------------------------------------------------------------------------------------------*/
do on error undo, return error return-value :
find ub.trn-doc where ub.trn-doc.doc-code = p-doc-code no-lock.   /* ПН */

 define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  ub.trn-doc.host-code
        ,input  ub.trn-doc.obj-type
        ,input  ub.trn-doc.obj-code
      ) no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          l-par
          ""
          view-as alert-box error
        .

v-old-price-sale = p-price-sale .
/* 000 */

  if ub.trn-doc.ext-doc-type = {&tdedt_Pri_vnesh} then do:
     /* message par-pr-nakl par-gen-mrgn-ie . */
     if not (par-pr-nakl-ie = yes and par-gen-mrgn-ie = {&typeprice_Before-margin} ) then return .
  end.
  if ub.trn-doc.ext-doc-type = {&tdedt_Pri_Perem} then do:
     /* message par-pr-nakl par-gen-mrgn-iv 'perem'. */
     if not (par-pr-nakl-iv = yes and par-gen-mrgn-iv = {&typeprice_Before-margin} ) then return .
  end.

  if  ub.trn-doc.doc-type <> {&income} or
      ub.trn-doc.is-back-date = true   then do:
    return.
  end.

  find first ub.goods no-lock where
             ub.goods.artic     = p-artic and
              ub.goods.prod-type = p-prod-type and
              ub.goods.prod-code = p-prod-code no-error .
  if error-status :error then return .


define variable p-exist   as logical  no-undo .

  run lineattr-exist in this-procedure (
      input ub.trn-doc.doc-code  ,
      input ub.goods.gds-code    ,
      input {&lineattr-corr-price-sale} ,
      output p-exist ) .
  if p-exist  = true then return . /* была ручная корректировка прод цены в строке ПН */

 run waitfram-show in this-procedure ( "Расчет продажной цены... " ) .
        run ver-modificator-price-is-null (
            input    ub.goods.artic        ,
            input    ub.goods.prod-type    ,
            input    ub.goods.prod-code    ,
            input    ub.trn-doc.obj-type   ,
            input    ub.trn-doc.obj-code   ,
            output   v-ret ).
        if v-ret = false then next.

      find ub.units where
           ub.units.unit-name = ub.goods.unit-base no-lock.
      if lookup ({&petrolium}, ub.units.type) <> 0 then do:
        /* для топлива не генерим */
        return .  /* --->>>--- */
      end.

      /* находим главный код */
      { gbl/gdsbcode.i
        ub.goods.gds-code
        ?
        v-root-b-code }
      /* находим цену главного кода */
      { gbl/bcodeprc.i
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
      for each ub.price-list where
               ub.price-list.doc-num    = gp-doc-num and
               ub.price-list.artic      = ub.goods.artic and
               ub.price-list.prod-type  = ub.goods.prod-type and
               ub.price-list.prod-code  = ub.goods.prod-code and
               ub.price-list.main-price = no,
          first ub.bar-code no-lock where
                ub.bar-code.b-code = ub.price-list.b-code and
                ub.bar-code.unit-cli = ub.goods.unit-base
      :
        if rem-gds <> ub.goods.gds-code
        then do:
          message
            "Артикул:" ub.goods.artic skip
            "Производитель:" ub.goods.prod-type ub.goods.prod-code skip
            ub.goods.gds-name skip
            "По этому товару есть специальные цены по шкале или партиям."
            "Создать для такого товара переоценку по приходу невозможно."
            "Пропускаем."
            view-as alert-box error.
        end.
        assign
          rem-gds = ub.goods.gds-code
        .
        return  .
      end.

      /* делаем документ переоценки */
      find first ub.price-doc exclusive-lock where
                 ub.price-doc.doc-num   = "$" + ub.trn-doc.doc-code no-error .
        if not available ub.price-doc then do:
            create ub.price-doc .
            assign
              ub.price-doc.doc-num   = "$" + ub.trn-doc.doc-code
              ub.price-doc.doc-date  = ub.trn-doc.doc-date
              ub.price-doc.fact-num  = 0
              ub.price-doc.host-code = v-cntxt-host-code-obj
              ub.price-doc.cr-db-num = v-cntxt-db-num
              ub.price-doc.obj-code  = ub.trn-doc.obj-code
              ub.price-doc.obj-type  = ub.trn-doc.obj-type
              ub.price-doc.status_   = {&g___new}
              .
        end.
        /* из ТПЛ автопереоценок */
define buffer buf_price-list-type for ub.price-list-type  .
define variable   p-plt-id as integer   no-undo .
define variable   p-plt-db-num as integer   no-undo .

{ gbl/gtplobj.i
  parparentproc
  ub.trn-doc.obj-type
  ub.trn-doc.obj-code
  yes
  p-plt-id
  p-plt-db-num
  no-error }

  find first buf_price-list-type no-lock where
             buf_price-list-type.stts = integer({&pdf-new}) and
             buf_price-list-type.main = true  and
             buf_price-list-type.plt-id     = p-plt-id     and
             buf_price-list-type.plt-db-num = p-plt-db-num
             no-error .
  if not available buf_price-list-type then do:
     p-price-sale = ? .
     return error substitute("Не найден главный тип прайс-листа  &1 &2" ,p-plt-id ,p-plt-db-num ) .
  end.
    assign
        v-round-method = buf_price-list-type.calc-round-method
        v-round-base   = buf_price-list-type.calc-round-base
    .
      run cre-pr-list  ( input v-root-b-code,
                         input ub.price-doc.doc-num,
                         output pr-list-rec)
                         no-error .
      if error-status :error then do:
        return error.
      end.

      find first ub.price-list where
                 ub.price-list.doc-num    = ub.price-doc.doc-num and
                 ub.price-list.price-type = "" and
                 ub.price-list.b-code     = v-root-b-code
                no-error .
      if error-status :error then do:
         return .
        end.


      find first b1-doc-line where
                 b1-doc-line.doc-code   = ub.trn-doc.doc-code   and
                 b1-doc-line.artic      = ub.price-list.artic     and
                 b1-doc-line.prod-type  = ub.price-list.prod-type and
                 b1-doc-line.prod-code  = ub.price-list.prod-code no-lock no-error .

      ub.price-list.road-tax   = if available b1-doc-line then  b1-doc-line.road-tax  else ? .
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
      if p-new-road-tax <> ub.price-list.road-tax then do:
         p-flag = true .
      end.

        doc-code = ub.trn-doc.doc-code.
        run chec-par in this-procedure (
              output l-par
              ,input  ub.trn-doc.host-code
              ,input  ub.trn-doc.obj-type
              ,input  ub.trn-doc.obj-code
            ) no-error .

          /* нужно посчитать цену способом из goods */
          define variable p-line-mode as character no-undo .
          p-line-mode = line-mode .
          line-mode = "calc":U.
          p-price-sale = 0 .

          run calc-pr-list
            ( input v-root-b-code,
              input ub.price-doc.doc-num,
              input {&pr-calc-goods},
              input ?,
              input v-round-method,
              input v-round-base,
              input p-doc-price-rubl,
              input p-doc-price-base,
              input p-doc-price-rubl-novat,
              input p-doc-price-base-novat,
              output calc-rec
            )
            no-error.
            if error-status :error then
            do:
                 message
                   vss-workfile vss-revision vss-description skip
                   error-status :get-message(1) skip
                   return-value skip
                   ""
                   view-as alert-box error
                 .
                run waitfram-hide in this-procedure.
                return .
            end.
define buffer bufd_price-list for ub.price-list  .
   find first bufd_price-list exclusive-lock where
              recid(bufd_price-list) = calc-rec no-error .
              if available bufd_price-list then do:
                  p-price-sale = bufd_price-list.price-sale .
                  delete bufd_price-list.
              end.
    delete ub.price-doc.

  run waitfram-hide in this-procedure.

end.

{ str/alt-calc.i proc-ver }
{ str/alt-calc.i pr-list in-pr }
{ str/alt-calc.i ver-pr-equ-dq }
{ str/alt-calc.i exp-prt }

procedure ver-par-disc-mar :
 do
 on error undo, return error return-value
 :
define input parameter   p-obj-type    like ub.clients.obj-type no-undo .
define input parameter   p-obj-code    like ub.clients.obj-type no-undo .
define input parameter   p-node-code   like ub.goods.grp-code no-undo .
define output parameter  par-disc-mar  as logical no-undo .

define variable p-host-code as integer no-undo .
define variable p-prc-min as decimal no-undo .
define variable p-prc-max as decimal no-undo .
define variable p-increase-pc as decimal no-undo .
define variable p-round-method as character no-undo .
define variable p-base          as decimal no-undo .
define variable p-value-margin  as integer  no-undo.
define variable p-type-margin   as logical no-undo .
define variable p-value-increase  as integer  no-undo.
define variable p-type-increase  as logical no-undo .
define variable p-value-rmethod  as integer  no-undo.
define variable p-type-rmethod  as logical no-undo .


 par-disc-mar = false .
{ gbl/hostcode.i p-obj-type p-obj-code p-host-code }

if trim(par-pr-discm) = "" then return .

run grp-obj-margin-value
( input   p-node-code    ,
  input   p-obj-type     ,
  input   p-obj-code     ,
  output  p-prc-min      ,
  output  p-prc-max      ,
  output  p-increase-pc  ,
  output  p-round-method ,
  output  p-base         ,
  output  p-value-margin ,
  output  p-type-margin  ,
  output  p-value-increase,
  output  p-type-increase ,
  output  p-value-rmethod ,
  output  p-type-rmethod
  ) .

if p-type-margin = false  then return.

par-disc-mar = true  .

 end. /* do */
end procedure. /* ver-par-disc-mar */