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
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".
&if "{1}" <> "Display"  &then
          n-nn = 0.
          n-no = n-no + 1 .
 For Each gds-list  break
                &if "{1}" = "no-classify" &then
                by
                   (if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                &endif
                &if "{1}" = "prod-code" &then
                by gds-list.prod-type
                by gds-list.prod-code
                by
                   ( if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                &endif
                &if "{1}" = "grp-goods" &then
                by gds-list.grp-name
                by
                   (if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))

                by gds-list.artic
                &endif
                &if "{1}" = "VAT-pc" &then
                by gds-list.qnty
                   by
                   (if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                &endif
                 with FRAME Zapas :

              IF first-of(gds-list.artic) then DO:
                assign
                  f-qnty         = 0
                  f-cost-sum     = 0
                  f-sale-sum     = 0
                  f-sale-other   = 0
                  f-qnty-alt         = 0
                  f-cost-sum-alt     = 0
                  f-sale-sum-alt     = 0
                  f-sale-other-alt   = 0
                  .
              End.
&if "{1}" = "prod-code"  &then
/* По производителю----------- */
          if first-of(gds-list.prod-code) then DO:
              FIND FIRST clients-p where  gds-list.prod-type = clients-p.obj-type AND
                                          gds-list.prod-code = clients-p.obj-code no-lock no-error.
                  if avail clients-p then var-client = Clients-p.obj-name.
                  if  Itog = false Then do:
                    { rep/r-ob-cr.i disp   var-client   f-gds-name}
                    Display stream OutStream .
                    DOWN stream OutStream .
                    {&PutExcel} var-client {&new-line} .
                  End.
          End.
/*----------------------------*/
&endif
&if "{1}" = "grp-goods" &then
/* По производителю----------- */
          if first-of(gds-list.grp-name) then  DO:
            var-client = gds-list.grp-name.
            if  Itog = false Then do:
              PUT stream OutStream  gds-list.grp-name  AT 1 format "X(160)" SKIP.
              DOWN stream OutStream .
              {&PutExcel} gds-list.grp-name {&new-line} .
            End.
          End.
/*----------------------------*/
&endif
&if "{1}" = "VAT-pc" &then
/* По НДС ----------- */
          if first-of(gds-list.qnty) then DO:
              var-client = string(gds-list.qnty) + '%'.
              if  Itog = false Then do:
                  { rep/r-ob-cr.i disp   "'Ставка НДС ' + string(gds-list.qnty) + '%'"    f-gds-name}
                  Display stream OutStream .
                  DOWN stream OutStream .
                  {&PutExcel} 'Ставка НДС ' + string(gds-list.qnty) + '%' {&new-line} .
              End.
          End.
&endif
          if last-of(gds-list.artic) then DO:
             n-nm = n-nm + 1.
             { rep/r-mess.i n-nm 50 }
 /* по объект  1 */
             For each obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = obj-list.obj-code and
                    ub.gds-obj.obj-type  = obj-list.obj-type    :
                    Assign
                      f-qnty       = f-qnty     + ub.gds-obj.{&qnty-type}
                      f-cost-sum   = f-cost-sum + determined(gds-obj.fact-{5})
                      f-sale-sum   = f-sale-sum + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
 /* по объект  2 */
             For each alt-obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = alt-obj-list.obj-code and
                    ub.gds-obj.obj-type  = alt-obj-list.obj-type    :
                    Assign
                    f-qnty-alt       = f-qnty-alt     + ub.gds-obj.{&qnty-type}
                    f-cost-sum-alt   = f-cost-sum-alt + determined(gds-obj.fact-{5})
                    f-sale-sum-alt   = f-sale-sum-alt + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other-alt = 100 * determined((f-sale-sum-alt - f-cost-sum-alt) / f-cost-sum-alt).

             if itog = false and
                NOT(
                   ( f-qnty          = 0 and
                    f-cost-sum       = 0 and
                    f-sale-sum       = 0 and
                    f-sale-other     = 0 and
                    f-qnty-alt       = 0 and
                    f-cost-sum-alt   = 0 and
                    f-sale-sum-alt   = 0 and
                    f-sale-other-alt = 0  ))
             Then DO:
                    sss = 0 .
                    if show-zero = false  then do:
                    /* проверка на нуль */
                       if c-f-qnty <>  ?  and  f-qnty <> 0 then sss = 1 .
                       if c-f-cost-sum       <>  ?  and  round(f-cost-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum       <>  ?  and  round(f-sale-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-other     <>  ?  and  round(f-sale-other     ,2) <> 0 then sss = 1 .
                       if c-f-qnty-alt       <>  ?  and  round(f-qnty-alt       ,2) <> 0 then sss = 1 .
                       if c-f-cost-sum-alt   <>  ?  and  round(f-cost-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum-alt   <>  ?  and  round(f-sale-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-other-alt <>  ?  and  round(f-sale-other-alt,2)  <> 0 then sss = 1 .
                    end.
                    else  do: sss = 1 . end.

                    if sss = 1 then do:
                      n-nn = n-nn + 1 .
                      { gbl/gdsbcode.i gds-list.gds-code ? v-bar-code  }
                      { rep/r-ob-cr.i disp  string(n-nn)     nn         }
                      { rep/r-ob-cr.i disp  gds-list.artic   f-artic    }
                      { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'") f-b-code   }
                      { rep/r-ob-cr.i disp  gds-list.gds-name  f-gds-name }
                      { rep/r-ob-cr.i disp  f-qnty           f-qnty         }
                      { rep/r-ob-cr.i disp  f-cost-sum       f-cost-sum     }
                      { rep/r-ob-cr.i disp  f-sale-sum       f-sale-sum     }
                      { rep/r-ob-cr.i disp  f-sale-other     f-sale-other   }
                      { rep/r-ob-cr.i disp  f-qnty-alt       f-qnty-alt     }
                      { rep/r-ob-cr.i disp  f-cost-sum-alt   f-cost-sum-alt }
                      { rep/r-ob-cr.i disp  f-sale-sum-alt   f-sale-sum-alt }
                      { rep/r-ob-cr.i disp  f-sale-other-alt f-sale-other-alt }

                      display stream OutStream  no-error .
                      DOWN stream OutStream .
                      {&PutExcel}
                        string(n-nn)                      {&tabulation}
                        v-bar-code                        {&tabulation}
                        (gds-list.artic)                  {&tabulation}
                        gds-list.gds-name                 {&tabulation}
                                                          {&tabulation}
                        excel-qnty(f-qnty        )        {&tabulation}
                        excel-sum (f-cost-sum    )        {&tabulation}
                        excel-sum (f-sale-sum    )        {&tabulation}
                        excel-sum (f-sale-other  )        {&tabulation}
                        excel-qnty(f-qnty-alt        )    {&tabulation}
                        excel-sum (f-cost-sum-alt    )    {&tabulation}
                        excel-sum (f-sale-sum-alt    )    {&tabulation}
                        excel-sum (f-sale-other-alt  )    {&tabulation}
                        {&new-line} .
                        Run Display-prt in this-procedure  .
                    end. /* sss = 1  */
             End. /* if itog false */

 &if "{1}" = "no-classify" &then
              accumulate f-qnty               (TOTAL) .
              accumulate f-cost-sum           (TOTAL) .
              accumulate f-sale-sum           (TOTAL) .
              accumulate f-sale-other         (TOTAL) .
              accumulate f-qnty-alt           (TOTAL) .
              accumulate f-cost-sum-alt       (TOTAL) .
              accumulate f-sale-sum-alt       (TOTAL) .
              accumulate f-sale-other-alt     (TOTAL) .

&Else
              accumulate f-qnty               (TOTAL  by {2} ) .
              accumulate f-cost-sum           (TOTAL  by {2} ) .
              accumulate f-sale-sum           (TOTAL  by {2} ) .
              accumulate f-sale-other         (TOTAL  by {2} ) .
              accumulate f-qnty-alt           (TOTAL  by {2} ) .
              accumulate f-cost-sum-alt       (TOTAL  by {2} ) .
              accumulate f-sale-sum-alt       (TOTAL  by {2} ) .
              accumulate f-sale-other-alt     (TOTAL  by {2} ) .

&endif

                Assign
                  f-qnty              = 0
                  f-cost-sum          = 0
                  f-sale-sum          = 0
                  f-sale-other        = 0
                  f-qnty-alt          = 0
                  f-cost-sum-alt      = 0
                  f-sale-sum-alt      = 0
                  f-sale-other-alt    = 0
                 .
          End. /* if last-of artic */

&if "{1}" <> "no-classify" &then
          if last-of({2})  then do :
            f-artic = {3} .
            { rep/r-ob-cr.i disp    "'Итого'"    nn }
            { rep/r-ob-cr.i disp    f-artic         f-artic }
            { rep/r-ob-cr.i disp    var-client   f-gds-name  }
            { rep/r-ob-cr.i disp    "accum TOTAL by "{2}" f-qnty    "         f-qnty        }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-cost-sum "        f-cost-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL  by {2}  f-sale-sum"         f-sale-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-sale-other"       f-sale-other  }
            { rep/r-ob-cr.i disp    "accum TOTAL by "{2}" f-qnty-alt    "         f-qnty-alt        }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-cost-sum-alt "        f-cost-sum-alt    }
            { rep/r-ob-cr.i disp    "accum TOTAL  by {2}  f-sale-sum-alt"         f-sale-sum-alt    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  {2}  f-sale-other-alt"       f-sale-other-alt  }

              Display stream OutStream  no-error .
              DOWN stream OutStream .
              {&PutExcel}
              "Итого"                                              {&tabulation}
              {3}
              var-client                                           {&tabulation} {&tabulation} {&tabulation} {&tabulation}
              excel-qnty(accum TOTAL by {2}  f-qnty           )    {&tabulation}
              excel-sum (accum TOTAL by {2}  f-cost-sum       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-sum       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-other     )   {&tabulation}
              excel-qnty(accum TOTAL by {2}  f-qnty-alt           )    {&tabulation}
              excel-sum (accum TOTAL by {2}  f-cost-sum-alt       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-sum-alt       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-other-alt     )   {&tabulation}

              {&new-line} .
          End.  /*if last prod-code */
&endif
 End. /*for each gds-list */
 run u-line.
  { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn           }
  { rep/r-ob-cr.i disp   "'по объектам'"                  f-artic      }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other   }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty-alt"             f-qnty-alt         }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-alt"         f-cost-sum-alt     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum-alt"         f-sale-sum-alt     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other-alt"       f-sale-other-alt   }

  Display stream OutStream with FRAME Zapas no-error.
  DOWN stream OutStream with FRAME Zapas.
  run u-line.
  {&PutExcel}
          "ИТОГО"                         {&tabulation}
          "по объектам"                    {&tabulation}
                                             {&tabulation} {&tabulation} {&tabulation}
          excel-qnty(accum TOTAL f-qnty           )  {&tabulation}
          excel-sum (accum TOTAL f-cost-sum       )  {&tabulation}
          excel-sum (accum TOTAL f-sale-sum       )  {&tabulation}
          excel-sum (accum TOTAL f-sale-other    )   {&tabulation}
          excel-qnty(accum TOTAL f-qnty-alt           )  {&tabulation}
          excel-sum (accum TOTAL f-cost-sum-alt       )  {&tabulation}
          excel-sum (accum TOTAL f-sale-sum-alt       )  {&tabulation}
          excel-sum (accum TOTAL f-sale-other-alt    )   {&tabulation}
          {&new-line} .
&else
/* Procedure Display-prt ------------------------------------------------------------------------------------------------*/
/* а есть ли у него шкала ? */

IF gds-list.prt-root <> Prtroot Then DO:
    for each ub.gds-prt no-lock where
        ub.gds-prt.prt-root = gds-list.prt-root and
        ub.gds-prt.IS-term   =  true
        by ub.gds-prt.f-name with FRAME Zapas :
      /* по объект  1 */
            For each obj-list no-lock :
                for each ub.prt-obj no-lock where
                    ub.prt-obj.artic     = gds-list.artic     and
                    ub.prt-obj.prod-type = gds-list.prod-type and
                    ub.prt-obj.prod-code = gds-list.prod-code and
                    ub.prt-obj.obj-code  = obj-list.obj-code and
                    ub.prt-obj.obj-type  = obj-list.obj-type and
                    ub.prt-obj.IS-term   =  true and
                    ub.prt-obj.prt-code  = ub.gds-prt.node-code :
                    Assign
                      p-qnty      = p-qnty       + ub.prt-obj.{&qnty-type}
                      p-sale-sum  = p-sale-sum   + ub.prt-obj.{&qnty-type} * ub.prt-obj.price-sale .

                End.
            End.
            Assign
              p-cost-sum     = determined( f-cost-sum * p-qnty  / f-qnty)
              p-sale-other   = 100 * determined((p-sale-sum - p-cost-sum) / p-cost-sum)
              .
    /* по объект 2 */
            For each alt-obj-list no-lock :
                for each ub.prt-obj no-lock where
                    ub.prt-obj.artic     = gds-list.artic     and
                    ub.prt-obj.prod-type = gds-list.prod-type and
                    ub.prt-obj.prod-code = gds-list.prod-code and
                    ub.prt-obj.obj-code  = alt-obj-list.obj-code and
                    ub.prt-obj.obj-type  = alt-obj-list.obj-type and
                    ub.prt-obj.IS-term   = true and
                    ub.prt-obj.prt-code  = ub.gds-prt.node-code
                    :
                    assign
                      p-qnty-alt      = p-qnty-alt       + ub.prt-obj.{&qnty-type}
                      p-sale-sum-alt  = p-sale-sum-alt   + ub.prt-obj.{&qnty-type} * ub.prt-obj.price-sale
                   .
                end.
            end.
            assign
              p-cost-sum-alt     = determined( f-cost-sum-alt * p-qnty-alt  / f-qnty-alt)
              p-sale-other-alt   = 100 * determined ((p-sale-sum-alt - p-cost-sum-alt) / p-cost-sum-alt)
              .

            if  NOT(
                  p-qnty      =  0  and
                  p-cost-sum    =  0  and
                  p-sale-sum    =  0  and
                  p-sale-other  =  0 and
                  p-qnty-alt      =  0  and
                  p-cost-sum-alt    =  0  and
                  p-sale-sum-alt    =  0  and
                  p-sale-other-alt  =  0
                  ) then DO:

                { gbl/gdsbcode.i gds-list.gds-code ub.gds-prt.node-code v-bar-code  }
                { rep/r-ob-cr.i disp  "''"                             nn         }
                { rep/r-ob-cr.i disp  "''"                             f-artic    }
                { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'") f-b-code   }
                { rep/r-ob-cr.i disp  ub.gds-prt.f-name                   f-prt-name }
                { rep/r-ob-cr.i disp  p-qnty           f-qnty       }
                { rep/r-ob-cr.i disp  p-cost-sum       f-cost-sum   }
                { rep/r-ob-cr.i disp  p-sale-sum       f-sale-sum   }
                { rep/r-ob-cr.i disp  p-sale-other     f-sale-other }
                { rep/r-ob-cr.i disp  p-qnty-alt       f-qnty-alt       }
                { rep/r-ob-cr.i disp  p-cost-sum-alt   f-cost-sum-alt   }
                { rep/r-ob-cr.i disp  p-sale-sum-alt   f-sale-sum-alt   }
                { rep/r-ob-cr.i disp  p-sale-other-alt f-sale-other-alt }

                Display stream OutStream no-error.
                DOWN stream OutStream .
                    {&PutExcel}
                     string(n-nn)                 {&tabulation}
                     v-bar-code                   {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
                     ub.gds-prt.f-name               {&tabulation}
                     excel-qnty(p-qnty        )   {&tabulation}
                     excel-sum (p-cost-sum    )   {&tabulation}
                     excel-sum (p-sale-sum    )   {&tabulation}
                     excel-sum (p-sale-other  )   {&tabulation}
                     excel-qnty(p-qnty-alt      ) {&tabulation}
                     excel-sum (p-cost-sum-alt  ) {&tabulation}
                     excel-sum (p-sale-sum-alt  ) {&tabulation}
                     excel-sum (p-sale-other-alt) {&tabulation}
                     {&new-line} .
            End.
            Assign
              p-qnty            =  0
              p-cost-sum        =  0
              p-sale-sum        =  0
              p-sale-other      =  0
              p-qnty-alt        =  0
              p-cost-sum-alt    =  0
              p-sale-sum-alt    =  0
              p-sale-other-alt  =  0
              .
    End.
End.
&endif
/* $Workfile$ e n d */