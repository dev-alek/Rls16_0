block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: impalpha.p $
$Archive: utl/impalpha.p $

Закачка стран происхождения в карточку товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/06
Author: Bakhtadze Natalya
Creation date: 12/08/06

формат файла импорта :

артикул;код производителя с типом ОРГ;код ALPHA1 - должен содержатся в справочнике countries
после последней строки Enter

пример :
арт-1;9999;RU


*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impalpha.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impalpha.p $":U .
define variable vss-description as character no-undo init "Закачка стран происхождения в карточку товара".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/tt-tax.i "new shared" tt-tax full }


define variable InputFileName as char                 no-undo.
define variable glog as logical no-undo .
define variable v-parameter   as character no-undo .


{ gbl/getcntxt.i get }
if ( v-cntxt-db-num > 0 ) then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.

SYSTEM-DIALOG GET-FILE InputFileName
              TITLE   "Файл для заполнения поля страны происхождения"
              FILTERS "Текстовый файл (*.txt)" "*.txt",
                      "Все файлы (*.*)"        "*.*"
              MUST-EXIST
              USE-FILENAME
              UPDATE glog.
if not glog then return.

InputFileName = trim (string (InputFileName)) .
glog = yes.
message
"Выберите кодировку входного файла: YES - 1251, NO - KOI8-R"
view-as alert-box question buttons YES-NO update glog.
define variable v-encoding as character no-undo .
if glog then
v-encoding = "1251".
else
v-encoding = "KOI8-R".

glog = yes.
message "Выберите режим импорта:" skip
        "YES - замена" skip
        "NO - добавление (заполняются только пустые)"
        view-as alert-box question buttons YES-NO update glog.

{ gbl/getcntxt.i get }

assign
v-parameter =

              "alpha1":U + {&delim-nws} +
              (if glog then "replace" else {&add-def}) + {&delim-par} + inputfilename + {&delim-par} + v-encoding +
                            {&delim-nws} +
              v-cntxt-obj-type                                                                                    + {&delim-par} +
              string(v-cntxt-obj-code)                                                                            + {&delim-par} +
              "":U /*var-fact-order*/                                                                             + {&delim-par} +
              "":U /*gds-name */                                                                                  + {&delim-par} +
              "":U /*engl-name */                                                                                 + {&delim-par} +
              "":U /*label-name */                                                                                + {&delim-par} +
              "":U /*chk-name */                                                                                  + {&delim-par} +
              "":U /*aplha1 */                                                                                    + {&delim-par} +
              "":U /*unit-cli */                                                                                  + {&delim-par} +
              "":U /*max-rate */                                                                                  + {&delim-par} +
              "":U /*min-rate */                                                                                  + {&delim-par} +
              "":U /*cli-base-rate */                                                                             + {&delim-par} +
              "":U /*qnty-cart */                                                                                 + {&delim-par} +
              "":U /**ms-base*/                                                                                   + {&delim-par} +
              "":U /**wt-base*/                                                                                   + {&delim-par} +
              "":U /**ms-cart*/                                                                                   + {&delim-par} +
              "":U /**wt-cart*/                                                                                   + {&delim-par} +
              "":U /*v-calc-method*/                                                                              + {&delim-par} +
              "":U /*increase-pc*/                                                                                + {&delim-par} +
              "":U /*negative-rest*/                                                                              + {&delim-par} +
              "":U /*okdp*/                                                                                       + {&delim-par} +
              "":U /* destin_ */                                                                                  + {&delim-par} +
              "":U /*attrib_ */                                                                                   + {&delim-par} +
              "":U /* user-rule_ */                                                                               + {&delim-par} +
              "":U /*sert_ */                                                                                     + {&delim-par} +
              "":U /*struct_ */                                                                                   + {&delim-par} +
              "":U /*deadline_ */                                                                                 + {&delim-par} +
              "":U /*cond-keep-code_*/                                                                            + {&delim-par} +
              "":U /*sort_ */                                                                                     + {&delim-par} +
              "":U /*normal-wastage_*/                                                                            + {&delim-par} +
              "":U /*normal-waste_*/                                                                              + {&delim-par} +
              "":U /*tnved_ */                                                                                    + {&delim-par} +
              "":U /*nationality_ */                                                                              + {&delim-par} +
              "":U /* unit-cst_ */                                                                                + {&delim-par} +
              "":U /*cst-base-rate_*/                                                                             + {&delim-par} +
              "":U /*fbr-grp-code */                                                                              + {&delim-par} +
              "":U /*ps */                                                                                        + {&delim-par} +
              "":U /*(par-date, "99/99/9999") */                                                                  + {&delim-par} +
              "":U /*stts*/
.
v-parameter = v-parameter + {&delim-nws}.
v-parameter = v-parameter +
              "no":U /*gds-name */                                                                                  + {&delim-par} +
              "no":U /*engl-name */                                                                                 + {&delim-par} +
              "no":U /*label-name */                                                                                + {&delim-par} +
              "no":U /*chk-name */                                                                                  + {&delim-par} +
              "yes":U /*aplha1 */                                                                                    + {&delim-par} +
              "no":U /*unit-cli */                                                                                  + {&delim-par} +
              "no":U /*max-rate */                                                                                  + {&delim-par} +
              "no":U /*min-rate */                                                                                  + {&delim-par} +
              "no":U /*cli-base-rate */                                                                             + {&delim-par} +
              "no":U /*qnty-cart */                                                                                 + {&delim-par} +
              "no":U /**ms-base*/                                                                                   + {&delim-par} +
              "no":U /**wt-base*/                                                                                   + {&delim-par} +
              "no":U /**ms-cart*/                                                                                   + {&delim-par} +
              "no":U /**wt-cart*/                                                                                   + {&delim-par} +
              "no":U /*v-calc-method*/                                                                              + {&delim-par} +
              "no":U /*increase-pc*/                                                                                + {&delim-par} +
              "no":U /*negative-rest*/                                                                              + {&delim-par} +
              "no":U /*okdp*/                                                                                       + {&delim-par} +
              "no":U /* destin_ */                                                                                  + {&delim-par} +
              "no":U /*attrib_ */                                                                                   + {&delim-par} +
              "no":U /* user-rule_ */                                                                               + {&delim-par} +
              "no":U /*sert_ */                                                                                     + {&delim-par} +
              "no":U /*struct_ */                                                                                   + {&delim-par} +
              "no":U /*deadline_ */                                                                                 + {&delim-par} +
              "no":U /*cond-keep-code_*/                                                                            + {&delim-par} +
              "no":U /*sort_ */                                                                                     + {&delim-par} +
              "no":U /*normal-wastage_*/                                                                            + {&delim-par} +
              "no":U /*normal-waste_*/                                                                              + {&delim-par} +
              "no":U /*tnved_ */                                                                                    + {&delim-par} +
              "no":U /*nationality_ */                                                                              + {&delim-par} +
              "no":U /* unit-cst_ */                                                                                + {&delim-par} +
              "no":U /*cst-base-rate_*/                                                                             + {&delim-par} +
              "no":U /*fbr-grp-code */                                                                              + {&delim-par} +
              "no":U /*ps */                                                                                        + {&delim-par} +
              "no":U /*stts */                                                                                      + {&delim-par} +
              "no":U /*br-tt-tax*/
 .

  run str/diallog.w ( input parparentproc
              , input this-procedure
              , input 'goods01r.p':U
              , input v-parameter
              , input no /*p-auto-go*/
              , input "&Стоп"
              , input 'Пакетное изменение страны происхождения товара') .