block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obcntr.p $
$Archive: rep/r-obcntr.p $

Оборотная ведомость по контрагентам

Автор: Комаров Иван Сергеевич
Дата создания: 11/30/09
Author: Ivan Komarov
Creation date: 11/30/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obcntr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obcntr.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость по контрагентам ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ cmp/operlist.i }
{ str/trdcalib.i }
{ gbl/prn-lib.i  }
{ rep/fmtcli.i   }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ rep/r-sym.i }
define variable g#report-num as integer   no-undo .
{ gbl/paramls.i  }
{ gbl/waitfram.i }
{ ref/grplibfn.i }

/* parameters definitions ---                                           */
define input parameter p-curr-host-code  like ub.clients.obj-code   no-undo .
define input parameter p-curr-host-type  like ub.clients.obj-type   no-undo .
define input parameter x-base-type       like ub.currency.curr-abbr no-undo .
define input parameter x-base-code       like ub.currency.curr-code no-undo .
define input parameter p-detgoods        as logical                 no-undo .
define input parameter p-detdoctip       as logical                 no-undo .

define variable v-curr-r-b         as character   no-undo .
define variable v-print-rubl       as logical     no-undo .
def var v-old-name as char.

{ rep/lkp-font.i }
{ trg/factord.i }
define variable xserv as char init {&all} no-undo.

define buffer a-clients         for ub.clients .
define buffer buf_clients       for ub.clients .
define buffer buf_trn-doc       for ub.trn-doc  .
define buffer buf_doc-line      for ub.doc-line .
define buffer buf_doc-line-sum  for ub.doc-line-sum .
define buffer buf_goods         for ub.goods.
define buffer buf_cli-gds       for ub.cli-gds.
define buffer buf_gds-obj       for ub.gds-obj.
define buffer buf_ot-line       for ub.ot-line.

DEFINE temp-table buy-data no-undo
field obj-type            like ub.clients.obj-type
field obj-code            like ub.clients.obj-code
field obj-name            like ub.clients.obj-name
field name                as character
field gds-code            like ub.goods.gds-code
field artic               like ub.goods.artic
field prod-type           like ub.goods.prod-type
field prod-code           like ub.goods.prod-code
field ret-qnty            as decimal
field ras-qnty            as decimal
field all-qnty            as decimal
field cost-sum-rubl-ras   as decimal
field cost-sum-base-ras   as decimal
field sale-sum-rubl-ras   as decimal
field sale-sum-base-ras   as decimal
field cost-sum-rubl-ret   as decimal
field cost-sum-base-ret   as decimal
field sale-sum-rubl-ret   as decimal
field sale-sum-base-ret   as decimal
field cost-sum-rubl-all   as decimal
field cost-sum-base-all   as decimal
field sale-sum-rubl-all   as decimal
field sale-sum-base-all   as decimal
field doc-type            like ub.trn-doc.ext-doc-type
index pi IS PRIMARY UNIQUE obj-type obj-code gds-code
.

define temp-table tt-goods no-undo
  field gds-code      like ub.goods.gds-code
  field artic         like ub.goods.artic
  field prod-code     like ub.goods.prod-code
  field prod-type     like ub.goods.prod-type
index pi is primary unique
 artic prod-type prod-code
.

define temp-table itog no-undo
field  ret-qnty            as decimal
field  ras-qnty            as decimal
field  all-qnty            as decimal
field  cost-sum-rubl-ras   as decimal
field  cost-sum-base-ras   as decimal
field  sale-sum-rubl-ras   as decimal
field  sale-sum-base-ras   as decimal
field  cost-sum-rubl-ret   as decimal
field  cost-sum-base-ret   as decimal
field  sale-sum-rubl-ret   as decimal
field  sale-sum-base-ret   as decimal
field  cost-sum-rubl-all   as decimal
field  cost-sum-base-all   as decimal
field  sale-sum-rubl-all   as decimal
field  sale-sum-base-all   as decimal
field  obj-name            as character
field  obj-type            like buy-data.obj-type
field  obj-code            like buy-data.obj-code
index pi is primary obj-code obj-type obj-name
.

define variable itog-cost-sum-rubl-ras as decimal     no-undo.
define variable itog-cost-sum-base-ras as decimal     no-undo.
define variable itog-sale-sum-rubl-ras as decimal     no-undo.
define variable itog-sale-sum-base-ras as decimal     no-undo.
define variable itog-cost-sum-rubl-ret as decimal     no-undo.
define variable itog-cost-sum-base-ret as decimal     no-undo.
define variable itog-sale-sum-rubl-ret as decimal     no-undo.
define variable itog-sale-sum-base-ret as decimal     no-undo.
define variable itog-cost-sum-rubl-all as decimal     no-undo.
define variable itog-cost-sum-base-all as decimal     no-undo.
define variable itog-sale-sum-rubl-all as decimal     no-undo.
define variable itog-sale-sum-base-all as decimal     no-undo.
define variable itog-ras-qnty          as decimal     no-undo.
define variable itog-ret-qnty          as decimal     no-undo.
define variable itog-all-qnty          as decimal     no-undo.

define variable    valtype           as   integer no-undo.

/* local variable definitions ---                                       */
define variable    v-gds-counter     as integer             no-undo .

define variable    ObjName           as character           no-undo.
define variable    tPrintRubl        as logical             no-undo.
define variable    Line              as character           no-undo.

define variable F-pos-cli-code    as character  no-undo .
define variable F-Artic           as character  no-undo .
define variable F-Fullname        as character  no-undo.
define variable F-qnty-ras        as decimal    no-undo.
define variable F-qnty-ret        as decimal    no-undo.
define variable F-qnty-all        as decimal    no-undo.
define variable F-rashod          as decimal    no-undo.
define variable F-return          as decimal    no-undo.
define variable F-all             as decimal    no-undo.

define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-str  as character no-undo .
define variable C-c    as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define variable p-var  as integer no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable temp-str          as character                no-undo.
define variable str               as character format "x(60)" no-undo.
define variable i#i               as integer                  no-undo.
define variable i                 as integer                  no-undo.
define variable list-field        as character                no-undo.
define variable str10             as character                no-undo.
define variable Counter1          as integer   no-undo.

define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable disabledoptions   as integer   no-undo .
define variable v-orient-page     as character no-undo .

define stream  OutStream.
define stream  macr_excel .

define variable v-file-name     as character no-undo .
define variable v-file-name-ind as integer   no-undo .

  if p-detdoctip = true then do :
   assign line = fill( "-" , 155 ) .
  end .
  else do :
   assign line = fill( "-" , 110 ) .
  end .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

/*===================================================================================================================*/
  case x-SET_val_TYPE :
    when {&v-rubl} then do:
      assign  v-print-rubl = yes .
    end.
    when {&v-base} then do:
      assign  v-print-rubl = no .
    end.
    otherwise do:
      if x-SET_PAY_TYPE <> {&p-crsa} then  message "Неизвестный тип валюты!" skip "Отчет формируется в базовой валюте" view-as alert-box information .
      { gbl/curr-r-b.i v-curr-r-b }
      assign  v-print-rubl = ( v-curr-r-b = {&r-b-rubl} )  .
    end.
  end case.
  case x-SET_PAY_TYPE :
    when {&p-crsa} then do:
      assign show-crsa  = true .
    end.
    when {&p-cost} then do:
      assign show-cost  = true .
    end.
    otherwise do:
      assign show-sale  = true .
    end.
  end case.

run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-fdec.i }
{ rep/f-flav.i }
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
    then   assign tprintrubl = yes .
    else   assign tprintrubl = no .

  run waitfram-show ( {&mywaitmess} ) .
  { cmp/open-out.i stream outstream  " " reportpageheight }

  assign
  make-excel      = yes
  v-file-name     = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  v-file-name-ind = 1
.
output stream macr_excel to value(v-file-name) .
  run display-title .

run report-exec1. /*Расчет temp-table */

run calc-itog .   /*Расчет итогов*/

run print-text .  /*Вывод текстовой таблички*/

run print-excel . /*Вывод а Excel*/

end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure display-title :
num#str# = 1.
num#col# = 1.
put stream outstream  reportname  at 20 format "x(170)" skip
                      trim(str1)  at 20 format "x(75)" .
run macr_excel_char_with_format in this-procedure
                (input  reportname
                ,input  num#str#
                ,input  num#col#
                ) .
run macr_cell_format in this-procedure
  (input 18           /* p-size   */
  ,input true         /* p-bold   */
  ,input false        /* p-italic */
  ,input ?            /* p-color  */
  ,input num#str#     /* p-row    */
  ,input num#col#     /* p-col    */
  ,input ?            /* p-row-2  */
  ,input ?            /* p-col-2  */
  ) .

num#str# = num#str# + 1.

run macr_excel_char_with_format in this-procedure
                (input  str1
                ,input  num#str#
                ,input  num#col#
                ) .
num#str# = num#str# + 1.

repeat i = 1 to num-entries(str2,chr(10)) :
  put stream outstream entry(i,str2,chr(10))  at 1 format "x(170)" skip .
end.
run macr_excel_char_with_format in this-procedure
                (input  str2
                ,input  num#str#
                ,input  num#col#
                ) .
num#str# = num#str# + 1.

put stream outstream trim(str3)  at 1 format "x(75)" skip.
run macr_excel_char_with_format in this-procedure
                (input  str3
                ,input  num#str#
                ,input  num#col#
                ) .
num#str# = num#str# + 1.

repeat i = 1 to num-entries(str4,chr(10)) :
  put stream outstream entry(i,str4,chr(10))  at 1 format "x(170)" skip .
end.
run macr_excel_char_with_format in this-procedure
                (input  str4
                ,input  num#str#
                ,input  num#col#
                ) .
num#str# = num#str# + 1.

repeat i = 1 to num-entries(reportheader,chr(10)) :
  put stream outstream entry(i,reportheader,chr(10))  at 1 format "x(170)" skip .
end.
/*    {&put-u1}  string( v-cntxt-host-name-obj +  " , " + p-curr-host-type  +  " " + objname) at 50 format "x(85)" skip(2)*/
end procedure.

/*-------------------------------*/

procedure report-exec1  :
   find first a-clients where p-curr-host-type = a-clients.obj-type and
                              p-curr-host-code = a-clients.obj-code no-lock no-error.
  if available a-clients then  objname = a-clients.obj-name. else  objname = "объект не определен".

  run waitfram-show (objname) .
  run create-tt-goods.
find first G#CUSTOMER no-error .
  if not available G#CUSTOMER then do:
      for each buf_clients no-lock
        ,each obj-list
      :
          for each buf_trn-doc no-lock
              where buf_trn-doc.obj-code     = obj-list.obj-code /*p-curr-host-code*/
              and   buf_trn-doc.obj-type     = obj-list.obj-type /*p-curr-host-type*/
              and   buf_trn-doc.cli-type     = buf_clients.obj-type
              and   buf_trn-doc.cli-code     = buf_clients.obj-code
              and   buf_trn-doc.fact-date   >= x-date-start
              and   buf_trn-doc.fact-date   <= x-date-end
              and ( buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                or  buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} )
              and buf_trn-doc.status_        = {&fact}
              :
                  assign Counter1 = Counter1 + 1.
                  { rep/repfrm.i disp Counter1 }
                  { rep/r-obcntr.i buf_clients}
          end.
      end.
  end.
Else for each G#CUSTOMER no-lock
      ,each obj-list
     :
  for each buf_trn-doc no-lock
              where buf_trn-doc.obj-code     = obj-list.obj-code /*p-curr-host-code*/
              and   buf_trn-doc.obj-type     = obj-list.obj-type /*p-curr-host-type*/
              and   buf_trn-doc.cli-type     = G#CUSTOMER.obj-type
              and   buf_trn-doc.cli-code     = G#CUSTOMER.obj-code
              and   buf_trn-doc.fact-date   >= x-date-start
              and   buf_trn-doc.fact-date   <= x-date-end
              and ( buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                or  buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} )
              and buf_trn-doc.status_        = {&fact}
              :
                  assign Counter1 = Counter1 + 1.
                  { rep/repfrm.i disp Counter1 }
                  { rep/r-obcntr.i G#CUSTOMER}
  end.
end.


end procedure.

/* ==================================================================================================================== */
procedure create-tt-goods :

  define variable v-curr-grp-name as character no-undo .
  define variable v-host-code     like ub.clients.host-code  no-undo .

  do on error undo, return error return-value :
    run waitfram-show in this-procedure ( "Формирование списка товаров..." ) .
    empty temp-table tt-goods.

    for each obj-list :
      case x-SelectGood :
        when {&g-all} then do: /* все товары */
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
            :
            run fill-tt in this-procedure .
          end.
        end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli : /* встать на производителя */
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.prod-type = G#cli.obj-type
                and buf_gds-obj.prod-code = G#cli.obj-code
              use-index pi  :
              run fill-tt in this-procedure .
            end .
          end .                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins v-curr-grp-name
              use-index obj-grp :
              run fill-tt in this-procedure .
            end .
          end.
        end.
        otherwise do:  /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run fill-tt in this-procedure .
          end.
        end.

      end case.
    end.                    /* for each ... по объектам */
    run waitfram-hide in this-procedure .
  end.
end procedure. /* create-tt-goods */

/* =====================================================================*/
procedure fill-tt :

  do  on error undo, return error return-value :
    find first tt-goods no-lock
    where tt-goods.artic     = buf_gds-obj.artic
      and tt-goods.prod-type = buf_gds-obj.prod-type
      and tt-goods.prod-code = buf_gds-obj.prod-code
      no-error.
    if not available tt-goods then do:
      create tt-goods.
      assign
        v-gds-counter      = v-gds-counter + 1
        tt-goods.prod-type = buf_gds-obj.prod-type
        tt-goods.prod-code = buf_gds-obj.prod-code
        tt-goods.artic     = buf_gds-obj.artic
        tt-goods.gds-code  = buf_gds-obj.gds-code
      .
    end.
  end.
end procedure. /* fill-tt */
/* ==================================================================================================================== */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-goods.
end.

end procedure. /* clear-tt */
/* ==================================================================================================================== */
procedure calc-itog :
for each buy-data by buy-data.obj-name :
     find first itog
     where itog.obj-code = buy-data.obj-code
       and itog.obj-type = buy-data.obj-type
       no-error .
       if available itog then do:
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }
          assign
                itog.ret-qnty          = itog.ret-qnty          + buy-data.ret-qnty
                itog.ras-qnty          = itog.ras-qnty          + buy-data.ras-qnty
                itog.all-qnty          = itog.all-qnty          + buy-data.all-qnty
                itog.cost-sum-rubl-ras = itog.cost-sum-rubl-ras + buy-data.cost-sum-rubl-ras
                itog.cost-sum-base-ras = itog.cost-sum-base-ras + buy-data.cost-sum-base-ras
                itog.sale-sum-rubl-ras = itog.sale-sum-rubl-ras + buy-data.sale-sum-rubl-ras
                itog.sale-sum-base-ras = itog.sale-sum-base-ras + buy-data.sale-sum-base-ras
                itog.cost-sum-rubl-ret = itog.cost-sum-rubl-ret + buy-data.cost-sum-rubl-ret
                itog.cost-sum-base-ret = itog.cost-sum-base-ret + buy-data.cost-sum-base-ret
                itog.sale-sum-rubl-ret = itog.sale-sum-rubl-ret + buy-data.sale-sum-rubl-ret
                itog.sale-sum-base-ret = itog.sale-sum-base-ret + buy-data.sale-sum-base-ret
                itog.cost-sum-rubl-all = itog.cost-sum-rubl-all + buy-data.cost-sum-rubl-all
                itog.cost-sum-base-all = itog.cost-sum-base-all + buy-data.cost-sum-base-all
                itog.sale-sum-rubl-all = itog.sale-sum-rubl-all + buy-data.sale-sum-rubl-all
                itog.sale-sum-base-all = itog.sale-sum-base-all + buy-data.sale-sum-base-all
          .
       end.
       else do:
          create itog.
          assign
                itog.ret-qnty          = itog.ret-qnty          + buy-data.ret-qnty
                itog.ras-qnty          = itog.ras-qnty          + buy-data.ras-qnty
                itog.all-qnty          = itog.all-qnty          + buy-data.all-qnty
                itog.cost-sum-rubl-ras = itog.cost-sum-rubl-ras + buy-data.cost-sum-rubl-ras
                itog.cost-sum-base-ras = itog.cost-sum-base-ras + buy-data.cost-sum-base-ras
                itog.sale-sum-rubl-ras = itog.sale-sum-rubl-ras + buy-data.sale-sum-rubl-ras
                itog.sale-sum-base-ras = itog.sale-sum-base-ras + buy-data.sale-sum-base-ras
                itog.cost-sum-rubl-ret = itog.cost-sum-rubl-ret + buy-data.cost-sum-rubl-ret
                itog.cost-sum-base-ret = itog.cost-sum-base-ret + buy-data.cost-sum-base-ret
                itog.sale-sum-rubl-ret = itog.sale-sum-rubl-ret + buy-data.sale-sum-rubl-ret
                itog.sale-sum-base-ret = itog.sale-sum-base-ret + buy-data.sale-sum-base-ret
                itog.cost-sum-rubl-all = itog.cost-sum-rubl-all + buy-data.cost-sum-rubl-all
                itog.cost-sum-base-all = itog.cost-sum-base-all + buy-data.cost-sum-base-all
                itog.sale-sum-rubl-all = itog.sale-sum-rubl-all + buy-data.sale-sum-rubl-all
                itog.sale-sum-base-all = itog.sale-sum-base-all + buy-data.sale-sum-base-all
                itog.obj-code          = buy-data.obj-code
                itog.obj-type          = buy-data.obj-type
                itog.obj-name          = buy-data.obj-name
            .
       end.
end.
for each itog :
               assign
                itog-cost-sum-rubl-ras = itog-cost-sum-rubl-ras + itog.cost-sum-rubl-ras
                itog-cost-sum-base-ras = itog-cost-sum-base-ras + itog.cost-sum-base-ras
                itog-sale-sum-rubl-ras = itog-sale-sum-rubl-ras + itog.sale-sum-rubl-ras
                itog-sale-sum-base-ras = itog-sale-sum-base-ras + itog.sale-sum-base-ras
                itog-cost-sum-rubl-ret = itog-cost-sum-rubl-ret + itog.cost-sum-rubl-ret
                itog-cost-sum-base-ret = itog-cost-sum-base-ret + itog.cost-sum-base-ret
                itog-sale-sum-rubl-ret = itog-sale-sum-rubl-ret + itog.sale-sum-rubl-ret
                itog-sale-sum-base-ret = itog-sale-sum-base-ret + itog.sale-sum-base-ret
                itog-cost-sum-rubl-all = itog-cost-sum-rubl-all + itog.cost-sum-rubl-all
                itog-cost-sum-base-all = itog-cost-sum-base-all + itog.cost-sum-base-all
                itog-sale-sum-rubl-all = itog-sale-sum-rubl-all + itog.sale-sum-rubl-all
                itog-sale-sum-base-all = itog-sale-sum-base-all + itog.sale-sum-base-all
                itog-ret-qnty          = itog-ret-qnty          + itog.ret-qnty
                itog-ras-qnty          = itog-ras-qnty          + itog.ras-qnty
                itog-all-qnty          = itog-all-qnty          + itog.all-qnty
               .
end.
end procedure. /* calc-itog */

/* ==================================================================================================================== */

procedure print-text :
  if p-detdoctip = true
  then do :
  DEFINE FRAME obcntr-det
          sym1            column-label ":!:"                      format "x(1)"                 space(0)
          F-pos-cli-code  column-label "Код ! ":C9                format "x(9)"                 space(0)
          sym2            column-label ":!:"                      format "x(1)"                 space(0)
          F-Artic         column-label "Артикул! ":C16            format "X(16)"                space(0)
          sym3            column-label ":!:"                      format "x(1)"                 space(0)
          F-Fullname      column-label "Наименование! ":C40       format "X(40)"                space(0)
          sym4            column-label ":!:"                      format "x(1)"                 space(0)
          F-qnty-ras      column-label "Количество! Расход ":C12  format "->>>>>>9.999"         space(0)
          sym5            column-label ":!:"                      format "x(1)"                 space(0)
          F-rashod        column-label "Расход ! ":C15            format "->>>>>>>>>>9.99"      space(0)
          sym6            column-label ":!:"                      format "x(1)"                 space(0)
          F-qnty-ret      column-label "Количество! Возврат ":C12 format "->>>>>>9.999"         space(0)
          sym7            column-label ":!:"                      format "x(1)"                 space(0)
          F-return        column-label "Возврат ! ":C15           format "->>>>>>>>>>9.99"      space(0)
          sym8            column-label ":!:"                      format "x(1)"                 space(0)
          F-qnty-all      column-label "Итого! количество":C12    format "->>>>>>9.999"         space(0)
          sym9            column-label ":!:"                      format "x(1)"                 space(0)
          F-all           column-label "Итого! обороты!":C15      format "->>>>>>>>>>9.99"      space(0)
          sym10           column-label ":!:"                      format "x(1)"                 space(0)
      HEADER
          string( "Страница " + string((PAGE-NUMBER( OutStream ) + 1) , ">>>>9") ) AT 140 format "X(15)" skip
          Line format "X(160)" at 1 skip
    with width {&DOS_CW}  down stream-io use-text NO-BOX.
        FORM HEADER
            "Продолжение - на следующей странице" AT 100 SKIP
      with FRAME Outstream width {&DOS_CW}  PAGE-BOTTOM NO-LABELS no-box.
    VIEW stream Outstream FRAME obcntr-det .
    FORM with FRAME obcntr-det .
  end.
  else do:
  DEFINE FRAME obcntr
          sym1            column-label ":!:"                      format "x(1)"                 space(0)
          F-pos-cli-code  column-label "Код !  ":C9               format "x(9)"                 space(0)
          sym2            column-label ":!:"                      format "x(1)"                 space(0)
          F-Artic         column-label "Артикул! ":C16            format "X(16)"                space(0)
          sym3            column-label ":!:"                      format "x(1)"                 space(0)
          F-Fullname      column-label "Наименование! ":C40       format "X(40)"                space(0)
          sym4            column-label ":!:"                      format "x(1)"                 space(0)
          F-qnty-all      column-label "Количество! ":C12         format "->>>>>>9.999"         space(0)
          sym5            column-label ":!:"                      format "x(1)"                 space(0)
          F-all           column-label "Итого обороты! ":C15      format "->>>>>>>>>>9.99"      space(0)
          sym6            column-label ":!:"                      format "x(1)"                 space(0)
      HEADER
          string( "Страница " + string((PAGE-NUMBER( OutStream ) + 1) , ">>>>9") ) AT 78 format "X(15)" skip
          Line format "X(98)" AT 1 skip
    with width {&DOS_CW} down stream-io use-text NO-BOX.
    FORM HEADER
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME Outstream width {&DOS_CW} PAGE-BOTTOM NO-LABELS no-box.
    VIEW stream Outstream FRAME obcntr .
    FORM with FRAME obcntr .
  end.


  for each itog by itog.obj-name:
      if p-detdoctip = true then do:
          display stream Outstream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 when p-detgoods = true
          itog.obj-name                                      when p-detgoods = true    @ F-Fullname
          with frame obcntr-det .
          down stream Outstream 1 with frame obcntr-det .
          for each buy-data
          where buy-data.obj-type = itog.obj-type
          and   buy-data.obj-code = itog.obj-code
          and   p-detgoods = true
          :
              display stream Outstream
                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                  buy-data.gds-code           @ F-pos-cli-code
                  buy-data.artic              @ F-Artic
                  buy-data.name               @ F-Fullname
                  buy-data.ras-qnty           @ F-qnty-ras
                  buy-data.ret-qnty           @ F-qnty-ret
                  buy-data.all-qnty           @ F-qnty-all
                  buy-data.cost-sum-rubl-ras  when ( v-print-rubl = true and show-cost = true) @ F-rashod
                  buy-data.sale-sum-rubl-ras  when ( v-print-rubl = true and show-sale = true) @ F-rashod
                  buy-data.cost-sum-base-ras  when ( v-print-rubl = false and show-cost = true) @ F-rashod
                  buy-data.sale-sum-base-ras  when ( v-print-rubl = false and show-sale = true) @ F-rashod

                  buy-data.sale-sum-rubl-ret  when ( v-print-rubl = true and show-sale = true) @ F-return
                  buy-data.cost-sum-rubl-ret  when ( v-print-rubl = true and show-cost = true) @ F-return
                  buy-data.sale-sum-base-ret  when ( v-print-rubl = false and show-sale = true) @ F-return
                  buy-data.cost-sum-base-ret  when ( v-print-rubl = false and show-cost = true) @ F-return

                  buy-data.sale-sum-rubl-all  when ( v-print-rubl = true and show-sale = true) @ F-all
                  buy-data.cost-sum-rubl-all  when ( v-print-rubl = true and show-cost = true) @ F-all
                  buy-data.sale-sum-base-all  when ( v-print-rubl = false and show-sale = true) @ F-all
                  buy-data.cost-sum-base-all  when ( v-print-rubl = false and show-cost = true) @ F-all
                  with frame obcntr-det .
                  down stream Outstream 1 with frame obcntr-det .

          end.
          display stream Outstream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
          ("Итого " + itog.obj-name) when p-detgoods = true @ F-fullname
          itog.obj-name              when p-detgoods = false  @ F-fullname
          itog.ras-qnty                                                                    @ F-qnty-ras
          itog.ret-qnty                                                                    @ F-qnty-ret
          itog.all-qnty                                                                    @ F-qnty-all
          itog.cost-sum-rubl-ras   when ( v-print-rubl = true  and show-cost = true)       @ F-rashod
          itog.sale-sum-rubl-ras   when ( v-print-rubl = true  and show-sale = true)       @ F-rashod
          itog.cost-sum-base-ras   when ( v-print-rubl = false and show-cost = true)       @ F-rashod
          itog.sale-sum-base-ras   when ( v-print-rubl = false and show-sale = true)       @ F-rashod

          itog.cost-sum-rubl-ret   when ( v-print-rubl = true  and show-cost = true)       @ F-return
          itog.sale-sum-rubl-ret   when ( v-print-rubl = true  and show-sale = true)       @ F-return
          itog.cost-sum-base-ret   when ( v-print-rubl = false and show-cost = true)       @ F-return
          itog.sale-sum-base-ret   when ( v-print-rubl = false and show-sale = true)       @ F-return

          itog.cost-sum-rubl-all   when ( v-print-rubl = true  and show-cost = true)       @ F-all
          itog.sale-sum-rubl-all   when ( v-print-rubl = true  and show-sale = true)       @ F-all
          itog.cost-sum-base-all   when ( v-print-rubl = false and show-cost = true)       @ F-all
          itog.sale-sum-base-all   when ( v-print-rubl = false and show-sale = true)       @ F-all

          with frame obcntr-det .
          down stream Outstream 1 with frame obcntr-det .
          underline stream outstream F-pos-cli-code F-Artic F-Fullname F-qnty-ras F-qnty-ret F-qnty-all F-rashod F-return F-all with frame obcntr-det .
      end.
      else do :
          display stream Outstream
              sym1 sym2 sym3 sym4 sym5 sym6  when p-detgoods = true
              itog.obj-name                  when p-detgoods = true     @ F-Fullname
              with frame obcntr .
              down stream Outstream 1 with frame obcntr .
          for each buy-data
          where buy-data.obj-type = itog.obj-type
          and   buy-data.obj-code = itog.obj-code
          and p-detgoods = true
          :
              display stream Outstream
                  sym1 sym2 sym3 sym4 sym5 sym6
                  buy-data.gds-code             @ F-pos-cli-code
                  buy-data.artic                @ F-Artic
                  buy-data.name                 @ F-Fullname
                  buy-data.all-qnty             @ F-qnty-all
                  buy-data.sale-sum-rubl-all  when ( v-print-rubl = true  and show-sale = true) @ F-all
                  buy-data.cost-sum-rubl-all  when ( v-print-rubl = true  and show-cost = true) @ F-all
                  buy-data.sale-sum-base-all  when ( v-print-rubl = false and show-sale = true) @ F-all
                  buy-data.cost-sum-base-all  when ( v-print-rubl = false and show-cost = true) @ F-all
                  with frame obcntr .
                down stream Outstream 1 with frame obcntr .
          end.
          display stream Outstream
          sym1 sym2 sym3 sym4 sym5 sym6
          ("Итого " + itog.obj-name)            when p-detgoods = true                @ F-fullname
          itog.obj-name                         when p-detgoods = false               @ F-fullname
          itog.all-qnty                                                               @ F-qnty-all
          itog.cost-sum-rubl-all   when ( v-print-rubl = true  and show-cost = true)  @ F-all
          itog.sale-sum-rubl-all   when ( v-print-rubl = true  and show-sale = true)  @ F-all
          itog.cost-sum-base-all   when ( v-print-rubl = false and show-cost = true)  @ F-all
          itog.sale-sum-base-all   when ( v-print-rubl = false and show-sale = true)  @ F-all
          with frame obcntr .
          down stream Outstream 1 with frame obcntr .
          underline stream outstream F-pos-cli-code F-Artic F-Fullname F-qnty-all F-all  with frame obcntr .
      end.
  end.

  if p-detdoctip = true then do:
      display stream Outstream
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
      "Итого по всем контрагентам: " @ F-fullname
          itog-ras-qnty                                                                    @ F-qnty-ras
          itog-ret-qnty                                                                    @ F-qnty-ret
          itog-all-qnty                                                                    @ F-qnty-all
          itog-cost-sum-rubl-ras   when ( v-print-rubl = true  and show-cost = true)       @ F-rashod
          itog-sale-sum-rubl-ras   when ( v-print-rubl = true  and show-sale = true)       @ F-rashod
          itog-cost-sum-base-ras   when ( v-print-rubl = false and show-cost = true)       @ F-rashod
          itog-sale-sum-base-ras   when ( v-print-rubl = false and show-sale = true)       @ F-rashod

          itog-cost-sum-rubl-ret   when ( v-print-rubl = true  and show-cost = true)       @ F-return
          itog-sale-sum-rubl-ret   when ( v-print-rubl = true  and show-sale = true)       @ F-return
          itog-cost-sum-base-ret   when ( v-print-rubl = false and show-cost = true)       @ F-return
          itog-sale-sum-base-ret   when ( v-print-rubl = false and show-sale = true)       @ F-return

          itog-cost-sum-rubl-all   when ( v-print-rubl = true  and show-cost = true)       @ F-all
          itog-sale-sum-rubl-all   when ( v-print-rubl = true  and show-sale = true)       @ F-all
          itog-cost-sum-base-all   when ( v-print-rubl = false and show-cost = true)       @ F-all
          itog-sale-sum-base-all   when ( v-print-rubl = false and show-sale = true)       @ F-all
      with frame obcntr-det .
      down stream Outstream 1 with frame obcntr-det .
      underline stream outstream F-pos-cli-code F-Artic F-Fullname F-qnty-ras F-qnty-ret F-qnty-all F-rashod F-return F-all with frame obcntr-det .
  end.
  else do:
      display stream Outstream
          sym1 sym2 sym3 sym4 sym5 sym6
          ("Итого по всем контрагентам: " )                                           @ F-fullname
          itog-all-qnty                                                               @ F-qnty-all
          itog-cost-sum-rubl-all   when ( v-print-rubl = true  and show-cost = true)  @ F-all
          itog-sale-sum-rubl-all   when ( v-print-rubl = true  and show-sale = true)  @ F-all
          itog-cost-sum-base-all   when ( v-print-rubl = false and show-cost = true)  @ F-all
          itog-sale-sum-base-all   when ( v-print-rubl = false and show-sale = true)  @ F-all
          with frame obcntr .
          down stream Outstream 1 with frame obcntr .
          underline stream outstream F-pos-cli-code F-Artic F-Fullname F-qnty-all F-all  with frame obcntr .
  end.
end procedure .

/* ==================================================================================================================== */

procedure print-excel .

run proc-print-header in this-procedure .

if p-detdoctip = true then do :
put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , 7 , 1 , num#str# ,  9 ) + {&new-line}  +
       'BORDER( 2, 2, 2, 2, , , , , , , ) '  + {&new-line} .
end.
else do :
put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , 7 , 1 , num#str# ,  5 ) + {&new-line}  +
       'BORDER( 2, 2, 2, 2, , , , , , , ) '  + {&new-line} .

end.


num#str# = num#str# + 1 .
for each itog by itog.obj-name :
        Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }
        if p-detgoods = true then do :
              assign num#col# = 3.
              run macr_excel_char_with_format in this-procedure
                (input  itog.obj-name
                ,input  num#str#
                ,input  num#col#
                ) .
                run macr_cell_format in this-procedure
                  (input 10           /* p-size   */
                  ,input true         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
              assign num#str# = num#str# + 1 .
              for each buy-data
              where buy-data.obj-type = itog.obj-type
              and   buy-data.obj-code = itog.obj-code
              :
                    assign num#col# = 1 .
                    run macr_excel_char_with_format in this-procedure
                      (input  buy-data.gds-code
                      ,input  num#str#
                      ,input  num#col#
                      ) .
                    assign num#col# = num#col# + 1 .
                    run macr_excel_char_with_format in this-procedure
                      (input  buy-data.artic
                      ,input  num#str#
                      ,input  num#col#
                      ) .
                    assign num#col# = num#col# + 1 .
                    run macr_excel_char_with_format in this-procedure
                      (input  buy-data.name
                      ,input  num#str#
                      ,input  num#col#
                      ) .
                    assign num#col# = num#col# + 1 .
              { rep/r-cntrxl.i  "buy-data." false }
              end. /*for each buy-data*/
              assign num#col# = 3 .
              run macr_excel_char_with_format in this-procedure
                (input  ("Итого " + itog.obj-name)
                ,input  num#str#
                ,input  num#col#
                ) .
              run macr_cell_format in this-procedure
                (input 10           /* p-size   */
                ,input true         /* p-bold   */
                ,input false        /* p-italic */
                ,input ?            /* p-color  */
                ,input num#str#     /* p-row    */
                ,input num#col#     /* p-col    */
                ,input ?            /* p-row-2  */
                ,input ?            /* p-col-2  */
                ) .
                assign num#col# = num#col# + 1 .
       { rep/r-cntrxl.i  "itog." true }
       end.
       else do :   /*сразу ПЕЧАТЬ ИТОГОВ*/
              Counter1 = Counter1 + 1.
              { rep/repfrm.i disp Counter1 }

              assign num#col# = 3 .
              run macr_excel_char_with_format in this-procedure
                (input  itog.obj-name
                ,input  num#str#
                ,input  num#col#
                ) .
                assign num#col# = num#col# + 1 .
       { rep/r-cntrxl.i  "itog." false }
       end.
end.
assign num#col# = 3 .
run macr_excel_char in this-procedure
  (input  "Итого по всем контрагентам: "
  ,input  num#str#
  ,input  num#col#
  ) .
run macr_cell_format in this-procedure
  (input 10           /* p-size   */
  ,input true         /* p-bold   */
  ,input false        /* p-italic */
  ,input ?            /* p-color  */
  ,input num#str#     /* p-row    */
  ,input num#col#     /* p-col    */
  ,input ?            /* p-row-2  */
  ,input ?            /* p-col-2  */
  ) .
  assign num#col# = num#col# + 1 .
{ rep/r-cntrxl.i "itog-" true }


hide   stream outstream frame obcntr .
output stream outstream close.
run waitfram-hide in this-procedure .

Output stream Macr_Excel  close .

run paramls-write in this-procedure
  (input  "file"
  ,input  string(v-file-name-ind)
  ,input  v-file-name
  ) .

run end-proc in this-procedure .

run gbl/prnfilen.w
         ( input  ""
         , input  8
         , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         , input  ReportFontNum
         , output v-user-action
         , output v-printed
         ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end procedure .

 { rep/r-libmcr.i macr_excel         }