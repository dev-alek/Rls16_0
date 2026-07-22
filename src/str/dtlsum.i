/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение сумм детализации документа МЦ по партиям

Автор: Гридчина Полина Дмитриевна
Дата создания: 07/17/07
Author: Polina Gridchina
Creation date: 07/17/07

{1} - buffer tt-dtl
{2} - buffer wth-parts
{3} - wth-doc-code
{4} - w-p-code
*/



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
{1}.q-ty-doc  = 0
{1}.q-ty-fact = 0
{1}.doc-sum   = 0
{1}.fact-sum  = 0
{1}.sum-gds-rubl = 0
{1}.sum-gds-base = 0
.

for each {2} no-lock where {2}.w-p-code = {1}.w-p-code
                       and {2}.wth-code = {1}.wth-code
                       and {2}.par-code = {1}.par-code
                       and {2}.out-code = {1}.doc-code
                       and {2}.stts = 0 :
   assign
  {1}.q-ty-doc     =  {1}.q-ty-doc  + {2}.qnty-doc
  {1}.q-ty-fact    =  {1}.q-ty-fact + {2}.fact-qnty
  {1}.sum-gds-rubl =  {1}.sum-gds-rubl + {2}.price-rubl * {2}.fact-qnty
  {1}.sum-gds-base =  {1}.sum-gds-base + {2}.price-base * {2}.fact-qnty
  no-error
  .
end.

assign
  {1}.doc-sum     =  {1}.q-ty-doc  * {1}.par-rate
  {1}.fact-sum    =  {1}.q-ty-fact * {1}.par-rate
  no-error
  .