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
{5 = 1}
*/
define variable pr-cursor as integer no-undo init 0.
define variable go-work   as logical no-undo init no.
define variable v-tmp-prt like gds-prt.node-code init -1.

&if "{1}" <> "Display"  &then
  for each obj-list no-lock with frame zapas :
    if not( classify = 1 and itog = true) then do:
      { rep/r-ob-cr.i disp  obj-list.obj-name  f-gds-name}
      { rep/r-ob-cr.i full  "''"   f-qnty       }
      { rep/r-ob-cr.i full  "''"   f-cost-pr    }
      { rep/r-ob-cr.i full  "''"   f-cost-sum   }
      { rep/r-ob-cr.i full  "''"   f-sale-pr    }
      { rep/r-ob-cr.i full  "''"   f-sale-sum   }
      { rep/r-ob-cr.i full  "''"   f-sale-other }
      { rep/r-ob-cr.i full  "''"   f-free-qnty  }
      { rep/r-ob-cr.i full  "''"   f-wait-qnty  }
      { rep/r-ob-cr.i full  "''"   f-rez-qnty    }
      { rep/r-ob-cr.i full  "''"   f-rez-cost    }
      { rep/r-ob-cr.i full  "''"   f-rez-sale    }
      { rep/r-ob-cr.i full  "''"   f-rez-cost-pr }

  display stream outstream no-error .
  down stream outstream .
      { rep/r-ob-cr.i sfull f-qnty        }
      { rep/r-ob-cr.i sfull f-cost-pr     }
      { rep/r-ob-cr.i sfull f-cost-sum    }
      { rep/r-ob-cr.i sfull f-sale-pr     }
      { rep/r-ob-cr.i sfull f-sale-sum    }
      { rep/r-ob-cr.i sfull f-sale-other  }
      { rep/r-ob-cr.i sfull f-free-qnty   }
      { rep/r-ob-cr.i sfull f-wait-qnty   }
      { rep/r-ob-cr.i sfull f-rez-qnty    }
      { rep/r-ob-cr.i sfull f-rez-cost    }
      { rep/r-ob-cr.i sfull f-rez-sale    }

   {&PutExcel}  obj-list.obj-name {&new-line}.
  end.
          n-nn = 0.
          n-no = n-no + 1 .
&if "{1}" = "vat-pc" &then
    &if '{6}' = 'gds-list' &then
    For Each gds-list no-lock :
      assign
        gds-list.qnty = func-vat ( input gds-list.gds-code , input obj-list.obj-type, input obj-list.obj-code)
      .
    end.
    &else
    For Each gds-obj no-lock  where
          gds-obj.obj-code    = obj-list.obj-code and
          gds-obj.obj-type    = obj-list.obj-type,
          first goods no-lock where
                goods.prod-type = gds-obj.prod-type and
                goods.prod-code = gds-obj.prod-code and
                goods.artic     = gds-obj.artic
                :
      find first gds-list where gds-list.gds-code = gds-obj.gds-code  no-error .
      if not available  gds-list then create gds-list .
      buffer-copy goods to gds-list
      assign
        gds-list.qnty = func-vat ( input gds-obj.gds-code , input gds-obj.obj-type, input gds-obj.obj-code)
      .
    end.
&endif


&endif.
 For Each gds-obj where
          gds-obj.obj-code    = obj-list.obj-code and
          gds-obj.obj-type    = obj-list.obj-type
          no-lock,
          first goods where
                goods.prod-type = gds-obj.prod-type and
                goods.prod-code = gds-obj.prod-code and
                goods.artic     = gds-obj.artic  and
                goods.gds-type    = {&gds-goods}
                              no-lock
           &if "{1}" = "VAT-pc" or '{6}' = 'gds-list'  &then
          , first gds-list where
                  gds-list.prod-type =  gds-obj.prod-type and
                  gds-list.prod-code =  gds-obj.prod-code and
                  gds-list.artic     =  gds-obj.artic
                  no-lock
            &endif
            break
                &if "{1}" = "no-classify" &then
                by ( gds-obj.artic + gds-obj.prod-type + string ( gds-obj.prod-code ))
                by gds-obj.prod-type By gds-obj.prod-code by gds-obj.artic
                &endif
                &if "{1}" = "prod-code" &then
                by gds-obj.prod-type By gds-obj.prod-code by gds-obj.artic
                &endif
                &if "{1}" = "grp-goods" &then
                by goods.grp-name by ( gds-obj.artic + gds-obj.prod-type + string ( gds-obj.prod-code ))
                by gds-obj.artic
                &endif
                &if "{1}" = "VAT-pc" &then
                by gds-list.qnty
                by ( gds-obj.artic + gds-obj.prod-type + string ( gds-obj.prod-code ))
                by gds-obj.artic
                &endif
                with FRAME Zapas :
                     pr-cursor = 0.
                     go-work = false.
                     if v-prizn = "" then do:
                        go-work = true.
                     end.
                     else do:
                          if goods.prt-root <> Prtroot then
                          do while pr-cursor < num-entries(v-prizn,","):
                          pr-cursor = pr-cursor + 1.
                              if entry(pr-cursor,v-prizn,",") <> "" then do:
                                  for first prt-obj where
                                  prt-obj.artic     = goods.artic     and
                                  prt-obj.prod-type = goods.prod-type and
                                  prt-obj.prod-code = goods.prod-code and
                                  prt-obj.obj-code  = obj-list.obj-code and
                                  prt-obj.obj-type  = obj-list.obj-type and
                                  prt-obj.is-term   =  true  and
                                  prt-obj.prt-code  = integer(entry(pr-cursor,v-prizn,","))
                                  no-lock:
                                      pr-cursor = num-entries(v-prizn,",").
                                      go-work = true.
                                      v-tmp-prt = integer(entry(pr-cursor,v-prizn,",")).
                                  end.
                              end.
                          end.
                      end.
                if go-work then do:
                n-nm = n-nm + 1.
                { rep/repfrm.i disp n-nm }
                IF first-of(gds-obj.artic) then DO:
                assign
                  f-qnty         = 0
                  f-cost-sum     = 0
                  f-sale-sum     = 0
                  f-cost-pr      = 0
                  f-sale-pr      = 0
                  f-sale-other   = 0
                  f-free-qnty    = 0
                  f-wait-qnty    = 0
                  f-rez-qnty     = 0
                  f-rez-cost     = 0
                  f-rez-sale     = 0
                  f-rez-cost-pr  = 0
                  tot-v-sale-sum = 0
                  tot-v-cost-sum = 0
                  .
                End.

&if "{1}" = "prod-code"  &then
/* По производителю----------- */
          if first-of(gds-obj.prod-code)  and classify = 2 then DO:
              FIND FIRST clients-p where  gds-obj.prod-type = clients-p.obj-type AND
                                          gds-obj.prod-code = clients-p.obj-code no-lock no-error.
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
          if first-of(goods.grp-name) then  DO:
             var-client = goods.grp-name.
                  if  Itog = false Then do:
                    PUT stream OutStream  goods.grp-name  AT 1 format "X(160)" SKIP.
                    DOWN stream OutStream .
                    {&PutExcel} goods.grp-name {&new-line} .
                  End.
          End.
/*----------------------------*/
&endif
&if "{1}" = "VAT-pc" &then
/* По НДС ----------- */
if first-of( gds-list.qnty ) then do:
  var-client = string(gds-list.qnty) + '%'.
  if  itog = false then do:
    { rep/r-ob-cr.i disp   "'Ставка НДС ' + string(gds-list.qnty) + '%'" f-gds-name}
    display stream outstream .
    down stream outstream .
    {&putexcel} 'Ставка НДС ' + string(gds-list.qnty) + '%' {&new-line} .
  end.
end.

/*--------------------------------------------------------------------------------------------------------------------*/
&endif
if last-of(gds-obj.artic) then DO:
  /* По товару ------------------------*/
 
 IF v-var = "no-today" then DO:
     
 
             /* На < сегодня */
               /* Продажная */
               RUN ost-line in this-procedure
               (
/*               input   v-tmp-prt         ,*/
                input   gds-obj.obj-code  ,
                input   gds-obj.obj-type  ,
                INPUT   gds-obj.artic     ,
                INPUT   gds-obj.prod-code ,
                INPUT   gds-obj.prod-type ,
                input   0                 ,
                INPUT   fact-order-2      ,
                input   {&arh-crsa}       ,
                input   {&root-cat-id}    ,
                input   yes               ,
                output  Quantity1         ,
                output  Coast_R1          ,
                output  Coast_V1          ,
                output  VAT_R1            ,
                output  VAT_V1            ,
                output  SLT_R1            ,
                output  SLT_V1            ).
             Assign
                f-qnty       = Quantity1
                f-sale-sum   = if tprintrubl then Coast_R1 else Coast_V1
                f-sale-pr    = if f-qnty = 0 then 0 else f-sale-sum / f-qnty
                .
               /* Учетная */
               RUN ost-line in this-procedure
               ( 
                input   gds-obj.obj-code  ,
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
                f-cost-sum   = if tprintrubl then Coast_R1 else Coast_V1
                f-cost-pr    = if Quantity1 = 0 then 0 else ( f-cost-sum / Quantity1 )
                .
               
end.
else do:
/*     На  сегодня*/
     if v-prizn <> "" and goods.prt-root <> Prtroot then do:
        pr-cursor = 0.
                 f-qnty = 0.
         do while pr-cursor < num-entries(v-prizn,","):
             pr-cursor = pr-cursor + 1.
/*           message pr-cursor view-as alert-box. */
             if entry(pr-cursor,v-prizn,",") <> "" then do:
                 for each prt-obj no-lock where prt-obj.prt-code = integer(entry(pr-cursor,v-prizn,","))
                 and prt-obj.artic = gds-obj.artic
                 and prt-obj.obj-code = gds-obj.obj-code
                 and prt-obj.obj-type = gds-obj.obj-type
                 and prt-obj.is-term   =  true
                 :
                 assign
                    f-qnty       =  f-qnty + prt-obj.fact-qnty
                    f-cost-sum   = f-cost-sum + if gds-obj.fact-qnty = 0 then 0 else prt-obj.fact-qnty * determined(gds-obj.fact-{5}) / gds-obj.fact-qnty
                    f-sale-sum   = f-sale-sum + if gds-obj.fact-qnty = 0 then 0 else prt-obj.fact-qnty * gds-obj.fact-sale / gds-obj.fact-qnty
                    f-free-qnty  = f-free-qnty + prt-obj.free-qnty
                    f-cost-pr   = if prt-obj.fact-qnty  = 0 then 0 else determined(gds-obj.fact-{5}) / gds-obj.fact-qnty
                    f-sale-pr   = if prt-obj.fact-qnty  = 0 then 0 else prt-obj.price-sale
                    .
                 end.
             end.
         end.
     end.
     else do:
         Assign
            f-qnty       = gds-obj.fact-qnty
            f-cost-sum   = determined(gds-obj.fact-{5})
            f-sale-sum   = gds-obj.fact-sale
            f-free-qnty  = gds-obj.free-qnty
            f-cost-pr   = if f-qnty = 0 then 0 else f-cost-sum / f-qnty
            f-sale-pr   = if f-qnty = 0 then 0 else f-sale-sum / f-qnty
          .
      end.
     end.         
              /* подсчет резерва */
              if c-f-rez-qnty     <> ? or
                 c-f-rez-cost     <> ? or
                 c-f-rez-sale     <> ? then do:
                 empty temp-table t-trn-doc .
                 empty temp-table temp_gds-dtl .
                      for each buf_parts no-lock where
                               buf_parts.artic      = gds-obj.artic       and
                               buf_parts.prod-type  = gds-obj.prod-type   and
                               buf_parts.prod-code  = gds-obj.prod-code   and
                               buf_parts.obj-type   = gds-obj.obj-type    and
                               buf_parts.obj-code   = gds-obj.obj-code    and
                               buf_parts.status_    = false               and
                               buf_parts.rsrv-free  = true    ,
                        first bufi_trn-doc no-lock where
                              bufi_trn-doc.doc-code = buf_parts.out-code
                              and
                            ( bufi_trn-doc.doc-type = {&expense} or
                              bufi_trn-doc.doc-type = {&write-off} )
                              :

                              if not can-find( first t-trn-doc where t-trn-doc.doc-code = bufi_trn-doc.doc-code) then do:
                                  create t-trn-doc.
                                  assign
                                  t-trn-doc.doc-code = bufi_trn-doc.doc-code .
                .
end.
                          end.

                          for each t-trn-doc :
                              for each  bufd_gds-dtl no-lock where
                                        bufd_gds-dtl.doc-code   = t-trn-doc.doc-code  and
                                        bufd_gds-dtl.artic      = gds-obj.artic       and
                                        bufd_gds-dtl.prod-type  = gds-obj.prod-type   and
                                        bufd_gds-dtl.prod-code  = gds-obj.prod-code ,
                                  first buff_doc-line no-lock where
                                        buff_doc-line.doc-code   = bufd_gds-dtl.doc-code  and
                                        buff_doc-line.artic      = bufd_gds-dtl.artic     and
                                        buff_doc-line.prod-type  = bufd_gds-dtl.prod-type and
                                        buff_doc-line.prod-code  = bufd_gds-dtl.prod-code
                                        :
                                        assign
                                          f-rez-qnty = f-rez-qnty  + bufd_gds-dtl.doc-qnty
                                          f-rez-cost = f-rez-cost  + ( bufd_gds-dtl.doc-qnty * buff_doc-line.price-{5} )
                                          f-rez-sale = f-rez-sale  + ( bufd_gds-dtl.doc-qnty * bufd_gds-dtl.price-{5} )
                                          f-rez-cost-pr = ( if f-rez-qnty = 0 then 0 else f-rez-cost / f-rez-qnty )
                                        .
                                        create temp_gds-dtl.
                                        buffer-copy bufd_gds-dtl to temp_gds-dtl
                                        assign
                                           temp_gds-dtl.cost-sum = bufd_gds-dtl.doc-qnty * buff_doc-line.price-{5}
                                           temp_gds-dtl.sale-sum = bufd_gds-dtl.doc-qnty * bufd_gds-dtl.price-{5}
                                        .
                              end.
                              
                         end.
                         
              end.

              f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
              /* ожидаемое */
              if c-f-wait-qnty <> ? Then DO :
                for each trn-doc no-lock  where
                    trn-doc.obj-code        = obj-list.obj-code and
                    trn-doc.obj-type        = obj-list.obj-type and
                    trn-doc.status_         = {&wayb}           and
                    trn-doc.flag_           = true              and
                    trn-doc.Fact-order      <= fact-order-2     and
                    trn-doc.ext-doc-type    = {&TDEDT_Pri_Vnesh} :
                    for each doc-line no-lock where
                        doc-line.doc-code   = trn-doc.doc-code   and
                        doc-line.artic      = goods.artic        and
                        doc-line.prod-code  = goods.prod-code    and
                        doc-line.prod-type  = goods.prod-type    :
                            Assign
                              f-wait-qnty   = f-wait-qnty     + doc-line.fact-qnty.
                    end. /* for each doc-line */
                End. /* for each trn-doc*/
              End.  /* if c-f-wait-qnty <> ? */

             if itog = false and
                ( p-zero-ost = true or
                not(f-qnty         = 0 and
                    f-cost-sum     = 0 and
                    f-sale-sum     = 0 and
                    f-sale-other   = 0 and
                    f-free-qnty    = 0 and
                    f-wait-qnty    = 0  ))
                Then DO:
                    n-nn = n-nn + 1 .
                    { gbl/gdsbcode.i goods.gds-code ? v-bar-code  }
                    { rep/r-ob-cr.i disp  string(n-nn)                       nn         }
                    { rep/r-ob-cr.i disp  gds-obj.artic                      f-artic    }
                    { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'")   f-b-code   }
                    { rep/r-ob-cr.i disp  goods.gds-name                     f-gds-name }
                    { rep/r-ob-cr.i disp  f-qnty         f-qnty        }
                    { rep/r-ob-cr.i disp  f-cost-pr      f-cost-pr     }
                    { rep/r-ob-cr.i disp  f-cost-sum     f-cost-sum    }
                    { rep/r-ob-cr.i disp  f-sale-pr      f-sale-pr     }
                    { rep/r-ob-cr.i disp  f-sale-sum     f-sale-sum    }
                    { rep/r-ob-cr.i disp  f-sale-other   f-sale-other  }
                    { rep/r-ob-cr.i disp  f-free-qnty    f-free-qnty   }
                    { rep/r-ob-cr.i disp  f-wait-qnty    f-wait-qnty   }
                    { rep/r-ob-cr.i disp  f-rez-qnty     f-rez-qnty    }
                    { rep/r-ob-cr.i disp  f-rez-cost     f-rez-cost    }
                    { rep/r-ob-cr.i disp  f-rez-sale     f-rez-sale    }
                    { rep/r-ob-cr.i disp  f-rez-cost-pr  f-rez-cost-pr }
                    display stream OutStream  no-error .
                    DOWN stream OutStream .
                    {&PutExcel}
                     string(n-nn)                      {&tabulation}
                     v-bar-code                        {&tabulation}
                     gds-obj.artic                     {&tabulation}
                     goods.gds-name                    {&tabulation}
                                                       {&tabulation}
                     excel-qnty(f-qnty        )        {&tabulation}
                     excel-sum (f-cost-pr     )        {&tabulation}
                     excel-sum (f-cost-sum    )        {&tabulation}
                     excel-sum (f-sale-pr     )        {&tabulation}
                     excel-sum (f-sale-sum    )        {&tabulation}
                     excel-sum (f-sale-other  )        {&tabulation}
                     excel-sum (f-free-qnty   )        {&tabulation}
                     excel-sum (f-wait-qnty   )        {&tabulation}
                     excel-sum (f-rez-qnty    )        {&tabulation}
                     excel-sum (f-rez-cost    )        {&tabulation}
                     excel-sum (f-rez-sale    )        {&tabulation}
                     excel-sum (f-rez-cost-pr )        {&tabulation}
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
              accumulate  f-rez-qnty  (TOTAL ) .
              accumulate  f-rez-cost  (TOTAL ) .
              accumulate  f-rez-sale  (TOTAL ) .
              tot-v-sale-sum = tot-v-sale-sum + f-sale-sum.
              tot-v-cost-sum = tot-v-cost-sum + f-cost-sum.
&Else
              accumulate f-qnty           (TOTAL  by {2} ) .
              accumulate f-cost-sum       (TOTAL  by {2} ) .
              accumulate f-sale-sum       (TOTAL  by {2} ) .
              accumulate f-sale-other     (TOTAL  by {2} ) .
              accumulate f-free-qnty      (TOTAL  by {2} ) .
              accumulate f-wait-qnty      (TOTAL  by {2} ) .
              accumulate f-rez-qnty   (TOTAL  by {2} ) .
              accumulate f-rez-cost   (TOTAL  by {2} ) .
              accumulate f-rez-sale   (TOTAL  by {2} ) .
&endif
                Assign
                  f-qnty          = 0
                  f-cost-sum      = 0
                  f-sale-sum      = 0
                  f-sale-other    = 0
                  f-free-qnty     = 0
                  f-wait-qnty     = 0
                  f-rez-qnty     = 0
                  f-rez-cost     = 0
                  f-rez-sale     = 0
                  f-rez-cost-pr  = 0
                 .
          End. /* if last-of artic */
&if "{1}" <> "no-classify" &then
          if last-of({2})  then do :
            f-artic = {3} .
            { rep/r-ob-cr.i disp    "'Итого'"    nn }
            { rep/r-ob-cr.i disp    f-artic         f-artic }
            { rep/r-ob-cr.i disp    var-client   f-gds-name  }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-qnty      " f-qnty        }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-cost-sum  " f-cost-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-sale-sum  " f-sale-sum    }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-sale-other" f-sale-other  }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-free-qnty " f-free-qnty   }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-wait-qnty " f-wait-qnty   }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-rez-qnty  " f-rez-qnty   }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-rez-cost  " f-rez-cost   }
            { rep/r-ob-cr.i disp    "accum TOTAL by {2} f-rez-sale  " f-rez-sale   }

              Display stream OutStream  no-error .
              DOWN stream OutStream .
              {&PutExcel}
              "Итого"                                              {&tabulation}
              {3}
              var-client                                           {&tabulation} {&tabulation}
              {&tabulation} {&tabulation}
              excel-qnty(accum TOTAL by {2}  f-qnty           )    {&tabulation}
                                                                   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-cost-sum       )    {&tabulation}
                                                                   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-sum       )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-sale-other     )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-free-qnty      )   {&tabulation}
              excel-sum (accum TOTAL by {2}  f-wait-qnty      )   {&tabulation}
              excel-sum (accum TOTAL by {2} f-rez-qnty  ) {&tabulation}
              excel-sum (accum TOTAL by {2} f-rez-cost  ) {&tabulation}
              excel-sum (accum TOTAL by {2} f-rez-sale  ) {&tabulation}
              {&tabulation}
              {&new-line} .
          End.  /*if last prod-code */
&endif
end.
 End. /*for each gds-obj */
 run u-line in this-procedure.
{ rep/r-ob-cr.i disp "'ИТОГО'"                  nn            }
{ rep/r-ob-cr.i disp "'по объекту'"             f-b-code      }
{ rep/r-ob-cr.i disp "obj-list.obj-name"        f-gds-name    }
{ rep/r-ob-cr.i disp "accum TOTAL f-qnty"       f-qnty        }
{ rep/r-ob-cr.i disp "accum TOTAL f-cost-sum"   f-cost-sum    }
{ rep/r-ob-cr.i disp "accum TOTAL f-sale-sum"   f-sale-sum    }
{ rep/r-ob-cr.i disp "accum TOTAL f-sale-other" f-sale-other  }
{ rep/r-ob-cr.i disp "accum TOTAL f-free-qnty"  f-free-qnty   }
{ rep/r-ob-cr.i disp "accum TOTAL f-wait-qnty"  f-wait-qnty   }
{ rep/r-ob-cr.i disp "accum TOTAL f-rez-qnty"   f-rez-qnty    }
{ rep/r-ob-cr.i disp "accum TOTAL f-rez-cost"   f-rez-cost    }
{ rep/r-ob-cr.i disp "accum TOTAL f-rez-sale"   f-rez-sale    }

  Display stream OutStream no-error.
  DOWN stream OutStream .
  run u-line in this-procedure.
  {&PutExcel}
          "ИТОГО"                         {&tabulation}
          "по объекту"                    {&tabulation}
          obj-list.obj-name               {&tabulation}  {&tabulation}  {&tabulation}
          excel-qnty(accum TOTAL f-qnty           )  {&tabulation}
                                                     {&tabulation}
          excel-sum (tot-v-cost-sum       )  {&tabulation}
                                                     {&tabulation}
          excel-sum (tot-v-sale-sum       )  {&tabulation}
          excel-sum (accum TOTAL f-sale-other    )   {&tabulation}
          excel-sum (accum TOTAL f-free-qnty     )   {&tabulation}
          excel-sum (accum TOTAL f-wait-qnty     )   {&tabulation}
    excel-sum (accum TOTAL  f-rez-qnty  ) {&tabulation}
    excel-sum (accum TOTAL  f-rez-cost  ) {&tabulation}
    excel-sum (accum TOTAL  f-rez-sale  ) {&tabulation}
    {&tabulation}
          {&new-line} .
End.  /*for each obj-list*/
   if n-no > 1 then do:
        { rep/r-ob-cr.i disp "'ИТОГО'"                  nn          }
        { rep/r-ob-cr.i disp "'ПО ВСЕМ ОБЬЕКТАМ'"       f-artic     }
        { rep/r-ob-cr.i disp "accum TOTAL f-qnty"       f-qnty      }
        { rep/r-ob-cr.i disp "accum TOTAL f-cost-sum"   f-cost-sum  }
        { rep/r-ob-cr.i disp "accum TOTAL f-sale-sum"   f-sale-sum  }
        { rep/r-ob-cr.i disp "accum TOTAL f-sale-other" f-sale-other}
        { rep/r-ob-cr.i disp "accum TOTAL f-free-qnty"  f-free-qnty }
        { rep/r-ob-cr.i disp "accum TOTAL f-wait-qnty"  f-wait-qnty }
        { rep/r-ob-cr.i disp "accum TOTAL f-rez-qnty"   f-rez-qnty  }
        { rep/r-ob-cr.i disp "accum TOTAL f-rez-cost"   f-rez-cost  }
        { rep/r-ob-cr.i disp "accum TOTAL f-rez-sale"   f-rez-sale  }
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line in this-procedure.
         {&PutExcel}
         "ИТОГО"                       {&tabulation}
         "ПО ВСЕМ ОБЬЕКТАМ"            {&tabulation} {&tabulation} {&tabulation}
          {&tabulation}
         excel-qnty(accum TOTAL f-qnty           )   {&tabulation}
         {&tabulation}
         excel-sum (accum TOTAL f-cost-sum       )   {&tabulation}
         {&tabulation}
         excel-sum (accum TOTAL f-sale-sum       )   {&tabulation}
         excel-sum (accum TOTAL f-sale-other     )   {&tabulation}
         excel-sum (accum TOTAL f-free-qnty      )   {&tabulation}
         excel-sum (accum TOTAL f-wait-qnty      )   {&tabulation}
        excel-sum (accum TOTAL f-rez-qnty  )   {&tabulation}
        excel-sum (accum TOTAL f-rez-cost  )   {&tabulation}
        excel-sum (accum TOTAL f-rez-sale  )   {&tabulation}
         {&new-line} .
    End. /* do */
&else
/* Procedure Display-prt */
/* а есть ли у него шкала ? */

IF goods.prt-root <> Prtroot Then DO:
  /* На любое время */
    If v-var = "no-today"  then do:
run  prdoclib-init-prt-obj-by-factord in this-procedure
( input gds-obj.obj-type  ,
  input gds-obj.obj-code  ,
  input gds-obj.artic     ,
  input gds-obj.prod-type ,
  input gds-obj.prod-code ,
  input fact-order-2 ,
  input false ) .
    end.
  for each prt-obj where
      prt-obj.artic     = goods.artic     and
      prt-obj.prod-type = goods.prod-type and
      prt-obj.prod-code = goods.prod-code and
      prt-obj.obj-code  = obj-list.obj-code and
      prt-obj.obj-type  = obj-list.obj-type and
      prt-obj.is-term   =  true no-lock
      BREAK BY prt-obj.prt-code with FRAME Zapas :
      pr-cursor = 0.
      go-work = false.
      if v-prizn = "" then do: 
        go-work = true.
      end.
      else do:
          do while pr-cursor < num-entries(v-prizn,","):
              pr-cursor = pr-cursor + 1.
              if entry(pr-cursor,v-prizn,",") <> "" then do:
                  if integer(entry(pr-cursor,v-prizn,",")) = prt-obj.prt-code then do:
                      pr-cursor = num-entries(v-prizn,",").
                      go-work = true.
                  end.
              end.
          end.
      end.
      if go-work then do:
          if v-var <> "no-today" then do:
              Assign
                p-qnty      = p-qnty       + prt-obj.fact-qnty
                p-free-qnty = p-free-qnty  + prt-obj.free-qnty
                p-sale-sum  = p-sale-sum   + prt-obj.fact-qnty * prt-obj.price-sale
                p-sale-pr   = if p-qnty = 0 then 0 else p-sale-sum / p-qnty
                .
          End.
          IF last-of(prt-obj.prt-code) THEN DO:
              { gbl/gdsbcode.i gds-obj.gds-code prt-obj.prt-code v-bar-code  } /* бар-код признака*/
              if v-var = "no-today" then do:
                find first temp-prt-obj no-lock
                     where temp-prt-obj.prt-obj-recid   = recid (prt-obj) no-error .
                     if avail temp-prt-obj then do :
                        run  calc-price-sale-for-prt in this-procedure  (output v-price-sale) .
                        Assign
                          p-qnty      = temp-prt-obj.fact-qnty
                          p-free-qnty = 0
                          p-sale-sum  = temp-prt-obj.fact-qnty * v-price-sale
                          p-sale-pr   = if p-qnty = 0 then 0 else p-sale-sum / p-qnty
                          .
                      End.
                      Else
                        Assign
                          p-qnty      = 0
                          p-free-qnty = 0
                          p-sale-sum  = 0   .

              End.
        FIND first gds-prt  where gds-prt.node-code = prt-obj.prt-code NO-LOCK no-error .
        /* ожидаемое */
        if c-f-wait-qnty <> ? Then DO :
          for each trn-doc no-lock  where
              trn-doc.obj-code        = obj-list.obj-code and
              trn-doc.obj-type        = obj-list.obj-type and
              trn-doc.status_         = {&wayb}           and
              trn-doc.flag_           = true              and
              trn-doc.ext-doc-type    = {&TDEDT_Pri_Vnesh} :
              for each gds-dtl no-lock where
                  gds-dtl.doc-code   = trn-doc.doc-code   and
                  gds-dtl.artic      = goods.artic        and
                  gds-dtl.prod-code  = goods.prod-code    and
                  gds-dtl.prod-type  = goods.prod-type    and
                  gds-dtl.prt-code   = prt-obj.prt-code   and
                  gds-dtl.obj-code   = obj-list.obj-code  and
                  gds-dtl.obj-type   = obj-list.obj-type :
                  Assign
                  p-wait-qnty   = p-wait-qnty     + gds-dtl.fact-qnty.
              end. /* for each gds-dtl */
          End. /* for each trn-doc*/
        End.  /* if c-f-wait-qnty <> ? */

        if ( f-rez-qnty <> ? or
            f-rez-cost <> ? or
            f-rez-sale <> ? ) and  v-var <> "no-today"
        then do:
              for each temp_gds-dtl where
                        temp_gds-dtl.prt-code   = prt-obj.prt-code  :
                  assign
                    p-rez-qnty = p-rez-qnty  + temp_gds-dtl.doc-qnty
                    p-rez-cost = p-rez-cost  + temp_gds-dtl.cost-sum
                    p-rez-sale = p-rez-sale  + temp_gds-dtl.sale-sum
                    p-rez-cost-pr = ( if p-rez-qnty = 0 then 0 else p-rez-cost / p-rez-qnty )
                  .
              end.
        end.
        Assign
        p-cost-sum     = determined( f-cost-sum * p-qnty  / f-qnty)
        p-sale-other   = 100 * determined((p-sale-sum - p-cost-sum) / p-cost-sum)
        p-cost-pr      = if p-qnty = 0 then 0 else p-cost-sum   / p-qnty
        .
        if not (p-zero = false  and
             (p-qnty        =  0  and
              p-cost-sum    =  0  and
              p-sale-sum    =  0  and
              p-sale-other  =  0  and
              p-free-qnty   =  0  and
                  p-wait-qnty  = 0  ) ) then do:

            { rep/r-ob-cr.i disp  "''"                                nn         }
            { rep/r-ob-cr.i disp  "''"                                f-artic    }
            { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'")    f-b-code   }
            { rep/r-ob-cr.i disp  gds-prt.f-name                      f-prt-name }
            { rep/r-ob-cr.i disp  p-qnty        f-qnty        }
            { rep/r-ob-cr.i disp  p-cost-pr     f-cost-pr     }
            { rep/r-ob-cr.i disp  p-cost-sum    f-cost-sum    }
            { rep/r-ob-cr.i disp  p-sale-pr     f-sale-pr     }
            { rep/r-ob-cr.i disp  p-sale-sum    f-sale-sum    }
            { rep/r-ob-cr.i disp  p-sale-other  f-sale-other  }
            { rep/r-ob-cr.i disp  p-free-qnty   f-free-qnty   }
            { rep/r-ob-cr.i disp  p-wait-qnty   f-wait-qnty   }
            { rep/r-ob-cr.i disp  p-rez-qnty    f-rez-qnty    }
            { rep/r-ob-cr.i disp  p-rez-cost    f-rez-cost    }
            { rep/r-ob-cr.i disp  p-rez-sale    f-rez-sale    }
            { rep/r-ob-cr.i disp  p-rez-cost-pr f-rez-cost-pr }

            Display stream OutStream no-error.
            DOWN stream OutStream .
            {&PutExcel}
            {&tabulation}
            string(v-bar-code,"999999999") {&tabulation}
                         {&tabulation}
                         {&tabulation}
             gds-prt.f-name                    {&tabulation}
             excel-qnty(p-qnty)                            {&tabulation}
             excel-sum(p-cost-pr)                        {&tabulation}
             excel-sum(p-cost-sum)                        {&tabulation}
             excel-sum(p-sale-pr)                        {&tabulation}
             excel-sum(p-sale-sum)                        {&tabulation}
             excel-sum(p-sale-other)                      {&tabulation}
             excel-sum(p-free-qnty)                       {&tabulation}
            excel-sum(p-wait-qnty)   {&tabulation}
            excel-sum(p-rez-qnty   ) {&tabulation}
            excel-sum(p-rez-cost   ) {&tabulation}
            excel-sum(p-rez-sale   ) {&tabulation}
            excel-sum(p-rez-cost-pr) {&tabulation}
            {&new-line} .
        End.
        Assign
          p-qnty        =  0
          p-cost-sum    =  0
          p-sale-sum    =  0
          p-sale-other  =  0
          p-free-qnty   =  0
          p-wait-qnty   =  0
          p-rez-qnty     = 0
          p-rez-cost     = 0
          p-rez-sale     = 0
          p-rez-cost-pr  = 0
          .
    End.
  End.
  end.
End.
&endif
/* $Workfile$ e n d */