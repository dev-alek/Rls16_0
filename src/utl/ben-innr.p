block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ben-innr.p $
$Archive: utl/ben-innr.p $

Запуск ben-innu.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/04/06
Author: Bakhtadze Natalya
Creation date: 04/04/06

*/

define input parameter parparentproc as widget-handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ben-innr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ben-innr.p $":U .
define variable vss-description as character no-undo init "Запуск ben-innu.p".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/getcntxt.i get }
{ ref/extclass.i }


if v-cntxt-db-num <> 0 then do:
  message
  "Данную утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return.
end.

run str/diallog.w (
                  input parparentproc
                 ,input this-procedure:handle
                 ,input ('ben-innu':U + {&delim-par}  +
                        "1" + {&delim-par} +
                        "0" + {&delim-par} +
                        "1" + {&delim-par} +
                        "1" + {&delim-par} +
                        "yes")
                 ,input '':U
                 ,input no
                 ,input '':U
                 ,input 'Утилита коррекции кодов INN в таблице ext-classif по данным карточке контрагентов') no-error.


procedure ben-innu :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable ii as integer no-undo .
define variable ii-prs as integer no-undo .
define variable ii-cmp as integer no-undo .
define variable ii-prs-ok as integer no-undo .
define variable ii-cmp-ok as integer no-undo .
define variable ii-err-rec as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-rid as recid no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer buf_clients for ub.clients.

_cmp:
for each buf_firm no-lock
on error undo, next _cmp
on stop undo, next _cmp:
   assign
   ii-cmp = ii-cmp + 1.
   ii = ii + 1.
   .
   run write-counter in p-log-handle ( input substitute("Просмотрено &1 записей контрагентов", ii)) .
   if trim(buf_firm.inn) = '':U then next _cmp.
   find first buf_clients no-lock where
              buf_clients.obj-type = {&cmp}
          and buf_clients.obj-code = buf_firm.firm-code no-error.
    run gen-key-rec in this-procedure (
                                        input  ({&table_clients})
                                        ,input  (buffer buf_clients:handle)
                                        ,output v-uniq-key-rec ).

   find first buf_ext-classif where
            buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = {&extclass_clients_inn}
        and buf_ext-classif.charkey_one  = buf_firm.inn
        and buf_ext-classif.db-num  = -1
        and buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        no-error.
   if available buf_ext-classif
   and buf_ext-classif.charkey_one = buf_firm.inn then next _cmp.
   if available buf_ext-classif
   and buf_ext-classif.charkey_one <> buf_firm.inn then do:
     run ref/extclas3.p ( input yes
                         ,input recid(buf_ext-classif)) no-error.
     if error-status:error then do:
        run write-log in p-log-handle (
              input 1
            , input substitute( substitute("Ошибка при удалении {&abbr_inn_allshift} (ext-classif), не совпадающего с {&abbr_inn_allshift} в карточке &1&2"
                                           , {&cmp}, buf_firm.firm-code))).
       next _cmp.
     end.
     else do:
      ii-err-rec = ii-err-rec + 1.
     end.
   end. /*if buf_ext-classif.charkey_one <> buf_firm.inn then do:*/
   run ref/extclas1.p ( INPUT {&add-def}
                        ,INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT v-rid
                        ,INPUT {&table_clients} /*p-classif-subject*/
                        ,INPUT {&extclass_clients_inn} /*p-classif-name*/
                        ,input (-1) /*p-db-num*/
                        ,input 0 /*p-key#_one*/
                        ,input 0 /*p-Key#_Two*/
                        ,input 0 /*p-key#_Three*/
                        ,input buf_firm.inn /*p-CharKey_One */
                        ,input '':U /*p-CharKey_two */
                        ,input '':U /*p-CharKey_three */
                        ,input ''
                        ,input v-uniq-key-rec ) no-error.
    if not error-status:error then do:
      assign
      ii-cmp-ok = ii-cmp-ok + 1.
      .
   end.
   else do:
      run write-log in p-log-handle (
            input 1
          , input substitute( substitute("Ошибка при сохранении {&abbr_inn_allshift} (ext-classif) для &1&2"
                                          , {&cmp}, buf_firm.firm-code))).
   end.
end.
_prs:
for each buf_person no-lock
on error undo, next _prs
on stop undo, next _prs:
   assign
   ii-prs = ii-prs + 1.
   ii = ii + 1.
   .
   run write-counter in p-log-handle ( input substitute("Просмотрено &1 записей контрагентов", ii)).

   if trim(buf_person.inn) = '':U then next _prs.
   find first buf_clients no-lock where
              buf_clients.obj-type = {&cmp}
          and buf_clients.obj-code = buf_person.psn-code no-error.
    run gen-key-rec in this-procedure (
                                        input  ({&table_clients})
                                        ,input  (buffer buf_clients:handle)
                                        ,output v-uniq-key-rec ).

   find first buf_ext-classif where
            buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = {&extclass_clients_inn}
        and buf_ext-classif.charkey_one  = buf_person.inn
        and buf_ext-classif.db-num  = -1
        and buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        no-error.
   if available buf_ext-classif
   and buf_ext-classif.charkey_one = buf_person.inn then next _prs.
   if available buf_ext-classif
   and buf_ext-classif.charkey_one <> buf_person.inn then do:
     run ref/extclas3.p ( input yes
                         ,input recid(buf_ext-classif)) no-error.
     if error-status:error then do:
        run write-log in p-log-handle (
              input 1
            , input substitute( substitute("Ошибка при удалении {&abbr_inn_allshift} (ext-classif), не совпадающего с {&abbr_inn_allshift} в карточке &1&2 "
                                           , {&prs}, buf_person.psn-code))).
       next _prs.
     end.
     else do:
      ii-err-rec = ii-err-rec + 1.
     end.
   end.
   run ref/extclas1.p ( INPUT {&add-def}
                        ,INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT v-rid
                        ,INPUT {&table_clients} /*p-classif-subject*/
                        ,INPUT {&extclass_clients_inn} /*p-classif-name*/
                        ,input (-1) /*p-db-num*/
                        ,input 0 /*p-key#_one*/
                        ,input 0 /*p-Key#_Two*/
                        ,input 0 /*p-key#_Three*/
                        ,input buf_person.inn /*p-CharKey_One */
                        ,input '':U /*p-CharKey_two */
                        ,input '':U /*p-CharKey_three */
                        ,input ""
                        ,input v-uniq-key-rec ) no-error.
   if not error-status:error then do:
    assign
    ii-prs-ok = ii-prs-ok + 1.
    .
   end.
   else do:
      run write-log in p-log-handle (
            input 1
          , input substitute( substitute("Ошибка при сохранении {&abbr_inn_allshift} (ext-classif) для &1&2"
                                          , {&prs}, buf_person.psn-code))).
   end.
end.
for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = {&table_clients}
   and buf_ext-classif.classif-name = {&extclass_clients_inn}:
  run gen-row-keyr  in this-procedure (
  input  buf_ext-classif.uniq-key-rec
  ,input  ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
  ,input  "ub"
  ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,input NO-LOCK
  ,output v-tbl-row
  ,output v-tbl-name) no-error.
  if error-status:error
  or not v-tbl-name = {&table_clients} then do:
     run ref/extclas3.p ( input yes
                         ,input recid(buf_ext-classif)) no-error.
     if error-status:error then do:
        run write-log in p-log-handle (
              input 1
            , input substitute( substitute("Ошибка при удалении {&abbr_inn_allshift} (ext-classif), с невернмы uniq-key-rec &1"
                                           , buf_ext-classif.uniq-key-rec))).
     end.
     else do:
      ii-err-rec = ii-err-rec + 1.
     end.
  end.
end.

run write-log in p-log-handle (
      input 1
    , input substitute( substitute("Просмотрено &1 записей по организациям и  &2 по физическим лицам&3" +
                                    "Сохранено кодов {&abbr_inn_allshift}&3" +
                                    "&4 по организациям и &5 по физическим лицам&3" +
                                    "удалено &6 неверных записей"
                                    , ii-cmp
                                    , ii-prs
                                    , {&new-line}
                                    , ii-cmp-ok
                                    , ii-prs-ok
                                    , ii-err-rec
                                    ))).
end procedure. /* ben-innu */
