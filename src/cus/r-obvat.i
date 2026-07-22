/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет цены клиента в нетто цену клиента!!!!!!

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*

{1} - def иди calc

line - буфер где содержится price-cli vat-pc slt-pc - в нашем случае parts - {2}

pf - префикс переменной для для части {3}

doc - буфер документа в нашем случае приход!!! {4}

*/


&if "{1}" <> "" and "{1}" <> "def" and "{1}" <> "calc" &then
  &message r-obvat.i: Неправильное значение первого аргумента: {1} .
&endif
&IF "{2}" = ""
&THEN
&SCOP line ub.doc-line.
&ELSE
&SCOP line {2}
&ENDIF

&SCOP pf {3}

&IF "{4}" = ""
&THEN
&SCOP doc t-doc.
&ELSE
&SCOP doc {4}
&ENDIF


&if "{1}" = "def" &then
   define variable {&pf}price-without-abs        like ub.doc-line.price-base no-undo.
   define variable {&pf}price-slt                like ub.doc-line.price-base no-undo.
   define variable {&pf}price-vat                like ub.doc-line.price-base no-undo.
   define variable {&pf}price-no-vat-slt         like ub.doc-line.price-base no-undo.
   define variable {&pf}price-cli-netto          like ub.doc-line.price-base no-undo.
&endif

&if "{1}" = "calc" &then

if {&doc}VAT-type = {&no-vat} then do:
  if {&doc}SLT-type = {&no-slt}      or
     {&doc}SLT-Type = {&without-slt} then do:
    assign
      {&pf}price-VAT        = {&line}price-cli                             * {&line}vat-pc / 100
      {&pf}price-slt        = {&line}price-cli * (1 + {&line}vat-pc / 100) * {&line}slt-pc / 100
      {&pf}price-no-vat-slt = {&line}price-cli.
  end.
  /*inc-slt
   Вырожденный случай когда указали цену без НДС, но с налогом с продаж*/
  else do:
    assign
      {&pf}price-VAT        = {&line}price-cli / ((100 / {&line}vat-pc) * (1 + {&line}slt-pc / 100) + {&line}slt-pc / 100)
      {&pf}price-slt        = {&line}price-cli * ( 1 - 1 / (1 + {&line}slt-pc / 100 + {&line}slt-pc / 100 * {&line}vat-pc / 100 ))
      {&pf}price-no-vat-slt = {&line}price-cli - {&pf}price-slt.
  end.
end.
/*inc-vat*/
else do:
  if {&doc}SLT-type = {&no-slt}      or
     {&doc}SLT-Type = {&without-slt} then do:
    assign
      {&pf}price-VAT        = {&line}price-cli                                               * {&line}vat-pc / (100 + {&line}vat-pc)
      {&pf}price-slt        = {&line}price-cli                                               * {&line}slt-pc / 100
      {&pf}price-no-vat-slt = {&line}price-cli - {&pf}price-VAT.
  end.
  /*inc-slt*/
  else do:
    assign
      {&pf}price-VAT        = {&line}price-cli * (100 / ( 100 + {&line}slt-pc))              * {&line}vat-pc / (100 + {&line}vat-pc)
      {&pf}price-slt        = {&line}price-cli                                               * {&line}slt-pc / (100 + {&line}slt-pc)
      {&pf}price-no-vat-slt = {&line}price-cli - {&pf}price-VAT - {&pf}price-SLT.
  end.
end.
assign {&pf}price-without-abs = {&pf}price-no-vat-slt + {&pf}price-VAT + {&pf}price-slt.

    assign
    {&pf}price-cli-netto = {&pf}price-without-abs  / {&line}cli-base-rate.


&endif


/* $Workfile$ e n d */