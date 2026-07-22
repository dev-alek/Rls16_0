/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

внутренности Foreach для отчета по признакам

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".
&if "{1}" <> "Display"  &then
n-nn = 0.
n-no = n-no + 1 .
 For Each temp-goods  no-lock
            break
                &if "{1}" = "no-classify" &then
                by ( temp-goods.artic + temp-goods.prod-type + string ( temp-goods.prod-code ))
                by temp-goods.prod-type By temp-goods.prod-code by temp-goods.artic
                &endif
                &if "{1}" = "prod-code" &then
                by temp-goods.cli  by ( temp-goods.artic + temp-goods.prod-type + string ( temp-goods.prod-code ))
                by temp-goods.artic
                &endif
                &if "{1}" = "grp-goods" &then
                by temp-goods.grp-name by ( temp-goods.artic + temp-goods.prod-type + string ( temp-goods.prod-code ))
                by temp-goods.artic
                &endif
                &if "{1}" = "VAT-pc" &then
                by temp-goods.vat-pc by ( temp-goods.artic + temp-goods.prod-type + string ( temp-goods.prod-code ))
                by temp-goods.artic
                &endif
                 with FRAME Zapas :

              IF first-of(temp-goods.artic) then DO:

                assign
                  f-qnty       = 0
                  f-cost-sum   = 0
                  f-sale-sum   = 0
                  f-sale-other = 0
                  .

            End.

&if "{1}" = "prod-code"  &then
/* По производителю----------- */
          if first-of(temp-goods.cli) then DO:

             var-client = temp-goods.cli.
             if  Itog = false Then do:
               {&PutExcel} var-client {&new-line} .
             End.
          End.
/*----------------------------*/
&endif
&if "{1}" = "grp-goods" &then
/* По производителю----------- */
          if first-of(temp-goods.grp-name) then  DO:
             var-client = temp-goods.grp-name.
             if  Itog = false Then do:
               {&PutExcel} temp-goods.grp-name {&new-line} .
             End.
          End.
/*----------------------------*/
&endif
&if "{1}" = "VAT-pc" &then
/* По производителю----------- */
          if first-of(temp-goods.VAT-pc) then DO:
             var-client = string(temp-goods.VAT-pc) + '%'.
                  if  Itog = false Then do:
                    {&PutExcel} 'Ставка НДС ' + string(temp-goods.VAT-pc) + '%' {&new-line} .
                  End.
          End.
/*--------------------------------------------------------------------------------------------------------------------*/
&endif
          if last-of(temp-goods.artic) then DO:
             n-nm = n-nm + 1.
             { rep/r-mess.i n-nm 50 }
 /* по объект  1 */
            n-nn = n-nn + 1 .
            if itog = false  Then DO:
                { gbl/gdsbcode.i temp-goods.gds-code ? v-bar-code  }
                {&PutExcel}
                    string(n-nn)                      {&tabulation}
                    v-bar-code                        {&tabulation}
                    format-excel-text(temp-goods.artic)    {&tabulation}
                    temp-goods.gds-name                    {&tabulation}
                                                      {&tabulation}
                                                      .
            End.

            For each obj-list no-lock :
                Assign
                  f-qnty       = 0
                  f-cost-sum   = 0
                  f-sale-sum   = 0
                  f-sale-other = 0
                .

                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = temp-goods.artic     and
                    ub.gds-obj.prod-type = temp-goods.prod-type and
                    ub.gds-obj.prod-code = temp-goods.prod-code and
                    ub.gds-obj.obj-code  = obj-list.obj-code and
                    ub.gds-obj.obj-type  = obj-list.obj-type    :
                    Assign
                    f-qnty       = f-qnty     + ub.gds-obj.fact-qnty
                    f-cost-sum   = f-cost-sum + determined(ub.gds-obj.fact-{5})
                    f-sale-sum   = f-sale-sum + ub.gds-obj.fact-sale
                    .
                End.  /* ub.gds-obj */
                f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
                    if itog = false
                        Then DO:
                            {&PutExcel}
                            excel-qnty(f-qnty        )        {&tabulation}
                            if p-cost then ( excel-sum (f-cost-sum    )    +    {&tabulation} ) else ""
                            if p-sale then ( excel-sum (f-sale-sum    )    +    {&tabulation} ) else ""
                            if p-dis  then ( excel-sum (f-sale-other  )    +    {&tabulation} ) else ""
                            .
                    End. /* if itog false */


             find first Temp-i where Temp-i.obj-code  = obj-list.obj-code and
                                     Temp-i.obj-type  = obj-list.obj-type  no-error .
                  if not avail Temp-i Then  create Temp-i no-error .
                  assign
                    Temp-i.obj-code     = obj-list.obj-code
                    Temp-i.obj-type     = obj-list.obj-type
                    Temp-i.b-qnty       = Temp-i.b-qnty       + f-qnty
                    Temp-i.b-cost-sum   = Temp-i.b-cost-sum   + f-cost-sum
                    Temp-i.b-sale-sum   = Temp-i.b-sale-sum   + f-sale-sum
                    Temp-i.b-sale-other = Temp-i.b-sale-other + f-sale-other
                  .
             &if "{1}" <> "no-classify" &then
             find first Temp-b where Temp-b.obj-code  = obj-list.obj-code and
                                     Temp-b.obj-type  = obj-list.obj-type no-error .
                  if not avail Temp-b Then  create Temp-b no-error .
                  assign
                    Temp-b.grp          = STRING({2})
                    Temp-b.obj-code     = obj-list.obj-code
                    Temp-b.obj-type     = obj-list.obj-type
                    Temp-b.b-qnty       = Temp-b.b-qnty       + f-qnty
                    Temp-b.b-cost-sum   = Temp-b.b-cost-sum   + f-cost-sum
                    Temp-b.b-sale-sum   = Temp-b.b-sale-sum   + f-sale-sum
                    Temp-b.b-sale-other = Temp-b.b-sale-other + f-sale-other
                  .
            &endif

         end. /* OBJ-LIST */

             if  Itog = false Then do:
                 {&PutExcel}  {&new-line} .
             End.
             run display-prt in this-procedure  .
          End. /* if last-of artic */

&if "{1}" <> "no-classify" &then
          if last-of({2})  then do :
            f-artic = {3} .
              {&PutExcel}
              "Итого"                                             {&tabulation}
              {3}
              var-client                                          {&tabulation} {&tabulation} {&tabulation} {&tabulation}
              .
              for each obj-list no-lock :
                   find first Temp-b where Temp-b.obj-code  = obj-list.obj-code and
                                           Temp-b.obj-type  = obj-list.obj-type and
                                           Temp-b.grp          = STRING({2})    no-lock  no-error .
                    if avail  Temp-b then do:
                        {&PutExcel}
                        excel-qnty(Temp-b.b-qnty           )   {&tabulation}
                        if p-cost then ( excel-sum (Temp-b.b-cost-sum       ) +  {&tabulation} ) else ""
                        if p-sale then ( excel-sum (Temp-b.b-sale-sum       ) +  {&tabulation} ) else ""
                        if p-dis  then ( excel-sum (Temp-b.b-sale-other     ) +  {&tabulation} ) else ""
                        .
                    end.
                    Else do:
                        {&PutExcel}
                        0 {&tabulation}
                        if p-cost then (  {&tabulation} ) else ""
                        if p-sale then (  {&tabulation} ) else ""
                        if p-dis  then (  {&tabulation} ) else ""
                        .
                    end.
                    find current  Temp-b .
                    assign
                          Temp-b.b-qnty       = 0
                          Temp-b.b-cost-sum   = 0
                          Temp-b.b-sale-sum   = 0
                          Temp-b.b-sale-other = 0
                          .

              End.
              {&PutExcel} {&new-line} .
          End.  /*if last prod-code */

&endif

 End. /*for each temp-goods */
  {&PutExcel}
          "ИТОГО"                           {&tabulation}
          "по объектам"                     {&tabulation}
                      {&tabulation}
                      {&tabulation}
                      {&tabulation}
              .
              for each obj-list no-lock :
                   find first Temp-i where Temp-i.obj-code  = obj-list.obj-code and
                                           Temp-i.obj-type  = obj-list.obj-type no-lock  no-error .
                    if not avail Temp-i Then  create Temp-i no-error .
                    assign
                      Temp-i.obj-code     = obj-list.obj-code
                      Temp-i.obj-type     = obj-list.obj-type
                      .

                    {&PutExcel}
                    excel-qnty(Temp-i.b-qnty           )   {&tabulation}
                   if p-cost then ( excel-sum (Temp-i.b-cost-sum       ) +  {&tabulation} ) else ""
                   if p-sale then ( excel-sum (Temp-i.b-sale-sum       ) +  {&tabulation} ) else ""
                   if p-dis  then ( excel-sum (Temp-i.b-sale-other     ) +  {&tabulation} ) else ""
                    .
              End.

          {&PutExcel} {&new-line} .
&else

/* Procedure Display-prt */
/* а есть ли у него шкала ? */


IF temp-goods.prt-root <> Prtroot Then DO:
    for each ub.gds-prt no-lock where
        ub.gds-prt.prt-root = temp-goods.prt-root and
        ub.gds-prt.IS-term   =  true
        by ub.gds-prt.f-name with FRAME Zapas :

      /* по объект  1 */
             pp = 0 .
            { gbl/gdsbcode.i temp-goods.gds-code ub.gds-prt.node-code v-bar-code  }
            For each obj-list no-lock :
                Assign
                  p-qnty      =  0
                  p-cost-sum  =  0
                  p-sale-sum  =  0
                  p-sale-other=  0
                  .

                for each ub.prt-obj no-lock where
                    ub.prt-obj.artic     = temp-goods.artic     and
                    ub.prt-obj.prod-type = temp-goods.prod-type and
                    ub.prt-obj.prod-code = temp-goods.prod-code and
                    ub.prt-obj.obj-code  = obj-list.obj-code and
                    ub.prt-obj.obj-type  = obj-list.obj-type and
                    ub.prt-obj.IS-term   =  true and
                    ub.prt-obj.prt-code  = ub.gds-prt.node-code :
                    Assign
                      p-qnty      = p-qnty       + ub.prt-obj.fact-qnty
                      p-sale-sum  = p-sale-sum   + ub.prt-obj.fact-qnty * ub.prt-obj.price-sale .

                End.
                Assign
                  p-cost-sum     = determined( f-cost-sum * p-qnty  / f-qnty)
                  p-sale-other   = 100 * determined((p-sale-sum - p-cost-sum) / p-cost-sum)
                  .
                create temp-gds-prt.
                assign temp-gds-prt.v-p-qnty       = p-qnty
                        temp-gds-prt.v-p-cost-sum   = p-cost-sum
                        temp-gds-prt.v-p-sale-sum   = p-sale-sum
                        temp-gds-prt.v-p-sale-other = p-sale-other
                        temp-gds-prt.obj-code = obj-list.obj-code
                        temp-gds-prt.obj-type = obj-list.obj-type
                        .

            End.
            /* проверим на нолики */
            pp = 0.
            for each obj-list no-lock ,
                each temp-gds-prt where temp-gds-prt.obj-code = obj-list.obj-code and
                                        temp-gds-prt.obj-type = obj-list.obj-type no-lock  :
                  if not (
                  temp-gds-prt.v-p-qnty      =  0 and
                  temp-gds-prt.v-p-cost-sum  =  0 and
                  temp-gds-prt.v-p-sale-sum  =  0 and
                  temp-gds-prt.v-p-sale-other=  0   ) then do:
                     pp = 1.
                     leave.
                     end.
            End.

              if pp = 1 then do :
                {&PutExcel}
                    /*  string(n-nn) */           {&tabulation}
                      v-bar-code                  {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
                      ub.gds-prt.f-name              {&tabulation}
                      .
                  for each obj-list no-lock :
                      find first temp-gds-prt where temp-gds-prt.obj-code = obj-list.obj-code and
                                                    temp-gds-prt.obj-type = obj-list.obj-type no-lock  no-error .
                      if avail temp-gds-prt then do:
                      {&PutExcel}
                        excel-qnty(temp-gds-prt.v-p-qnty        )   {&tabulation}
                        if p-cost then ( excel-sum (temp-gds-prt.v-p-cost-sum    ) +  {&tabulation}) else ""
                        if p-sale then ( excel-sum (temp-gds-prt.v-p-sale-sum    ) +  {&tabulation}) else ""
                        if p-dis  then ( excel-sum (temp-gds-prt.v-p-sale-other  ) +  {&tabulation}) else ""
                        .
                      End.
                  End.
                  if  Itog = false Then do:
                      {&PutExcel} {&new-line} .
                      End.
              End . /* if */
              for each temp-gds-prt : delete temp-gds-prt. end.
    End.
End.
&endif
/* $Workfile$ e n d */