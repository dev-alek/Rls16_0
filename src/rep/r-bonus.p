block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bonus.p $
$Archive: rep/r-bonus.p $

Отчет по бонусам

Автор: Шальнев Иван Сергеевич
Дата создания: 23/07/10
Author: Shalnev ivan
Creation date: 23/07/10


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bonus.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-bonus.p $":U .
define variable vss-description as character no-undo init "Отчет по бонусам ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
/* parameters definitions ---                                           */
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter x-cli-art      as character          no-undo.
define input parameter x-postname     as character          no-undo.
define input parameter xclassify      as char               no-undo.
define input parameter xsorttype      as char               no-undo.
define input parameter x-cont-code    as integer            no-undo.
{ rep/r-defpst.i  &df = new  &framename = 'bonus':u }
{ rep/lkp-font.i }
{ trg/factord.i }
define variable xserv as char init {&all} no-undo.
/* define input parameter  xserv      as char no-undo. */
define buffer a-clients for ub.clients.
define  stream  outstream2.

define variable    chosedtype        as   integer no-undo.
define variable    valtype           as   integer no-undo.
define variable    firstline         as   logical     no-undo.

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* local variable definitions ---                                       */

define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.
define variable  quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.
define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-fdec.i }
{ rep/f-flav.i }
/*===================================================================================================================*/
assign
i=0
select-good   = x-selectgood
paytype       = x-set_pay_type
retclassify   = xclassify
retsorttype   = xsorttype
cli-art       = x-cli-art
postname      = x-postname
xtogobj       = true
firstline     = false
line          = fill("-", {&dos_cw_2})
valtype       = if (paytype = 1) then 0  else x-set_val_type.
type-stor = 1.
run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure report-execute :
  assign tprintrubl = yes .

  run waitfram-show ( {&mywaitmess} ) .
  { cmp/open-out.i stream outstream  " "  reportpageheight}
  run report-exec1 in this-procedure .

  hide   stream outstream frame zapas .
  output stream outstream close.
  run waitfram-hide .
  {&closeexcel}
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable disabledoptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
    (input  ""
    ,input  disabledoptions
    ,input  string(session :temp-directory) + {&df_name} + string( g#report-num )
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure print-header :
if not firstline then  do:
  run display-title.
end.
firstline = true .
form {&wfz} .  {&frame-d} .
break_group = true.
break_group1 = true.
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure print-footer :
/*------------------------------------------------------------------------------------------------------------------------
  purpose: Печать итогов отчета
  parameters:  <none>
  notes:
-------------------------------------------------------------------------------------------------------------------------*/
 end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure u-line :
underline stream outstream  {&all-sym9}
   gds-zap-b-code
   gds-zap-artic
   gds-zap-gds-name
   F-bonus
   F-price-sale
   F-kassa
   F-bonus-dohod
   F-nacenka
  {&wfz} .
  {&frame-d}.
  end procedure.
/*-------------------------------*/
procedure p-line :
underline stream outstream {&all-sym9}
   gds-zap-b-code
   gds-zap-artic
   gds-zap-gds-name
   F-bonus
   F-price-sale
   F-kassa
   F-bonus-dohod
   F-nacenka
  {&wfz}.
  {&frame-d} .
  end procedure.
/*-------------------------------*/
procedure calcitog :
/*------------------------------------------------------------------------------
  purpose:  Найти  на начало и конец  fact-order
  номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
      run factord-end-day (input x-date-start - 1 , output fact-order-1 ) .
      run factord-end-day (input x-date-end,        output fact-order-2 ) .
end procedure.


/*-------------------------------------------------------------------------------------------------------------*/
procedure display-bi  :

  run di-qnty ("кол-во",1,  "", gds-zap-artic ,"" ,"", "bi":u).

end procedure.


procedure clear-b1  :

end procedure.


procedure clear-b2  :

end procedure.

procedure clear-bi  :

end procedure.


procedure display-title :
define variable XLS-page-num  as integer   no-undo .
define variable sheet-name    as character no-undo .
define variable v-ii          as integer initial 0 no-undo .

   {&put-u1} reportname  at 65 format "x(170)" skip
            trim(str1)  at 1  format "x(75)"  skip.

  repeat i = 1 to num-entries(str2,chr(10)) :
  {&put-u1}  entry(i,str2,chr(10))  at 1 format "x(170)" skip.
  end.
i=0.

  {&put-u1}  trim(str3)  at 35 format "x(75)" skip.

  repeat i = 1 to num-entries(str4,chr(10)) :
  {&put-u1}  entry(i,str4,chr(10))  at 1 format "x(170)" skip.
  end.
i=0.

  repeat i = 1 to num-entries(reportheader,chr(10)) :
  {&put-u1}  entry(i,reportheader,chr(10))  at 1 format "x(170)" skip.
  end.
i=0.



for each SheetF where
          SheetF.Sheet-Num > 1
:
  delete SheetF .
end.



 run u-line.
 {&put-u1} "ОБЪЕКТЫ РАЗДЕЛЬНО" at 65 format "x(170)" skip.
 run p-line.

XLS-page-num = 0.
for each obj-list no-lock :
  XLS-page-num = XLS-page-num + 1.
  find first sheetf where sheetf.sheet-num = XLS-page-num no-error .
  if not available sheetf then do:
    create sheetf.
  end.
  assign
  sheet-name = obj-list.obj-name
  sheetf.sheet-num   = XLS-page-num
  sheetf.MergeCellsH = "1:4,5:8,9:11"
  sheetf.Excel-Column-Lable = "Объект:" + {&comma-char} + {&comma-char} + {&comma-char} + {&comma-char} + /**/
                            sheet-name + {&comma-char} + {&comma-char} + {&comma-char} + {&comma-char} + {&new-line} + /**/
                            "Код" + {&comma-char} +
                            "Артикул" + {&comma-char} +
                            "Наименование товара" + {&comma-char} +
                            "Значение бонуса" + {&comma-char} +
                            "Последняя цена прихода" + {&comma-char} +
                            "Касса продажа-возврат" + {&comma-char} +
                            "Валовой доход от бонуса" + {&comma-char} +
                            "Фактический % наценки" + {&comma-char}
  sheetf.Sizes  = "10,16,60,13,13,13,13,13"
  Sheetf.ColFOrmat = "2=@;3=@" + {&delim-par} + {&delim-par} + sheet-name
  Sheetf.Bas-File = "exe/Adjustw.bas"
  .
end. /*for each obj-list no-lock :*/
v-last-page = XLS-page-num + 1.


find first sheetf where sheetf.sheet-num = v-last-page no-error .
if not available sheetf then do:
  create sheetf.
end.
assign
sheetf.sheet-num = v-last-page
sheetf.MergeCellsH = "1:7"
sheetf.Excel-Column-Lable = "Итоги" + {&comma-char} + {&comma-char} + {&comma-char} + {&comma-char} + {&comma-char} + {&comma-char} + {&comma-char} + {&new-line} + /**/
                            "Код" + {&comma-char} +
                            "Артикул" + {&comma-char} +
                            "Наименование товара" + {&comma-char} +
                            "Значение бонуса" + {&comma-char} +
                            "Касса продажа-возврат" + {&comma-char} +
                            "Валовой доход от бонуса" + {&comma-char} +
                            "Фактический % наценки" + {&comma-char}
sheetf.Sizes  = "10,16,60,13,13,13,13"
Sheetf.ColFOrmat = "2=@;3=@" + {&delim-par} + {&delim-par} + "Итоги"
Sheetf.Bas-File = "exe/Adjustw.bas"
.
  end procedure.
 { rep/ostatok.i }



procedure report-exec1  :
  find first a-clients where
            a-clients.obj-type = x-store-type
        and a-clients.obj-code = x-store-code  no-lock no-error.
  if available a-clients then  objname = a-clients.obj-name. else  objname = "объект не определен".

  run waitfram-show (objname) .

  form with frame zapas .
  { rep/r-formh.i x(152) {&dos_cw_2}}
  run calcitog.
  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
    case retsorttype :
      when "sort-article":u  or when "sort-artic":u  then do :
        run rep/r-bn-2.p (x-store-code, x-store-type, x-base-type , x-base-code,x-cont-code ).
      end.
      when "sort-code":u  then  do :
        run rep/r-bn-4.p (x-store-code, x-store-type, x-base-type , x-base-code,x-cont-code ).
      end.
      when "sort-name":u  then do :
        run rep/r-bn-6.p (x-store-code, x-store-type, x-base-type , x-base-code,x-cont-code ).
      end.
    end case.
    run print-last-page.
  hide stream outstream frame bottomframe .
  end procedure.

procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to 6:
 assign
    v-bonus                    [kk]  = 0
    v-price-sale               [kk]  = 0
    v-kassa                    [kk]  = 0
    v-bonus-dohod              [kk]  = 0
    v-nacenka                  [kk]  = 0
    s-kassa                    [kk]  = 0
    s-bonus-dohod              [kk]  = 0
    s-nacenka                  [kk]  = 0
    .
 end.
end procedure.

procedure print-last-page :
find first sheetf where entry(3, sheetf.colformat, {&delim-par}) = "Итоги" no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = "Итоги"
            .
          end.
run u-line.
{&put-u1} "ИТОГИ" at 65 format "x(170)" skip.
run p-line.
    case retsorttype :
      when "sort-article":u  or when "sort-artic":u  then do :
        run rep/r-bn-1.p (x-store-code, x-store-type, x-base-type , x-base-code,x-cont-code ).
      end.
      when "sort-code":u  then  do :
        run rep/r-bn-3.p (x-store-code, x-store-type, x-base-type , x-base-code,x-cont-code ).
      end.
      when "sort-name":u  then do :
        run rep/r-bn-5.p (x-store-code, x-store-type, x-base-type , x-base-code,x-cont-code ).
      end.
    end case.
end procedure.