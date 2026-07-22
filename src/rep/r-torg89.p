block-level on error undo, throw.
/*

$Revision: 899f5f3721f3, 1951, rls $
$Author: ASMorozov $
$Date: Fri Jul 26 11:39:33 2019 +0300 $
$Workfile: r-torg89.p $
$Archive: rep/r-torg89.p $

Отчет по движению СТ. НТФ-8.9 (Кедр-М)

Автор: Комаров Иван Сергеевич
Дата создания: 02/02/10
Author: Ivan Komarov
Creation date: 02/02/10

*/

define variable vss-revision    as character no-undo init "$Revision: 899f5f3721f3, 1951, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:39:33 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-torg89.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-torg89.p $":U .
define variable vss-description as character no-undo init "Отчет по движению СТ. НТФ-8.9 (Кедр-М)".
{ cmp/vssrevis.i }

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
{ str/trdcalib.i }

define stream out-stream.

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
  define variable g#report-num as integer no-undo .
  run get-report-num  in parparentproc (output  g#report-num).
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }
  define variable v-cntxt-obj-name      as character no-undo .

 { rep/r-tg89xl.i }

define temp-table temp-grp-obj no-undo
  FIELD count            as integer
  FIELD grpname          as character
  FIELD pripost          as decimal
  FIELD priperem         as decimal
  FIELD priprvo          as decimal
  FIELD privozv          as decimal
  FIELD prielse          as decimal
  FIELD rasprod          as decimal
  FIELD rasvozv          as decimal
  FIELD rasperem         as decimal
  FIELD rasvnesh         as decimal
  FIELD rasprvo          as decimal
  FIELD rasspis          as decimal
  FIELD raselse          as decimal
  FIELD peresort         as decimal
  FIELD izlish           as decimal
  FIELD nedost           as decimal
  FIELD ostend           as decimal
  FIELD ostbegin         as decimal

  FIELD obj-code         as integer
  FIELD obj-type         as character

  INDEX ii1 is primary unique grpname obj-code obj-type
  .
define temp-table temp-gds no-undo
  FIELD prod-code as integer
  FIELD prod-type as character
  FIELD artic     as character
  FIELD grp-name  as character
  FIELD gds-code  as integer
  INDEX ii is primary unique artic prod-type prod-code
.
  define buffer buf_gds-obj       for ub.gds-obj .
  define buffer buf_clients       for ub.clients .
  define buffer buf_ot-line       for ub.ot-line .
  define buffer buf_stk-line      for ub.stk-line .
  define buffer buf_sale-doc      for ub.sale-doc .
  define buffer buf_doc-attr      for ub.doc-attr .
  define buffer buf_obj-list      for obj-list .

  define variable v-count       as integer   no-undo .
  define variable v-str         as integer   no-undo .
  define variable v-firm        as character no-undo .
  define variable v-object      as character no-undo .
  define variable v-date        as character no-undo .
  define variable CurrGrpName   as character no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable Counter1      as integer   no-undo .
  define variable tmp           as decimal   no-undo .
  define variable it_pripost    as decimal   no-undo .
  define variable it_priperem   as decimal   no-undo .
  define variable it_priprvo    as decimal   no-undo .
  define variable it_privozv    as decimal   no-undo .
  define variable it_prielse    as decimal   no-undo .
  define variable it_rasprod    as decimal   no-undo .
  define variable it_rasvozv    as decimal   no-undo .
  define variable it_rasperem   as decimal   no-undo .
  define variable it_rasvnesh   as decimal   no-undo .
  define variable it_rasprvo    as decimal   no-undo .
  define variable it_rasspis    as decimal   no-undo .
  define variable it_raselse    as decimal   no-undo .
  define variable it_peresort   as decimal   no-undo .
  define variable it_izlish     as decimal   no-undo .
  define variable it_nedost     as decimal   no-undo .
  define variable it_ostend     as decimal   no-undo .
  define variable it_ostbegin   as decimal   no-undo .
  define variable v-date-start  as character no-undo .
  define variable v-date-end    as character no-undo .

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

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  find first tmp#grp no-error .
      if not available tmp#grp then do :
        message "Не выбраны группы товаров." view-as alert-box error .
        return .
      end .
  run xl-init in this-procedure .
  for each temp-grp-obj :
  delete   temp-grp-obj .
  end .
  for each temp-gds :
  delete   temp-gds .
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

  find first obj-list
       where obj-list.obj-type = v-cntxt-obj-type
         and obj-list.obj-code = v-cntxt-obj-code
         no-error .
       if available obj-list then do :
           assign v-cntxt-obj-name = obj-list.obj-name .
       end .

  for each buf_obj-list no-lock :
    assign
      x-store-code = buf_obj-list.obj-code
      x-store-type = buf_obj-list.obj-type
    .
    run calcitog in this-procedure.
      assign v-object = string("по движению сопутствующих товаров на ") + string(buf_obj-list.obj-name) .

      { gbl/hostcode.i buf_obj-list.obj-type buf_obj-list.obj-code v-host-code }

      for each tmp#grp :  /* составляем список товаров */
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
        create temp-grp-obj .
        assign
            temp-grp-obj.obj-code   = buf_obj-list.obj-code
            temp-grp-obj.obj-type   = buf_obj-list.obj-type
            temp-grp-obj.grpname    = CurrGrpName
         .
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type = buf_obj-list.obj-type
            and buf_gds-obj.obj-code = buf_obj-list.obj-code
            and buf_gds-obj.grp-name begins CurrGrpName
          use-index obj-grp :
          find first temp-gds
          where temp-gds.prod-code = buf_gds-obj.prod-code
            and temp-gds.prod-type = buf_gds-obj.prod-type
            and temp-gds.artic     = buf_gds-obj.artic
            and temp-gds.grp-name  = CurrGrpName
            use-index ii no-lock no-error .
            if not available temp-gds then do :
              create temp-gds .
                assign
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
      
        for each temp-gds no-lock :
          find first temp-grp-obj
            where temp-grp-obj.grpname  = temp-gds.grp-name
              and  temp-grp-obj.obj-code = buf_obj-list.obj-code
              and  temp-grp-obj.obj-type = buf_obj-list.obj-type
              use-index ii1 no-lock no-error .
          for each buf_ot-line
              where buf_ot-line.artic         = temp-gds.artic
              AND   buf_ot-line.fact-order   <= fact-order-2
              AND   buf_ot-line.fact-order    > fact-order-1
              AND   buf_ot-line.prod-code     = temp-gds.prod-code
              AND   buf_ot-line.prod-type     = temp-gds.prod-type
              AND   buf_ot-line.obj-code      = buf_obj-list.obj-code
              AND   buf_ot-line.obj-type      = buf_obj-list.obj-type
              AND   buf_ot-line.sum-type      = {&arh-cost}
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
    
   /*техпролив*/          if v-tech-pass or can-find(first buf_sale-doc where buf_sale-doc.doc-code = buf_ot-line.doc-code and buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell})
                            then do :
                              assign temp-grp-obj.prielse   = temp-grp-obj.prielse  + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                            end .
                            else do :
                              assign temp-grp-obj.pripost  = temp-grp-obj.pripost   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                            end .
                       end .
  /*перемещ.со скл.*/  when {&TDEDT_Pri_Perem} or when {&TDEDT_Vozvrat_Perem}
                                                    then assign temp-grp-obj.priperem   = temp-grp-obj.priperem  + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*перемещ.в груп.*/  when {&TDEDT_Pri_Prvo}       then assign temp-grp-obj.priprvo    = temp-grp-obj.priprvo   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*возврат от пок.*/  when {&TDEDT_Vozvrat_Vnesh}  then assign temp-grp-obj.privozv    = temp-grp-obj.privozv   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*прочие обороты */  when {&TDEDT_Corr_Acc_Price} or when {&TDEDT_Corr_Minus_Parts}
                       then do :
                          if buf_ot-line.sum-rubl > 0 then do :
                              assign temp-grp-obj.prielse   = temp-grp-obj.prielse   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*РАСХОД:*/             end .
                          else do :
                              assign temp-grp-obj.raselse   = temp-grp-obj.raselse   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                          end .
                       end.
  /*продажа*/          when {&TDEDT_Ras_Vnesh_Kass} 
                                                    then assign temp-grp-obj.rasprod    = temp-grp-obj.rasprod   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
 /*продажи - возврат*/ when {&TDEDT_Vozvrat_Vnesh_Kass} then assign temp-grp-obj.rasprod = temp-grp-obj.rasprod  - ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*возврат постав.*/  when {&TDEDT_Ras_Vnesh_VP}   then assign temp-grp-obj.rasvozv    = temp-grp-obj.rasvozv   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*перемещ.со скл.*/  when {&TDEDT_Ras_Perem}      then assign temp-grp-obj.rasperem   = temp-grp-obj.rasperem  + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
  /*перемещ.в груп.*/  when {&TDEDT_Spi_Prvo}       then assign temp-grp-obj.rasprvo    = temp-grp-obj.rasprvo   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
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
                              
                             if v-tech-pass or can-find(first buf_sale-doc where buf_sale-doc.doc-code = buf_ot-line.doc-code and buf_sale-doc.doc-kind = {&sale-add-tech-refuell})
                             then do :
                                assign temp-grp-obj.raselse    = temp-grp-obj.raselse   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl).
                             end .
                             else do :
                                assign temp-grp-obj.rasspis    = temp-grp-obj.rasspis   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl).
                             end .
                       end .
                       
                       when {&TDEDT_Ras_Vnesh}
                       then assign temp-grp-obj.rasvnesh = temp-grp-obj.rasvnesh   + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                       
/*ИНВЕНТАРИЗАЦИЯ:*/
  /*пересорт*/         when {&TDEDT_Peresort}       then assign temp-grp-obj.peresort   = temp-grp-obj.peresort  + (buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                       when {&TDEDT_Inv} then do :
  /*недостача*/          if buf_ot-line.sum-rubl < 0  then do :
                            assign temp-grp-obj.nedost   = temp-grp-obj.nedost    + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                         end.
  /*излишки*/            else do :
                            assign temp-grp-obj.izlish   = temp-grp-obj.izlish    + ABS(buf_ot-line.sum-rubl - buf_ot-line.VAT-rubl) .
                       end .
                end .
              end case .
          end.
        end.
        for each temp-grp-obj
         where temp-grp-obj.obj-code = buf_obj-list.obj-code
           and temp-grp-obj.obj-type = buf_obj-list.obj-type
           use-index ii1 no-lock :
              for each temp-gds
                where temp-gds.grp-name begins temp-grp-obj.grpname
                no-lock :
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
              assign
                  it_pripost      = it_pripost  + temp-grp-obj.pripost
                  it_priperem     = it_priperem + temp-grp-obj.priperem
                  it_priprvo      = it_priprvo  + temp-grp-obj.priprvo
                  it_privozv      = it_privozv  + temp-grp-obj.privozv
                  it_prielse      = it_prielse  + temp-grp-obj.prielse
                  it_rasprod      = it_rasprod  + temp-grp-obj.rasprod
                  it_rasvozv      = it_rasvozv  + temp-grp-obj.rasvozv
                  it_rasperem     = it_rasperem + temp-grp-obj.rasperem
                  it_rasvnesh     = it_rasvnesh + temp-grp-obj.rasvnesh
                  it_rasprvo      = it_rasprvo  + temp-grp-obj.rasprvo
                  it_rasspis      = it_rasspis  + temp-grp-obj.rasspis
                  it_raselse      = it_raselse  + temp-grp-obj.raselse
                  it_peresort     = it_peresort + temp-grp-obj.peresort
                  it_izlish       = it_izlish   + temp-grp-obj.izlish
                  it_nedost       = it_nedost   + temp-grp-obj.nedost
                  it_ostend       = it_ostend   + temp-grp-obj.ostend
                  it_ostbegin     = it_ostbegin + temp-grp-obj.ostbegin
                  .
        end.
  end. /*buf_list-object*/

   { gbl/working.i }

   { cmp/open-out.i stream out-stream " " {&CS_PS} }

   put stream out-stream unformatted
         {&new-line}
      + "Печатная форма предназначена только для вывода в Microsoft Excel."
      + {&new-line}
   .
   output stream out-stream close.

 for each temp-grp-obj no-lock by temp-grp-obj.grpname :
        assign v-count = v-count + 1 .

  run xl-write-line-data in this-procedure (  input v-count
                                            , input temp-grp-obj.grpname
                                            , input temp-grp-obj.ostbegin
                                            , input temp-grp-obj.pripost
                                            , input temp-grp-obj.priperem
                                            , input temp-grp-obj.priprvo
                                            , input temp-grp-obj.privozv
                                            , input temp-grp-obj.prielse
                                            , input temp-grp-obj.rasprod
                                            , input temp-grp-obj.rasvozv
                                            , input temp-grp-obj.rasperem
                                            , input temp-grp-obj.rasvnesh
                                            , input temp-grp-obj.rasprvo
                                            , input temp-grp-obj.rasspis
                                            , input temp-grp-obj.raselse
                                            , input temp-grp-obj.peresort
                                            , input temp-grp-obj.izlish
                                            , input temp-grp-obj.nedost
                                            , input temp-grp-obj.ostend
                                           ) .
  end .
  run xl-write-line-data in this-procedure (  input ""
                                            , input "ИТОГО:"
                                            , input it_ostbegin
                                            , input it_pripost
                                            , input it_priperem
                                            , input it_priprvo
                                            , input it_privozv
                                            , input it_prielse
                                            , input it_rasprod
                                            , input it_rasvozv
                                            , input it_rasperem
                                            , input it_rasvnesh
                                            , input it_rasprvo
                                            , input it_rasspis
                                            , input it_raselse
                                            , input it_peresort
                                            , input it_izlish
                                            , input it_nedost
                                            , input it_ostend
                                           ) .

    run xl-write-cell-data in this-procedure (
       input {&tg89xl-h_organization}
       , input v-firm
   ).
    run xl-write-cell-data in this-procedure (
       input {&tg89xl-h_object}
       , input v-object
   ).
    run xl-write-cell-data in this-procedure (
       input {&tg89xl-h_date}
       , input v-date
   ).

  run xl-close in this-procedure .
  Output stream PrnLibStream close .
  { rep/repfrm.i off }
  { gbl/stopwork.i }

   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
   os-rename
     value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
     value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
   .
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .
   define variable v-orient-page as character no-undo .
   run gbl/prnfilen.w   ( input "":U
                        , input 20
                        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
                        , input ReportFontNum
                        , output v-user-action
                        , output v-printed
                        ) .
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

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