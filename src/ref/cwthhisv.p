block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cwthhisv.p $
$Archive: ref/cwthhisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/


define input parameter p-wth-code like ub.c-wth-hist.wth-code no-undo .
define input parameter p-par-code like ub.c-wth-hist.par-code no-undo .
define input parameter p-chip-num like ub.c-wth-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-wth-hist.corr-user-db-num no-undo .
define input parameter p-host-code like ub.c-wth-hist.host-code no-undo .
define input parameter p-obj-type like ub.c-wth-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-wth-hist.obj-code no-undo .
define input parameter p-subject  like ub.c-wth-hist.subject no-undo .
define input parameter p-action   like ub.c-wth-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define input parameter p-ser-code  like ub.c-wth-hist.ser-code no-undo .
define input parameter p-serdb-num like ub.c-wth-hist.db-num no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cwthhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cwthhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории МЦ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/gdsoattr.i }
{ ref/gdshattr.i }
{ ref/gds-attr.i }
{ trg/factord.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-wth-hist for ub.c-wth-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action" }

find first buf_c-wth-hist no-lock where
          buf_c-wth-hist.wth-code = p-wth-code
      AND buf_c-wth-hist.chip-num = p-chip-num
      AND buf_c-wth-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-wth-hist.obj-type = p-obj-type
      AND buf_c-wth-hist.obj-code = p-obj-code
      AND buf_c-wth-hist.subject  = p-subject no-error .
if not available buf_c-wth-hist then do:
  return error .
end.
CASE p-subject:
  when {&table_wealth} then do:
    run wealth-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_wth-par} then do:
    run wth-par-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_wth-ser} then do:
    run wth-ser-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_wth-gds} then do:
    run wth-gds-proc in this-procedure(output p-description) no-error .
  end.

END CASE.
if error-status:error then do:
  return error .
end.

procedure wealth-proc :
define output parameter p-description as character no-undo .
define buffer current_c-wealth for ub.c-wealth  .

do
on error undo, return error
:
    find first current_c-wealth no-lock where
               current_c-wealth.wth-code = p-wth-code
           AND current_c-wealth.chip-num = p-chip-num
           AND current_c-wealth.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-wealth then do:
       v-mess = "Неверная ссылка на c-wealth в таблице c-wth-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
&scop fields-name-list "curr-code,is-money,PS,stts,unit-base,wth-code,wth-name,is-ser"
v-label-param =
  "curr-code" + {&delim-par} + "Код валюты" + {&delim-par} + "" + {&delim-flf}
 + "is-money" + {&delim-par} + "Наличные" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "stts" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "unit-base" + {&delim-par} + "Ед.изм" + {&delim-par} + "" + {&delim-flf}
 + "wth-code" + {&delim-par} + "Код МЦ" + {&delim-par} + "" + {&delim-flf}
 + "wth-name" + {&delim-par} + "Название" + {&delim-par} + ""  + {&delim-flf}
 + "is-ser" + {&delim-par} + "Серийный" + {&delim-par} + ""
  .
 run proc-full-temp-changes in this-procedure (input (buf_c-wth-hist.action = {&bef-hn-create} )
                                             ,input (buf_c-wth-hist.action = {&bef-hn-delete} )
                                            ,input  buffer current_c-wealth:handle
                                            ,input  {&table_wealth}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.
end procedure. /* wealth-proc */


procedure wth-par-proc :
define output parameter p-description as character no-undo .
define buffer current_c-wth-par for ub.c-wth-par  .

  do
  on error undo, return error
  :
    find first current_c-wth-par no-lock where
               current_c-wth-par.wth-code = p-wth-code
           AND current_c-wth-par.par-code = p-par-code
           AND current_c-wth-par.chip-num = p-chip-num
           AND current_c-wth-par.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-wth-par then do:
       v-mess = "Неверная ссылка на c-wth-par в таблице c-wth-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "par-code,par-feat,par-rate,par-unit,par-val,wth-code"

define variable v-label-param as character no-undo .

v-label-param =
  "par-code" + {&delim-par} + "Код номинала" + {&delim-par} + "" + {&delim-flf}
 + "par-feat" + {&delim-par} + "Доп. признак" + {&delim-par} + "" + {&delim-flf}
 + "par-rate" + {&delim-par} + "Коэффициент" + {&delim-par} + "" + {&delim-flf}
 + "par-unit" + {&delim-par} + "Ед изм" + {&delim-par} + "" + {&delim-flf}
 + "par-val" + {&delim-par} + "Номинал" + {&delim-par} + "" + {&delim-flf}
 + "wth-code" + {&delim-par} + "Код МЦ" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure ( input (buf_c-wth-hist.action = {&bef-hn-create} )
                                             ,input (buf_c-wth-hist.action = {&bef-hn-delete} )
                                            ,input  buffer current_c-wth-par:handle
                                            ,input  {&table_wth-par}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* wth-par-proc */

procedure wth-ser-proc :
define output parameter p-description as character no-undo .
define buffer current_c-wth-ser for ub.c-wth-ser .

  do
  on error undo, return error
  :
    find first current_c-wth-ser no-lock where
               current_c-wth-ser.wth-code = p-wth-code
           AND current_c-wth-ser.chip-num = p-chip-num
           AND current_c-wth-ser.ser-code = p-ser-code
           AND current_c-wth-ser.db-num   = p-serdb-num
           AND current_c-wth-ser.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-wth-ser then do:
       v-mess = "Неверная ссылка на c-wth-ser в таблице c-wth-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "ser-code,db-num,wth-code,authr,chk-ser,stts,beg-dd,beg-dt,beg-mm,beg-yy-smb,beg-yy,chk-bdt~
,chk-edt,chk-gds,chk-par,end-dd,end-dt,end-mm,end-yy-smb,end-yy,gds-rule,gds-smb,maska,par-code,par-rule,par-smb,PS~
,qnty,range-rule,range-smb,ser-rule,ser-smb"
define variable v-label-param as character no-undo .
v-label-param =
  "ser-code" + {&delim-par} + "Код серии" + {&delim-par} + "" + {&delim-flf}
  + "db-num" + {&delim-par} + "№ БД" + {&delim-par} + "" + {&delim-flf}
  + "wth-code" + {&delim-par} + "Код МЦ" + {&delim-par} + "" + {&delim-flf}
  + "authr" + {&delim-par} + "Авторизация" + {&delim-par} + "" + {&delim-flf}
  + "chk-ser" + {&delim-par} + "Проверка по серии" + {&delim-par} + "" + {&delim-flf}
  +  "beg-dd" + {&delim-par} + "Проверка дня начала с симв." + {&delim-par} + "" + {&delim-flf}
  + "beg-dt" + {&delim-par} + "Дата начала" + {&delim-par} + "" + {&delim-flf}
  + "beg-mm" + {&delim-par} + "Проверка месяца начала с симв." + {&delim-par} + "" + {&delim-flf}
  + "beg-yy-smb" + {&delim-par} + "Кол-во симв. в годе срока начала" + {&delim-par} + "" + {&delim-flf}
  + "beg-yy" + {&delim-par} + "Проверка года начала с симв." + {&delim-par} + "" + {&delim-flf}
  + "end-dd" + {&delim-par} + "Проверка дня оконч. с симв." + {&delim-par} + "" + {&delim-flf}
  + "end-yy-smb" + {&delim-par} + "Кол-во симв. в годе срока оконч." + {&delim-par} + "" + {&delim-flf}
  + "end-yy" + {&delim-par} + "Проверка года оконч. с симв." + {&delim-par} + "" + {&delim-flf}
  + "ser-rule" + {&delim-par} + "Проверка серии с символа" + {&delim-par} + "" + {&delim-flf}
  + "ser-smb" + {&delim-par} + "Значение для проверки серии" + {&delim-par} + "" + {&delim-flf}
  + "gds-rule" + {&delim-par} + "Проверка кода товара с символа" + {&delim-par} + "" + {&delim-flf}
  + "gds-smb" + {&delim-par} + "Значение товара в штрих-коде" + {&delim-par} + "" + {&delim-flf}
  + "par-rule" + {&delim-par} + "Проверка номинала товара с символа" + {&delim-par} + "" + {&delim-flf}
  + "par-smb" + {&delim-par} + "Значение номинала в штрих-коде" + {&delim-par} + "" + {&delim-flf}
  + "range-rule" + {&delim-par} + "Проверка диапазона с симв." + {&delim-par} + "" + {&delim-flf}
  + "range-smb" + {&delim-par} + "Проверка диапазона по симв." + {&delim-par} + "" + {&delim-flf}
  + "gds-smb" + {&delim-par} + "Кол-во симв. в коде товара" + {&delim-par} + "" + {&delim-flf}
  + "chk-bdt" + {&delim-par} + "Проверка по сроку начала" + {&delim-par} + "" + {&delim-flf}
  + "stts" + {&delim-par} + "Статус" + {&delim-par} + ""

  .

 run proc-full-temp-changes in this-procedure (input (buf_c-wth-hist.action = {&bef-hn-create} )
                                             ,input (buf_c-wth-hist.action = {&bef-hn-delete} )
                                            ,input  buffer current_c-wth-ser:handle
                                            ,input  {&table_wth-ser}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* wth-ser-proc */

procedure wth-gds-proc :
define output parameter p-description as character no-undo .
define buffer current_c-wth-gds for ub.c-wth-gds .

  do
  on error undo, return error
  :
    find first current_c-wth-gds no-lock where
               current_c-wth-gds.wth-code = p-wth-code
           AND current_c-wth-gds.chip-num = p-chip-num
           AND current_c-wth-gds.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-wth-gds then do:
       v-mess = "Неверная ссылка на c-wth-ser в таблице c-wth-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "gds-code,wth-code,stts"

define variable v-label-param as character no-undo .

v-label-param =
  "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
  + "wth-code" + {&delim-par} + "Код МЦ" + {&delim-par}  + "" + {&delim-flf}
  + "stts" + {&delim-par} + "Статус" + {&delim-par} + "" .

 run proc-full-temp-changes in this-procedure (  input (buf_c-wth-hist.action = {&bef-hn-create} )
                                             ,input (buf_c-wth-hist.action = {&bef-hn-delete} )
                                            , input  buffer current_c-wth-gds:handle
                                            ,input  {&table_wth-gds}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* wth-gds-proc */


PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("История МЦ с кодом &1 номинал &2: щепка &3 БД:&4 фирма: &5 объект: &6 Предмет изменений &7"
                 ,p-wth-code
                 ,p-par-code
                 ,p-chip-num
                 ,p-corr-user-db-num
                 ,p-host-code
                 ,(p-obj-type + string(p-obj-code))
                 ,p-subject) + {&new-line} + p-mess.
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.