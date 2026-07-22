block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 6

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=4;ruleset_id=1;-----------------
Импорт стоплистов

---------------------------&end-codex_id=4;ruleset_id=1;-----------------

*/

/*---------------------------&start-using-class&-------------------------------*/


/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-fact-date as date no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
{ str/saledcdf.i " " }
define INPUT parameter table for temp-d-card.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 6".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list   def "shared" }
{ cmp/dcp-list.i dcp-list def "shared" }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }

{ str/ean-13f.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ ref/dc-prop.i }
{ ref/discprop.i }


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-d-card as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-type as character no-undo .
/*****************************/
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable num-rec-write as integer.
define variable num-rec-write-ok as integer.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .

{ rul/seterror.i }
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-clients_ no-undo like ub.clients.
define temp-table temp-dis-card_ no-undo like ub.dis-card.


define stream instream.
define variable log-file-name                as character      no-undo init "in-stpl1.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-seek                       as int64          no-undo .

function 00060000_get-readed-line returns character ( input p-seek as int64):
define variable v-line as character no-undo .
seek stream instream to p-seek.
import stream instream unformatted v-line.
return v-line.
end function.

function 00060000_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
return v-mess.
end function.

define variable default-host like ub.shop.host-code.
define variable default-issue-host like ub.shop.host-code.
define variable s as char format "X(300)".
/*для раскладки строчки*/
define variable n-entry as char no-undo extent 20.
/*компоненты строчки*/
define variable my-dcard like ub.dis-card.d-card.
define variable v-blank1 as character no-undo . /*cardnumber*/
define variable v-blank2 as character no-undo . /*account type*/
define variable v-blank3 as character no-undo . /*name*/
define variable myproductcode as integer no-undo . /*product-code*/
define variable v-blank5 as character no-undo . /*product-name*/
define variable myquota as decimal no-undo . /*additionquantity*/
define variable mycarname as character no-undo . /*car-name*/
define variable mycarnumber as character no-undo . /*cardnumber*/
define variable my-del-status-int as integer no-undo .
define variable my-stop-list-flag as integer no-undo .
define variable my-ext-cli-code as integer no-undo .
define variable my-obj-name like ub.clients.obj-name.
define variable my-lim-kr as decimal no-undo .
DEFINE VARIABLE myaccounttype AS INTEGER NO-UNDO.
define variable v-blank9 as character no-undo . /*inactive*/
define variable my-cli-stop-list-flag as integer no-undo .
define variable my-discount-value as decimal no-undo .
define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
define variable choice as integer no-undo.
define variable dd as decimal.
define variable my-value as integer no-undo.
define variable full-d-card as character no-undo .
define variable ii as integer.
define variable var-rid as recid no-undo .
define variable v-dop as character no-undo .
define variable ss as character no-undo .
define variable v-bas-full-path    as character no-undo .
define variable v-txt-full-path        as character no-undo .
define variable v-txt-path             as character no-undo .
define variable v-txt-file-name        as character no-undo .
define variable v-txt-file-name-no-ext as character no-undo .
define variable v-txt-file-name-ext    as character no-undo .
define variable v-txt-full-path2        as character no-undo .
define variable v-txt-path2             as character no-undo .
define variable v-txt-file-name2        as character no-undo .
define variable v-txt-file-name-no-ext2 as character no-undo .
define variable v-txt-file-name-ext2    as character no-undo .
define variable v-found as logical no-undo .
define variable v-resource-id as character no-undo .
define variable v-line-num as integer no-undo .

define variable v-gds-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-status           as character no-undo .
define variable v-stop-list-mess as character no-undo .
define variable v-value as character no-undo .
define variable v-stop-status as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-fact-time as integer no-undo .
define variable v-status_ as character no-undo .
define variable v-stop-list-value as character no-undo .
define variable v-global-err as logical no-undo .
define variable v-gds-attr-value as character no-undo .
define variable v-car-brand as character no-undo .
define variable v-car-reg-number as character no-undo .
define variable v-limit-type as character no-undo .
define variable v-limit as decimal no-undo .
define variable v-limit-l as decimal no-undo .
define variable v-quota-period as character no-undo .
define variable v-quota as decimal no-undo .
define variable v-cc as integer no-undo .
DEFINE VARIABLE v-account-type AS INTEGER NO-UNDO.
define variable v-pay-code as integer no-undo .
define variable v-cdpay-code as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-entry as character no-undo .
define variable v-ext-product-code as integer no-undo .
define variable v-discount-value as decimal no-undo .
define variable v-dis-kat as integer no-undo .
define variable v-dis-kat-type as character no-undo .
define temp-table ext-product-code no-undo
field ext-code as integer
field gds-code as integer
index pi is unique primary
ext-code.
define buffer buf_dis-card for ub.dis-card.
define buffer buf2_dis-card for ub.dis-card.
define buffer bufg_ext-classif for ub.ext-classif.
define buffer bufc_ext-classif for ub.ext-classif.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf0_stop-list for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_dis-card-type  for ub.dis-card-type.
define buffer buf_Dis-card-property for ub.dis-card-property.
define buffer buf_clients for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_shop for ub.shop.

define temp-table temp-imp no-undo
field src-d-card as character
field d-card as character
field product-code as integer
field quota as decimal
field car-name as character
field car-number as character
field del-status-int as integer
field stop-list-flag as integer
field ext-cli-code as integer
field lim-kr as decimal
field cli-stop-list-flag as integer
field account-type as integer
index pi is unique primary
src-d-card
index imain d-card
.
define temp-table temp-ext-discounts no-undo
field ext-cli-code as integer
field ext-code as integer
field discnt-value like ub.dis-rule.discnt-value
index pi
is unique primary
ext-cli-code
ext-code
.

define temp-table temp-discounts no-undo
field obj-type like ub.dis-rule.obj-type
field obj-code like ub.dis-rule.obj-code
field gds-code like ub.goods.gds-code
field pos-type as character
field ext-code as integer
field dis-kat  like ub.dis-rule.dis-kat
field discnt-value like ub.dis-rule.discnt-value
field value-type like ub.dis-rule.value-type
index pi is unique primary
gds-code
obj-type
obj-code
pos-type
dis-kat
index iobj
obj-type
obj-code
index ikat
dis-kat
ext-code
.



&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
define variable p-close as logical no-undo.
define variable p-this-type-only as logical no-undo .


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.

/* ------------------------- &start-def-vars& -----------------------------------*/


/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure ( input p-type
                              ,input p-emitent-host-code ) no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

assign
v-emitent-host-code = p-emitent-host-code
v-type = p-type.

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт стоплиста из файла &1", file-name)).


run gbl/filename.p (
                 input  "exe/sibneft-stop-list.bas"
                ,output v-bas-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найден МАКРОС для импорта стоплиста по ДК -  &1", "sibneft-stop-list.bas")).
  assign
  v-view-log = yes.
  {&view-log}.
  return error.
end.

/*родим название для временного файла*/

run gbl/_tmpfile.p ( input ""
               , ".clients"
               , output v-txt-full-path) .

run gbl/_tmpfile.p ( input ""
               , ".discounts"
               , output v-txt-full-path2) .

run gbl/xlimport.p (
      input v-full-path
    , input v-txt-full-path + {&comma-char} + v-txt-full-path2 /*parameter*/
    , input v-bas-full-path
) no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при чтении из .xls файла&1&2&1&3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        )).
  assign
  v-view-log = yes.
  {&view-log}.
  return error.

end.
if search(v-txt-full-path) = ?
or search(v-txt-full-path2) = ? then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найдены результаты преобразования стоплиста в .txt вид&1&2&1&3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        )).
  assign
  v-view-log = yes.
  {&view-log}.
  return error.
end.

assign
file-name = v-txt-full-path.

/*добавим перевод каретки*/
output stream Instream to value(file-name) append.
put stream instream unformatted skip(1).
output stream Instream close.



run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт стоплиста по ДК из файла &1", file-name)).

/*заполним таблицу скидок*/
for each ext-product-code,
    each buf_shop no-lock:

  for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = ext-product-code.gds-code
        and buf_dis-gds-rule.obj-type = {&shop}
        and buf_dis-gds-rule.obj-code = buf_shop.obj-code
        and buf_dis-gds-rule.discnt-role = {&dgr-pcnt-kat}:
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = buf_Dis-gds-rule.rule-num no-error.
    if available buf_dis-rule then do:
       for each term_dis-rule no-lock where
              term_dis-rule.upper-rule-num = buf_Dis-rule.rule-num:
          find first temp-discounts no-lock where
                    temp-discounts.obj-type = {&shop}
                and temp-discounts.obj-code = buf_shop.obj-code
                and temp-discounts.gds-code = ext-product-code.gds-code
                and temp-discounts.dis-kat = term_dis-rule.dis-kat no-error.
          if not available temp-discounts then do:
            create temp-discounts.
            assign
            temp-discounts.obj-type = {&shop}
            temp-discounts.obj-code = buf_shop.obj-code
            temp-discounts.gds-code = ext-product-code.gds-code
            temp-discounts.dis-kat = term_dis-rule.dis-kat
            temp-discounts.ext-code = ext-product-code.ext-code
            temp-discounts.pos-type = buf_dis-gds-rule.pos-type
            .
          end.
          assign
          temp-discounts.discnt-value = term_dis-rule.discnt-value
          temp-discounts.value-type = buf_dis-rule.value-type
          .
          release temp-discounts.
       end. /*for each term_dis-rule no-lock where*/
    end. /*if available buf_dis-rule then do:*/
  end. /*  for each buf_dis-gds-rule no-lock where*/
end. /*for each ext-product-code,*/
find first buf0_stop-list exclusive-lock where
          buf0_stop-list.classif-type = {&table_dis-card}
        and buf0_stop-list.stop-list-code = v-current-doc-code  no-error .
if not available buf0_stop-list then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найден стоплист &1", v-current-doc-code)).
  v-view-log = yes.
  {&view-log}.
end.

input stream Instream from value(file-name).
_stroka:
REPEAT:
  my-seek1 = seek(Instream).
  num-rec = num-rec + 1.
  assign
  my-dcard = ?
  my-del-status-int = ?
  my-stop-list-flag = ?
  my-ext-cli-code = ?
  my-obj-name = ?
  my-lim-kr = ?
  my-cli-stop-list-flag = ?
  myproductcode = ?
  mycarname = '':U
  mycarnumber = '':U
  myquota = ?
  myaccounttype = ?
  .
  import stream INstream
  my-dcard
  /*
  v-blank1
  v-blank2
  v-blank3
  */
  myproductcode
  /*v-blank5*/
  myquota
  mycarname
  mycarnumber
  my-del-status-int
  my-stop-list-flag
  my-ext-cli-code
  my-lim-kr
  /*v-blank9*/
  my-cli-stop-list-flag
  myaccounttype
  No-ERROR.
  my-seek2 = seek(Instream).
  IF ERROR-STATUS:ERROR
  or (my-seek2 - my-seek1 = 2)
  or (my-seek2 - my-seek1 = 1)
  then do:
      seek STREAM Instream to my-seek1.
      import STREAM Instream unformatted ss.
      my-seek2 = seek(Instream).
      if ss =  "":U then do:
        next _stroka.
      end.
      if num-rec = 1 then do:
          v-global-err = yes.
          my-mess = "Строчка не разобрана!" + {&new-line} +
                          "Требуемый формат строки(между полями пробелы - символьные поля закавычены):" + {&new-line} +
                          "Номер счета(карты)" + {&new-line} +
                          /*
                          "[пропускаем колонку номер карты]" + {&new-line} +
                          "[пропускаем колонку тип счета]" + {&new-line} +
                          "[пропускаем колонку название типа счета]" + {&new-line} +
                          */
                          "код топлива" + {&new-line} +
                          /*"[пропускаем колонку название топлива]" + {&new-line} +*/
                          "квота на топливо" + {&new-line} +
                          "марка ТС" + {&new-line} +
                          "госномер ТС" + {&new-line} +
                          "флаг удаленной карты" + {&new-line} +
                          "флаг стоплиста" + {&new-line} +
                          "код клиента в системе "  + {&new-line} +
                          "лимит по топливу" + {&new-line} +
                          /*"[пропускаем колонку неактивна]" + {&new-line} +*/
                          "флаг стоплиста клиента" + {&new-line} +
                          "Тип счета"
                          .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input my-mess).
          v-view-log = yes.
          {&view-log}.
      end.
      else do:
          my-mess = "Строчка не разобрана!"  .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
      end.
  end.
  assign
  my-mess = ""
  .
  find first temp-imp where
            temp-imp.src-d-card = my-dcard no-error.
  if available temp-imp then do:
    my-mess = substitute("!!!ДК &1 встречается в стоплисте более одного раза", temp-imp.d-card).
    run err-write in this-procedure ( input-output my-mess).
    next _stroka.
  end.
  create temp-imp.
  assign
  temp-imp.src-d-card            = my-dcard
  temp-imp.product-code          = (if myaccounttype = 6 then 0 else myproductcode)
  temp-imp.quota                 = myquota
  temp-imp.car-name              = mycarname
  temp-imp.car-number            = mycarnumber
  temp-imp.del-status-int        = my-del-status-int
  temp-imp.stop-list-flag        = my-stop-list-flag
  temp-imp.ext-cli-code          = my-ext-cli-code
  temp-imp.lim-kr                = my-lim-kr
  temp-imp.cli-stop-list-flag    = my-cli-stop-list-flag
  temp-imp.account-type          = myaccounttype
  .
  release temp-imp.
  num-rec-ok = num-rec-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Стоплист: cчитано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  process events.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _stroka.
  end.
END. /*REPEAT*/
input stream InStream close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Чтение стоплиста из файла &1 завершено: из &2 записей успешно считано &3", file-name, num-rec, num-rec-ok )).

assign
num-rec = 0
num-rec-ok = 0
.


assign
file-name = v-txt-full-path2.
output stream Instream to value(file-name) append.
put stream instream unformatted skip(1).
output stream Instream close.
input stream Instream from value(file-name).
_stroka:
REPEAT:
  my-seek1 = seek(Instream).
  num-rec = num-rec + 1.
  assign
  my-ext-cli-code = ?
  myproductcode = ?
  my-discount-value = ?
  .
  import stream INstream
  my-ext-cli-code
  myproductcode
  my-discount-value
  No-ERROR.
  my-seek2 = seek(Instream).
  IF ERROR-STATUS:ERROR
  or (my-seek2 - my-seek1 = 2)
  or (my-seek2 - my-seek1 = 1)
  then do:
      seek STREAM Instream to my-seek1.
      import STREAM Instream unformatted ss.
      my-seek2 = seek(Instream).
      if ss =  "":U then do:
        next _stroka.
      end.
      if num-rec = 1 then do:
          v-global-err = yes.
          my-mess = "Строчка не разобрана!" + {&new-line} +
                          "Требуемый формат строки(между полями пробелы - символьные поля закавычены):" + {&new-line} +
                          "код клиента в системе "  + {&new-line} +
                          "код топлива в системе "  + {&new-line} +
                          "Значение скидки на топливо"
                          .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input my-mess).
          v-view-log = yes.
          {&view-log}.
      end.
      else do:
          my-mess = "Строчка не разобрана!"  .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
      end.
  end.
  assign
  my-mess = ""
  .
  find first temp-ext-discounts where
            temp-ext-discounts.ext-cli-code = my-ext-cli-code
        and temp-ext-discounts.ext-code = myproductcode
              no-error.
  if available temp-ext-discounts then do:
    my-mess = substitute("!!!Клиент &1 топливо &2 встречается в листе скидок более одного раза"
                          , temp-ext-discounts.ext-cli-code
                          , temp-ext-discounts.ext-code
                          ).
    run err-write in this-procedure ( input-output my-mess).
    next _stroka.
  end.
  create temp-ext-discounts.
  assign
  temp-ext-discounts.ext-cli-code = my-ext-cli-code
  temp-ext-discounts.ext-code     = myproductcode
  temp-ext-discounts.discnt-value = my-discount-value
  .
  release temp-ext-discounts.
  num-rec-ok = num-rec-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Скидки: cчитано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _stroka.
  end.
END. /*REPEAT*/
output to temp-ext-discounts.txt.
for each temp-ext-discounts:
 export temp-ext-discounts.
end.
output close.
os-delete value(v-txt-full-path).
os-delete value(v-txt-full-path2).
run show-counter in p-log-handle .
run write-counter in p-log-handle (substitute("Сохранение..." )) no-error.

if not v-stop then do:
  _stroka2:
  for each temp-imp
  on error undo _stroka2, next _stroka2 :
    if temp-imp.src-d-card = '':U then next _stroka2.
    num-rec-write = num-rec-write + 1.
    IF NOT temp-imp.src-d-card  = ? then do:
      assign
      full-d-card = ean-13("99" + temp-imp.src-d-card + "1", "")
      no-error
      .
      if error-status:error
      or full-d-card = ? then do:
        my-mess = substitute("!!!Ошибка попытке восстановить полный номер карты &1"
                              , temp-imp.src-d-card).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
      assign
      temp-imp.d-card = full-d-card.
      FIND FIRST buf_dis-card NO-LOCK WHERE
                  buf_dis-card.d-card = temp-imp.d-card NO-ERROR.
      if not available buf_dis-card then do:
        my-mess = substitute("!!!Нет дисконтной карты с номером &1"
                              , temp-imp.d-card).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
      if p-this-type-only = yes
      and not (buf_dis-card.type = v-type
               and
               buf_dis-card.emitent-host-code = v-emitent-host-code) then do:
        my-mess = substitute("В импортируемом стоплисте встретилась карта &1 ДРУГОГО типа/эмитента: &2 эмитент &3&4" +
                             "согласно параметрам импорта - пропускаем"
                             , buf_dis-card.d-card
                             , buf_dis-card.type
                             , buf_Dis-card.emitent-host-code
                             , {&new-line}
                             ).
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input my-mess).
        next _stroka2.
      end.
    END. /*NOT temp-imp.d-card  = ?*/
    else do:
      my-mess = "!!!Не задан номер дисконтной карты" .
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code
      and  buf_dis-card-type.type = buf_dis-card.type no-error.
    if not available buf_dis-card-type then do:
      my-mess = substitute("!!!Не удалось определить тип ДК для ДК &1", buf_dis-card.d-card).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    v-pay-code = buf_dis-card-type.pay-code.
    if temp-imp.product-code = ?
    or (temp-imp.product-code = 0 and temp-imp.account-type <> 6) then do:
      my-mess = substitute("!!!Не задан код топлива").
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.product-code > 0
    and temp-imp.account-type <> 6 then do:
      find first ext-product-code no-lock where
                          ext-product-code.ext-code = temp-imp.product-code no-error.
      if not available ext-product-code then do:
        my-mess = substitute("!!!Неизвестное значение кода топлива &1", temp-imp.product-code).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
    end.
    /*запишем dc-prop_dc-petrol */
    assign
    v-car-reg-number = '':U
    v-car-brand  = '':U
    v-limit-type = '':U
    v-limit = 0.0
    v-limit-l = 0.0
    v-quota-period = '':U
    v-quota = 0.0
    v-account-type = 0
    v-cdpay-code = 0
    .
    v-found = no.
    for each buf_dis-card-property no-lock where
            buf_Dis-card-property.d-card = temp-imp.d-card
       and buf_Dis-card-property.dtm-code = {&dc-prop_dc-petrol}
    break
    by buf_Dis-card-property.dt-code:
      if buf_dis-card-property.sum-id <> substitute("petrol-&1"
                                              ,(if temp-imp.product-code > 0
                                                then ext-product-code.gds-code else 0)) then next.
      v-found = yes.
      case buf_dis-card-property.node-code:
        when /*№ автомобиля*/
        {&dc_prop_dc-petrol_car-reg-number} then do:
          assign
          v-car-reg-number = buf_Dis-card-property.property-value-character
          .
        end.
        when /*Марка транспортного средства*/
        {&dc_prop_dc-petrol_car-brand} then do:
          assign
          v-car-brand  = buf_Dis-card-property.property-value-character
          .
        end.
        when /*Тип лимита по топливу*/
        {&dc_prop_dc-petrol_limit-type} then do:
          assign
          v-limit-type = buf_Dis-card-property.property-value-character
          .
        end.
        when /*Лимит по сумме*/
        {&dc_prop_dc-petrol_sum-limit} then do:
          assign
          v-limit = buf_Dis-card-property.property-value-decimal
          .
        end.
        when /*Лимит по количеству*/
        {&dc_prop_dc-petrol_qnty-limit} then do:
          assign
          v-limit-l = buf_Dis-card-property.property-value-decimal
          .
        end.
        when /*Период квоты*/
        {&dc_prop_dc-petrol_quota-period} then do:
          assign
          v-quota-period = buf_Dis-card-property.property-value-character
          .
        end.
        when /*Квота*/
        {&dc_prop_dc-petrol_quota} then do:
          assign
          v-quota = buf_Dis-card-property.property-value-decimal
          .
            end.
        when /*Тип счета*/
        {&dc_prop_dc-petrol_account-type} then do:
          assign
          v-account-type = buf_Dis-card-property.property-value-integer
          .
        end.
        when /*тип кассового платежа*/
        {&dc_prop_dc-petrol_cdpay-code} then do:
          assign
          v-cdpay-code = buf_Dis-card-property.property-value-integer
          .
        end.
      end case.
    end.
    if not v-found then do:
      my-mess = substitute("!!!Ошибка при определении Транспортных средств и лимитов по топливу &1&3" +
                             "для ДК &4&3&5&3&6&3" +
                             "они не определены или неправильно заполнены&3"
                            , temp-imp.product-code
                            , v-pay-code
                            , {&new-line}
                            , temp-imp.d-card
                            , error-status:get-message(1)
                            , return-value
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if v-cdpay-code <> v-pay-code then do:
      my-mess = substitute("!!!Неверно задан тип кассового платежа для оплаты топлива:&1согласно типу ДК должно быть &2, в свойствах ДК - &3"
                           , {&new-line}
                           , v-pay-code
                           , v-cdpay-code
                           ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if /*temp-imp.car-name = '':U*/
    temp-imp.car-name = ?
    then do:
      my-mess = substitute("!!!Не задана марка транспортного средства").
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if /* temp-imp.car-number = '':U*/
    temp-imp.car-number = ?
    then do:
      my-mess = substitute("!!!Не задан гос.рег.номер транспортного средства").
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.car-name <> v-car-brand then do:
      my-mess = substitute("!!!Марка транспортного средства = &1 для ДК &2 в системе IBS TH &3" +
                            "не совпадает с маркой транспортного средства =&4, указанной в стоплисте"
                            , v-car-brand
                            , temp-imp.d-card
                            , {&new-line}
                            , temp-imp.car-name
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.car-number <> v-car-reg-number then do:
      my-mess = substitute("!!!Гос.рег.номер транспортного средства =&1 для ДК &2 в системе IBS TH &3" +
                            "не совпадает с гос.рег.номером транспортного средства &4, указанным в стоплисте"
                            , v-car-reg-number
                            , temp-imp.d-card
                            , {&new-line}
                            , temp-imp.car-number
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.quota <> v-quota then do:
      my-mess = substitute("!!!Значение квоты по топливу &1 =&2 для ДК &3 в системе IBS TH&4" +
                            "не совпадает со значением квоты =&5, указанным в стоплисте"
                            , temp-imp.product-code
                            , v-quota
                            , temp-imp.d-card
                            , {&new-line}
                            , temp-imp.quota
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_Dis-card.cli-type
          and buf_clients.obj-code = buf_Dis-card.cli-code no-error .
    if not available buf_clients then do:
      my-mess = substitute("!!!Не найден держатель карты &1 - &2&3"
                            , buf_Dis-card.d-card
                            , buf_Dis-card.cli-type
                            , buf_Dis-card.cli-code
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if integer(v-account-type) <> temp-imp.account-type then do:
      my-mess = substitute("!!!Значение ТИП СЧЕТА КАРТЫ для ДК &2 в системе IBS TH&3" +
                            "не совпадает со значением ТИПА СЧЕТА КАРТЫ =&4, указанным в стоплисте"
                            , integer(v-account-type)
                            , temp-imp.d-card
                            , {&new-line}
                            , temp-imp.account-type
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.del-status-int <> 0
    and temp-imp.del-status-int <> 1 then do:
      my-mess = substitute("!!!Неверное значение флага удаленной карты= &1", temp-imp.del-status-int).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.stop-list-flag <> 0
    and temp-imp.stop-list-flag <> 1 then do:
      my-mess = substitute("!!!Неверное значение флага стоплиста= &1", temp-imp.stop-list-flag).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.cli-stop-list-flag <> 0
    and temp-imp.cli-stop-list-flag <> 1 then do:
      my-mess = substitute("!!!Неверное значение флага стоплиста клиента= &1", temp-imp.cli-stop-list-flag).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    v-dis-kat = buf_Dis-card.category.
    define variable v-found as logical no-undo .
    _discounts:
    for each temp-ext-discounts where
              temp-ext-discounts.ext-cli-code = temp-imp.ext-cli-code:
      if temp-imp.account-type <> 6
      and temp-ext-discounts.ext-code <> temp-imp.product-code then next _discounts.
      v-found = no.
      for each temp-discounts  where
              temp-discounts.dis-kat = v-dis-kat
          and temp-discounts.ext-code = temp-ext-discounts.ext-code :
        v-found = yes.
        if not (temp-discounts.discnt-value = temp-ext-discounts.discnt-value
              and
              temp-discounts.value-type = integer({&discnt-v-abs})
              ) then do:
          my-mess = substitute("!!!Неверное значение атрибута КАТЕГОРИЯ СКИДКИ=&1&2" +
                              "на объекте &3&4 для места использования &8 значение скидки на товар &5=&6, а должно быть &7"
                             ,v-dis-kat
                             ,{&new-line}
                             ,temp-discounts.obj-type
                             ,temp-discounts.obj-code
                             ,temp-discounts.gds-code
                             ,temp-discounts.discnt-value
                             ,temp-ext-discounts.discnt-value
                             ,temp-discounts.pos-type
                             ).
          run err-write2 in this-procedure ( input-output my-mess).
          NEXT _stroka2.
        end.
      end. /*      for each temp-discounts  where*/
      if not v-found then do:
        my-mess = substitute("!!!Неверное значение КАТЕГОРИЯ СКИДКИ=&1&2" +
                            "для такой категории не задано значение скидки на товар &3"
                            ,v-dis-kat
                            ,{&new-line}
                            ,temp-ext-discounts.ext-code
                            ).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
    end. /*  for each temp-ext-discounts where*/
    /*непосредственное создание записей*/
    if p-save = 0 then do:
      DO ON STOP UNDO _stroka2, NEXT _stroka2
      ON ERROR UNDO _stroka2, NEXT _stroka2:
        if temp-imp.del-status-int = 1
        then do:
         if not p-this-type-only
            or (buf_dis-card.type = v-type
          and buf_dis-card.emitent-host-code = v-emitent-host-code) then do:
              /*внесем в стоплист*/
            find first buf_stop-list-line no-lock where
                      buf_stop-list-line.classif-type = {&table_dis-card}
                  and buf_stop-list-line.stop-list-code = v-current-doc-code
                  and buf_stop-list-line.charkey_one = buf_dis-card.d-card no-error.
            if not available buf_stop-list-line then do:
            v-stop-status = integer({&delete-card}).
          &scop stop-status-code string(v-stop-status)
              v-stop-list-mess = {&stop-status-name}.
              run gen-key-rec in this-procedure ( input {&table_dis-card}
                                                  ,input (buffer buf_dis-card:handle)
                                                  ,output v-resource-id).
              find last buf_stop-list-line no-lock where
                        buf_stop-list-line.classif-type = {&table_dis-card}
                    and buf_stop-list-line.stop-list-code = v-current-doc-code  no-error.
              if available buf_stop-list-line then do:
                v-line-num = buf_stop-list-line.line-num.
              end.
              else do:
                v-line-num = 0.
              end.

              create buf_stop-list-line.
              assign
              buf_stop-list-line.classif-type = {&table_dis-card}
              buf_stop-list-line.stop-list-code = v-current-doc-code
              buf_stop-list-line.line-message = v-stop-list-mess
              buf_stop-list-line.resource_id = v-resource-id
              buf_stop-list-line.charkey_one = buf_dis-card.d-card
              buf_stop-list-line.key#_one = v-stop-status
              buf_stop-list-line.line-num = v-line-num + 1
              v-line-num = v-line-num + 1
              .
              release buf_stop-list-line no-error .
              if error-status:error then do:
                my-mess =  substitute("!!!Ошибка при внесении карты ДК &1 клиента &2&3 в стоплист &4&5" +
                                        "&6&5&7"
                                        ,buf_dis-card.d-card
                                        ,buf_dis-card.cli-type
                                        ,buf_dis-card.cli-code
                                        ,v-current-doc-code
                                        ,{&new-line}
                                        ,error-status:get-message(1)
                                        ,return-value ).
                run err-write2 in this-procedure ( input-output my-mess).
                NEXT _stroka2.
              end.
            end.
          end.
        end. /*if temp-imp.del-status-int = 1 then do:*/
        else do:
          if temp-imp.cli-stop-list-flag = 1 then do:
            /*включим в стоплист все карты держателя*/
            if temp-imp.stop-list-flag = 0 then do:
              v-stop-status = integer({&stop-client}).
        &scop stop-status-code string(v-stop-status)
              v-stop-list-mess = {&stop-status-name}.
            end.
            else do:
              v-stop-status = 3.
              v-stop-status = integer({&stop-card-and-client}).
        &scop stop-status-code string(v-stop-status)
              v-stop-list-mess = {&stop-status-name}.
            end.
            find first buf_clients no-lock where
                      buf_clients.obj-type = buf_Dis-card.cli-type
                  and buf_clients.obj-code = buf_Dis-card.cli-code.
              /*
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute("Контрагент &1&2 &3&4" +
                                      "Все имеющиеся у данного контрагента ДК будут включены в стоплист"
                                      , buf_Dis-card.cli-type
                                      , buf_Dis-card.cli-code
                                      ,buf_clients.obj-name
                                      , {&new-line}
                                      )).*/
            run gen-key-rec in this-procedure ( input {&table_clients}
                                                ,input (buffer buf_clients:handle)
                                                ,output v-resource-id).
            find last buf_stop-list-line no-lock where
                      buf_stop-list-line.classif-type = {&table_dis-card}
                  and buf_stop-list-line.stop-list-code = v-current-doc-code  no-error.
            if available buf_stop-list-line then do:
              v-line-num = buf_stop-list-line.line-num.
            end.
            else do:
              v-line-num = 0.
            end.
            _buf2:
            FOR EACH buf2_dis-card no-lock WHERE
                  buf2_dis-card.cli-type = buf_dis-card.cli-type
            AND  buf2_dis-card.cli-code = buf_dis-card.cli-code
            on error  undo _stroka2, next _stroka2
            on stop   undo _stroka2, next _stroka2
            on endkey undo _stroka2, next _stroka2
            :
              if p-this-type-only
              and not (buf2_dis-card.type = v-type
                      and
                      buf2_dis-card.emitent-host-code = v-emitent-host-code) then next _buf2.
              find first buf_stop-list-line no-lock where
                        buf_stop-list-line.classif-type = {&table_dis-card}
                    and buf_stop-list-line.stop-list-code = v-current-doc-code
                    and buf_stop-list-line.charkey_one = buf2_dis-card.d-card no-error.
              if not available buf_stop-list-line then do:
                create buf_stop-list-line.
                assign
                buf_stop-list-line.classif-type = {&table_dis-card}
                buf_stop-list-line.stop-list-code = v-current-doc-code
                buf_stop-list-line.line-message = v-stop-list-mess
                buf_stop-list-line.resource_id = v-resource-id
                buf_stop-list-line.charkey_one = buf2_dis-card.d-card
                buf_stop-list-line.key#_one = v-stop-status
                buf_stop-list-line.line-num = v-line-num + 1
                v-line-num = v-line-num + 1
                .
                release buf_stop-list-line no-error .
                if error-status:error then do:
                  my-mess =  substitute("!!!Ошибка при внесении карты ДК &1 клиента &2&3 в стоплист &4&5" +
                                          "&6&5&7"
                                          ,buf2_dis-card.d-card
                                          ,buf2_dis-card.cli-type
                                          ,buf2_dis-card.cli-code
                                          ,v-current-doc-code
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
                  run err-write2 in this-procedure ( input-output my-mess).
                  NEXT _stroka2.
                end.
              end. /*if not available buf_stop-list-line then do:*/
            END. /*          FOR EACH buf_dis-card no-lock WHERE*/
          end. /*if temp-imp.cli-stop-list-flag = 1 then do:*/
          else do:
            if temp-imp.stop-list-flag = 1 then do:
              if p-this-type-only
              and not (buf_dis-card.type = v-type
                        and
                        buf_dis-card.emitent-host-code = v-emitent-host-code) then do:
              end.
              else do:
                  /*внесем в стоплист*/
                find first buf_stop-list-line no-lock where
                          buf_stop-list-line.classif-type = {&table_dis-card}
                      and buf_stop-list-line.stop-list-code = v-current-doc-code
                      and buf_stop-list-line.charkey_one = buf_dis-card.d-card no-error.
                if not available buf_stop-list-line then do:
                v-stop-status = integer({&stop-card}).
              &scop stop-status-code string(v-stop-status)
                  v-stop-list-mess = {&stop-status-name}.
                  run gen-key-rec in this-procedure ( input {&table_dis-card}
                                                      ,input (buffer buf_dis-card:handle)
                                                      ,output v-resource-id).
                  find last buf_stop-list-line no-lock where
                            buf_stop-list-line.classif-type = {&table_dis-card}
                        and buf_stop-list-line.stop-list-code = v-current-doc-code  no-error.
                  if available buf_stop-list-line then do:
                    v-line-num = buf_stop-list-line.line-num.
                  end.
                  else do:
                    v-line-num = 0.
                  end.

                  create buf_stop-list-line.
                  assign
                  buf_stop-list-line.classif-type = {&table_dis-card}
                  buf_stop-list-line.stop-list-code = v-current-doc-code
                  buf_stop-list-line.line-message = v-stop-list-mess
                  buf_stop-list-line.resource_id = v-resource-id
                  buf_stop-list-line.charkey_one = buf_dis-card.d-card
                  buf_stop-list-line.key#_one = v-stop-status
                  buf_stop-list-line.line-num = v-line-num + 1
                  v-line-num = v-line-num + 1
                  .
                  release buf_stop-list-line no-error .
                  if error-status:error then do:
                    my-mess =  substitute("!!!Ошибка при внесении карты ДК &1 клиента &2&3 в стоплист &4&5" +
                                            "&6&5&7"
                                            ,buf_dis-card.d-card
                                            ,buf_dis-card.cli-type
                                            ,buf_dis-card.cli-code
                                            ,v-current-doc-code
                                            ,{&new-line}
                                            ,error-status:get-message(1)
                                            ,return-value ).
                    run err-write2 in this-procedure ( input-output my-mess).
                    NEXT _stroka2.
                  end.
                  num-rec-write-ok = num-rec-write-ok + 1.
                end. /*if not available buf_stop-list then do:*/
              end. /*все типы карт можно*/
            end.
          end. /*else /*if temp-imp.cli-stop-list-flag = 1 then do:*/*/
        end.
      END. /*    DO ON*/
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранялось &1 из них успешно &2"
                                                  , num-rec-write
                                                  , num-rec-write-ok
                                                  )) no-error.
    end.  /*if p-save = 0*/
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _stroka2.
    end.
  end. /*for each temp-imp:*/
  if not v-stop then do:
    for each buf_dis-card no-lock:
      if buf_dis-card.status_ = {&current-status} then do:
        find first temp-imp where
                  temp-imp.d-card = buf_dis-card.d-card no-error.
        if not available temp-imp then do:
          my-mess =  substitute("!!!В системе IBS TH обнаружена лишняя ДК &1 в статусе &2,&3" +
                                  "которой нет в стоплисте &4"
                                  ,buf_dis-card.d-card
                                  ,{&current-status}
                                  ,{&new-line}
                                  ,v-current-doc-code).
          run err-write3 in this-procedure ( input-output my-mess).
        end.
      end. /*if buf_dis-card.status_ = {&current-status} then do:*/
      find /*НЕ МЕНЯТЬ НА find first */  buf_dis-card-property no-lock where
                                        buf_dis-card-property.dtm-code = {&dc-prop_dc-petrol}
                                    and buf_dis-card-property.d-card = buf_dis-card.d-card
                                    and buf_dis-card-property.host-code = 0
                                    and buf_dis-card-property.obj-type = '':U
                                    and buf_dis-card-property.obj-code = 0
                                    and buf_dis-card-property.node-code = {&dc_prop_dc-petrol_account-type}
                                    no-error.
      if ambiguous buf_dis-card-property then do:
        my-mess =  substitute("!!!В системе IBS TH обнаружено более одного&2свойства типа ТОПЛИВО для ДК &1&2"
                                ,buf_dis-card.d-card
                                ,{&new-line}
                                ).
        run err-write3 in this-procedure ( input-output my-mess).
      end.
    end.
  end.
  run write-counter in p-log-handle ( input "") no-error.
end. /*if not v-stop*/

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сохранение стоплиста из файла &1 завершено: из &2 записей успешно сохранено &3", file-name, num-rec-write, num-rec-write-ok )).

if p-close
and v-global-err = no then do:
  run ref/stop-l2.p (
                  input parparentproc
                 ,input recid(buf0_stop-list)
                 ,input yes) no-error.
  if error-status:error then do:
    my-mess =  substitute("!!!Ошибка при записи шапки стоплиста &1&2" +
                            "&3&2&4"
                            ,v-current-doc-code
                            ,{&new-line}
                            ,error-status:get-message(1)
                            ,return-value ).
    run err-write2 in this-procedure (input-output my-mess).
  end.
end.

  end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.

  do
  on error undo, return error
  :

/*---------------------------&start-process-rule-call-param&-------------------------------*/

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-close"
 no-error.
if available buf_rule-call-param then do:
assign p-close = buf_rule-call-param.param-value-logical.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-this-type-only"
 no-error.
if available buf_rule-call-param then do:
assign p-this-type-only = buf_rule-call-param.param-value-logical.
end.


/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1 then do:
        assign
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-date = p-doc-date
        v-current-doc-code = p-doc-code
        file-name  = p-process-file-name
        .
        if NOT g#db-num = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Импорт стоплистов возможен только в ГБД")).
          assign
          v-view-log = yes.
          {&view-log}.
          return "return".
        end.

        run gbl/filename.p (
                        input  file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найден файл &1 для импорта стоплистов", file-name)).
          assign
          v-view-log = yes.
          {&view-log}.
          return "return".
        end.
        assign
        file-name = v-full-path.
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */


PROCEDURE err-write:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  seek STREAM Instream to my-seek1.
  import stream InStream unformatted
  s.
  v-global-err = yes.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess + {&new-line} + s).
  assign
  v-view-log = yes.
  mess = "".
  seek STREAM Instream to my-seek2.
END PROCEDURE.

PROCEDURE err-write2:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  v-global-err = yes.
  mess = substitute("&1&2Счет &3"
                    ,mess
                    ,{&new-line}
                    ,temp-imp.src-d-card
                    ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess).
  assign
  v-view-log = yes.
  mess = "".
END PROCEDURE.

PROCEDURE err-write3:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  v-global-err = yes.
  mess = substitute("&1&2Карта &3"
                    ,mess
                    ,{&new-line}
                    ,buf_dis-card.d-card
                    ).

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess).
  assign
  v-view-log = yes.
  mess = "".
END PROCEDURE.