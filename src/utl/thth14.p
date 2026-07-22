block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: thth14.p $
$Archive: utl/thth14.p $

Запуск пакета утилита THTH - 16.0 и 14

Автор: Чернова Светлана Александровна
Дата создания: 01/19/10
Author: Svetlana Chernova
Creation date: 01/19/10

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: thth14.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/thth14.p $":U .
define variable vss-description as character no-undo init "Запуск пакета утилита THTH - 16.0 и 14".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/thth14.i }

define variable v-operations as character no-undo .
define variable v-operation-codes as character no-undo .
define variable v-selected-operation as character no-undo .
define variable v-operation-name as character no-undo .
define variable v-run-file-name as character no-undo .
define variable v-can-init as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
define variable v-is-debug as logical no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-mess as character no-undo .
define variable v-log as logical no-undo .
define variable v-attr-query-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-jj as integer no-undo .
define variable v-exist as logical no-undo .
/*
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к 14 БД TH&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value )
  view-as alert-box error .
  return error .
end.
*/
v-is-debug = no.

assign
v-operations = "":U
v-operation-codes = "":U
v-selected-operation = "start"
.
assign
v-operations =
              "Инициация переноса объекта" + {&delim-par} +
              "Соответствие клиентов" + {&delim-par} +
              "Соответствие товаров" + {&delim-par} +
              "Соответствие объектов" + {&delim-par} +
              "Импорт переоценок" + {&delim-par} +
              "Закрытие ДНЦ" + {&delim-par} +
              "Импорт приходных накладных" + {&delim-par} +
              "Импорт лок. данных - ЗАПУСКАЕТСЯ В УБД - если объект принадлежит УБД" + {&delim-par} +
              "Отчет"

v-operation-codes  =  "ini" + {&delim-par} +
                      {&table_clients} + {&delim-par} +
                      {&table_goods} + {&delim-par} +
                      {&table_shop} + {&delim-par} +
                      {&table_price-doc} + {&delim-par} +
                      "close-pdf" + {&delim-par} +
                      {&table_trn-doc} + {&delim-par} +
                      "impxexpi" + {&delim-par} +
                      "rep"
.


&scop do-checking ~
      do v-jj = 1 to num-entries(v-attr-query-list, ~{&delim-par~}): ~
        v-value = ''. ~
        run thth14-db-attr-value in this-procedure ( input 0 ~
                                                  ,input entry(v-jj, v-attr-query-list, ~{&delim-par~}) ~
                                                  ,output v-value ~
                                                  ,output v-type) no-error. ~
        assign ~
        v-log = logical(v-value) ~
        no-error . ~
        if v-log = logical(entry(v-jj, v-value-list, ~{&delim-par~})) then do: ~
          if v-is-debug then do: ~
            message ~
            entry(v-jj, v-mess, {&delim-par} ) ~
            view-as alert-box warning. ~
          end. ~
          else do: ~
            message  ~
            v-mess     ~
            view-as alert-box error. ~
            next _leave. ~
          end.            ~
        end. ~
      end



_leave:
do while v-selected-operation <> ""
on error undo, leave _leave
on stop undo, leave _leave
on end-key undo, leave _leave
:
  run gbl/d-list.w (
                INPUT "b-sel":U
                ,INPUT "Выберите операцию по сведению систем 16.0 и 14"
                ,INPUT v-operation-codes
                ,INPUT v-operations
                ,INPUT {&delim-par}
                ,INPUT "":U
                ,output v-selected-operation).
  IF v-selected-operation = "":u THEN do:
    leave _leave.
  end.
  assign
  v-operation-name = entry(lookup(v-selected-operation, v-operation-codes, {&delim-par}) , v-operations, {&delim-par})
  .
  case v-selected-operation:
    when "" then do:
      leave _leave.
    end.
    when "ini" then do:
      /*здесь можно работать только если все атрибуты yes или их НЕТ ВООЩЕ*/
      assign
      v-value-list = ''
      v-attr-query-list = {&attr-thth14-clients} + {&delim-par} + {&attr-thth14-goods} + {&delim-par} + {&attr-thth14-shop}
      .
      do v-jj = 1 to num-entries(v-attr-query-list, {&delim-par} ):
        v-exist = no.
        v-value = string(yes).
        run thth14-db-attr-exist in this-procedure ( input 0
                                                 ,input entry(v-jj, v-attr-query-list, {&delim-par} )
                                                 ,output v-exist).
        if v-exist then do:
          run thth14-db-attr-value in this-procedure ( input 0
                                                    ,input entry(v-jj, v-attr-query-list, {&delim-par})
                                                    ,output v-value
                                                    ,output v-type) no-error.
        end.
        v-value-list = v-value-list + (if v-value-list = '' then '' else {&delim-par} ) + v-value.
      end. /*do v-jj = 1 to num-entries(v-attr-query-list, {&delim-par} ):*/
      if lookup(string(no), v-value-list, {&delim-par} ) > 0 then do:
        message
        "Начат но не закончен этап сведения v14 и v16.0"
        view-as alert-box error .
      end.
      else do:
          /*обнулим все атрибуты*/
        do v-jj = 1 to num-entries(v-attr-query-list, {&delim-par} ):
          run thth14-db-attr-write in this-procedure ( input 0
                                                    ,input entry(v-jj, v-attr-query-list, {&delim-par})
                                                    ,input string(no)
                                                    ) no-error.
        end.
      end.
    end. /*when "ini" then do:*/
    when {&table_goods} then do:
      assign
      v-attr-query-list = {&attr-thth14-clients}
      v-value-list = "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД"
      .
      {&do-checking}.
      run utl/thth-gds.w ( input parparentproc
                           ,input (if g#db-num = 0 then "b-add" else "")
                           ,input {&thth14-from-version}
                           ,input '' /*p-list-mode*/
                           ,input-output v-rid-list) no-error.
    end.
    when {&table_clients} then do:
      run utl/thth-cli.w ( input parparentproc
                           ,input (if g#db-num = 0 then "b-add" else "")
                           ,input {&thth14-from-version}
                           ,input '' /*p-list-mode*/
                           ,input-output v-rid-list) no-error.
    end.
    when "impxexpi" then do:
      assign
      v-attr-query-list = {&attr-thth14-shop} + {&delim-par} +
                          {&attr-thth14-clients} + {&delim-par} +
                          {&attr-thth14-goods}
      v-value-list = "no" + {&delim-par} +
                     "no" + {&delim-par} +
                     "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ОБЪЕКТАМИ В РАЗНЫХ БД" + {&delim-par} +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД" + {&delim-par}  +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ТОВАРАМИ В РАЗНЫХ БД"
      .
      {&do-checking}.
      run utl/expximp.w ( input parparentproc) no-error.
    end.
    when {&table_shop} then do:
      run utl/thth-cli.w ( input parparentproc
                      ,input (if g#db-num = 0 then "b-add" else "")
                      ,input {&thth14-from-version}
                      ,input {&g___object} /*p-list-mode*/
                      ,input-output v-rid-list) no-error.

    end.
    when {&table_price-doc} then do:
      assign
      v-attr-query-list = {&attr-thth14-shop} + {&delim-par} +
                          {&attr-thth14-clients} + {&delim-par} +
                          {&attr-thth14-goods}
      v-value-list = "no" + {&delim-par} +
                     "no" + {&delim-par} +
                     "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ОБЪЕКТАМИ В РАЗНЫХ БД" + {&delim-par} +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД" + {&delim-par}  +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ТОВАРАМИ В РАЗНЫХ БД"
      .
      {&do-checking}.

      run cmp/ththovr1.w ( input parparentproc ) no-error .
    end.
    when "close-pdf" then do:
      run utl/ththovr3.p ( input parparentproc ) no-error .
    end.

    when {&table_trn-doc} then do:
      assign
      v-attr-query-list = {&attr-thth14-shop} + {&delim-par} +
                          {&attr-thth14-clients} + {&delim-par} +
                          {&attr-thth14-goods}
      v-value-list = "no" + {&delim-par} +
                     "no" + {&delim-par} +
                     "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ОБЪЕКТАМИ В РАЗНЫХ БД" + {&delim-par} +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД" + {&delim-par}  +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ТОВАРАМИ В РАЗНЫХ БД"
      .
      {&do-checking}.
      run cmp/ththpri1.w ( input parparentproc ) no-error .
    end.
    when "rep" then do:
      run utl/ththrepr.p ( input parparentproc ) no-error.
    end.
    otherwise do:
      message
      "НЕВЕРНОЕ ЗНАЧЕНИЕ ВЫБОРА"
      view-as alert-box .
    end.
  end case.
  if error-status:error
  or return-value = "error"
  then do:
    message
    substitute("Ошибки при выполнении операции &1:&2" +
                "&3&2&4"
                , v-operation-name
                , {&new-line}
                , error-status:get-message(1)
                , return-value )
    view-as alert-box error .
  end.
end. /*_leave*/
if connected ("src") then do:
  disconnect src.
end.


/* Процедура колбек для закрытия накладных без проверки спецификации */
procedure cb_close-without-verify :
define output parameter p-no-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-no-ver = true .
  end.
end procedure. /* cb_close-without-verify */