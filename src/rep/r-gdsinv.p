block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gdsinv.p $
$Archive: rep/r-gdsinv.p $

Отчет Вхождение товара в инвентаризации

Автор: Морозов Александр Сергеевич
Дата создания: 04/22/11
Author: Alexandr Morozov
Creation date: 04/22/11

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gdsinv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gdsinv.p $":U .
define variable vss-description as character no-undo init "Отчет Вхождение товара в инвентаризации".

define input parameter parparentproc  as   widget-handle  no-undo .
define input parameter v-sort    as integer no-undo.
define input parameter v-det-obj as logical no-undo.
define input parameter v-gds-grp as logical no-undo.

define variable   Counter1            as   integer        no-undo.
define temp-table tt-line no-undo
  field artic     like ub.doc-line.artic
  field prod-type like ub.doc-line.prod-type /*тип произ. орг. физ. лицо и тп. для опр. наим. товара*/
  field prod-code like ub.doc-line.prod-code /*код. произ. для опр. наим. товара*/
  field unit-base like ub.goods.unit-base /*ед. изм.*/
  field fact-date like ub.trn-doc.fact-date
  field doc-code  like ub.trn-doc.doc-code
  field agnt      like ub.clients.obj-name
  field fact-qnty like ub.doc-line.fact-qnty
  field gds-name  like ub.goods.gds-name
  field grp-name  like ub.goods.grp-name
  field grp-code  like ub.goods.grp-code
  field obj-code  like ub.trn-doc.obj-code
  field obj-type  like ub.trn-doc.obj-type
  field obj-name  like ub.clients.obj-name
    index pi is primary unique doc-code artic prod-type prod-code
    index grp-artic grp-code artic
    index grp-name grp-name artic prod-type prod-code
    index obj obj-type obj-code
.

define buffer buf-doc  for ub.trn-doc.
define buffer buf-line for ub.doc-line.
define buffer buf-gds  for ub.goods.
define buffer buf-unit for ub.units.
define buffer buf-clients for ub.clients.
&scop sortname  1
&scop sortartic 2
&scop frame-name gdsinvent
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  } /* все что нужно для excel  и тп.*/
{ cmp/r-pril.i   }
{ gbl/prn-lib.i "new shared" }
{ rep/r-sym.i    }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */


    /*{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }*/

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
        sym1              column-label ":!:"                format "X(1)"         space(0)
        tt-line.artic     column-label "Код":C8             format "X(8)"         space(0)
        sym2              column-label ":!:"                format "X(1)"         space(0)
        tt-line.gds-name  column-label "Наименование!":C86  format "x(86)"        space(0)
        sym3              column-label ":!:"                format "X(1)"         space(0)
        tt-line.unit-base column-label "Ед.!изм.":C4        format "X(4)"         space(0)
        sym4              column-label ":!:"                format "X(1)"         space(1)
        tt-line.fact-dat  column-label "Дата"               format "99/99/9999"   space(1)
        sym5              column-label ":!:"                format "X(1)"         space(0)
        tt-line.doc-code  column-label "№!документа":C11    format "X(11)"        space(0)
        sym6              column-label ":!:"                format "X(1)"         space(0)
        tt-line.agnt      column-label "Исполнитель!":C57   format "X(57)"        space(0)
        sym7              column-label ":!:"                format "X(1)"         space(0)
        tt-line.fact-qnty column-label "Кол-во!"            format "->>>,>>9.<<<" space(0)
        sym8              column-label ":!:" format "X(1)" space(0)
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
with width {&DOS_CW_2} down stream-io .


do:

  run prn-lib-open-stream  in this-procedure
    ( input parParentProc
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
    ).
  if v-sort = {&sortname} then ReportHeader = "Сортировка по имени".
    else ReportHeader = "Сортировка по артиклу".
  if v-gds-grp then ReportHeader = ReportHeader + chr(10) + "Группировка по группе товаров".
  if v-det-obj then ReportHeader = ReportHeader + chr(10) + "Детализировать по объектам".
  run print-header.
  assign  Counter1 = 0 .
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  case x-SelectGood :
    when 1 then
      for each obj-list no-lock ,
          each buf-doc where buf-doc.obj-code = obj-list.obj-code
              and buf-doc.obj-type = obj-list.obj-type  and buf-doc.doc-type = {&inventory} and buf-doc.ext-doc-type = {&TDEDT_Inv} and buf-doc.status_ = {&fact}
              and buf-doc.fact-date >= x-Date-Start and buf-doc.fact-date <= x-Date-End no-lock ,
          each buf-line of buf-doc no-lock :
          for first buf-gds field (gds-name grp-name grp-code unit-base) where
                      buf-gds.artic     = buf-line.artic     and
                      buf-gds.prod-type = buf-line.prod-type and
                      buf-gds.prod-code = buf-line.prod-code no-lock :
            find first buf-clients where buf-clients.obj-code =  buf-doc.agnt and buf-clients.obj-type = {&prs} no-error.
            create tt-line.
            assign
              tt-line.artic     = buf-line.artic
              tt-line.prod-type = buf-line.prod-type
              tt-line.prod-code = buf-line.prod-code
              tt-line.unit-base = buf-gds.unit-base
              tt-line.fact-date = buf-doc.fact-date
              tt-line.doc-code  = buf-doc.doc-code
              tt-line.agnt      = if available buf-clients then buf-clients.obj-name else ""
              tt-line.fact-qnty = buf-line.fact-qnty
              tt-line.gds-name  = buf-gds.gds-name
              tt-line.grp-name  = buf-gds.grp-name
              tt-line.grp-code  = buf-gds.grp-code
              tt-line.obj-code  = buf-doc.obj-code
              tt-line.obj-type  = buf-doc.obj-type
              tt-line.obj-name  = obj-list.obj-name
            .
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
          end.
      end.
    when 2 then
      for each tmp#grp no-lock ,
          each obj-list no-lock ,
          each buf-doc where buf-doc.obj-code = obj-list.obj-code
              and buf-doc.obj-type = obj-list.obj-type  and buf-doc.doc-type = {&inventory} and buf-doc.ext-doc-type = {&TDEDT_Inv} and buf-doc.status_ = {&fact}
              and buf-doc.fact-date >= x-Date-Start and buf-doc.fact-date <= x-Date-End no-lock ,
          each buf-line of buf-doc no-lock :
          for first buf-gds field (gds-name grp-name grp-code unit-base) where
                      buf-gds.artic     = buf-line.artic     and
                      buf-gds.prod-type = buf-line.prod-type and
                      buf-gds.prod-code = buf-line.prod-code and
                      buf-gds.grp-code  = tmp#grp.node-code no-lock :
            find first buf-clients where buf-clients.obj-code =  buf-doc.agnt and buf-clients.obj-type = {&prs} no-error.
            create tt-line.
            assign
              tt-line.artic     = buf-line.artic
              tt-line.prod-type = buf-line.prod-type
              tt-line.prod-code = buf-line.prod-code
              tt-line.unit-base = buf-gds.unit-base
              tt-line.fact-date = buf-doc.fact-date
              tt-line.doc-code  = buf-doc.doc-code
              tt-line.agnt      = if available buf-clients then buf-clients.obj-name else ""
              tt-line.fact-qnty = buf-line.fact-qnty
              tt-line.gds-name  = buf-gds.gds-name
              tt-line.grp-name  = buf-gds.grp-name
              tt-line.grp-code  = buf-gds.grp-code
              tt-line.obj-code  = buf-doc.obj-code
              tt-line.obj-type  = buf-doc.obj-type
              tt-line.obj-name  = obj-list.obj-name
            .
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
          end.
      end.
    when 4 then
      for each obj-list no-lock ,
          each buf-doc where buf-doc.obj-code = obj-list.obj-code
              and buf-doc.obj-type = obj-list.obj-type  and buf-doc.doc-type = {&inventory} and buf-doc.ext-doc-type = {&TDEDT_Inv} and buf-doc.status_ = {&fact}
              and buf-doc.fact-date >= x-Date-Start and buf-doc.fact-date <= x-Date-End no-lock ,
          each buf-line of buf-doc no-lock :
          for first gds-list field (gds-name grp-name grp-code unit-base) where
                      gds-list.artic     = buf-line.artic     and
                      gds-list.prod-type = buf-line.prod-type and
                      gds-list.prod-code = buf-line.prod-code  no-lock :
            find first buf-clients where buf-clients.obj-code =  buf-doc.agnt and buf-clients.obj-type = {&prs} no-error.
            create tt-line.
            assign
              tt-line.artic     = buf-line.artic
              tt-line.prod-type = buf-line.prod-type
              tt-line.prod-code = buf-line.prod-code
              tt-line.unit-base = gds-list.unit-base
              tt-line.fact-date = buf-doc.fact-date
              tt-line.doc-code  = buf-doc.doc-code
              tt-line.agnt      = if available buf-clients then buf-clients.obj-name else ""
              tt-line.fact-qnty = buf-line.fact-qnty
              tt-line.gds-name  = gds-list.gds-name
              tt-line.grp-name  = gds-list.grp-name
              tt-line.grp-code  = gds-list.grp-code
              tt-line.obj-code  = buf-doc.obj-code
              tt-line.obj-type  = buf-doc.obj-type
              tt-line.obj-name  = obj-list.obj-name
            .
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
          end.
      end.
  end case.

  { rep/repfrm.i off }

  if not v-det-obj and not v-gds-grp then do :
    if v-sort = {&sortname} then
      for each tt-line by tt-line.gds-name :
        run  print-line (input recid(tt-line)).
      end.
    else
      for each tt-line by tt-line.artic :
        run  print-line (input recid(tt-line)).
      end.
  end.

  if v-det-obj and not v-gds-grp then do :
    if v-sort = {&sortname} then
      for each tt-line break by tt-line.obj-code by tt-line.gds-name :
        if first-of (tt-line.obj-code) then do:
          {&PutExcel}
              "Объект - " + tt-line.obj-name
          skip.
          run print-obj (tt-line.obj-name).
        end.
        run  print-line (input recid(tt-line)).
      end.
    else
      for each tt-line break by tt-line.obj-code by tt-line.artic :
        if first-of (tt-line.obj-code) then do:
          {&PutExcel}
              "Объект - " + tt-line.obj-name
          skip.
          run print-obj (tt-line.obj-name).
        end.
        run  print-line (input recid(tt-line)).
      end.
  end.

  if not v-det-obj and v-gds-grp then do :
    if v-sort = {&sortname} then
      for each tt-line break by tt-line.grp-code by tt-line.gds-name :
        if first-of (tt-line.grp-code) then do:
          {&PutExcel}
              {&tabulation} "Группа - " + tt-line.grp-name
          skip.
          run print-grp (tt-line.grp-name).
        end.
        run  print-line (input recid(tt-line)).
      end.
    else
      for each tt-line break by tt-line.grp-code by tt-line.artic :
        if first-of (tt-line.grp-code) then do:
          {&PutExcel}
              {&tabulation} "Группа - " + tt-line.grp-name
          skip.
          run print-grp (tt-line.grp-name).
        end.
        run  print-line (input recid(tt-line)).
      end.
  end.

  if v-det-obj and v-gds-grp then do :
      if v-sort = {&sortname} then
        for each tt-line break by tt-line.obj-code by tt-line.grp-code by tt-line.gds-name :
          if first-of (tt-line.obj-code) then do:
            {&PutExcel}
                "Объект - " + tt-line.obj-name
            skip.
            run print-obj (tt-line.obj-name).
          end.
          if first-of (tt-line.grp-code) then do:
            {&PutExcel}
                {&tabulation} "Группа - " + tt-line.grp-name
            skip.
            run print-grp (tt-line.grp-name).
          end.
          run  print-line (input recid(tt-line)).
        end.
      else
        for each tt-line break by tt-line.obj-code by tt-line.grp-code by tt-line.artic :
          if first-of (tt-line.obj-code) then do:
            {&PutExcel}
                "Объект - " + tt-line.obj-name
            skip.
            run print-obj (tt-line.obj-name).
          end.
          if first-of (tt-line.grp-code) then do:
            {&PutExcel}
                {&tabulation} "Группа - " + tt-line.grp-name
            skip.
            run print-grp (tt-line.grp-name).
          end.
          run  print-line (input recid(tt-line)).
        end.
  end.

  {&CloseExcel}
  output stream PrnLibStream close.
  { gbl/stopwork.i }
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
end.

/* **********************  Internal Procedures  *********************** */

procedure print-line :
  DEFINE  INPUT PARAMETER p-line-rec_id   AS RECID     NO-UNDO.
for tt-line field ( artic
                    gds-name
                    unit-base
                    fact-date
                    doc-code
                    agnt
                    fact-qnty ) where recid (tt-line) = p-line-rec_id no-lock :

    {&PutExcel}
              tt-line.artic     {&tabulation}
              tt-line.gds-name  {&tabulation}
              tt-line.unit-base {&tabulation}
              tt-line.fact-date {&tabulation}
              tt-line.doc-code  {&tabulation}
              tt-line.agnt      {&tabulation}
              tt-line.fact-qnty {&tabulation}
    skip.
    display stream PrnLibStream sym1  tt-line.artic
                                sym2  tt-line.gds-name
                                sym3  tt-line.unit-base
                                sym4  tt-line.fact-date
                                sym5  tt-line.doc-code
                                sym6  tt-line.agnt
                                sym7  tt-line.fact-qnty
                                sym8  skip
    with frame {&FRAME-NAME} .
    down stream PrnLibStream with frame {&FRAME-NAME} .
end.
end. /*procedure print-line*/

procedure print-obj.
  define input parameter p-grp as character.
  form with frame {&FRAME-NAME}.
  display stream PrnLibStream sym1 "Объект -" @ tt-line.artic p-grp @ tt-line.gds-name sym8 with frame {&FRAME-NAME}.
  down stream PrnLibStream with frame {&FRAME-NAME} .
  underline stream PrnLibStream tt-line.artic tt-line.gds-name with frame {&FRAME-NAME} .
end.
procedure print-grp.
  define input parameter p-grp as character.
  form with frame {&FRAME-NAME}.
  display stream PrnLibStream sym1 "Группа - " + p-grp @ tt-line.gds-name sym8 with frame {&FRAME-NAME}.
  down stream PrnLibStream with frame {&FRAME-NAME} .
  put stream PrnLibStream unformatted "          -------------------------------------------------------------------------------------- " .
end.

procedure print-header :
find first sheetf where sheet-num = 1 /*no-error*/.

    assign
    Sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "Код" + {&comma-char} +
                         "Наименование" + {&comma-char} +
                         "Ед. Изм." + {&comma-char} +
                         "Дата" + {&comma-char} +
                         "№ документа" + {&comma-char} +
                         "Исполнитель" + {&comma-char} +
                         "Кол-во"
    Sheetf.Sizes = "10,80,5,10,12,35,7"
    Sheetf.colformat = "1=@;2=@;3=@;4=dd/mm/yy;5=@;6=@;7=0,00;"
    .
  RUN rep/extitle.p (1).

  put stream PrnLibStream unformatted
  reportNAme  + {&new-line}
              + str1 + {&new-line}
              + str2 + {&new-line}
              + str3 + {&new-line}
              + str4 + {&new-line}
              + ReportHeader.

end. /*procedure print-header*/