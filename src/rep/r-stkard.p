block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-stkard.p $
$Archive: rep/r-stkard.p $

Печатная форма стеллажные карты

Автор: Житкевич Александр Николаевич
Дата создания: 04/12/06
Author: Zhitkevich
Creation date: 04/12/06
*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter p-parent-proc as widget-handle no-undo.
define input parameter p-rec-id      as recid         no-undo.

/* VSS Variables Definitions */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-stkard.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-stkard.p $":U .
define variable vss-description as character no-undo init "Экспорт накладной".

/* Local Variable Definitions ---                                       */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i new } /* все что нужно для excel  и тп.*/
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i  def }
{ str/out-vatp.i  def }
{ str/in-vatp.i   def }
{ str/prl-vat.i  }
{ rep/cur-rate.i }
{ ref/gds-attr.i }
{ rep/p-fmt.i    }

define buffer buf_trn-doc       for ub.trn-doc  .
define buffer buf_doc-line      for ub.doc-line .
define buffer buf_goods         for ub.goods    .
define buffer buf_prod-bc       for ub.prod-bc  .
define buffer buf_bar-code      for ub.bar-code .
define buffer buf_parts         for ub.parts    .
define buffer buf_clients       for ub.clients  .
define buffer buf_temp_p-fmt_string-part for temp_p-fmt_string-part.

define shared variable CostPrice as logical no-undo.
define variable g#report-num     as integer no-undo.
define variable Rubl_Coeff       as decimal  no-undo.
my-handle = p-parent-proc.
run get-report-num in my-handle (output g#report-num).

DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
{ rep/opclexcl.i }
define buffer buf_doc  for ub.trn-doc.
&SCOP FRAME-NAME r-stkard


Main-Block:
do on error   undo Main-Block, leave Main-Block
  on end-key undo Main-Block, leave Main-Block :
  find buf_doc no-lock where recid( buf_doc ) = p-rec-id no-error.
  if not available buf_doc then do:
    message "Накладная не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Ждите..." ).
  IF SESSION :SET-WAIT-STATE( "COMPILER" ) THEN DO: END.
  RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT {&LS_PS_A4}, INPUT YES, INPUT NO ).
  Make-Excel = true.
  run  OpenForExcel.
  run print-header in this-procedure .
  if error-status :error then
  do:
    undo Main-Block, leave Main-Block.
  end.
  run print (p-rec-id)  no-error .
  /* запуск макроса*/
  if error-status :error then
  do:
    undo Main-Block, leave Main-Block.
  end.

  {&CloseExcel}
  output stream PrnLibStream close.

  if session :SET-WAIT-STATE( "":U       ) then do: end.
  run WaitFram-Hide in this-procedure.
  RUN prn-lib-prn-file IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT 8 ).

end. /* Main-Block */
run WaitFram-Hide in this-procedure.


procedure print-header :
  assign
    sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "" + {&comma-char} + "" + {&comma-char} + "" +  {&comma-char} + "" + {&comma-char} + ""
    Sheetf.Sizes = "15" + {&comma-char} + "15" + {&comma-char} + "15" + {&comma-char} + "15"
+ {&comma-char} + "15"
    Sheetf.colformat = "1=@;2=@;3=@;4=dd/mm/yyyy;5=@"
    ReportHeader = ""
    Sheetf.Bas-File = "exe/r-stkard.bas"
    .
  run rep/extitle.p(1).

end. /*procedure print-header*/


procedure print:

  define input parameter p-doc-recid as recid  no-undo.

  define variable v-article     as character no-undo .
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-obj-name as char no-undo.
  define variable v-cli-name as char no-undo.
  define variable str        as char no-undo.
  
  DEFINE FRAME {&FRAME-NAME}
    sym1  SPACE( 0 ) str                  FORMAT "x(16)"        SPACE( 1 )
    sym2  SPACE( 0 ) buf_goods.gds-name   FORMAT "x(73)"        SPACE( 0 )
    sym3  SPACE( 0 ) buf_parts.part-code  FORMAT "x(20)"        SPACE( 0 )
    sym4  SPACE( 0 ) buf_parts.last-date  FORMAT "99/99/9999"   SPACE( 0 )
    sym5  SPACE( 0 ) buf_clients.obj-name FORMAT "X(67)"        SPACE( 0 )
    sym6  SPACE( 0 )
    WITH WIDTH 195 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

  find buf_trn-doc no-lock where recid( buf_trn-doc ) = p-doc-recid .
  for each buf_doc-line no-lock where
    buf_trn-doc.doc-code = buf_doc-line.doc-code :

    find first buf_goods no-lock
      where buf_goods.prod-type = buf_doc-line.prod-type
      and buf_goods.prod-code = buf_doc-line.prod-code
      and buf_goods.artic = buf_doc-line.artic.

    find first buf_clients no-lock
      where  buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code
      no-error .

    for each buf_parts no-lock
      where buf_parts.out-code   = buf_doc-line.doc-code
      and buf_parts.obj-type   = buf_doc-line.obj-type
      and buf_parts.obj-code   = buf_doc-line.obj-code
      and buf_parts.artic      = buf_doc-line.artic
      and buf_parts.prod-type  = buf_doc-line.prod-type
      and buf_parts.prod-code  = buf_doc-line.prod-code
      :

      {&PutExcel}
      "Cтеллажная карта"   {&tabulation}
      buf_goods.gds-name   {&tabulation}
      buf_parts.part-code  {&tabulation}
      buf_parts.last-date  {&tabulation}
      buf_clients.obj-name {&tabulation}
      skip.
      
      run p-fmt-split in this-procedure (
        input buf_goods.gds-name
        , input 73
        ).
      find first buf_temp_p-fmt_string-part where buf_temp_p-fmt_string-part.str-key = 1 .
      display stream PrnLibStream
        sym1 "Cтеллажная карта" @ str
        sym2  buf_temp_p-fmt_string-part.string-part @ buf_goods.gds-name
        sym3  buf_parts.part-code
        when buf_parts.part-code <> ?
        sym4  buf_parts.last-date
        when buf_parts.last-date   <> ?
        sym5  buf_clients.obj-name
        when buf_clients.obj-name <> ?
        sym6
        with frame {&FRAME-NAME}.
      down stream PrnLibStream with frame {&FRAME-NAME}.
      
      for each buf_temp_p-fmt_string-part where buf_temp_p-fmt_string-part.str-key <> 1:
        display stream PrnLibStream 
          sym1 "" @ str
          sym2
          buf_temp_p-fmt_string-part.string-part @ buf_goods.gds-name
          sym3
          sym4
          sym5
          sym6
          with frame {&FRAME-NAME}.
        down stream PrnLibStream with frame {&FRAME-NAME}.
      end.
    end.
  end.

end.