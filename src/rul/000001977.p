/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=18;ruleset_id=4;-----------------
Импорт данных по заказам

---------------------------&end-codex_id=18;ruleset_id=4;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18 набор правил 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ str/ord-list.i ord-list def "shared" }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ cus/edocsord.i }
{ cus/cr-edist.i }
&undefine cr-edist_i
{ cus/cr-edist.i  tt }



/*переменные контекста*/
/*это у нас объект 0*/

define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-type as character no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable num-rec-ok2 as integer no-undo .
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
define variable v-ds-read-order as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-extension as character no-undo .
define temp-table temp-esys no-undo
field esys-id as integer
field db-num as integer
field esys-name as character
field delivery-method as integer
field rowid_ as rowid
field ftp-ip as character
field ftp-login as character
field ftp-password as character
index pi is unique primary
esys-id
.

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .


function 00180004_get-error-message returns character :
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




&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-xsd-file as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  get-thobj-es }











/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.

/* ------------------------- &start-def-vars& -----------------------------------*/
 define variable ImpData1 as class Route-data_ no-undo .
&scop constructor_2 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input v_dataseth, input v-xmlh)
ImpData1 = new Route-data_{&constructor_2} .


/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-trn-doc as character no-undo .
define variable v-ext-obj-code as integer   no-undo .
define variable v-ship-date as date no-undo .
define variable v-status_ as character no-undo .
define variable v-desstatus as character no-undo .
define variable v-artic as character no-undo .
define variable v-cli-art as character no-undo .
define variable v-price as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable v-line-status_ as integer no-undo .
define variable v-nameth as character no-undo .
define variable v-hdesstatus as character no-undo .
define variable v-loc-file-name as character no-undo .
define variable v-custom-pack-name as character no-undo .
define variable v-success as logical   no-undo .
define variable v-pack-num as integer   no-undo .
define variable v-heap-dir as character no-undo .
define variable v-exchange-dir as character no-undo .
define variable v-temp-dir as character no-undo .
define variable v-log-file-name as character no-undo .
define variable v-list-file-name as character no-undo .
define variable v-custom-pack-flag as logical   no-undo .
define variable v-short-file-name as character no-undo .
define variable v-filetype as character no-undo .
define variable v-present as logical no-undo .


define buffer buf_ext-system for ub.ext-system.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.

&scop full-trans   transaction
&scop single-trans


_main:
do {&full-trans}
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по заказам из ВС")
  {&display-message}.

for each temp-esys:
    delete temp-esys.
  end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по заказам из файла &1", file-name)).

    find first buf_ext-system no-lock where
              buf_ext-system.esys-id = v-esys-id
          and buf_ext-system.db-num = 0 no-error.
    if not available buf_ext-system
    or not (buf_ext-system.esys-type  = integer({&openxml-type-edoc-nn})) then do:
    &scop my-message  substitute("Не найдена ВС &1 или она не имеет типа EDOC-NN", v-esys-id)
       {&display-message}.
       undo _main, return error ''.
    end.
    create temp-esys.
    assign
    temp-esys.esys-id = buf_ext-system.esys-id
    temp-esys.db-num  = buf_ext-system.db-num
    temp-esys.esys-name  = buf_ext-system.esys-name
    temp-esys.delivery-method  = buf_ext-system.delivery-method
    temp-esys.rowid_  = rowid(buf_ext-system)
    .
    release temp-esys.

  for each temp-esys:
do v-ii = 1 to num-entries(v-ds-read-order):
  find first buf_temp-xml-tables where
            buf_temp-xml-tables.tbl-name = entry(v-ii, v-ds-read-order)
       and  buf_temp-xml-tables.gate-handle_ = v_dataseth.
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
  glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
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
  _stroka:
  REPEAT:
        if buf_temp-xml-tables.is-parent then do:
    num-rec = num-rec + 1.
        end.
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
      do {&single-trans}
      on error undo _rule, retry _rule:
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
          undo _rule, next _stroka.
        end.
        &endif
        if retry then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("&1&2&3"
                                                                  , error-status:get-message(1)
                                                                  , {&new-line}
                                                                  , return-value)).
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
          undo _main, return error ''.
        end.
        else do:
        v_qh:get-next().
        IF v_qh:query-off-end then leave _stroka.
      /* ------------------------- &start-rule& -----------------------------------*/
          /* Импорт  данных по продаже по ДК из внешней системы
          Импортируемые данные должны удовлетворять схеме exe/edoc-nn-order-01-ds.xsd */

          IF  ImpData1:current-tbl-name( ) = "order-header"  THEN do:
            v-current-doc-code = ImpData1:route-data_get-field-character( input "order-header", input "doc-code") .
            v-trn-doc = ImpData1:route-data_get-field-character( input "order-header", input "trn-code") .
            v-ship-date = ImpData1:route-data_get-field-date( input "order-header", input "ship-date") .
            v-status_ = ImpData1:route-data_get-field-character( input "order-header", input "status_") .
            v-hdesstatus = ImpData1:route-data_get-field-character( input "order-header", input "desstatus") .

            if v-status_ <> v-extension
            and temp-esys.delivery-method = integer({&esys-dm-nnold})
            then do:
            &scop my-message substitute("Нарушение протокола обмена:&1Статус заказа &2 не равен расширению файла &3" ~
                                        , ~{&new-line~} ~
                                        , v-status_ ~
                                        , v-extension)
              {&display-message}.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              undo _main, return error ''.
            end.
            if v-trn-doc = ''
            and v-status_ = {&edoc-ext-pst} then do:
              &scop my-message substitute("Нарушение протокола обмена:&1В статусе заказа &2 не заполнен номер поставки <trn-code>" ~
                                          , ~{&new-line~} ~
                                          , v-status_)
              {&display-message}.
              assign v-view-log = yes.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              undo _main, return error ''.
            end.
            find first buf_ord-doc no-lock where
                      buf_ord-doc.doc-code = v-current-doc-code no-error.
            if not available buf_ord-doc then do:
              &scop my-message substitute("Не найден заказ поставщику с номером &1", v-current-doc-code)
              {&display-message}.
              assign v-view-log = yes.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              undo _main, return error ''.
            end.
                v-ext-obj-code = ImpData1:route-data_get-field-integer( input "order-header", input "ext-obj-code").
                IF  context_get-thobj-es( input temp-esys.esys-id
                                        , input ''
                                        , input v-ext-obj-code
                                    , output v-current-obj-type
                                    , output v-current-obj-code) = false  THEN do:

                  &scop my-message  substitute("Не найдено соответствие объекта &1 внешней системы &2 и объекта TH", v-ext-obj-code, temp-esys.esys-id)
                  {&display-message}.
              assign v-view-log = yes.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              undo _main, return error ''.
            end.
            if not (buf_ord-doc.obj-code = v-current-obj-code) then do:
                  &scop my-message  substitute("Неверный код объекта TH = &1 для заказа &2 - в IBS TH указан объект &3" ~
                                              , v-current-obj-code ~
                                              , buf_ord-doc.doc-code  ~
                                           , buf_ord-doc.obj-code)
                  {&display-message}.
              assign v-view-log = yes.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              undo _main, return error ''.
            end.
            find first ord-list where
                      ord-list.doc-code = buf_ord-doc.doc-code
                  and ord-list.trn-doc = v-trn-doc no-error.
            if not available ord-list then do:
                create ord-list.
            end.
                buffer-copy
            buf_ord-doc to ord-list
            assign
            ord-list.trn-doc = v-trn-doc
            ord-list.ps = substitute("&1 &2", ord-list.ps, v-hdesstatus)
            .
            assign
            ord-list.ord-int1 = integer(entry (lookup (v-status_, {&edoc-spis-ex}) , {&edoc-spis})) no-error .
                release ord-list.
          end. /*IF  ImpData1:current-tbl-name( ) = "order-header"  THEN do:*/

          IF  ImpData1:current-tbl-name( ) = "order-line"  THEN do:
            v-artic = ImpData1:route-data_get-field-character( input "order-line", input "artth") .
            v-cli-art = ImpData1:route-data_get-field-character( input "order-line", input "cliart") .
            v-price = ImpData1:route-data_get-field-decimal( input "order-line", input "pricequant") .
            v-qnty = ImpData1:route-data_get-field-decimal( input "order-line", input "quantityquant") .
            v-line-status_ = ImpData1:route-data_get-field-integer( input "order-line", input "status_") .
                v-nameth = ImpData1:route-data_get-field-character( input "order-line", input "nameth") .
                v-desstatus = ImpData1:route-data_get-field-character( input "order-line", input "desstatus") .

              find first temp-ord-line where
                        temp-ord-line.doc-code  = v-current-doc-code
                    and  temp-ord-line.cliart  = v-cli-art
                    and  temp-ord-line.trn-doc = v-trn-doc no-error.
              if not available temp-ord-line then do:
                create temp-ord-line.
                assign
                temp-ord-line.doc-code      =  v-current-doc-code
                temp-ord-line.cliart        =  v-cli-art
                temp-ord-line.trn-doc = v-trn-doc
                .
              end.
              assign
                temp-ord-line.artth         =  v-artic
                temp-ord-line.nameth        =  v-nameth
                temp-ord-line.quantityquant =  v-qnty
                temp-ord-line.pricequant    =  v-price
                temp-ord-line.status_       =  string(v-line-status_)
                temp-ord-line.desstatus     =  v-desstatus
                .
                release temp-ord-line.
          end. /*IF  ImpData1:current-tbl-name( ) = "order-line"  THEN do:*/
      /* ------------------------- &end-rule -------------------------------------*/
      end.
    end.
    v-retry-action = 0 .
    _release:
    do on error undo, retry:
      if  retry then do:
        v-retry-action = v-retry-action + 1.
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("&1&2&3"
                                                                , error-status:get-message(1)
                                                                , {&new-line}
                                                                , v-last-error-message )).
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
          if v-retry-action = 0
          and buf_temp-xml-tables.is-parent
          then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         undo _main, return error .
      end.
    end. /*repeat*/
        if not v-stop
        and buf_temp-xml-tables.is-parent
        then do:
      num-rec = num-rec - 1.
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/
  leave.
end. /*for each temp-esys*/
  _ord-list:
  for each ord-list where ord-list.sel-order = 0
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
      find first buf_ord-doc exclusive-lock where
                buf_ord-doc.doc-code = ord-list.doc-code no-error.
      if not available buf_ord-doc then do:
  &scop my-message substitute("Из ВС &1 получены данные по несуществующему заказу &2" ~
                            , temp-esys.esys-id ~
                            , ord-list.doc-code )

      {&display-message}.
        run delete-ord-list in this-procedure ( input ord-list.doc-code
                                              , input ord-list.trn-doc).
        next _ord-list.
      end.
      &scop order-stts-int1 string(ord-list.ord-int1)
      run edocsord_import in this-procedure (
                                              buffer buf_ord-doc
                                            ,input {&edoc-stts-ex}
                                            ,input ord-list.trn-doc
                                            ,input ord-list.ps
                                            ) no-error.
      if error-status:error then do:
        if return-value <> '' then do:
          &scop my-message substitute("Ошибка при изменении статуса заказа при приеме данных:&1&2", {&new-line}, return-value )
          {&display-message}.
        end.
      run delete-ord-list in this-procedure ( input ord-list.doc-code
                                             ,input ord-list.trn-doc ).
        next _ord-list.
      end.
      else do:
        num-rec-ok2 = num-rec-ok2 + 1.
      end.
  END.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok2)).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-itop as integer   no-undo .
define variable v-ichild as integer   no-undo .
define variable v-pck-num as integer no-undo .
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
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
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v_dataseth = handle(entry(2, p-process-file-name, {&delim-par}))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-extension = entry(num-entries(file-name, "."), file-name, ".")
        no-error
        .
      find first buf_ext-system no-lock where
                buf_ext-system.esys-id = v-esys-id
            and buf_ext-system.db-num = 0 no-error .
      if not available buf_ext-system then do:
        &scop my-message substitute("Не найдена ВС &1&2пропускаем ..." ~
                                      , v-esys-id ~
                                      , ~{&new-line~} ~
                                      )
        {&display-message}.
        undo, return error {&my-message}.

      end.

      if v-extension = ''
      or (lookup(v-extension, "stk-ok,rpl,pst,acc-ok") = 0 and buf_ext-system.delivery-method = integer({&esys-dm-nnold})) then do:
        &scop my-message substitute("Файл &1 имеет недопустимое расширение &3&2пропускаем ..." ~
                                      ,file-name ~
                                      , ~{&new-line~} ~
                                      , v-extension ~
                                      )
        {&display-message}.
        undo, return error {&my-message}.
      end.

        _top-buffers:
        do v-itop = 1 to v_dataseth:num-top-buffers:
          if v_dataseth:get-top-buffer(v-itop):table = "THheader" then do:
            glog = v_dataseth:get-top-buffer(v-itop):find-first( "where true") no-error.
            if error-status:error
            or not glog
            or v_dataseth:get-top-buffer(v-itop):available = no then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("Не найден HEADER для файла &1&2" +
                                    "пропускаем"
                                    ,p-process-file-name
                                    , {&new-line}
                                    )).
              run set-stop-leave-status in p-parent-handle ( input "LEAVE").
              return "return".
            end.
            else do:
              v-pck-num = v_dataseth:get-top-buffer(v-itop):buffer-field("THpack-num"):buffer-value.
              v-esys-id = v_dataseth:get-top-buffer(v-itop):buffer-field("THimport-esys-id"):buffer-value.
            end.
            find first buf_esys-pck-keys no-lock where
                      buf_esys-pck-keys.esys-id = v-esys-id
                  and buf_esys-pck-keys.db-num = 0
                  and buf_esys-pck-keys.espr-cr-db-num = g#db-num
                  and buf_esys-pck-keys.espr-pack-num = v-pck-num
                  and buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                                     , {&delim-par}
                                                                     , p-call-id
                                                                     , p-codex-id
                                                                     , p-ruleset-id
                                                                     , p-order-id)

                  no-error.
            if available buf_esys-pck-keys then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("Пакет &1 уже был импортирован из внешней системы &2&3" +
                                    "пропускаем"
                                    ,v-pck-num
                                    ,v-esys-id
                                    , {&new-line}
                                    )).
              run set-stop-leave-status in p-parent-handle ( input "LEAVE").
              return "return".
            end.
            next _top-buffers.
          end.
          assign
          v-ds-read-order = v-ds-read-order +
                            (if v-ds-read-order = '':U then '':U else {&comma-char}) +
                            v_dataseth:get-top-buffer(v-itop):table
                            .
          do v-ichild = 1 to v_dataseth:get-top-buffer(v-itop):num-child-relations:
            assign
            v-ds-read-order = v-ds-read-order + {&comma-char} + v_dataseth:get-top-buffer(v-itop):get-child-relation(v-ichild):child-buffer:name.
          end.
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

procedure delete-ord-list :
define input parameter p-doc-code as character no-undo .
define input parameter p-trn-doc as character no-undo .
define buffer buf_ord-list for ord-list.

for each temp-ord-line where
        temp-ord-line.doc-code = p-doc-code
    and temp-ord-line.trn-doc = p-trn-doc
        :
  delete temp-ord-line.
end.

find first buf_ord-list where
          buf_ord-list.doc-code = p-doc-code
      and buf_ord-list.trn-doc = p-trn-doc
         no-error .
if available buf_ord-list then delete buf_ord-list.

end procedure. /* delete-ord-list */