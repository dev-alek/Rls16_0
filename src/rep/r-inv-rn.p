block-level on error undo, throw.
/*

$Revision: 1d79976a03ad, 2027, rls $
$Author: EShklyar $
$Date: Fri Oct 18 10:55:57 2019 +0300 $
$Workfile: r-inv-rn.p $
$Archive: rep/r-inv-rn.p $

Сличительная ведомость по результатам инвентаризации (Роснефть)

Автор: Сливенко Сергей Андреевич
Дата создания: 09/14/11
Author: Sergey Slivenko
Creation date: 09/14/11

*/


define variable vss-revision    as character no-undo init "$Revision: 1d79976a03ad, 2027, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 18 10:55:57 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-inv-rn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-inv-rn.p $":U .
define variable vss-description as character no-undo init "Сличительная ведомость по результатам инвентаризации (Роснефть)".
{ cmp/vssrevis.i }

define input parameter parparentproc  as   widget-handle  no-undo .
define input parameter t-only-itog  as logical no-undo.
define input parameter p-inv-date-start  as   date           no-undo .
define input parameter p-inv-date-end    as   date           no-undo .
define input parameter p-inv-shift-start as   integer        no-undo .
define input parameter p-inv-shift-end   as   integer        no-undo .


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ trg/factord.i }
{ rep/ostatok.i }
{ rep/ost-line.i }
{ str/lib-trn.i }
{ ref/grplib.i   }
{ ref/gds-attr.i }


define temp-table tt-obj-inv no-undo
    field name    as character
    field ost        as decimal
    field f-ost      as decimal
    field r-ost      as decimal
    field izl-uc     as decimal
    field izl-rc10   as decimal
    field izl-rc18   as decimal
    field izl-rc     as decimal
    field nst-uc18   as decimal
    field nst-vat18  as decimal
    field nst-uc10   as decimal
    field nst-vat10  as decimal
    field nst-rc     as decimal
    field real-uc    as decimal
    field real-uc10  as decimal
    field real-uc18  as decimal
    field real-rc    as decimal
    field obj-code like clients.obj-code
    field obj-type like clients.obj-type
    field inv        as logical
    index pi is primary unique
     obj-code
     obj-type
    .

define temp-table tt-grp-inv no-undo
    field name    as character
    field ost        as decimal
    field f-ost      as decimal
    field r-ost      as decimal
    field izl-uc     as decimal
    field izl-rc10   as decimal
    field izl-rc18   as decimal
    field izl-rc     as decimal
    field nst-uc18   as decimal
    field nst-vat18  as decimal
    field nst-uc10   as decimal
    field nst-vat10  as decimal
    field nst-rc     as decimal
    field real-uc    as decimal
    field real-uc10  as decimal
    field real-uc18  as decimal
    field real-rc    as decimal
    field obj-code like clients.obj-code
    field obj-type like clients.obj-type
    field grp      like goods.grp-code
    index pi is primary unique
     obj-code
     obj-type
     grp
    .

define temp-table tt-gds-inv no-undo
    field name    as character
    field ost        as decimal
    field f-ost      as decimal
    field r-ost      as decimal
    field izl-uc     as decimal
    field izl-rc10   as decimal
    field izl-rc18   as decimal
    field izl-rc     as decimal
    field nst-uc18   as decimal
    field nst-vat18  as decimal
    field nst-uc10   as decimal
    field nst-vat10  as decimal
    field nst-rc     as decimal
    field real-uc    as decimal
    field real-uc10  as decimal
    field real-uc18  as decimal
    field real-rc    as decimal
    field obj-code like clients.obj-code
    field obj-type like clients.obj-type
    field grp      like goods.grp-code
    field inv      like doc-line.doc-code
    field gds-code like goods.gds-code
    index pi is primary unique
     obj-code
     obj-type
     grp
     gds-code
    index name
     name
    .


define variable g#report-num as integer no-undo .
define variable is-petrolium as logical no-undo.
define variable is-pieces as logical no-undo.

define buffer buf_doc-line for ub.doc-line.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_stk-line for ub.stk-line.
define buffer buf_doc-line-sum for ub.doc-line-sum.



define variable v-gds-start-line          as integer   no-undo .
define variable v-gds-end-line            as integer   no-undo .
define variable v-gds-list                as character no-undo .
define variable v-grp-start-line          as integer   no-undo .
define variable v-grp-end-line            as integer   no-undo .
define variable v-grp-list                as character no-undo .

define variable v-temp-f-o                as decimal no-undo .
define variable v-shift-end-fact-order    as decimal no-undo .
define variable v-shift-start-fact-order  as decimal no-undo .
define variable v-inv-end-fact-order      as decimal no-undo .
define variable v-inv-start-fact-order    as decimal no-undo .

define variable CurrGrpName   as character no-undo .

define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V2         like ub.stk-tot.sum-rubl   no-undo.

define variable  stk-sum-rubl as decimal no-undo.
define variable  stk-vat-rubl as decimal no-undo.
define variable  v-real-uc    as decimal no-undo.

define variable VAT-p  like ub.tax-rate-value.rate-value no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .

run waitfram-show in this-procedure ("Ждите...").

    run ostatok (
        input 0  ,
        input ""  ,yes,
        input x-date-start - 1 ,
        input date('')      ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-shift-start-fact-order ).
    run ostatok (
        input 0  ,
        input ""  ,yes,
        input x-date-start  ,
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-shift-end-fact-order ).

    run ostatok (
        input 0  ,
        input ""  ,yes,
        input p-inv-date-start - 1 ,
        input date('')      ,  p-inv-Shift-Start,p-inv-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-inv-start-fact-order ).
    run ostatok (
        input 0  ,
        input ""  ,yes,
        input p-inv-date-start  ,
        input p-inv-date-end    ,  p-inv-Shift-Start,p-inv-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-inv-end-fact-order ).



run empty-tt in this-procedure.

case x-SelectGood:
     when {&g-all} then
          for each goods no-lock  :
              run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input gds-name,
                           input grp-code,
                           input grp-name
                           ).
          end.
     when {&g-grp} then
       for each tmp#grp no-lock :
          for each goods where trim(goods.grp-name) begins trim(tmp#grp.grp-name) no-lock :
              run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input gds-name,
                           input grp-code,
                           input grp-name
                           ).
          end.
       end.
     when {&g-prod} then
       for each g#cli no-lock :
          for each goods where goods.prod-code = g#cli.obj-code and goods.prod-type = g#cli.obj-type no-lock :
              run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input gds-name,
                           input grp-code,
                           input grp-name
                           ).
          end.
       end.
     otherwise
          for each gds-list no-lock :
              run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input gds-name,
                           input grp-code,
                           input grp-name
                           ).
          end.
end case.

procedure empty-tt :
do
on error undo, return error return-value
:
  empty temp-table tt-obj-inv    .
  empty temp-table tt-grp-inv    .
  empty temp-table tt-gds-inv    .
end.

end procedure. /* empty-tt */


procedure fill-tt:
  define input parameter p-artic     like goods.artic     no-undo.
  define input parameter p-prod-type like goods.prod-type no-undo.
  define input parameter p-prod-code like goods.prod-code no-undo.
  define input parameter p-gds-code  like goods.gds-code  no-undo.
  define input parameter p-gds-name  like goods.gds-name  no-undo.
  define input parameter p-grp-code  like goods.grp-code  no-undo.
  define input parameter p-grp-name  like goods.grp-name  no-undo.

  define variable v-cur-inv          like ub.doc-line.doc-code no-undo.
  define variable attr-value   as character no-undo.
  define variable attr-type    as character no-undo.


DO   /*  for each goods/gds-list no-lock  */
    :
    { str/is-petrl.i
      p-artic
      p-prod-type
      p-prod-code
      is-petrolium
      is-pieces
      no-error
      }
      if error-status :error
      then do:
        return error return-value .
      end.
    if is-petrolium then do :
      run gds-attr-value in this-procedure (
                                   input p-gds-code
                                  ,input {&attr-ptrl-as-good}
                                  ,output attr-value
                                  ,output attr-type) no-error.
      is-petrolium = (not logical(attr-value)).
    end.
    if not is-petrolium then do
    :
    for each obj-list no-lock
        :
        assign
          v-cur-inv = ?
        .

        find first tt-obj-inv where
                                    tt-obj-inv.obj-type = obj-list.obj-type and
                                    tt-obj-inv.obj-code = obj-list.obj-code no-lock no-error.
        if not available tt-obj-inv then do:
            create tt-obj-inv.
            assign tt-obj-inv.name     = obj-list.obj-name
                   tt-obj-inv.obj-type = obj-list.obj-type
                   tt-obj-inv.obj-code = obj-list.obj-code.

        end.

        find last buf_doc-line where
                                    buf_doc-line.ext-doc-type = {&TDEDT_Inv}      and
                                    buf_doc-line.obj-type     = obj-list.obj-type and
                                    buf_doc-line.obj-code     = obj-list.obj-code and
                                    buf_doc-line.artic        = p-artic           and
                                    buf_doc-line.prod-code    = p-prod-code       and
                                    buf_doc-line.prod-type    = p-prod-type       and
                                    buf_doc-line.status_      = {&fact}           and
                                    buf_doc-line.fact-order  <= v-inv-end-fact-order and
                                    buf_doc-line.fact-order   > v-inv-start-fact-order   no-lock no-error.
        if available buf_doc-line then
          assign
                                         v-cur-inv        = buf_doc-line.doc-code
                                         tt-obj-inv.inv   = true
          .

        create tt-gds-inv.
        assign  tt-gds-inv.name     = string(p-gds-name) + " (Артикул: " + string(p-artic) + " )"
                tt-gds-inv.obj-type = obj-list.obj-type
                tt-gds-inv.obj-code = obj-list.obj-code
                tt-gds-inv.inv      = v-cur-inv
                tt-gds-inv.grp      = p-grp-code
                tt-gds-inv.gds-code = p-gds-code.

        find first tt-grp-inv where tt-grp-inv.grp      = tt-gds-inv.grp      and
                                    tt-grp-inv.obj-type = tt-obj-inv.obj-type and
                                    tt-grp-inv.obj-code = tt-obj-inv.obj-code no-lock no-error.
        if not available tt-grp-inv then do:
          create tt-grp-inv.
          assign  tt-grp-inv.name     = p-grp-name
                  tt-grp-inv.obj-type = obj-list.obj-type
                  tt-grp-inv.obj-code = obj-list.obj-code
                  tt-grp-inv.grp      = tt-gds-inv.grp.
        end.

        if tt-gds-inv.inv <> ? then do :
              for first buf_doc-line-sum where buf_doc-line-sum.doc-code = tt-gds-inv.inv and
                                               buf_doc-line-sum.gds-code = p-gds-code     and
                                               buf_doc-line-sum.sum-type = {&sum-after-doc}  no-lock
                                      :
                                      assign
                                        tt-gds-inv.f-ost  = (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)

                                        tt-grp-inv.f-ost = tt-grp-inv.f-ost + tt-gds-inv.f-ost
                                        tt-obj-inv.f-ost = tt-obj-inv.f-ost + tt-gds-inv.f-ost.
              end.
              for first buf_doc-line-sum where buf_doc-line-sum.doc-code = tt-gds-inv.inv and
                                               buf_doc-line-sum.gds-code = p-gds-code     and
                                               buf_doc-line-sum.sum-type = {&sum-before-doc}  no-lock
                                      :
                                      assign
                                        tt-gds-inv.r-ost  = (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)

                                        tt-grp-inv.r-ost = tt-grp-inv.r-ost + tt-gds-inv.r-ost
                                        tt-obj-inv.r-ost = tt-obj-inv.r-ost + tt-gds-inv.r-ost.
              end.

        end. /* if tt-gds-inv.inv <> ? */

/*        find first buf_doc-line where
                                    buf_doc-line.ext-doc-type = {&TDEDT_Inv}      and
                                    buf_doc-line.obj-type     = obj-list.obj-type and
                                    buf_doc-line.obj-code     = obj-list.obj-code and
                                    buf_doc-line.artic        = p-artic           and
                                    buf_doc-line.prod-code    = p-prod-code       and
                                    buf_doc-line.prod-type    = p-prod-type       and
                                    buf_doc-line.status_      = {&fact}           and
                                    buf_doc-line.fact-order   > v-shift-start-fact-order  no-lock no-error.
             find first buf_trn-doc where
                                         buf_trn-doc.doc-code  = buf_doc-line.doc-code and
                                         buf_trn-doc.fact-date = X-date-start no-lock no-error.
             if available buf_trn-doc then
                                         v-fact-order-start = buf_doc-line.fact-order.
             else v-fact-order-start = v-shift-start-fact-order.          */

             for each buf_doc-line-sum where buf_doc-line-sum.obj-type     = obj-list.obj-type  and
                                             buf_doc-line-sum.obj-code     = obj-list.obj-code  and
                                             buf_doc-line-sum.gds-code     = p-gds-code         and
                                             buf_doc-line-sum.sum-type     = {&sum-general-doc} and
                                             buf_doc-line-sum.ext-doc-type = {&TDEDT_Inv}       and
                                             buf_doc-line-sum.fact-order  >  v-inv-start-fact-order and
                                             buf_doc-line-sum.fact-order  <= v-inv-end-fact-order   no-lock,
                            each buf_trn-doc where buf_trn-doc.doc-code = buf_doc-line-sum.doc-code and
                                                   buf_trn-doc.status_  = {&fact}                   no-lock
                            :
                              tt-obj-inv.inv   = true.
                              if buf_doc-line-sum.cost-sum-rubl > 0 then do :
                                  if (buf_doc-line-sum.sale-vat-rubl / (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)) * 100 > 9 and 
                                  (buf_doc-line-sum.sale-vat-rubl / (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)) * 100 < 11 then
                                      assign
                                            tt-gds-inv.izl-rc10 = tt-gds-inv.izl-rc10 + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)

                                            tt-grp-inv.izl-rc10 = tt-grp-inv.izl-rc10 + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)
                                            tt-obj-inv.izl-rc10 = tt-obj-inv.izl-rc10 + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl).
                                  else
                                      assign
                                            tt-gds-inv.izl-rc18 = tt-gds-inv.izl-rc18 + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)

                                            tt-grp-inv.izl-rc18 = tt-grp-inv.izl-rc18 + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)
                                            tt-obj-inv.izl-rc18 = tt-obj-inv.izl-rc18 + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl).
                                    assign
                                            tt-gds-inv.izl-uc = tt-gds-inv.izl-uc + (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-gds-inv.izl-rc = tt-gds-inv.izl-rc + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)

                                            tt-grp-inv.izl-uc = tt-grp-inv.izl-uc + (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-grp-inv.izl-rc = tt-grp-inv.izl-rc + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)
                                            tt-obj-inv.izl-uc = tt-obj-inv.izl-uc + (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-obj-inv.izl-rc = tt-obj-inv.izl-rc + (buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl).
                              end.
                              else do :
                                  if buf_doc-line-sum.cost-vat-rubl = 0 then do:
                                    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
                                    { gbl/pftxvalg.i p-gds-code {&vat-tax-code} ? v-host-code obj-list.obj-type obj-list.obj-code vat-p no-error }
                                  end.  
                                  if VAT-p < 11 and VAT-p > 9 then VAT-p = 10 .
                                  if ((buf_doc-line-sum.cost-vat-rubl / (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)) * 100 > 9 and 
                                  (buf_doc-line-sum.cost-vat-rubl / (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)) * 100 < 11) or vat-p = 10 then
                                      assign
                                            tt-gds-inv.nst-uc10  = tt-gds-inv.nst-uc10  + abs(buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-gds-inv.nst-vat10 = tt-gds-inv.nst-vat10 + abs(buf_doc-line-sum.cost-vat-rubl)

                                            tt-grp-inv.nst-uc10  = tt-grp-inv.nst-uc10  + abs(buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-grp-inv.nst-vat10 = tt-grp-inv.nst-vat10 + abs(buf_doc-line-sum.cost-vat-rubl)
                                            tt-obj-inv.nst-uc10  = tt-obj-inv.nst-uc10  + abs(buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-obj-inv.nst-vat10 = tt-obj-inv.nst-vat10 + abs(buf_doc-line-sum.cost-vat-rubl).
                                  else
                                      assign
                                            tt-gds-inv.nst-uc18  = tt-gds-inv.nst-uc18  + abs(buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-gds-inv.nst-vat18 = tt-gds-inv.nst-vat18 + abs(buf_doc-line-sum.cost-vat-rubl)

                                            tt-grp-inv.nst-uc18  = tt-grp-inv.nst-uc18  + abs(buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-grp-inv.nst-vat18 = tt-grp-inv.nst-vat18 + abs(buf_doc-line-sum.cost-vat-rubl)
                                            tt-obj-inv.nst-uc18  = tt-obj-inv.nst-uc18  + abs(buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-vat-rubl)
                                            tt-obj-inv.nst-vat18 = tt-obj-inv.nst-vat18 + abs(buf_doc-line-sum.cost-vat-rubl).
                                  assign
                                      tt-gds-inv.nst-rc = tt-gds-inv.nst-rc + abs(buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)

                                      tt-grp-inv.nst-rc = tt-grp-inv.nst-rc + abs(buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl)
                                      tt-obj-inv.nst-rc = tt-obj-inv.nst-rc + abs(buf_doc-line-sum.sale-sum-rubl - buf_doc-line-sum.sale-vat-rubl).
                              end.
              end. /*  for each buf_doc-line-sum   */

          assign
            stk-sum-rubl = 0
            stk-vat-rubl = 0
            v-real-uc    = 0
          .
          /* Начало  "Реализация в учётных ценах без ндс"    */
                /* Начало "Расход внешний через КАССУ"  */
                          /*   На конец периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass} use-index pi no-lock no-error.
          if available buf_stk-line then
                   assign
                      tt-gds-inv.real-uc = abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = buf_stk-line.sum-rubl
                      stk-vat-rubl = buf_stk-line.vat-rubl
                      v-real-uc = abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                   .

                        /*   На начало периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass} use-index pi no-lock no-error.
          if available buf_stk-line then
                    assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = stk-sum-rubl - buf_stk-line.sum-rubl
                      stk-vat-rubl = stk-vat-rubl - buf_stk-line.vat-rubl
                      v-real-uc = v-real-uc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                    .

          if (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 > 9 and (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 < 11 then
            tt-gds-inv.real-uc10 = tt-gds-inv.real-uc10 + v-real-uc
          .
          else
            tt-gds-inv.real-uc18 = tt-gds-inv.real-uc18 + v-real-uc
          .
          assign
            stk-sum-rubl = 0
            stk-vat-rubl = 0
            v-real-uc    = 0
          .
                /* Конец "Расход внешний через КАССУ"  */

                /* Начало "Расход внешний"  */
                        /*   На конец периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Ras_Vnesh} use-index pi no-lock no-error.
          if available buf_stk-line then
                   assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc + abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = buf_stk-line.sum-rub
                      stk-vat-rubl = buf_stk-line.vat-rubl
                      v-real-uc = abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                   .

                      /*   На начало периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Ras_Vnesh} use-index pi no-lock no-error.
          if available buf_stk-line then
                    assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = stk-sum-rubl - buf_stk-line.sum-rubl
                      stk-vat-rubl = stk-vat-rubl - buf_stk-line.vat-rubl
                      v-real-uc = v-real-uc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                    .

          if (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 > 9 and (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 < 11 then
            tt-gds-inv.real-uc10 = tt-gds-inv.real-uc10 + v-real-uc
          .
          else
            tt-gds-inv.real-uc18 = tt-gds-inv.real-uc18 + v-real-uc
          .
          assign
            stk-sum-rubl = 0
            stk-vat-rubl = 0
            v-real-uc    = 0
          .
                /* Конец "Расход внешний"  */

                /* Начало "Возврат через КАССУ"  */
                          /*   На конец периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass} use-index pi no-lock no-error.
         if available buf_stk-line then
                    assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc - (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = buf_stk-line.sum-rub
                      stk-vat-rubl = buf_stk-line.vat-rubl
                      v-real-uc = abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                    .

                        /*   На начало периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass} use-index pi no-lock no-error.
          if available buf_stk-line then
                    assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc + (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = stk-sum-rubl - buf_stk-line.sum-rubl
                      stk-vat-rubl = stk-vat-rubl - buf_stk-line.vat-rubl
                      v-real-uc = v-real-uc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                    .

          if (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 > 9 and (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 < 11 then
            tt-gds-inv.real-uc10 = tt-gds-inv.real-uc10 - v-real-uc
          .
          else
            tt-gds-inv.real-uc18 = tt-gds-inv.real-uc18 - v-real-uc
          .
          assign
            stk-sum-rubl = 0
            stk-vat-rubl = 0
            v-real-uc    = 0
          .
                /* Конец "Возврат через КАССУ"  */

                /* Начало "Возврат внешний"  */
                        /*   На конец периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh} use-index pi no-lock no-error.
          if available buf_stk-line then
                    assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc - (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = buf_stk-line.sum-rub
                      stk-vat-rubl = buf_stk-line.vat-rubl
                      v-real-uc = abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                    .

                      /*   На начало периода          */
          find last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh} use-index pi no-lock no-error.
          if available buf_stk-line then
                    assign
                      tt-gds-inv.real-uc = tt-gds-inv.real-uc + (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                      stk-sum-rubl = stk-sum-rubl - buf_stk-line.sum-rubl
                      stk-vat-rubl = stk-vat-rubl - buf_stk-line.vat-rubl
                      v-real-uc = v-real-uc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl)
                    .

          if (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 > 9 and (stk-vat-rubl / (stk-sum-rubl - stk-vat-rubl)) * 100 < 11 then
            tt-gds-inv.real-uc10 = tt-gds-inv.real-uc10 - v-real-uc
          .
          else
            tt-gds-inv.real-uc18 = tt-gds-inv.real-uc18 - v-real-uc
          .

                /* Конец "Возврат внешний"  */
          /* Конец  "Реализация в учётных ценах без ндс"    */

          /* Начало  "Реализация в розничных ценах без ндс"    */
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass} use-index pi no-lock :
                       tt-gds-inv.real-rc = abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Ras_Vnesh} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc + abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Ras_Vnesh} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc - abs(buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc - (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc + (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-end-fact-order       and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc - (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
          for  last buf_stk-line where  buf_stk-line.fact-order  <=  v-shift-start-fact-order     and
                                        buf_stk-line.artic        =  p-artic                and
                                        buf_stk-line.prod-code    =  p-prod-code            and
                                        buf_stk-line.prod-type    =  p-prod-type            and
                                        buf_stk-line.obj-code     =  obj-list.obj-code      and
                                        buf_stk-line.obj-type     =  obj-list.obj-type      and
                                        buf_stk-line.sum-type     = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh} use-index pi no-lock :
                       tt-gds-inv.real-rc = tt-gds-inv.real-rc + (buf_stk-line.sum-rubl - buf_stk-line.vat-rubl).
          end.
            /* Конец  "Реализация в розничных ценах без ндс"    */
          if available tt-grp-inv then
          assign
                    tt-grp-inv.real-uc = tt-grp-inv.real-uc + tt-gds-inv.real-uc
                    tt-grp-inv.real-rc = tt-grp-inv.real-rc + tt-gds-inv.real-rc
                    tt-obj-inv.real-uc = tt-obj-inv.real-uc + tt-gds-inv.real-uc
                    tt-obj-inv.real-rc = tt-obj-inv.real-rc + tt-gds-inv.real-rc

                    tt-grp-inv.real-uc10 = tt-grp-inv.real-uc10 + tt-gds-inv.real-uc10
                    tt-grp-inv.real-uc18 = tt-grp-inv.real-uc18 + tt-gds-inv.real-uc18
                    tt-obj-inv.real-uc10 = tt-obj-inv.real-uc10 + tt-gds-inv.real-uc10
                    tt-obj-inv.real-uc18 = tt-obj-inv.real-uc18 + tt-gds-inv.real-uc18
          .

          run ost-line (
              input obj-list.obj-code  ,
              input obj-list.obj-type  ,
              input p-artic       ,
              input p-prod-code   ,
              input p-prod-type    ,
              input x-TOG-Shift ,
              input v-shift-end-fact-order ,
              input {&arh-cost}   ,
              input {&root-cat-id},
              input YES ,

              output  Quantity2  ,
              output  Coast_R2   ,
              output  Coast_V2   ,
              output  VAT_R2     ,
              output  VAT_V2     ,
              output  slt_R2     ,
              output  slt_V2     ).
          assign tt-gds-inv.ost = (Coast_R2 - VAT_R2)
                 tt-grp-inv.ost = tt-grp-inv.ost + tt-gds-inv.ost
                 tt-obj-inv.ost = tt-obj-inv.ost + tt-gds-inv.ost
          .
    end.   /*    for each obj-list   */
    end.  /*  if not is-petrolium   */
  end.   /*    for each goods/gds-list   */
end procedure.    /*   fill-tt     */



 run waitfram-show in this-procedure ("Ждите... Вывод информации...").
assign
sheetf.Excel-Column-Lable =
"№ АЗС и кафе" + {&comma-char} +
"Остаток на конец отчетного периода (учетная цена без НДС)" + {&comma-char} +
"Фактический остаток (учетная цена без НДС)"  + {&comma-char} +
"Расчетный остаток (учетная цена без НДС)"  + {&comma-char} +
"Излишки (+) в учет. ценах без НДС"  + {&comma-char} +
"Излишки (+) в рознич. ценах (облагаемые 10%) без НДС"  + {&comma-char} +
"Излишки (+) в рознич. ценах (облагаемые 18/20%) без НДС"  + {&comma-char} +
"Излишки (+) в рознич. ценах без НДС"  + {&comma-char} +
"Недостача (-) в уч. ценах без НДС (облагаемая 18/20%)"  + {&comma-char} +
"Сумма НДС (18/20%) относящийся к недостаче" + {&comma-char} +
"Недостача (-) в уч. ценах без НДС (облагаемая по ставке 10%)" + {&comma-char} +
"Сумма НДС (10%) относящийся к недостаче" + {&comma-char} +
"Недостача (-) в рознич. ценах без НДС"  + {&comma-char} +
"Реализация (в учет. ценах без НДС)"  + {&comma-char} +
"Реализация (в учет. ценах без НДС. облагаемая 10%)"  + {&comma-char} +
"Реализация (в учет. ценах без НДС. облагаемая 18/20%)"  + {&comma-char} +
"Реализация (в рознич. ценах без НДС)"
sheetf.sizes =
"35" + {&comma-char} +
"17"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"
Sheetf.colformat = "1=@;2=0,00;3=0,00;4=0,00;5=0,00;6=0,00;7=0,00;8=0,00;9=0,00;10=0,00;11=0,00;12=0,00;13=0,00;14=0,00;15=0,00;16=0,00;17=0,00"
sheetf.Bas-File           = "exe/inv-RN.bas"
sheetf.Bas-Param-Add      = yes
.
/*output stream ForExcel to value( string( session:temp-directory +
                            {&DF_Name} + string( g#report-num ) + ".txt" ) )      .
*/
run rep/extitle.p (1).

assign
      v-gds-start-line  = 1
      v-gds-end-line    = 0

      v-grp-start-line  = 1
      v-grp-end-line    = 0
      v-grp-list        = ''
    .

for each tt-obj-inv break by tt-obj-inv.name:
   v-gds-list        = ''.
   if tt-obj-inv.inv then do:
      {&PutExcel}
      tt-obj-inv.name {&tabulation}
      tt-obj-inv.ost {&tabulation}
      tt-obj-inv.f-ost {&tabulation}
      tt-obj-inv.r-ost {&tabulation}
      tt-obj-inv.izl-uc {&tabulation}
      tt-obj-inv.izl-rc10 {&tabulation}
      tt-obj-inv.izl-rc18 {&tabulation}
      tt-obj-inv.izl-rc {&tabulation}
      tt-obj-inv.nst-uc18 {&tabulation}
      tt-obj-inv.nst-vat18 {&tabulation}
      tt-obj-inv.nst-uc10 {&tabulation}
      tt-obj-inv.nst-vat10 {&tabulation}
      tt-obj-inv.nst-rc {&tabulation}
      tt-obj-inv.real-uc {&tabulation}
      tt-obj-inv.real-uc10 {&tabulation}
      tt-obj-inv.real-uc18 {&tabulation}
      tt-obj-inv.real-rc {&tabulation}
 /*     tt-obj-inv.inv */
      SKIP.
   end.
   Else do:
      {&PutExcel}
      tt-obj-inv.name {&tabulation}
      tt-obj-inv.ost {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      " - " {&tabulation}
      tt-obj-inv.real-uc {&tabulation}
      tt-obj-inv.real-uc10 {&tabulation}
      tt-obj-inv.real-uc18 {&tabulation}
      tt-obj-inv.real-rc {&tabulation}
   /*   tt-obj-inv.inv   */
      SKIP.
   end.
      for each tt-grp-inv where tt-grp-inv.obj-type = tt-obj-inv.obj-type and
                                tt-grp-inv.obj-code = tt-obj-inv.obj-code break by tt-grp-inv.name:
        if tt-grp-inv.ost = 0 and tt-grp-inv.f-ost = 0 and tt-grp-inv.r-ost = 0 and tt-grp-inv.izl-uc = 0 and tt-grp-inv.nst-uc18 = 0 and tt-grp-inv.nst-uc10 = 0 and tt-grp-inv.real-uc = 0 then do:
        delete tt-grp-inv.
        next.
        end.
        else do:
          {&PutExcel}
          tt-grp-inv.name {&tabulation}
          tt-grp-inv.ost {&tabulation}
          tt-grp-inv.f-ost {&tabulation}
          tt-grp-inv.r-ost {&tabulation}
          tt-grp-inv.izl-uc {&tabulation}
          tt-grp-inv.izl-rc10 {&tabulation}
          tt-grp-inv.izl-rc18 {&tabulation}
          tt-grp-inv.izl-rc {&tabulation}
          tt-grp-inv.nst-uc18 {&tabulation}
          tt-grp-inv.nst-vat18 {&tabulation}
          tt-grp-inv.nst-uc10 {&tabulation}
          tt-grp-inv.nst-vat10 {&tabulation}
          tt-grp-inv.nst-rc {&tabulation}
          tt-grp-inv.real-uc {&tabulation}
          tt-grp-inv.real-uc10 {&tabulation}
          tt-grp-inv.real-uc18 {&tabulation}
          tt-grp-inv.real-rc {&tabulation}

        /*  tt-grp-inv.grp */
          SKIP.

          v-grp-end-line = v-grp-end-line + 1.

          if not t-only-itog then do :
          v-gds-start-line = v-grp-end-line + 1.

          for each tt-gds-inv where tt-gds-inv.obj-type = tt-obj-inv.obj-type and
                                    tt-gds-inv.obj-code = tt-obj-inv.obj-code and
                                    tt-gds-inv.grp = tt-grp-inv.grp :
            if tt-gds-inv.ost = 0 and tt-gds-inv.f-ost = 0 and tt-gds-inv.r-ost = 0 and tt-gds-inv.izl-uc = 0 and tt-gds-inv.nst-uc18 = 0 and tt-gds-inv.nst-uc10 = 0 and tt-gds-inv.real-uc = 0 then next.
            else do:
                {&PutExcel}
                tt-gds-inv.name {&tabulation}
                tt-gds-inv.ost {&tabulation}
                tt-gds-inv.f-ost {&tabulation}
                tt-gds-inv.r-ost {&tabulation}
                tt-gds-inv.izl-uc {&tabulation}
                tt-gds-inv.izl-rc10 {&tabulation}
                tt-gds-inv.izl-rc18 {&tabulation}
                tt-gds-inv.izl-rc {&tabulation}
                tt-gds-inv.nst-uc18 {&tabulation}
                tt-gds-inv.nst-vat18 {&tabulation}
                tt-gds-inv.nst-uc10 {&tabulation}
                tt-gds-inv.nst-vat10 {&tabulation}
                tt-gds-inv.nst-rc {&tabulation}
                tt-gds-inv.real-uc {&tabulation}
                tt-gds-inv.real-uc10 {&tabulation}
                tt-gds-inv.real-uc18 {&tabulation}
                tt-gds-inv.real-rc {&tabulation}
              /*  tt-gds-inv.inv   {&tabulation}
                tt-gds-inv.grp */
                SKIP.

                v-grp-end-line = v-grp-end-line + 1.
                v-gds-end-line = v-grp-end-line + 0.
            end. /*  if tt-gds-inv...  */
          end.   /*    for each tt-gds-inv     */
          v-gds-list        = v-gds-list + substitute("&1&2&3" , v-gds-start-line , {&delim-nws}, v-gds-end-line ) + {&delim-par}.
          assign
                v-gds-start-line  = v-grp-end-line + 2
                v-gds-end-line    = v-gds-start-line - 1
            .
         end.  /*  if not t-only-itog   */
        end.  /*  if tt-grp-inv...  */
      end. /*   for each tt-grp-inv    */

      find first tt-grp-inv where tt-grp-inv.obj-type = tt-obj-inv.obj-type and
                                  tt-grp-inv.obj-code = tt-obj-inv.obj-code no-error.
      if available tt-grp-inv then
                v-grp-list  = v-grp-list + substitute("&1&2&3" , v-grp-start-line , {&delim-nws}, v-grp-end-line ) + {&delim-par} + v-gds-list.


      assign
          v-grp-start-line  = v-grp-end-line + 2
          v-grp-end-line    = v-grp-start-line - 1
        .
  /*   {&PutExcel}   tt-obj-inv.fact-ord-end skip.
     {&PutExcel}   tt-obj-inv.fact-ord-start skip. */
end.  /*  for each tt-obj-inv   */
sheetf.Bas-Params   = trim( v-grp-list, {&delim-par}).

/*{&PutExcel} v-grp-list skip.  */


{&CloseExcel}
run waitfram-hide in this-procedure .
run get-report-num in my-handle (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

run waitfram-hide in this-procedure .