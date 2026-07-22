block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-unlway.p $
$Archive: rep/r-unlway.p $

Печатные формы. Выгрузка товарной накладной

Автор: Морозов Александр Сергеевич
Дата создания: 05/03/11
Author: Alexandr Morozov
Creation date: 05/03/11

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter p-parent-proc as widget-handle no-undo.
define input parameter p-rec-id      as recid         no-undo.

/* VSS Variables Definitions */
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-unlway.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-unlway.p $":U.
define variable vss-description as character no-undo initial "Печатные формы. Выгрузка товарной накладной":U.

/* Local Variable Definitions ---                                       */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i   new } /* все что нужно для excel  и тп.*/
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i  def }
{ str/out-vatp.i  def }
{ str/in-vatp.i   def }
{ str/prl-vat.i  }
{ rep/cur-rate.i }
define shared variable CostPrice as logical no-undo.
define variable g#report-num     as integer no-undo.
define variable Rubl_Coeff       as decimal  no-undo.
run get-report-num in p-parent-proc (output g#report-num).
{ rep/opclexcl.i }
define buffer buf_doc  for ub.trn-doc.

/* ***************************  Main Block  *************************** */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  find buf_doc no-lock where recid( buf_doc ) = p-rec-id no-error.
  if not available buf_doc then do:
    message "Накладная не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  run WaitFram-Show in this-procedure ( input "Ждите..." ).
  if session :SET-WAIT-STATE( "COMPILER" ) then do: end.
  Make-Excel = true.
  run openforexcel in this-procedure .
  run print-header in this-procedure .

    run print-line-dtl in this-procedure (  input p-rec-id )
                                            no-error .
    if error-status :error then do: undo Main-Block, leave Main-Block. end.
    if error-status :error then do: undo Main-Block, leave Main-Block. end.



  {&CloseExcel}
  if session :SET-WAIT-STATE( "":U       ) then do: end.
  { gbl/stopwork.i }
  run rep/runexcel.p (string( session:temp-directory) + {&df_name} + string( g#report-num ) + ".txt") .
  os-delete value( string( session:temp-directory ) +
                            {&df_name} + string( g#report-num ) + ".txt":u ) .
  run WaitFram-Hide in this-procedure.

end. /* Main-Block */
run WaitFram-Hide in this-procedure.


procedure print-header :
  find first sheetf where sheet-num = 1 /*no-error*/.
  assign
    sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "Артикул-цвет-размер" + {&comma-char} +
                                "Наименование"        + {&comma-char} +
                                "Цена розничная"      + {&comma-char} +
                                "Количество"          + {&comma-char} +
                                "Цена за ед."         + {&comma-char} +
                                "Стоимость"           + {&comma-char} +
                                "Штрих коды"
    Sheetf.Sizes = "21,42,15,11,11,11,15"
    Sheetf.colformat = "1=@;2=@;3=0,00;4=0,00;5=0,00;6=0,00;7=0;"
  .
  assign
    str1 = ""
    str2 = ""
    str3 = ""
    str4 = ""
    ReportHeader = ""
  .
  run rep/extitle.p (1).
end. /*procedure print-header*/

procedure print-line-dtl :

define input parameter p-doc-recid as recid  no-undo.

define variable v-article     as character no-undo .
define variable v-wealth-name as character no-undo .
define variable v-cost-mpl    as decimal   no-undo .
define variable v-fact-qnty   as decimal   no-undo .
define variable v-cost        as decimal   no-undo .
define variable v-sum         as decimal   no-undo .
define variable v-b-code      as integer   no-undo .
define variable v-b-str       as character no-undo .
define variable v-prt-name    as character no-undo.

define variable v-doc-num     like ub.price-doc.doc-num     no-undo .
define variable v-price-sale  like ub.bar-code.b-code       no-undo .
define variable v-road-tax    like ub.price-list.road-tax   no-undo .
define variable v-excise      like ub.price-list.excise     no-undo .
define variable v-node-code     like    gds-prt.upper-code  no-undo.

    define buffer buf_trn-doc       for ub.trn-doc  .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_goods         for ub.goods    .
    define buffer buf_prod-bc       for ub.prod-bc  .
    define buffer buf_bar-code      for ub.bar-code .
  do
  for buf_trn-doc
    , buf_doc-line
  on error undo, return error
  :
    find buf_trn-doc no-lock where recid( buf_trn-doc ) = p-doc-recid .
    for each buf_doc-line no-lock where
           buf_trn-doc.doc-code = buf_doc-line.doc-code :
    find first buf_goods no-lock
      where buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        and buf_goods.artic = buf_doc-line.artic
    .
    assign
      v-wealth-name = ( if available buf_goods then buf_goods.gds-name   else "":U )
      v-article     = buf_doc-line.artic
    .
    for each gds-dtl no-lock
    where gds-dtl.prod-type = buf_doc-line.prod-type
      and gds-dtl.prod-code = buf_doc-line.prod-code
      and gds-dtl.artic     = buf_doc-line.artic
      and gds-dtl.doc-code  = buf_doc-line.doc-code
    :
    /*---S--------- Для каждого признака -----------------------------*/
    find first gds-prt no-lock
          where gds-prt.node-code = gds-dtl.prt-code
    .
	if CostPrice = yes
    then do:
        { str/in-vatp.i calc buf_doc-line. buf_trn-doc. g }
        assign
            v-cost = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
        .
    end.
    else do:
        { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. gds-dtl. }
        assign
            v-cost = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
        .
    end.
        find first buf_bar-code no-lock
              where buf_bar-code.gds-code  = buf_goods.gds-code
                and buf_bar-code.unit-cli  = buf_goods.unit-base
                and buf_bar-code.node-code = gds-dtl.prt-code
                and buf_bar-code.part-code = ""
                and buf_bar-code.in-code   = ""
        .
        find first buf_prod-bc no-lock
              where buf_prod-bc.b-code = buf_bar-code.b-code no-error
        .



        assign
          v-b-code  = buf_bar-code.b-code
          v-b-str = if available buf_prod-bc then buf_prod-bc.b-str else ""
        .
      { gbl/bcodeprc.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          v-b-code
          0
          0
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          no-error
      }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении цены бар-кода" skip
              "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
              "Бар-код" v-b-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
     run proc-cur-rate( input buf_trn-doc.obj-type, input buf_trn-doc.obj-code, output Rubl_Coeff ).
        assign
          v-prt-name = ""
        v-fact-qnty = gds-dtl.fact-qnty
        v-cost-mpl  = if PrintRubl then v-price-sale /* gds-dtl.price-rubl*/ else ( v-price-sale / Rubl_Coeff ) /*( gds-dtl.price-rubl / buf_trn-doc.base-rate ) */
        .
        do while available gds-prt:
            if available gds-prt
          then do:
            assign
                v-prt-name = "-" + string( gds-prt.node-name /*, "x(10)"*/ ) + v-prt-name
            .
          end.
            assign
                v-node-code = gds-prt.upper-code
            .
            find first gds-prt no-lock
                  where gds-prt.node-code = v-node-code
                    and gds-prt.root <> yes
            no-error.
        end.

    {&PutExcel}
          v-article + v-prt-name       {&tabulation}
          v-wealth-name   {&tabulation}
            v-cost-mpl      {&tabulation}
          v-fact-qnty     {&tabulation}
          v-cost          {&tabulation}
          (v-cost
          * v-fact-qnty)  {&tabulation}
          v-b-str         {&tabulation}
    skip.

    end.
          /*---E--------- Для каждого признака -----------------------------*/
  end.
  end.
end procedure. /* print-line-dtl */
