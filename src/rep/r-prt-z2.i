/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вызов отчета

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
              { rep/r-ob-cr.i full  "''"   f-cost-pr      }
              { rep/r-ob-cr.i full  "''"   f-cost-sum     }
              { rep/r-ob-cr.i full  "''"   f-sale-pr      }
              { rep/r-ob-cr.i full  "''"   f-sale-sum     }
              { rep/r-ob-cr.i full  "''"   f-sale-other   }
              { rep/r-ob-cr.i full  "''"   f-free-qnty    }
              { rep/r-ob-cr.i full  "''"   f-wait-qnty    }

              Display stream OutStream no-error .
              DOWN stream OutStream .
              { rep/r-ob-cr.i sfull f-qnty           }
              { rep/r-ob-cr.i sfull f-cost-pr        }
              { rep/r-ob-cr.i sfull f-cost-sum       }
              { rep/r-ob-cr.i sfull f-sale-pr        }
              { rep/r-ob-cr.i sfull f-sale-sum       }
              { rep/r-ob-cr.i sfull f-sale-other     }
              { rep/r-ob-cr.i sfull f-free-qnty      }
              { rep/r-ob-cr.i sfull f-wait-qnty      }
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
                       ub.gds-season.db-num   = tt-season.db-num  and
                       ub.gds-season.sea-code = tt-season.sea-code ,
                  each ub.gds-obj no-lock where
                       ub.gds-obj.gds-code    = ub.gds-season.gds-code and
                       ub.gds-obj.obj-code    = obj-list.obj-code and
                       ub.gds-obj.obj-type    = obj-list.obj-type ,
                  each ub.goods no-lock where
                       ub.goods.gds-code    = ub.gds-season.gds-code and
                       ub.goods.gds-type   = {&gds-goods}
                &if '{6}' = 'gds-list'  &then ,
                  each gds-list where
                      gds-list.gds-code = ub.gds-season.gds-code
                  &Endif
                                  break
                                      &if "{1}" = "no-classify" &then
                                      by (ub.gds-season.gds-code ) by ub.goods.grp-name
                                      &endif
                                      &if "{1}" = "grp-goods" &then
                                      by ub.goods.grp-name by (ub.gds-season.gds-code)
                                      &endif
                                      with FRAME Zapas :

                                    n-nm = n-nm + 1.
                                  { rep/repfrm.i disp n-nm }
                                    IF first-of(ub.gds-season.gds-code) then DO:
                                      assign
                                        f-qnty         = 0
                                        f-cost-sum     = 0
                                        f-sale-sum     = 0
                                        f-sale-other   = 0
                                        f-free-qnty    = 0
                                        f-wait-qnty    = 0
                                        .
                                    End.

                      &if "{1}" = "grp-goods" &then
                                if first-of(ub.goods.grp-name) then  DO:
                                  var-client = ub.goods.grp-name.
                                        if  Itog = false Then do:
                                          PUT stream OutStream  ub.goods.grp-name  AT 1 format "X(160)" SKIP. DOWN stream OutStream .
                                          {&PutExcel} ub.goods.grp-name {&new-line} .
                                        End.
                                End.
                      /*----------------------------*/
                      &endif

                      if last-of(ub.gds-season.gds-code) then DO:
                        /* По товару ------------------------*/
                                        IF v-var = "no-today" then DO:
                                                    /* На < сегодня */
                                                      /* Продажная */
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
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
                                                        f-qnty       = Quantity1
                                                        f-sale-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-sale-pr    = if f-qnty = 0 then 0 else  f-sale-sum  / f-qnty

                                                        .
                                                      /* Учетная */
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
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
                                                        f-cost-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-cost-pr   = if Quantity1 = 0 then 0 else f-cost-sum / Quantity1
                                                        .
                                        end.
                                        else do:
                                                    /* На  сегодня */
                                                    Assign
                                                        f-qnty       = ub.gds-obj.fact-qnty
                                                        f-cost-sum   = determined(ub.gds-obj.fact-{5})
                                                        f-sale-sum   = ub.gds-obj.fact-sale
                                                        f-free-qnty  = ub.gds-obj.free-qnty
                                                        f-cost-pr   = if f-qnty = 0 then 0 else f-cost-sum / f-qnty
                                                        f-sale-pr   = if f-qnty = 0 then 0 else f-sale-sum / f-qnty

                                                        .
                                        end.

                                    f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
                                    /* ожидаемое */
                                    if c-f-wait-qnty <> ? Then DO :
                                      for each ub.trn-doc no-lock  where
                                          ub.trn-doc.obj-code        = obj-list.obj-code and
                                          ub.trn-doc.obj-type        = obj-list.obj-type and
                                          ub.trn-doc.status_         = {&wayb}           and
                                          ub.trn-doc.flag_           = true              and
                                          ub.trn-doc.Fact-order      <= fact-order-2     and
                                          ub.trn-doc.ext-doc-type    = {&TDEDT_Pri_Vnesh} :
                                          for each ub.doc-line no-lock where
                                              ub.doc-line.doc-code   = ub.trn-doc.doc-code   and
                                              ub.doc-line.artic      = ub.goods.artic        and
                                              ub.doc-line.prod-code  = ub.goods.prod-code    and
                                              ub.doc-line.prod-type  = ub.goods.prod-type    :
                                                  Assign
                                                    f-wait-qnty   = f-wait-qnty     + ub.doc-line.fact-qnty.
                                          end. /* for each ub.doc-line */
                                      End. /* for each ub.trn-doc*/
                                    End.  /* if c-f-wait-qnty <> ? */

                                  if itog = false and
                                      not(f-qnty         = 0 and
                                          f-cost-sum     = 0 and
                                          f-sale-sum     = 0 and
                                          f-sale-other   = 0 and
                                          f-free-qnty    = 0 and
                                          f-wait-qnty    = 0  )
                                      Then DO:
                                          n-nn = n-nn + 1 .
                                          { gbl/gdsbcode.i ub.goods.gds-code ? v-bar-code  }
                                          { rep/r-ob-cr.i disp  string(n-nn)                       nn         }
                                          { rep/r-ob-cr.i disp  ub.gds-obj.artic                      f-artic    }
                                          { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'")   f-b-code   }
                                          { rep/r-ob-cr.i disp  ub.goods.gds-name                     f-gds-name }
                                          { rep/r-ob-cr.i disp  f-qnty              f-qnty         }
                                          { rep/r-ob-cr.i disp  f-cost-pr           f-cost-pr     }
                                          { rep/r-ob-cr.i disp  f-cost-sum          f-cost-sum     }
                                          { rep/r-ob-cr.i disp  f-sale-pr           f-sale-pr     }
                                          { rep/r-ob-cr.i disp  f-sale-sum          f-sale-sum     }
                                          { rep/r-ob-cr.i disp  f-sale-other        f-sale-other   }
                                          { rep/r-ob-cr.i disp  f-free-qnty         f-free-qnty    }
                                          { rep/r-ob-cr.i disp  f-wait-qnty         f-wait-qnty    }

                                          display stream OutStream  no-error .
                                          DOWN stream OutStream .
                                          {&PutExcel}
                                          string(n-nn)                      {&tabulation}
                                          v-bar-code                        {&tabulation}
                                          ub.gds-obj.artic                     {&tabulation}
                                          ub.goods.gds-name                    {&tabulation}
                                                                            {&tabulation}
                                          excel-qnty(f-qnty        )        {&tabulation}
                                          excel-sum (f-cost-pr     )        {&tabulation}
                                          excel-sum (f-cost-sum    )        {&tabulation}
                                          excel-sum (f-sale-pr     )        {&tabulation}
                                          excel-sum (f-sale-sum    )        {&tabulation}
                                          excel-sum (f-sale-other  )        {&tabulation}
                                          excel-sum (f-free-qnty   )        {&tabulation}
                                          excel-sum (f-wait-qnty   )        {&tabulation}
                                          {&new-line} .
                                          Run Display-prt in this-procedure  .
                                  End. /* if itog false */

                      &if "{1}" = "no-classify" &then
                                    accumulate f-qnty           (TOTAL ) .
                                    accumulate f-cost-sum       (TOTAL ) .
                                    accumulate f-sale-sum       (TOTAL ) .
                                    accumulate f-sale-other     (TOTAL ) .
                                    accumulate f-free-qnty      (TOTAL ) .
                                    accumulate f-wait-qnty      (TOTAL ) .

                      &Else
                                    accumulate f-qnty           (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-cost-sum       (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-sale-sum       (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-sale-other     (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-free-qnty      (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-wait-qnty      (TOTAL  by ub.goods.grp-name ) .
                      &endif

                                      Assign
                                        f-qnty          = 0
                                        f-cost-sum      = 0
                                        f-sale-sum      = 0
                                        f-sale-other    = 0
                                        f-free-qnty     = 0
                                        f-wait-qnty     = 0
                                      .
                                End. /* if last-of artic */

                      &if "{1}" <> "no-classify" &then
                                if last-of(ub.goods.grp-name)  then do :
                                  f-artic = {3} .
                                  { rep/r-ob-cr.i disp    "'Итого'"    nn }
                                  { rep/r-ob-cr.i disp    f-artic         f-artic }
                                  { rep/r-ob-cr.i disp    var-client   f-gds-name  }
                                  { rep/r-ob-cr.i disp    "accum TOTAL by ub.goods.grp-name  f-qnty    "         f-qnty        }
                                  { rep/r-ob-cr.i disp    "accum TOTAL by ub.goods.grp-name  f-cost-sum "        f-cost-sum    }
                                  { rep/r-ob-cr.i disp    "accum TOTAL by ub.goods.grp-name  f-sale-sum"         f-sale-sum    }
                                  { rep/r-ob-cr.i disp    "accum TOTAL by ub.goods.grp-name  f-sale-other"       f-sale-other  }
                                  { rep/r-ob-cr.i disp    "accum TOTAL by ub.goods.grp-name  f-free-qnty"        f-free-qnty   }
                                  { rep/r-ob-cr.i disp    "accum TOTAL by ub.goods.grp-name  f-wait-qnty"        f-wait-qnty   }

                                    Display stream OutStream  no-error .
                                    DOWN stream OutStream .
                                    {&PutExcel}
                                    "Итого"                                              {&tabulation}
                                    {3}                                                   {&tabulation}
                                    var-client                                           {&tabulation} {&tabulation}  {&tabulation}
                                    excel-qnty(accum TOTAL by ub.goods.grp-name  f-qnty           )    {&tabulation}
                                    {&tabulation}
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-cost-sum       )   {&tabulation}
                                    {&tabulation}
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-sale-sum       )   {&tabulation}
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-sale-other     )   {&tabulation}
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-free-qnty      )   {&tabulation}
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-wait-qnty      )   {&tabulation}
                                    {&new-line} .
                                End.  /*if last prod-code */

                      &endif

                      End. /*for each ub.gds-obj & ub.gds-season */

        run u-line in this-procedure.

        { rep/r-ob-cr.i disp   "'ИТОГО'"                      nn             }
        { rep/r-ob-cr.i disp   "'коллекция'"               f-b-code       }
        { rep/r-ob-cr.i disp   "tt-season.sea-name"              f-gds-name     }

        { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
        { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
        { rep/r-ob-cr.i disp   "accum TOTAL f-free-qnty"        f-free-qnty    }
        { rep/r-ob-cr.i disp   "accum TOTAL f-wait-qnty"        f-wait-qnty    }

        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        {&PutExcel}
                "ИТОГО"                         {&tabulation}
                "коллекция"                    {&tabulation}
                tt-season.sea-name               {&tabulation}  {&tabulation}  {&tabulation}
                excel-qnty(accum TOTAL f-qnty           )  {&tabulation}
                {&tabulation}
                excel-sum (accum TOTAL f-cost-sum       )  {&tabulation}
                {&tabulation}
                excel-sum (accum TOTAL f-sale-sum       )  {&tabulation}
                excel-sum (accum TOTAL f-sale-other    )   {&tabulation}
                excel-sum (accum TOTAL f-free-qnty     )   {&tabulation}
                excel-sum (accum TOTAL f-wait-qnty     )   {&tabulation}

                {&new-line} .


      end.  /*      for each season */

      run u-line in this-procedure.
        { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
        { rep/r-ob-cr.i disp   "'по объекту'"                   f-b-code       }
        { rep/r-ob-cr.i disp   "obj-list.obj-name"              f-gds-name     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
        { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
        { rep/r-ob-cr.i disp   "accum TOTAL f-free-qnty"        f-free-qnty    }
        { rep/r-ob-cr.i disp   "accum TOTAL f-wait-qnty"        f-wait-qnty    }
        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        {&PutExcel}
          "ИТОГО"                         {&tabulation}
          "по объекту"                    {&tabulation}
          obj-list.obj-name               {&tabulation}  {&tabulation}  {&tabulation}
          excel-qnty(accum TOTAL f-qnty           )  {&tabulation}
          {&tabulation}
          excel-sum (accum TOTAL f-cost-sum       )  {&tabulation}
          {&tabulation}
          excel-sum (accum TOTAL f-sale-sum       )  {&tabulation}
          excel-sum (accum TOTAL f-sale-other    )   {&tabulation}
          excel-sum (accum TOTAL f-free-qnty     )   {&tabulation}
          excel-sum (accum TOTAL f-wait-qnty     )   {&tabulation}
          {&new-line} .

End.  /*for each obj-list*/
   if n-no > 1 then do:
        { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
        { rep/r-ob-cr.i disp   "'ПО ВСЕМ ОБЬЕКТАМ'"             f-artic        }
        { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
        { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
        { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
        { rep/r-ob-cr.i disp   "accum TOTAL f-free-qnty"        f-free-qnty    }
        { rep/r-ob-cr.i disp   "accum TOTAL f-wait-qnty"        f-wait-qnty    }

        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line in this-procedure.
         {&PutExcel}
         "ИТОГО"                       {&tabulation}
         "ПО ВСЕМ ОБЬЕКТАМ"            {&tabulation} {&tabulation} {&tabulation}  {&tabulation}
         excel-qnty(accum TOTAL f-qnty           )   {&tabulation}
         {&tabulation}
         excel-sum (accum TOTAL f-cost-sum       )   {&tabulation}
         {&tabulation}
         excel-sum (accum TOTAL f-sale-sum       )   {&tabulation}
         excel-sum (accum TOTAL f-sale-other     )   {&tabulation}
         excel-sum (accum TOTAL f-free-qnty      )   {&tabulation}
         excel-sum (accum TOTAL f-wait-qnty      )   {&tabulation}
         {&new-line} .
    End. /* do */
&else
/* Procedure Display-prt */
/* а есть ли у него шкала ? */

IF ub.goods.prt-root <> Prtroot Then DO:
  /* На любое время */
If v-var = "no-today"  then
run  prdoclib-init-prt-obj-by-factord in this-procedure
( input ub.gds-obj.obj-type  ,
  input ub.gds-obj.obj-code  ,
  input ub.gds-obj.artic     ,
  input ub.gds-obj.prod-type ,
  input ub.gds-obj.prod-code ,
  input fact-order-2 ,
  input false ) .

  for each ub.prt-obj where
      ub.prt-obj.artic     = ub.goods.artic     and
      ub.prt-obj.prod-type = ub.goods.prod-type and
      ub.prt-obj.prod-code = ub.goods.prod-code and
      ub.prt-obj.obj-code  = obj-list.obj-code and
      ub.prt-obj.obj-type  = obj-list.obj-type and
      ub.prt-obj.IS-term   =  true no-lock
            BREAK BY ub.prt-obj.prt-code with FRAME Zapas :
              if v-var <> "no-today" then do:
                  Assign
                    p-qnty      = p-qnty       + ub.prt-obj.fact-qnty
                    p-free-qnty = p-free-qnty  + ub.prt-obj.free-qnty
                    p-sale-sum  = p-sale-sum   + ub.prt-obj.fact-qnty * ub.prt-obj.price-sale
                    p-sale-pr   = if p-qnty = 0 then 0 else p-sale-sum / p-qnty    .
              End.

    IF last-of(ub.prt-obj.prt-code) THEN DO:

              { gbl/gdsbcode.i ub.gds-obj.gds-code ub.prt-obj.prt-code v-bar-code  } /* бар-код признака*/
              if v-var = "no-today" then do:
                find first temp-prt-obj no-lock
                     where temp-prt-obj.prt-obj-recid   = recid (ub.prt-obj) no-error .
                     if avail temp-prt-obj then do :
                       run  calc-price-sale-for-prt in this-procedure  (output v-price-sale) .
                        Assign
                          p-qnty      = temp-prt-obj.fact-qnty
                          p-free-qnty = 0
                          p-sale-sum  = temp-prt-obj.fact-qnty * v-price-sale
                          p-sale-pr   = if p-qnty = 0 then 0 else p-sale-sum / p-qnty    .
                      End.
                      Else
                        Assign
                          p-qnty      = 0
                          p-free-qnty = 0
                          p-sale-sum  = 0   .

              End.
        FIND first ub.gds-prt  where ub.gds-prt.node-code = ub.prt-obj.prt-code NO-LOCK no-error .
        /* ожидаемое */
        if c-f-wait-qnty <> ? Then DO :
          for each ub.trn-doc no-lock  where
              ub.trn-doc.obj-code        = obj-list.obj-code and
              ub.trn-doc.obj-type        = obj-list.obj-type and
              ub.trn-doc.status_         = {&wayb}           and
              ub.trn-doc.flag_           = true              and
              ub.trn-doc.ext-doc-type    = {&TDEDT_Pri_Vnesh} :
              for each ub.gds-dtl no-lock where
                  ub.gds-dtl.doc-code   = ub.trn-doc.doc-code   and
                  ub.gds-dtl.artic      = ub.goods.artic        and
                  ub.gds-dtl.prod-code  = ub.goods.prod-code    and
                  ub.gds-dtl.prod-type  = ub.goods.prod-type    and
                  ub.gds-dtl.prt-code   = ub.prt-obj.prt-code   and
                  ub.gds-dtl.obj-code   = obj-list.obj-code  and
                  ub.gds-dtl.obj-type   = obj-list.obj-type :
                      Assign
                        p-wait-qnty   = p-wait-qnty     + ub.gds-dtl.fact-qnty.
              end. /* for each ub.gds-dtl */
          End. /* for each ub.trn-doc*/
        End.  /* if c-f-wait-qnty <> ? */
        Assign
        p-cost-sum     = determined( f-cost-sum * p-qnty  / f-qnty)
        p-sale-other   = 100 * determined((p-sale-sum - p-cost-sum) / p-cost-sum)
        p-cost-pr    = if p-qnty = 0 then 0 else p-cost-sum  / p-qnty


        .
        if not (p-zero = false  and
             (p-qnty        =  0  and
              p-cost-sum    =  0  and
              p-sale-sum    =  0  and
              p-sale-other  =  0  and
              p-free-qnty   =  0  and
              p-wait-qnty   =  0  ) )then DO:


            { rep/r-ob-cr.i disp  "''"                                 nn         }
            { rep/r-ob-cr.i disp  "''"                                 f-artic    }
            { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'")     f-b-code   }
            { rep/r-ob-cr.i disp  ub.gds-prt.f-name                     f-prt-name }
            { rep/r-ob-cr.i disp  p-qnty             f-qnty       }
            { rep/r-ob-cr.i disp  p-cost-pr         f-cost-pr   }
            { rep/r-ob-cr.i disp  p-cost-sum         f-cost-sum   }
            { rep/r-ob-cr.i disp  p-sale-pr         f-sale-pr   }
            { rep/r-ob-cr.i disp  p-sale-sum         f-sale-sum   }
            { rep/r-ob-cr.i disp  p-sale-other       f-sale-other }
            { rep/r-ob-cr.i disp  p-free-qnty        f-free-qnty  }
            { rep/r-ob-cr.i disp  p-wait-qnty        f-wait-qnty   }
            Display stream OutStream no-error.
            DOWN stream OutStream .
            {&PutExcel}
            {&tabulation}
            string(v-bar-code,"999999999")
                         {&tabulation}
                         {&tabulation}
                         {&tabulation}
             ub.gds-prt.f-name                    {&tabulation}
             excel-qnty(p-qnty)                            {&tabulation}
             {&tabulation}
             excel-sum(p-cost-sum)                        {&tabulation}
             {&tabulation}
             excel-sum(p-sale-sum)                        {&tabulation}
             excel-sum(p-sale-other)                      {&tabulation}
             excel-sum(p-free-qnty)                       {&tabulation}
             excel-sum(p-wait-qnty)                       {&new-line} .

        End.
        Assign
          p-qnty        =  0
          p-cost-sum    =  0
          p-sale-sum    =  0
          p-sale-other  =  0
          p-free-qnty   =  0
          p-wait-qnty   =  0
          .
    End.
  End.
End.
&endif
/* $Workfile$ e n d */