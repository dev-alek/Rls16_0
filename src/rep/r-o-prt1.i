/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

внутренности Foreach для отчета по признакам

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&if "{1}" <> "Display"  &then
for each obj-list no-lock with frame zapas :
    &if "{1}" = "VAT-pc" &then
    for each gds-obj where
             gds-obj.obj-code    = obj-list.obj-code and
             gds-obj.obj-type    = obj-list.obj-type
             {&ver-last-doc}
             no-lock,
             first goods where   goods.gds-code    = gds-obj.gds-code  and
                                 goods.gds-type    = {&gds-goods}
             no-lock ,
             first gds-list where   gds-list.prod-type = gds-obj.prod-type and
                                    gds-list.prod-code = gds-obj.prod-code and
                                    gds-list.artic     = gds-obj.artic
        :
        gds-list.qnty = {&break-vat} .
      end.
    &endif

if not( classify = 1 and itog = true) then do:
  { rep/r-ob-cr.i disp  obj-list.obj-name  f-gds-name}
  { rep/r-ob-cr.i full  "''"   f-qnty         }
  { rep/r-ob-cr.i full  "''"   f-cost-sum     }
  { rep/r-ob-cr.i full  "''"   f-sale-sum     }
  { rep/r-ob-cr.i full  "''"   f-sale-other   }
  { rep/r-ob-cr.i full  "''"   f-crsa-sum     }
  { rep/r-ob-cr.i full  "''"   f-qnty-all     }
  { rep/r-ob-cr.i full  "''"   f-cost-sum-all }
  { rep/r-ob-cr.i full  "''"   f-crsa-sum-all }
  { rep/r-ob-cr.i full  "''"   f-qnty-o       }
  { rep/r-ob-cr.i full  "''"   f-cost-sum-o   }
  { rep/r-ob-cr.i full  "''"   f-crsa-sum-o   }

display stream outstream no-error .
down stream outstream .
  { rep/r-ob-cr.i sfull f-qnty           }
  { rep/r-ob-cr.i sfull f-cost-sum       }
  { rep/r-ob-cr.i sfull f-sale-sum       }
  { rep/r-ob-cr.i sfull f-sale-other     }
  { rep/r-ob-cr.i sfull f-crsa-sum       }
  { rep/r-ob-cr.i sfull f-qnty-all       }
  { rep/r-ob-cr.i sfull f-cost-sum-all   }
  { rep/r-ob-cr.i sfull f-crsa-sum-all   }
  { rep/r-ob-cr.i sfull f-qnty-o         }
  { rep/r-ob-cr.i sfull f-cost-sum-o     }
  { rep/r-ob-cr.i sfull f-crsa-sum-o     }
{&putexcel}  obj-list.obj-name {&new-line}.
end.
      n-nn = 0.
      n-no = n-no + 1 .
for each ub.ot-line where
      ub.ot-line.fact-order <= fact-order-2 and
      ub.ot-line.fact-order >= fact-order-1 and
      ub.ot-line.obj-code    = obj-list.obj-code and
      ub.ot-line.obj-type    = obj-list.obj-type  and
      ( ub.ot-line.sum-type = {&arh-sale} or
        ub.ot-line.sum-type = {&arh-crsa} or
        ub.ot-line.sum-type = {&arh-cost} )
        no-lock ,
      first goods where
            goods.prod-type  = ub.ot-line.prod-type and
            goods.prod-code  = ub.ot-line.prod-code and
            goods.artic      = ub.ot-line.artic     and
            goods.gds-type   = {&gds-goods}
            no-lock ,
       first gds-list where  gds-list.prod-type  = ub.ot-line.prod-type and
                              gds-list.prod-code = ub.ot-line.prod-code and
                              gds-list.artic     = ub.ot-line.artic
        break
            &if "{1}" = "no-classify" &then
            by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
            by ub.ot-line.prod-type by ub.ot-line.prod-code by ub.ot-line.artic
            &endif
            &if "{1}" = "prod-code" &then
            by ub.ot-line.prod-type by ub.ot-line.prod-code by ub.ot-line.artic
            &endif
            &if "{1}" = "grp-goods" &then
            by goods.grp-name by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
            by ub.ot-line.artic
            &endif
            &if "{1}" = "VAT-pc" &then
            by  gds-list.qnty
            by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
            by ub.ot-line.artic
            &endif

            with frame zapas :
           n-nm = n-nm + 1.
          { rep/repfrm.i n-nm}
        if first-of(ub.ot-line.artic) then do:
            assign
              f-qnty         = 0
              f-cost-sum     = 0
              f-sale-sum     = 0
              f-sale-other   = 0
              f-crsa-sum     = 0
              f-qnty-all     = 0
              f-cost-sum-all = 0
              f-crsa-sum-all = 0
              f-qnty-o       = 0
              f-cost-sum-o   = 0
              f-crsa-sum-o   = 0.
            for each temp-doc-code  : delete temp-doc-code . end.
            for each temp-doc-code-all  : delete temp-doc-code-all . end.
        end.
        if can-find( first tdedt where  ub.ot-line.ext-doc-type = tdedt.id no-lock ) then do:
            case  ub.ot-line.sum-type :
                when {&arh-cost} then do:
                    f-cost-sum = f-cost-sum + ub.ot-line.sum-{5} .
                end.
                when {&arh-sale} then do:
                    f-sale-sum   = f-sale-sum   +  ub.ot-line.sum-{5} .
                    f-sale-other = f-sale-other + ub.ot-line.other-{5} .
                end.
                when  {&arh-crsa} then do:
                    f-crsa-sum = f-crsa-sum + ub.ot-line.sum-{5}  .
                    f-qnty     = f-qnty     + ub.ot-line.fact-qnty .
                    if itog = false then do:
                        create temp-doc-code .
                        assign
                            temp-doc-code.doc-code     = ub.ot-line.doc-code
                            temp-doc-code.ext-doc-type = ub.ot-line.ext-doc-type
                            temp-doc-code.si  = if  ub.ot-line.fact-qnty < 0 then -1 else 1
                            temp-doc-code.si2 = if  ub.ot-line.other-{5} < 0 then -1 else 1
                            .
                    end.
                end.
            end case.
          end.
            case  ub.ot-line.sum-type :
                when {&arh-cost} then do:
                  f-cost-sum-all = f-cost-sum-all + ub.ot-line.sum-{5} .
                end.
                when  {&arh-crsa} then do:
                  f-crsa-sum-all = f-crsa-sum-all + ub.ot-line.sum-{5}  .
                  f-qnty-all     = f-qnty-all     + ub.ot-line.fact-qnty .
                end.
            end case.

            create temp-doc-code-all .
            assign
                temp-doc-code-all.doc-code = ub.ot-line.doc-code
                temp-doc-code-all.ext-doc-type = ub.ot-line.ext-doc-type
                temp-doc-code-all.si  = if  ub.ot-line.fact-qnty < 0 then -1 else 1
                temp-doc-code-all.si2 = if  ub.ot-line.other-{5} < 0 then -1 else 1
                .

            &if "{1}" = "prod-code"  &then
/* По производителю----------- */
      if first-of(ub.ot-line.prod-code)  and classify = 2 then do:
          find first clients-p where  ub.ot-line.prod-type = clients-p.obj-type and
                                      ub.ot-line.prod-code = clients-p.obj-code no-lock no-error.
            if avail clients-p then var-client = clients-p.obj-name.
              if  itog = false then do:
                { rep/r-ob-cr.i disp   var-client   f-gds-name}
                display stream outstream .
                down stream outstream .
                {&putexcel} var-client {&new-line} .
              end.
      end.
/*----------------------------*/
&endif
&if "{1}" = "grp-goods" &then
/* По производителю----------- */
      if first-of(goods.grp-name) then  do:
          var-client = goods.grp-name.
              if  itog = false then do:
                put stream outstream  goods.grp-name  at 1 format "x(160)" skip.
                down stream outstream .
                {&putexcel} goods.grp-name {&new-line} .
              end.
      end.
/*----------------------------*/
&endif
&if "{1}" = "vat-pc" &then
      if first-of(gds-list.qnty) then do:
          var-client = string(gds-list.qnty) + '%'.
              if  itog = false then do:
                { rep/r-ob-cr.i disp   "'Ставка НДС ' + string(gds-list.qnty) + '%'"    f-gds-name}
                display stream outstream .
                down stream outstream .
                {&putexcel} 'Ставка НДС ' + string(gds-list.qnty) + '%' {&new-line} .
              end.
      end.
/*----------------------------*/
&endif
      if last-of(ub.ot-line.artic) then do:
          find first gds-obj where  ub.ot-line.prod-type = gds-obj.prod-type and
                                    ub.ot-line.prod-code = gds-obj.prod-code and
                                    ub.ot-line.artic     = gds-obj.artic and
                                    ub.ot-line.obj-code  = gds-obj.obj-code and
                                    ub.ot-line.obj-type  = gds-obj.obj-type
                                    no-lock no-error .
        if avail gds-obj then do:
          if v-var = "no-today" then do:
          /* На < сегодня */
            /* Продажная */
            run ost-line in this-procedure
            (input   gds-obj.obj-code  ,
            input   gds-obj.obj-type  ,
            input   gds-obj.artic     ,
            input   gds-obj.prod-code ,
            input   gds-obj.prod-type ,
            input   0                 ,
            input   fact-order-2      ,
            input   {&arh-crsa}       ,
            input   {&root-cat-id}    ,
            input   yes      ,
            output  quantity1   ,
            output  coast_r1  ,
            output  coast_v1  ,
            output  vat_r1    ,
            output  vat_v1    ,
            output  slt_r1    ,
            output  slt_v1     ).
          assign
            f-qnty-o       = quantity1
            f-crsa-sum-o   = if tprintrubl then coast_r1 else coast_v1
            .
            /* Учетная */
            run ost-line in this-procedure
            (input   gds-obj.obj-code  ,
            input   gds-obj.obj-type  ,
            input   gds-obj.artic     ,
            input   gds-obj.prod-code ,
            input   gds-obj.prod-type ,
            input   0                 ,
            input   fact-order-2      ,
            input   {&arh-cost}       ,
            input   {&root-cat-id}    ,
            input   yes      ,
            output  quantity1   ,
            output  coast_r1  ,
            output  coast_v1  ,
            output  vat_r1    ,
            output  vat_v1    ,
            output  slt_r1    ,
            output  slt_v1    ).
          assign
            f-cost-sum-o   = if tprintrubl then coast_r1 else coast_v1
            .

          end.
          else do:
            assign
              f-qnty-o     = gds-obj.fact-qnty
              f-cost-sum-o = gds-obj.fact-{5}
              f-crsa-sum-o = gds-obj.fact-sale .
          end.
        end.
          if itog = false and
            not(f-qnty        = 0 and
                f-qnty-o      = 0 and
                f-cost-sum    = 0 and
                f-sale-sum    = 0 and
                f-sale-other  = 0 and
                f-crsa-sum    = 0 and
                f-qnty-all    = 0 and
                f-cost-sum-all =0 and
                f-crsa-sum-all =0      )
            then  do:
                n-nn = n-nn + 1 .
                { gbl/gdsbcode.i goods.gds-code ? v-bar-code  }
                  run display-str-cr in this-procedure .
                  run display-prt in this-procedure  .
          end. /* if itog false */

&if "{1}" = "no-classify" &then
          accumulate f-qnty           (total ) .
          accumulate f-cost-sum       (total ) .
          accumulate f-sale-sum       (total ) .
          accumulate f-sale-other     (total ) .
          accumulate f-crsa-sum       (total ) .
          accumulate f-qnty-all       (total ) .
          accumulate f-cost-sum-all   (total ) .
          accumulate f-crsa-sum-all   (total ) .
          accumulate f-qnty-o         (total ) .
          accumulate f-cost-sum-o     (total ) .
          accumulate f-crsa-sum-o     (total ) .
&else
          accumulate f-qnty           (total  by {2} ) .
          accumulate f-cost-sum       (total  by {2} ) .
          accumulate f-sale-sum       (total  by {2} ) .
          accumulate f-sale-other     (total  by {2} ) .
          accumulate f-crsa-sum       (total  by {2} ) .
          accumulate f-qnty-all       (total  by {2} ) .
          accumulate f-cost-sum-all   (total  by {2} ) .
          accumulate f-crsa-sum-all   (total  by {2} ) .
          accumulate f-qnty-o         (total  by {2} ) .
          accumulate f-cost-sum-o     (total  by {2} ) .
          accumulate f-crsa-sum-o     (total  by {2} ) .
&endif

            assign
              f-qnty          = 0
              f-crsa-sum      = 0
              f-qnty          = 0
              f-cost-sum      = 0
              f-sale-sum      = 0
              f-sale-other    = 0
              f-crsa-sum      = 0
              f-qnty-all      = 0
              f-cost-sum-all  = 0
              f-crsa-sum-all  = 0
              f-qnty-o        = 0
              f-cost-sum-o    = 0
              f-crsa-sum-o    = 0
              .
      end. /* if last-of artic */

&if "{1}" <> "no-classify" &then

      if last-of({2})  then do :
        f-artic = {3} .
        { rep/r-ob-cr.i disp    "'Итого'"    nn }
        { rep/r-ob-cr.i disp    f-artic         f-artic }
        { rep/r-ob-cr.i disp    var-client   f-gds-name  }
        { rep/r-ob-cr.i disp    "accum total by "{2}" f-qnty    "         f-qnty        }
        { rep/r-ob-cr.i disp    "accum total by {2} f-cost-sum "        f-cost-sum    }
        { rep/r-ob-cr.i disp    "accum total  by {2}  f-sale-sum"         f-sale-sum    }
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-sale-other"       f-sale-other  }
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-crsa-sum"         f-crsa-sum    }
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-qnty-all"         f-qnty-all    }
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-cost-sum-all"     f-cost-sum-all}
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-crsa-sum-all"     f-crsa-sum-all}
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-qnty-o"           f-qnty-o      }
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-cost-sum-o"       f-cost-sum-o  }
        { rep/r-ob-cr.i disp    "accum total by  {2}  f-crsa-sum-o"       f-crsa-sum-o  }

          display stream outstream  no-error .
          down stream outstream .
          {&putexcel}
          "Итого"                                              {&tabulation}
          {3}                                                   {&tabulation}
          var-client                                           {&tabulation} {&tabulation}
          excel-qnty(accum total by {2}  f-qnty           )    {&tabulation}
          excel-sum (accum total by {2}  f-cost-sum       )   {&tabulation}
          excel-sum (accum total by {2}  f-sale-sum       )   {&tabulation}
          excel-sum (accum total by {2}  f-sale-other     )   {&tabulation}
          excel-sum (accum total by {2}  f-crsa-sum       )   {&tabulation}
          excel-sum (accum total by {2}  f-qnty-all       )   {&tabulation}
          excel-sum (accum total by {2}  f-cost-sum-all   )   {&tabulation}
          excel-sum (accum total by {2}  f-crsa-sum-all   )   {&tabulation}
          excel-sum (accum total by {2}  f-qnty-o         )   {&tabulation}
          excel-sum (accum total by {2}  f-cost-sum-o     )   {&tabulation}
          excel-sum (accum total by {2}  f-crsa-sum-o     )   {&new-line} .
      end.  /*if last prod-code */

&endif

end. /*for each ub.ot-line */
run u-line.
{ rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
{ rep/r-ob-cr.i disp   "'по объекту'"                   f-b-code       }
{ rep/r-ob-cr.i disp   "obj-list.obj-name"              f-gds-name     }
{ rep/r-ob-cr.i disp   "accum total f-qnty"             f-qnty         }
{ rep/r-ob-cr.i disp   "accum total f-cost-sum"         f-cost-sum     }
{ rep/r-ob-cr.i disp   "accum total f-sale-sum"         f-sale-sum     }
{ rep/r-ob-cr.i disp   "accum total f-sale-other"       f-sale-other   }
{ rep/r-ob-cr.i disp   "accum total f-crsa-sum"         f-crsa-sum     }
{ rep/r-ob-cr.i disp   "accum total f-qnty-all"         f-qnty-all     }
{ rep/r-ob-cr.i disp   "accum total f-cost-sum-all"     f-cost-sum-all }
{ rep/r-ob-cr.i disp   "accum total f-crsa-sum-all"     f-crsa-sum-all }
{ rep/r-ob-cr.i disp   "accum total f-qnty-o"           f-qnty-o       }
{ rep/r-ob-cr.i disp   "accum total f-cost-sum-o"       f-cost-sum-o   }
{ rep/r-ob-cr.i disp   "accum total f-crsa-sum-o"       f-crsa-sum-o   }
display stream outstream no-error.
down stream outstream .
run u-line.
{&putexcel}
      "ИТОГО"                         {&tabulation}
      "по объекту"                    {&tabulation}  {&tabulation}
      obj-list.obj-name               {&tabulation}
      excel-qnty(accum total f-qnty           )  {&tabulation}
      excel-sum (accum total f-cost-sum       )  {&tabulation}
      excel-sum (accum total f-sale-sum       )  {&tabulation}
      excel-sum (accum total f-sale-other    )   {&tabulation}
      excel-sum (accum total f-crsa-sum      )   {&tabulation}
      excel-sum (accum total f-qnty-all      )   {&tabulation}
      excel-sum (accum total f-cost-sum-all  )   {&tabulation}
      excel-sum (accum total f-crsa-sum-all  )   {&tabulation}
      excel-sum (accum total f-qnty-o        )   {&tabulation}
      excel-sum (accum total f-cost-sum-o    )   {&tabulation}
      excel-sum (accum total f-crsa-sum-o    )   {&new-line} .

end.  /*for each obj-list*/
if n-no > 1 then do:
    { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
    { rep/r-ob-cr.i disp   "'ПО ВСЕМ ОБЬЕКТАМ'"             f-artic        }
    { rep/r-ob-cr.i disp   "accum total f-qnty"             f-qnty         }
    { rep/r-ob-cr.i disp   "accum total f-cost-sum"         f-cost-sum     }
    { rep/r-ob-cr.i disp   "accum total f-sale-sum"         f-sale-sum     }
    { rep/r-ob-cr.i disp   "accum total f-sale-other"       f-sale-other   }
    { rep/r-ob-cr.i disp   "accum total f-crsa-sum"         f-crsa-sum     }
    { rep/r-ob-cr.i disp   "accum total f-qnty-all"         f-qnty-all     }
    { rep/r-ob-cr.i disp   "accum total f-cost-sum-all"     f-cost-sum-all  }
    { rep/r-ob-cr.i disp   "accum total f-crsa-sum-all"     f-crsa-sum-all  }
    { rep/r-ob-cr.i disp   "accum total f-qnty-o"           f-qnty-o        }
    { rep/r-ob-cr.i disp   "accum total f-cost-sum-o"       f-cost-sum-o    }
    { rep/r-ob-cr.i disp   "accum total f-crsa-sum-o"       f-crsa-sum-o    }

    display stream outstream with frame zapas no-error .
    down stream outstream with frame zapas.
  run u-line.
      {&putexcel}
      "ИТОГО"                       {&tabulation}
      "ПО ВСЕМ ОБЬЕКТАМ"            {&tabulation}     {&tabulation}
      excel-qnty(accum total f-qnty           )   {&tabulation}
      excel-sum (accum total f-cost-sum       )   {&tabulation}
      excel-sum (accum total f-sale-sum       )   {&tabulation}
      excel-sum (accum total f-sale-other     )   {&tabulation}
      excel-sum (accum total f-crsa-sum       )   {&tabulation}
      excel-sum (accum total f-qnty-all       )   {&tabulation}
      excel-sum (accum total f-cost-sum-all   )   {&tabulation}
      excel-sum (accum total f-crsa-sum-all   )   {&tabulation}
      excel-sum (accum total f-qnty-o         )   {&tabulation}
      excel-sum (accum total f-cost-sum-o     )   {&tabulation}
      excel-sum (accum total f-crsa-sum-o     )   {&new-line} .
end. /* do */
&else
/* procedure display-prt */
/* а есть ли у него шкала ? */

if goods.prt-root <> Prtroot Then DO:
/* На любое время */
If v-var = "no-today"  then
run prdoclib-init-prt-obj-by-factord in this-procedure
( input gds-obj.obj-type  ,
input gds-obj.obj-code  ,
input gds-obj.artic     ,
input gds-obj.prod-type ,
input gds-obj.prod-code ,
input fact-order-2 ,
input false ) .

for each ub.prt-obj where
  ub.prt-obj.artic     = goods.artic         and
  ub.prt-obj.prod-type = goods.prod-type and
  ub.prt-obj.prod-code = goods.prod-code and
  ub.prt-obj.obj-code  = obj-list.obj-code   and
  ub.prt-obj.obj-type  = obj-list.obj-type   and
  ub.prt-obj.IS-term   =  true no-lock
        BREAK BY ub.prt-obj.prt-code with FRAME Zapas:
              if v-var <> "no-today" then do:
                Assign
                  p-qnty-o     = p-qnty-o     + ub.prt-obj.fact-qnty
                  p-crsa-sum-o = p-crsa-sum-o + ub.prt-obj.fact-qnty * ub.prt-obj.price-sale .
              End.

IF last-of(prt-obj.prt-code) THEN DO:
    { gbl/gdsbcode.i gds-obj.gds-code ub.prt-obj.prt-code v-bar-code  }
          if v-var = "no-today" then do:
            find first temp-prt-obj no-lock
                  where temp-prt-obj.prt-obj-recid   = recid (prt-obj) no-error .
                  if avail temp-prt-obj then do :
                    run calc-price-sale-for-prt in this-procedure  (output v-price-sale) .
                    Assign
                      p-qnty-o      = temp-prt-obj.fact-qnty
                      p-crsa-sum-o  = temp-prt-obj.fact-qnty * v-price-sale      .
                  End.
                  Else
                    Assign
                      p-qnty-o      = 0
                      p-crsa-sum-o  = 0   .

          End.

    FIND first ub.gds-prt  where ub.gds-prt.node-code = ub.prt-obj.prt-code NO-LOCK no-error .

    /* обороты */
    for each ub.gds-dtl no-lock where
        ub.gds-dtl.artic      = goods.artic     and
        ub.gds-dtl.prod-code  = goods.prod-code and
        ub.gds-dtl.prod-type  = goods.prod-type and
        ub.gds-dtl.prt-code   = ub.prt-obj.prt-code  and
        ub.gds-dtl.obj-code   = obj-list.obj-code  and
        ub.gds-dtl.obj-type   = obj-list.obj-type :
          /* выборочный оборот */
            find first temp-doc-code where temp-doc-code.doc-code = ub.gds-dtl.doc-code no-lock no-error .
              if avail temp-doc-code then DO:

              Assign
                  t-qnty = if temp-doc-code.ext-doc-type = {&TDEDT_Inv}
                              then ub.gds-dtl.doc-qnty
                              else ( ub.gds-dtl.fact-qnty * temp-doc-code.si )

                  p-qnty       = p-qnty       + t-qnty
                  p-sale-sum   = p-sale-sum   + (gds-dtl.price-{5} * t-qnty)
                  p-sale-other = p-sale-other + (gds-dtl.discnt-{5} * temp-doc-code.si2)
                  p-crsa-sum   = p-crsa-sum   + (gds-dtl.cur-base * t-qnty)
                  .

            End.
            find first temp-doc-code-all where temp-doc-code-all.doc-code = ub.gds-dtl.doc-code no-lock no-error .
              if avail temp-doc-code-all then DO:
                  Assign
                  t-qnty-all = if temp-doc-code-all.ext-doc-type = {&TDEDT_Inv}
                                    then ub.gds-dtl.doc-qnty
                                    else ( ub.gds-dtl.fact-qnty * temp-doc-code-all.si )

                    p-qnty-all       = p-qnty-all  + t-qnty-all
                    p-crsa-sum-all   = p-crsa-sum-all   + (gds-dtl.cur-base * t-qnty-all ).
              End.
    end. /* for each ub.gds-dtl */
    if f-qnty <> ? and f-qnty <> 0 then
        Assign
          p-cost-sum     = f-cost-sum      * p-qnty     / f-qnty
        .
    else
        Assign
            p-cost-sum     = 0
        .
    if f-qnty-all <> ? and f-qnty-all <> 0 then
        Assign
          p-cost-sum-all = f-cost-sum-all  * p-qnty-all / f-qnty-all
        .
    else
        Assign
            p-cost-sum-all = 0
          .
    if f-qnty-o <> ? and f-qnty-o <> 0 then
        Assign
          p-cost-sum-o   = f-cost-sum-o    * p-qnty-o   / f-qnty-o
        .
    else
        Assign
            p-cost-sum-o   = 0
        .

    if  NOT(p-qnty      =  0 and
          p-cost-sum    =  0     and
          p-sale-sum    =  0     and
          p-sale-other  =  0     and
          p-crsa-sum    =  0     and
          p-qnty-all    =  0     and
          p-cost-sum-all = 0     and
          p-crsa-sum-all=  0    ) then dO:


        { rep/r-ob-cr.i disp  "''"                                 nn         }
        { rep/r-ob-cr.i disp  "''"                                 f-artic    }
        { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'")     f-b-code   }
        { rep/r-ob-cr.i disp  ub.gds-prt.f-name                     f-gds-name }
        { rep/r-ob-cr.i disp  p-qnty             f-qnty       }
        { rep/r-ob-cr.i disp  p-cost-sum         f-cost-sum   }
        { rep/r-ob-cr.i disp  p-sale-sum         f-sale-sum   }
        { rep/r-ob-cr.i disp  p-sale-other       f-sale-other }
        { rep/r-ob-cr.i disp  p-crsa-sum         f-crsa-sum   }
        { rep/r-ob-cr.i disp  p-qnty-all         f-qnty-all    }
        { rep/r-ob-cr.i disp  p-cost-sum-all     f-cost-sum-all}
        { rep/r-ob-cr.i disp  p-crsa-sum-all     f-crsa-sum-all}
        { rep/r-ob-cr.i disp  p-qnty-o           f-qnty-o      }
        { rep/r-ob-cr.i disp  p-cost-sum-o       f-cost-sum-o  }
        { rep/r-ob-cr.i disp  p-crsa-sum-o       f-crsa-sum-o  }
        Display stream OutStream no-error.
        DOWN stream OutStream .
    {&PutExcel}
          " "                             {&tabulation}
          " "                             {&tabulation}
          format-excel-text(string(v-bar-code,"999999999"))  {&tabulation}
          ub.gds-prt.f-name                 {&tabulation}
          round(p-qnty,3)                {&tabulation}
          round(p-cost-sum,2)            {&tabulation}
          round(p-sale-sum,2)            {&tabulation}
          round(p-sale-other,2)          {&tabulation}
          round(p-crsa-sum,2)            {&tabulation}
          round(p-qnty-all,3)            {&tabulation}
          round(p-cost-sum-all,2)        {&tabulation}
          round(p-crsa-sum-all,2)        {&tabulation}
          round(p-qnty-o,3)              {&tabulation}
          round(p-cost-sum-o,2)          {&tabulation}
          round(p-crsa-sum-o,2)          {&new-line} .

    End.
    Assign
      p-qnty        =  0
      p-cost-sum    =  0
      p-sale-sum    =  0
      p-sale-other  =  0
      p-crsa-sum    =  0
      p-qnty-all    =  0
      p-cost-sum-all = 0
      p-crsa-sum-all=  0
      p-qnty-o      =  0
      p-cost-sum-o  =  0
      p-crsa-sum-o  =  0 .
End.
End.
End.
&endif
/* $Workfile$ e n d */