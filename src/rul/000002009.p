/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 13 набор правил 3

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=13;ruleset_id=3;-----------------
Импорт данных по группам товаров из XML файла

---------------------------&end-codex_id=13;ruleset_id=3;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 13 набор правил 4".
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
{ ref/grplib.i }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ ref/extclass.i }
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
define variable log-file-name                as character      no-undo init "process-gds-grp.txt".
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
define temp-table temp-gds-grp_ no-undo like ub.gds-grp.
define buffer buf_temp-xml-tables for temp-xml-tables.


function 00130004_get-error-message returns character :
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

function 00130004_after-import_f returns logical ( input p-d-card as character):
  run 00130004_after-import in this-procedure ( input p-d-card) no-error.
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
define variable v-current-node-code as integer no-undo .
define variable v-current-upper-node-code as integer no-undo .
define variable v-current-node-name as character no-undo .
define variable v-calc-method as character no-undo .
define variable v-increase-pc as decimal no-undo .
define variable v-print-code  as character  no-undo .
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-mode as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-present as logical no-undo .
define variable v-current-group-code as integer no-undo .
define variable v-current-depart-code as integer no-undo .
define variable v-current-class-code as integer no-undo .
define variable v-current-subclass-code as integer no-undo .
define variable v-current-rpm-grp-name as character no-undo .
define variable v-line-status_ as character no-undo .
define variable v-upper-group-code as integer no-undo .
define variable v-upper-depart-code as integer no-undo .
define variable v-upper-class-code as integer no-undo .
define variable v-upper-subclass-code as integer no-undo .
define variable v-upper-rpm-grp-name as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-table-name as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-rec as recid no-undo .
define variable v-root-code as integer   no-undo .

define variable v-rid as recid no-undo .
define buffer buf_gds-grp for ub.gds-grp.
define buffer upper_gds-grp for ub.gds-grp.
define buffer buf_ext-classif for ub.ext-classif.
define buffer upper_ext-classif for ub.ext-classif.

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
&scop my-message substitute(".............Импорт данных по группам товаров из ВС")
  {&display-message}.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по группам товаров из файла &1", file-name)).

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
          IF  ImpData1:current-tbl-name( ) = "rpm-gds-grp"  THEN do:
            _tr:
            do {&single-trans}
            on error undo _rule, retry _rule
            :
              v-current-node-code = 0.
              v-current-upper-node-code = 0.
              v-line-num = ImpData1:route-data_get-field-integer( input "rpm-gds-grp", input "line-num") .
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
              v-current-group-code = ImpData1:route-data_get-field-integer( input "rpm-gds-grp", input "group-code") .
              v-current-depart-code = ImpData1:route-data_get-field-integer( input "rpm-gds-grp", input "depart-code") .
              v-current-class-code = ImpData1:route-data_get-field-integer( input "rpm-gds-grp", input "class-code") .
              v-current-subclass-code = ImpData1:route-data_get-field-integer( input "rpm-gds-grp", input "subclass-code") .
              v-current-rpm-grp-name = ImpData1:route-data_get-field-character( input "rpm-gds-grp", input "rpm-grp-name") .
              v-line-status_ = ImpData1:route-data_get-field-character( input "rpm-gds-grp", input "status_") .
              find first buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = {&table_gds-grp}
                    and buf_ext-classif.classif-name = {&extclass_gds-grp_rpm}
                    AND buf_ext-classif.db-num = - 1
                    and buf_ext-classif.charkey_one = string(v-current-group-code)
                    and buf_ext-classif.key#_one = v-current-depart-code
                    and buf_ext-classif.key#_two = v-current-class-code
                    and buf_ext-classif.key#_three = v-current-subclass-code no-error.
              if available buf_ext-classif then do:
                RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                    ,INPUT ?
                                                    ,INPUT "ub"
                                                    ,INPUT ? /*p-bh-handle*/
                                                    ,INPUT NO-LOCK
                                                    ,OUTPUT v-rowid
                                                    ,OUTPUT v-table-name) NO-ERROR.
                find first buf_gds-grp no-lock where
                          rowid(buf_gds-grp) = v-rowid no-error.
                assign
                v-current-node-code = buf_gds-grp.node-code
                v-current-upper-node-code = buf_gds-grp.upper-code
                .
              end.
              assign
              v-upper-group-code = (if v-current-depart-code > 0 then v-current-group-code else 0)
              v-upper-depart-code = (if v-current-class-code > 0 then v-current-depart-code else 0)
              v-upper-class-code = (if v-current-subclass-code > 0 then v-current-class-code else 0)
              v-upper-subclass-code = 0
              .
              if v-upper-group-code = 0
              and v-upper-depart-code = 0
              and v-upper-class-code = 0
              and v-upper-subclass-code = 0 then do:
                 run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
                 v-current-upper-node-code = v-root-code.
              end.
              else do:
                find first upper_ext-classif no-lock where
                          upper_ext-classif.classif-subject = {&table_gds-grp}
                      and upper_ext-classif.classif-name = {&extclass_gds-grp_rpm}
                      AND upper_ext-classif.db-num = - 1
                      and upper_ext-classif.charkey_one = string(v-upper-group-code)
                      and upper_ext-classif.key#_one = v-upper-depart-code
                      and upper_ext-classif.key#_two = v-upper-class-code
                      and upper_ext-classif.key#_three = v-upper-subclass-code no-error.
                if available upper_ext-classif then do:
                  RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT upper_ext-classif.uniq-key-rec
                                                      ,INPUT ?
                                                      ,INPUT "ub"
                                                      ,INPUT ? /*p-bh-handle*/
                                                      ,INPUT NO-LOCK
                                                      ,OUTPUT v-rowid
                                                      ,OUTPUT v-table-name) NO-ERROR.
                  find first upper_gds-grp no-lock where
                            rowid(upper_gds-grp) = v-rowid no-error.
                  assign
                  v-current-upper-node-code = upper_gds-grp.node-code.
                end.
              end.
              v-current-node-name = v-current-rpm-grp-name.
              v-calc-method = {&pr-calc-cost}.
              v-increase-pc = 0.
              v-round-method = {&pr-round-off}.
              v-base = 0.
              case v-line-status_:
                when {&ora-line-update} then do:
                  v-mode = {&update}.
                  if not available buf_ext-classif then do:
                    &scop my-message substitute("Запись &1: Не найден изменяемый узел товарного классификатора RPM &2/&3/&4/&6" ~
                                                  ,v-line-num ~
                                                  ,v-current-group-code    ~
                                                  ,v-current-depart-code   ~
                                                  ,v-current-class-code    ~
                                                  ,v-current-subclass-code)
                    {&display-message}.
                      run set-err-type in p-cont-handle
                        ( input {&ora-err-type-SYNCHRONIZATION}
                        ) no-error.
                    undo _rule, retry _rule .
                  end.
                  if not available upper_ext-classif
                  and v-current-upper-node-code = 0
                  then do:
                    &scop my-message substitute("Запись &1: Не найден вышестоящий узел изменяемого узла товарного классификатора RPM &2/&3/&4/&5" ~
                                                  ,v-line-num ~
                                                  ,v-upper-group-code    ~
                                                  ,v-upper-depart-code   ~
                                                  ,v-upper-class-code    ~
                                                  ,v-upper-subclass-code)
                    {&display-message}.
                      run set-err-type in p-cont-handle
                        ( input {&ora-err-type-SYNCHRONIZATION}
                        ) no-error.
                    undo _rule, retry _rule .
                  end.
                  v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
                end.
                when {&ora-line-create} then do:
                  v-mode = {&add-def}.
                  if available buf_ext-classif then do:
                    &scop my-message substitute("Запись &1: Уже есть добавляемый узел товарного классификатора RPM &2/&3/&4/&6" ~
                                                  ,v-line-num ~
                                                  ,v-current-group-code    ~
                                                  ,v-current-depart-code   ~
                                                  ,v-current-class-code    ~
                                                  ,v-current-subclass-code)
                    {&display-message}.
                      run set-err-type in p-cont-handle
                        ( input {&ora-err-type-SYNCHRONIZATION}
                        ) no-error.
                    undo _rule, retry _rule .
                  end.
                  if not available upper_ext-classif
                  and v-current-upper-node-code = 0
                  then do:
                    &scop my-message substitute("Запись &1: Не найден вышестоящий узел добавляемого узла товарного классификатора RPM &2/&3/&4/&5" ~
                                                  ,v-line-num ~
                                                  ,v-upper-group-code    ~
                                                  ,v-upper-depart-code   ~
                                                  ,v-upper-class-code    ~
                                                  ,v-upper-subclass-code)
                    {&display-message}.
                      run set-err-type in p-cont-handle
                        ( input {&ora-err-type-SYNCHRONIZATION}
                        ) no-error.
                    undo _rule, retry _rule .
                  end.
                end.
                when {&ora-line-delete} then do:
                  v-mode = {&deletion}.
                  if not available buf_ext-classif then do:
                    &scop my-message substitute("Запиь &1: Не найден удаляемый узел товарного классификатора RPM &2/&3/&4/&5" ~
                                                  ,v-line-num ~
                                                  ,v-current-group-code    ~
                                                  ,v-current-depart-code   ~
                                                  ,v-current-class-code    ~
                                                  ,v-current-subclass-code)
                    {&display-message}.
                      run set-err-type in p-cont-handle
                        ( input {&ora-err-type-SYNCHRONIZATION}
                        ) no-error.
                    undo _rule, retry _rule .
                  end.
                end.
              end case.
              if v-mode = {&deletion} then do:
                run ref/gdsgrp03.p ( input yes /*p-silent*/
                                    ,input recid(buf_gds-grp)
                                    ,input "" /*p-child-grp-behavior*/
                                    ,input "" /*p-child-gds-behavior*/
                                    ) no-error.
              end.
              else do:
                run ref/gdsgrp01.p ( input v-mode
                                      ,input yes /*p-silent*/
                                      ,input no /*p-get-node-code*/
                                      ,input (if v-mode = {&add-def} then yes else no) /*p-fill-tax-from-upper*/
                                      ,input-output v-current-node-code
                                      ,input-output v-current-upper-node-code
                                      ,input v-current-node-name
                                      ,input v-calc-method
                                      ,input v-increase-pc
                                      ,input v-print-code
                                      ,input v-round-method
                                      ,input v-base
                                      ,output v-rid ) no-error.
              end.
              if error-status:error then do:
                run set-err-type in p-cont-handle
                  ( input {&ora-err-type-processing}
                  ) no-error.
                if valid-handle(v_qh) then do:
                  delete object v_qh no-error.
                end.
                &scop my-message  substitute("Запись &1: &2&3&4"  ~
                                            , v-line-num ~
                                            , error-status:get-message(1) ~
                                            , ~{&new-line~} ~
                                            , return-value)
                {&display-message}.
                undo _rule, retry _rule .
              end.
              define variable v-old-name as character no-undo .
              v-old-name = (if available buf_ext-classif then buf_ext-classif.charkey_two else '').

              if v-mode = {&deletion}
              or (v-mode = {&update}
              and buf_ext-classif.charkey_two <> v-current-node-name)
              then do:
                run ref/extclas3.p (
                                input yes /*p-silent*/
                               ,input recid(buf_ext-classif)
                               ) no-error.
                if error-status :error then do:
                   &scop my-message substitute("Запись &1: Ошибка при удалении узла товарного классификатора RPM &2/&3/&4/&5" ~
                                                  , v-line-num ~
                                                  ,v-current-group-code    ~
                                                  ,v-current-depart-code   ~
                                                  ,v-current-class-code    ~
                                                  ,v-current-subclass-code)

                  {&display-message}.
                  undo _rule, retry _rule .
                end.
              end.
              if ((v-mode = {&update}
                   and v-old-name <> v-current-node-name)
                  or
                  v-mode = {&add-def})
              then do:
                if v-mode = {&add-def} then do:
                  find first buf_gds-grp no-lock where
                            recid(buf_gds-grp) = v-rid no-error.
                  if available buf_gds-grp then do:
                     run gen-key-rec in this-procedure ( input {&table_gds-grp}
                                                        ,input (buffer buf_gds-grp:handle)
                                                        ,output v-uniq-key-rec) .
                  end.
                  else do:
                    &scop my-message  substitute("Запись &1: Не найдена вновь созданная группа товара с rid &2"  ~
                                                , v-line-num ~
                                                , v-rid ~
                                                )
                    {&display-message}.
                    undo _rule, retry _rule .
                  end.
                end.
                v-rec = ?.
                run ref/extclas1.p (
                                      input {&add-def}
                                    ,input yes /*p-silent*/
                                    ,input-output v-rec
                                    ,input {&table_gds-grp} /*p-classif-subject */
                                    ,input {&extclass_gds-grp_rpm}
                                    ,input -1 /*p-db-num*/
                                    ,input v-current-depart-code /*p-Key#_One*/
                                    ,input v-current-class-code /*p-Key#_two*/
                                    ,input v-current-subclass-code /*p-Key#_three*/
                                    ,input v-current-group-code /*p-CharKey_One*/
                                    ,input v-current-node-name /*p-CharKey_Two*/
                                    ,input '' /*p-CharKey_Three*/
                                    ,input '' /*p-nonunique*/
                                    ,input v-uniq-key-rec /*p-uniq-key-rec*/
                                    ) no-error.
              end.
              if error-status:error then do:
                run set-err-type in p-cont-handle
                  ( input {&ora-err-type-processing}
                  ) no-error.
                if valid-handle(v_qh) then do:
                  delete object v_qh no-error.
                end.
                &scop my-message  substitute("Запись &1: &2&3&4"  ~
                                            , v-line-num ~
                                            , error-status:get-message(1) ~
                                            , ~{&new-line~} ~
                                            , return-value)
                {&display-message}.
                undo _rule, retry _rule .
              end.
            end.
          end.
      /* ------------------------- &end-rule -------------------------------------*/
        end.
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


procedure create_gds-grp_:
define input parameter p-node-code as integer no-undo .
define buffer buf_temp-gds-grp_ for temp-gds-grp_.
find first buf_temp-gds-grp_ where
          buf_temp-gds-grp_.node-code = p-node-code no-error .
if not available buf_temp-gds-grp_ then do:
  create buf_temp-gds-grp_.
  assign
  buf_temp-gds-grp_.node-code = p-node-code
  .
end.
end procedure.

procedure can-find_gds-grp_  :
define input parameter p-node-code as integer no-undo .
define output parameter p-find as logical no-undo .
find first temp-gds-grp_ where
                     temp-gds-grp_.node-code = p-node-code no-error.
p-find = available temp-gds-grp_.
end procedure.


procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-gds-grp_:
        delete temp-gds-grp_.
      end.
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

/*не удалять!!!!*/