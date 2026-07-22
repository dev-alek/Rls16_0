/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

внутренности Foreach для отчета по признакам обход по gds-obj

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
  for each obj-list no-lock with FRAME Zapas :
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

          n-nn = 0.
          n-no = n-no + 1 .

for each tt-season no-lock ,
    each ub.gds-season no-lock where
         ub.gds-season.db-num   = tt-season.db-num and
         ub.gds-season.sea-code = tt-season.sea-code ,
    each gds-obj where
          gds-obj.gds-code    = ub.gds-season.gds-code and
          gds-obj.obj-code    = obj-list.obj-code and
          gds-obj.obj-type    = obj-list.obj-type
          {&ver-last-doc}
          no-lock,
          first goods where   gds-obj.gds-code  = goods.gds-code and
                              goods.gds-type    = {&gds-goods}
                              no-lock
          &if '{6}' = 'gds-list'  &then
          , First gds-list where  gds-obj.prod-type = gds-list.prod-type and
                                  gds-obj.prod-code = gds-list.prod-code and
                                  gds-obj.artic     = gds-list.artic no-lock
            &Endif

            break
                by goods.grp-name
                by ub.gds-season.db-num
                by ub.gds-season.sea-code
                by ub.gds-season.gds-code
                with FRAME Zapas :

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

              For Each ub.ot-line where
                        ub.ot-line.fact-order <= fact-order-2 and
                        ub.ot-line.fact-order >= fact-order-1 and
                        ub.ot-line.obj-code    = obj-list.obj-code and
                        ub.ot-line.obj-type    = obj-list.obj-type  and
                        ub.ot-line.artic     = gds-obj.artic  and
                        ub.ot-line.prod-type = gds-obj.prod-type and
                        ub.ot-line.prod-code = gds-obj.prod-code and
                        (ub.ot-line.sum-type = {&arh-sale} OR
                          ub.ot-line.sum-type = {&arh-crsa} OR
                          ub.ot-line.sum-type = {&arh-cost} ) no-lock :

                    run in-proc.

              End. /*for each ub.ot-line */
            End.
          if first-of({2}) then  DO:
             var-client = goods.grp-name.
              PUT stream OutStream  goods.grp-name  AT 1 format "X(160)" SKIP.
              DOWN stream OutStream .
              {&PutExcel} goods.grp-name {&new-line} .
          End.

          if first-of(ub.gds-season.sea-code) then  DO:
            var-client = tt-season.sea-name.
                  if  Itog = false Then do:
                    PUT stream OutStream  tt-season.sea-name  AT 10 format "X(160)" SKIP. DOWN stream OutStream .
                    {&PutExcel} {&tabulation} tt-season.sea-name {&new-line} .
                  End.
          End.



          if last-of(ub.gds-season.gds-code) then DO:
          run last-of-artic.
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

              accumulate f-qnty           (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-cost-sum       (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-sale-sum       (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-sale-other     (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-crsa-sum       (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-qnty-all       (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-cost-sum-all   (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-crsa-sum-all   (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-qnty-o         (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-cost-sum-o     (TOTAL  by ub.gds-season.sea-code ) .
              accumulate f-crsa-sum-o     (TOTAL  by ub.gds-season.sea-code ) .


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

          if last-of(ub.gds-season.sea-code)  then do :
            if itog = false then run u-line in this-procedure.
            f-artic = "коллекция" .
            { rep/r-ob-cr.i disp    "'Итого'"    nn }
            { rep/r-ob-cr.i disp    f-artic         f-artic }
            { rep/r-ob-cr.i disp    var-client   f-gds-name  }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-qnty    "         f-qnty        }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-cost-sum "        f-cost-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-sale-sum"         f-sale-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-sale-other"       f-sale-other  }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-crsa-sum"         f-crsa-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-qnty-all"         f-qnty-all    }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-cost-sum-all"     f-cost-sum-all}
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-crsa-sum-all"     f-crsa-sum-all}
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-qnty-o"           f-qnty-o      }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-cost-sum-o"       f-cost-sum-o  }
            { rep/r-ob-cr.i disp    "accum TOTAL by  ub.gds-season.sea-code  f-crsa-sum-o"       f-crsa-sum-o  }

              Display stream OutStream  no-error .
              DOWN stream OutStream .
              {&PutExcel}
              "Итого"                                              {&tabulation}
              {3}                                                   {&tabulation}
              var-client                                           {&tabulation} {&tabulation}
              excel-qnty(accum TOTAL by ub.gds-season.sea-code  f-qnty           )    {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-cost-sum       )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-sale-sum       )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-sale-other     )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-crsa-sum       )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-qnty-all       )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-cost-sum-all   )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-crsa-sum-all   )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-qnty-o         )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-cost-sum-o     )   {&tabulation}
              excel-sum (accum TOTAL by ub.gds-season.sea-code  f-crsa-sum-o     )   {&new-line} .
          End.  /*if last prod-code */


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
              {3}
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


End. /* for each gds-obj */
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
          "по объекту"                    {&tabulation}
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
         "ПО ВСЕМ ОБЬЕКТАМ"            {&tabulation}
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
/* $Workfile$ e n d */