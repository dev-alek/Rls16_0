/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=20;ruleset_id=4;-----------------
Импорт данных по группам товаров из XML файла

---------------------------&end-codex_id=20;ruleset_id=4;-----------------

*/

/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
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
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .



define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 20 набор правил 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ gbl/orapreps.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-node-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-esys-id as integer no-undo .
define variable v-extension as character no-undo .
define variable v-last-rec-ord as integer no-undo .
define variable v-err-type as character no-undo .
define variable v-pck-num as integer no-undo .

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define buffer buf_temp-xml-tables for temp-xml-tables.


function 00200004_get-error-message returns character :
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

function 00200004_after-import_f returns logical ( input p-d-card as character):
  run 00200004_after-import in this-procedure ( input p-d-card) no-error.
  run set-error in this-procedure ( input return-value ).
  return not (error-status:error).
end function.



&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)



/*---------------------------&start-rule-call-param&-------------------------------*/
define variable p-esys-id as integer no-undo .
define variable p-xsd-file as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh) no-error.
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return error.

/* ------------------------- &start-def-vars& -----------------------------------*/
define variable ImpData1 as class Route-data_ no-undo .
&scop constructor_2 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input v_dataseth, input v-xmlh)
ImpData1 = new Route-data_{&constructor_2} .


/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-current-code-bank as integer no-undo .
define variable v-bank-name as character no-undo .
define variable v-short-name as character no-undo .
define variable v-bik as character no-undo .
define variable v-addres as character no-undo .
define variable v-bank-city as character no-undo .
define variable v-ps as character no-undo .
define variable v-mode as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-present as logical no-undo .
define variable v-line-status_ as character no-undo .
define variable v-rec as recid no-undo .

define variable v-rid as recid no-undo .
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_sysconf for ub.sysconf.

&scop full-trans   transaction
&scop single-trans

_main:
do {&full-trans}
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по банкам из ВС")
  {&display-message}.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по банкам из файла &1", file-name)).

for each buf_temp-xml-tables where buf_temp-xml-tables.order >= 0:
  /*надо создать динамический query*/
  create query v_qh.
  glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
  if error-status:error
  or
  not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                            , buf_temp-xml-tables.tbl-name ~
                                                            , ~{&new-line~} ~
                                                            , error-status:get-message(1) ~
                                                            , return-value)
    {&display-message}.
    undo _main, return error ''.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 by &1.line-num", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                            , buf_temp-xml-tables.tbl-name ~
                                                            , ~{&new-line~} ~
                                                            , error-status:get-message(1) ~
                                                            , return-value)
    {&display-message}.
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or not glog then do:
    run write-log-and-file in p-log-handle (
                                            input 1
                                          , input log-file-name
                                          , input 1
                                          , input substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , {&new-line}
                                                            , error-status:get-message(1)
                                                            , return-value)).
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    undo _main, return error ''.
  end.
    _stroka:
    REPEAT:
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                                                  , buf_temp-xml-tables.tbl-name ~
                                                                  , num-rec ~
                                                                  , ~{&new-line~} ~
                                                                  , error-status:get-message(1) ~
                                                                  , return-value)
          {&display-message}.
          if valid-handle(v_qh) then do:
            delete object v_qh no-error.
          end.
          undo _main, return error ''.
        end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
      if v-retry-action < 1 then do:
        &scop release_2 dump ( )
        ImpData1:Route-data_{&release_2} .
      end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.
      _rule:
       do on error undo _rule, retry _rule:
         if retry then do:
           if valid-handle(v_qh) then do:
             delete object v_qh no-error.
           end.
           &scop my-message  substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
           {&display-message}.
           undo _main, return error ''.
         end.
         else do:
          v_qh:get-next().
          IF v_qh:query-off-end then leave _stroka.

      /* ------------------------- &start-rule& -----------------------------------*/
          IF ImpData1:current-tbl-name( ) = {&table_fin-bank}  THEN do:
            _tr:
            do {&single-trans}
            on error undo _rule, retry _rule
            :
              v-current-code-bank = 0.
              v-line-num = ImpData1:route-data_get-field-integer( input {&table_fin-bank}, input "line-num") .
              v-present = no.
              &if "{&single-trans}" = "transaction" &then
              run get-xcnf_check-imp-rec in p-cont-handle (
                                                    input "create"
                                                  , input p-esys-id
                                                  , input 0
                                                  , input g#db-num
                                                  , input v-pck-num
                                                  , input string(v-line-num)
                                                  , output v-present
                                                  ) no-error.
              if v-present then do:
                next _stroka.
              end.
              &endif
              num-rec = num-rec + 1.
              v-current-code-bank = ImpData1:route-data_get-field-integer( input {&table_fin-bank}, input "code-bank") .
              v-bank-name = ImpData1:route-data_get-field-character( input {&table_fin-bank}, input "bank-name") .
              v-short-name = ImpData1:route-data_get-field-character( input {&table_fin-bank}, input "short-name") .
              v-bik = ImpData1:route-data_get-field-character( input {&table_fin-bank}, input "bik") .
              v-addres = ImpData1:route-data_get-field-character( input {&table_fin-bank}, input "addres") .
              v-bank-city = ImpData1:route-data_get-field-character( input {&table_fin-bank}, input "bank-city") .
              /*v-ps = ImpData1:route-data_get-field-character( input {&table_fin-bank}, input "ps") .*/
              for each buf_sysconf no-lock
              on error  undo _rule, retry _rule
              on stop   undo _rule, retry _rule
              on endkey undo _rule, retry _rule
              :
                find first buf_fin-bank share-lock where
                          buf_fin-bank.host-code = buf_sysconf.host-code
                      and buf_fin-bank.code-bank = v-current-code-bank no-error.
                 if available buf_fin-bank then do:
                   v-rid = recid(buf_fin-bank).
                   v-mode = {&update}.
                 end.
                 else do:
                   v-rid = ?.
                   v-mode = {&add-import}.
                 end.
                run ref/finbank1.p (
                                    input-output v-rid
                                    ,input v-mode
                                    ,input yes
                                    ,input "" /*p-verify*/
                                    ,input "":U
                                    ,input buf_sysconf.host-code
                                    ,input v-current-code-bank
                                    ,input v-addres
                                    ,input v-bank-city
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.addres1)
                                    ,input v-bank-name
                                    ,input v-bik
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.cor-acc)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.e-mail)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.fax)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.inn)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.kpp)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.licenz)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.okato)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.okonx)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.okpo)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.otdel)
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.phone)
                                    ,input v-ps
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.rkc)
                                    ,input v-short-name
                                    ,input (if v-mode = {&add-import} then '' else buf_fin-bank.cl-bank)
                                    )
                                    no-error.
              end.
              if error-status:error then do:
                &scop my-message  substitute("Запись &1: &2&3&4"  ~
                                            , v-line-num ~
                                            , error-status:get-message(1) ~
                                            , ~{&new-line~} ~
                                            , return-value)
                {&display-message}.
                run set-err-type in p-cont-handle
                  ( input {&ora-err-type-PROCESSING}
                  ) no-error.
                if valid-handle(v_qh) then do:
                  delete object v_qh no-error.
                end.
                undo _rule, retry _rule .
              end. /*if error-status:error then do:*/
            end. /*do transaction*/
          end. /*IF  ImpData1:current-tbl-name( ) = "fin-bank"  THEN do:*/
      /* ------------------------- &end-rule -------------------------------------*/
        end. /*ne retry*/
      end. /*       do on error undo _rule, retry _rule:*/
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          &scop my-message  substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , v-last-error-message )
          {&display-message}.
          undo _main, return error ''.
        end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
      if v-retry-action < 1 then do:
        &scop release_2 dump ( )
        ImpData1:Route-data_{&release_2} .
      end.
      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.
      if v-retry-action = 0 then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
    end. /*stroka*/
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
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
and buf_rule-call-param.param-name = "p-esys-id"
 no-error.
if available buf_rule-call-param then do:
assign p-esys-id = buf_rule-call-param.param-value-integer.
end.

    find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.


/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 4 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v_dataseth = handle(entry(2, p-process-file-name, {&delim-par}))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-extension = entry(num-entries(file-name, "."), file-name, ".")
        v-pck-num = integer(entry(3, p-process-file-name, {&delim-par}))
        log-file-name = entry(4, p-process-file-name, {&delim-par})
        no-error
        .
        if error-status:error then do:
          &scop my-message substitute("Ошибки параметров&1&2 ..." ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system then do:
          &scop my-message substitute("Не найдена ВС &1&2 ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        if v-extension = ''
        or lookup(v-extension, "dat") = 0 then do:
          &scop my-message substitute("Файл &1 имеет недопустимое расширение &3&2 ..." ~
                                        ,file-name ~
                                        , ~{&new-line~} ~
                                        , v-extension ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
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

/*не удалять!!!!*/