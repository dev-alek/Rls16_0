/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список форм печати, часть 2

Автор: Демин Алексей Сергеевич
Дата создания: 03/20/06
Author: Alexey Demin
Creation date: 03/20/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define variable is-ptrl  as character no-undo .
define variable is-jwlr  as character no-undo .
define variable par-type as character no-undo .

  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define VARIABLE v-izlish        as logical    no-undo .   
  
run gbl/conf-rd.p ("is-ptrl", "", "", 0, "", "", "", no, output is-ptrl, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-ptrl  <> "yes"
then do:
  assign is-ptrl = "no".
end.
run gbl/conf-rd.p ("is-jwlr", "", "", 0, "", "", "", no, output is-jwlr, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-jwlr  <> "yes"
then do:
  assign is-jwlr = "no".
end.
      run adm/shattri.p (
        input "get":U
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&attr-inv-obj}
        ,input  "izlcstpr"
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-izlish
        ,output v-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
 define variable Log-Res      as      logical     no-undo.

   /*Проверка прав */
 { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_mark_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-res
}        
   
/*-ИНВЕНТАРИЗАЦИЯ----------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* 60- 89 */
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись'"                                           "'cost,sale,rubl,base'" "'rep/inv-3p.p'"    "'invent,no,no'"            "'-+-+++-+'"  "''"        "''"          "''"     "v-izlish = yes"  }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись ИНВ-5'"                                     "'cost,sale,rubl,base'" "'rep/inv-5.p'"     "'invent,no,no'"            "'-+-+++-+'"  "''"                  "'HTML'"      "''"                   ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Предварительная инвентаризационная опись'"                           "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,no,no'"            "'-+-+++-+'"  "''"                  "''"          "''"                   "v-izlish = yes" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись'"                                           "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,no,no'"            "'-+-+++-+'"  "''"                  "''"          "''"                   "v-izlish = no" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись сжатая'"                                    "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,no,yes'"           "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись топлива (вес)'"                             "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,no,no'"         "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись топлива (вес) сжатая'"                      "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,no,yes'"        "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость'"                                             "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,no,no'"                "'-+++++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость сжатая'"                                      "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,no,yes'"               "'-+++++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} {&fact_permitted} "'*'" "'*'"  "'Сличительная ведомость ИНВ-19'"                                      "'cost,sale,rubl,base'" "'rep/inv-19.p'"    "' '"                       "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} {&fact_permitted} "'*'" "'*'"  "'Сличительная ведомость ИНВ-19 (с ОКДП)'"                             "'cost,sale,rubl,base'" "'rep/inv-19.p'"    "'OKDP'"                    "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость топлива (вес)'"                               "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,no,no'"             "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость топлива (вес) сжатая'"                        "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,no,yes'"            "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (итоги по группам)'"                        "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,yes,no'"           "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (итоги по группам) сжатая'"                 "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,yes,yes'"          "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись топлива (вес) (итоги по группам)'"          "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,yes,no'"        "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись топлива (вес) (итоги по группам) сжатая'"   "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,yes,yes'"       "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (итоги по группам)'"                          "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,yes,no'"               "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (итоги по группам) сжатая'"                   "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,yes,yes'"              "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость топлива (вес) (итоги по группам)'"            "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,yes,no'"            "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость топлива (вес) (итоги по группам) сжатая'"     "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,yes,yes'"           "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (ювелирные изделия)'"                       "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent-gold,no,no'"       "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (ювелирные изделия) сжатая'"                "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent-gold,no,yes'"      "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость   (ювелирные изделия)'"                       "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl-gold,no,no'"           "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость   (ювелирные изделия) сжатая'"                "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl-gold,no,yes'"          "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (ювелирные изделия) ИНВ-8'"                 "'rubl'"                "'rep/inv-8l.p'"    "''"                        "'-----+--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (ювелирные изделия) ИНВ-8 ед.'"             "'rubl'"                "'rep/inv-8.p'"     "''"                        "'-----+--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Ведомость учета результатов, выявленных инв-ей (ИНВ-26)'"            "'rubl'"                "'rep/inv-26.p'"    "''"                        "'-----+--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (для пересчета)'"                             "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'no,no'"                   "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (для пересчета) сжатая'"                      "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'yes,no'"                  "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (для пересчета - только расхождения)'"        "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'no,yes'"                  "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (для пересчета - только расхождения) сжатая'" "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'yes,yes'"                 "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Пустографка для всех документов'"                                    "'cost,sale,rubl,base'" "'rep/zeroinv.p'"   "string(p-alldocs-handle) + ',no'"                      "'----++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Пустографка для документа'"                                          "'cost,sale,rubl,base'" "'rep/zeroinv.p'"   "string(p-alldocs-handle) + ',yes'"                     "'----++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость результатов инвентаризации СУГ'"                "'cost,sale,rubl,base'" "'rep/r-orsvx-sug.p'"  "''"                   "'---+----'"  "'yukos,ibs,Rosneft-*'"   "'HTML'"          "''"                   "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость результатов инвентаризации нефтепродуктов'"   "'cost,sale,rubl,base'" "'rep/r-orsvxl.p'"  "''"                        "'---+----'"  "'yukos,ibs,Rosneft-*'"   "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Расчет естественной убыли нефтепродуктов. Форма 34-НП'"              "'cost,sale,rubl,base'" "'rep/r-np34.p'"    "''"                        "'-+-+----'"  "'yukos,ibs,Rosneft-*'"   "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись нефти и нефтепродуктов'"                    "'cost,sale,rubl,base'" "'rep/r-orioxl.p'"  "''"                        "'---+----'"  "'yukos,ibs,Rosneft-*'"   "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись СУГ'"                                       "'cost,sale,rubl,base'" "'rep/r-orioxl-sug.p'"  "''"                    "'---+----'"  "'yukos,ibs,Rosneft-*'"       "'HTML'"      "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Печать датаматриксов по излишкам'"                                     "'cost,sale,rubl,base'" "'rep/r-print-marks.p'"  "''"                 "'---+----'"  "''"                 "'HTML'"      "''"                   "log-res = yes" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (РН-регионы) результатов инв. нефтепродуктов'"  "'cost,sale,rubl,base'" "'rep/r-orsvx1.p'"  "''"                      "'---+----'"  "'yukos,ibs,Rosneft-*'"   "''"      "'Rosneft-Moscow'"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (по поставщикам)'"                          "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'invent,no,no,no'"         "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (по поставщикам)'"                          "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'invent,no,no,yes'"        "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (по поставщикам)'"                            "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'sl,no,no,no'"             "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (по поставщикам)'"                            "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'sl,no,no,yes'"            "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (итоги по производителям) сжатая'"          "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,prod,no'"          "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись (итоги по производителям)'"                 "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,prod,yes'"         "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} {&fact} "'*'" "'*'"            "'Инвентаризационная опись нефтепродуктов'"                              "'cost,sale,rubl,base'" "'rep/r-orioxl-pokmi.p'" "''"                 "'---+----'"  "'yukos,ibs,Rosneft-*'"   "'HTML'"      "''"                   "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (итоги по производителям) сжатая'"            "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,prod,no'"              "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Сличительная ведомость (итоги по производителям)'"                   "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,prod,yes'"             "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризация (анализ отклонений)'"                                 "'cost,sale,rubl,base'" "'rep/inv-3slg.p'"  "'no'"                      "'-+-+++--'"  "'SPAR'"    "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризация (анализ отклонений) сжатая'"                          "'cost,sale,rubl,base'" "'rep/inv-3slg.p'"  "'yes'"                     "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Документ инвентаризации'"                                            "'cost,sale,rubl,base'" "'rep/inv-new.p'"   "''"                        "'---+----'"  "'world'"   "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} {&fact} "'*'" "'*'"            "'Акт приема-передачи'"                                                "'cost,sale,rubl,base'" "'rep/inv-akt.p'"   "''"                        "'----++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись'"                                           "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,no,no'"            "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись сжатая'"                                    "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,no,yes'"           "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись топлива (вес)'"                             "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,no,no'"         "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись топлива (вес) сжатая'"                      "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,no,yes'"        "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость'"                                             "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,no,no'"                "'-+++++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость сжатая'"                                      "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,no,yes'"               "'-+++++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость топлива (вес)'"                               "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,no,no'"             "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость топлива (вес) сжатая'"                        "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,no,yes'"            "'-+-+++--'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (итоги по группам)'"                        "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,yes,no'"           "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (итоги по группам) сжатая'"                 "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,yes,yes'"          "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись топлива (вес) (итоги по группам)'"          "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,yes,no'"        "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись топлива (вес) (итоги по группам) сжатая'"   "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'invent,no,yes,yes'"       "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (итоги по группам)'"                          "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,yes,no'"               "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (итоги по группам) сжатая'"                   "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,yes,yes'"              "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость топлива (вес) (итоги по группам)'"            "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,yes,no'"            "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость топлива (вес) (итоги по группам) сжатая'"     "'cost,sale,rubl,base'" "'rep/inv-3-kg.p'"  "'sl,no,yes,yes'"           "'-+-+----'"  "''"        "''"          "''"     "is-ptrl = 'yes'" }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (ювелирные изделия)'"                       "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent-gold,no,no'"       "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (ювелирные изделия) сжатая'"                "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent-gold,no,yes'"      "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость   (ювелирные изделия)'"                       "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl-gold,no,no'"           "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость   (ювелирные изделия) сжатая'"                "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl-gold,no,yes'"          "'-+-+++-+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Пустографка для всех документов'"                                    "'cost,sale,rubl,base'" "'rep/zeroinv.p'"   "'no'"                      "'----++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Пустографка для документа'"                                          "'cost,sale,rubl,base'" "'rep/zeroinv.p'"   "'yes'"                     "'----++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (по поставщикам)'"                          "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'invent,no,no,no'"         "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (по поставщикам)'"                          "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'invent,no,no,yes'"        "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (по поставщикам)'"                            "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'sl,no,no,no'"             "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (по поставщикам)'"                            "'cost,sale,rubl,base'" "'rep/inv-pst.p'"   "'sl,no,no,yes'"            "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (итоги по производителям) сжатая'"          "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,prod,no'"          "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризационная опись (итоги по производителям)'"                 "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'invent,prod,yes'"         "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (итоги по производителям) сжатая'"            "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,prod,no'"              "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (итоги по производителям)'"                   "'cost,sale,rubl,base'" "'rep/inv-3.p'"     "'sl,prod,yes'"             "'-+-+---+'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризация (анализ отклонений)'"                                 "'cost,sale,rubl,base'" "'rep/inv-3slg.p'"  "'no'"                      "'-+-+++--'"  "'SPAR'"    "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Инвентаризация (анализ отклонений) сжатая'"                          "'cost,sale,rubl,base'" "'rep/inv-3slg.p'"  "'yes'"                     "'-+-+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (для пересчета)'"                             "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'no,no'"                   "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (для пересчета) сжатая'"                      "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'yes,no'"                  "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (для пересчета - только расхождения)'"        "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'no,yes'"                  "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Сличительная ведомость (для пересчета - только расхождения) сжатая'" "'cost,sale,rubl,base'" "'rep/inv-3del.p'"  "'yes,yes'"                 "'----++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Документ инвентаризации'"                                            "'cost,sale,rubl,base'" "'rep/inv-new.p'"   "''"                        "'---+----'"  "'world'"   "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} {&fact} "'*'" "'*'"       "'Акт приема-передачи'"                                                "'cost,sale,rubl,base'" "'rep/inv-akt.p'"   "''"                        "'----++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Peresort} "'*'" "'*'" "'*'"         "'Документ пересортицы'"                                               "'cost,sale,rubl,base'" "'rep/r-resort.p'"  "''"                        "'---+----'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'*'" "'*'"   "'Акт переоценки учетной цены по остаткам товара поставщика'"          "'cost,sale,rubl,base'" "'rep/r-akt-po.p'"  "''"                        "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'*'" "'*'"   "'Документ ТОРГ12 (возврат поставщику) для переоценки уч.цены'"        "'cost,sale,rubl,base'" "'rep/trg-12po.p'"  "'yes'"                     "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'*'" "'*'"   "'Документ ТОРГ12 (приход внешний) для переоценки уч.цены'"            "'cost,sale,rubl,base'" "'rep/trg-12po.p'"  "'no'"                      "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'no'" "'*'"  "'Счет-фактура (возврат поставщику) для переоценки уч.цены'"           "'cost,sale,rubl,base'" "'rep/factur.p'"    "'yes,yes,all,no,no'"       "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'no'" "'*'"  "'Счет-фактура (приход внешний) для переоценки уч.цены'"               "'cost,sale,rubl,base'" "'rep/factur.p'"    "'yes,no,all,no,no'"        "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Chg_Purch_Code} "'*'" "'*'" "'*'"   "'Акт смены типа приобретения'"                                        "'cost,sale,rubl,base'" "'rep/r-akt-st.p'"  "''"                        "'---+++--'"  "''"        "'A4port'"    "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'no'" "'*'"  "'Счет-фактура (приход внешний) для переоц.(без НП)'"                  "'cost,sale,rubl,base'" "'rep/factur.p'"    "'yes,no,all,no,yes'"       "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&TDEDT_Corr_Acc_Price} "'*'" "'no'" "'*'"  "'Счет-фактура (возврат поставщику) для переоц.(без НП)'"              "'cost,sale,rubl,base'" "'rep/factur.p'"    "'yes,yes,all,no,yes'"      "'---+++--'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i "'*'" "'*'" "'*'" "'*'"                     "'Печать документов внешней программой'"                               "'cost,sale,rubl,base'" "'rep/torg-ext.p'"  {&print}                    "'--------'"  "'BDC'"     "'self'"      "''"     ? }
{ rep/menu-doc.i "'*'" "'*'" "'*'" "'*'"                     "'Печать штрих-кодов внешней программой'"                              "'cost,sale,rubl,base'" "'rep/torg-ext.p'"  {&alt-barcode}              "'--------'"  "'BDC'"     "'self'"      "''"     ? }
{ rep/menu-doc.i {&TDEDT_Inv} {&fact} "'*'" "'*'"            "'Акт на списание материалов'"                                         "'cost,sale,rubl,base'" "'rep/r-achmat.p'"  "''"                        "'-+-----+'"  "'yukos,ibs,Rosneft-*'"       "''"     "''"  ? }

/* Для ОС */
{ rep/menu-doc.i {&write-off}  {&fact} "'no'"  "'*'"         "'Требование-накладная (форма М-11)'"                                  "'cost,sale,rubl,base'" "'rep/r-f_m11.p'"   "''"                        "'-+-+----'"  "''"        "'self'"      "''"     ? }
{ rep/menu-doc.i {&expense_return}    {&fact} "'yes'" "'*'"  "'Требование-накладная (форма М-11)'"                                  "'cost,sale,rubl,base'" "'rep/r-f_m11.p'"   "''"                        "'-+-+----'"  "''"        "'self'"      "''"     ? }
{ rep/menu-doc.i {&write-off}  {&fact} "'no'"  "'*'"         "'Акт о списании материалов (ЦУМ)'"                                    "'cost,sale,rubl,base'" "'rep/r-actspi.p'"  "''"                        "'--------'"  "'ZUM'"     "'self'"      "''"     ? }
{ rep/menu-doc.i {&income}     {&fact} "'*'"   "'*'"         "'Приходный ордер (форма М-4)'"                                        "'cost,sale,rubl,base'" "'rep/r-f_m04.p'"   "'no,11'"                   "'--------'"  "''"        "''"          "'yukos,ibs,Rosneft-*'" ? }
{ rep/menu-doc.i {&income}     {&fact} "'*'"   "'*'"         "'Приходный ордер (форма М-4)'"                                        "'cost,sale,rubl,base'" "'rep/r-f_m04.p'"   "'yes,11'"                  "'--------'"  "'yukos,ibs,Rosneft-*'"   "''"          "''"     ? }
{ rep/menu-doc.i {&income}     {&fact} "'*'"   "'*'"         "'Приходный ордер (форма М-4)'"                                        "'cost,sale,rubl,base'" "'rep/r-f_m04.p'"   "'no,12'"                   "'--------'"  "''"        "''"          "''"     ? }
{ rep/menu-doc.i {&income}     {&fact} "'*'"   "'*'"         "'Приходный ордер (форма М-4Р)'"                                       "'cost,sale,rubl,base'" "'rep/r-f_m04.p'"   "'no,13'"                   "'--------'"  "'Pskov'"   "''"          "''"     ? }
{ rep/menu-doc.i {&expense}    {&fact} "'no'"  "'*'"         "'Накладная на отпуск материалов на сторону (форма М-15)'"             "'cost,sale,rubl,base'" "'rep/r-f_m15.p'"   "''"                        "'--------'"  "'ZUM'"     "'self'"      "''"     ? }

/* $Workfile$ e n  d */