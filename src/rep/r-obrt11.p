block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obrt11.p $
$Archive: rep/r-obrt11.p $

расчетная часть детализированой оборотки r-obort1

Автор: Кочетков Михаил Юрьевич
Дата создания: 12/14/06
Author: Michael Kochetkov
Creation date: 12/14/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obrt11.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obrt11.p $":U .
define variable vss-description as character no-undo init "расчетная часть детализированой оборотки r-obort1".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ ref/grplib.i   }
{ rep/obr-defv.i }
{ rep/rep-bt.i   }
{ trg/partslib.i }
{ trg/factord.i  }
{ str/clcprtsl.i }

define variable g#host-code as integer   no-undo .
assign g#host-code = v-cntxt-host-code-obj .

define input parameter RADIO-Nomenkl     as integer   no-undo .
define input parameter Tog-obj           as logical   no-undo .
define input parameter name-tov          as integer   no-undo .
define input parameter no-nds            as logical   no-undo .
define input parameter RADIO-AltObj      as integer   no-undo .
define input parameter AltObj-list       as character no-undo .
define input parameter sys-key           as character no-undo .
define input  parameter prod-zen as logical   no-undo .
define input parameter ShowZero          as logical   no-undo .
define input parameter ShowZero-2        as logical   no-undo .
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR gds-prop .
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR o_temp-parts .


define variable CurrGrpName  as character no-undo .
define variable str-find     as character no-undo .
define variable str-find1    as character no-undo .
define variable str-find2    as character no-undo .

define buffer buf_goods    for ub.goods.
define buffer buf_clients  for ub.clients.
define buffer buf1_clients for ub.clients.
define buffer buf2_clients for ub.clients.
define buffer buf_gds-obj  for ub.gds-obj.
define buffer buf_stk-line for ub.stk-line.
define buffer b_obj-list   for obj-list .
define buffer buf_obj-list for obj-list .
define buffer next_price-list for ub.price-list  .

define variable v-fact-order-start    as decimal   no-undo .
define variable v-fact-order-end      as decimal   no-undo .
/*  define buffer buf_usr-grpo for usr-grpo . */

define variable p-num as integer   no-undo .
define variable ii as integer   no-undo .
define variable Counter1 as integer   no-undo .
define variable vvv1         as decimal   no-undo .
define variable vvv2         as decimal   no-undo .
define variable v-qntyp      as decimal   no-undo .
define variable v-vat-pc as decimal   no-undo .

/* function */

function f-cli-name  returns character
( input p-cli-type as character   ,
  input p-cli-code as integer   ) .
define buffer buf_clients for ub.clients  .
  find first buf_clients no-lock where
             buf_clients.obj-type = p-cli-type  and
             buf_clients.obj-code = p-cli-code  no-error  .
   if available buf_clients then return buf_clients.obj-name .
      else return '' .
end function.


function f-bar-code  returns integer
( input p-artic      as character   ,
  input p-prod-type  as character  ,
  input p-prod-code  as integer   ,
  input p-part-code as character ,
  input p-in-code   as character ) .

define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods    for ub.goods .

  find first buf_goods no-lock where
             buf_goods.artic = p-artic and
             buf_goods.prod-type  = p-prod-type and
             buf_goods.prod-code  = p-prod-code
             no-error .

  find first buf_bar-code no-lock where
             buf_bar-code.gds-code  = buf_goods.gds-code  and
             buf_bar-code.in-code   = p-in-code   and
             buf_bar-code.part-code = p-part-code
             no-error  .
   if available buf_bar-code then return buf_bar-code.b-code .
      else return 0 .
end function.



  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each o_temp-parts :  delete o_temp-parts . end.
  for each gds-prop :  delete gds-prop . end.

  for each buf_obj-list :
    find first buf2_clients
         where buf2_clients.obj-type = buf_obj-list.obj-type
         and buf2_clients.obj-code = buf_obj-list.obj-code
         no-lock
         .

    run get-fo-range in this-procedure
      (  input buf_obj-list.obj-type
      ,  input buf_obj-list.obj-code
      ,  input x-Date-Start
      ,  input x-Date-End
      ,  input x-Shift-Start
      ,  input x-Shift-End
      ,  input x-TOG-Shift
      , output v-fact-order-start
      , output v-fact-order-end
      ) no-error .
    if error-status :error
    then do:
      message return-value view-as alert-box .
      return error .
    end.

    case x-SelectGood :
      when {&g-all} then do: /* все товары */
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = buf_obj-list.obj-type
            and buf_gds-obj.obj-code  = buf_obj-list.obj-code
          :
          run fill-tt in this-procedure .
        end.
      end.
      when {&g-prod} then do:    /* не все производители */
        for each G#cli : /* встать на производителя */
          for each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = buf2_clients.obj-type
              and buf_gds-obj.obj-code  = buf2_clients.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
            use-index pi  :
            run fill-tt in this-procedure .
          end .
        end .                /* do ... по производителям */
      end .
      when {&g-grp} then do:    /* не все группы товаров */
        for each tmp#grp :
          run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type = buf2_clients.obj-type
              and buf_gds-obj.obj-code = buf2_clients.obj-code
              and buf_gds-obj.grp-name begins CurrGrpName
            use-index obj-grp :
            run fill-tt in this-procedure .
          end .
        end.
      end.
      otherwise do:   /* список товаров */
        for each gds-list ,
            each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = buf2_clients.obj-type
            and buf_gds-obj.obj-code  = buf2_clients.obj-code
            and buf_gds-obj.artic     = gds-list.artic
            and buf_gds-obj.prod-type = gds-list.prod-type
            and buf_gds-obj.prod-code = gds-list.prod-code
          :
          run fill-tt in this-procedure .
        end.
      end.

    end case.
  end.                    /* for each ... по объектам */
  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

procedure fill-tt :
  do on error undo, return error return-value :
      { rep/obr-k-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
  end.
end procedure. /* fill-tt */


procedure get-fo-range :
  define input  parameter p-obj-type as character        no-undo.
  define input  parameter p-obj-code as integer          no-undo.
  define input  parameter p-date-from  as date      no-undo .
  define input  parameter p-date-till  as date      no-undo .
  define input  parameter p-shift-from as integer   no-undo .
  define input  parameter p-shift-till as integer   no-undo .
  define input  parameter p-is-shift   as logical   no-undo .
  define output parameter p-fo-from    as decimal   no-undo initial 0.00 .
  define output parameter p-fo-till    as decimal   no-undo initial 0.00 .

  define variable v-shift-end-fact-order as decimal no-undo .
  define variable v-day-end-fact-order   as decimal no-undo .
  define variable v-fact-order           as decimal no-undo .

  define variable Quantity1    like ub.stk-tot.fact-qnty   no-undo.
  define variable Coast_R1     like ub.stk-tot.sum-rubl    no-undo.
  define variable Coast_V1     like ub.stk-tot.sum-rubl    no-undo.
  define variable VAT_R1       like ub.stk-tot.sum-rubl    no-undo.
  define variable VAT_V1       like ub.stk-tot.sum-rubl    no-undo.
  do
  on error undo, return error return-value
  :
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/

    run ostatok in this-procedure (
        input p-obj-code  ,
        input p-obj-type  ,
        input x-TOG-Shift ,
        input x-date-start - 1 ,
        input date('')      ,
        input x-Shift-Start ,
        input x-Shift-End ,
        input {&arh-cost} ,
        input {&root-cat-id} ,
        input yes ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  p-fo-from
        ).
/*----------------------------------------------------------------------------------------------------------------*/
/* номер последнего Fact-ordera и остатки на конец интервала  */
/* номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ*/
    run ostatok (
        input p-obj-code  ,
        input p-obj-type  ,
        input x-TOG-Shift ,
        input x-date-start  ,
        input x-date-end    ,
        input x-Shift-Start ,
        input x-Shift-End ,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input yes ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  p-fo-till ).

  end. /* on error */
end procedure. /* get-fo-range */

{ rep/ostatok.i }