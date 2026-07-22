/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/09
Author: Bakhtadze Natalya
Creation date: 01/26/09


---------------------------&start-codex_id=18;ruleset_id=4;-----------------
Импорт данных по налогам

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
/*{ gbl/gate-clb.i }*/
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ trg/factord.i  }
{ gbl/orapreps.i }

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
define variable v-retry-action     as integer no-undo .
define variable v_dataseth         as handle no-undo .
define variable v-xmlh             as handle no-undo .
define variable v_qh               as handle    no-undo .
define variable v_child-qh         as handle    no-undo .
define variable glog as logical no-undo .
define variable v-ds-read-order as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-pck-num as integer no-undo .
define variable v-extension as character no-undo .
define variable v-err-type as character no-undo .
{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_temp-rel-handle for temp-rel-handle.


define variable log-file-name                as character      no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

define temp-table temp-tax-rate no-undo
  like ub.tax-rate
  field line-num as integer
  index pi is unique primary tax-code rate-code
  index pii line-num tax-code rate-code
  .
define temp-table temp-tax-rate-value no-undo
  like ub.tax-rate-value
  field line-num as integer
  index pi is unique primary tax-code rate-code fact-date
  index pii line-num tax-code rate-code fact-date
  .

procedure clear_tt :
  do
  on error  undo, return error substitute( "&1 (clear-tt). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (clear-tt). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (clear-tt). endkey", vss-workfile )
  :
    for each temp-tax-rate
    on error undo, next
    :
      delete temp-tax-rate .
    end.
    for each temp-tax-rate-value
    on error undo, next
    :
      delete temp-tax-rate-value .
    end.
  end.

end procedure. /* clear-tt */

function 00200004_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
end function.




&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
  define variable p-esys-id  as integer no-undo.
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

&scop full-trans transaction
&scop single-trans

procedure proc-main :
define variable v-ii               as   integer                      no-undo .
define variable v-tax-code         like ub.tax-rate.tax-code         no-undo .
define variable v-rate-code        like ub.tax-rate.rate-code        no-undo .
define variable v-rate-name        like ub.tax-rate.rate-name        no-undo .
define variable v-rate-value       like ub.tax-rate-value.rate-value no-undo .
define variable v-fact-date        like ub.tax-rate-value.fact-date  no-undo .
define variable v-status           as   character                    no-undo .
define variable v-line-num         as   integer                      no-undo .
define variable v-present          as   logical                      no-undo .
define variable v-current-tbl-name as   character                    no-undo .


define buffer buf_ext-system for ub.ext-system.

if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Вызов процедуры в действующей транзакции недопустим") skip
    view-as alert-box error .
  return error substitute( "&1 (proc-main). Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .

end.

_main:
do {&full-trans}
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/

assign
  v-tax-code  = integer({&vat-tax-code})
.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по налогам из ВС")
  {&display-message}.
  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по налогам из файла &1", file-name)).

    find first buf_ext-system no-lock where
              buf_ext-system.esys-id = p-esys-id
          and buf_ext-system.db-num = 0 no-error.
    if not available buf_ext-system
    or not (buf_ext-system.esys-type  = integer({&openxml-type-oracle-retail})) then do:
    &scop my-message  substitute("Не найдена ВС &1 или она не имеет типа ORACLE RETAIL", p-esys-id)
       {&display-message}.
       undo _main, return error ''.
    end.
  assign
    num-rec          = 0
    num-rec-ok       = 0
    num-rec-ok2      = 0
  .
  _table:
  for each buf_temp-xml-tables where
          buf_temp-xml-tables.order >= 0
      and buf_temp-xml-tables.is-parent = true
  on error undo _table, retry _table
  :
    if retry then do:
      &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                              , buf_temp-xml-tables.tbl-name ~
                                                              , ~{&new-line~} ~
                                                              , error-status:get-message(1) ~
                                                              , return-value)
      {&display-message}.
      run delete-procedure in this-procedure .
      if valid-handle(v_qh) then do:
        delete object v_qh no-error.
      end.
      undo _main, return error ''.
    end.
    /*надо создать динамический query*/
    if buf_temp-xml-tables.tbl-name = "THheader" then next.

  /*надо создать динамический query*/
  create query v_qh.
  glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
  if error-status:error
    or not glog
  then do:
     undo _table, retry _table.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 by &1.line-num", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
    or not glog
  then do:
     undo _table, retry _table.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
    or not glog
  then do:
     undo _table, retry _table.
  end.
  _stroka:
  repeat:
    assign
      num-rec = num-rec + 1
      v-retry-action = 0
    .

    _release:
    do
    on error undo _release, retry _release
    :
      if  retry then do:
        v-retry-action = v-retry-action + 1.
        &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                      , buf_temp-xml-tables.tbl-name ~
                                      , num-rec ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value)
        {&display-message}.
        run delete-procedure in this-procedure .

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
    do
    on error undo _rule, retry _rule
    :
      if retry then do:
        &scop my-message substitute("Ошибка разбора/приема данных по ставке налога из ВС:&1&2&1&3", {&new-line}, return-value, error-status :get-message( 1 ) )
        {&display-message}.

        run set-err-type in p-cont-handle
          ( input v-err-type
          ) no-error.

        run delete-procedure in this-procedure .

        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
        if valid-handle(v_child-qh) then do:
          delete object v_child-qh no-error.
        end.

        undo _main, return error ''.
      end.
      else do:
        v_qh:get-next().
        if v_qh:query-off-end then do:
          leave _stroka.
        end.
    /* ------------------------- &start-rule& -----------------------------------*/
        assign
          v-current-tbl-name = ImpData1:current-tbl-name( )
        .

        IF v-current-tbl-name = {&table_tax-rate}  THEN do:
          trans_save:
          do {&single-trans}
          on error  undo _rule, retry _rule
          on stop   undo _rule, retry _rule
          on endkey undo _rule, retry _rule
          :
            assign
              v-line-num  = ImpData1:route-data_get-field-integer  ( input {&table_tax-rate}, input "line-num":U )
              v-rate-code = ImpData1:route-data_get-field-integer  ( input {&table_tax-rate}, input "rate-code":U )
              v-rate-name = ImpData1:route-data_get-field-character( input {&table_tax-rate}, input "rate-name":U )
              v-status    = ImpData1:route-data_get-field-character( input {&table_tax-rate}, input "status_":U )
            .
            &if "{&single-trans}" = "transaction" &then
            run get-xcnf_check-imp-rec in p-cont-handle
              ( input "create"
              , input p-esys-id
              , input 0
              , input g#db-num
              , input v-pck-num
              , input substitute( "&1", v-line-num )
              , output v-present
              ) no-error.
            if error-status:error then do:
              &scop my-message substitute("Ошибка идентификации принимаемых данных по ставке налога из ВС:" )
              {&display-message}.
              undo _rule, retry _rule.
            end.
            if v-present = true then do:
              leave trans_save .
            end.
            &endif
            run proc-save-tax-rate in this-procedure
              ( input v-tax-code
              , input v-rate-code
              , input v-rate-name
              , input v-status
              ) no-error .
            if error-status:error then do:
              &scop my-message substitute("Ошибка при сохранении данных по ставке налога при приеме данных из ВС:" )
              {&display-message}.
              undo _rule, retry _rule.
            end.
            else do:
              assign
                num-rec-ok2 = num-rec-ok2 + 1
              .
            end.
            if v-status <> {&ora-line-delete} then do:
              for each buf_temp-rel-handle
                where buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name
              on error undo _rule, retry _rule
              :
                run tmpreld2_query in this-procedure
                  ( buffer buf_temp-rel-handle
                  , input-output v_child-qh
                  ) no-error.
                if error-status:error then do:
                  &scop my-message substitute("Не удалось получить записи &1 для &2&3&4&3&5" ~
                                              , buf_temp-rel-handle.child-buffer_ ~
                                              , v-current-tbl-name ~
                                              , ~{&new-line~} ~
                                              , error-status:get-message(1)  ~
                                              , return-value )
                  {&display-message}.
                  undo _rule, retry _rule .
                end.
                _child-stroka:
                repeat:
                  v_child-qh:get-next().
                  if v_child-qh:query-off-end then do:
                    leave _child-stroka.
                  end.
                  case buf_temp-rel-handle.child-buffer_:
                    when {&table_tax-rate-value} then do:
/*                      assign*/
/*                        v-line-num   = ImpData1:route-data_get-field-integer  ( buffer buf_temp-rel-handle:handle, input {&table_tax-rate-value}, input "line-num":U )*/
/*                      .*/
                      run proc-save-tax-rate-value in this-procedure
                        ( input v-tax-code
                        , input ImpData1:route-data_get-field-integer  ( buffer buf_temp-rel-handle:handle, input {&table_tax-rate-value}, input "rate-code":U )
                        , input ImpData1:route-data_get-field-decimal  ( buffer buf_temp-rel-handle:handle, input {&table_tax-rate-value}, input "rate-value":U )
                        , input ImpData1:route-data_get-field-date     ( buffer buf_temp-rel-handle:handle, input {&table_tax-rate-value}, input "fact-date":U )
                        , input 0    /* host-cod e*/
                        , input "":U /* obj-type */
                        , input 0    /* obj-code */
                        , input ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input {&table_tax-rate-value}, input "status_":U )
                        ) no-error .
                      if error-status:error then do:
                        undo _rule, retry _rule.
                      end.

                    end. /*when {&table_tax-rate-value}   */
                  end case. /*  case buf_temp-rel-handle_.child-buffer_:*/
                end.
                delete object v_child-qh no-error.
              end. /*              for each buf_temp-rel-handle where*/
            end. /* v-status <> {&ora-line-delete} */
          end. /* trans_save */
        end. /*IF  ImpData1:current-tbl-name( ) = "tax-rate"  THEN do:*/
    /* ------------------------- &end-rule -------------------------------------*/
      end.
    end.

    v-retry-action = 0 .
    _release:
    do
    on error undo _release, retry _release
    :
      if retry then do:
        v-retry-action = v-retry-action + 1.
        &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                      , buf_temp-xml-tables.tbl-name ~
                                      , num-rec ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value)
        {&display-message}.
        run delete-procedure in this-procedure .

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

    if v-retry-action = 0 then do:
      num-rec-ok = num-rec-ok + 1.
    end.
    run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
    /*
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
      run write-log-and-file in p-log-handle (
                                              input 1
                                            , input log-file-name
                                            , input 1
                                            , input substitute("Процесс импорта прерван пользователем")).
      undo _main, return error .
    end.
    */
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

  run write-log-and-file in p-log-handle
    ( input 1
    , input log-file-name
    , input 1
    , input substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok2 )
    ).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-itop as integer   no-undo .
define variable v-ichild as integer   no-undo .
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
          &scop my-message substitute("Не найдена ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.

        end.
        if v-extension = ''
        or lookup(v-extension, "dat") = 0 then do:
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
          if v_dataseth:get-top-buffer(v-itop):table = "header_" then do:
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
        end. /*        do v-itop = 1 to v_dataseth:num-top-buffers:*/
        run tmpreldf_get-relations in this-procedure ( input  v_dataseth).
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure delete-procedure :

  do
  on error  undo, return error substitute( "&1 (delete-procedure). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (delete-procedure). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (delete-procedure). endkey", vss-workfile )
  :
      run clear_tt in this-procedure .
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */

procedure proc-save-tax-rate :

  define input  parameter p-tax-code  like ub.tax-rate.tax-code  no-undo .
  define input  parameter p-rate-code like ub.tax-rate.rate-code no-undo .
  define input  parameter p-rate-name like ub.tax-rate.rate-name no-undo .
  define input  parameter p-status    as   character             no-undo .

  do
  on error  undo, return error substitute( "&1 (proc-save-tax-rate). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (proc-save-tax-rate). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-save-tax-rate). endkey", vss-workfile )
  :
    define buffer buf_tax            for ub.tax .
    define buffer buf_tax-rate       for ub.tax-rate .
    define buffer buf_tax-rate-value for ub.tax-rate-value .
    define buffer buf_clients        for ub.clients .

    define variable v-rid       as recid     no-undo .
    define variable v-host-code as integer   no-undo .
    define variable v-stts      as character no-undo .

    find first buf_tax-rate exclusive-lock
      where buf_tax-rate.tax-code  = p-tax-code
        and buf_tax-rate.rate-code = p-rate-code
      no-error .
    if available buf_tax-rate then do:
      assign
        v-rid  = recid( buf_tax-rate )
        v-stts = {&update}
      .
    end.
    else do:
      assign
        v-rid  = ?
        v-stts = {&add-def}
      .
    end.

    case p-status :
      when {&ora-line-create}
      or when {&ora-line-update}
      then do:
        run ref/taxrati1.p
          ( input-output v-rid
          , input v-stts
          , input true /* p-silent */
          , input p-tax-code
          , input p-rate-code
          , input p-rate-name
          , input {&current-status}
          ) no-error.
        if error-status:error then do:
          undo, return error substitute( "&1 (proc-save-tax-rate). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) .
        end.
      end.
      when {&ora-line-delete} then do:
        if available buf_tax-rate then do:
          for each buf_tax-rate-value exclusive-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate.rate-code
          on error undo, return error substitute( "&1 (proc-save-tax-rate). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          :
            assign
              buf_tax-rate-value.status_ = {&deleted-status}
            .
          end.
          assign
            buf_tax-rate.status_ = {&deleted-status}
          .
          release buf_tax-rate .
        end.
        else do:
          undo, return error substitute( "&1 (proc-save-tax-rate). Запрошено удаление отсутствующей записи", vss-workfile ) .
        end.
      end.
    end case.
    find first buf_tax no-lock where
             buf_tax.tax-code = p-tax-code no-error.
    if available buf_tax
    and buf_tax.to-cashdesk = yes
    then do:
      for each buf_clients no-lock
        where buf_clients.obj-type = {&shop}
          and buf_clients.db-num = g#db-num
      on error undo, return error return-value
      :
        { gbl/hostcode.i
          buf_clients.obj-type
          buf_clients.obj-code
          v-host-code
        }
        run fill-cash-txr in p-cont-handle (
                                             input p-tax-code
                                            ,input p-rate-code
                                            ,input (if p-status = {&ora-line-create}
                                                    or p-status = {&ora-line-update}
                                                    then {&current-status}
                                                    else {&deleted-status})
                                            ,input v-host-code
                                            ,input buf_clients.obj-type
                                            ,input buf_clients.obj-code
                                            ,input buf_tax.tax-type
                                            ,input ?
                                            ,input p-rate-code
                                            ,input v-rid
                                            ).
      end.
    end.
  end.

end procedure. /* proc-save-tax-rate */

procedure proc-save-tax-rate-value :

  define input  parameter p-tax-code   like ub.tax-rate-value.tax-code   no-undo .
  define input  parameter p-rate-code  like ub.tax-rate-value.rate-code  no-undo .
  define input  parameter p-rate-value like ub.tax-rate-value.rate-value no-undo .
  define input  parameter p-fact-date  like ub.tax-rate-value.fact-date  no-undo .
  define input  parameter p-host-code  like ub.tax-rate-value.host-code  no-undo .
  define input  parameter p-obj-type   like ub.tax-rate-value.obj-type   no-undo .
  define input  parameter p-obj-code   like ub.tax-rate-value.obj-code   no-undo .
  define input  parameter p-status     as   character                    no-undo .

  do
  on error  undo, return error substitute( "&1 (proc-save-tax-rate-value). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (proc-save-tax-rate-value). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-save-tax-rate-value). endkey", vss-workfile )
  :
    define buffer buf_tax            for ub.tax .
    define buffer buf_tax-rate-value for ub.tax-rate-value .

    define variable v-rid        as   recid                        no-undo .
    define variable v-fact-order like ub.tax-rate-value.fact-order no-undo .
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.


    run factord-end-day in this-procedure
      ( input p-fact-date
      , output v-fact-order
      ).

    find first buf_tax-rate-value exclusive-lock
      where buf_tax-rate-value.tax-code   = p-tax-code
        and buf_tax-rate-value.rate-code  = p-rate-code
        and buf_tax-rate-value.host-code  = p-host-code
        and buf_tax-rate-value.obj-type   = p-obj-type
        and buf_tax-rate-value.obj-code   = p-obj-code
        and buf_tax-rate-value.fact-order = v-fact-order
      no-error .
    if available buf_tax-rate-value then do:
      assign
        v-rid  = recid( buf_tax-rate-value )
      .
    end.
    else do:
      assign
        v-rid  = ?
      .
    end.

    case p-status :
      when {&ora-line-create}
      or when {&ora-line-update}
      then do:
        run ref/taxvali1.p
          ( input-output v-rid
          , input {&add-def}   /* ( if p-status = {&ora-line-create} then {&add-def} else {&update} ) */
          , input true /* p-silent */
          , input p-tax-code
          , input p-rate-code
          , input p-rate-value
          , input p-fact-date
          , input p-host-code
          , input p-obj-type
          , input p-obj-code
          , input {&current-status}
          ) no-error.
        if error-status:error then do:
          undo, return error substitute( "&1 (proc-save-tax-rate-value). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) .
        end.
      end.
      when {&ora-line-delete} then do:
        if available buf_tax-rate-value then do:
          assign
            buf_tax-rate-value.status_ = {&deleted-status}
          .
          release buf_tax-rate-value .
        end.
        else do:
          undo, return error substitute( "&1 (proc-save-tax-rate-value). Запрошено удаление отсутствующей записи", vss-workfile ) .
        end.
      end.
    end case.
    find buf_tax where
        buf_tax.tax-code = p-tax-code no-lock no-error.
    run cur-time in this-procedure ( output v-today, output v-time).
    if available buf_tax
    and buf_tax.to-cashdesk = yes
    and p-fact-date <= v-today
    then do:
      run fill-cash-txr in p-cont-handle (
                                           input buf_tax.tax-code
                                          ,input p-rate-code
                                          ,input ?
                                          ,input p-host-code
                                          ,input p-obj-type
                                          ,input p-obj-code
                                          ,input buf_tax.tax-type
                                          ,input (if p-status = {&ora-line-delete} then ? else p-rate-value)
                                          ,input integer( p-fact-date)
                                          ,input v-rid
                                          ).

  end.


  end.

end procedure. /* proc-save-tax-rate */