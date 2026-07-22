block-level on error undo, throw.
/*

$Revision: 0500dccfad42, 789, rls $
$Author: PGridchina $
$Date: Wed Sep 14 14:42:19 2016 +0300 $
$Workfile: r-saleup.p $
$Archive: rep/r-saleup.p $

Описание файла

Автор: Сливенко Сергей Андреевич
Дата создания: 11/07/11
Author: Sergey Slivenko
Creation date: 11/07/11

*/

define variable vss-revision    as character no-undo init "$Revision: 0500dccfad42, 789, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 14 14:42:19 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-saleup.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-saleup.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам упаковками".
{ cmp/vssrevis.i }

define input parameter parparentproc  as   widget-handle  no-undo .
define input parameter SortType  as integer no-undo.
define input parameter Classify  as integer no-undo.
define input parameter p-det-obj as logical no-undo.

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ rep/rep-bt.i   }
{ rep/repfrm.i def }
{ str/libbcrcn.i }   /* Библиотека поиска по бар коду !!! */
{ str/sclspref.i } 
define temp-table tt-line no-undo
  field artic     like ub.goods.artic
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
  field gds-code  like ub.goods.gds-code
  field gds-name  like ub.goods.gds-name
  field grp-name  like ub.goods.grp-name
  field obj-code  like ub.clients.obj-code
  field obj-type  like ub.clients.obj-type
  field obj-name  like ub.clients.obj-name
  field unit      like ub.bar-code.unit-cli
  field rate      like ub.bar-code.cli-base-rate
  field qnty      as decimal
  field sum       as decimal
    index pi is primary gds-code
    index grp-artic   grp-name artic
    index grp-name    grp-name artic prod-type prod-code
    index obj         gds-code obj-type obj-code 
    index unit        unit rate
.

define temp-table tt-sum no-undo
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field obj-code  like ub.clients.obj-code
  field obj-type  like ub.clients.obj-type
  field sum       as decimal
    index pi is primary unique obj-type obj-code grp-name prod-type prod-code
.

define temp-table tt-chk-gds no-undo like ub.chk-gds
  field obj-code  like ub.clients.obj-code
  field obj-type  like ub.clients.obj-type
    index pi is primary b-code src-code obj-code obj-type
.

define buffer bf1_tt-sum for tt-sum.
define buffer bf2_tt-sum for tt-sum.
define buffer bf3_tt-sum for tt-sum.
define buffer bf4_tt-sum for tt-sum.
define buffer bf5_tt-sum for tt-sum.
define buffer bf6_tt-sum for tt-sum.
define buffer bf7_tt-sum for tt-sum.

define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_clients for ub.clients.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_goods   for ub.goods.

define variable v-sum-itog as decimal no-undo .

define variable CurrGrpName            as character no-undo .
define variable v-NameString           as character no-undo .
define variable v-row                  as integer   no-undo .
define variable v-col                  as integer   no-undo .
define variable v-cur-db-num           as integer   no-undo .
define variable v-db-list              as character no-undo .
define variable v-obj-list             as character no-undo .

define variable   Counter1            as   integer        no-undo.

assign  Counter1 = 0 .

empty temp-table tt-line .
empty temp-table tt-sum  .
v-sum-itog = 0 .


{ gbl/curdbnum.i v-cur-db-num }
if v-cur-db-num = 0 then do :
  for each obj-list no-lock :
    for first db where db.db-num > 0 and db.db-num = obj-list.db-num no-lock :
      if db.send-check = false then do :
        v-db-list = v-db-list + ", " + db.db-name .
        v-obj-list = v-obj-list + ', "' + obj-list.obj-name + '"' .
      end.
    end.
  end.
  if v-obj-list <> ? and v-obj-list <> "" then do :
    v-db-list  = substring(v-db-list,3).
    v-obj-list = substring(v-obj-list,3).
  end.
end.

if v-obj-list <> ? and v-obj-list <> "" then do :
  message ("На " + v-db-list + " отключена пересылка чеков. ~ Данные по " + v-obj-list + " будут нулевыми. ~ Продолжить формирование отчёта?")
  view-as alert-box question buttons yes-no update b as logical .
  if not b then return no-apply .
end.

  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
 


  for each obj-list :                /* встать на объект */
   for each buf_chk-doc where buf_chk-doc.chk-date >= X-date-start     and
                             buf_chk-doc.chk-date <= X-date-end     
                             and  buf_chk-doc.obj-type = obj-list.obj-type
                             and buf_chk-doc.obj-code = obj-list.obj-code no-lock :
    for each buf_chk-gds where buf_chk-gds.doc-code  = buf_chk-doc.doc-code and
                               buf_chk-gds.doc-qnty <> 0 no-lock :
      create tt-chk-gds.
      buffer-copy buf_chk-gds to tt-chk-gds.
      assign
        tt-chk-gds.obj-code = buf_chk-doc.obj-code
        tt-chk-gds.obj-type = buf_chk-doc.obj-type
      .
    end.
  end. 
      case x-SelectGood :
      when {&g-all} then do: /* все товары */
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
            :
            run fill-tt in this-procedure
                          (input buf_gds-obj.artic,
                           input buf_gds-obj.prod-type,
                           input buf_gds-obj.prod-code,
                           input buf_gds-obj.gds-code,
                           input buf_gds-obj.grp-name
                           ) .
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
          end.
      end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli , /* встать на производителя */
              each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
             use-index pi  :
             run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input grp-name
                           ).
             assign Counter1 = Counter1 + 1.
             { rep/repfrm.i disp Counter1 }
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input grp-name
                           ).
              assign Counter1 = Counter1 + 1.
              { rep/repfrm.i disp Counter1 }
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.

       otherwise do: /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run fill-tt in this-procedure
                          (input gds-list.artic,
                           input gds-list.prod-type,
                           input gds-list.prod-code,
                           input gds-list.gds-code,
                           input gds-list.grp-name
                           ).
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
          end.
        end.

      end case.
  end.                    /* for each ... по объектам */

  run print-header in this-procedure .

  case classify:
    when 1 then run class1 in this-procedure .  /*"Без классификации" .*/
    when 2 then run class2 in this-procedure .  /*"Производители"   .*/
    when 3 then run class3 in this-procedure .  /*"Группы товаров"  .*/
    when 4 then run class4 in this-procedure .  /*"Производители/Группы товаров" .*/
    when 5 then run class5 in this-procedure .  /*"Группы товаров/Производители" .*/
  end case.


  {&PutExcel}
               {&tabulation}
               {&tabulation}
               {&tabulation}
               {&tabulation}
               {&tabulation}
               {&tabulation}
              "Итого:   "       {&tabulation}
              v-sum-itog        {&tabulation}
    skip.




  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  {&CloseExcel}

run get-report-num in my-handle (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").




Procedure fill-tt :
  define input parameter p-artic     like goods.artic     no-undo.
  define input parameter p-prod-type like goods.prod-type no-undo.
  define input parameter p-prod-code like goods.prod-code no-undo.
  define input parameter p-gds-code  like goods.gds-code  no-undo.
  define input parameter p-grp-name  like goods.grp-name  no-undo.
find first buf_goods where buf_goods.gds-code = p-gds-code no-lock .
  DEFINE BUFFER b_bar-code FOR  ub.bar-code .
  DEFINE BUFFER buf_prod-bc  FOR  ub.prod-bc.
  DEFINE BUFFER buf_place    FOR  ub.place.
  /*  */
  DEFINE VARIABLE v-cResult  AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE v-cType-bc AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE v-dWeight  AS DECIMAL   NO-UNDO INITIAL 0.

  
for first buf_bar-code where buf_bar-code.gds-code = p-gds-code  and buf_bar-code.unit-cli = buf_goods.unit-base /* and   buf_bar-code.cli-base-rate > 1 */ no-lock,                                 
       each  tt-chk-gds where tt-chk-gds.b-code = buf_bar-code.b-code  and tt-chk-gds.obj-type = obj-list.obj-type and
                                 tt-chk-gds.obj-code = obj-list.obj-code and tt-chk-gds.doc-qnty <> tt-chk-gds.src-qnty  no-lock break by tt-chk-gds.src-code
                                 /* ,
        first buf_bar-code where buf_bar-code.b-code   = integer(tt-chk-gds.src-code) and
                                 buf_bar-code.gds-code = p-gds-code         and
                                 buf_bar-code.cli-base-rate > 1 no-lock
                                 */
        :
       
		
		
          { str/bc-rcnz.i
           parparentproc
           tt-chk-gds.src-code
           ?
           obj-list.obj-type
           obj-list.obj-code
           yes
           no
           varscales-pref
           varpgscales-pref
           v-cResult
           v-cType-bc
           v-dWeight
           b_bar-code
           buf_prod-bc
           buf_place
           no-error
         }
        
          if not available b_bar-code then next.   
         
            if p-det-obj then do :     /*  Детализировать по объектам   */
            /*  find first buf_clients where buf_clients.obj-type = obj-list.obj-type and buf_clients.obj-code = obj-list.obj-code no-lock . */
              find first tt-line where tt-line.gds-code = p-gds-code        and
                                       tt-line.obj-type = obj-list.obj-type and
                                       tt-line.obj-code = obj-list.obj-code and
                                       tt-line.unit     = b_bar-code.unit-cli  and
                                       tt-line.rate     = b_bar-code.cli-base-rate
                                        no-lock no-error.
              if not available tt-line then do :
                create tt-line.
                assign
                  tt-line.artic     = p-artic
                  tt-line.prod-code = p-prod-code
                  tt-line.prod-type = p-prod-type
                  tt-line.gds-code  = p-gds-code
                  tt-line.gds-name  = buf_goods.gds-name
                  tt-line.obj-type  = obj-list.obj-type
                  tt-line.obj-code  = obj-list.obj-code
                  tt-line.obj-name  = obj-list.obj-name
                  tt-line.grp-name  = p-grp-name
                  tt-line.unit      = b_bar-code.unit-cli
                  tt-line.rate      = b_bar-code.cli-base-rate
                  tt-line.qnty      = 0
                  tt-line.sum       = 0
                .
              end.  /*   if not available tt-line   */
              assign
                tt-line.qnty = tt-line.qnty + tt-chk-gds.src-qnty
                tt-line.sum  = tt-line.sum  + tt-chk-gds.sum-base
                v-sum-itog   = v-sum-itog   + tt-chk-gds.sum-base
              .
              /*  Итог по объекту  */
              find first bf1_tt-sum where bf1_tt-sum.obj-type = obj-list.obj-type   and
                                          bf1_tt-sum.obj-code = obj-list.obj-code   and
                                          bf1_tt-sum.prod-type = "-1"               and
                                          bf1_tt-sum.prod-code = -1                 and
                                          bf1_tt-sum.grp-name  = "-1"               no-lock no-error.
              if not available bf1_tt-sum then do :
                create bf1_tt-sum.
                assign
                  bf1_tt-sum.obj-type = obj-list.obj-type
                  bf1_tt-sum.obj-code = obj-list.obj-code
                  bf1_tt-sum.prod-type = "-1"
                  bf1_tt-sum.prod-code = -1
                  bf1_tt-sum.grp-name  = "-1"
                  bf1_tt-sum.sum      = 0
                .
              end.
              bf1_tt-sum.sum = bf1_tt-sum.sum + tt-chk-gds.sum-base.
              /*  Итог по объекту/производителю  */
              find first bf2_tt-sum where bf2_tt-sum.obj-type  = obj-list.obj-type  and
                                      bf2_tt-sum.obj-code  = obj-list.obj-code  and
                                      bf2_tt-sum.prod-type = p-prod-type        and
                                      bf2_tt-sum.prod-code = p-prod-code        and
                                      bf2_tt-sum.grp-name  = "-1"               no-lock no-error.
              if not available bf2_tt-sum then do :
                create bf2_tt-sum.
                assign
                  bf2_tt-sum.obj-type  = obj-list.obj-type
                  bf2_tt-sum.obj-code  = obj-list.obj-code
                  bf2_tt-sum.prod-type = p-prod-type
                  bf2_tt-sum.prod-code = p-prod-code
                  bf2_tt-sum.grp-name  = "-1"
                  bf2_tt-sum.sum       = 0
                .
              end.
              bf2_tt-sum.sum = bf2_tt-sum.sum + tt-chk-gds.sum-base.
              /*  Итог по объекту/группе  */
              find first bf3_tt-sum where bf3_tt-sum.obj-type  = obj-list.obj-type  and
                                      bf3_tt-sum.obj-code  = obj-list.obj-code  and
                                      bf3_tt-sum.prod-type = "-1"               and
                                      bf3_tt-sum.prod-code = -1                 and
                                      bf3_tt-sum.grp-name  = p-grp-name         no-lock no-error.
              if not available bf3_tt-sum then do :
                create bf3_tt-sum.
                assign
                  bf3_tt-sum.obj-type  = obj-list.obj-type
                  bf3_tt-sum.obj-code  = obj-list.obj-code
                  bf3_tt-sum.prod-type = "-1"
                  bf3_tt-sum.prod-code = -1
                  bf3_tt-sum.grp-name  = p-grp-name
                  bf3_tt-sum.sum       = 0
                .
              end.
              bf3_tt-sum.sum = bf3_tt-sum.sum + tt-chk-gds.sum-base.
              /*  Итог по объекту/производителю/группе  */
              find first bf4_tt-sum where bf4_tt-sum.obj-type  = obj-list.obj-type  and
                                      bf4_tt-sum.obj-code  = obj-list.obj-code  and
                                      bf4_tt-sum.prod-type = p-prod-type        and
                                      bf4_tt-sum.prod-code = p-prod-code        and
                                      bf4_tt-sum.grp-name  = p-grp-name         no-lock no-error.
              if not available bf4_tt-sum then do :
                create bf4_tt-sum.
                assign
                  bf4_tt-sum.obj-type  = obj-list.obj-type
                  bf4_tt-sum.obj-code  = obj-list.obj-code
                  bf4_tt-sum.prod-type = p-prod-type
                  bf4_tt-sum.prod-code = p-prod-code
                  bf4_tt-sum.grp-name  = p-grp-name
                  bf4_tt-sum.sum       = 0
                .
              end.
              bf4_tt-sum.sum = bf4_tt-sum.sum + tt-chk-gds.sum-base.
            end.
            else do :     /*  НЕ детализировать по объектам   */
              find first tt-line where tt-line.gds-code = p-gds-code and
                                       tt-line.unit     = b_bar-code.unit-cli  and
                                       tt-line.rate     = b_bar-code.cli-base-rate
                                       no-lock no-error.
              if not available tt-line then do :
                create tt-line.
                assign
                  tt-line.artic     = p-artic
                  tt-line.prod-code = p-prod-code
                  tt-line.prod-type = p-prod-type
                  tt-line.gds-code  = p-gds-code
                  tt-line.gds-name  = buf_goods.gds-name
                  tt-line.grp-name  = p-grp-name
                  tt-line.unit      = b_bar-code.unit-cli
                  tt-line.rate      = b_bar-code.cli-base-rate
                  tt-line.qnty      = 0
                  tt-line.sum       = 0
                .
              end.  /*   if not available tt-line   */
              assign
                tt-line.qnty = tt-line.qnty + tt-chk-gds.src-qnty
                tt-line.sum  = tt-line.sum  + tt-chk-gds.sum-base
                v-sum-itog   = v-sum-itog   + tt-chk-gds.sum-base
              .
            end.
            /*  Итог по производителю  */
              find first bf5_tt-sum where bf5_tt-sum.obj-type  = "-1"               and
                                      bf5_tt-sum.obj-code  = -1                 and
                                      bf5_tt-sum.prod-type = p-prod-type        and
                                      bf5_tt-sum.prod-code = p-prod-code        and
                                      bf5_tt-sum.grp-name  = "-1"               no-lock no-error.
              if not available bf5_tt-sum then do :
                create bf5_tt-sum.
                assign
                  bf5_tt-sum.obj-type  = "-1"
                  bf5_tt-sum.obj-code  = -1
                  bf5_tt-sum.prod-type = p-prod-type
                  bf5_tt-sum.prod-code = p-prod-code
                  bf5_tt-sum.grp-name  = "-1"
                  bf5_tt-sum.sum       = 0
                .
              end.
              bf5_tt-sum.sum = bf5_tt-sum.sum + tt-chk-gds.sum-base.
              /*  Итог по группе  */
              find first bf6_tt-sum where bf6_tt-sum.obj-type  = "-1"               and
                                      bf6_tt-sum.obj-code  = -1                 and
                                      bf6_tt-sum.grp-name  = p-grp-name         and
                                      bf6_tt-sum.prod-type = "-1"               and
                                      bf6_tt-sum.prod-code = -1                 no-lock no-error.
              if not available bf6_tt-sum then do :
                create bf6_tt-sum.
                assign
                  bf6_tt-sum.obj-type  = "-1"
                  bf6_tt-sum.obj-code  = -1
                  bf6_tt-sum.grp-name  = p-grp-name
                  bf6_tt-sum.prod-type = "-1"
                  bf6_tt-sum.prod-code = -1
                  bf6_tt-sum.sum       = 0
                .
              end.
              bf6_tt-sum.sum = bf6_tt-sum.sum + tt-chk-gds.sum-base.
              /*  Итог по производителю/группе  */
              find first bf7_tt-sum where bf7_tt-sum.obj-type  = "-1"               and
                                      bf7_tt-sum.obj-code  = -1                 and
                                      bf7_tt-sum.prod-type = p-prod-type        and
                                      bf7_tt-sum.prod-code = p-prod-code        and
                                      bf7_tt-sum.grp-name  = p-grp-name         no-lock no-error.
              if not available bf7_tt-sum then do :
                create bf7_tt-sum.
                assign
                  bf7_tt-sum.obj-type  = "-1"
                  bf7_tt-sum.obj-code  = -1
                  bf7_tt-sum.prod-type = p-prod-type
                  bf7_tt-sum.prod-code = p-prod-code
                  bf7_tt-sum.grp-name  = p-grp-name
                  bf7_tt-sum.sum       = 0
                .
              end.
              bf7_tt-sum.sum = bf7_tt-sum.sum + tt-chk-gds.sum-base.

      end.  /*  for each chk-doc, chk-gds...  */
   
end.  /*   Procedure fill-tt   */

procedure print-line :
  define input parameter p-line-recid as recid no-undo.

  for tt-line field (artic
                     gds-code
                     gds-name
                     unit
                     rate
                     qnty
                     sum     ) where recid (tt-line) = p-line-recid no-lock :

    {&PutExcel}
              tt-line.artic     {&tabulation}
              tt-line.gds-code  {&tabulation}
              tt-line.gds-name  {&tabulation}
              tt-line.unit      {&tabulation}
              tt-line.rate      {&tabulation}
              tt-line.qnty      {&tabulation}
              (tt-line.rate * tt-line.qnty)      {&tabulation}
              tt-line.sum       {&tabulation}
    skip.
  end.
end.  /*   procedure print-line   */

procedure print-header :
find first sheetf where sheet-num = 1 /*no-error*/.

    assign
    Sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "Артикул" + {&comma-char} +
                         "Код" + {&comma-char} +
                         "Наименование" + {&comma-char} +
                         "Ед. Изм." + {&comma-char} +
                         "Коэффициент" + {&comma-char} +
                         "Оборот в количестве упаковок. (Продажа-возврат)" + {&comma-char} +
                         "Оборот в количестве в пересчёте на штуки. (Продажа-возврат)" + {&comma-char} +
                         "Сумма в продажных ценах"
    Sheetf.Sizes = "10,10,80,5,10,15,15,20"
    Sheetf.colformat = "1=@;2=@;3=@;4=@;5=0;6=0;7=0;8=0,00;"
    .
  RUN rep/extitle.p (1).

end. /*procedure print-header*/

/* *********************************************************** */

procedure class1 :  /*"Без классификации" .*/
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.gds-code :  run print-line in this-procedure (input recid(tt-line)) .  end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.artic :     run print-line in this-procedure (input recid(tt-line)) .  end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.gds-name :  run print-line in this-procedure (input recid(tt-line)) .  end.
      end.
    end case.
  end.
  if  p-det-obj then do :       /*   Детализировать по объектам    */
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.gds-code :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.artic :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.gds-name :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure. /* class1 */


procedure class2 :  /* Производители */
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure. /* class2 */


procedure class3 :  /* Группы товаров */
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure. /* class3 */


procedure class4 :  /* Производители/Группы товаров */
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure. /* class4 */


procedure class5 :  /* Группы товаров/Производители */
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.obj-code) then {&PutExcel} tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            {&PutExcel} tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            {&PutExcel} buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(buf_clients.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.grp-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            {&PutExcel} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
                        ("Итого по " + string(tt-line.obj-name) + " :")         {&tabulation} {&tabulation} {&tabulation}
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure. /* class5 */
