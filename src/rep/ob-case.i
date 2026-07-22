/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок оборотки

Автор: Чернова Светлана Александровна
Дата создания: 03/13/06
Author: Svetlana Chernova
Creation date: 03/13/06

*/
&if "{&{1}}"  = "{&TDEDT_Ras_Prvo}" &then
  WHEN {&TDEDT_Spi_Prvo}  OR  WHEN {&TDEDT_Ras_Prvo} THEN DO:
    ASSIGN oborot-{&bef-{1}}[1 + tt#]   = oborot-{&bef-{1}}[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-{&bef-{1}}[2 + tt#]   = oborot-{&bef-{1}}[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-{&bef-{1}}[3 + tt#]   = oborot-{&bef-{1}}[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
        if tt# = 6 Then  assign
          oborot-{&bef-disc}[1]   = oborot-{&bef-disc}[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-{&bef-{1}}[10]   = oborot-{&bef-{1}}[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
&else
&if "{&{1}}"  = "{&TDEDT_Inv}" &then
  WHEN {&TDEDT_Inv}  OR  WHEN {&TDEDT_Corr_Minus_Parts} OR WHEN {&TDEDT_Peresort} THEN DO:
    ASSIGN oborot-{&bef-{1}}[1 + tt#]   = oborot-{&bef-{1}}[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-{&bef-{1}}[2 + tt#]   = oborot-{&bef-{1}}[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-{&bef-{1}}[3 + tt#]   = oborot-{&bef-{1}}[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
        if tt# = 6 Then  assign
          oborot-{&bef-disc}[1]   = oborot-{&bef-disc}[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-{&bef-{1}}[10]   = oborot-{&bef-{1}}[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
&else
  WHEN {&{1}} THEN DO:
    ASSIGN oborot-{&bef-{1}}[1 + tt#]   = oborot-{&bef-{1}}[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-{&bef-{1}}[2 + tt#]   = oborot-{&bef-{1}}[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-{&bef-{1}}[3 + tt#]   = oborot-{&bef-{1}}[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-{&bef-disc}[1]   = oborot-{&bef-disc}[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-{&bef-{1}}[10]   = oborot-{&bef-{1}}[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
&endif
&endif