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
  for each obj-list no-lock with FRAME Zapas :
    if NOT( classify = 1 and Itog = true) then dO:
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

  Display stream OutStream no-error .
  DOWN stream OutStream .
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
   {&PutExcel}  obj-list.obj-name {&new-line}.
  end.
          n-nn = 0.
          n-no = n-no + 1 .

      for each tt-season no-lock with FRAME Zapas:
          if not ("{1}" = "no-classify" and itog = true ) then do:
              put stream outstream tt-season.sea-name  at 1 format "x(160)" skip.  down stream outstream .
              {&putexcel} tt-season.sea-name {&new-line} .
          end.

              for each ub.gds-season no-lock where
                       ub.gds-season.sea-code = tt-season.sea-code and
                       ub.gds-season.db-num   = tt-season.db-num
                       ,
                  each goods no-lock where
                       goods.gds-code    = ub.gds-season.gds-code and
                       goods.gds-type   = {&gds-goods} ,
                  Each ub.ot-line where
                          ub.ot-line.fact-order <= fact-order-2 and
                          ub.ot-line.fact-order >= fact-order-1 and
                          ub.ot-line.obj-code    = obj-list.obj-code and
                          ub.ot-line.obj-type    = obj-list.obj-type  and
                          ub.ot-line.prod-type   = goods.prod-type and
                          ub.ot-line.prod-code   = goods.prod-code and
                          ub.ot-line.artic       = goods.artic  and
                          (ub.ot-line.sum-type   = {&arh-sale} OR
                            ub.ot-line.sum-type  = {&arh-crsa} OR
                            ub.ot-line.sum-type  = {&arh-cost} )

                &if '{6}' = 'gds-list'  &then ,
                  each gds-list where
                      gds-list.gds-code = ub.gds-season.gds-code
                  &Endif
                      break
                          &if "{1}" = "no-classify" &then
                          by (ub.gds-season.gds-code ) by goods.grp-name
                          &endif
                          &if "{1}" = "grp-goods" &then
                          by goods.grp-name by (ub.gds-season.gds-code)
                          &endif
                          with FRAME Zapas :


             n-nm = n-nm + 1.
             { rep/repfrm.i n-nm}
            IF first-of(ub.gds-season.gds-code) then DO:
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
               For Each temp-doc-code  : delete temp-doc-code . end.
               For Each temp-doc-code-all  : delete temp-doc-code-all . end.
            End.
            if can-find( first tdedt where  ub.ot-line.ext-doc-type = tdedt.id no-lock ) then DO:
                Case  ub.ot-line.sum-type :
                    When {&arh-cost} then do:
                        f-cost-sum = f-cost-sum + ub.ot-line.sum-{5} .
                    End.
                    When {&arh-sale} then do:
                        f-sale-sum   = f-sale-sum   +  ub.ot-line.sum-{5} .
                        f-sale-other = f-sale-other + ub.ot-line.other-{5} .
                    End.
                    When  {&arh-crsa} then do:
                        f-crsa-sum = f-crsa-sum + ub.ot-line.sum-{5}  .
                        f-qnty     = f-qnty     + ub.ot-line.fact-qnty .
                        IF itog = false then do:
                            Create temp-doc-code .
                            Assign
                               temp-doc-code.doc-code = ub.ot-line.doc-code
                               temp-doc-code.ext-doc-type = ub.ot-line.ext-doc-type
                               temp-doc-code.si  = if  ub.ot-line.fact-qnty < 0 then -1 else 1
                               temp-doc-code.si2 = if  ub.ot-line.other-{5} < 0 then -1 else 1
                               .
                        End.
                    End.
                End case.
              End.
                Case  ub.ot-line.sum-type :
                    when {&arh-cost} then do:
                      f-cost-sum-all = f-cost-sum-all + ub.ot-line.sum-{5} .
                    end.
                    when  {&arh-crsa} then do:
                      f-crsa-sum-all = f-crsa-sum-all + ub.ot-line.sum-{5}  .
                      f-qnty-all     = f-qnty-all     + ub.ot-line.fact-qnty .
                    end.
                End case.

                Create temp-doc-code-all .
                Assign
                    temp-doc-code-all.doc-code = ub.ot-line.doc-code
                    temp-doc-code-all.ext-doc-type = ub.ot-line.ext-doc-type
                    temp-doc-code-all.si  = if  ub.ot-line.fact-qnty < 0 then -1 else 1
                    temp-doc-code-all.si2 = if  ub.ot-line.other-{5} < 0 then -1 else 1
                    .

&if "{1}" = "grp-goods" &then
          if first-of(goods.grp-name) then  DO:
             var-client = goods.grp-name.
                  if  Itog = false Then do:
                    PUT stream OutStream  goods.grp-name  AT 1 format "X(160)" SKIP.
                    DOWN stream OutStream .
                    {&PutExcel} goods.grp-name {&new-line} .
                  End.
          End.
&endif

          if last-of(ub.gds-season.gds-code) then DO:
             Find first gds-obj where  ub.ot-line.prod-type = gds-obj.prod-type and
                                       ub.ot-line.prod-code = gds-obj.prod-code and
                                       ub.ot-line.artic     = gds-obj.artic and
                                       ub.ot-line.obj-code  = gds-obj.obj-code and
                                       ub.ot-line.obj-type  = gds-obj.obj-type
                                       no-lock no-error .
           if avail gds-obj then do:
             if v-var = "no-today" then do:
             /* На < сегодня */
               /* Продажная */
               RUN ost-line in this-procedure
               (input   gds-obj.obj-code  ,
                input   gds-obj.obj-type  ,
                INPUT   gds-obj.artic     ,
                INPUT   gds-obj.prod-code ,
                INPUT   gds-obj.prod-type ,
                input   0                 ,
                INPUT   fact-order-2      ,
                input   {&arh-crsa}       ,
                input   {&root-cat-id}    ,
                input   yes      ,
                output  Quantity1   ,
                output  Coast_R1  ,
                output  Coast_V1  ,
                output  VAT_R1    ,
                output  VAT_V1    ,
                output  SLT_R1    ,
                output  SLT_V1     ).
             Assign
                f-qnty-o       = Quantity1
                f-crsa-sum-o   = if tprintrubl then Coast_R1 else Coast_V1
                .
               /* Учетная */
               RUN ost-line in this-procedure
               (input   gds-obj.obj-code  ,
                input   gds-obj.obj-type  ,
                INPUT   gds-obj.artic     ,
                INPUT   gds-obj.prod-code ,
                INPUT   gds-obj.prod-type ,
                input   0                 ,
                INPUT   fact-order-2      ,
                input   {&arh-cost}       ,
                input   {&root-cat-id}    ,
                input   yes      ,
                output  Quantity1   ,
                output  Coast_R1  ,
                output  Coast_V1  ,
                output  VAT_R1    ,
                output  VAT_V1    ,
                output  SLT_R1    ,
                output  SLT_V1    ).
             Assign
                f-cost-sum-o   = if tprintrubl then Coast_R1 else Coast_V1
                .

             End.
             Else do:
               Assign
                 f-qnty-o     = gds-obj.fact-qnty
                 f-cost-sum-o = gds-obj.fact-{5}
                 f-crsa-sum-o = gds-obj.fact-sale .
             End.
           End.
             if itog = false and
                not(f-qnty        = 0 and
                    f-cost-sum    = 0 and
                    f-sale-sum    = 0 and
                    f-sale-other  = 0 and
                    f-crsa-sum    = 0 and
                    f-qnty-all    = 0 and
                    f-cost-sum-all =0 and
                    f-crsa-sum-all =0      )
                Then  DO:
                    n-nn = n-nn + 1 .
                    { gbl/gdsbcode.i goods.gds-code ? v-bar-code  }
                     run display-str-cr in this-procedure .
                     Run Display-prt in this-procedure  .
             End. /* if itog false */

 &if "{1}" = "no-classify" &then
              accumulate f-qnty           (TOTAL ) .
              accumulate f-cost-sum       (TOTAL ) .
              accumulate f-sale-sum       (TOTAL ) .
              accumulate f-sale-other     (TOTAL ) .
              accumulate f-crsa-sum       (TOTAL ) .
              accumulate f-qnty-all       (TOTAL ) .
              accumulate f-cost-sum-all   (TOTAL ) .
              accumulate f-crsa-sum-all   (TOTAL ) .
              accumulate f-qnty-o         (TOTAL ) .
              accumulate f-cost-sum-o     (TOTAL ) .
              accumulate f-crsa-sum-o     (TOTAL ) .
&Else
              accumulate f-qnty           (TOTAL  by {2} ) .
              accumulate f-cost-sum       (TOTAL  by {2} ) .
              accumulate f-sale-sum       (TOTAL  by {2} ) .
              accumulate f-sale-other     (TOTAL  by {2} ) .
              accumulate f-crsa-sum       (TOTAL  by {2} ) .
              accumulate f-qnty-all       (TOTAL  by {2} ) .
              accumulate f-cost-sum-all   (TOTAL  by {2} ) .
              accumulate f-crsa-sum-all   (TOTAL  by {2} ) .
              accumulate f-qnty-o         (TOTAL  by {2} ) .
              accumulate f-cost-sum-o     (TOTAL  by {2} ) .
              accumulate f-crsa-sum-o     (TOTAL  by {2} ) .
&endif

                Assign
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
          End. /* if last-of artic */

&if "{1}" <> "no-classify" &then

          if last-of({2})  then do :
            f-artic = {3} .
            { rep/r-ob-cr.i disp    "'Итого'"    nn }
            { rep/r-ob-cr.i disp    f-artic         f-artic }
            { rep/r-ob-cr.i disp    var-client   f-gds-name  }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2} f-qnty    "         f-qnty        }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2} f-cost-sum "        f-cost-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-sale-sum"         f-sale-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-sale-other"       f-sale-other  }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-crsa-sum"         f-crsa-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-qnty-all"         f-qnty-all    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-cost-sum-all"     f-cost-sum-all}
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-crsa-sum-all"     f-crsa-sum-all}
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-qnty-o"           f-qnty-o      }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-cost-sum-o"       f-cost-sum-o  }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-crsa-sum-o"       f-crsa-sum-o  }

              Display stream OutStream  no-error .
              DOWN stream OutStream .
              {&PutExcel}
              "Итого"                                              {&tabulation}
              {3}                                                   {&tabulation}
              var-client                                           {&tabulation} {&tabulation}
              excel-qnty(accum TOTAL by {2}  f-qnty           )    {&tabulation}
              excel-sum (accum TOTAL by {2}  f-cost-sum       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-sum       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-other     )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-crsa-sum       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-qnty-all       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-cost-sum-all   )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-crsa-sum-all   )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-qnty-o         )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-cost-sum-o     )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-crsa-sum-o     )   {&new-line} .
          End.  /*if last prod-code */

&endif
 end.  /*for each ub.ot-line */
 run u-line.
  { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
  { rep/r-ob-cr.i disp   "'коллекция'"                   f-b-code       }
  { rep/r-ob-cr.i disp   "tt-season.sea-name"              f-gds-name     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum"         f-crsa-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-all"         f-qnty-all     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-all"     f-cost-sum-all }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum-all"     f-crsa-sum-all }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-o"           f-qnty-o       }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-o"       f-cost-sum-o   }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum-o"       f-crsa-sum-o   }
  Display stream OutStream no-error.
  DOWN stream OutStream .
  run u-line.
  {&PutExcel}
    "ИТОГО"                         {&tabulation}
    "коллекци "                    {&tabulation}  {&tabulation}
    tt-season.sea-name               {&tabulation}
    excel-qnty(accum TOTAL f-qnty           )  {&tabulation}
    excel-sum (accum TOTAL f-cost-sum       )  {&tabulation}
    excel-sum (accum TOTAL f-sale-sum       )  {&tabulation}
    excel-sum (accum TOTAL f-sale-other    )   {&tabulation}
    excel-sum (accum TOTAL f-crsa-sum      )   {&tabulation}
    excel-sum (accum TOTAL f-qnty-all      )   {&tabulation}
    excel-sum (accum TOTAL f-cost-sum-all  )   {&tabulation}
    excel-sum (accum TOTAL f-crsa-sum-all  )   {&tabulation}
    excel-sum (accum TOTAL f-qnty-o        )   {&tabulation}
    excel-sum (accum TOTAL f-cost-sum-o    )   {&tabulation}
    excel-sum (accum TOTAL f-crsa-sum-o    )   {&new-line} .

 End. /* for each season */
 run u-line.
  { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
  { rep/r-ob-cr.i disp   "'по объекту'"                   f-b-code       }
  { rep/r-ob-cr.i disp   "obj-list.obj-name"              f-gds-name     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum"         f-crsa-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-all"         f-qnty-all     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-all"     f-cost-sum-all }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum-all"     f-crsa-sum-all }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-o"           f-qnty-o       }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-o"       f-cost-sum-o   }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum-o"       f-crsa-sum-o   }
  Display stream OutStream no-error.
  DOWN stream OutStream .
  run u-line.
  {&PutExcel}
    "ИТОГО"                         {&tabulation}
    "по объекту"                    {&tabulation}  {&tabulation}
    obj-list.obj-name               {&tabulation}
    excel-qnty(accum TOTAL f-qnty           )  {&tabulation}
    excel-sum (accum TOTAL f-cost-sum       )  {&tabulation}
    excel-sum (accum TOTAL f-sale-sum       )  {&tabulation}
    excel-sum (accum TOTAL f-sale-other    )   {&tabulation}
    excel-sum (accum TOTAL f-crsa-sum      )   {&tabulation}
    excel-sum (accum TOTAL f-qnty-all      )   {&tabulation}
    excel-sum (accum TOTAL f-cost-sum-all  )   {&tabulation}
    excel-sum (accum TOTAL f-crsa-sum-all  )   {&tabulation}
    excel-sum (accum TOTAL f-qnty-o        )   {&tabulation}
    excel-sum (accum TOTAL f-cost-sum-o    )   {&tabulation}
    excel-sum (accum TOTAL f-crsa-sum-o    )   {&new-line} .

End.  /*for each obj-list*/
   if n-no > 1 then do:
        { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
        { rep/r-ob-cr.i disp   "'ПО ВСЕМ ОБЬЕКТАМ'"             f-artic        }
        { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
        { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
        { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum"         f-crsa-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-all"         f-qnty-all     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-all"     f-cost-sum-all  }
        { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum-all"     f-crsa-sum-all  }
        { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-o"           f-qnty-o        }
        { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-o"       f-cost-sum-o    }
        { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum-o"       f-crsa-sum-o    }

        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line.
         {&PutExcel}
         "ИТОГО"                       {&tabulation}
         "ПО ВСЕМ ОБЬЕКТАМ"            {&tabulation}     {&tabulation}
         excel-qnty(accum TOTAL f-qnty           )   {&tabulation}
         excel-sum (accum TOTAL f-cost-sum       )   {&tabulation}
         excel-sum (accum TOTAL f-sale-sum       )   {&tabulation}
         excel-sum (accum TOTAL f-sale-other     )   {&tabulation}
         excel-sum (accum TOTAL f-crsa-sum       )   {&tabulation}
         excel-sum (accum TOTAL f-qnty-all       )   {&tabulation}
         excel-sum (accum TOTAL f-cost-sum-all   )   {&tabulation}
         excel-sum (accum TOTAL f-crsa-sum-all   )   {&tabulation}
         excel-sum (accum TOTAL f-qnty-o         )   {&tabulation}
         excel-sum (accum TOTAL f-cost-sum-o     )   {&tabulation}
         excel-sum (accum TOTAL f-crsa-sum-o     )   {&new-line} .
    End. /* do */
&else
/* Procedure Display-prt */
/* а есть ли у него шкала ? */

if goods.prt-root <> Prtroot Then DO:
/* На любое время */
If v-var = "no-today"  then
run  prdoclib-init-prt-obj-by-factord in this-procedure
( input gds-obj.obj-type  ,
  input gds-obj.obj-code  ,
  input gds-obj.artic     ,
  input gds-obj.prod-type ,
  input gds-obj.prod-code ,
  input fact-order-2 ,
  input false ) .

  for each prt-obj where
      prt-obj.artic     = goods.artic         and
      prt-obj.prod-type = goods.prod-type and
      prt-obj.prod-code = goods.prod-code and
      prt-obj.obj-code  = obj-list.obj-code   and
      prt-obj.obj-type  = obj-list.obj-type   and
      prt-obj.IS-term   =  true no-lock
            BREAK BY prt-obj.prt-code with FRAME Zapas:
                  if v-var <> "no-today" then do:
                    Assign
                      p-qnty-o     = p-qnty-o     + prt-obj.fact-qnty
                      p-crsa-sum-o = p-crsa-sum-o + prt-obj.fact-qnty * prt-obj.price-sale .
                  End.

    IF last-of(prt-obj.prt-code) THEN DO:
        { gbl/gdsbcode.i gds-obj.gds-code prt-obj.prt-code v-bar-code  }
              if v-var = "no-today" then do:
                find first temp-prt-obj no-lock
                     where temp-prt-obj.prt-obj-recid   = recid (prt-obj) no-error .
                     if avail temp-prt-obj then do :
                       run  calc-price-sale-for-prt in this-procedure  (output v-price-sale) .
                        Assign
                          p-qnty-o      = temp-prt-obj.fact-qnty
                          p-crsa-sum-o  = temp-prt-obj.fact-qnty * v-price-sale      .
                      End.
                      Else
                        Assign
                          p-qnty-o      = 0
                          p-crsa-sum-o  = 0   .

              End.

        FIND first gds-prt  where gds-prt.node-code = prt-obj.prt-code NO-LOCK no-error .

        /* обороты */
        for each gds-dtl no-lock where
            gds-dtl.artic      = goods.artic     and
            gds-dtl.prod-code  = goods.prod-code and
            gds-dtl.prod-type  = goods.prod-type and
            gds-dtl.prt-code   = prt-obj.prt-code  and
            gds-dtl.obj-code   = obj-list.obj-code  and
            gds-dtl.obj-type   = obj-list.obj-type :
              /* выборочный оборот */
                find first temp-doc-code where temp-doc-code.doc-code = gds-dtl.doc-code no-lock no-error .
                 if avail temp-doc-code then DO:
                  Assign
                      t-qnty = if temp-doc-code.ext-doc-type = {&TDEDT_Inv}
                                  then gds-dtl.doc-qnty
                                  else ( gds-dtl.fact-qnty * temp-doc-code.si )

                      p-qnty       = p-qnty       + t-qnty
                      p-sale-sum   = p-sale-sum   + (gds-dtl.price-{5} * t-qnty)
                      p-sale-other = p-sale-other + (gds-dtl.discnt-{5} * temp-doc-code.si2)
                      p-crsa-sum   = p-crsa-sum   + (gds-dtl.cur-base * t-qnty)
                      .


                End.
                find first temp-doc-code-all where temp-doc-code-all.doc-code = gds-dtl.doc-code no-lock no-error .
                 if avail temp-doc-code-all then DO:
                      Assign
                      t-qnty-all = if temp-doc-code-all.ext-doc-type = {&TDEDT_Inv}
                                        then gds-dtl.doc-qnty
                                        else ( gds-dtl.fact-qnty * temp-doc-code-all.si )

                        p-qnty-all       = p-qnty-all  + t-qnty-all
                        p-crsa-sum-all   = p-crsa-sum-all   + (gds-dtl.cur-base * t-qnty-all ).

                  End.
        end. /* for each gds-dtl */
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
            { rep/r-ob-cr.i disp  gds-prt.f-name                     f-gds-name }
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
             gds-prt.f-name                 {&tabulation}
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