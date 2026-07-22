block-level on error undo, throw.
/*

$Revision: 899f5f3721f3, 1951, rls $
$Author: ASMorozov $
$Date: Fri Jul 26 11:39:33 2019 +0300 $
$Workfile: r-wr-off.p $
$Archive: rep/r-wr-off.p $

Отчет по списанию

Автор: Шальнев Иван Сергеевич
Дата создания: 17/06/11
Author: Shalnev ivan
Creation date: 17/06/11


*/

define variable vss-revision    as character no-undo init "$Revision: 899f5f3721f3, 1951, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:39:33 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wr-off.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wr-off.p $":U .
define variable vss-description as character no-undo init "Отчет по списанию ".
{ cmp/vssrevis.i }


define temp-table tt-write-off no-undo
field object        as character
field wr-off-num    as character
field pri-num       as character
field prt-date      as date
field qnty          as decimal
field sum-rubl      as decimal
field vat-rubl      as decimal
field vat           as decimal
index pi
object
wr-off-num
.

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_parts for ub.parts.
define buffer buf_doc-attr for ub.doc-attr.

define variable Counter1      as integer no-undo.
define variable v-fact-order-start like ub.ot-line.fact-order no-undo.
define variable v-fact-order-end   like ub.ot-line.fact-order no-undo.


&scop frame-name calcwastage

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i "new shared" }
{ trg/factord.i  }
{ rep/r-sym.i    }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ rep/repfrm.i   def }   /* Показать окно информации о текущем процессе */
{ cmp/r-page1.i  }
{ str/in-vatp.i  def }
{ str/trdcalib.i }

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
        sym1                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.object        column-label "Наименование!объекта":C50               format "X(30)"         space(0)
        sym2                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.wr-off-num    column-label "Номер документа!списания":C15           format "x(15)"         space(0)
        sym3                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.pri-num       column-label "Номер приходной!накладной":C15          format "X(15)"         space(0)
        sym4                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.prt-date      column-label "Дата поступления!партии":C16            format "99/99/9999"    space(0)
        sym5                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.qnty          column-label "Количество":C13                         format "->>>>>>>>9.99" space(0)
        sym6                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.sum-rubl      column-label "Сумма учетных цен!без НДС":C20          format "->>>>>>>>9.99" space(0)
        sym7                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.vat-rubl      column-label "Сумма НДС!(учетные цены)":C20           format "->>>>>>>>9.99" space(0)
        sym8                       column-label ":!:"                                  format "X(1)"          space(0)
        tt-write-off.vat           column-label "Ставка НДС":C15                         format "->>>>>>>>9.99" space(0)
        sym9                       column-label ":!:"                                  format "X(1)"          space(0)
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
"-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
with width {&DOS_CW_2} down stream-io .


do:

  run prn-lib-open-stream  in this-procedure
    ( input my-handle
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
    ).
  run print-header.
  assign  Counter1 = 0 .
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
  run day-begin-fact-order(
      input x-Date-Start,
      output v-fact-order-start
      ).
  run factord-end-day(
      input x-Date-End,
      output v-fact-order-end
      ).
  def var v-value as character no-undo.
  def var v-type  as character no-undo.
  def var v-tech-pass as logical no-undo.      
  for each obj-list no-lock
   :
    for each buf_trn-doc no-lock
       where buf_trn-doc.obj-type     = obj-list.obj-type
         and buf_trn-doc.obj-code     = obj-list.obj-code
         and buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
         and buf_trn-doc.fact-order  >= v-fact-order-start
         and buf_trn-doc.fact-order   <= v-fact-order-end
         and buf_trn-doc.status_      = {&fact} :
      { str/tdat-val.i                                    
        buf_trn-doc.doc-code
        {&trdcattr-techpass}
        v-value 
        v-type 
        no-error
      }
      assign
        v-tech-pass = yes when v-value = "yes".
      
      if not (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = buf_trn-doc.doc-code
                                          and ub.sale-doc.doc-kind = {&sale-add-tech-refuell})) then do :
        for each buf_doc-line no-lock
            where buf_doc-line.doc-code = buf_trn-doc.doc-code :
          for each buf_parts no-lock
            where buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.out-code  = buf_trn-doc.doc-code :
          create tt-write-off.
          assign
            tt-write-off.object     = obj-list.obj-type + string(obj-list.obj-code) + " " + obj-list.obj-name
            tt-write-off.wr-off-num = buf_trn-doc.doc-code
            tt-write-off.pri-num    = buf_parts.in-code
            tt-write-off.prt-date   = buf_parts.fact-date
            tt-write-off.qnty       = buf_parts.fact-qnty
            tt-write-off.vat        = buf_parts.vat-pc
          .
          {str/in-vatp.i calc buf_doc-line. buf_trn-doc. g }
          assign
            tt-write-off.sum-rubl = tt-write-off.qnty * price-rubl-without-tax-loc
            tt-write-off.vat-rubl = tt-write-off.qnty * vat-rubl-loc
          .
          end. /*for each buf_parts*/
        end. /*for each buf_doc-line*/
      end.
    end. /*for each buf_trn-doc*/
  end. /*for each obj-list*/


  for each tt-write-off break by tt-write-off.object
                              by tt-write-off.wr-off-num :

    run print-line (input recid(tt-write-off)).
  end.
  output stream PrnLibStream close.
  { gbl/stopwork.i }
   {&CloseExcel}
  run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).

end.


  /* **********************  Internal Procedures  *********************** */


procedure print-line :
  DEFINE  INPUT PARAMETER p-line-rec_id   AS RECID     NO-UNDO.
for tt-write-off where recid (tt-write-off) = p-line-rec_id no-lock :

    {&PutExcel}
        tt-write-off.object      {&tabulation}
        tt-write-off.wr-off-num  {&tabulation}
        tt-write-off.pri-num     {&tabulation}
        tt-write-off.prt-date    {&tabulation}
        tt-write-off.qnty        {&tabulation}
        tt-write-off.sum-rubl    {&tabulation}
        tt-write-off.vat-rubl    {&tabulation}
        tt-write-off.vat         {&tabulation}
    skip.

    display stream PrnLibStream sym1  tt-write-off.object
                                sym2  tt-write-off.wr-off-num
                                sym3  tt-write-off.pri-num
                                sym4  tt-write-off.prt-date
                                sym5  tt-write-off.qnty
                                sym6  tt-write-off.sum-rubl
                                sym7  tt-write-off.vat-rubl
                                sym8  tt-write-off.vat
                                sym9 skip
    with frame {&FRAME-NAME} .
    down stream PrnLibStream with frame {&FRAME-NAME} .
end.
end. /*procedure print-line*/

procedure print-header :
find first sheetf where sheet-num = 1 /*no-error*/.
    assign
    Sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "Наименование объекта" + {&comma-char} +
                        "Номер документа списания " + {&comma-char} +
                        "Номер приходной накладной" + {&comma-char} +
                        "Дата поступления партии" + {&comma-char} +
                        "Количество" + {&comma-char} +
                        "Сумма учетных цен без НДС" + {&comma-char} +
                        "Сумма НДС (учетные цены)" + {&comma-char} +
                        "Ставка НДС"
    Sheetf.Sizes = "50,15,15,12,13,20,20,15"
    Sheetf.colformat = "1=@;2=@;3=@;4=dd/mm/yyyy;5=0,00;6=0,00;7=0,00;8=0,00"
    .
  RUN rep/extitle.p (1).
  if  length (str4) > 210 then do :
     str4 = substring(str4,1,205) + "..." .
  end.
  put stream PrnLibStream unformatted
  reportNAme  + {&new-line}
  + str1 + {&new-line} + str4
  .

end. /*procedure print-header*/