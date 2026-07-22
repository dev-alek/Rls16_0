/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет сумм линии документов МЦ по линиям детализации

Автор: Гридчина Полина Дмитриевна
Дата создания: 07/18/07
Author: Polina Gridchina
Creation date: 07/18/07

{1} - buffer wth-line
{2} - buffer tt-par-dtl
{3} - wth-doc-code
{4} - w-p-code


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
{1}.doc-sum   = 0
{1}.fact-sum  = 0
{1}.sum-gds-rubl = 0
{1}.sum-gds-base = 0
{1}.price-rubl   = 0
{1}.price-base   = 0.
for each {2} no-lock where {2}.w-p-code = {1}.w-p-code
                       and {2}.wth-code = {1}.wth-code
                       and {2}.doc-code = {1}.doc-code
                       :
  assign
  {1}.doc-sum      =  {1}.doc-sum  + {2}.doc-sum
  {1}.fact-sum     =  {1}.fact-sum + {2}.fact-sum
  {1}.sum-gds-rubl =  {1}.sum-gds-rubl + {2}.sum-gds-rubl
  {1}.sum-gds-base =  {1}.sum-gds-base + {2}.sum-gds-base
  .

end.

assign
  {1}.price-rubl  =  {1}.sum-gds-rubl / {1}.fact-sum
  {1}.price-base  =  {1}.sum-gds-base / {1}.fact-sum
  .