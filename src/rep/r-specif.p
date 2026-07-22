block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-specif.p $
$Archive: rep/r-specif.p $

Печать спецификации к документу по партиям

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/



define input parameter parParentProc as   widget-handle         no-undo.
define input parameter rec_id        as recid.
define input parameter print_zak     as log no-undo .  /* yes    если yes, то печатаем колонку с ценой закупки */

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-specif.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-specif.p $":U .
def var vss-description as character no-undo init "Печать спецификации к документу по партиям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i }
{ cmp/breakstr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

&scop PS-form 46

def var sym1 as char init ":" no-undo.
def var sym2 as char init ":" no-undo.
def var sym3 as char init ":" no-undo.
def var sym4 as char init ":" no-undo.
def var sym5 as char init ":" no-undo.
def var sym6 as char init ":" no-undo.
def var sym7 as char init ":" no-undo.
def var sym8 as char init ":" no-undo.
def var sym9 as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init ":" no-undo.

def var Line             as      char    no-undo.
def var tb-code          as      char    no-undo.
def var b-code           as      integer no-undo .
def var list-b-code      as      char    no-undo.
def var full_list-b-code as      char    no-undo.
def var is-new           as      logical no-undo.
def var new-list         as      char    no-undo.
def var Lines_Counter    as      integer no-undo.
def var part-b-code      as      char    no-undo.
/*def var Parts_Counter   as      integer no-undo.*/
def var tdoc-date    like trn-doc.doc-date no-undo.
def var tdoc-code    like trn-doc.doc-code no-undo.

def var i   as      integer                 no-undo.
def var parts-PS like parts.PS no-undo.
def var parts-PS1 like parts.PS no-undo.
def var parts-PS2 like parts.PS no-undo.

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }
{ rep/specifxl.i }

DEFINE STREAM Out_Stream.

DEFINE FRAME parts-print
        sym1 column-label ":!:" format "X(1)"                                        /*1*/  /*1-2*/
        Lines_Counter COLUMN-LABEL " N!п/п" format ">>>9"                            /*4*/  /*3-7*/
        sym2 column-label ":!:" format "X(1)"                                        /*1*/  /*8-9*/
        tb-code column-label "Код" format "x({&BarCode_Length})"                     /*10*/ /*10-20*/
        sym3 column-label ":!:" format "X(1)"                                        /*1*/  /*21-22*/
        goods.artic COLUMN-LABEL "Артикул" format "X(16)"                            /*16*/ /*23-39*/
        sym4 column-label ":!:" format "X(1)"                                        /*1*/  /*40-41*/
        goods.gds-name COLUMN-LABEL "Наименование!Партия" format "X(40)"             /*40*/ /*42-82*/
        sym5 column-label ":!:" format "X(1)"                                        /*1*/  /*83-84*/
        parts.fact-qnty COLUMN-LABEL " Количество " format "->>>,>>9.<<<"            /*12*/ /*85-97*/
        sym6 column-label ":!:" format "X(1)"                                        /*1*/  /*98-99*/
        goods.unit-base COLUMN-LABEL "Ед.!изм." format "X(4)"                        /*4*/  /*100-104*/
        sym7 column-label ":!:" format "X(1)"                                        /*1*/  /*105-106*/
        parts.last-date COLUMN-LABEL "Срок!годности" format "99.99.9999"             /*10*/ /*107-117*/
        sym8 column-label ":!:" format "X(1)"                                        /*1*/  /*118-119*/
        parts.PS COLUMN-LABEL "Описание" format "X({&PS-form})"                      /*46*/ /*120-166*/
        sym9 column-label ":!:" format "X(1)"                                        /*1*/  /*167-168*/
        list-b-code COLUMN-LABEL "БАР-КОДЫ по товару" format "X(27)"                 /*27*/ /*169-196*/
        sym10 column-label ":!:" format "X(1)"                                       /*1*/  /*197*/
    HEADER
        cur-time-print() AT 5 format "X(35)"
            tdoc-code AT 70 format "X(10)" " от " tdoc-date format "99/99/99"
            "Страница " AT 120 PAGE-NUMBER( Out_Stream ) AT 130 FORMAT ">>9" SKIP
        Line format "X(197)" AT 1
    with width {&DOS_CW} down stream-io.    /*235*/

DEFINE FRAME parts-print1
        sym1 column-label ":!:" format "X(1)"                                        /*1*/  /*1-2*/
        Lines_Counter COLUMN-LABEL " N!п/п" format ">>>9"                            /*4*/  /*3-7*/
        sym2 column-label ":!:" format "X(1)"                                        /*1*/  /*8-9*/
        tb-code column-label "Код" format "x({&BarCode_Length})"                     /*10*/ /*10-20*/
        sym3 column-label ":!:" format "X(1)"                                        /*1*/  /*21-22*/
        goods.artic COLUMN-LABEL "Артикул" format "X(16)"                            /*16*/ /*23-39*/
        sym4 column-label ":!:" format "X(1)"                                        /*1*/  /*40-41*/
        goods.gds-name COLUMN-LABEL "Наименование!Партия" format "X(40)"             /*40*/ /*42-82*/
        sym5 column-label ":!:" format "X(1)"                                        /*1*/  /*83-84*/
        parts.fact-qnty COLUMN-LABEL " Количество " format "->>>,>>9.<<<"            /*12*/ /*85-97*/
        sym6 column-label ":!:" format "X(1)"                                        /*1*/  /*98-99*/
        goods.unit-base COLUMN-LABEL "Ед.!изм." format "X(4)"                        /*4*/  /*100-104*/
        sym7 column-label ":!:" format "X(1)"                                        /*1*/  /*105-106*/
        parts.last-date COLUMN-LABEL "Срок!годности" format "99.99.9999"             /*10*/ /*107-117*/
        sym8 column-label ":!:" format "X(1)"                                        /*1*/  /*118-119*/
        parts.PS COLUMN-LABEL "Описание" format "X(32)"                              /*32*/ /*120-152*/
        sym9 column-label ":!:" format "X(1)"                                        /*1*/  /*153-154*/
        parts.price-rubl COLUMN-LABEL "   Цена  "   format "->>>,>>9.99"             /*11*/ /*155-166*/
        sym10 column-label ":!:" format "X(1)"                                       /*1*/  /*167-168*/
        list-b-code COLUMN-LABEL "БАР-КОДЫ по товару" format "X(27)"                 /*27*/ /*169-196*/
        sym11 column-label ":!:" format "X(1)"                                       /*1*/  /*197*/
    HEADER
        cur-time-print() AT 5 format "X(35)"
            tdoc-code AT 70 format "X(10)" " от " tdoc-date format "99/99/99"
            "Страница " AT 120 PAGE-NUMBER( Out_Stream ) AT 130 FORMAT ">>9" SKIP
        Line format "X(197)" AT 1
    with width {&DOS_CW} down stream-io.    /*235*/

FIND trn-doc WHERE recid( trn-doc ) = rec_id  NO-LOCK.

if session:set-wait-state("compiler") then.
Line = fill("-", 200).
assign
  Lines_Counter = 0
  tdoc-code = trn-doc.doc-code
  tdoc-date = trn-doc.doc-date
.

run get-report-num  in parParentProc(output g#report-num).
run get-quest-print in parParentProc(output g#quest-print).

{ cmp/open-out.i STREAM Out_Stream " "}
run specifxl-init in this-procedure .

 if print_zak = yes then do:
   FORM with FRAME parts-print1 .
 end.
 else do:
   FORM with FRAME parts-print .
 end.
 FORM HEADER
   Line format "X(197)" AT 1 SKIP "Продолжение - на следующей странице" AT 30 SKIP
   with FRAME BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .   /*198*/
 VIEW STREAM Out_Stream FRAME BottomFrame .

PUT STREAM Out_Stream "С П Е Ц И Ф И К А Ц И Я   к документу N "
    AT 32 format "X(40)" trn-doc.doc-code format "X(10)" "  от  "
    trn-doc.doc-date format "99.99.9999" SKIP(1).

run specifxl-write-cell-data in this-procedure (
      input {&specifxl-h_docName}
    , input string("С П Е Ц И Ф И К А Ц И Я   к документу №  " + string(trn-doc.doc-code) ) + "  от  " + string( trn-doc.doc-date, "99.99.9999" )
).
run specifxl-write-cell-data in this-procedure (
      input {&specifxl-h_printdate}
    , input cur-time-print()
).

FOR EACH doc-line WHERE doc-line.doc-code = trn-doc.doc-code NO-LOCK
                                              BY doc-line.artic:
    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                      goods.prod-code = doc-line.prod-code AND
                                      goods.artic = doc-line.artic NO-LOCK .

    if print_zak = yes then DISPLAY STREAM Out_Stream with FRAME parts-print1 .
    else                    DISPLAY STREAM Out_Stream with FRAME parts-print .

    assign
      Lines_Counter = Lines_Counter + 1
    .

    { gbl/gdsbcode.i  goods.gds-code  ?  b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" goods.gds-code skip
      view-as alert-box error .
      undo, return error .
    end.
    run b-code-lst in this-procedure .
    assign
      full_list-b-code = list-b-code
    .
    run sub-b-code-lst in this-procedure  (input-output list-b-code, output new-list) .

    if print_zak = no then do:
      DISPLAY STREAM Out_Stream
        sym1 Lines_Counter
        sym2 string( goods.gds-code ) @ tb-code
        sym3 goods.artic
        sym4 goods.gds-name
        sym5 (if can-do( {&fact} , trn-doc.status_ ) then doc-line.fact-qnty else doc-line.doc-qnty) @ parts.fact-qnty
        sym6 goods.unit-base
        sym7
        sym8
        sym9 list-b-code
        sym10
      with FRAME parts-print .
      DOWN STREAM Out_Stream 1 with FRAME parts-print .
    end.
    else do:
        DISPLAY STREAM Out_Stream
          sym1 Lines_Counter
          sym2 string( goods.gds-code ) @ tb-code
          sym3 goods.artic
          sym4 goods.gds-name
          sym5 (if can-do( {&fact} , trn-doc.status_ ) then doc-line.fact-qnty else doc-line.doc-qnty) @ parts.fact-qnty
          sym6 goods.unit-base
          sym7
          sym8
          sym9
          sym10 list-b-code
          sym11
        with FRAME parts-print1 .
        DOWN STREAM Out_Stream 1 with FRAME parts-print1 .
    end.
    run fill-line( Lines_Counter, goods.gds-code, goods.artic, goods.gds-name,
                   (if can-do( {&fact} , trn-doc.status_ ) then doc-line.fact-qnty else doc-line.doc-qnty),
                   goods.unit-base, ? /*p-last-date*/, "" /*p-PS*/, 0 /*p-price-rubl*/, full_list-b-code, print_zak ).

    FOR EACH parts NO-LOCK
      WHERE parts.out-code = trn-doc.doc-code
        AND parts.artic = doc-line.artic
        AND parts.prod-type = doc-line.prod-type
        AND parts.prod-code = doc-line.prod-code
    BREAK BY parts.part-code:

        FIND bar-code WHERE bar-code.gds-code = goods.gds-code AND
                                              bar-code.unit-cli = goods.unit-base AND
                                              bar-code.part-code = parts.part-code AND
                                              bar-code.in-code = parts.in-code
                                              NO-LOCK NO-ERROR .
        if available bar-code then do:
          assign tb-code = string( bar-code.b-code ).
          if lookup( tb-code, full_list-b-code ) = 0 then
            assign
              part-b-code = tb-code
              full_list-b-code = full_list-b-code + (if full_list-b-code = "" then "" else ",") + tb-code
              new-list = new-list + (if new-list = "" then "" else ",") + tb-code
            .
          else
            part-b-code = "".
        end.
        else
            assign tb-code = "" part-b-code = "".

        assign parts-PS = ENTRY( 1, parts.PS , chr( 10 ) ) .
        DO i = 2 TO ( NUM-ENTRIES( parts.PS , chr( 10 ) ) ) :
            assign parts-PS = parts-PS + " " + ENTRY( i, parts.PS , chr( 10 ) ) .
        END.
        assign parts-PS = trim( parts-PS ) .
        parts-PS1 = breakstr(parts-PS, (if print_zak = yes then 32 else {&PS-form} ), input-output parts-PS1, input-output parts-PS2).

        Assign
          list-b-code = new-list
        .
        run sub-b-code-lst in this-procedure  (input-output list-b-code, output new-list) .

        if print_zak = yes then do:
          DISPLAY STREAM Out_Stream
            sym1 /*Parts_Counter @ Lines_Counter*/
            sym2 /*tb-code*/
            sym3
            sym4 ( if parts.part-code = "" then "  ----  " else parts.part-code ) @ goods.gds-name
            sym5 ( if can-do( {&fact} , trn-doc.status_ ) then parts.fact-qnty else parts.qnty ) @ parts.fact-qnty
            sym6 goods.unit-base
            sym7 parts.last-date
            sym8 parts-PS1 @ parts.PS
            sym9 ( if PrintRubl = yes then parts.price-rubl else parts.price-base ) @ parts.price-rubl
            sym10 list-b-code
            sym11
          with FRAME parts-print1 .
          DOWN STREAM Out_Stream 1 with FRAME parts-print1 .
        end.
        else do:
          DISPLAY STREAM Out_Stream
            sym1 /*Parts_Counter @ Lines_Counter*/
            sym2 /*tb-code*/
            sym3
            sym4 ( if parts.part-code = "" then "  ----  " else parts.part-code ) @ goods.gds-name
            sym5 ( if can-do( {&fact} , trn-doc.status_ ) then parts.fact-qnty else parts.qnty ) @ parts.fact-qnty
            sym6 goods.unit-base
            sym7 parts.last-date
            sym8 parts-PS1 @ parts.PS
            sym9 list-b-code
            sym10
          with FRAME parts-print .
          DOWN STREAM Out_Stream 1 with FRAME parts-print .
        end.
        run fill-line( 0 /*Lines_Counter*/, "" /*tb-code*/, "" /*goods.artic*/, ( if parts.part-code = "" then "  ----  " else parts.part-code ) /*goods.gds-name*/,
                       ( if can-do( {&fact} , trn-doc.status_ ) then parts.fact-qnty else parts.qnty ),
                       goods.unit-base, parts.last-date, parts-PS,
                       ( if PrintRubl = yes then parts.price-rubl else parts.price-base ), part-b-code, print_zak ).

        assign parts-PS = trim( parts-PS2 ) .
        DO WHILE parts-PS <> "" or new-list <> "" and last( parts.part-code ) :
          parts-PS1 = breakstr(parts-PS, (if print_zak = yes then 32 else {&PS-form} ), input-output parts-PS1, input-output parts-PS2).

          assign list-b-code = new-list .
          run sub-b-code-lst in this-procedure  (input-output list-b-code, output new-list) .

          if print_zak = yes then do:
            DISPLAY STREAM Out_Stream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 parts-PS1 @ parts.PS sym9 sym10 list-b-code sym11 with FRAME parts-print1 .
            DOWN STREAM Out_Stream 1 with FRAME parts-print1 .
          end.
          else do:
            DISPLAY STREAM Out_Stream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 parts-PS1 @ parts.PS sym9 list-b-code sym10 with FRAME parts-print .
            DOWN STREAM Out_Stream 1 with FRAME parts-print .
          end.

          assign parts-PS = trim( parts-PS2 ) .
        END .

    END.
END.

PUT STREAM Out_Stream Line format "X(197)" AT 1 SKIP .

HIDE STREAM Out_Stream FRAME BottomFrame .

output STREAM Out_Stream CLOSE.
run specifxl-close in this-procedure .

if session:set-wait-state("") then.


def var Log-Res as log no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_waybills-to-file_print':U
  {&cntxt-firm}
  trn-doc.host-code
  '':U
  0
  0
  0
  0
  false
  Log-Res
}

if Log-Res then DO:
    { rep/q-print.i 0}  End.
else  DO:
    { rep/q-print.i 4}  End.

procedure b-code-lst :
  do
  on error undo, return error return-value
  :
      assign
        is-new = yes
        list-b-code = ""
      .
      for each prod-bc no-lock where prod-bc.b-code = b-code :
        if is-new then do:
          assign is-new = no .
          if prod-bc.bc-on then assign list-b-code = "* " + prod-bc.b-str .
          else assign list-b-code = prod-bc.b-str .
        end.
        else do:
          if prod-bc.bc-on then assign list-b-code = list-b-code + ", " +  "* " + prod-bc.b-str .
          else assign list-b-code = list-b-code + ", " + prod-bc.b-str .
        end.
        if length(list-b-code) > 30000 then do:
          message vss-workfile vss-revision vss-description skip "Слишком много бар-кодов производителя! Список будет выводиться неполностью." skip  "Код товара " goods.gds-code " Артикул товара " goods.artic skip
          view-as alert-box error .
          leave.
        end.
      end.
  end.
end procedure. /* b-code-lst */


procedure sub-b-code-lst :
  do
  on error undo, return error return-value
  :
    define input-output  parameter str1 as character no-undo .
    define output parameter        str2 as character no-undo .

    assign  str2 = "" .

    if length(str1) > 27 then do:
      define variable nn as integer initial 0  no-undo .
      define variable ii as integer initial 1  no-undo .

      repeat :
        ii = index(str1,',',ii) .
        if ii > 27 or ii < 1 then leave.
        assign
          nn = ii
          ii = ii + 1
        .
      end.
      str2 = substr ( str1, nn + 1) .
      str1 = substr ( str1, 1, nn - 1) .
    end.

  end.
end procedure. /* sub-b-code-lst */

Procedure fill-line :
  define input parameter p-Counter     as integer               no-undo.
  define input parameter p-cTb-code    as character format "X({&BarCode_Length})" no-undo.
  define input parameter p-artic       like goods.artic         no-undo.
  define input parameter p-gds-name    like ub.goods.gds-name   no-undo.
  define input parameter p-qnty        as decimal               no-undo.
  define input parameter p-unit-base   like ub.goods.unit-base  no-undo.
  define input parameter p-last-date   like ub.parts.last-date  no-undo.
  define input parameter p-PS          like ub.parts.PS         no-undo.
  define input parameter p-price-rubl  like ub.parts.price-rubl no-undo.
  define input parameter p-list-b-code as character             no-undo.
  define input parameter p-print_zak   as logical               no-undo.

  run specifxl-write-line-data in this-procedure (
            input p-Counter
          , input p-cTb-code
          , input p-artic
          , input p-gds-name
          , input p-qnty /*string( qnty )*/
          , input p-unit-base
          , input p-last-date
          , input p-PS
          , input p-price-rubl
          , input p-list-b-code
          , input p-print_zak
  ).

end.  /*   Procedure fill-tt   */