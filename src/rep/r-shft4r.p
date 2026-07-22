block-level on error undo, throw.
/*

$Revision: bdfe88c223c8, 373, rls $
$Author: SShalanin $
$Date: Mon Dec 28 19:14:17 2015 +0300 $
$Workfile: r-shft4r.p $
$Archive: rep/r-shft4r.p $

печать сменного отчета (ЮКОС лист 4 сбор данных - услуги)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter pobj-type     like ub.shift-obj.obj-type   no-undo .
define input parameter pobj-code     like ub.shift-obj.obj-code   no-undo .
define input parameter pshift-date   like ub.shift-obj.shift-date no-undo .
define input parameter pshift-num    like ub.shift-obj.shift-num  no-undo .
DEFINE INPUT PARAMETER pshift-date1  like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num1   like ub.shift-obj.shift-num no-undo.
define input parameter p-previous-shift-date as   date                    no-undo .

define variable vss-revision    as character no-undo initial "$Revision: bdfe88c223c8, 373, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SShalanin $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Dec 28 19:14:17 2015 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-shft4r.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shft4r.p $":U .
define variable vss-description as character no-undo initial "печать сменного отчета (ЮКОС лист 4 сбор данных - услуги)":U .

{ cmp/str-glbl.i                      }
{ cmp/library.i                       }
{ cmp/r-page1.i                       }
{ rep/real-4df.i shared treal-4       }
{ rep/icm-4df.i  shared               }
{ arc/stk-lnrv.i def                  }
{ rep/real-4cr.i        treal-4       }
{ trg/factord.i                       }
{ rep/r-shftfo.i attr-arh-detail-date }
{ arc/stk-lnrv.i calc                 }

define variable vdoc-num        like ub.price-list.doc-num    no-undo .
define variable vprice-sale     like ub.price-list.price-sale no-undo .
define variable vroad-tax       as   decimal                  no-undo .
define variable vexcise         as   decimal                  no-undo .
define variable acc-other-qnty1 as   decimal                  no-undo .
define variable acc-other-netto as   decimal                  no-undo .
define variable mc              like ub.bar-code.b-code       no-undo .

if MOVING <> yes
then do:
  return .
end.
for each  ub.stk-line no-lock where
          ub.stk-line.obj-type   =      pobj-type           and
          ub.stk-line.obj-code   =      pobj-code           and
          ub.stk-line.fact-order >= prev-fo                 AND
          ub.stk-line.fact-order <= fo                      AND
          ub.stk-line.cat-id     =      {&root-cat-id}      and
          ub.stk-line.sum-type   begins {&arh-sadt-service}
  , first ub.goods    no-lock where
          ub.goods.artic     = ub.stk-line.artic     and
          ub.goods.prod-type = ub.stk-line.prod-type and
          ub.goods.prod-code = ub.stk-line.prod-code
 break by ub.stk-line.artic
       by ub.stk-line.prod-type
       by ub.stk-line.prod-code
:
  if last-of( ub.stk-line.prod-code )
  then do:
    { gbl/bcodeprc.i
        pobj-type
        pobj-code
        ub.goods.gds-code
        0
        fo
        vdoc-num
        vprice-sale
        vroad-tax
        vexcise
        no-error
    }
    assign
      mc = ub.goods.gds-code
    .
    { gbl/gdsbcode.i
        ub.goods.gds-code
        ?
        mc
    }
    create t-4 .
    assign
      t-4.gds-code = ub.goods.gds-code
      t-4.main-code = mc
      t-4.artic = ub.goods.artic
      t-4.gds-name = ub.goods.gds-name
      t-4.prod-type = ub.goods.prod-type
      t-4.prod-code = ub.goods.prod-code
      t-4.last-price = vprice-sale
    .

    /* заполнение данными по архивам - инвентаризация и т.д. */
    /* по архивам найдем  реализацию и т.д. */
    for each tt-stk-line
    :
      delete tt-stk-line .
    end.
    
       assign 
        acc-other-qnty1 = 0
        acc-other-netto = 0.
        
        
    run stk-lnrv in this-procedure
      ( input        pobj-type
      , input        pobj-code
      , input        t-4.artic
      , input        t-4.prod-type
      , input        t-4.prod-code
      , input        prev-fo
      , input        fo
      , input        {&arh-sadt-service}
      , input        {&root-cat-id}
      , input        yes
      , output table tt-stk-line
      ) no-error .
    for each tt-stk-line /* tt-stk-line.artic = t-2gds and ... */
    :
      /* поскольку все цифры лягут в графу расход и должны быть там положительными все цифры идут с минусами!!! */
      case substring( tt-stk-line.sum-type, length( {&arh-sadt-service} ) + 1 ) :
        when {&TDEDT_Ras_Vnesh_Kass}     or
        when {&TDEDT_Vozvrat_Vnesh_Kass}
        then do:
          /* уже учли */
        end.
        otherwise do:
          /* суммируем в переменные */
          assign
            acc-other-qnty1 = acc-other-qnty1 - tt-stk-line.fact-qnty
            acc-other-netto = acc-other-netto - tt-stk-line.sum-base
          .
        end.
      end case.
      delete tt-stk-line .
    end. /* for each tt-stk-line */
    run create-treal-4 in this-procedure
      ( input t-4.gds-code
      , input -1
      , input 0
      , input acc-other-qnty1
      , input acc-other-netto
      , input "Прочий докум.расход"
      , input no
      , input ?
      ) no-error .
  end. /* last-of( ub.stk-line.prod-code ) */
end. /* for each ub.stk-line */