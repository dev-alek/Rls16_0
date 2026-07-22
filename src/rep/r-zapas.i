/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Состояние запаса(закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 20/10/00
Author: Svetlana Chernova
Creation date: 20/10/00

*/
define input parameter x-store-code like clients.obj-code no-undo.
define input parameter x-store-type like clients.obj-type no-undo.
define input parameter x-base-type  like currency.curr-abbr no-undo.
define input parameter x-base-code  like currency.curr-code no-undo.
define input parameter xClassify    as character no-undo.
define input parameter xSortType    as character no-undo.
define input parameter xSumsOnly    as logical  no-undo.
define input parameter xShowZero    as logical  no-undo.
define input parameter xlongName    as logical  no-undo.
define input parameter xPartsDet    as logical  no-undo.
define input parameter x-photo      as logical  no-undo.
define input parameter x-alc-marks  as logical  no-undo .
/*define input parameter x-photo-size as character  no-undo.*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Состояние запаса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }

{ rep/r-sym.i }
{ rep/r-gl.i }
{ rep/f-fdec.i }
{ gbl/cur-time.i }
{ gbl/paramls.i  }
{ rep/lkp-font.i }

{ trg/factord.i  }
{ trg/partslib.i }
{ str/prl-vat.i  }
{ trg/partsfnc.i }
{ gbl/alc-lib.i  }
{ gbl/prn-lib.i "new shared" }
{ str/clcprtsl.i "only-one-parts" }
{ ref/gds-attr.i }
{ref/imagelist.i}
{ rep/html-conv.i }
{ gbl/key-rec.i  }
{ str/marks.i }

define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .

define variable  zap-date   as date no-undo.
define variable  tPrintRubl as log no-undo.
define variable  time-start as decimal no-undo .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .

define variable hndl-proc-egais-marks-lib as handle.
define variable v-parts-uniq-key-rec      as character no-undo .
define variable v-rezerv                  as integer   no-undo .
define variable v-marks                   as character no-undo .
define variable v-marks-num               as character no-undo .
define variable ii                        as integer   no-undo .
define variable v-reserv-marks            as integer   no-undo .
/*общий итог*/

define variable Tot-1 as decimal FORMAT "->>>>>>>>>>9.999" no-undo init 0.
define variable Tot-2 as decimal FORMAT "->>>>>>>>>>9.99" no-undo init 0.
define variable Tot-3 as decimal FORMAT "->>>>>>>>>>9.99" no-undo init 0.
define variable Tot-4 as decimal FORMAT "->>>>>>>>>>9.99" no-undo init 0.
define variable Tot-5 as decimal FORMAT "->>>>>>>>>>9.99" no-undo init 0.

/* итог по объекту*/
define variable oTot-1 as decimal FORMAT "->>>>>>>>>>9.999"  no-undo init 0.
define variable oTot-2 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable oTot-3 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable oTot-4 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable oTot-5 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.

/* итог по группе 1 */
define variable Tot-1-1 as decimal FORMAT "->>>>>>>>>>9.999"  no-undo init 0.
define variable Tot-1-2 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable Tot-1-3 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable Tot-1-4 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable Tot-1-5 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.


/* итог по группе 2 */
define variable Tot-2-1 as decimal FORMAT "->>>>>>>>>>9.999"  no-undo init 0.
define variable Tot-2-2 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable Tot-2-3 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable Tot-2-4 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.
define variable Tot-2-5 as decimal FORMAT "->>>>>>>>>>9.99"  no-undo init 0.

define buffer b-clients for clients .
define buffer buf_parts for ub.parts.
define buffer buf_tt-allsum for tt-allsum.
define buffer buf_goods for ub.goods.
define buffer buf_gen-attr for ub.gen-attr.

define variable    ObjName           as char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    RetClassify       as   char no-undo.
define variable    RetSortType       as   char no-undo.
define variable    Show-Negativ      as   logical no-undo.
define variable    Sums-Only         as   logical no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.
define variable    FirstLine         as  logical  no-undo.
define variable    Parts-Det         as  logical  no-undo.
define variable    v-photo           as logical  no-undo.
define variable    v-alc-marks       as logical  no-undo.
/*define variable    v-photo-size      as character  no-undo.*/
define variable v-goods-alcohol-prod    as logical   no-undo.
define variable gds-zap-part-print-code as character no-undo .
define variable v-show-part-code as character no-undo .

define variable parparentproc        as widget-handle no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-col               as integer   no-undo initial 11.
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .


  define variable v-cur-dn  as character no-undo .
  define variable v-price as decimal   no-undo .
  define variable v-cur-rt as decimal   no-undo .
  define variable v-cur-ex as decimal   no-undo .
  define variable v-cur-VAT-pc as decimal   no-undo .
  define variable v-cur-SLT-pc as decimal   no-undo .
  define variable v-cons-vat-pc as decimal   no-undo .

  define variable v-is-part-price as logical   no-undo .


define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* Local Variable Definitions ---                                       */

define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable rid-list as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base   no-undo  .
define variable gds-zap-prt-root      like ub.goods.prt-root    no-undo  .
define variable gds-zap-gds-name      like ub.goods.gds-name    no-undo  .
define variable gds-zap-gds-long-name as character format "x(120)" no-undo .
define variable gds-zap-part-b-code   like ub.bar-code.b-code   no-undo  .
define variable gds-zap-prod-type     like ub.goods.prod-type   no-undo  .
define variable gds-zap-prod-code     like ub.goods.prod-code   no-undo  .
define variable gds-zap-artic         like ub.goods.artic       no-undo  .
define variable gds-zap-b-code        like ub.bar-code.b-code   no-undo  .
define variable gds-zap-grp-name      like ub.goods.grp-name    no-undo  .
define variable gds-zap-prod-name     like ub.clients.obj-name  no-undo  .
define variable gds-zap-price-base    like ub.stk-tot.sum-base FORMAT "->>>>>>>>>>9.99" no-undo.
define variable gds-zap-price-nds     like ub.stk-tot.sum-base FORMAT "->>>>>>>>>>9.99" no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base FORMAT "->>>>>>>>>>9.99" no-undo.
define variable gds-zap-qnty          like ub.stk-tot.sum-base FORMAT "->>>>>>>>>9.999" no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base FORMAT "->>>>>>>>>>9.99" no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base FORMAT "->>>>>>>>>>9.99" no-undo.
define variable gds-zap-image         as character              no-undo .

DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
/*===================================================================================================================*/
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .

assign
  i=0
  zap-date      = x-Date-Alone
  Select-Good   = x-SelectGood
  PayType       = x-SET_PAY_TYPE
  RetClassify   = xClassify
  RetSortType   = xSortType
  Sums-Only     = xSumsOnly
  Show-Negativ  = xShowZero
  Parts-Det     = xPartsDet
  v-photo       = x-photo
  v-alc-marks   = x-alc-marks
/*  v-photo-size  = x-photo-size*/
  ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
  time-start    = time.

define variable v-fact-order-end as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input ( zap-date + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  RUN REPORT-EXECUTE.
/*------------------------------------------------------------------------------------------------*/
procedure foreach :
 do
 on error undo, return error return-value
 :

 
 FIND LAST  ub.stk-line where
                        ub.stk-line.artic      = gds-zap-artic
                  AND   ub.stk-line.fact-date <= zap-date
                  AND   ub.stk-line.obj-code   = x-store-code
                  AND   ub.stk-line.obj-type   = x-store-type
                  AND   ub.stk-line.prod-code  = gds-zap-prod-code
                  AND   ub.stk-line.prod-type  = gds-zap-prod-type
                  AND   ub.stk-line.sum-type   = (IF PayType = 2  then  {&arh-cost} /* учетная */
                                                               else  {&arh-crsa} )
                 AND    ub.stk-line.cat-id       = {&root-cat-id}
                       USE-INDEX category no-lock no-error.
        IF AVAILABLE ub.stk-line Then DO:
            IF  tPrintRubl  THEN
                  ASSIGN gds-zap-qnty       = ub.stk-line.fact-qnty
                        gds-zap-stoim-base  = ub.stk-line.sum-rubl
                        gds-zap-Nds         = ub.stk-line.VAT-rubl
                        gds-zap-Np          = ub.stk-line.SLT-rubl .
              ELSE
                  ASSIGN gds-zap-qnty       =  ub.stk-line.fact-qnty
                        gds-zap-stoim-base  =  ub.stk-line.sum-base
                        gds-zap-Nds         =  ub.stk-line.VAT-base
                        gds-zap-Np          =  ub.stk-line.SLT-base .
             End.
          Else ASSIGN gds-zap-qnty       = 0
                      gds-zap-price-base = 0
                      gds-zap-price-nds = 0
                      gds-zap-stoim-base = 0
                      gds-zap-Nds   = 0
                      gds-zap-Np    = 0.
        Assign
          gds-zap-price-base = if (gds-zap-qnty <> 0) Then round((gds-zap-stoim-base / gds-zap-qnty),2) Else 0
          tot_tqnty          = gds-zap-stoim-base - gds-zap-Nds
          gds-zap-price-nds = if (gds-zap-qnty <> 0) Then round( (tot_tqnty / gds-zap-qnty) , 2) Else 0
          .
              if v-photo = yes then do:
                  IF mImagePh THEN
                DO:

                  find first buf_goods where buf_goods.artic = gds-zap-artic and buf_goods.prod-code = gds-zap-prod-code and buf_goods.prod-type = gds-zap-prod-type no-error.
                  if available buf_goods then do:
                      RUN gds-attr-value ( buf_goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
                      RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, buf_goods.gds-code, OUTPUT vImageList).
                  gds-zap-image = entry (1,vImageList).
                  end.

                v-col = 12.
                END.

              end.

 end. /* do */
end procedure. /* foreach */

procedure display-line :
define variable v-sum-dsc-rubl-acc-no-nds as decimal no-undo .  
 do
 on error undo, return error return-value
 :
     i = i + 1.
     IF  NOT (NOT Show-Negativ  AND (round(gds-zap-qnty,3) = 0 and round(gds-zap-stoim-base,2) = 0 and round(gds-zap-Nds,2) = 0 )) then DO:
        IF NOT Sums-Only then DO:
          if fr = true then do:
                          if fr0 = true then do:
                      
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="' + string(v-col) + '"> ' + tmp#stroka0 + '</TD>'skip
                            '</TR>'skip
                            .
                              PUT stream OutStr-html  tmp#stroka0 format "X(100)" skip .
                              num#str# = num#str# + 1.
                              num#col# = 1.

                              fr0 = false .
                           end.
                       put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="' + string(v-col) + '"> ' + tmp#stroka + '</TD>'skip
                            '</TR>'skip
                            .
                        PUT stream  OutStr-html   space(6) tmp#stroka format "X(100)" skip .
                        num#str# = num#str# + 1.
                        num#col# = 2.

                        fr = false .
          end.
            if not Parts-Det then do :
              put stream OutStr-html unformatted
                '<TR>'skip
                '<TD style="text-align: center"> ' + string(gds-zap-b-code) + '</TD>'skip
                '<TD style="text-align: center"> ' + string(gds-zap-artic) + '</TD>'skip
                '<TD> ' + string(gds-zap-gds-name) + '</TD>'skip
                '<TD style="text-align: center"> ' + string(gds-zap-unit-base) + '</TD>'skip
/* Количество */    '<TD num="0.000" val="' + fnc-convert-dot-to-colon(gds-zap-qnty,      "->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if gds-zap-qnty <> ? then fnc-convert-dot-to-colon(gds-zap-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
/* Цена */          '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-price-base,"->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-price-base <> ? then fnc-convert-dot-to-colon(gds-zap-price-base,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* Стоимость */     '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-stoim-base,"->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-stoim-base <> ? then fnc-convert-dot-to-colon(gds-zap-stoim-base,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* НДС */           '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-Nds,       "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-Nds <> ? then fnc-convert-dot-to-colon(gds-zap-Nds,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* НП */            '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-Np,        "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-Np <> ? then fnc-convert-dot-to-colon(gds-zap-Np,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* Цена без НДС */  '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-price-nds, "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-price-nds <> ? then fnc-convert-dot-to-colon(gds-zap-price-nds,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* Сумма без НДС */ '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(tot_tqnty,         "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if tot_tqnty <> ? then fnc-convert-dot-to-colon(tot_tqnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
              .                
                if v-photo then do:
                              put stream OutStr-html unformatted
                                  '<TD style="text-align: center; width: 20px;">'skip
                                  '<img  src="' + gds-zap-image + '"; alt="Фото товара" style="height: 50px;"/>'
                                  '</TD>'skip
                              .                
                end.  
              put stream OutStr-html unformatted
                '</TR>'skip    
              .                
                run new-tmp-page .
                  num#str# = num#str# + 1.
                  num#col# = 1.
            end.
            /*Детализация по партиям*/
            else do :
              put stream OutStr-html unformatted
                '<TR>'skip
                  '<TD style="text-align: center"> ' + string(gds-zap-b-code) + '</TD>'skip
                  '<TD style="text-align: center"> ' + string(gds-zap-artic) + '</TD>'skip
                  '<TD style="text-align: left"> ' + string(gds-zap-gds-name) + '</TD>'skip
                  '<TD style="text-align: center"> ' + if string(gds-zap-part-b-code) = ? then " " + '</TD>' else string(gds-zap-part-b-code) + '</TD>'skip
                  '<TD style="text-align: center"> ' + string(gds-zap-unit-base) + '</TD>'skip
'<TD num="0.000" val="' + fnc-convert-dot-to-colon(gds-zap-qnty,      "->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if gds-zap-qnty <> ? then fnc-convert-dot-to-colon(gds-zap-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
'<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-price-base,"->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-price-base <> ? then fnc-convert-dot-to-colon(gds-zap-price-base,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
'<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-stoim-base,"->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-stoim-base <> ? then fnc-convert-dot-to-colon(gds-zap-stoim-base,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
'<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-Nds,       "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-Nds <> ? then fnc-convert-dot-to-colon(gds-zap-Nds,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
'<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-Np,        "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-Np <> ? then fnc-convert-dot-to-colon(gds-zap-Np,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
'<TD num="0.00"  val="' + fnc-convert-dot-to-colon(gds-zap-price-nds, "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if gds-zap-price-nds <> ? then fnc-convert-dot-to-colon(gds-zap-price-nds,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
'<TD num="0.00"  val="' + fnc-convert-dot-to-colon(tot_tqnty,         "->>>>>>>>>>>9.99", 2) + '" style="text-align: right"> ' + if tot_tqnty <> ? then fnc-convert-dot-to-colon(tot_tqnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
              .                          
              if v-photo then do:
                            put stream OutStr-html unformatted
                                '<TD style="text-align: center; width: 20px;">'skip
                                  '<img src="' + gds-zap-image + '"; alt="Фото товара" style="height: 50px;"/>'
                                  '</TD>'skip
                            .                          
              end.
              put stream OutStr-html unformatted
                '</TR>'skip    
              .                        
              run new-tmp-page .
                num#str# = num#str# + 1.
                num#col# = 1.
                for each temp-parts no-lock :
                    gds-zap-part-print-code = ''.
                    gds-zap-part-b-code = ?.
                    find first buf_parts where  buf_parts.obj-type   = temp-parts.obj-type   and
                        buf_parts.obj-code   = temp-parts.obj-code   and
                        buf_parts.artic      = temp-parts.artic      and
                        buf_parts.prod-type  = temp-parts.prod-type  and
                        buf_parts.prod-code  = temp-parts.prod-code  and
                        buf_parts.in-code    = temp-parts.in-code    /*and
                                              buf_parts.out-code   = temp-parts.out-code   and
                                              buf_parts.part-code  = temp-parts.part-code*/  no-lock no-error.
                      /* Является ли товар алкогольной продукцией */
                { gbl/gdscdat.i
                    gds-zap-b-code
                    "'alcohol-prod=request':u"
                    v-goods-alcohol-prod
                    no-error
                  }
                    if (v-goods-alcohol-prod = false) and (temp-parts.part-code = '':u)
                        then 
                    do:
                        v-show-part-code = '------':u .
                    end.
                    else 
                    do:
                        if v-alc-marks then 
                        do:             
                            run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                ,input (buffer buf_parts:handle)
                                ,output v-parts-uniq-key-rec).         
                        
                          
                            run bge/egais-marks-find.p persistent (output hndl-proc-egais-marks-lib) no-error .

                            run find-marks-part in hndl-proc-egais-marks-lib (input v-parts-uniq-key-rec, output v-marks, output v-rezerv).
                                        
                            delete object hndl-proc-egais-marks-lib no-error. /* не забываем удалять также при любом ошибочном (досрочном) выходе вашей процедуры */
                        end.    

                        run partsfnc_get-parts-show-code in this-procedure
                            (input  temp-parts.part-code
                            ,input  temp-parts.mark-db-num
                            ,input  temp-parts.mark-code
                            ,input  temp-parts.alc-bottling-date
                            ,input  v-goods-alcohol-prod
                            ,output v-show-part-code
                            ) .

                    end.                  
                        
                  { gbl/partbcod.i
                    buf_parts
                    gds-zap-part-b-code
                    no-error
                  }
                    if not(gds-zap-part-b-code = 0 or gds-zap-part-b-code = ? ) then 
                    do:
                        gds-zap-part-print-code =  string(gds-zap-part-b-code).
                        { gbl/bcprcex.i
                        buf_parts.obj-type
                        buf_parts.obj-code
                        gds-zap-part-b-code
                        0
                        v-fact-order-end
                        v-cur-dn
                        v-price
                        v-cur-rt
                        v-cur-ex
                        v-cur-VAT-pc
                        v-cur-SLT-pc
                        no-error
                      }
                  end.
                  else gds-zap-part-print-code = buf_parts.in-code.
                      { gbl/consvtpc.i
                        buf_parts.host-code
                        v-cons-vat-pc
                      }
                      if v-cons-vat-pc = ? then v-cons-vat-pc = 0.
                  buffer-copy temp-parts to tt-clcparts.
                  run clcprtsl_calc-parts in this-procedure
                    (input recid(tt-clcparts)
                    ,input false /* paris-doc         */
                    ,input true /*(if v-is-part-price = true  then true else false)*/ /* paris-cur         */
                    ,input ?     /* parroad-tax       */
                    ,input ?     /* parexcise         */
                    ,input ?     /* parvat-pc         */
                    ,input ?     /* parcons-vat-pc    */
                    ,input ?     /* parslt-pc         */
                    ,input ?     /* parbase-rate      */
                    ,input ?     /* parbase-scale     */
                    ,input ?     /* parr-b            */
                    ,input v-price /*(if v-is-part-price = true  then v-price else ? )*/     /* parcur-base       */
                    ,input v-cur-rt     /* parcur-road-tax   */
                    ,input v-cur-ex     /* parcur-excise     */
                    ,input v-cur-VAT-pc     /* parcur-vat-pc     */
                    ,input v-cons-vat-pc     /* parcurcons-vat-pc */
                    ,input v-cur-SLT-pc     /* parcurslt-pc      */
                    ) no-error .
                  find first buf_tt-allsum
                       where buf_tt-allsum.sum-type = {&sum-general}
                       no-error .

                  IF PayType = 2 then do :
                    if tPrintRubl then do :
                      v-sum-dsc-rubl-acc-no-nds = buf_tt-allsum.sum-dsc-rubl-acc - buf_tt-allsum.vat-rubl-acc .
                      put stream OutStr-html unformatted
                        '<TR>'skip
                        '<TD></TD>'skip
                        '<TD></TD>'skip
                        '<TD style="text-align: center"> ' + string(v-show-part-code) + '</TD>'skip
                        '<TD style="text-align: center"> ' + if string(gds-zap-part-print-code) = ? then " " else string(gds-zap-part-print-code) + '</TD>'skip
                        '<TD style="text-align: center"> ' + string(gds-zap-unit-base) + '</TD>'skip
/* Количество */    '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if buf_tt-allsum.fact-qnty <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
/* Цена */          '<TD num="0.00"  val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then buf_tt-allsum.sum-dsc-rubl-acc / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then buf_tt-allsum.sum-dsc-rubl-acc / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '</TD>'skip
/* Стоимость */     '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.sum-dsc-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip  
/* НДС */           '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.vat-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* НП */            '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.slt-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
/* Цена без НДС */  '<TD num="0.00"  val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then v-sum-dsc-rubl-acc-no-nds / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then v-sum-dsc-rubl-acc-no-nds / buf_tt-allsum.fact-qnty else 0  ),"->>>>>>>>>>>9.99",2) + '</TD>'skip
/* Сумма без НДС */ '<TD num="0.00"  val="' + fnc-convert-dot-to-colon(v-sum-dsc-rubl-acc-no-nds,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + fnc-convert-dot-to-colon(v-sum-dsc-rubl-acc-no-nds,"->>>>>>>>>>>9.99",2) + '</TD>'skip
                      .              
                      if v-photo then do:
                            put stream OutStr-html unformatted
                                '<TD style="text-align: center; width: 20px;">'skip
                                  '<img src="' + gds-zap-image + '"; alt="Фото товара" style="height: 50px;"/>'
                                  '</TD>'skip
                            '</TR>'skip    
                            .              
                            do ii = 1 to NUM-ENTRIES(v-marks, ","):
                            v-marks-num = entry(ii, v-marks, ",").
    
                            find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                                              and buf_gen-attr.attr-code  = v-marks-num no-error .
                            if AVAILABLE buf_gen-attr then do:
                                v-reserv-marks = buf_gen-attr.whole-send-news .                            
                            end.    
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD style="text-align: left"> ' + string(v-marks-num) + '</TD>'skip
                                '<TD style="text-align: center"> ' + string(v-reserv-marks) + '</TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip  
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                            '</TR>'skip    
                            .         
                            end.                
                      end.
                      else do:
                            put stream OutStr-html unformatted
                            '</TR>'skip    
                            .  
                            do ii = 1 to NUM-ENTRIES(v-marks, ","):
                            v-marks-num = entry(ii, v-marks, ",").
    
                            find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                                              and buf_gen-attr.attr-code  = v-marks-num no-error .
                            if AVAILABLE buf_gen-attr then do:
                                v-reserv-marks = buf_gen-attr.whole-send-news .                            
                            end.    
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD style="text-align: left"> ' + string(v-marks-num) + '</TD>'skip
                                '<TD style="text-align: center"> ' + string(v-reserv-marks) + '</TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip  
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                            '</TR>'skip    
                            .         
                            end.       
                        end.
                    end.  /*   if tPrintRubl   */
                    else do :
                      if v-photo then do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD style="text-align: center"> ' + string(v-show-part-code) + '</TD>'skip
                                '<TD style="text-align: center"> </TD>'skip
                                '<TD style="text-align: center"> ' + string(gds-zap-unit-base) + '</TD>'skip
                                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if buf_tt-allsum.fact-qnty <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then buf_tt-allsum.sum-dsc-rubl-acc / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then buf_tt-allsum.sum-dsc-rubl-acc / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '</TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-rubl-acc - buf_tt-allsum.vat-rubl-acc) / buf_tt-allsum.fact-qnty else 0  ),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-rubl-acc - buf_tt-allsum.vat-rubl-acc) / buf_tt-allsum.fact-qnty else 0  ),"->>>>>>>>>>>9.99",2) + '</TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.sum-dsc-base-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip  
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.vat-base-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.slt-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-base-acc - buf_tt-allsum.vat-base-acc),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-base-acc - buf_tt-allsum.vat-base-acc),"->>>>>>>>>>>9.99",2) + '</TD>'skip
                                '<TD style="text-align: center; width: 20px;">'skip
                                  '<img src="' + gds-zap-image + '"; alt="Фото товара" style="height: 50px;"/>'
                                  '</TD>'skip
                            '</TR>'skip    
                            .  
                      end.
                      else do:  
                             put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD style="text-align: center"> ' + string(v-show-part-code) + '</TD>'skip
                                '<TD style="text-align: center"> </TD>'skip
                                '<TD style="text-align: center"> ' + string(gds-zap-unit-base) + '</TD>'skip
                                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if buf_tt-allsum.fact-qnty <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then buf_tt-allsum.sum-dsc-base-acc / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then buf_tt-allsum.sum-dsc-base-acc / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '</TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-base-acc - buf_tt-allsum.vat-base-acc) / buf_tt-allsum.fact-qnty else 0  ),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-base-acc - buf_tt-allsum.vat-base-acc) / buf_tt-allsum.fact-qnty else 0  ),"->>>>>>>>>>>9.99",2) + '</TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.sum-dsc-base-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip  
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.vat-base-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.slt-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-base-acc - buf_tt-allsum.vat-base-acc),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-base-acc - buf_tt-allsum.vat-base-acc),"->>>>>>>>>>>9.99",2) + '</TD>'skip
                            '</TR>'skip    
                            .  
                        end.
                    end.
                    run new-tmp-page .
                    num#str# = num#str# + 1.
                    num#col# = 1.
                  end.     /*  if PayType = 2    */
                  else do :
                    if v-photo then do:
                             put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD> ' + string(v-show-part-code) + '</TD>'skip
                                '<TD style="text-align: center"> ' + if string(gds-zap-part-b-code) = ? then " " else string(gds-zap-part-b-code) + '</TD>'skip
                                '<TD> ' + string(gds-zap-unit-base) + '</TD>'skip
                                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if buf_tt-allsum.fact-qnty <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(v-price,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if v-price <> 0 then fnc-convert-dot-to-colon(v-price,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</TD>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur)  / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur)  / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '</TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.sum-dsc-rubl-cur <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip  
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.vat-rubl-cur <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.slt-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur),"->>>>>>>>>>>9.99",2) + '</TD>'skip
                                '<TD style="text-align: center; width: 20px;">'skip
                                  '<img src="' + gds-zap-image + '"; alt="Фото товара" style="height: 50px;"/>'
                                  '</TD>'skip
                            '</TR>'skip    
                            .  
                      end.
                      else do:
                              put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD> ' + string(v-show-part-code) + '</TD>'skip
                                '<TD style="text-align: center"> ' + if string(gds-zap-part-b-code) = ? then " " else string(gds-zap-part-b-code) + '</TD>'skip
                                '<TD> ' + string(gds-zap-unit-base) + '</TD>'skip
                                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if buf_tt-allsum.fact-qnty <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.fact-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(v-price,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if v-price <> 0 then fnc-convert-dot-to-colon(v-price,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</TD>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur)  / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '" style="text-align: right"> ' +  fnc-convert-dot-to-colon((if buf_tt-allsum.fact-qnty <> 0 then (buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur)  / buf_tt-allsum.fact-qnty else 0),"->>>>>>>>>>>9.99",2 ) + '</TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.sum-dsc-rubl-cur <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.sum-dsc-rubl-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip  
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.vat-rubl-cur <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.vat-rubl-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_tt-allsum.slt-rubl-acc <> ? then fnc-convert-dot-to-colon(buf_tt-allsum.slt-rubl-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + fnc-convert-dot-to-colon((buf_tt-allsum.sum-dsc-rubl-cur - buf_tt-allsum.vat-rubl-cur),"->>>>>>>>>>>9.99",2) + '</TD>'skip
                            '</TR>'skip    
                            .
                      end.  
                      run new-tmp-page .
                        num#str# = num#str# + 1.
                        num#col# = 1.
                  end.
              end.  /* for each temp-parts */
            end.
       End.
            Assign
                   TOT-1  = tot-1 + gds-zap-qnty
                   TOT-2  = tot-2 + gds-zap-stoim-base
                   TOT-3  = tot-3 + tot_tqnty
                   TOT-4  = tot-4 + gds-zap-Nds
                   TOT-5  = tot-5 + gds-zap-Np
                   oTOT-1 = otot-1 + gds-zap-qnty
                   oTOT-2 = otot-2 + gds-zap-stoim-base
                   oTOT-3 = otot-3 + tot_tqnty
                   oTOT-4 = otot-4 + gds-zap-Nds
                   oTOT-5 = otot-5 + gds-zap-Np
                   TOT-1-1 = tot-1-1 + gds-zap-qnty
                   TOT-1-2 = tot-1-2 + gds-zap-stoim-base
                   TOT-1-3 = tot-1-3 + tot_tqnty
                   TOT-1-4 = tot-1-4 + gds-zap-Nds
                   TOT-1-5 = tot-1-5 + gds-zap-Np
                   TOT-2-1 = tot-2-1 + gds-zap-qnty
                   TOT-2-2 = tot-2-2 + gds-zap-stoim-base
                   TOT-2-3 = tot-2-3 + tot_tqnty
                   TOT-2-4 = tot-2-4 + gds-zap-Nds
                   TOT-2-5 = tot-2-5 + gds-zap-Np.
      END.


 end. /* do */
end procedure. /* display-line */

procedure print-header :
 do
 on error undo, return error return-value
 :
   
           run get-report-num (
            output p-report-id
        ).
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    /*шапка*/
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
             "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip

                '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        '<TR class="set_columns">'skip
            .
            
 /*определяем кол-во колонок*/
 if not Parts-Det then do :
    if v-photo then do:
    put stream OutStr-html unformatted
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 200px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 100px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 14px;">СОСТОЯНИЕ ЗАПАСА</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 14px;">на ' + string(zap-date,"99.99.9999") + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 14px;">' + string( trim(str3)) + '</TD>'skip
        '</TR>'skip
/*        '<TR>'skip                                                                    */
/*            '<TD colspan="12" STYLE="font-size: 16px;">' + string( str2) + '</TD>'skip*/
/*        '</TR>'skip                                                                   */
    .
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 14px;">' + Entry(i,str4,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 14px;">' + Entry(i,ReportHeader,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     if tPrintRubl then do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="12">Цены указаны в {&abbr_rub_allshift}</TD>'skip
            '</TR>'skip    
            .
     end.
     else do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="12">Цены указаны в ' + x-base-type + '</TD>'skip
            '</TR>'skip    
            .
     end. 
     put stream OutStr-html unformatted
            '</thead>' skip
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Код</TH>'skip
            '<TH style="text-align: center;">Артикул</TH>'skip
            '<TH style="text-align: center;">Название товара</TH>'skip
            '<TH style="text-align: center;">Ед. изм.</TH>'skip
            '<TH style="text-align: center;">Количество</TH>'skip
            '<TH style="text-align: center;">Цена</TH>'skip
            '<TH style="text-align: center;">Стоимость</TH>'skip
            '<TH style="text-align: center;">НДС</TH>'skip
            '<TH style="text-align: center;">НП</TH>'skip
            '<TH style="text-align: center;">Цена без НДС</TH>'skip
            '<TH style="text-align: center;">Сумма без НДС</TH>'skip
            '<TH style="text-align: center; width: 100px;">Фото товара</TH>'skip
        '</TR>'skip    
            .
            
    end.
    else do:   
    put stream OutStr-html unformatted
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 200px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">СОСТОЯНИЕ ЗАПАСА</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">на ' + string(zap-date,"99.99.9999") + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string( trim(str3)) + '</TD>'skip
        '</TR>'skip
/*        '<TR>'skip                                                                    */
/*            '<TD colspan="11" STYLE="font-size: 16px;">' + string( str2) + '</TD>'skip*/
/*        '</TR>'skip                                                                   */
    .
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + Entry(i,str4,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.

     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + Entry(i,ReportHeader,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     if tPrintRubl then do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="11">Цены указаны в {&abbr_rub_allshift}</TD>'skip
            '</TR>'skip    
            .
     end.
     else do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="11">Цены указаны в ' + x-base-type + '</TD>'skip
            '</TR>'skip    
            .
     end. 
     put stream OutStr-html unformatted
            '</thead>' skip
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Код</TH>'skip
            '<TH style="text-align: center;">Артикул</TH>'skip
            '<TH style="text-align: center;">Название товара</TH>'skip
            '<TH style="text-align: center;">Ед. изм.</TH>'skip
            '<TH style="text-align: center;">Количество</TH>'skip
            '<TH style="text-align: center;">Цена</TH>'skip
            '<TH style="text-align: center;">Стоимость</TH>'skip
            '<TH style="text-align: center;">НДС</TH>'skip
            '<TH style="text-align: center;">НП</TH>'skip
            '<TH style="text-align: center;">Цена без НДС</TH>'skip
            '<TH style="text-align: center;">Сумма без НДС</TH>'skip
        '</TR>'skip    
            .
            
      end. /*else v-photo*/
    end.
    else do :
      if v-photo then do:
          put stream OutStr-html unformatted
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 200px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 100px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 16px;">СОСТОЯНИЕ ЗАПАСА</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 16px;">на ' + string(zap-date,"99.99.9999") + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 16px;">ФАКТИЧЕСКОЕ наличие ' + string( trim(str3)) + '</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 16px;">' + string( str2) + '</TD>'skip
        '</TR>'skip
    .
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
     put stream OutStr-html unformatted 
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 16px;">' + Entry(i,str4,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
     put stream OutStr-html unformatted 
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 16px;">' + Entry(i,ReportHeader,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     if tPrintRubl then do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="13">Цены указаны в {&abbr_rub_allshift}</TD>'skip
            '</TR>'skip    
            .
     end.
     else do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="13">Цены указаны в ' + x-base-type + '</TD>'skip
            '</TR>'skip 
            .
     end. 
         put stream OutStr-html unformatted
            '</thead>'skip   
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Код</TH>'skip
            '<TH style="text-align: center;">Артикул</TH>'skip
            '<TH style="text-align: center;">Название товара</TH>'skip
            '<TH style="text-align: center;">Бар-код партии</TH>'skip
            '<TH style="text-align: center;">Ед. изм.</TH>'skip
            '<TH style="text-align: center;">Количество</TH>'skip
            '<TH style="text-align: center;">Цена</TH>'skip
            '<TH style="text-align: center;">Стоимость</TH>'skip
            '<TH style="text-align: center;">НДС</TH>'skip
            '<TH style="text-align: center;">НП</TH>'skip
            '<TH style="text-align: center;">Цена без НДС</TH>'skip
            '<TH style="text-align: center;">Сумма без НДС</TH>'skip
            '<TH style="text-align: center; width: 90px;">Фото товара</TH>'skip
        '</TR>'skip    
            .
      end.
      else do:  
          put stream OutStr-html unformatted
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 100px;"></TD>'skip
            '<TD style="width: 200px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 16px;">СОСТОЯНИЕ ЗАПАСА</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 16px;">на ' + string(zap-date,"99.99.9999") + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 16px;">ФАКТИЧЕСКОЕ наличие ' + string( trim(str3)) + '</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 16px;">' + string( str2) + '</TD>'skip
        '</TR>'skip
    .
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
     put stream OutStr-html unformatted 
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 16px;">' + Entry(i,str4,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
     put stream OutStr-html unformatted 
        '<TR>'skip
            '<TD colspan="12" STYLE="font-size: 16px;">' + Entry(i,ReportHeader,chr(10)) + '</TD>'skip
        '</TR>'skip
    .
     End.
     if tPrintRubl then do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="12">Цены указаны в {&abbr_rub_allshift}</TD>'skip
            '</TR>'skip    
            .
     end.
     else do:
            put stream OutStr-html unformatted
            '<TR>'skip
                '<TD colspan="12">Цены указаны в ' + x-base-type + '</TD>'skip
            '</TR>'skip 
            .
     end. 
         put stream OutStr-html unformatted
            '</thead>'skip   
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Код</TH>'skip
            '<TH style="text-align: center;">Артикул</TH>'skip
            '<TH style="text-align: center;">Название товара</TH>'skip
            '<TH style="text-align: center;">Бар-код партии</TH>'skip
            '<TH style="text-align: center;">Ед. изм.</TH>'skip
            '<TH style="text-align: center;">Количество</TH>'skip
            '<TH style="text-align: center;">Цена</TH>'skip
            '<TH style="text-align: center;">Стоимость</TH>'skip
            '<TH style="text-align: center;">НДС</TH>'skip
            '<TH style="text-align: center;">НП</TH>'skip
            '<TH style="text-align: center;">Цена без НДС</TH>'skip
            '<TH style="text-align: center;">Сумма без НДС</TH>'skip
        '</TR>'skip    
            .
    end. /*else do: v-photo*/   
 end.

   Assign
      Tot-1=0
      Tot-2=0
      Tot-3=0
      Tot-4=0
      Tot-5=0
      Tot-1-1=0
      Tot-1-2=0
      Tot-1-3=0
      Tot-1-4=0
      Tot-1-5=0
      Tot-2-1=0
      Tot-2-2=0
      Tot-2-3=0
      Tot-2-4=0
      Tot-2-5=0
      break_group = true
      break_group1 = true.


 end. /* do */
end procedure. /* print-header */

procedure Print-Footer :
 do
 on error undo, return error return-value
 :
 define variable var-1 as integer no-undo .
 define variable var-2 as integer no-undo .
    if not Parts-Det then do :
        if v-photo then do:
                              put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD> Итого </TD>'skip
                                  '<TD style="text-align: center"></TD>'skip
                                  '<TD style="text-align: center"></TD>'skip
                                  '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1 <> ? then fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2 <> ? then fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-4 <> ? then fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-5 <> ? then fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-3 <> ? then fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                              '</TR>'skip    
                              .            
        end.
        else do:  
                              put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD> Итого </TD>'skip
                                  '<TD style="text-align: center"></TD>'skip
                                  '<TD style="text-align: center"></TD>'skip
                                  '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1 <> ? then fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2 <> ? then fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-4 <> ? then fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-5 <> ? then fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-3 <> ? then fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                              '</TR>'skip    
                              .    
      end.
    end.
    else do :
      if v-photo then do:
                              put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD> Итого </TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1 <> ? then fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2 <> ? then fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-4 <> ? then fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-5 <> ? then fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-3 <> ? then fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                              '</TR>'skip    
                              .  
      end.
      else do:  
                              put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD> Итого </TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD style="text-align: right"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1 <> ? then fnc-convert-dot-to-colon(Tot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2 <> ? then fnc-convert-dot-to-colon(Tot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-4 <> ? then fnc-convert-dot-to-colon(Tot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-5 <> ? then fnc-convert-dot-to-colon(Tot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-3 <> ? then fnc-convert-dot-to-colon(Tot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                              '</TR>'skip    
                              .    
      end.
    end.

      assign
       num#str# = num#str# + 1
       num#col# =  1
       var-1 = num#str#
       var-2 = num#col#
       .

      assign
       num#str# = num#str# + 1
       num#col# =  1
       .
             if v-photo then do:
/*                            put stream OutStr-html unformatted*/
/*                            '<tfoot>'skip                                                                    */
/*                            '<tr>'                                                                           */
/*                                '<TD colspan="2"> Время формирования отчета </TD>' skip                      */
/*                                '<TD style="text-align: right">' + string( time - time-start ) + '</TD>' skip*/
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD></TD>' skip                                                             */
/*                                '<TD></TD>' skip                                                             */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                            '</tr>'                                                                          */
/*                            '</Tfoot>'skip                                                                   */
/*                            .                                                                                */
      run u-line.
                            put stream OutStr-html unformatted
                            '<tfoot>'skip
                                '<tr>'
                                    '<TD colspan="12">Итого ' + string(tot-1) + ' единиц , на сумму ' +   string(trim( string(tot-2,"->>>>>>>>>>>>9.99"))) + 
            '(' + (if tprintrubl then '{&abbr_rub_allshift}' else x-base-type ) + ')</TD>' skip
                                '</tr>'    
                                '<tr>'
                                   '<TD colspan="12">Время формирования отчета ' + string( time - time-start) + '</TD>' skip
                                '</tr>'    
                            '</Tfoot>'skip    
                            .
             end.
             else do:  
/*                            put stream OutStr-html unformatted                                               */
/*                            '<tfoot>'skip                                                                    */
/*                            '<tr>'                                                                           */
/*                                '<TD colspan="2"> Время формирования отчета </TD>' skip                      */
/*                                '<TD style="text-align: right">' + string( time - time-start ) + '</TD>' skip*/
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD></TD>' skip                                                             */
/*                                '<TD></TD>' skip                                                             */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                                '<TD style="text-align: right"></TD>' skip                                   */
/*                            '</tr>'                                                                          */
/*                            '</Tfoot>'skip                                                                   */
/*                            .                                                                                */
      run u-line.
                            put stream OutStr-html unformatted
                            '<tfoot>'skip
                                '<tr>'
                                    '<TD colspan="11">Итого ' + string(tot-1) + ' единиц , на сумму ' +   string(trim( string(tot-2,"->>>>>>>>>>>>9.99"))) + 
            '(' + (if tprintrubl then '{&abbr_rub_allshift}' else x-base-type ) + ')</TD>' skip
                                '</tr>'    
                                '<tr>'
                                   '<TD colspan="11">Время формирования отчета ' + string( time - time-start) + '</TD>' skip
                                '</tr>'    
                            '</Tfoot>'skip    
                            .
                 end.           
 end. /* do */
end procedure. /* Print-Footer */


procedure Print-Footer-o :
 do
 on error undo, return error return-value
 :

define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .

    if not Parts-Det then do :
      if v-photo then do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD> Итого по </TD>' skip
                                '<TD></TD>' skip
                                '<TD>' + string(objname) + '</TD>' skip
                                '<TD style="text-align: right">' '</TD>' skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if oTot-1 <> ? then fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-2 <> ? then fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-4 <> ? then fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-5 <> ? then fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-3 <> ? then fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD></TD>' skip
                            '</TR>'skip    
                            .   
      end.
      else do:   
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD> Итого по </TD>' skip
                                '<TD></TD>' skip
                                '<TD>' + string(objname) + '</TD>' skip
                                '<TD style="text-align: right">' '</TD>' skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if oTot-1 <> ? then fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-2 <> ? then fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-4 <> ? then fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-5 <> ? then fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-3 <> ? then fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                            '</TR>'skip    
                            .   
      end.
    end.
    else do :
        if v-photo then do:
                            put stream OutStr-html unformatted
                            '<TR>' skip
                                '<TD> Итого по </TD>' skip
                                '<TD></TD>' skip
                                '<TD>' + string(objname) + '</TD>' skip
                                '<TD></TD>' skip
                                '<TD></TD>' skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if oTot-1 <> ? then fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-2 <> ? then fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-4 <> ? then fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-5 <> ? then fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-3 <> ? then fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<td></td>'
                            '</TR>' skip    
                            . 
         end.     
         else do:
                            put stream OutStr-html unformatted
                            '<TR>' skip
                                '<TD> Итого по </TD>' skip
                                '<TD></TD>' skip
                                '<TD>' + string(objname) + '</TD>' skip
                                '<TD></TD>' skip
                                '<TD></TD>' skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if oTot-1 <> ? then fnc-convert-dot-to-colon(oTot-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-2 <> ? then fnc-convert-dot-to-colon(oTot-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-4 <> ? then fnc-convert-dot-to-colon(oTot-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-5 <> ? then fnc-convert-dot-to-colon(oTot-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if oTot-3 <> ? then fnc-convert-dot-to-colon(oTot-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                            '</TR>' skip    
                            . 
         end.                 
    end.

      assign
       num#str# = num#str# + 1
       num#col# =  1
       var-1 = num#str#
       var-2 = num#col#
       .
   Assign
      oTot-1=0
      oTot-2=0
      oTot-3=0
      oTot-4=0
      oTot-5=0.
   run u-line.
 end. /* do */
end procedure. /* Print-Footer-o */


procedure U-LINE :
 do
 on error undo, return error return-value
 :
  if not Parts-Det then do :
  end.
  else do :
  end.

 end. /* do */
end procedure. /* U-LINE */


procedure P-LINE :
 do
 on error undo, return error return-value
 :
  if not Parts-Det then do :
  end.
  else do :
  end.
 end. /* do */
end procedure. /* P-LINE */

procedure Run1 :
 do
 on error undo, return error return-value
 :
  &if '{1}' = '1' &Then
  case RetSortType  :
  when "sort-code":U  then DO:
       CAse Select-Good :
        when {&g-all}   then DO: { rep/run1.i "1" "1" 1 goods goods.gds-code } End.
        when {&g-grp}   then DO: { rep/run2.i "1" "1" 1 goods goods.gds-code} End.
        when {&g-prod}  then DO: { rep/run3.i "1" "1" 1 goods goods.gds-code} End.
        otherwise do:
          { rep/run1.i "1" "1" 1 gds-list gds-list.gds-code}
        end.
        End case.
    End.
   when "sort-artic" then DO:
       CAse Select-Good :
        when {&g-all}   then DO: { rep/run1.i "1" "1" 1 goods goods.artic} End.
        when {&g-grp}   then DO: { rep/run2.i "1" "1" 1 goods goods.artic} End.
        when {&g-prod}  then DO: { rep/run3.i "1" "1" 1 goods goods.artic} End.
        otherwise do:
          { rep/run1.i "1" "1" 1 gds-list gds-list.artic}
        end.
        End case.
    End.
   when "sort-name"  then DO:
       CAse Select-Good :
        when {&g-all}   then DO: { rep/run1.i "1" "1" 1 goods goods.gds-name} End.
        when {&g-grp}   then DO: { rep/run2.i "1" "1" 1 goods goods.gds-name} End.
        when {&g-prod}  then DO: { rep/run3.i "1" "1" 1 goods goods.gds-name} End.
        otherwise do:
          { rep/run1.i "1" "1" 1 gds-list gds-list.gds-name}
        end.
        End case.
    End.
   End case.
    &endif
 end. /* do */
end procedure. /* Run1 */


procedure Run2 :
 do
 on error undo, return error return-value
 :
&if '{1}' = '2' &Then
  case RetSortType :
  when "sort-code":U  then DO:
       CAse Select-Good :
          when {&g-all}   then DO:  { rep/run1.i "1" goods.grp-name 3 goods goods.gds-code }  End.
          when {&g-grp}   then DO:  { rep/run2.i "1" goods.grp-name 3 goods goods.gds-code }  End.
          when {&g-prod}  then DO:  { rep/run3.i "1" goods.grp-name 3 goods goods.gds-code }  End.
          otherwise do:
            { rep/run1.i "1" gds-list.grp-name 3 gds-list gds-list.gds-code }
          end.
       end case.
       End.
 when "sort-artic" then do:
       CAse Select-Good :
          when {&g-all}   then DO:  { rep/run1.i "1" goods.grp-name 3 goods goods.artic }  End.
          when {&g-grp}   then DO:  { rep/run2.i "1" goods.grp-name 3 goods goods.artic }  End.
          when {&g-prod}  then DO:  { rep/run3.i "1" goods.grp-name 3 goods goods.artic }  End.
          otherwise do:
            { rep/run1.i "1" gds-list.grp-name 3 gds-list gds-list.artic }
          end.
       end case.
       End.
 when "sort-name" then do:
       CAse Select-Good :
          when {&g-all}   then DO:  { rep/run1.i "1" goods.grp-name 3 goods goods.gds-name }  End.
          when {&g-grp}   then DO:  { rep/run2.i "1" goods.grp-name 3 goods goods.gds-name }  End.
          when {&g-prod}  then DO:  { rep/run3.i "1" goods.grp-name 3 goods goods.gds-name }  End.
          otherwise do:
            { rep/run1.i "1" gds-list.grp-name 3 gds-list gds-list.gds-name }
          end.
       end case.
       End.
 end case.
 &endif

 end. /* do */
end procedure. /* Run2 */



PROCEDURE Run3 :
 do
 on error undo, return error return-value
 :

&if '{1}' = '3' &Then
  case RetSortType :
  when "sort-code":U  then DO:
      CASE Select-Good :
        when {&g-all}   then DO: { rep/run1.i "1" b-clients.obj-name 2 goods goods.gds-code } End.
        when {&g-grp}   then DO: { rep/run2.i "1" b-clients.obj-name 2 goods goods.gds-code } End.
        when {&g-prod}  then DO: { rep/run3.i "1" b-clients.obj-name 2 goods goods.gds-code } End.
        otherwise do:
          { rep/run1.i "1" b-clients.obj-name 2 gds-list gds-list.gds-code }
        end.
        End case.
       End.
    when "sort-artic" then do:
      CASE Select-Good :
        when {&g-all}   then DO: { rep/run1.i "1" b-clients.obj-name 2 goods "goods.prod-type by  goods.prod-code by goods.artic" } End.
        when {&g-grp}   then DO: { rep/run2.i "1" b-clients.obj-name 2 goods "goods.prod-type by  goods.prod-code by goods.artic" } End.
        when {&g-prod}  then DO: { rep/run3.i "1" b-clients.obj-name 2 goods "goods.prod-type by  goods.prod-code by goods.artic" } End.
        otherwise do:
          { rep/run1.i "1" b-clients.obj-name 2 gds-list "gds-list.prod-type by gds-list.prod-code by gds-list.artic" }
        end.
        End case.
       End.
    when "sort-name" then do:
      CASE Select-Good :
        when {&g-all}   then DO: { rep/run1.i "1" b-clients.obj-name 2 goods goods.gds-name } End.
        when {&g-grp}   then DO: { rep/run2.i "1" b-clients.obj-name 2 goods goods.gds-name } End.
        when {&g-prod}  then DO: { rep/run3.i "1" b-clients.obj-name 2 goods goods.gds-name } End.
         otherwise do:
           { rep/run1.i "1" b-clients.obj-name 2 gds-list gds-list.gds-name }
         end.
        End case.
       End.
   end case.
&endif
 end. /* do */
END PROCEDURE.

&if '{1}' = '4' &Then
PROCEDURE Run4 :
 do
 on error undo, return error return-value
 :

  case RetSortType :
  when "sort-code":U  then DO:
    run run4-sort-code.
   End.
   when "sort-artic"   then do:
     run run4-sort-artic.
    End.
  when "sort-name":U  then DO:
  run run4-sort-name.
   End.
   End case.
 end. /* do */
END PROCEDURE.

procedure  run4-sort-code :
 do
 on error undo, return error return-value
 :
      CASE Select-Good :
         when {&g-all}   then DO: { rep/run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" goods.grp-name 4 goods goods.gds-code} End.
         when {&g-grp}   then DO: { rep/run2.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" goods.grp-name 4 goods goods.gds-code} End.
         when {&g-prod}  then DO: { rep/run3.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" goods.grp-name 4 goods goods.gds-code} End.
         otherwise do:
           { rep/run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-list.grp-name 4 gds-list gds-list.gds-code}
         end.
      End case.
 end. /* do */
END PROCEDURE.

procedure  run4-sort-artic :
 do
 on error undo, return error return-value
 :
      CASE Select-Good :
         when {&g-all}   then do: { rep/run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))"  goods.grp-name 4 goods goods.artic} end.
         when {&g-grp}   then do: { rep/run2.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))"  goods.grp-name 4 goods goods.artic} end.
         when {&g-prod}  then do: { rep/run3.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))"  goods.grp-name 4 goods goods.artic} end.
         otherwise do:
           { rep/run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-list.grp-name 4 gds-list gds-list.artic}
         end.
      End case.
 end. /* do */
END PROCEDURE.

procedure  run4-sort-name :
 do
 on error undo, return error return-value
 :

      CASE Select-Good :
         when {&g-all}   then DO: { rep/run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" goods.grp-name 4 goods goods.gds-name} End.
         when {&g-grp}   then DO: { rep/run2.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" goods.grp-name 4 goods goods.gds-name} End.
         when {&g-prod}  then DO: { rep/run3.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" goods.grp-name 4 goods goods.gds-name} End.
         otherwise do:
           { rep/run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-list.grp-name 4 gds-list gds-list.gds-name}
         end.
      End case.
 end. /* do */
END PROCEDURE.
&endif



&if '{1}' = '5' &Then
PROCEDURE Run5 :
 do
 on error undo, return error return-value
 :
  case RetSortType :
  when "sort-code":U  then DO:
    run run5-sort-code.
   End.
   when "sort-artic"   then do:
     run run5-sort-artic.
    End.
  when "sort-name":U  then DO:
  run run5-sort-name.
   End.
   End case.
end. /* do */
END PROCEDURE.

procedure  run5-sort-code :
 do
 on error undo, return error return-value
 :

      case Select-Good:
         when {&g-all}   then DO: { rep/run1.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.gds-code } End.
         when {&g-grp}   then DO: { rep/run2.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.gds-code } End.
         when {&g-prod}  then DO: { rep/run3.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.gds-code } End.
         otherwise do:
           { rep/run1.i gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 gds-list gds-list.gds-code }
         end.
      End case.
 end. /* do */
END PROCEDURE.

procedure  run5-sort-artic :
 do
 on error undo, return error return-value
 :

      case Select-Good:
         when {&g-all}   then DO: { rep/run1.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.artic } End.
         when {&g-grp}   then DO: { rep/run2.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.artic } End.
         when {&g-prod}  then DO: { rep/run3.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.artic } End.
         otherwise do:
           { rep/run1.i gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 gds-list gds-list.artic }
         end.
      End case.
 end. /* do */
END PROCEDURE.

procedure  run5-sort-name :
 do
 on error undo, return error return-value
 :

      case Select-Good:
         when {&g-all}   then DO: { rep/run1.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.gds-name } End.
         when {&g-grp}   then DO: { rep/run2.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.gds-name } End.
         when {&g-prod}  then DO: { rep/run3.i goods.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods goods.gds-name } End.
         otherwise do:
           { rep/run1.i gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 gds-list gds-list.gds-name }
         end.
      End case.
 end. /* do */
END PROCEDURE.
&endif


procedure proc-prt-1 :
 do
 on error undo, return error return-value
 :
/*run new-tmp-page .                                                                                                                        */
    if not Parts-Det then do :
      if v-photo then do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="2">' + substring(tmp#stroka,1,16) + '</TD>'skip
                                '<TD text_wrap="true">' + substring(tmp#stroka,17,160) + '</TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1-1 <> ? then fnc-convert-dot-to-colon(Tot-1-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-2 <> ? then fnc-convert-dot-to-colon(Tot-1-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-4 <> ? then fnc-convert-dot-to-colon(Tot-1-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-5 <> ? then fnc-convert-dot-to-colon(Tot-1-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-3 <> ? then fnc-convert-dot-to-colon(Tot-1-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD style="text-align: right"></TD>'skip
                            '</TR>'skip    
                            .
      end.
      else do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="2">' + substring(tmp#stroka,1,16) + '</TD>'skip
                                '<TD text_wrap="true">' + substring(tmp#stroka,17,160) + '</TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1-1 <> ? then fnc-convert-dot-to-colon(Tot-1-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-2 <> ? then fnc-convert-dot-to-colon(Tot-1-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-4 <> ? then fnc-convert-dot-to-colon(Tot-1-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-5 <> ? then fnc-convert-dot-to-colon(Tot-1-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-3 <> ? then fnc-convert-dot-to-colon(Tot-1-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                            '</TR>'skip    
                            .         
      end.
    end.
    else do :
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="2">' + substring(tmp#stroka,1,16) + '</TD>'skip
                                '<TD text_wrap="true">' + substring(tmp#stroka,17,160) + '</TD>'skip
                                '<TD></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-1-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-1-1 <> ? then fnc-convert-dot-to-colon(Tot-1-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-2 <> ? then fnc-convert-dot-to-colon(Tot-1-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-4 <> ? then fnc-convert-dot-to-colon(Tot-1-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-5 <> ? then fnc-convert-dot-to-colon(Tot-1-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-1-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-1-3 <> ? then fnc-convert-dot-to-colon(Tot-1-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                            '</TR>'skip    
                            .           
    end.
      assign
        num#str# = num#str# + 1
        num#col# =  1
        var-1 = num#str#
        var-2 = num#col#
      .

    if not sums-only then run u-line.
    assign break_group = true
      Tot-1-1=0
      Tot-1-2=0
      Tot-1-3=0
      Tot-1-4=0
      Tot-1-5=0 .


 end. /* do */
end procedure. /* proc-prt-1 */



procedure proc-prt-2 :
 do
 on error undo, return error return-value
 :

if not Parts-Det then do :
  if v-photo then do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="3">' + substring(tmp#stroka,1,10) + substring(tmp#stroka,11,18) + substring(tmp#stroka,29,60) + '</TD>'skip
/*                                '<TD>' + substring(tmp#stroka,11,18) + '</TD>'skip*/
/*                                '<TD>' + substring(tmp#stroka,29,60) + '</TD>'skip*/
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-2-1 <> ? then fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-2 <> ? then fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-4 <> ? then fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-5 <> ? then fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-3 <> ? then fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD style="text-align: right"></TD>'skip
                            '</TR>'skip    
                            .
  end.
  else do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="3">' + substring(tmp#stroka,1,10) + substring(tmp#stroka,11,18) + substring(tmp#stroka,29,60) + '</TD>'skip
/*                                '<TD>' + substring(tmp#stroka,11,18) + '</TD>'skip*/
/*                                '<TD>' + substring(tmp#stroka,29,60) + '</TD>'skip*/
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-2-1 <> ? then fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-2 <> ? then fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-4 <> ? then fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-5 <> ? then fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-3 <> ? then fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                            '</TR>'skip    
                            .
  end.                               
end.
else do :
  if v-photo then do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="3">' + substring(tmp#stroka,1,10) + substring(tmp#stroka,11,18) + substring(tmp#stroka,29,60) + '</TD>'skip
/*                                '<TD>' + substring(tmp#stroka,11,18) + '</TD>'skip*/
/*                                '<TD>' + substring(tmp#stroka,29,60) + '</TD>'skip*/
                                '<TD></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-2-1 <> ? then fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-2 <> ? then fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-4 <> ? then fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-5 <> ? then fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-3 <> ? then fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                '<TD style="text-align: right"></TD>'skip
                            '</TR>'skip    
                            .
  end.
  else do:
                            put stream OutStr-html unformatted
                            '<TR>'skip
                                '<TD colspan="3">' + substring(tmp#stroka,1,10) + substring(tmp#stroka,11,18) + substring(tmp#stroka,29,60) + '</TD>'skip
/*                                '<TD>' + substring(tmp#stroka,11,18) + '</TD>'skip*/
/*                                '<TD>' + substring(tmp#stroka,29,60) + '</TD>'skip*/
                                '<TD></TD>'skip
                                '<TD style="text-align: center"></TD>'skip
                                  '<TD num="0.000" val="' + fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '" style="text-align: right">' + if Tot-2-1 <> ? then fnc-convert-dot-to-colon(Tot-2-1,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-2 <> ? then fnc-convert-dot-to-colon(Tot-2-2,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-4 <> ? then fnc-convert-dot-to-colon(Tot-2-4,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-5 <> ? then fnc-convert-dot-to-colon(Tot-2-5,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD style="text-align: right">' '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '" style="text-align: right">' + if Tot-2-3 <> ? then fnc-convert-dot-to-colon(Tot-2-3,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                            '</TR>'skip    
                            .   
  end.
end.

  assign
  num#str# = num#str# + 1
  num#col# =  1
  var-1 = num#str#
  var-2 = num#col#
  .
 end. /* do */
end procedure. /* proc-prt-2 */


procedure proc-prt-3 :
 do
 on error undo, return error return-value
 :
  PUT stream  OutStr-html  tmp#stroka0 format "X(100)" SKIP.
  assign
  num#str# = num#str# + 1
  num#col# =  1
  var-1 = num#str#
  var-2 = num#col#
  .
 end. /* do */
end procedure. /* proc-prt-3 */


procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >= 63000 then do:
        /*Запишем в файл параметров */
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header-my. /* снова шапку */
    end.

 end. /* do */
end procedure. /* new-tmp-page */


procedure proc-print-header-my :
 do
 on error undo, return error return-value
 :
/* Шапка */
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,{&new-line}) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , {&new-line} ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .

     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, {&new-line}) , {&comma-char} ) .

     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, {&new-line}) , {&comma-char}) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.

    c-i = 0.
    end.
 end. /* do */
end procedure. /* proc-print-header-my */

PROCEDURE report-execute :
 do
 on error undo, return error return-value
 :

    { rep/r-val.i }
/*     создаем временный файл*/
    v-ind = 1    .
    num#str# = 0 .

  { cmp/open-out.i stream OutStr-html  " " ReportPageHeight }
  /* от куда печатается. */
  FIND First clients where
             x-store-type = clients.obj-type AND
             x-store-code = clients.obj-code no-lock no-error.
    If available clients then  ObjName = clients.obj-name.
                         else  ObjName="объект не определен".

  run print-header .

      num#str# = num#str# + 1 .
      num#col# =  1 .

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

  num#str# = num#str# + 1.
  num#col# = 1.
/*Печать шапки */
   run proc-print-header-my.
   /* проход по списку товаров 1 2 3-№ поиска */
   For each obj-list no-lock :
      x-store-type  =  obj-list.obj-type .
      x-store-code  =  obj-list.obj-code .
      FIND First clients where x-store-type = clients.obj-type AND
                               x-store-code = clients.obj-code no-lock no-error.
        If available clients then  ObjName = clients.obj-name.
                             else  ObjName = "объект не определен".

      PUT stream OutStr-html  string(  "ПО ОБЬЕКТУ : (" + x-store-type  + string(x-store-code)  +  ") " + ObjName) at 2 format "x(100)" skip .
      assign
       num#str# = num#str# + 1
       num#col# =  1
       .
       case retclassify :
          when "no-classify":u  then do:
            run run1.
            end.
          when "grp-goods":u then do:
            run run2.
            end.
          when "prod":u then do:
            run run3.
            end.
          when "prod/grp-goods":u then do:
           &if '{1}' = '4' &then run run4. &endif
            end.
          when "grp-goods/prod":u then do:
           &if '{1}' = '5' &then run run5.  &endif
            end.
      end case.
      run print-footer-o.
  end.
  run print-footer.
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "2,3,4"
        ) .

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .

   put stream OutStr-html unformatted
                                '</tbody>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
                                                                                        
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
 end. /* do */
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num automain
PROCEDURE get-report-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


