block-level on error undo, throw.
/*

$Revision: 9263cff4388a, 1753, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:50:10 2019 +0300 $
$Workfile: get-rkep.p $
$Archive: str/get-rkep.p $

Программа приема чеков с касс R-keeper

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

на вход подается  уже преобразованный файл в формате .d

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type  like ub.cash-desk.pos-type no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input parameter p-table as character no-undo .
define input parameter p-file-num  as integer no-undo .
define input-output parameter p-view-log as logical no-undo .

DEFINE VARIABLE vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author: SMMolotkov $":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile: get-rkep.p $":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive: str/get-rkep.p $":u .
DEFINE VARIABLE vss-description as character no-undo init "Программа приема чеков с касс R-keeper" .
{ cmp/vssrevis.i }

{ str/get-chk.i }
/*общие для кассовой части и чековой*/

{ str/get-chkc.i def }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */
/*только чековая часть*/
{ cmp/bitoper.i }
{ str/r-keepdf.i "SHARED" "temp" }
{ str/r-keepdf.i " " "temp-i" }
{ gbl/cur-time.i }
{ str/r-keepth.i }
{ ref/fbrglib.i }
{ gbl/thbj-def.i }
define variable v-session-status_ as character no-undo .

DEFINE TEMP-TABLE tt-cash-pay-r-keeper NO-UNDO LIKE ub.cash-pay
       field r-keeper-cdpay-code like ub.cash-pay.cdpay-code
       index pi is unique primary r-keeper-cdpay-code.

DEFINE TEMP-TABLE tt-dis-rule-r-keeper NO-UNDO LIKE ub.dis-rule
       field r-keeper-rule-num like ub.dis-rule.rule-num
       index pi is unique primary r-keeper-rule-num.



FUNCTION convert-cash-pay returns integer
                                          ( input p-cdpay-code-r-keeper as integer
                                           ,output p-curr-code as integer
                                          ) :
find first tt-cash-pay-r-keeper no-lock where
          tt-cash-pay-r-keeper.r-keeper-cdpay-code = p-cdpay-code-r-keeper    no-error .
if available tt-cash-pay-r-keeper then do:
  assign
  p-curr-code = tt-cash-pay-r-keeper.curr-code.
  return tt-cash-pay-r-keeper.cdpay-code.
end.
assign
p-curr-code = 0.
return p-cdpay-code-r-keeper.
END FUNCTION.


FUNCTION get-sales-man returns integer
                                          ( input p-r-keeper-sifr as integer
                                           ,input p-date as date
                                          ) :
define variable v-seller-code as integer no-undo .
define variable v-s-password as character no-undo .
define buffer buf_cd-clu for ub.cd-clu.
find first buf_cd-clu no-lock where
          buf_cd-clu.obj-type = p-obj-type
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = {&cd-type-r-keeper}
      and buf_cd-clu.clu-type = 'W'
      and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
if not available buf_cd-clu then do :
  find first buf_cd-clu no-lock where
            buf_cd-clu.obj-type = p-obj-type
        and buf_cd-clu.obj-code = p-obj-code
        and buf_cd-clu.pos-type = {&cd-type-r-keeper}
        and buf_cd-clu.clu-type = 'M'
        and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
end.
if available buf_cd-clu and
            buf_cd-clu.cli-code <> ?
        and buf_cd-clu.cli-code <> 0 then do:
  assign
  v-seller-code = gbclcode-get-db-role (  input {&role-seller}
                                         ,input g#db-num
                                         ,input buf_cd-clu.cli-code
                                         ,input p-date
                                         ,output v-s-password ) no-error .
  if error-status:error
  then do:
     return ?.
  end.
  if buf_cd-clu.clu-type = 'M' and ( v-seller-code = ? or v-seller-code = 0 ) then do :
     v-seller-code = gbclcode-get-db-role (  input {&role-cashier}
                                            ,input g#db-num
                                            ,input buf_cd-clu.cli-code
                                            ,input p-date
                                            ,output v-s-password ) no-error .
     if error-status:error
     then do:
       return ?.
     end.
  end.
  return v-seller-code.
end.
return 0.
END FUNCTION.


FUNCTION get-cashier returns integer
                                          ( input p-r-keeper-sifr as integer
                                            ,input p-date as date
                                          ) :
define variable v-cashier-code as integer no-undo .
define variable v-s-password as character no-undo .
define buffer buf_cd-clu for ub.cd-clu.
find first buf_cd-clu no-lock where
          buf_cd-clu.obj-type = p-obj-type
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = {&cd-type-r-keeper}
      and buf_cd-clu.clu-type = 'K'
      and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
if not available buf_cd-clu then do :
  find first buf_cd-clu no-lock where
            buf_cd-clu.obj-type = p-obj-type
        and buf_cd-clu.obj-code = p-obj-code
        and buf_cd-clu.pos-type = {&cd-type-r-keeper}
        and buf_cd-clu.clu-type = 'M'
        and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
end.
if available buf_cd-clu and
            buf_cd-clu.cli-code <> ? then do:
  assign
  v-cashier-code = gbclcode-get-db-role (
                                          input {&role-cashier}
                                         ,input g#db-num
                                         ,input buf_cd-clu.cli-code
                                         ,input p-date
                                         ,output v-s-password ) no-error .
  if error-status:error
  then do:
     return ?.
  end.
  if buf_cd-clu.clu-type = 'M' and ( v-cashier-code = ? or v-cashier-code = 0 ) then do :
     v-cashier-code = gbclcode-get-db-role (   input {&role-seller}
                                              ,input g#db-num
                                              ,input buf_cd-clu.cli-code
                                              ,input p-date
                                              ,output v-s-password ) no-error .
     if error-status:error
     then do:
       return ?.
     end.
  end.
  return v-cashier-code.

end.
return 0.
END FUNCTION.

DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-salesman            as   logical   no-undo .
define variable v-flag-card              as   logical   no-undo .
define variable v-end-of-check             as   logical no-undo init yes.
define variable v-seek                      as integer no-undo .
define variable ll-loc                      as integer no-undo .

assign
shop-type = p-obj-type
shop-code = p-obj-code
dflt-cd = {&cd-type-r-keeper}
.

if file_ <> "":U then  do:
  RUN get-r-keeper-c in this-procedure ( input file_)  no-error .
  if error-status:error then do:
  session:date-format = "dmy":U.
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибка при обработке файла &1: &2"
                              , file_
                              , return-value
                            )
                                            ).
    assign
    p-view-log = yes
    .
    undo, return .
  end.
  session:date-format = "dmy":U.
end.
else do:
  /*сначала убедимся что все данные пришли - сравним с тем, что написана в control*/
  run check-records-num in this-procedure no-error .
  if error-status:error then do:
    assign
    p-view-log = yes
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!При обработке данных с кассы &1 &2&3 нарушена целостность данных: &4"
                            , p-pos-type
                            , p-obj-type
                            , p-obj-code
                            , return-value
                          )
                                          ).
    undo, return.
  end.
  { str/get-chkc.i run }
  get-chkc_context.pos-type = p-pos-type.
  run get-r-keeper-parameters in this-procedure no-error.
  if error-status:error then do:
    assign
    p-view-log = yes
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!При обработке данных с кассы &1 &2&3 произошла ошибка при получении значений настроечных параметров:&4&5"
                            , p-pos-type
                            , p-obj-type
                            , p-obj-code
                            , {&new-line}
                            , return-value
                          )
                                          ).
    undo, return.
  end.
  run save-r-keeper-data in this-procedure no-error .
  if error-status:error then do:
    assign
    p-view-log = yes
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!При обработке данных с кассы &1 &2&3 произошла ошибка при сохранении данных в БД:&4&5"
                            , p-pos-type
                            , p-obj-type
                            , p-obj-code
                            , {&new-line}
                            , return-value
                          )
                                          ).
    undo, return.
  end.
end.

PROCEDURE get-r-keeper-c.
def input parameter filename as char no-undo.
define variable v-file-size as integer no-undo .
define variable v-sys_num as integer no-undo .
define variable v-line-num as integer no-undo .
define buffer buf_temp-control for temp-control.

&scop count-record ~
      find first buf_temp-control where ~
                buf_temp-control.file_ = ~{&delim-par~} + p-table  no-error . ~
       if not available buf_temp-control then do:                             ~
        create buf_temp-control.                                              ~
        assign                                                                ~
        buf_temp-control.file_ = ~{&delim-par~} + p-table                     ~
        .                                                                     ~
        error-status:error = no.                                              ~
      end.                                                                    ~
      assign                                                                  ~
      buf_temp-control.records = buf_temp-control.records + 1                 ~

&scop log-import-error ~
      if error-status:error then do:                                          ~
        run write-log-and-file in p-log-handle (                              ~
              input 1                                                         ~
            , input log-file-name                                             ~
            , input 1                                                         ~
            , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"  ~
                              , filename                                                             ~
                              , var-file-line-num                                                    ~
                              , ~{&new-line~}                                                        ~
                              , error-status:get-message(1)                                          ~
                                )).                                                                  ~
        assign                                                                                       ~
        p-view-log = yes                                                                             ~
        .                                                                                            ~
      end


run gbl/filename.p (
                input filename
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                          , filename
                          , return-value
                        )
                                  ).
  return.
end.
error-status:error = FALSE.
run gbl/filesize.p (
                input v-full-path
               ,output v-file-size)
               no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении длины файла: &2"
                          , filename
                          , return-value
                        )
                                  ).
  return.
end.

input stream ChkStream from value( filename ) convert source "ibm866".
if Lookup(p-table, {&data-field-files}) > 0 then session:date-format = "mdy":U.
else session:date-format = "dmy":U.
_repeat:
REPEAT :
_line:
  DO TRANSACTION:
    v-seek  = seek(CHkstream).
    if (v-seek = ?) or (v-file-size - v-seek <= 2) then do:
      return.
    end.
    CASE p-table:
      when "ACHECK":U then do:
        if available temp-i-acheck then delete temp-i-acheck.
        create temp-i-acheck.
        import stream ChkStream temp-i-acheck no-error .
        if not error-status:error then do:
          create temp-acheck.
          buffer-copy temp-i-acheck to temp-acheck
          assign
          temp-acheck.start-time = integer(temp-acheck.opendate) +
                                   0.00001 * (integer(entry(1, temp-acheck.opentime, ":":U)) * 3600 + integer (entry(2, temp-acheck.opentime, ":":U)) * 60 )
          temp-acheck.end-time = integer(temp-acheck.realdate) +
                                   0.00001 * (integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60 )
          .
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "ADCHECK":U then do:
        if available temp-i-adcheck then delete temp-i-adcheck.
        create temp-i-adcheck.
        import stream ChkStream temp-i-adcheck no-error .
        if not error-status:error then do:
          create temp-adcheck.
          buffer-copy temp-i-adcheck to temp-adcheck
          assign
          v-line-num = (if v-sys_num = temp-i-adcheck.sys_num
                        then v-line-num
                        else 0)
          temp-adcheck.line-num = v-line-num + 1
          v-line-num = v-line-num + 1
          v-sys_num = temp-i-adcheck.sys_num
          .
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "APCHECK":U then do:
        if available temp-i-apcheck then delete temp-i-apcheck.
        create temp-i-apcheck.
        import stream ChkStream temp-i-apcheck no-error .
        if not error-status:error then do:
          create temp-apcheck.
          buffer-copy temp-i-apcheck to temp-apcheck
          assign
          v-line-num = (if v-sys_num = temp-i-apcheck.sys_num
                        then v-line-num
                        else 0)
          temp-apcheck.line-num = v-line-num + 1
          v-line-num = v-line-num + 1
          v-sys_num = temp-i-apcheck.sys_num
          .
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "ARCHECK":U then do:
        if available temp-i-archeck then delete temp-i-archeck.
        create temp-i-archeck.
        import stream ChkStream temp-i-archeck no-error .
        if not error-status:error then do:
          create temp-archeck.
          buffer-copy temp-i-archeck to temp-archeck
          assign
          v-line-num = (if v-sys_num = temp-i-archeck.sys_num
                        then v-line-num
                        else 0)
          temp-archeck.line-num = v-line-num + 1
          v-sys_num = temp-i-archeck.sys_num
          v-line-num = v-line-num + 1
          .
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "AVCHECK":U then do:
        if available temp-i-avcheck then delete temp-i-avcheck.
        create temp-i-avcheck.
        import stream ChkStream temp-i-avcheck no-error .
        if not error-status:error then do:
          create temp-avcheck.
          buffer-copy temp-i-avcheck to temp-avcheck
          assign
          temp-avcheck.del-time = integer(temp-avcheck.realdate) +
                                  0.00001 * (integer(entry(1, temp-avcheck.f_time, ":":U)) * 3600 + integer (entry(2, temp-avcheck.f_time, ":":U)) * 60 )
          temp-avcheck.line-num = v-line-num + 1
          v-line-num = v-line-num + 1
          temp-avcheck.sys_num = 0
          .
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "CATEG":U then do:
        if available temp-i-categ then delete temp-i-categ.
        create temp-i-categ.
        import stream ChkStream temp-i-categ no-error .
        if not error-status:error then do:
          create temp-categ.
          buffer-copy temp-i-categ to temp-categ.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "CHARGES":U then do:
        if available temp-i-charges then delete temp-i-charges.
        create temp-i-charges.
        import stream ChkStream temp-i-charges no-error .
        if not error-status:error then do:
          create temp-charges.
          buffer-copy temp-i-charges to temp-charges.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "CONTROL":U then do:
        if available temp-i-control then delete temp-i-control.
        create temp-i-control.
        import stream ChkStream temp-i-control no-error .
        if not error-status:error then do:
          create temp-control.
          buffer-copy temp-i-control to temp-control.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "MENU":U then do:
        if available temp-i-menu then delete temp-i-menu.
        create temp-i-menu.
        import stream ChkStream temp-i-menu no-error .
        if not error-status:error then do:
          create temp-menu.
          buffer-copy temp-i-menu to temp-menu.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "MODIFY":u then do:
        if available temp-i-modify then delete temp-i-modify.
        create temp-i-modify.
        import stream ChkStream temp-i-modify no-error .
        if not error-status:error then do:
          create temp-modify.
          buffer-copy temp-i-modify to temp-modify.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "MONEY":u then do:
        if available temp-i-money then delete temp-i-money.
        create temp-i-money.
        import stream ChkStream temp-i-money no-error .
        if not error-status:error then do:
          create temp-money.
          buffer-copy temp-i-money to temp-money.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "PERSONAL":u then do:
        if available temp-i-personal then delete temp-i-personal.
        create temp-i-personal.
        import stream ChkStream temp-i-personal no-error .
        if not error-status:error then do:
          create temp-personal.
          buffer-copy temp-i-personal to temp-personal.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      when "REASONS":u then do:
        if available temp-i-reasons then delete temp-i-reasons.
        create temp-i-reasons.
        import stream ChkStream temp-i-reasons no-error .
        if not error-status:error then do:
          create temp-reasons.
          buffer-copy temp-i-reasons to temp-reasons.
          {&count-record}.
        end.
        {&log-import-error}.
      end.
      otherwise do:
        return.
      end.
    END CASE.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", filename, var-file-line-num)).
    end.
  END.
END. /*repeat*/
session:date-format = "dmy":U.
error-status:error = false.
input stream ChkStream close.
END PROCEDURE.

PROCEDURE get-r-keeper-parameters:
define variable v-cash-pay-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cdpay-code-r-keeper LIKE ub.cash-pay.cdpay-code NO-UNDO.
define variable v-dis-rule-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rule-num-r-keeper LIKE ub.dis-rule.rule-num NO-UNDO.
define variable ii as integer no-undo .
define variable v-entry as character no-undo .
DEFINE VARIABLE v-cdpay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-curr-code LIKE ub.cash-pay.curr-code NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_dis-rule for ub.dis-rule.


if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен, а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                          )).
  assign
  p-view-log = yes
  .
  undo, return .
end.

if get-chkc_context.t-shft > 0 and get-chkc_context.shift-on = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен,&3" +
                          "а настройка СМЕЩЕННЫЕ СМЕНЫ НА КАССЕ&3" +
                          "(АРМ Администратор - Справочники - Магазины - Параметры - время начала пересменки)&3" +
                          "включена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                         , {&new-line}
                          )).
  assign
  p-view-log = yes
  .
  undo, return .
end.

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-cd-type-r-keeper}
    ,input  '':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute(
                        "Не удалось получить настройки для  POS типа &1 для маг&2"
                        , {&cd-type-r-keeper}
                        , p-obj-code)
                                        ).
    assign
    p-view-log = yes
    .
    undo, return .
end.
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = p-obj-type
    and thbjattr_thbj-attr.obj-code = p-obj-code
    and thbjattr_thbj-attr.upper-prop-code =  {&attr-cd-type-r-keeper}
on error undo, return error :
  case thbjattr_thbj-attr.prop-code :
    when {&attr-cd-type-r-keeper_cash-pay-list} then do:
      assign
      v-cash-pay-list = thbjattr_thbj-attr.property-value-character.
    end.
    when {&attr-cd-type-r-keeper_dis-rule-list} then do:
      assign
      v-dis-rule-list = thbjattr_thbj-attr.property-value-character.
    end.
  end case.
end.
if v-cash-pay-list <> "":U then do:
_ii:
DO ii = 1 TO  NUM-ENTRIES(v-cash-pay-list, ";"):
   ASSIGN
   v-entry = entry(ii, v-cash-pay-list, ";":U)
   v-cdpay-code-r-keeper = integer(entry(1, entry(1, v-entry, {&slash-char}), {&comma-char}))
   v-cdpay-code = integer(entry(1, entry(2, v-entry, {&slash-char}), {&comma-char}))
   v-curr-code = integer(entry(2, entry(2, v-entry, {&slash-char}), {&comma-char}))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
   IF NOT AVAILABLE buf_cash-pay THEN NEXT _ii.
    CREATE tt-cash-pay-r-keeper.
    BUFFER-COPY buf_cash-pay TO tt-cash-pay-r-keeper
    ASSIGN
    tt-cash-pay-r-keeper.r-keeper-cdpay-code = v-cdpay-code-r-keeper
    .
END.
end.
if v-dis-rule-list <> "":U then do:
  _ii:
  DO ii = 1 TO  NUM-ENTRIES(v-dis-rule-list, ";"):
    ASSIGN
    v-entry = entry(ii, v-dis-rule-list, ";":U)
    v-rule-num-r-keeper = integer(entry(1, entry(1, v-entry, {&slash-char}), {&comma-char}))
    v-rule-num = integer(entry(1, entry(2, v-entry, {&slash-char}), {&comma-char}))
    .
    FIND FIRST buf_dis-rule NO-LOCK WHERE
                buf_dis-rule.rule-num = v-rule-num  NO-ERROR.
    IF NOT AVAILABLE buf_dis-rule THEN NEXT _ii.
    CREATE tt-dis-rule-r-keeper.
    BUFFER-COPY buf_dis-rule TO tt-dis-rule-r-keeper
    ASSIGN
    tt-dis-rule-r-keeper.r-keeper-rule-num = v-rule-num-r-keeper
    .
  END.
end.
END PROCEDURE. /*get-r-keeper-parameter*/


procedure check-records-num :
define variable v-return-value as character no-undo .
define buffer buf_temp-control for temp-control.

  do
  on error undo, return error return-value
  :
    for each temp-control no-lock:
      if  temp-control.file_ begins {&delim-par} then NEXT.
      if LOOKUP(temp-control.file, {&all-used-files }) = 0  then NEXT.
      if p-file-num < 0 and LOOKUP(temp-control.file, {&chk-used-files }) = 0   then NEXT.
      find first buf_temp-control no-lock where
                buf_temp-control.file_ begins ({&delim-par} + temp-control.file_) no-error .


      if (not available buf_temp-control and temp-control.records <> 0)
      or (available buf_temp-control and temp-control.records <> buf_temp-control.records)
      then do:
        assign
        v-return-value = v-return-value + {&new-line} +
                         substitute("Файл &1: ожидалось &2 записей - получено &3"
                                    , temp-control.file_
                                    , temp-control.records
                                    , (if available buf_temp-control then buf_temp-control.records else 0)
                                    ).
      end.
    end.
    if v-return-value <> "":u then do:
      return error v-return-value.
    end.
  end.

end procedure. /* check-records-num */

procedure save-r-keeper-data :
define buffer buf_cd-doc for ub.cd-doc.

  do
  on error undo, return error return-value
  :
   /* if p-file-num > 0 then do: */
      run save-goods in this-procedure no-error .
      if error-status:error then do:
        return error return-value .
      end.
      run save-modifiers in this-procedure no-error .
      if error-status:error then do:
        return error return-value .
      end.
      run save-clients in this-procedure no-error .
      if error-status:error then do:
        return error return-value .
      end.
   /* end. */
    find first buf_cd-doc exclusive-lock where
            buf_cd-doc.obj-type = p-obj-type
        and buf_cd-doc.obj-code = p-obj-code
        and buf_cd-doc.pos-type = {&cd-type-r-keeper}
        and buf_cd-doc.doc-type = '':U
        and buf_cd-doc.doc-code = string((abs(p-file-num))) no-wait no-error.
    if not available buf_cd-doc then do:
      return error substitute("!!!Не найдена запись сессии чтения чеков с касс R-KEEPER для маг&1", p-obj-code).
    end.

    assign
    buf_cd-doc.to-send = yes
    buf_cd-doc.charkey_one = '':U
    .
    run get-checks in this-procedure no-error .
    assign
    buf_cd-doc.charkey_one = v-session-status_
    buf_cd-doc.to-send = (v-session-status_ = 'U')
    .
    if error-status:error then do:
       return error return-value .
    end.
  end.

end procedure. /* save-r-keeper-data */



procedure save-goods :
define variable v-mode as character no-undo .
define variable v-update-price as logical no-undo .
define variable v-update-name as logical no-undo .
define variable v-update-group as logical no-undo .
define variable v-update-modificator as logical no-undo .
define variable v-update-parent as logical no-undo .

define variable v-deleted    as logical   no-undo .
define variable v-price      as decimal  no-undo .
define variable v-price-sale as decimal no-undo .
define variable v-doc-num    as character no-undo .
define variable v-gds-name   as character no-undo .
define variable v-grp-code   as integer no-undo .
define variable v-grp-name   as character no-undo .
define variable v-modif      as logical no-undo .
define variable v-null-price as logical no-undo .
define variable v-parent     as integer no-undo .
define variable v-dop-code-int as integer no-undo .
define variable v-lvl-num as integer no-undo .
define variable v-upper-num as integer no-undo .



define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-grp for ub.cd-grp.
define buffer buf_cd-doc-line for ub.cd-doc-line.
define buffer ucs_cd-grp for ub.cd-grp.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.
define buffer upper_temp-menu for temp-menu.

  _main:
  do
  on error undo, return error return-value
  :
    _temp-menu:
    for each temp-menu:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранение полученных данных: обработано записей &1", ll-loc)).
      assign
      v-dop-code-int = integer(temp-menu.code-chr)
      no-error
      .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Ошибка при обработке записи блюда с id &1 код меню &2 &3:&4&5 &6"
                                  , temp-menu.sifr
                                  , temp-menu.code-chr
                                  , temp-menu.name
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                )
                                                ).
      end.
      assign
      v-mode = "":U
      v-update-name = no
      v-update-price = no
      v-update-group = no
      v-update-modificator = no
      v-price-sale = ?
      v-gds-name  = "":U
      v-grp-code  = 0
      v-modif = no
      v-null-price = no
      .
      if temp-menu.treetype = "F":U
      or temp-menu.treetype = "L":U then do:
        find first buf_cd-plu where
                  buf_cd-plu.obj-type = p-obj-type
             and  buf_cd-plu.obj-code = p-obj-code
             and buf_cd-plu.pos-type = {&cd-type-r-keeper}
             and buf_cd-plu.plu-type = '':U
             and buf_cd-plu.plu-code = temp-menu.sifr no-error.
        if not available buf_cd-plu then do:
          assign
          v-mode = {&add-def}.
        end.
        else do:
          find last buf_cd-doc-line where
                   buf_cd-doc-line.obj-type = p-obj-type
               and buf_cd-doc-line.obj-code = p-obj-code
               and buf_cd-doc-line.pos-type = {&cd-type-r-keeper}
               and buf_cd-doc-line.doc-type = {&overvalue}
               and buf_cd-doc-line.doc-code < string(p-file-num)
               AND buf_cd-doc-line.plu-type = '':U
               AND buf_cd-doc-line.plu-code = temp-menu.sifr no-error .
          if not available buf_cd-doc-line then do:
            assign
            v-price = ?
            v-update-price = yes
            v-update-name =  yes
            v-update-group = yes
            v-update-modificator = yes
            .
          end.
          else do:
            assign
            v-price = buf_cd-doc-line.deckey_one
            .
          end.
          if buf_cd-plu.b-code <> 0 then do:
            assign
            v-price-sale = get-rkgTH-price(shop-type, shop-code, buf_cd-plu.b-code, output v-doc-num)
            v-gds-name   = get-rkgTH-name(shop-type, shop-code, buf_cd-plu.b-code, buffer buf_goods)
            v-grp-code   = get-rkgTH-group(shop-type, shop-code, buf_cd-plu.b-code
                          , output v-grp-name)
            v-modif      = get-rkgTH-modificator(shop-type, shop-code, buf_cd-plu.b-code, output v-null-price)
            .
            assign
            v-update-price = (temp-menu.price <> v-price-sale) or v-price-sale = ?
            v-update-name =  (temp-menu.name <> v-gds-name)
            v-update-group  =  (temp-menu.parent <> v-grp-code)
            v-update-modificator =  ((temp-menu.price = 0 and not v-null-price)
                                     or
                                   (temp-menu.price <> 0 and v-null-price))
            .

          end.
          if (buf_cd-plu.key#_two <> temp-menu.parent)
          or (buf_cd-plu.charkey_one <> temp-menu.name)
          or v-update-name
          or (buf_cd-plu.to-del <>  (not temp-menu.del))
          or (buf_cd-plu.to-send <> temp-menu.del)
          or (buf_cd-plu.b-code > 0 and (v-price = ? or (temp-menu.price <> v-price) or v-update-price or v-price-sale = ? ))
          or (buf_cd-plu.key#_one <> v-dop-code-int)
          or v-update-group
          or v-update-modificator
          then do:
            assign
            v-mode = {&update}
            .
            /*взведем флаг что надо связать*/
          end.
        end. /*available */
        if v-mode <> "":U then do:
          run update-product in this-procedure (
                                                   input v-mode
                                                  ,input v-update-name
                                                  ,input v-update-price
                                                  ,input v-update-group
                                                  ,input v-update-modificator
                                                  ,input temp-menu.sifr
                                                  ,input temp-menu.code-chr
                                                  ,input temp-menu.name
                                                  ,input temp-menu.treetype
                                                  ,input temp-menu.price
                                                  ,input temp-menu.parent
                                                  ,input temp-menu.del
                                                  )
          no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Ошибка при сохранении записи блюда меню с id &1 код меню &2 &3:&4&5 &6"
                                      , temp-menu.sifr
                                      , temp-menu.code-chr
                                      , temp-menu.name
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                    )
                                                    ).
            assign
            p-view-log = yes
            .
            undo _temp-menu, next _temp-menu.
          end.
        end.
      end. /*if F или L*/
      if temp-menu.treetype = "T":U then do:
        assign
        v-update-name = no
        v-update-parent = no
        v-grp-name = "":U
        v-parent = 0
        .
        /*найдем уровень*/
        if temp-menu.parent = 0 then v-lvl-num = 0.
        else do:
          assign
          v-upper-num = temp-menu.parent
          .
          v-lvl-num = - 1.
          do while available  upper_temp-menu or v-lvl-num = - 1:
            find first upper_temp-menu no-lock where
                      upper_temp-menu.sifr = v-upper-num
                        no-error.
            assign
            v-lvl-num = (if v-lvl-num = - 1 then 0 else v-lvl-num )
            v-lvl-num = (if available upper_temp-menu then v-lvl-num + 1 else v-lvl-num)
            v-upper-num = (if available upper_temp-menu then upper_temp-menu.parent else v-upper-num)
            .
          end.
          if v-lvl-num = 0 then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Ошибка при сохранении записи группы блюд меню с id &1 &2:&3не удалось определить уровень грппы"
                                      , temp-menu.sifr
                                      , temp-menu.name
                                      , {&new-line}
                                    )
                                                    ).
            assign
            p-view-log = yes
            .
            undo _temp-menu, next _temp-menu.
          end.
          assign
          temp-menu.lvl-num = v-lvl-num.
        end.
        find first buf_cd-grp no-lock where
                 buf_cd-grp.obj-type = p-obj-type
            and buf_cd-grp.obj-code = p-obj-code
            and buf_cd-grp.pos-type = {&cd-type-r-keeper}
            and buf_cd-grp.grp-type = '':U
            and buf_cd-grp.grp-code = temp-menu.sifr no-error .
        if not available buf_cd-grp then do:
          assign
          v-mode = {&add-def}
          v-update-name =  yes
          v-update-parent = yes
          .
        end.
        else do:
          assign
          v-grp-name   = get-rkgTH-group-name(shop-type, shop-code, temp-menu.sifr)
          v-parent    = get-rkgTH-parent(shop-type, shop-code, temp-menu.sifr)
          .
          assign
          v-update-name =  v-grp-name = ? or v-grp-name <> temp-menu.name
          v-update-parent = v-parent = ? or v-parent <> temp-menu.parent
          .
          if buf_cd-grp.grp-name <> temp-menu.name
          OR buf_cd-grp.upper-grp-code <> temp-menu.parent
          or buf_cd-grp.key#_one <> temp-menu.lvl-num
          or v-update-name
          or v-update-parent
          then do:
            assign
            v-mode = {&update}
            .
          end.
        end.
        if v-mode <> "":U then do:
          run update-country in this-procedure (
                                                   input v-mode
                                                  ,input v-update-name
                                                  ,input v-update-parent
                                                  ,input temp-menu.sifr
                                                  ,input temp-menu.name
                                                  ,input temp-menu.parent
                                                  ,input temp-menu.del
                                                  ,input temp-menu.lvl-num
                                                  )
          no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Ошибка при обработке сохранении записи группы меню с id &1 &2:&3&4 &5"
                                      , temp-menu.sifr
                                      , temp-menu.name
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                    )
                                                    ).
            assign
            p-view-log = yes
            .
            undo _temp-menu, next _temp-menu.
          end.
        end.
      end.
    end. /*for each */
    /*удалим ненужные продукты*/
    for each buf_cd-plu :
      if buf_cd-plu.charkey_two= "M" then next. /*это модификаторы*/
      if not can-find(first temp-menu no-lock where
                           temp-menu.sifr = buf_cd-plu.plu-code
                       AND (temp-menu.treetype = "F":U or
                            temp-menu.treetype = "L":U )) then do:
        delete buf_cd-plu .
      end.
    end.
    /*удалим ненужные группы*/
    for each buf_cd-grp where
            buf_cd-grp.obj-type = p-obj-type
        and buf_cd-grp.obj-code = p-obj-code
        and buf_cd-grp.pos-type = {&cd-type-r-keeper}
        and buf_cd-grp.grp-type = '':U  :
      if not can-find(first temp-menu no-lock where
                           temp-menu.sifr = buf_cd-grp.grp-code
                       AND temp-menu.treetype = "T":U)  then do:
        for each buf_fbr-gds-grp where
                buf_fbr-gds-grp.obj-type = p-obj-type
            AND buf_fbr-gds-grp.obj-code = p-obj-code
            and buf_fbr-gds-grp.out-code = buf_cd-grp.grp-code
        on error undo _main, return error return-value :
          assign
          buf_fbr-gds-grp.out-code = 0
          .
        end.
        delete buf_cd-grp .
      end.
    end.
  end.

end procedure. /* save-goods */


procedure save-modifiers :
define variable v-mode as character no-undo .
define variable v-update-name as logical no-undo .
define variable v-update-modificator as logical no-undo .
define variable v-deleted    as logical   no-undo .
define variable v-price      as decimal  no-undo .
define variable v-price-sale as decimal   no-undo .
define variable v-gds-name   as character no-undo .
define variable v-doc-num    as character no-undo .
define variable v-modif      as logical no-undo .
define variable v-null-price as logical no-undo .

define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-doc-line for ub.cd-plu.
define buffer buf_goods for ub.goods.


  _main:
  do
  on error undo, return error return-value
  :
    _temp-modify:
    for each temp-modify no-lock:
      if temp-modify.parent = 0 then next _temp-modify.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранение полученных данных: обработано записей &1", ll-loc)).
      assign
      v-mode = "":U.
      find first buf_cd-plu where
                buf_cd-plu.obj-type = p-obj-type
            and buf_cd-plu.obj-code = p-obj-code
            and buf_cd-plu.pos-type = {&cd-type-r-keeper}
            and buf_cd-plu.plu-type = 'modifier':U
            and buf_cd-plu.plu-code = temp-modify.sifr no-error.
      if not available buf_cd-plu then do:
        assign
        v-mode = {&add-def}
        v-update-name = no
        v-update-modificator = no
        .
      end.
      else do:
        if buf_cd-plu.b-code <> 0 then do:
          assign
          v-gds-name   = get-rkgTH-name(shop-type, shop-code, buf_cd-plu.b-code, buffer buf_goods)
          v-modif      = get-rkgTH-modificator(shop-type, shop-code, buf_cd-plu.b-code, output v-null-price)
          .
          assign
          v-update-name =  (temp-modify.name <> v-gds-name)
          v-update-modificator  =  ( not v-modif OR not v-null-price)
          .
        end.

        if (buf_cd-plu.charkey_one <> temp-modify.name)
        or (buf_cd-plu.to-send <>  temp-modify.del)
        or (buf_cd-plu.to-del <>  (not temp-modify.del))
        or v-update-name
        or v-update-modificator
        then do:
          /*todo*/
          assign
          v-mode = {&update}
          .
          /*взведем флаг что надо связать*/
        end.
      end. /*available */
      if v-mode <> "":U then do:
        run update-product in this-procedure (
                                                 input v-mode
                                                ,input v-update-name
                                                ,input no /*v-update-price*/
                                                ,input no /*v-update-group*/
                                                ,input v-update-modificator
                                                ,input - temp-modify.sifr
                                                ,input 0
                                                ,input temp-modify.name
                                                ,input "M":U
                                                ,input temp-modify.realprice
                                                ,input 0
                                                ,input temp-modify.del
                                                )
        no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при сохранении записи модификатора с id&1 &2:&3&4 &5"
                                    , temp-modify.sifr
                                    , temp-modify.name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
          undo _temp-modify, next _temp-modify.
        end.
      end.
    end. /*for each */
    /*удалим ненужные продукты*/
    for each buf_cd-plu :
      if not buf_cd-plu.charkey_two= "M":U then next. /*это немодификаторы*/
      if not can-find(first temp-modify no-lock where
                           temp-modify.sifr = buf_cd-plu.plu-code
                                                   ) then do:
        delete buf_cd-plu .
      end.
    end.
  end.

end procedure. /* save-goods */



procedure save-clients :
define variable v-mode as character no-undo .

define variable v-deleted    as logical   no-undo .
define buffer buf_cd-clu for ub.cd-clu.
  _main:
  do
  on error undo, return error return-value
  :
    _temp-personal:
    for each temp-personal no-lock:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранение полученных данных: обработано записей &1", ll-loc)).
      assign
      v-mode = "":U.
        find first buf_cd-clu no-lock where
                  buf_cd-clu.obj-type = p-obj-type
              and buf_cd-clu.obj-code = p-obj-code
              and buf_cd-clu.pos-type = {&cd-type-r-keeper}
              and buf_cd-clu.clu-type = temp-personal.type
              and buf_cd-clu.clu-code = temp-personal.sifr no-error.
      if not available buf_cd-clu then do:
        assign
        v-mode = {&add-def}.
      end.
      else do:
        if (buf_cd-clu.charkey_one <> temp-personal.name)
        or buf_cd-clu.to-send <>  temp-personal.del
        or buf_cd-clu.to-del <>  (not temp-personal.del)
        then do:
          /*todo*/
          assign
          v-mode = {&update}.
          /*взведем флаг что надо связать*/
        end.
      end. /*available */
      if v-mode <> "":U then do:
        run update-clients in this-procedure (
                                                 input v-mode
                                                ,input temp-personal.sifr
                                                ,input temp-personal.name
                                                ,input temp-personal.type
                                                ,input temp-personal.del
                                                )
        no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при сохранении записи персонала с id &1 &2:&3&4 &5"
                                    , temp-personal.sifr
                                    , temp-personal.name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
          undo _temp-personal, next _temp-personal.
        end.
      end.
    end. /*for each */
    /*удалим ненужные клиенты*/
    for each buf_cd-clu :
      if not can-find(first temp-personal no-lock where
                           temp-personal.sifr = buf_cd-clu.clu-code) then do:
        delete buf_cd-clu .
      end.
    end.
  end. /*doe*/
end procedure. /* save-clients */



procedure update-product :
define input parameter p-mode     as character no-undo .
define input parameter p-update-name as logical no-undo .
define input parameter p-update-price as logical no-undo .
define input parameter p-update-group as logical no-undo .
define input parameter p-update-modificator as logical no-undo .
define input parameter p-sifr     as integer no-undo .
define input parameter p-code-chr as character no-undo .
define input parameter p-name     as character no-undo .
define input parameter p-treetype as character no-undo .
define input parameter p-price    as decimal no-undo .
define input parameter p-parent   as integer no-undo .
define input parameter p-del      as logical no-undo .

define variable v-old-treetype as character no-undo .
define variable v-old-parent   as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-b-code     as integer   no-undo .
define variable v-doc-num    as character no-undo .
define variable v-price-sale as decimal   no-undo .
define variable v-road-tax   as decimal   no-undo .
define variable v-excise     as decimal   no-undo .
define variable v-vat-pc     as decimal   no-undo .
define variable v-slt-pc     as decimal   no-undo .
define variable v-line-num as integer no-undo .

define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-doc-line for ub.cd-doc-line.
define buffer buf_cd-doc for ub.cd-doc.
define buffer buf_goods for ub.goods.

/*таблица товаров cd-plu что пишем из R-keeper из TH*/
/*
charkey_one                   название блюда
b-code                      b-code для товара - можно шкальный можно неосновной
plu-code                            идентификатор sifr
logkey_four               нужно обновлять признак модификатор или признак нулевой цены
key#_two             код группы меню
charkey_two               тип товар  или модификатор
logkey_one                нужно обновлять название
v-logkey_two                нужно обновлять цену
v-logkey_three             нужно обновлять группу
v-key#_one                    код в меню
to-del to-send_                       статус у или д
*/


/*таблица цен*/
/*шапка cd-doc doc-type = {&overvalue}*/
/*
obj-code       объект
obj-type        объект
pos-type  {&cd-type-r-keeper}
doc-type {&overvalue}
doc-code p-file-num
to-send
to-del

*/

/*строки цен cd-doc-line*/
/*
obj-code       объект
obj-type        объект
pos-type  {&cd-type-r-keeper}
plu-code               идентификатор блюда
deckey_one              цена
doc-type {&overvalue}
doc-code            привязка к шапке = номер закачки get-price-id-from-int
to-del to-send                  статус у или д
datekey_one -today
*/


define buffer buf_cd-grp        for ub.cd-grp.
  _main:
  do
  on error undo, return error return-value
  :
    if p-mode = {&add-def} then do:
      create buf_cd-plu.
      assign
      buf_cd-plu.obj-type    = p-obj-type
      buf_cd-plu.obj-code    = p-obj-code
      buf_cd-plu.pos-type    = {&cd-type-r-keeper}
      buf_cd-plu.plu-type    = (if p-sifr > 0 then '':U else 'modifier')
      buf_cd-plu.plu-code    = abs(p-sifr)
      .
    end.
    else do:
      find first buf_cd-plu exclusive-lock where
              buf_cd-plu.obj-type    = p-obj-type
          and buf_cd-plu.obj-code    = p-obj-code
          and buf_cd-plu.pos-type    = {&cd-type-r-keeper}
          and buf_cd-plu.plu-type    = (if p-sifr > 0 then '':U else 'modifier')
          and buf_cd-plu.plu-code = abs(p-sifr) no-error.
      if not available buf_cd-plu then do:
        return error substitute("не найдена или занята запись товара/группы для кассы R-KEEPER с id = &1"
                              ,p-sifr).
      end.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    buf_cd-plu.charkey_one = p-name
    buf_cd-plu.key#_one = integer(p-code-chr)
    buf_cd-plu.to-del   =  not p-del
    buf_cd-plu.to-send   =  p-del
    buf_cd-plu.key#_two = p-parent
    buf_cd-plu.charkey_two = p-treetype
    buf_cd-plu.logkey_one = p-update-name
    buf_cd-plu.logkey_two = p-update-price
    buf_cd-plu.logkey_three = p-update-group
    buf_cd-plu.logkey_four = p-update-modificator
    .
    /*запишем цену и при неоходимости создадим документ цен*/
    if not (p-treetype = "M":U and p-price = 0) then do:
      find first buf_cd-doc no-lock where
                buf_cd-doc.obj-type = p-obj-type
            and buf_cd-doc.obj-code = p-obj-code
            and buf_cd-doc.pos-type = {&cd-type-r-keeper}
            and buf_cd-doc.doc-type = {&overvalue}
            and buf_cd-doc.doc-code = string(p-file-num)   no-error .
      if not available buf_cd-doc then do:
        run cur-time in this-procedure( output v-today, output v-time).
        create buf_cd-doc.
        assign
        buf_cd-doc.doc-type = {&overvalue}
        buf_cd-doc.pos-type = {&cd-type-r-keeper}
        buf_cd-doc.doc-code = string(p-file-num)
        buf_cd-doc.obj-type = p-obj-type
        buf_cd-doc.obj-code = p-obj-code
        buf_cd-doc.datekey_one = v-today
        .
      end.
      find first buf_cd-doc-line no-lock where
              buf_cd-doc-line.obj-type = p-obj-type
          and buf_cd-doc-line.obj-code = p-obj-code
          and buf_cd-doc-line.pos-type = {&cd-type-r-keeper}
          and buf_cd-doc-line.doc-type = {&overvalue}
          and buf_cd-doc-line.doc-code = string(p-file-num)
          and buf_cd-doc-line.plu-type = '':U
          and buf_cd-doc-line.plu-code = p-sifr no-error.
      if not available buf_cd-doc-line then do:
        find last buf_cd-doc-line no-lock where
                buf_cd-doc-line.obj-type = p-obj-type
            and buf_cd-doc-line.obj-code = p-obj-code
            and buf_cd-doc-line.pos-type = {&cd-type-r-keeper}
            and buf_cd-doc-line.doc-type = {&overvalue}
            and buf_cd-doc-line.doc-code = string(p-file-num)
            and buf_cd-doc-line.plu-type = '':U no-error.
        if not available buf_cd-doc-line then do:
          v-line-num = 1.
        end.
        else do:
          assign
          v-line-num = buf_cd-doc-line.line-num  + 1.
        end.

        define variable v-price-id as character no-undo .
        create buf_cd-doc-line.
        assign
        buf_cd-doc-line.obj-type = p-obj-type
        buf_cd-doc-line.obj-code = p-obj-code
        buf_cd-doc-line.pos-type = {&cd-type-r-keeper}
        buf_cd-doc-line.plu-code = p-sifr
        buf_cd-doc-line.plu-type = '':U
        buf_cd-doc-line.deckey_one = p-price
        buf_cd-doc-line.doc-type = {&overvalue}
        buf_cd-doc-line.doc-code = string(p-file-num)
        buf_cd-doc-line.to-del  = (not p-del)
        buf_cd-doc-line.to-send  = p-del
        buf_cd-doc-line.line-num = v-line-num
        .
      end.
    end.
    if p-mode = {&add-def}
    or buf_cd-plu.b-code  = 0 then do:
       /*сообщим в log что есть неизвестный товар*/
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3> - не сопоставлен товар в системе IBS TH"
                                , p-sifr
                                , p-code-chr
                                , p-name
                              )
                                              ).
      assign
      p-view-log = yes
      .
    end.
    /*старый товар*/
    if buf_cd-plu.b-code > 0 then do:
      /*найдем корневой бар-код */
      { gbl/gdsbcode.i buf_cd-plu.b-code ? v-b-code }
      /*найдем цену*/
      { gbl/bcprcex.i p-obj-type p-obj-code v-b-code 0 0 v-doc-num v-price-sale v-road-tax v-excise v-vat-pc v-slt-pc }
  /*    if v-price-sale <> p-price and not (p-treetype = "M" and p-price = 0) then do:
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_cd-plu.b-code.
        /*сообщим в log что есть несовпадение цены*/
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Блюдо меню/модификатор id &1 код в меню &2 &3 имеет цену на кассе R-KEEPER &4&5" +
                                  "соответствующий ему товар в IBS TH &6 имеет другую цену &7"
                                  , p-sifr
                                  , p-code-chr
                                  , p-name
                                  , p-price
                                  , {&new-line}
                                  , buf_cd-plu.b-code
                                  , v-price-sale
                                )
                                                ).
        assign
        p-view-log = yes
        .

      end.       */
    end.
    lll = lll + 1 .
    ll-loc = ll-loc + 1.
    release buf_cd-plu no-error .
    if error-status:error then undo _main, return error return-value .
    release buf_cd-doc-line no-error .
    if error-status:error then undo _main, return error return-value .
  end.

end procedure. /* update-product */



procedure update-country :
define input parameter p-mode as character no-undo .
define input parameter p-update-name as logical no-undo .
define input parameter p-update-parent as logical no-undo .
define input parameter p-sifr as integer no-undo .
define input parameter p-name  as character no-undo .
define input parameter p-parent as integer no-undo .
define input parameter p-del   as logical no-undo .
define input parameter p-lvl-num as integer no-undo .

define buffer buf_cd-grp for ub.cd-grp.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.

/*группы меню храним в cd-grp*/
/*
grp-code          идентификатор группы - общее пространство с идентификаторов блюд
grp-name        название группы
upper-grp-code    код вышестоящей
to-del to-send     статус у или д
key#_one = уровень
logkey_one  p-update-name
logkey_two  p-update-parent

*/

  _main:
  do
  on error undo, return error return-value
  :
    if p-mode = {&add-def} then do:
      create buf_cd-grp.
      assign
      buf_cd-grp.obj-type = p-obj-type
      buf_cd-grp.obj-code = p-obj-code
      buf_cd-grp.pos-type = {&cd-type-r-keeper}
      buf_cd-grp.grp-type = '':U
      .
    end.
    else do:
      find first buf_cd-grp exclusive-lock where
                buf_cd-grp.obj-type = p-obj-type
            and buf_cd-grp.obj-code = p-obj-code
            and buf_cd-grp.pos-type = {&cd-type-r-keeper}
            and buf_cd-grp.grp-type = '':U
            and buf_cd-grp.grp-code = p-sifr no-error.
      if not available buf_cd-grp then do:
        return error substitute("не найдена или занята запись группы для кассы R-KEEPER с id &1"
                              ,p-sifr
                              ).
      end.
    end.
    assign
    buf_cd-grp.grp-code = p-sifr
    buf_cd-grp.upper-grp-code = p-parent
    buf_cd-grp.grp-name = p-name
    buf_cd-grp.to-del = not p-del
    buf_cd-grp.to-send = p-del
    buf_cd-grp.logkey_one = p-update-name
    buf_cd-grp.logkey_two = p-update-parent
    buf_cd-grp.key#_one = p-lvl-num
    .
    lll = lll + 1 .
    ll-loc = ll-loc + 1.
    if p-mode = {&add-def}
    or not can-find(first buf_fbr-gds-grp no-lock where
                         buf_fbr-gds-grp.obj-type = p-obj-type
                     AND buf_fbr-gds-grp.obj-code = p-obj-code
                     AND buf_fbr-gds-grp.out-code = p-sifr ) then do:
       /*сообщим в log что есть неизвестный товар*/
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Группа блюд меню кассе R-KEEPER с id &1 <&2> - не сопоставлена группа блюд на &3&4 в системе IBS TH"
                                , p-sifr
                                , p-name
                                , p-obj-type
                                , p-obj-code
                              )    ).
      assign
      p-view-log = yes
      .
    end.
    release buf_cd-grp no-error .
    if error-status:error then undo _main, return error return-value .
 end. /*doe*/

end procedure. /* update-country */


procedure update-clients :
define input parameter p-mode as character no-undo .
define input parameter p-sifr as integer no-undo .
define input parameter p-name  as character no-undo .
define input parameter p-type  as character no-undo .
define input parameter p-del   as logical no-undo .

define buffer buf_cd-clu        for ub.cd-clu.
/*таблица  cd-clu */
/*
clu-code                  код персонала в r-keeper
charkey_one                 им
cli-code             если есть - то привязка к челу в TH
cli-type             тип персонала бармен менеджер и т.д. - используем это поле потому что у нас только челы
to-del_              статус у
to-send              статус  и
clu-type             должность
*/


  _main:
  do
  on error undo, return error return-value
  :
    if p-mode = {&add-def} then do:
      create buf_cd-clu.
      assign
      buf_cd-clu.obj-type = p-obj-type
      buf_cd-clu.obj-code = p-obj-code
      buf_cd-clu.pos-type = {&cd-type-r-keeper}
      buf_cd-clu.clu-type = p-type
      buf_cd-clu.clu-code = p-sifr
      /*buf_cd-clu.obj-code = ?*/
      .
    end.
    else do:
      find first buf_cd-clu exclusive-lock where
                buf_cd-clu.obj-type = p-obj-type
            and buf_cd-clu.obj-code = p-obj-code
            and buf_cd-clu.pos-type = {&cd-type-r-keeper}
            and buf_cd-clu.clu-type = p-type
            and buf_cd-clu.clu-code = p-sifr no-error.
      if not available buf_cd-clu then do:
        return error substitute("не найдена или занята запись персонала с id = &1 для кассы R-KEEPER "
                              ,p-sifr).
      end.
    end.
    assign
    buf_cd-clu.cli-type = {&prs}
    buf_cd-clu.charkey_one = p-name
    buf_cd-clu.to-send = (p-del = yes)
    buf_cd-clu.to-del = (p-del = no)
    .
    if buf_cd-clu.cli-code = ? then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!на кассе R-KEEPER &3 с id &1 <&2> - не сопоставлен сотрудник в системе IBS TH"
                                , p-sifr
                                , p-name
                                , entry(lookup(p-type, "W,M,K,B":U), "Официант,Менеджер,Кассир,Бармен")
                              )    ).
      assign
      p-view-log = yes
      .
    end.
    lll = lll + 1 .
    ll-loc = ll-loc + 1.
    release buf_cd-clu no-error .
    if error-status:error then undo _main, return error return-value .
 end. /*doe*/

end procedure. /* update-clients */

procedure get-checks :
define variable v-create-write-off as logical no-undo .
define variable v-create-return as logical no-undo .
define variable v-gds-create-write-off as logical no-undo .
define variable v-gds-create-return as logical no-undo .
define variable chk-type2 as integer no-undo .
define variable chk-sign as integer no-undo .
define variable chk-sign2 as integer no-undo .
define variable gds-sign as integer no-undo .
define variable gds-sign2 as integer no-undo .
define variable gds-wo-type as integer no-undo .
define variable gds-wo-type2 as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable prev-code2 as character no-undo .

define buffer buf_cd-plu for ub.cd-plu.
/*количества и скидки имеют одинаковые знаки и для продажи и для возврата -
направление операции определяется полем */

  do
  on error undo, return error
  :
    /*сначала разметим удаленные строки чеков*/
    /*сейчас это сделаем чтобы охватить все чеки а не только те которые ЕЩЕ не закачали*/
    for each temp-acheck no-lock,
        each temp-avcheck where
            temp-avcheck.unit = temp-acheck.unit
        AND temp-avcheck.depart = temp-acheck.depart
        AND temp-avcheck.logicdate = temp-acheck.logicdate
          and temp-avcheck.del-time >= temp-acheck.start-time
          AND temp-avcheck.del-time <= temp-acheck.end-time
          AND temp-avcheck.sys_num = 0 :
      assign
      temp-avcheck.sys_num = temp-acheck.sys_num.
    end.

     _temp-acheck:
    for each temp-acheck no-lock:
      /*обнуление переменных*/
      assign
      chk-date_ = 01/01/1990
      chk-time_ = 0
      shift-date_ = chk-date_
      shift-num_ = 0
      shift-name_ = '':U
      shop-code = 0
      shop-type = "":U
      sales-man_ = 0
      v-flag-salesman  = no
      v-flag-card = no
      cashier_ = 0
      pay-desk_ = 0
      z-num_ = 0
      cash-rate_ = 0
      d-card_ = "":U
      d-mask_ = "":U
      cli-type_ = "":U
      cli-code_ = 0
      tot-d-pcnt = 0
      doc-num_ = "":U
      v-end-of-check = no
      for-chk-type = ""
      prev-code = "":U
      prev-code2 = "":U
      v-create-write-off = no
      v-create-return = no
      .
      assign
      shop-code = ( if get-chkc_context.hnum
                    then integer(temp-acheck.depart)
                    else p-obj-code )
      shop-type = ( if get-chkc_context.hnum then {&shop} else p-obj-type )
      no-error
      .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для чека &1 неверный(нецифровой) номер магазина &2" +
                                  "чек не будет сохранен и обработан"
                                  , temp-acheck.cnum
                                  , temp-acheck.depart
                                  , {&new-line}
                                )    ).
        assign
        p-view-log = yes
        .
        run save-for-future in this-procedure .
        next _temp-acheck.
      end.

      assign
      pay-desk_ =  integer(temp-acheck.unit)
      no-error
      .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для чека &1 неверный(нецифровой) номер кассы &2" +
                                  "чек не будет сохранен и обработан"
                                  , temp-acheck.cnum
                                  , temp-acheck.unit
                                  , {&new-line}
                                )    ).
        assign
        p-view-log = yes
        .
        run save-for-future in this-procedure .
        next _temp-acheck.
      end.
      if temp-achecK.deleted  <> 0 then do:
        find first temp-reasons no-lock where
                  temp-reasons.sifr = temp-acheck.deleted no-error.
        if not available temp-reasons then do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Для чека &1 кассы &2 не найдена причина отмены с идентификатором &3&4" +
                                    "чек не будет сохранен и обработан"
                                    , temp-acheck.cnum
                                    , temp-acheck.unit
                                    , temp-acheck.deleted
                                    , {&new-line}
                                  )    ).
          assign
          p-view-log = yes
          .
          run save-for-future in this-procedure .
          next _temp-acheck.
        end.
        if temp-reasons.used then do:
          assign
          chk-type_ = integer({&rcpt-sale})
          chk-sign  = 1
          v-create-write-off = yes
          chk-type2 = integer({&rcpt-return-write-off})
          chk-sign2  = - 1
          .
        end.
        else do:
          assign
          chk-type_ = integer({&rcpt-sale})
          chk-sign  = 1
          v-create-return = yes
          chk-type2 = integer({&rcpt-return})
          chk-sign2  = - 1
          .
        end.
      end.
      else do:
        assign
        chk-type_ = integer({&rcpt-sale})
        chk-sign  = 1
        .
      end.
&glob chk-sign (if ii = 1 then chk-sign else chk-sign2)
      assign
      sales-man_ = get-sales-man(temp-acheck.waiter, chk-date_)
      cashier_  = get-cashier(temp-acheck.cashier, chk-date_)
      no-error .
          /*  message sales-man_ skip cashier_. */
      /*if sales-man_ = ?
      or cashier_ = 0 then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!В чеке &1 кассы &2 указан кассир или официант,&3" +
                                  "для которого не задано соответствие в IBS TH&3" +
                                  "чек не будет сохранен и обработан"
                                  , temp-acheck.cnum
                                  , temp-acheck.unit
                                  , {&new-line}
                                )    ).
        assign
        p-view-log = yes
        .
        run save-for-future in this-procedure .
        undo _temp-acheck,  next _temp-acheck.
      end.*/
      _do:
      do ii = 1 to 2:
        FIND  ub.chk-doc where
              ub.chk-doc.obj-type = shop-type and
              ub.chk-doc.obj-code = shop-code and
              ub.chk-doc.chk-date = temp-acheck.realdate and
              ub.chk-doc.pay-desk = integer(temp-acheck.unit) and
              ub.chk-doc.chk-time = integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60 and
              ub.chk-doc.chk-num = temp-acheck.cnum and
              ub.chk-doc.sales-man = sales-man_
              NO-ERROR NO-WAIT.
        if (avail ub.chk-doc and ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2))
        or locked ub.chk-doc then do:
          if not v-create-return and not v-create-write-off then leave _do.
          else next _do.
        end.
        if ambiguous ub.chk-doc then do:
          FIND  ub.chk-doc where
                ub.chk-doc.obj-type = shop-type and
                ub.chk-doc.obj-code = shop-code and
                ub.chk-doc.chk-date = temp-acheck.realdate and
                ub.chk-doc.pay-desk = integer(temp-acheck.unit) and
                ub.chk-doc.chk-time = integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60 and
                ub.chk-doc.chk-num = temp-acheck.cnum and
                ub.chk-doc.sales-man = sales-man_ and
                ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2)
                NO-ERROR NO-WAIT.
          if (avail ub.chk-doc and ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2))
          or locked ub.chk-doc
          or ambiguous ub.chk-doc then do:
            if not v-create-return and not v-create-write-off then leave _do.
            else next _do.
          end.
        end.
        assign
        exist = no
        cr = 0
        lll = lll + 1
        .
        create ub.chk-doc.
        assign
        lng = 0
        lnp = 0
        sub-d = 0
        var-discnt-id = 0
        lng-sub-d = 0
        netto-for-sub-d = 0
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.office = ?
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                              then string(next-value(s-chk, {&db-name_schema} ))
                              else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
        ub.chk-doc.chk-num = temp-acheck.cnum
        ub.chk-doc.chk-date = temp-acheck.realdate
        ub.chk-doc.chk-time = integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-d-card = "":U
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.src-shift-date = temp-acheck.logicdate
        ub.chk-doc.shift-num = 0
        ub.chk-doc.shift-name = '':U
        ub.chk-doc.src-shift-name = '':U
        ub.chk-doc.cash-rate = temp-acheck.basekurs
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = 0
        ub.chk-doc.doc-num = "Стол-" + string(temp-acheck.table_) + {&space-char} + "Персон-" + string(temp-acheck.cover)
        ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2)
        ub.chk-doc.correct = yes
        brutto-sum_ = {&chk-sign} * temp-acheck.total
        no-error
        .
        if error-status:error then do:
          ub.chk-doc.correct = no.
        end.
        if ii = 1
        then
        prev-code = ub.chk-doc.doc-code.
        if ii = 2
        then
        prev-code2 = ub.chk-doc.doc-code.
        for each temp-archeck no-lock where
                temp-archeck.sys_num = temp-acheck.sys_num:
           { str/get-rkep.i temp-archeck }
        end. /*for each temp-archeck*/
        /*теперь они хотя каждое удаленное блюдо отдельным чеком!!!!!*/
        /*но я пока этого не могу!!!!!!!!!*/
        for each temp-avcheck where
                temp-avcheck.sys_num = temp-acheck.sys_num:
           { str/get-rkep.i temp-avcheck }
        end.
        for each temp-adcheck no-lock where
            temp-adcheck.sys_num = temp-acheck.sys_num:
          find first tt-dis-rule-r-keeper no-lock where
                    tt-dis-rule-r-keeper.r-keeper-rule-num = temp-adcheck.sifr no-error.
          if not available tt-dis-rule-r-keeper then  do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Для чека &1 кассы &2 не найдено соответствующее правило скидки для скидки с идентификатором &3&4" +
                                      "чек не будет сохранен и обработан"
                                      , temp-acheck.cnum
                                      , temp-acheck.unit
                                      , temp-adcheck.sifr
                                      , {&new-line}
                                    )    ).
            assign
            p-view-log = yes
            .
            run save-for-future in this-procedure .
            undo _temp-acheck,  next _temp-acheck.
          end.
          if tt-dis-rule-r-keeper.discnt-type = integer({&discnt-sub-total})
          or tt-dis-rule-r-keeper.discnt-type = integer({&discnt-total})
          or tt-dis-rule-r-keeper.discnt-type = integer({&discnt-receipt})
          or tt-dis-rule-r-keeper.discnt-type = integer({&discnt-payment}) then do:
            sub-d = sub-d + {&chk-sign} * (- temp-adcheck.sum).
          end.
          create ub.chk-discnt.
          assign
          ub.chk-discnt.doc-code = ub.chk-doc.doc-code
          ub.chk-discnt.record-type = 0
          ub.chk-discnt.discnt-id = (var-discnt-id + 1)
          ub.chk-discnt.line-num = lng
          ub.chk-discnt.time-oper = ub.chk-doc.chk-time
          ub.chk-discnt.line-type = tt-dis-rule-r-keeper.subject-type
          ub.chk-discnt.line-sign =  (if temp-adcheck.sum <= 0 then  yes else no)
          ub.chk-discnt.pass-discnt = if temp-adcheck.person = 0 then integer({&discnt-p-auto}) else integer({&discnt-p-manual})
          ub.chk-discnt.value-type = tt-dis-rule-r-keeper.value-type
          ub.chk-discnt.discnt-type = tt-dis-rule-r-keeper.discnt-type
          ub.chk-discnt.src-d-card = string(temp-adcheck.CARDCOD)
          ub.chk-discnt.d-card = "":U
          ub.chk-doc.src-d-card = (if temp-adcheck.cardcod <> 0 then string(temp-adcheck.CARDCOD) else ub.chk-doc.src-d-card)
          ub.chk-discnt.discnt-value-abs = {&chk-sign} * - temp-adcheck.sum
          ub.chk-discnt.object-qnty = {&chk-sign} * ub.chk-doc.doc-qnty
          ub.chk-discnt.object-sum = {&chk-sign} * netto-for-sub-d
          ub.chk-discnt.discnt-value-pcnt = (if ub.chk-discnt.object-sum = 0 then 0 else {&chk-sign} * (- temp-adcheck.sum)  / ub.chk-discnt.object-sum  * 100)
          ub.chk-discnt.object-line-num = 0
          ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
          ub.chk-discnt.obj-code = ub.chk-doc.obj-code
          ub.chk-discnt.obj-type = ub.chk-doc.obj-type
          ub.chk-discnt.chk-date = ub.chk-doc.chk-date
          ub.chk-discnt.chk-time = ub.chk-doc.chk-time
          var-discnt-id = var-discnt-id + 1
          netto-for-sub-d = netto-for-sub-d - (- temp-adcheck.sum)
          .
        END.  /*for each temp-adcheck*/
        for each temp-apcheck no-lock where
                temp-apcheck.sys_num = temp-acheck.sys_num:
          assign
          curr_code = 0
          pay_code = convert-cash-pay ( input temp-apcheck.currency, output curr_code)
          .
          CREATE ub.chk-pay .
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-type = ub.chk-doc.obj-type
          ub.chk-pay.obj-code = ub.chk-doc.obj-code
          ub.chk-pay.tot-rubl = 0
          ub.chk-pay.tot-sum = {&chk-sign} * temp-apcheck.origsum
          ub.chk-pay.tot-base = 0
          ub.chk-pay.pay-code = pay_code
          ub.chk-pay.curr-code = curr_code
          ub.chk-pay.time-oper = ub.chk-doc.chk-time
          ub.chk-pay.cash-rate = temp-apcheck.kurs
          ub.chk-pay.line-type = "":U

          ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                              then (chk-pay.tot-sum >= 0)
                              else (chk-pay.tot-sum <= 0)
                              )
          ub.chk-pay.is-error = no
          .
          if temp-apcheck.discount <> 0 then do:
            create ub.chk-discnt.
            assign
            ub.chk-discnt.doc-code = ub.chk-doc.doc-code
            ub.chk-discnt.record-type = 0
            ub.chk-discnt.discnt-id = (var-discnt-id + 1)
            ub.chk-discnt.line-num = lng
            ub.chk-discnt.time-oper = ub.chk-doc.chk-time
            ub.chk-discnt.line-type = integer({&discnt-payment})
            ub.chk-discnt.pass-discnt = integer({&discnt-p-auto})
            ub.chk-discnt.value-type = integer({&discnt-v-pcnt})
            ub.chk-discnt.discnt-type = integer({&discnt-t-unknown})
            ub.chk-discnt.src-d-card = chk-gds.src-d-card
            ub.chk-discnt.d-card = chk-gds.d-card
            ub.chk-discnt.discnt-value-pcnt = temp-apcheck.discount  * 100
            ub.chk-discnt.discnt-value-abs = {&chk-sign} * (temp-apcheck.basesumeqw  * temp-apcheck.discount) / (1 - temp-apcheck.discount)
            ub.chk-discnt.line-sign =  (if temp-apcheck.discount >= 0 then  yes else no)
            ub.chk-discnt.object-qnty = {&chk-sign} * ub.chk-doc.doc-qnty
            ub.chk-discnt.object-sum = {&chk-sign} * netto-for-sub-d
            ub.chk-discnt.object-line-num = 0
            ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
            ub.chk-discnt.obj-code = ub.chk-doc.obj-code
            ub.chk-discnt.obj-type = ub.chk-doc.obj-type
            ub.chk-discnt.chk-date = ub.chk-doc.chk-date
            ub.chk-discnt.chk-time = ub.chk-doc.chk-time
            var-discnt-id = var-discnt-id + 1
            sub-d = sub-d + {&chk-sign} * ub.chk-discnt.discnt-value-abs
            netto-for-sub-d = netto-for-sub-d - {&chk-sign} * ub.chk-discnt.discnt-value-abs
            ub.chk-pay.tot-sum = ub.chk-pay.tot-sum - ub.chk-discnt.discnt-value-abs
            .
          end.
        end. /*for each temp-archeck*/
        if ii = 1 then do:
          get-chkc_context.ll = lll.
          { str/libchkvl_getcheck.i
            "buffer get-chkc_context:handle"
            ~{&add-def~}
            ''
            yes
            yes
            ?
            lng-sub-d
            sub-d
            var-discnt-id
            prev-code
            no-error
          }
          assign
          p-view-log = (p-view-log or get-chkc_context.view-log)
          lll = get-chkc_context.ll
          .
        end.
        if not v-create-return and not v-create-write-off then leave _do.
        if ii = 2 then do:
          get-chkc_context.ll = lll.
          { str/libchkvl_getcheck.i
            "buffer get-chkc_context:handle"
            ~{&add-def~}
            ''
            yes
            yes
            ?
            lng-sub-d
            sub-d
            var-discnt-id
            prev-code2
            no-error
          }
          assign
          p-view-log = (p-view-log or get-chkc_context.view-log)
          lll = get-chkc_context.ll
          .
        end.
      end. /*do ii */
     end. /*for each temp-acheck*/
  end. /*doe*/

end procedure. /* get-checks */


procedure save-for-future :
  do
  on error undo, return error
  :
    assign
    v-session-status_ = "U".
  end.

end procedure. /* save-for-future */