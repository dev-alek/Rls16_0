/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд проверки сходимости сумм в wth-doc

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
DEFINE VARIABLE vardoc-sum-dtl like ub.wth-dtl.doc-sum no-undo .
DEFINE VARIABLE varfact-sum-dtl like ub.wth-dtl.fact-sum no-undo .
DEFINE VARIABLE varbef-sum-dtl like ub.wth-dtl.bef-sum no-undo .
DEFINE VARIABLE varaft-sum-dtl like ub.wth-dtl.aft-sum no-undo .
DEFINE VARIABLE vardoc-sum-line like ub.wth-line.doc-sum no-undo .
DEFINE VARIABLE varfact-sum-line like ub.wth-line.fact-sum no-undo .
DEFINE VARIABLE varbef-sum-line like ub.wth-line.bef-sum no-undo .
DEFINE VARIABLE varaft-sum-line like ub.wth-line.aft-sum no-undo .

DEFINE VARIABLE varsum-gds-rubl-line  like ub.wth-line.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-line  like ub.wth-line.sum-gds-base no-undo .
DEFINE VARIABLE varsum-gds-rubl-dtl   like ub.wth-dtl.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-dtl   like ub.wth-dtl.sum-gds-base no-undo .
DEFINE VARIABLE varsum-gds-rubl-parts like ub.wth-dtl.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-parts like ub.wth-dtl.sum-gds-base no-undo .


DEFINE VARIABLE varis-dtl as logical no-undo .
DEFINE VARIABLE varis-part as logical no-undo .

DEFINE VARIABLE varinst-sum like ub.chk-pay.tot-sum no-undo .
DEFINE VARIABLE varchk-type like ub.chk-doc.chk-type no-undo .
define buffer check_chk-pay for ub.chk-pay .
define buffer check_chk-doc for ub.chk-doc .
define buffer bufdsum_wealth   for ub.wealth.
&ENdif

&if "{1}" = "check" &then
/*
2 - pardoc-code
3 - ub.wth-doc
4 - ub.wth-line
5 - ub.wth-dtl
6 - undo frase ending with ,
*/

assign
vardoc-sum-dtl = 0
varfact-sum-dtl = 0
varbef-sum-dtl = 0
varaft-sum-dtl = 0
vardoc-sum-line = 0
varfact-sum-line = 0
varbef-sum-line = 0
varaft-sum-line = 0
varinst-sum = 0
varsum-gds-rubl-line = 0
varsum-gds-base-line = 0
varsum-gds-rubl-dtl = 0
varsum-gds-base-dtl = 0
varsum-gds-rubl-parts = 0
varsum-gds-base-parts = 0
.

FOR EACH {4} No-LOCK WHERE
         {4}.doc-code = {2}:
  assign
  vardoc-sum-dtl = 0
  varfact-sum-dtl = 0
  varbef-sum-dtl = 0
  varaft-sum-dtl = 0
  varsum-gds-rubl-dtl = 0
  varsum-gds-base-dtl = 0
  varis-dtl = no
  .

  FOR EACH {5} No-LOCK WHERE
           {5}.doc-code = {4}.doc-code AND
           {5}.wth-code = {4}.wth-code AND
           {5}.w-p-code = {4}.w-p-code:

    assign
    varis-dtl = yes
    vardoc-sum-dtl = vardoc-sum-dtl + {5}.doc-sum
    varfact-sum-dtl = varfact-sum-dtl + {5}.fact-sum
    varbef-sum-dtl = varbef-sum-dtl + {5}.bef-sum
    varaft-sum-dtl = varaft-sum-dtl + {5}.aft-sum
    varsum-gds-rubl-dtl = varsum-gds-rubl-dtl + {5}.sum-gds-rubl
    varsum-gds-base-dtl = varsum-gds-base-dtl + {5}.sum-gds-base
    .
    /*Сумма по партиям*/
    assign varsum-gds-rubl-parts = 0
    varsum-gds-base-parts = 0
    varis-part = no.
    for each {8} no-lock where
      {8}.w-p-code = {5}.w-p-code and
      {8}.wth-code = {5}.wth-code and
      {8}.par-code = {5}.par-code and
      {8}.out-code = {5}.doc-code and
      {8}.stts = 0 :
      assign
      varis-part = yes
      varsum-gds-rubl-parts = varsum-gds-rubl-parts + {8}.fact-qnty * {8}.price-rubl
      varsum-gds-base-parts = varsum-gds-base-parts + {8}.fact-qnty * {8}.price-base
      .
    end.
    if varis-part or can-find(first bufdsum_wealth where bufdsum_wealth.wth-code = {5}.wth-code and bufdsum_wealth.is-ser = 1 no-lock  ) then do:
      if varsum-gds-rubl-parts <> {5}.sum-gds-rubl then do:
        var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                  "Код МЦ" +  {&space-char} +  string({5}.wth-code) + {&new-line} +
                  "Код МХ" + {&space-char} + string({5}.w-p-code) + {&new-line} +
                  "Код номинала" + {&space-char} + string({5}.par-code) + {&new-line} +
                  "Сумма по связанным товарам в {&abbr_rublyah} по партиям не равна сумме по номиналу" + {&new-line} + {&new-line} +
                  "Сумма по связанным товарам в {&abbr_rublyah}   по партиям=" + string(varsum-gds-rubl-parts) + {&space-char} +
                  "Сумма по связанным товарам в {&abbr_rublyah}   по номиналу=" + string({5}.sum-gds-rubl).
        if par-talk then
        message var-mes
        view-as alert-box error .
        {7} return error var-mes.
      end.
      if varsum-gds-base-parts <> {5}.sum-gds-base then do:
        var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                  "Код МЦ" +  {&space-char} +  string({5}.wth-code) + {&new-line} +
                  "Код МХ" + {&space-char} + string({5}.w-p-code) + {&new-line} +
                  "Код номинала" + {&space-char} + string({5}.par-code) + {&new-line} +
                  "Сумма по связанным товарам в базовой валюте по партиям не равна сумме по номиналу" + {&space-char} +  {&new-line} +
                  "Сумма по связанным товарам в базовой валюте по партиям=" + string(varsum-gds-base-parts) + {&space-char} +
                  "Сумма по связанным товарам в базовой валюте по номиналу=" + string({5}.sum-gds-base).
        if par-talk then
        message var-mes
        view-as alert-box error .
        {7} return error var-mes.
      end.

    end.
  END. /*for each {5}*/
  if varis-dtl then do:
    if vardoc-sum-dtl <> {4}.doc-sum then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Код МЦ" +  {&space-char} +  string({4}.wth-code) + {&new-line} +
                "Код МХ" + {&space-char} + string({4}.w-p-code) + {&new-line} +
                "Сумма по номиналам не равна сумме по строке" + {&space-char} +  {&new-line} +
                "Сумма по документу по номиналам=" + string(vardoc-sum-dtl) + {&space-char} +
                "Сумма по документу по строке=" + string({4}.doc-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
      {7} return error var-mes.
    end.
    if {3}.status_ = {&fact} then do:
      if varfact-sum-dtl <> {4}.fact-sum then do:
        var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                  "Код МЦ" +  {&space-char} +  string({4}.wth-code) + {&new-line} +
                  "Код МХ" + {&space-char} + string({4}.w-p-code) + {&new-line} +
                  "Сумма по номиналам не равна сумме по строке" + {&space-char} +  {&new-line} +
                  (if {3}.doc-type = {&inventory}
                  then
                  string(
                  "Сумма расхождений по номиналам=" + string(varfact-sum-dtl) + {&space-char} +
                  "Сумма расхождений по строке=" + string({4}.fact-sum)
                  )
                  else
                  string(
                  "Сумма факт по номиналам=" + string(varfact-sum-dtl) + {&space-char} +
                  "Сумма факт по строке=" + string({4}.fact-sum))
                  ).
        if par-talk then
        message var-mes
        view-as alert-box error .
        {7} return error var-mes.
      end.
    end.
    if varbef-sum-dtl <> {4}.bef-sum then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Код МЦ" +  {&space-char} +  string({4}.wth-code) + {&new-line} +
                "Код МХ" + {&space-char} + string({4}.w-p-code) + {&new-line} +
                "Сумма по номиналам не равна сумме по строке" + {&space-char} +  {&new-line} +
                "Сумма план по номиналам=" + string(varbef-sum-dtl) + {&space-char} +
                "Сумма план по строке=" + string({4}.bef-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
      {7} return error var-mes.
    end.
    if {3}.doc-type = {&inventory} then do:
      if {3}.status_ = {&fact} then do:
        if varaft-sum-dtl <> {4}.aft-sum then do:
          var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                    "Код МЦ" +  {&space-char} +  string({4}.wth-code) + {&new-line} +
                    "Код МХ" + {&space-char} + string({4}.w-p-code) + {&new-line} +
                    "Сумма по номиналам не равна сумме по строке" + {&space-char} +  {&new-line} +
                    "Сумма факт по номиналам=" + string(varaft-sum-dtl) + {&space-char} +
                    "Сумма факт по строке=" + string({4}.aft-sum).
          if par-talk then
          message var-mes
          view-as alert-box error .
          {7} return error var-mes.
        end.
      end.
    end.
    if varsum-gds-rubl-dtl <> {4}.sum-gds-rubl then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Код МЦ" +  {&space-char} +  string({4}.wth-code) + {&new-line} +
                "Код МХ" + {&space-char} + string({4}.w-p-code) + {&new-line} +
                "Сумма по связанным товарам в {&abbr_rublyah}  по номиналам не равна сумме по строке" + {&space-char} + {&new-line} +
                "Сумма по связанным товарам в {&abbr_rublyah}  по номиналам=" + string(varsum-gds-rubl-dtl) + {&space-char} +
                "Сумма по связанным товарам в {&abbr_rublyah}  по строке=" + string({4}.sum-gds-rubl).
      if par-talk then
      message var-mes
      view-as alert-box error .
      {7} return error var-mes.
    end.
    if varsum-gds-base-dtl <> {4}.sum-gds-base then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Код МЦ" +  {&space-char} +  string({4}.wth-code) + {&new-line} +
                "Код МХ" + {&space-char} + string({4}.w-p-code) + {&new-line} +
                "Сумма по связанным товарам в базовой валюте по номиналам не равна сумме по строке" + {&space-char} +  {&new-line} +
                "Сумма по связанным товарам в базовой валюте по номиналам=" + string(varsum-gds-base-dtl) + {&space-char} +
                "Сумма по связанным товарам в базовой валюте по строке=" + string({4}.sum-gds-base).
      if par-talk then
      message var-mes
      view-as alert-box error .
      {7} return error var-mes.
    end.


  end . /*if varis-dtl*/
  assign
  vardoc-sum-line = vardoc-sum-line + {4}.doc-sum
  varfact-sum-line = varfact-sum-line + {4}.fact-sum
  varbef-sum-line = varbef-sum-line + {4}.bef-sum
  varaft-sum-line = varaft-sum-line + {4}.aft-sum
  varsum-gds-rubl-line = varsum-gds-rubl-line + {4}.sum-gds-rubl
  varsum-gds-base-line = varsum-gds-base-line + {4}.sum-gds-base

  .
END. /*for each {4}*/

if vardoc-sum-line <> {3}.doc-sum then do:
  var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
            "Сумма по строкам не равна сумме по шапке" + {&space-char} + {&new-line} +
            "Сумма по документу по строкам=" + string(vardoc-sum-line) + {&space-char} +
            "Сумма по документу по шапке=" + string({3}.doc-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
  {7} return error var-mes.
end.
if {3}.status_ = {&fact} then do:
  if varfact-sum-line <> {3}.fact-sum then do:
    var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
              "Сумма по строкам не равна сумме по шапке" + {&space-char} + {&new-line} +
              (if {3}.doc-type = {&inventory}
              then
                string(
                "Сумма расхождений по строкам=" + string(varfact-sum-line) + {&space-char} +
                "Сумма расхождений по шапке=" + string({3}.fact-sum)
                )
              else
              string(
              "Сумма факт по строкам=" + string(varfact-sum-line) + {&space-char} +
              "Сумма факт по шапке=" + string({3}.fact-sum))
              ).
    if par-talk then
    message var-mes
    view-as alert-box error .
    {7} return error var-mes.
  end.
end.
if varbef-sum-line <> {3}.bef-sum then do:
  var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
            "Сумма по строкам не равна сумме по шапке" + {&space-char} + {&new-line} +
            "Сумма план по строкам=" + string(varbef-sum-line) + {&space-char} +
            "Сумма план по шапке=" + string({3}.bef-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
  {7} return error var-mes.
end.
if {3}.doc-type = {&inventory} then do:
  if varaft-sum-line <> {3}.aft-sum then do:
    var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
              "Сумма по строкам не равна сумме по шапке" + {&space-char} + {&new-line} +
              "Сумма факт по строкам=" + string(varaft-sum-line) + {&space-char} +
              "Сумма факт по шапке=" + string({3}.aft-sum).
    if par-talk then
    message var-mes
    view-as alert-box error .
    {7} return error var-mes.
  end.
end.
if varsum-gds-rubl-line <> {3}.sum-gds-rubl then do:
  var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
            "Сумма по связанным товарам в {&abbr_rublyah}  по строкам не равна сумме по шапке" + {&space-char} + {&new-line} +
            "Сумма по связанным товарам в {&abbr_rublyah}  по строкам=" + string(varsum-gds-rubl-line) + {&space-char} +
            "Сумма по связанным товарам в {&abbr_rublyah}  по шапке=" + string({3}.sum-gds-rubl).
  if par-talk then
  message var-mes   varsum-gds-rubl-line  {3}.sum-gds-rubl
  view-as alert-box error .
  {7} return error var-mes.
end.
if varsum-gds-base-line <> {3}.sum-gds-base then do:
  var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
            "Сумма по связанным товарам в базовой валюте по строкам не равна сумме по шапке" + {&space-char} +   {&new-line} +
            "Сумма по связанным товарам в базовой валюте по строкам=" + string(varsum-gds-base-line) + {&space-char} +
            "Сумма по связанным товарам в базовой валюте по шапке=" + string({3}.sum-gds-base).
  if par-talk then
  message var-mes
  view-as alert-box error .
  {7} return error var-mes.
end.

if {3}.auto-fill and {6} then do:
  for each check_chk-doc WHERE
           check_chk-doc.out-code = {3}.doc-code AND
           check_chk-doc.obj-type = {3}.obj-type AND
           check_chk-doc.obj-code = {3}.obj-code,
      EACH check_chk-pay No-LOCK WHERE
           check_chk-pay.doc-code = check_chk-doc.doc-code:
    varinst-sum = varinst-sum + check_chk-pay.tot-sum.
    varchk-type = check_chk-doc.chk-type.
  end.
  if {3}.doc-type = {&expense} then do:
    assign
    varinst-sum = - varinst-sum
    .
  end.
  if {3}.doc-type = {&inventory} then do:
    if string(varchk-type) = {&pay-transfer} then dO:
      /*
      if varinst-sum <> {3}.fact-sum then do:
        var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                  "Сумма по строкам чеков МЦ не равна сумме расхождений по шапке" + {&space-char} + {&new-line} +
                  "Сумма по чекам МЦ=" + string(varinst-sum) + {&space-char} +
                  "Сумма расхождений по шапке=" + string({3}.fact-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
        {7} return error var-mes.
      end.
      */
    end.
    else do:
      if varinst-sum <> {3}.aft-sum then do:
        var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                  "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + {&space-char} + {&new-line} +
                  "Сумма по строкам чеков МЦ=" + string(varinst-sum) + {&space-char} +
                  "Сумма факт по шапке=" + string({3}.aft-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
        {7} return error var-mes.
      end.
    end.
  end.
  else do:
    if varinst-sum <> {3}.doc-sum then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Сумма по строкам чеков МЦ не равна сумме документа по шапке" + {&space-char} + {&new-line} +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + {&space-char} +
                "Сумма документа по шапке=" + string({3}.doc-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
        {7} return error var-mes.
    end.
    if varinst-sum <> {3}.fact-sum
    and {3}.doc-type <> {&declaration}
    then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + {&space-char} + {&new-line} +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + {&space-char} +
                "Сумма факт по шапке=" + string({3}.fact-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
      {7} return error var-mes.
    end.
    if {3}.doc-type = {&declaration}
    and {3}.fact-sum <> 0 then do:
      var-mes = "Документ МЦ" + {&space-char} + {2} + {&new-line} +
                "Тип" + {&space-char} + {3}.doc-type +
                "Сумма факт по шапке <> 0" .
      if par-talk then
      message var-mes
      view-as alert-box error .
      {7} return error var-mes.

    end.

  end.
end.
&endif

/* $Workfile$ e n d */