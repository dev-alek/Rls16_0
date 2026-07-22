block-level on error undo, throw.
/*

$Revision: 899f5f3721f3, 1951, rls $
$Author: ASMorozov $
$Date: Fri Jul 26 11:39:33 2019 +0300 $
$Workfile: r-trg810.p $
$Archive: rep/r-trg810.p $

Сводный отчет по движению СТ. НТФ-8.10 (Кедр-М)

Автор: Комаров Иван Сергеевич
Дата создания: 02/02/10
Author: Ivan Komarov
Creation date: 02/02/10

*/

define variable vss-revision    as character no-undo init "$Revision: 899f5f3721f3, 1951, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:39:33 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-trg810.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-trg810.p $":U .
define variable vss-description as character no-undo init "Сводный отчет по движению СТ. НТФ-8.10 (Кедр-М)".
{ cmp/vssrevis.i }

define variable g#report-num  as integer no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ gbl/cur-time.i }
{ gbl/paramls.i  }
{ gbl/prn-lib.i  }
{ ref/grplib.i   }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ rep/r-sale.i   }
{ trg/factord.i  }
{ rep/ostatok.i  }
{ rep/ost-line.i }
{ rep/trg810xl.i }
{ str/trdcalib.i }

define stream out-stream.

  DEFINE VARIABLE parParentProc     AS WIDGET-HandLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
  run get-report-num  in parparentproc (output  g#report-num).
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }
  define variable v-cntxt-obj-name      as character no-undo .

define temp-table temp-obj no-undo
  field obj-code         as integer
  field obj-type         as character
  field obj-name         as character
  field char-count       as character
  INDEX ii2 is primary unique obj-code obj-type
  .

define temp-table temp-grp-obj no-undo
  field count1           as integer
  field count2           as integer
  field char-count       as character
  field grpname          as character
  field obj-name         as character
  field income           as decimal
  field expense          as decimal
  field int-income       as decimal
  field int-expense      as decimal
  field izlish           as decimal
  field nedost           as decimal
  field ostend           as decimal
  field ostbegin         as decimal
  field obj-code         as integer
  field obj-type         as character
  INDEX ii1 is primary unique grpname obj-code obj-type
  .
define temp-table temp-gds no-undo
  field obj-code         as integer
  field obj-type         as character
  field prod-code        as integer
  field prod-type        as character
  field artic            as character
  field grp-name         as character
  field gds-code         as integer
  INDEX ii is primary unique obj-code obj-type artic prod-type prod-code
  INDEX ii4 grp-name obj-code obj-type
.
define temp-table sub_temp-grp-obj no-undo
  field grpname          as character
  field income           as decimal
  field expense          as decimal
  field int-income       as decimal
  field int-expense      as decimal
  field izlish           as decimal
  field nedost           as decimal
  field ostend           as decimal
  field ostbegin         as decimal
  field obj-code         as integer
  field obj-type         as character
  INDEX ii3 is primary unique obj-code obj-type
  .

  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_clients     for ub.clients .
  define buffer buf_ot-line     for ub.ot-line .
  define buffer buf_stk-line    for ub.stk-line .
  define buffer buf_sale-doc    for ub.sale-doc .
  define buffer buf_obj-list    for obj-list .

  define variable v-count       as integer   no-undo .
  define variable v-str         as integer   no-undo .
  define variable v-firm        as character no-undo .
  define variable v-object      as character no-undo .
  define variable v-date        as character no-undo .
  define variable CurrGrpName   as character no-undo .
  define variable Line          as character no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-Count1      as integer   no-undo .
  define variable v-Count2      as integer   no-undo .
  define variable Counter1      as integer   no-undo .
  define variable tmp           as decimal   no-undo .
  define variable v-date-start  as character no-undo .
  define variable v-date-end    as character no-undo .
  define variable v-char-count  as character no-undo .
  define variable v-grpname     as character no-undo .
  define variable v-obj-name    as character no-undo .
  define variable v-income      as decimal   no-undo .
  define variable v-int-income  as decimal   no-undo .
  define variable v-expense     as decimal   no-undo .
  define variable v-int-expense as decimal   no-undo .
  define variable v-izlish      as decimal   no-undo .
  define variable v-nedost      as decimal   no-undo .
  define variable v-ostend      as decimal   no-undo .
  define variable v-ostbegin    as decimal   no-undo .

  define variable it_income      as decimal   no-undo .
  define variable it_int-income  as decimal   no-undo .
  define variable it_expense     as decimal   no-undo .
  define variable it_int-expense as decimal   no-undo .
  define variable it_izlish      as decimal   no-undo .
  define variable it_nedost      as decimal   no-undo .
  define variable it_ostend      as decimal   no-undo .
  define variable it_ostbegin    as decimal   no-undo .

  define variable x-store-code    like ub.clients.obj-code   no-undo.
  define variable x-store-type    like ub.clients.obj-type   no-undo.

  define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
  define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
  define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
  define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
  define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
  define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.

  define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
  define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
  define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
  define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
  define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
  define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
  define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.
  define variable  Quantity       like ub.stk-tot.fact-qnty  no-undo.
  define variable  Coast          like ub.stk-tot.sum-rubl   no-undo.
  define variable  Coast_R        like ub.stk-tot.sum-rubl   no-undo.
  define variable  Coast_V        like ub.stk-tot.sum-rubl   no-undo.
  define variable  VAT_R          like ub.stk-tot.sum-rubl   no-undo.
  define variable  VAT_V          like ub.stk-tot.sum-rubl   no-undo.
  define variable  SLT_R          like ub.stk-tot.sum-rubl   no-undo.
  define variable  SLT_V          like ub.stk-tot.sum-rubl   no-undo.
  define variable  SLT_R1         like ub.stk-tot.sum-rubl   no-undo.
  define variable  SLT_V1         like ub.stk-tot.sum-rubl   no-undo.
  define variable  SLT_R2         like ub.stk-tot.sum-rubl   no-undo.
  define variable  SLT_V2         like ub.stk-tot.sum-rubl   no-undo.

  assign  Line = fill( "-", 186 ) .

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */
  find first tmp#grp no-error .
      if not available tmp#grp then do :
        message "Не выбраны группы товаров." view-as alert-box error .
        return .
      end.
  for each temp-obj :
    delete temp-obj .
  end .
  for each temp-grp-obj :
    delete   temp-grp-obj .
  end .
  for each temp-gds :
    delete   temp-gds .
  end .
  for each sub_temp-grp-obj :
    delete   sub_temp-grp-obj .
  end .

  run tg810xl-init in this-procedure .
  find first obj-list
       where obj-list.obj-type = v-cntxt-obj-type
         and obj-list.obj-code = v-cntxt-obj-code
         no-error .
       if available obj-list then do :
           assign v-object = obj-list.obj-name .
       end .

  find first buf_clients
        where buf_clients.obj-type = {&cmp}
        and   buf_clients.obj-code = v-cntxt-host-code-obj
        no-lock
        .
  assign
      v-firm        = buf_clients.obj-name
      v-date-start  = string(x-date-start, "99/99/9999")
      v-date-end    = string(x-date-end,   "99/99/9999")
      v-date        = str1
      .
  for each buf_obj-list no-lock :
    assign
      x-store-code = buf_obj-list.obj-code
      x-store-type = buf_obj-list.obj-type
    .
    run calcitog in this-procedure.
        find first temp-obj
        where temp-obj.obj-code = buf_obj-list.obj-code
        and   temp-obj.obj-type = buf_obj-list.obj-type
        use-index ii2 no-error .
        if not available temp-obj then do :
          create temp-obj .
          assign
            temp-obj.obj-name   = buf_obj-list.obj-name
            temp-obj.obj-code   = buf_obj-list.obj-code
            temp-obj.obj-type   = buf_obj-list.obj-type
          .
        end.

   /*????*/   { gbl/hostcode.i buf_obj-list.obj-type buf_obj-list.obj-code v-host-code }

      for each tmp#grp :  /* составляем список товаров */
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
        create temp-grp-obj .
        assign
          temp-grp-obj.obj-code   = buf_obj-list.obj-code
          temp-grp-obj.obj-type   = buf_obj-list.obj-type
          temp-grp-obj.grpname    = CurrGrpName
          temp-grp-obj.obj-name   = buf_obj-list.obj-name
        .
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type = buf_obj-list.obj-type
            and buf_gds-obj.obj-code = buf_obj-list.obj-code
            and buf_gds-obj.grp-name begins CurrGrpName
          use-index obj-grp :
          find first temp-gds
          where temp-gds.obj-code  = buf_obj-list.obj-code
            and temp-gds.obj-type  = buf_obj-list.obj-type
            and temp-gds.artic     = buf_gds-obj.artic
            and temp-gds.prod-code = buf_gds-obj.prod-code
            and temp-gds.prod-type = buf_gds-obj.prod-type
            and temp-gds.grp-name  = CurrGrpName
            use-index ii no-lock no-error .
            if not available temp-gds then do :
              create temp-gds .
                assign
                temp-gds.obj-code  = buf_obj-list.obj-code
                temp-gds.obj-type  = buf_obj-list.obj-type
                temp-gds.prod-code = buf_gds-obj.prod-code
                temp-gds.prod-type = buf_gds-obj.prod-type
                temp-gds.artic     = buf_gds-obj.artic
                temp-gds.gds-code  = buf_gds-obj.gds-code
                temp-gds.grp-name  = CurrGrpName
              .
            end .
         end.
      end.
        def var v-value as character no-undo.
        def var v-type  as character no-undo.
        def var v-tech-pass as logical no-undo.
        
        for each temp-gds
        where temp-gds.obj-code  = buf_obj-list.obj-code
          and temp-gds.obj-type  = buf_obj-list.obj-type
        use-index ii no-lock :
        find first temp-grp-obj
          where temp-grp-obj.grpname  = temp-gds.grp-name
          and  temp-grp-obj.obj-code = buf_obj-list.obj-code
          and  temp-grp-obj.obj-type = buf_obj-list.obj-type
            use-index ii1 no-lock no-error .
          for each buf_ot-line
              where buf_ot-line.obj-type      = buf_obj-list.obj-type
              and   buf_ot-line.obj-code      = buf_obj-list.obj-code
              and   buf_ot-line.artic         = temp-gds.artic
              and   buf_ot-line.fact-order   <= fact-order-2
              and   buf_ot-line.fact-order    > fact-order-1
              and   buf_ot-line.prod-code     = temp-gds.prod-code
              and   buf_ot-line.prod-type     = temp-gds.prod-type
              and   buf_ot-line.sum-type      = {&arh-cost}
             use-index art-ot no-lock :
                 assign Counter1 = Counter1 + 1.
                 { rep/repfrm.i disp Counter1 }
                    case buf_ot-line.ext-doc-type :
/*ПРИХОД: */
  /*поступ.от пост.*/  when {&TDEDT_Pri_Vnesh} then do :
                           { str/tdat-val.i                                    
                             buf_ot-line.doc-code
                             {&trdcattr-techpass}
                             v-value 
                             v-type 
                             no-error
                           }
                            assign
                              v-tech-pass = yes when v-value = "yes".
                            if can-find(first buf_sale-doc where buf_sale-doc.doc-code = buf_ot-line.doc-code and buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell})
                            then do :
   /*прих.техпролив*/         assign temp-grp-obj.income = temp-grp-obj.income + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                            end .
                            else do :
                              assign temp-grp-obj.income = temp-grp-obj.income + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                            end .
                       end .
 /*внут.приход.*/      when {&TDEDT_Pri_Perem} or
 /*внут. возв.*/       when {&TDEDT_Vozvrat_Perem} or
  /*возврат от пок.*/  when {&TDEDT_Vozvrat_Vnesh} then do :
                            assign temp-grp-obj.income = temp-grp-obj.income + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                       end .
  /*прочие обороты */  when {&TDEDT_Corr_Acc_Price}
                       then do :
                          if buf_ot-line.sum-rubl > 0 then do :
                            assign temp-grp-obj.income = temp-grp-obj.income + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                          else do :
                            assign temp-grp-obj.expense = temp-grp-obj.expense + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                       end .
/*перемещ.в груп.*/    when {&TDEDT_Pri_Prvo} then assign temp-grp-obj.int-income = temp-grp-obj.int-income + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
/*РАСХОД: */
  /*расход внутр.*/    when {&TDEDT_Ras_Perem} or
  /*продажа*/          when {&TDEDT_Ras_Vnesh_Kass} or when {&TDEDT_Ras_Vnesh} or
  /*возврат постав.*/  when {&TDEDT_Ras_Vnesh_VP} then do :
                          assign temp-grp-obj.expense = temp-grp-obj.expense + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                       end .
  /*списание*/         when {&TDEDT_Spi_Vnesh} then do :
                         { str/tdat-val.i                                    
                           buf_ot-line.doc-code
                           {&trdcattr-techpass}
                           v-value 
                           v-type 
                           no-error
                         }
                          assign
                            v-tech-pass = yes when v-value = "yes".
                          if can-find(first buf_sale-doc where buf_sale-doc.doc-code = buf_ot-line.doc-code and buf_sale-doc.doc-kind = {&sale-add-tech-refuell})
                          then do :
  /*спис.техпролив*/          assign temp-grp-obj.int-expense = temp-grp-obj.int-expense + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                          else do :
                              assign temp-grp-obj.expense = temp-grp-obj.expense + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                       end .
/*продажи - возврат*/  when {&TDEDT_Vozvrat_Vnesh_Kass} then assign temp-grp-obj.expense = temp-grp-obj.expense  - ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
/*перемещ.в груп.*/    when {&TDEDT_Spi_Prvo} then assign temp-grp-obj.int-expense = temp-grp-obj.int-expense + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
/*ПЕРЕСОРТИЦА*/        when {&TDEDT_Peresort} then do :
                          if buf_ot-line.sum-rubl < 0 then do :
                            assign temp-grp-obj.int-expense = temp-grp-obj.int-expense + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                          else do :
                            assign temp-grp-obj.int-income = temp-grp-obj.int-income + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                       end .
/*ИНВЕНТАРИЗАЦИЯ:*/
                       when {&TDEDT_Inv} then do :
  /*недостача*/          if buf_ot-line.sum-rubl < 0  then do :
                           assign temp-grp-obj.nedost   = temp-grp-obj.nedost    + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                         end.
  /*излишки*/            else do :
                           assign temp-grp-obj.izlish   = temp-grp-obj.izlish    + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                         end .
                       end .
                    end case .
              end .
          end.
        for each temp-grp-obj
         where temp-grp-obj.obj-code = buf_obj-list.obj-code
           and temp-grp-obj.obj-type = buf_obj-list.obj-type
           use-index ii1 no-lock :
              assign Counter1 = Counter1 + 1.
              { rep/repfrm.i disp Counter1 }
              for each temp-gds
                where temp-gds.grp-name begins temp-grp-obj.grpname
                  and temp-gds.obj-code  = buf_obj-list.obj-code
                  and temp-gds.obj-type  = buf_obj-list.obj-type
                use-index ii4 no-lock :
                    run ost-line (
                      input x-store-code  ,
                      input x-store-type  ,
                      input temp-gds.artic       ,
                      input temp-gds.prod-code   ,
                      input temp-gds.prod-type    ,
                      input x-TOG-Shift ,
                      input Fact-order-1 ,
                      input {&arh-cost}   ,
                      input {&root-cat-id},
                      input YES ,

                      output  Quantity1  ,
                      output  Coast_R1   ,
                      output  Coast_V1   ,
                      output  VAT_R1     ,
                      output  VAT_V1     ,
                      output  slt_R1     ,
                      output  slt_V1     ).
                      assign temp-grp-obj.ostbegin = temp-grp-obj.ostbegin + (Coast_R1 - VAT_R1) .

                     run ost-line (
                      input x-store-code  ,
                      input x-store-type  ,
                      input temp-gds.artic       ,
                      input temp-gds.prod-code   ,
                      input temp-gds.prod-type    ,
                      input x-TOG-Shift ,
                      input Fact-order-2 ,
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
                      assign temp-grp-obj.ostend = temp-grp-obj.ostend + (Coast_R2 - VAT_R2) .
              end.
              find first sub_temp-grp-obj
              where sub_temp-grp-obj.obj-code = temp-grp-obj.obj-code
              and   sub_temp-grp-obj.obj-type = temp-grp-obj.obj-type
              use-index ii3 no-lock no-error .
              if not available sub_temp-grp-obj then do :
                  create sub_temp-grp-obj.
                  assign
                  sub_temp-grp-obj.obj-code = temp-grp-obj.obj-code
                  sub_temp-grp-obj.obj-type = temp-grp-obj.obj-type
                  sub_temp-grp-obj.grpname  = "Итого по " + buf_obj-list.obj-name
                  .
              end .
              assign
               sub_temp-grp-obj.ostbegin    = sub_temp-grp-obj.ostbegin    + temp-grp-obj.ostbegin
               sub_temp-grp-obj.income      = sub_temp-grp-obj.income      + temp-grp-obj.income
               sub_temp-grp-obj.expense     = sub_temp-grp-obj.expense     + temp-grp-obj.expense
               sub_temp-grp-obj.int-income  = sub_temp-grp-obj.int-income  + temp-grp-obj.int-income
               sub_temp-grp-obj.int-expense = sub_temp-grp-obj.int-expense + temp-grp-obj.int-expense
               sub_temp-grp-obj.izlish      = sub_temp-grp-obj.izlish      + temp-grp-obj.izlish
               sub_temp-grp-obj.nedost      = sub_temp-grp-obj.nedost      + temp-grp-obj.nedost
               sub_temp-grp-obj.ostend      = sub_temp-grp-obj.ostend      + temp-grp-obj.ostend
              .
        end .
        assign
          it_ostbegin    = it_ostbegin    + sub_temp-grp-obj.ostbegin
          it_income      = it_income      + sub_temp-grp-obj.income
          it_expense     = it_expense     + sub_temp-grp-obj.expense
          it_int-income  = it_int-income  + sub_temp-grp-obj.int-income
          it_int-expense = it_int-expense + sub_temp-grp-obj.int-expense
          it_izlish      = it_izlish      + sub_temp-grp-obj.izlish
          it_nedost      = it_nedost      + sub_temp-grp-obj.nedost
          it_ostend      = it_ostend      + sub_temp-grp-obj.ostend
        .
  end. /*buf_obj-list */
   { gbl/working.i }
   { cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }

DEFINE FRAME shift
        sym1          no-label format "X(1)" space(0)
        v-char-count  no-label format "x(6)" space(0)
        sym2          no-label format "X(1)" space(0)
        v-grpname     no-label format "x(41)" space(0)
        sym3          no-label format "X(1)" space(0)
        v-ostbegin    no-label format "->>>>,>>>,>>9.99" space(0)
        sym4          no-label format "X(1)" space(0)
        v-income      no-label format "->>>>,>>>,>>9.99" space(0)
        sym5          no-label format "X(1)" space(0)
        v-int-income  no-label format "->>>>,>>>,>>9.99" space(0)
        sym6          no-label format "X(1)" space(0)
        v-expense     no-label format "->>>>,>>>,>>9.99" space(0)
        sym7          no-label format "X(1)" space(0)
        v-int-expense no-label format "->>>>,>>>,>>9.99" space(0)
        sym8          no-label format "X(1)" space(0)
        v-izlish      no-label format "->>>>,>>>,>>9.99" space(0)
        sym9          no-label format "X(1)" space(0)
        v-nedost      no-label format "->>>>,>>>,>>9.99" space(0)
        sym10         no-label format "X(1)" space(0)
        v-ostend      no-label format "->>>>,>>>,>>9.99" space(0)
        sym11         no-label format "X(1)" space(0)
  header
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) at 174 format "X(13)" skip
"+------+-----------------------------------------+----------------+----------------+----------------+----------------+----------------+---------------------------------+----------------+" skip
"|  №   |                                         |     Остаток    |                |                |                |                |          Инвентаризация         |     Остаток    |" skip
"|      |                  Группа                 |   товаров на   |     Приход     |     Приход     |     Расход     |     Расход     +---------------------------------+   товаров на   |" skip
"| п/п  |                товаров                  |     начало     |                |   внутренний   |                |   внутренний   |     излишек    |   недостача    |      конец     |" skip
"|      |                                         |     периода    |                |                |                |                |                |                |     периода    |" skip
"+------+-----------------------------------------+----------------+----------------+----------------+----------------+----------------+----------------+----------------+----------------+" skip
with width {&DOS_CW_2} down stream-io no-box no-underline no-labels .


  PUT STREAM Out-Stream
                                                                                                                "1393НТФ №ТОРГ-8.10" AT 147       skip
    space(8) v-firm format "X(50)"                                            '"УТВЕРЖДАЮ"'        AT 126                                        skip
    space(4) "__________________________________" format "X(30)"              "Генеральный Директор" AT 119  "         " v-firm format "X(50)"     skip
    space(8) "(название организации)" format "X(30)"                                                            "______________________" at 147                 skip
                                                                                                                "(название организации)" format "X(30)" at 147  skip
    " " skip
                                                                               "____________________________________________" format "X(50)" at 126          skip
                                                                              "     (подпись)               (ФИО)           " format "X(50)" at 126          skip
    " " skip
                                                                               '"____"____________________20____г.'         format "X(50)" at 126          skip

    " " skip
    " " skip
    "СВОДНЫЙ ОТЧЕТ" format "X(20)" at 88 skip
    "по движению сопутствующих товаров на АЗС/АЗК" format "X(50)" at 73 skip
    v-date format "X(100)" at 69 skip
  .

    assign
    v-count1 = 0
    v-count2 = 0
 .
   form with frame shift .

 for each temp-obj by temp-obj.obj-name :
     assign
     v-count1 = v-count1 + 1
     v-count2 = 0
     temp-obj.char-count = string(v-count1) + "."
     .
      run tg810xl-write-line-data in this-procedure ( input temp-obj.char-count
                                                    , input temp-obj.obj-name
                                                    , input " "
                                                    , input " "
                                                    , input " "
                                                    , input " "
                                                    , input " "
                                                    , input " "
                                                    , input " "
                                                    , input " "
                                                    ) .
    run tg810xl-write-line-format in this-procedure ( "Заголовок1" ).
    display stream Out-Stream
          sym1  temp-obj.char-count @ v-char-count
          sym2  temp-obj.obj-name   @ v-grpname
          sym3
          sym4
          sym5
          sym6
          sym7
          sym8
          sym9
          sym10
          sym11
        with frame shift.
        down stream Out-Stream with frame shift .

     for each temp-grp-obj no-lock
      where temp-grp-obj.obj-code = temp-obj.obj-code
      and   temp-grp-obj.obj-type = temp-obj.obj-type
      use-index ii1
         by temp-grp-obj.grpname
     :
        assign
          v-count2 = v-count2 + 1
          temp-grp-obj.char-count = string(v-count1) + "." + string(v-count2) + "."
        .
        run tg810xl-write-line-data in this-procedure ( input temp-grp-obj.char-count
                                                        , input temp-grp-obj.grpname
                                                        , input temp-grp-obj.ostbegin
                                                        , input temp-grp-obj.income
                                                        , input temp-grp-obj.int-income
                                                        , input temp-grp-obj.expense
                                                        , input temp-grp-obj.int-expense
                                                        , input temp-grp-obj.izlish
                                                        , input temp-grp-obj.nedost
                                                        , input temp-grp-obj.ostend
                                                      ) .
        display stream Out-Stream
              sym1  temp-grp-obj.char-count  @ v-char-count
              sym2  temp-grp-obj.grpname     @ v-grpname
              sym3  temp-grp-obj.ostbegin    @ v-ostbegin
              sym4  temp-grp-obj.income      @ v-income
              sym5  temp-grp-obj.int-income  @ v-int-income
              sym6  temp-grp-obj.expense     @ v-expense
              sym7  temp-grp-obj.int-expense @ v-int-expense
              sym8  temp-grp-obj.izlish      @ v-izlish
              sym9  temp-grp-obj.nedost      @ v-nedost
              sym10  temp-grp-obj.ostend      @ v-ostend
              sym11
            with frame shift.
            down stream Out-Stream with frame shift .

      end .
      find first sub_temp-grp-obj
          where sub_temp-grp-obj.obj-code = temp-obj.obj-code
          and   sub_temp-grp-obj.obj-type = temp-obj.obj-type
          use-index ii3 no-error.
          if available sub_temp-grp-obj then do :
                run tg810xl-write-line-data in this-procedure ( input " "
                                                              , input sub_temp-grp-obj.grpname
                                                              , input sub_temp-grp-obj.ostbegin
                                                              , input sub_temp-grp-obj.income
                                                              , input sub_temp-grp-obj.int-income
                                                              , input sub_temp-grp-obj.expense
                                                              , input sub_temp-grp-obj.int-expense
                                                              , input sub_temp-grp-obj.izlish
                                                              , input sub_temp-grp-obj.nedost
                                                              , input sub_temp-grp-obj.ostend
                                                            ) .
                run tg810xl-write-line-format in this-procedure ( "Заголовок2" ).
                display stream Out-Stream
                      sym1  ""
                      sym2  sub_temp-grp-obj.grpname      @ v-grpname
                      sym3  sub_temp-grp-obj.ostbegin     @ v-ostbegin
                      sym4  sub_temp-grp-obj.income       @ v-income
                      sym5  sub_temp-grp-obj.int-income   @ v-int-income
                      sym6  sub_temp-grp-obj.expense      @ v-expense
                      sym7  sub_temp-grp-obj.int-expense  @ v-int-expense
                      sym8  sub_temp-grp-obj.izlish       @ v-izlish
                      sym9  sub_temp-grp-obj.nedost       @ v-nedost
                      sym10  sub_temp-grp-obj.ostend      @ v-ostend
                      sym11
                    with frame shift.
                    down stream Out-Stream with frame shift .
                    underline stream Out-Stream v-char-count v-grpname v-ostbegin v-income v-int-income v-expense v-int-expense v-izlish v-nedost v-ostend with frame shift .
          end .
          else do :
                    form with frame shift .
                    underline stream Out-Stream v-char-count v-grpname v-ostbegin v-income v-int-income v-expense v-int-expense v-izlish v-nedost v-ostend with frame shift .
          end .
 end .
 run tg810xl-write-line-data in this-procedure ( input " "
                                              , input "ВСЕГО:"
                                              , input it_ostbegin
                                              , input it_income
                                              , input it_int-income
                                              , input it_expense
                                              , input it_int-expense
                                              , input it_izlish
                                              , input it_nedost
                                              , input it_ostend
                                            ) .
 run tg810xl-write-line-format in this-procedure ( "Заголовок3" ).
 display stream Out-Stream
      sym1  ""
      sym2  "ВСЕГО:"       @ v-grpname
      sym3  it_ostbegin    @ v-ostbegin
      sym4  it_income      @ v-income
      sym5  it_int-income  @ v-int-income
      sym6  it_expense     @ v-expense
      sym7  it_int-expense @ v-int-expense
      sym8  it_izlish      @ v-izlish
      sym9  it_nedost      @ v-nedost
      sym10 it_ostend      @ v-ostend
      sym11
    with frame shift.
    down stream Out-Stream with frame shift .
  PUT STREAM Out-Stream
    Line format "X(186)" at 1
    " " skip
    " " skip
    " " skip
    space(8) "Ответственный сотрудник" format "X(30)"                                                                         skip
                                                   "_____________________    _______________________"  format "X(50)" at 120   skip
                                                    "     (подпись)           (расшифровка подписи)  " format "X(50)" at 120   skip
  .

   run tg810xl-write-cell-data in this-procedure (
       input {&tg810xl-h_organization}
       , input v-firm
   ).
    run tg810xl-write-cell-data in this-procedure (
       input {&tg810xl-h_object}
       , input v-firm
   ).
    run tg810xl-write-cell-data in this-procedure (
       input {&tg810xl-h_date}
       , input v-date
   ).
  run tg810xl-close in this-procedure .
  HIDE STREAM   Out-Stream   FRAME shift .
  Output stream Out-Stream   close .
  { rep/repfrm.i off }
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .

  run gbl/prnfilen.w
      ( input  ""
      , input  8
      , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      , input  ReportFontNum
      , output v-user-action
      , output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

  { gbl/stopwork.i }


 /*--------------------------------------*/
 procedure calcitog :
/*------------------------------------------------------------------------------
  purpose:  Найти  на начало и конец  fact-order
  номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input true ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input true ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).

end procedure.