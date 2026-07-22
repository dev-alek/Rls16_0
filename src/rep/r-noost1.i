/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

"Оборотная ведомость (без остатков)" внутренности.

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
{ rep/repfrm.i disp  n-nm reportname objname }
 &if "{1}" <> "vat-pc" &then
  for each obj-list no-lock with FRAME Zapas :
    if NOT( classify = 1 and Itog = true) then dO:
      { rep/r-ob-cr.i disp  obj-list.obj-name  f-gds-name}
      { rep/r-ob-cr.i full  "''"               f-crsa-sum }
      { rep/r-ob-cr.i full  "''"               f-sale-sum }
      { rep/r-ob-cr.i full  "''"               f-cost-sum }
      { rep/r-ob-cr.i full  "''"               f-cost-vat }
      { rep/r-ob-cr.i full  "''"               f-cost-sum-novat}
      { rep/r-ob-cr.i full  "''"               f-sale-vat }
      { rep/r-ob-cr.i full  "''"               f-sale-slt }
      { rep/r-ob-cr.i full  "''"               f-sale-other}
      { rep/r-ob-cr.i full  "''"               f-disc }
      { rep/r-ob-cr.i full  "''"               f-disc-prc}
      { rep/r-ob-cr.i full  "''"               f-qnty     }
  Display stream OutStream no-error .
  DOWN stream OutStream .

      { rep/r-ob-cr.i sfull f-crsa-sum }
      { rep/r-ob-cr.i sfull f-sale-sum }
      { rep/r-ob-cr.i sfull f-cost-sum }
      { rep/r-ob-cr.i sfull f-cost-vat }
      { rep/r-ob-cr.i sfull f-cost-sum-novat}
      { rep/r-ob-cr.i sfull f-sale-vat }
      { rep/r-ob-cr.i sfull f-sale-slt }
      { rep/r-ob-cr.i sfull f-sale-other}
      { rep/r-ob-cr.i sfull f-disc }
      { rep/r-ob-cr.i sfull f-disc-prc}
      { rep/r-ob-cr.i sfull f-qnty     }

   {&PutExcel}  obj-list.obj-name {&new-line}.
   End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type  no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
          &if '{6}' = 'gds-list'  &then
          , First gds-list where  ub.ot-line.prod-type = gds-list.prod-type and
                                  ub.ot-line.prod-code = gds-list.prod-code and
                                  ub.ot-line.artic     = gds-list.artic no-lock
            &Endif
            break
                &if "{1}" <> "prod-code" &then
                by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
                &endif
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic
                by ub.ot-line.sum-type
                with FRAME Zapas :

          accumulate ub.ot-line.fact-qnty  (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.sum-{5}    (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.vat-{5}   (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.slt-{5}   (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.other-{5} (TOTAL BY ub.ot-line.sum-type ).
&if "{1}" = "prod-code" &then
/* По производителю----------- */
          if first-of(ub.ot-line.prod-code)  and classify = 2 then DO:
              FIND FIRST clients-p where  ub.ot-line.prod-type = clients-p.obj-type AND
                                          ub.ot-line.prod-code = clients-p.obj-code no-lock no-error.
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
          if last-of(ub.ot-line.sum-type) then DO :
  /* Сбор сумм */
          Case  ub.ot-line.sum-type :
              when {&arh-cost} then do:
                f-cost-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-{5} .
                f-cost-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-{5} .
              end.
              when {&arh-sale} then do:
                 f-sale-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-{5} .
                 f-sale-other = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.other-{5} .
                 f-sale-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-{5} .
                 f-sale-slt = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.slt-{5} .
              end.
              when  {&arh-crsa} then do:
                f-crsa-sum1 = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-{5} .
                f-qnty1 = accum TOTAL BY  ub.ot-line.sum-type ub.ot-line.fact-qnty.

              end.
              when {&arh-cost-service} then do:
                f-cost-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-{5} .
                f-cost-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-{5} .
              end.
              when {&arh-sale-service} then do:
                 f-sale-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-{5} .
                 f-sale-other = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.other-{5} .
                 f-sale-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-{5} .
                 f-sale-slt = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.slt-{5} .
              end.
              when {&arh-crsa-service} then do:
                f-crsa-sum2 = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-{5} .
                f-qnty2 = accum TOTAL BY  ub.ot-line.sum-type ub.ot-line.fact-qnty.

              end.

          End case.
          f-qnty = f-qnty2 + f-qnty1.
          f-crsa-sum = f-crsa-sum2 + f-crsa-sum1.
          End.

          if last-of(ub.ot-line.artic) then DO:
             n-nm = n-nm + 1.
             { rep/repfrm.i disp n-nm reportname objname }
             find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                       ub.ot-line.prod-code = goods.prod-code and
                                       ub.ot-line.artic     = goods.artic no-lock no-error .

             f-cost-sum-novat = f-cost-sum - f-cost-vat .
             f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
             f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .
             if itog = false
                AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                Then DO:
                n-nn = n-nn + 1.
                    { rep/r-ob-cr.i disp  string(n-nn)       nn}
                    { rep/r-ob-cr.i disp  ub.ot-line.artic      f-artic}
                    { rep/r-ob-cr.i disp  goods.gds-name     f-gds-name}
                    { rep/r-ob-cr.i disp  f-qnty             f-qnty     }
                    { rep/r-ob-cr.i disp  f-crsa-sum         f-crsa-sum }
                    { rep/r-ob-cr.i disp  f-sale-sum         f-sale-sum }
                    { rep/r-ob-cr.i disp  f-cost-sum         f-cost-sum }
                    { rep/r-ob-cr.i disp  f-cost-vat         f-cost-vat }
                    { rep/r-ob-cr.i disp  f-cost-sum-novat   f-cost-sum-novat}
                    { rep/r-ob-cr.i disp  f-sale-vat         f-sale-vat }
                    { rep/r-ob-cr.i disp  f-sale-slt         f-sale-slt }
                    { rep/r-ob-cr.i disp  f-sale-other       f-sale-other}
                    { rep/r-ob-cr.i disp  f-disc             f-disc }
                    { rep/r-ob-cr.i disp  f-disc-prc         f-disc-prc}
                    display stream OutStream  no-error .
                    DOWN stream OutStream .

                    {&PutExcel}
                     string(n-nn)     {&tabulation}
                     (ub.ot-line.artic)    {&tabulation}
                     goods.gds-name   {&tabulation}
                     excel-qnty(f-qnty)           {&tabulation}
                     excel-sum (f-cost-sum)       {&tabulation}
                     excel-sum (f-cost-vat)       {&tabulation}
                     excel-sum (f-cost-sum-novat) {&tabulation}
                     excel-sum (f-sale-sum)       {&tabulation}
                     excel-sum (f-sale-other)     {&tabulation}
                     excel-sum (f-sale-vat)       {&tabulation}
                     excel-sum (f-sale-slt)       {&tabulation}
                     excel-sum (f-disc)           {&tabulation}
                     excel-qnty(f-disc-prc)       {&tabulation}
                     excel-sum (f-crsa-sum)       {&new-line} .
             End. /* if itog false */
              accumulate f-qnty           (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-crsa-sum       (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-sale-sum       (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-cost-sum       (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-cost-vat       (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-sale-vat       (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-sale-slt       (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-sale-other     (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-disc           (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .
              accumulate f-cost-sum-novat (TOTAL &if "{1}" = "prod-code" &then  by ub.ot-line.prod-code &endif) .

 &if "{1}" = "prod-code" &then                 /*ИТОГО По производителю */
                   if last-of(ub.ot-line.prod-code) and classify = 2 then do:
                      { rep/r-ob-cr.i disp    "'Итого'"                                               nn          }
                      { rep/r-ob-cr.i disp    "'по произв.'"                                          f-artic     }
                      { rep/r-ob-cr.i disp    var-client                                            f-gds-name  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-qnty"             f-qnty      }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-crsa-sum"         f-crsa-sum  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-sale-sum"         f-sale-sum  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-cost-sum"         f-cost-sum  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-cost-vat"         f-cost-vat  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-cost-sum-novat"   f-cost-sum-novat}
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-sale-vat"         f-sale-vat  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-sale-slt"         f-sale-slt  }
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-sale-other"       f-sale-other}
                      { rep/r-ob-cr.i disp    "accum TOTAL by ub.ot-line.prod-code f-disc"             f-disc      }
                       Display stream OutStream  no-error .
                       DOWN stream OutStream .
                       {&PutExcel}
                        "Итого"                                              {&tabulation}
                        "по произв."
                        var-client                                           {&tabulation}
                        excel-qnty(accum TOTAL by ub.ot-line.prod-code f-qnty          )    {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-cost-sum       )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-cost-vat       )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-cost-sum-novat )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-sum       )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-other     )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-vat       )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-slt       )   {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-disc           )   {&tabulation} {&tabulation}
                        excel-sum (accum TOTAL by ub.ot-line.prod-code  f-crsa-sum      )   {&new-line} .
                   End. /*if last prod-code */
&endif
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-qnty1           = 0
                  f-crsa-sum1       = 0
                  f-qnty2           = 0
                  f-crsa-sum2       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .
          End. /* if last-of artic */
 End. /*for each ub.ot-line */
 run u-line.
  { rep/r-ob-cr.i disp   "'ИТОГО'"                        nn             }
  { rep/r-ob-cr.i disp   "'по объекту'"                   f-artic        }
  { rep/r-ob-cr.i disp   "obj-list.obj-name"              f-gds-name     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-qnty"             f-qnty         }
  { rep/r-ob-cr.i disp   "accum TOTAL f-crsa-sum"         f-crsa-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-sum"         f-sale-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum"         f-cost-sum     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-vat"         f-cost-vat     }
  { rep/r-ob-cr.i disp   "accum TOTAL f-cost-sum-novat"   f-cost-sum-novat }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-vat"         f-sale-vat      }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-slt"         f-sale-slt      }
  { rep/r-ob-cr.i disp   "accum TOTAL f-sale-other"       f-sale-other    }
  { rep/r-ob-cr.i disp   "accum TOTAL f-disc"             f-disc          }

  Display stream OutStream no-error.
  DOWN stream OutStream .
  run u-line.
  {&PutExcel}
          "ИТОГО"                         {&tabulation}
          "по объекту"                    {&tabulation}
          obj-list.obj-name               {&tabulation}
          excel-qnty(accum TOTAL f-qnty           )   {&tabulation}
          excel-sum (accum TOTAL f-cost-sum       )   {&tabulation}
          excel-sum (accum TOTAL f-cost-vat       )   {&tabulation}
          excel-sum (accum TOTAL f-cost-sum-novat )   {&tabulation}
          excel-sum (accum TOTAL f-sale-sum      )    {&tabulation}
          excel-sum (accum TOTAL f-sale-other    )    {&tabulation}
          excel-sum (accum TOTAL f-sale-vat      )    {&tabulation}
          excel-sum (accum TOTAL f-sale-slt      )    {&tabulation}
          excel-sum (accum TOTAL f-disc         )     {&tabulation} {&tabulation}
          excel-sum (accum TOTAL f-crsa-sum      )    {&new-line} .

End.  /*for each obj-list*/
   if n-no > 1 then do:
        { rep/r-ob-cr.i disp    "'ИТОГО'"                        nn                 }
        { rep/r-ob-cr.i disp    "'ПО ВСЕМ ОБЬЕКТАМ'"             f-artic            }
        { rep/r-ob-cr.i disp    "accum TOTAL f-qnty"             f-qnty             }
        { rep/r-ob-cr.i disp    "accum TOTAL f-crsa-sum"         f-crsa-sum         }
        { rep/r-ob-cr.i disp    "accum TOTAL f-sale-sum"         f-sale-sum         }
        { rep/r-ob-cr.i disp    "accum TOTAL f-cost-sum"         f-cost-sum         }
        { rep/r-ob-cr.i disp    "accum TOTAL f-cost-vat"         f-cost-vat         }
        { rep/r-ob-cr.i disp    "accum TOTAL f-cost-sum-novat"   f-cost-sum-novat   }
        { rep/r-ob-cr.i disp    "accum TOTAL f-sale-vat"         f-sale-vat         }
        { rep/r-ob-cr.i disp    "accum TOTAL f-sale-slt"         f-sale-slt         }
        { rep/r-ob-cr.i disp    "accum TOTAL f-sale-other"       f-sale-other       }
        { rep/r-ob-cr.i disp    "accum TOTAL f-disc"             f-disc             }
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line.
         {&PutExcel}
         "ИТОГО"                       {&tabulation}
         "ПО ВСЕМ ОБЬЕКТАМ"            {&tabulation}
         excel-qnty(accum TOTAL f-qnty        )    {&tabulation}
         excel-sum (accum TOTAL f-cost-sum    )    {&tabulation}
         excel-sum (accum TOTAL f-cost-vat    )    {&tabulation}
         excel-sum (accum TOTAL f-cost-sum-novat ) {&tabulation}
         excel-sum (accum TOTAL f-sale-sum       ) {&tabulation}
         excel-sum (accum TOTAL f-sale-other    )  {&tabulation}
         excel-sum (accum TOTAL f-sale-vat      )  {&tabulation}
         excel-sum (accum TOTAL f-sale-slt      )  {&tabulation}
         excel-sum (accum TOTAL f-disc          )  {&tabulation} {&tabulation}
         excel-sum (accum TOTAL f-crsa-sum      )  {&new-line} .
    End.  &endif
/*======================================================================================================================*/
  &if "{1}" = "vat-pc" &then
   Assign
    ff-qnty           = 0
    ff-crsa-sum       = 0
    ff-sale-sum       = 0
    ff-cost-sum       = 0
    ff-cost-vat       = 0
    ff-cost-sum-novat = 0
    ff-sale-vat       = 0
    ff-sale-slt       = 0
    ff-sale-other     = 0
    ff-disc           = 0
    ff-disc-prc       = 0
    .

  For each obj-list no-lock break by obj-list.obj-type by obj-list.obj-code
   with FRAME Zapas :
      if NOT (itog = true and classify = 1) Then DO :
      { rep/r-ob-cr.i disp  obj-list.obj-name  f-gds-name}
      { rep/r-ob-cr.i full  "''"               f-crsa-sum }
      { rep/r-ob-cr.i full  "''"               f-sale-sum }
      { rep/r-ob-cr.i full  "''"               f-cost-sum }
      { rep/r-ob-cr.i full  "''"               f-cost-vat }
      { rep/r-ob-cr.i full  "''"               f-cost-sum-novat}
      { rep/r-ob-cr.i full  "''"               f-sale-vat }
      { rep/r-ob-cr.i full  "''"               f-sale-slt }
      { rep/r-ob-cr.i full  "''"               f-sale-other}
      { rep/r-ob-cr.i full  "''"               f-disc }
      { rep/r-ob-cr.i full  "''"               f-disc-prc}
      { rep/r-ob-cr.i full  "''"               f-qnty     }
  Display stream OutStream no-error .
  DOWN stream OutStream .
      { rep/r-ob-cr.i sfull f-crsa-sum }
      { rep/r-ob-cr.i sfull f-sale-sum }
      { rep/r-ob-cr.i sfull f-cost-sum }
      { rep/r-ob-cr.i sfull f-cost-vat }
      { rep/r-ob-cr.i sfull f-cost-sum-novat}
      { rep/r-ob-cr.i sfull f-sale-vat }
      { rep/r-ob-cr.i sfull f-sale-slt }
      { rep/r-ob-cr.i sfull f-sale-other}
      { rep/r-ob-cr.i sfull f-disc }
      { rep/r-ob-cr.i sfull f-disc-prc}
      { rep/r-ob-cr.i sfull f-qnty     }
      End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type and
          (
          ub.ot-line.sum-type    = string({2}) + String({3})
          OR
          ub.ot-line.sum-type    =
           &if {2} = {&arh-sale} &then {&arh-sale-service} + String({3})
                                 &else {&arh-cost-service}
                                 &endif
          )
          no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
          &if '{6}' = 'gds-list'  &then
          , First gds-list where  ub.ot-line.prod-type = gds-list.prod-type and
                                  ub.ot-line.prod-code = gds-list.prod-code and
                                  ub.ot-line.artic     = gds-list.artic no-lock
            &Endif
            break
                by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif
                by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic

                with FRAME Zapas :


            accumulate ub.ot-line.fact-qnty     (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.sum-{5}       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.vat-{5}       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.slt-{5}       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.other-{5}     (TOTAL by  ub.ot-line.artic ) .


      /* По ставкам */
      if first-of(&if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) then DO:
       for each wt share-lock : delete wt. end.
                  if  Itog = false Then do:
                      f-artic  =  &if {4} = 1 &then  "Ставка НДС"  &else  "Ставка НсП" &endif  .
                      f-gds-name = &if {4} = 0 &then   ub.ot-line.cat-id + '%' &else entry({4},ub.ot-line.cat-id) + '%' &endif .
                      { rep/r-ob-cr.i disp  f-artic   f-artic}
                      { rep/r-ob-cr.i disp  f-gds-name     f-gds-name}
                       Display stream OutStream .
                       DOWN stream OutStream .

                       {&PutExcel}
                              &if {4} = 1 &then  "Ставка НДС"  &else  "Ставка НсП" &endif                 {&tabulation}
                              &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif + "%"  {&new-line} .
                  End.
      End.

      Create WT.
      Assign WT.doc-code = ub.ot-line.doc-code.


      if last-of(ub.ot-line.artic) then DO:
                n-nm = n-nm + 1.
                { rep/repfrm.i disp  n-nm reportname objname }
                find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                        ub.ot-line.prod-code = goods.prod-code and
                                        ub.ot-line.artic     = goods.artic no-lock no-error .

                /*по артиклу и по текущему cat-id*/
               f-qnty       = accum  TOTAL by  ub.ot-line.artic ub.ot-line.fact-qnty  .
               &if {2} = {&arh-cost} OR {2} = {&arh-cost-service}  &then
               f-cost-sum   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.sum-{5}   .
               f-cost-vat   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.vat-{5}   .
               &else
               f-sale-sum   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.sum-{5}   .
               f-sale-vat   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.vat-{5}   .
               f-sale-slt   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.slt-{5}   .
               f-sale-other = accum  TOTAL by  ub.ot-line.artic ub.ot-line.other-{5} .
               &Endif
                f-crsa-sum = 0.
                For each crsa-ot-line where
                    crsa-ot-line.fact-order >= fact-order-1 and
                    crsa-ot-line.fact-order <= fact-order-2 and
                    crsa-ot-line.obj-code    = ub.ot-line.obj-code and
                    crsa-ot-line.obj-type    = ub.ot-line.obj-type and
                    crsa-ot-line.prod-type   = ub.ot-line.prod-type and
                    crsa-ot-line.prod-code   = ub.ot-line.prod-code and
                    crsa-ot-line.artic       = ub.ot-line.artic and
                    (crsa-ot-line.sum-type    = {&arh-crsa} OR
                    crsa-ot-line.sum-type    = {&arh-crsa-service} )
                    no-lock ,
                       First buf-tdedt where  buf-tdedt.id = crsa-ot-line.ext-doc-type  no-lock,
                       first wt where wt.doc-code = crsa-ot-line.doc-code
                    no-lock :
                  f-crsa-sum   = f-crsa-sum + crsa-ot-line.sum-{5}   .
                End.
                &if {2} = {&arh-sale} OR {2} = {&arh-sale-service} &then
                f-cost-sum   = 0 .
                f-cost-vat   = 0 .
                &else
                f-sale-sum   = 0 .
                f-sale-vat   = 0 .
                f-sale-slt   = 0 .
                f-sale-other = 0 .
                &Endif

                For each alt-ot-line where
                    alt-ot-line.fact-order >= fact-order-1 and
                    alt-ot-line.fact-order <= fact-order-2 and
                    alt-ot-line.obj-code    = ub.ot-line.obj-code and
                    alt-ot-line.obj-type    = ub.ot-line.obj-type and
                    alt-ot-line.prod-type   = ub.ot-line.prod-type and
                    alt-ot-line.prod-code   = ub.ot-line.prod-code and
                    alt-ot-line.artic       = ub.ot-line.artic and
                    alt-ot-line.sum-type    = &If {3} = '' &then {&arh-cost} &else  {&arh-sale} &endif
                    no-lock ,
                       First buf-tdedt where alt-ot-line.ext-doc-type   = buf-tdedt.id  no-lock,
                       first wt where wt.doc-code = alt-ot-line.doc-code
                    no-lock :
                      &if {2} = {&arh-sale} OR {2} = {&arh-sale-service} &then
                      f-cost-sum   = f-cost-sum + alt-ot-line.sum-{5}   .
                      f-cost-vat   = f-cost-vat + alt-ot-line.vat-{5}   .
                      &else
                      f-sale-sum   = f-sale-sum    + alt-ot-line.sum-{5}   .
                      f-sale-vat   = f-sale-vat    + alt-ot-line.vat-{5}   .
                      f-sale-slt   = f-sale-slt    + alt-ot-line.slt-{5}   .
                      f-sale-other = f-sale-other  + alt-ot-line.other-{5} .
                      &Endif
                    End.

                f-cost-sum-novat = f-cost-sum - f-cost-vat .
                f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
                f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .

              if itog = false
                 AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                 Then DO:
                 n-nn = n-nn + 1.
                  { rep/r-ob-cr.i disp       string(n-nn)       nn  }
                  { rep/r-ob-cr.i disp       ub.ot-line.artic      f-artic}
                  { rep/r-ob-cr.i disp       goods.gds-name     f-gds-name}
                  { rep/r-ob-cr.i disp       f-qnty             f-qnty     }
                  { rep/r-ob-cr.i disp       f-crsa-sum         f-crsa-sum }
                  { rep/r-ob-cr.i disp       f-sale-sum         f-sale-sum }
                  { rep/r-ob-cr.i disp       f-cost-sum         f-cost-sum }
                  { rep/r-ob-cr.i disp       f-cost-vat         f-cost-vat }
                  { rep/r-ob-cr.i disp       f-cost-sum-novat   f-cost-sum-novat}
                  { rep/r-ob-cr.i disp       f-sale-vat         f-sale-vat }
                  { rep/r-ob-cr.i disp       f-sale-slt         f-sale-slt }
                  { rep/r-ob-cr.i disp       f-sale-other       f-sale-other}
                  { rep/r-ob-cr.i disp       f-disc             f-disc     }
                  { rep/r-ob-cr.i disp       f-disc-prc         f-disc-prc }
                  display stream OutStream  no-error .
                  DOWN stream OutStream .
                  {&putexcel}
                        string(n-nn)     {&Tabulation}
                        (ub.ot-line.artic)    {&Tabulation}
                        goods.gds-name   {&Tabulation}
                        excel-qnty(f-qnty        )   {&Tabulation}
                        excel-sum (f-cost-sum     )  {&Tabulation}
                        excel-sum (f-cost-vat     )  {&Tabulation}
                        excel-sum (f-cost-sum-novat) {&Tabulation}
                        excel-sum (f-sale-sum      ) {&Tabulation}
                        excel-sum (f-sale-other    ) {&Tabulation}
                        excel-sum (f-sale-vat      ) {&Tabulation}
                        excel-sum (f-sale-slt      ) {&Tabulation}
                        excel-sum (f-disc          ) {&Tabulation}
                        excel-sum (f-disc-prc      ) {&Tabulation}
                        excel-sum(f-crsa-sum     )  {&new-line}.

                    End.
            accumulate f-qnty           (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-crsa-sum       (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-sale-sum       (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-cost-sum       (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-cost-vat       (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-sale-vat       (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-sale-slt       (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-sale-other     (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-disc           (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
            accumulate f-cost-sum-novat (TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) .
           End. /* if last of artic */

           if last-of(&if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif) then do:
                    f-artic    = &if {4} = 1 &then  "по ставке НДС"  &else  "по ставке НсП" &endif            .
                    f-gds-name = &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif  + "%" .
                       tf-qnty          =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-qnty          .
                       tf-crsa-sum      =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-crsa-sum      .
                       tf-sale-sum      =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-sum      .
                       tf-cost-sum      =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-cost-sum      .
                       tf-cost-vat      =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-cost-vat      .
                       tf-cost-sum-novat=accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-cost-sum-novat.
                       tf-sale-vat     =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-vat      .
                       tf-sale-slt      =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-slt      .
                       tf-sale-other    =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-other    .
                       tf-disc          =accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-disc          .

                    { rep/r-ob-cr.i disp    "'Итого'"    nn                       }
                    { rep/r-ob-cr.i disp    f-artic     f-artic                   }
                    { rep/r-ob-cr.i disp    f-gds-name  f-gds-name                }
                    { rep/r-ob-cr.i disp    tf-qnty              f-qnty           }
                    { rep/r-ob-cr.i disp    tf-crsa-sum          f-crsa-sum       }
                    { rep/r-ob-cr.i disp    tf-sale-sum          f-sale-sum       }
                    { rep/r-ob-cr.i disp    tf-cost-sum          f-cost-sum       }
                    { rep/r-ob-cr.i disp    tf-cost-vat          f-cost-vat       }
                    { rep/r-ob-cr.i disp    tf-cost-sum-novat    f-cost-sum-novat}
                    { rep/r-ob-cr.i disp    tf-sale-vat          f-sale-vat      }
                    { rep/r-ob-cr.i disp    tf-sale-slt          f-sale-slt      }
                    { rep/r-ob-cr.i disp    tf-sale-other        f-sale-other    }
                    { rep/r-ob-cr.i disp    tf-disc              f-disc          }
                    Display stream OutStream  no-error  .
                    DOWN stream OutStream .

                        {&putexcel}                                                                                                       {&tabulation}
                        "Итого"                                                                                                       {&tabulation}
                        &if {4} = 1 &then  "по ставке НДС"  &else  "по ставке НсП" &endif                                             {&tabulation}
                        &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif  + "%"                             {&tabulation}
                        excel-qnty(accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-qnty          )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-cost-sum      )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-cost-vat      )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-cost-sum-novat)  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-sum      )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-other    )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-vat      )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-sale-slt      )  {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-disc          )  {&tabulation} {&tabulation}
                        excel-sum (accum TOTAL  by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif f-crsa-sum      )  {&new-line}.

                      Assign
                       ff-qnty           = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-qnty
                       ff-crsa-sum       = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-crsa-sum
                       ff-sale-sum       = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-sale-sum
                       ff-cost-sum       = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-cost-sum
                       ff-cost-vat       = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-cost-vat
                       ff-cost-sum-novat = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-cost-sum-novat
                       ff-sale-vat       = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-sale-vat
                       ff-sale-slt       = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-sale-slt
                       ff-sale-other     = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-sale-other
                       ff-disc           = accum TOTAL by  &if {4} = 0 &then   ub.ot-line.cat-id  &else entry({4},ub.ot-line.cat-id) &endif   f-disc
                       .
              accumulate ff-qnty           (TOTAL by obj-list.obj-code) .
              accumulate ff-crsa-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-slt       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-other     (TOTAL by obj-list.obj-code) .
              accumulate ff-disc           (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum-novat (TOTAL by obj-list.obj-code) .

            End.
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .

 End.
   run u-line.
  { rep/r-ob-cr.i disp  "'ИТОГО'"                        nn                                    }
  { rep/r-ob-cr.i disp  "'по объекту'"                   f-artic                               }
  { rep/r-ob-cr.i disp  obj-list.obj-name               f-gds-name                             }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-qnty     "        f-qnty          }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-crsa-sum "        f-crsa-sum      }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-sale-sum "        f-sale-sum      }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-cost-sum "        f-cost-sum      }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-cost-vat "        f-cost-vat      }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-cost-sum-novat"   f-cost-sum-novat}
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-sale-vat      "   f-sale-vat      }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-sale-slt      "   f-sale-slt      }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-sale-other    "   f-sale-other    }
  { rep/r-ob-cr.i disp  "accum TOTAL by obj-list.obj-code ff-disc          "   f-disc          }

  Display stream OutStream no-error .
  DOWN stream OutStream .
  run u-line.
  {&putexcel}
          "ИТОГО"                                             {&tabulation}
          "по объекту"                                        {&tabulation}
          obj-list.obj-name                                   {&tabulation}
          excel-qnty(accum TOTAL by obj-list.obj-code ff-qnty          )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum      )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-vat      )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum-novat)  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-sum      )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-other    )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-vat      )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-slt      )  {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-disc          )  {&tabulation}   {&tabulation}
          excel-sum (accum TOTAL by obj-list.obj-code ff-crsa-sum      )  {&new-line}.

End.
 if n-no > 1 then do:
  { rep/r-ob-cr.i disp         "'ИТОГО'"                          nn             }
  { rep/r-ob-cr.i disp         "'ПО ВСЕМ ОБЬЕКТАМ'"               f-artic        }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-qnty"             f-qnty         }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-crsa-sum"         f-crsa-sum     }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-sale-sum"         f-sale-sum     }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-cost-sum"         f-cost-sum     }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-cost-vat"         f-cost-vat     }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-cost-sum-novat"   f-cost-sum-novat }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-sale-vat"         f-sale-vat     }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-sale-slt"         f-sale-slt     }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-sale-other"       f-sale-other   }
  { rep/r-ob-cr.i disp         "accum TOTAL  ff-disc"             f-disc         }
  Display stream OutStream
          with FRAME Zapas no-error .
          DOWN stream OutStream with FRAME Zapas.
          {&putexcel}
          "ИТОГО"                            {&tabulation}
          "ПО ВСЕМ ОБЬЕКТАМ"                 {&tabulation}
          excel-qnty(accum TOTAL  ff-qnty            )   {&tabulation}
          excel-sum (accum TOTAL  ff-cost-sum        )   {&tabulation}
          excel-sum (accum TOTAL  ff-cost-vat        )   {&tabulation}
          excel-sum (accum TOTAL  ff-cost-sum-novat  )   {&tabulation}
          excel-sum (accum TOTAL  ff-sale-sum        )   {&tabulation}
          excel-sum (accum TOTAL  ff-sale-other      )   {&tabulation}
          excel-sum (accum TOTAL  ff-sale-vat        )   {&tabulation}
          excel-sum (accum TOTAL  ff-sale-slt        )   {&tabulation}
          excel-sum (accum TOTAL  ff-disc            )   {&tabulation} {&tabulation}
          excel-sum (accum TOTAL  ff-crsa-sum        )   {&new-line}.
         run u-line.
  End.
&endif
/* $Workfile$ e n d */