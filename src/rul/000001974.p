/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 12 набор правил 3

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=12;ruleset_id=3;-----------------
Импорт данных по клиентам из XML файла

---------------------------&end-codex_id=12;ruleset_id=3;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12 набор правил 3".
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
{ rul/tempcxml.i "new shared" }
{ gbl/gate-clb.i }
{ cmp/cli-list.i cli-list def "SHARED" }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-cli-type as character no-undo .
define variable v-current-cli-code as integer no-undo .
define variable v-current-cli-name as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo init "process-clients.txt".
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
define variable v-last-rec-ord as integer no-undo .


{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define temp-table temp-clients_ no-undo like ub.clients.
define temp-table temp-firm_ no-undo like ub.firm.
define temp-table temp-person_ no-undo like ub.person.
define temp-table temp-staff no-undo like ub.staff.
{ trg/person1s.i temp-staff }
define buffer buf_temp-xml-tables for temp-xml-tables.


function 00120003_get-error-message returns character :
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

function 00120003_after-import_f returns logical ( input p-cli-type as character, input p-cli-code as integer):
  run 00120003_after-import in this-procedure ( input p-cli-type, input p-cli-code) no-error.
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
or return-value = "return" then return.

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
define variable v-current-upper-node-code as integer no-undo .
define variable v-current-node-name as character no-undo .
define variable v-rid as recid no-undo .
define variable v-current-tbl-name as character no-undo .
define variable glog as logical no-undo .
define variable v_child-qh as handle no-undo .
define variable v-current-firm-code as integer no-undo .
define variable v-current-psn-code as integer no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_temp-clients_ for temp-clients_.
define buffer buf_temp-firm_ for temp-firm_.
define buffer buf_temp-person_ for temp-person_.
define buffer buf_temp-rel-handle for temp-rel-handle.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute("Импорт данных по клиентам из файла &1", file-name)
{&display-message}.
run tmpreldf_get-relations in this-procedure ( input  v_dataseth).
for each buf_temp-xml-tables where
        buf_temp-xml-tables.order >= 0
    and buf_temp-xml-tables.is-parent = yes
        :
  /*надо создать динамический query*/
  if buf_temp-xml-tables.tbl-name = "THheader" then next.
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
    v-view-log = yes.
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
    v-view-log = yes.
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
    v-view-log = yes.
    undo _main, return error ''.
  end.
    _stroka:
    REPEAT:
      if buf_temp-xml-tables.is-parent = yes then do:
        num-rec = num-rec + 1.
      end.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          &scop my-message  substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                    , buf_temp-xml-tables.tbl-name ~
                                    , num-rec ~
                                    , ~{&new-line~} ~
                                    , error-status:get-message(1) ~
                                    , return-value)
          {&display-message}.
          v-view-log = yes.
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
           &scop my-message substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
          {&display-message}.
          v-view-log = yes.
           next _stroka.
         end.
         else do:
          v_qh:get-next().
          IF v_qh:query-off-end then leave _stroka.

      /* ------------------------- &start-rule& -----------------------------------*/
          assign
          v-current-tbl-name = ''
          v-current-tbl-name = ImpData1:current-tbl-name( ) no-error .

          case v-current-tbl-name :
            when "clients-01"  THEN do:
              v-current-cli-type = ImpData1:route-data_get-field-character( input "clients-01", input "obj-type") .
              v-current-cli-code = ImpData1:route-data_get-field-integer( input "clients-01", input "obj-code") .
              v-current-cli-name = ImpData1:route-data_get-field-character( input "clients-01", input "obj-name") .
              find first buf_clients no-lock where
                        buf_clients.obj-type = v-current-cli-type
                    and buf_clients.obj-code = v-current-cli-code no-error.
              if available buf_clients then do:
                &scop my-message substitute("Уже есть клиент &1&2. Пропускаем ...", v-current-cli-type, v-current-cli-code)
                {&display-message}.
                next _stroka.
              end.
              find first buf_temp-clients_ where
                        buf_temp-clients_.obj-type = v-current-cli-type
                    and buf_temp-clients_.obj-code = v-current-cli-code no-error.
              if not available buf_temp-clients_ then do:
                create  buf_temp-clients_.
                assign
                buf_temp-clients_.obj-type = v-current-cli-type
                buf_temp-clients_.obj-code = v-current-cli-code
                .
              end.
              assign
              buf_temp-clients_.obj-name = v-current-cli-name
              .
              assign
              glog = buffer buf_temp-clients_:handle:buffer-copy(ImpData1:route-data_get-record("clients-01"), "obj-type,obj-code,obj-name") no-error.
              if not glog
              or error-status:error then do:
                &scop my-message  substitute("Не удалось получить данные записи <clients-01>: &1&2&3" ~
                                              , error-status:get-message(1) ~
                                              , ~{&new-line~} ~
                                              , return-value)
                {&display-message}.
                next _stroka.
              end.
              _rel:
              for each buf_temp-rel-handle where
                      buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name:
                run tmpreld2_query in this-procedure ( buffer buf_temp-rel-handle, input-output v_child-qh) no-error.
                if error-status:error then do:
                  &scop my-message return-value
                  {&display-message}.
                  undo _rule, retry _rule.
                end.
                  _child:
                  repeat:
                  v_child-qh:get-next().
                  IF v_child-qh:query-off-end then do:
                    delete object v_child-qh no-error.
                    next _rel.
                  end.
                  case buf_temp-rel-handle.child-buffer_:
                    when "firm-01"
                    THEN do:
                      v-current-firm-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "firm-code") .
                      find first buf_temp-firm_ where
                                buf_temp-firm_.firm = v-current-firm-code no-error.
                      if not available buf_temp-firm_ then do:
                        create  buf_temp-firm_.
                        assign
                        buf_temp-firm_.firm-code = v-current-firm-code
                        .
                      end.
                      assign
                      glog = buffer buf_temp-firm_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                      ,"firm-code"
                                                                    ) no-error.
                      if not glog
                      or error-status:error then do:
                        &scop my-message substitute("Не удалось получить данные записи <&4>: &1&2&3" ~
                                                    , error-status:get-message(1) ~
                                                    , ~{&new-line~} ~
                                                    , return-value ~
                                                    , buf_temp-rel-handle.child-buffer_)
                        {&display-message}.
                        undo _rule, retry _rule.
                      end.
                      release buf_temp-firm_ .
                    end. /*when "firm-01" */
                    when "person-01"
                    THEN do:
                      v-current-psn-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_, input "psn-code") .
                      find first buf_temp-person_ where
                                buf_temp-person_.psn-code = v-current-psn-code no-error.
                      if not available buf_temp-person_ then do:
                        create  buf_temp-person_.
                        assign
                        buf_temp-person_.psn-code = v-current-psn-code
                        .
                      end.
                      assign
                      glog = buffer buf_temp-person_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                        ,"psn-code"
                                                                                                      ) no-error.
                      if not glog
                      or error-status:error then do:
                        &scop my-message substitute("Не удалось получить данные записи <&4>: &1&2&3" ~
                                                    , error-status:get-message(1) ~
                                                    , ~{&new-line~} ~
                                                    , return-value ~
                                                    , buf_temp-rel-handle.child-buffer_ )
                        {&display-message}.
                        undo _rule, retry _rule.
                      end.
                      release buf_temp-person_ .
                    end. /*when {&table_person}   */
                  end case. /*                case buf_temp-rel-handle_.child-buffer_:*/
                end. /*                    repeat:*/
                delete object v_child-qh no-error.
              end. /*              for each buf_temp-rel-handle where*/
              case v-current-cli-type:
                when {&cmp} then do:
                  find first buf_temp-firm_ where
                            buf_temp-firm_.firm-code = v-current-cli-code.
                  run ref/firm1.p (
                      input parparentproc
                      ,input-output v-rid
                      ,input {&add-def}
                      ,input "cli-all":U
                      ,input yes /*p-silent*/
                      ,input - abs(buf_temp-clients_.obj-code) /*генерация уникального номера внутри*/
                      ,input 0
                      ,input buf_temp-clients_.obj-name
                      ,input 0 /*p-lim-kr*/
                      ,input "":U /*p-PS*/
                      ,input buf_temp-clients_.grp-code
                      ,input buf_temp-firm_.addres1
                      ,input buf_temp-firm_.addres2
                      ,input buf_temp-firm_.city
                      ,input buf_temp-firm_.contact-psn
                      ,input buf_temp-firm_.director
                      ,input buf_temp-firm_.e-mail
                      ,input buf_temp-firm_.engl-name
                      ,input buf_temp-firm_.fax
                      ,input buf_temp-firm_.given-by
                      ,input buf_temp-firm_.ind
                      ,input buf_temp-firm_.inn
                      ,input no /*p-no-check-inn*/
                      ,input buf_temp-firm_.is-pboul
                      ,input buf_temp-firm_.kpp
                      ,input buf_temp-firm_.okonh
                      ,input buf_temp-firm_.okpo
                      ,input buf_temp-firm_.passp-num
                      ,input buf_temp-firm_.passp-ser
                      ,input buf_temp-firm_.phone
                      ,input buf_temp-firm_.phone1-note
                      ,input buf_temp-firm_.post-addr1
                      ,input buf_temp-firm_.post-addr2
                      ,input buf_temp-firm_.post-city
                      ,input buf_temp-firm_.post-ind
                      ,input buf_temp-clients_.reg-code
                      ,input buf_temp-firm_.telex
                      ,input buf_temp-firm_.tobj-code
                      ,input no /* p-turnover-buyer     */
                      ,input no /*p-turnover-buyer-gds */
                    ) no-error .
                end.
                when {&prs} then do:
                  find first buf_temp-person_ where
                            buf_temp-person_.psn-code = v-current-cli-code.
                  run ref/person1.p (
                      input parparentproc
                    ,input this-procedure:handle
                    ,input-output v-rid
                    ,input {&add-def}
                    ,input "cli-all":U
                    ,input yes  /*p-silent*/
                    ,input - abs(buf_temp-clients_.obj-code)  /*генерация уникального номера внутри!!!*/
                    ,input 0 /*stts*/
                    ,input buf_temp-clients_.obj-name
                    ,input 0 /*lim-kr*/
                    ,input "":U /*ps*/
                    ,input buf_temp-clients_.grp-code
                    ,input buf_temp-person_.address
                    ,input buf_temp-person_.city
                    ,input buf_temp-person_.date-birth
                    ,input buf_temp-person_.e-mail
                    ,input buf_temp-person_.fax
                    ,input buf_temp-person_.firm-code
                    ,input buf_temp-person_.firm-name
                    ,input buf_temp-person_.gender
                    ,input buf_temp-person_.given-by
                    ,input buf_temp-person_.ind
                    ,input buf_temp-person_.inn
                    ,input no /*p-no-check-inn*/
                    ,input buf_temp-person_.is-pboul
                    ,input buf_temp-person_.kpp
                    ,input buf_temp-person_.name1
                    ,input buf_temp-person_.name2
                    ,input buf_temp-person_.okonh
                    ,input buf_temp-person_.okpo
                    ,input buf_temp-person_.passp-num
                    ,input buf_temp-person_.passp-ser
                    ,input buf_temp-person_.phone1
                    ,input buf_temp-person_.phone1-note
                    ,input buf_temp-person_.position
                    ,input buf_temp-person_.post-box
                    ,input buf_temp-person_.post-address
                    ,input buf_temp-person_.post-city
                    ,input buf_temp-person_.post-ind
                    ,input buf_temp-clients_.reg-code
                    ,input no /* p-turnover-buyer     */
                    ,input no /*p-turnover-buyer-gds */
                    ) no-error .
                end.
              end case. /*              case v-current-cli-type:*/
              if available buf_temp-clients_ then delete buf_temp-clients_.
              if available buf_temp-firm_ then delete buf_temp-firm_.
              if available buf_temp-person_ then delete buf_temp-person_.
            end. /*when "clients-01"  THEN do:*/
          end case. /*          case v-current-tbl-name :*/
          if error-status:error then do:
            &scop my-message substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
            {&display-message}.
            v-view-log = yes.
            next _stroka.
          end. /*if error-status:error then do:*/

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
          v-view-log = yes.
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
        if buf_temp-xml-tables.is-parent = yes then do:
          num-rec-ok = num-rec-ok + 1.
        end.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         leave _stroka.
      end.
    end. /*repeat*/
    if not v-stop then do:
      if buf_temp-xml-tables.is-parent = yes then do:
        num-rec = num-rec - 1.
      end.
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/
  &scop my-message  substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)
  {&display-message}.
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
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/

    case p-ruleset-id:
      when 3 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v-xmlh = buffer buf_temp-xml-tables:handle:table-handle:default-buffer-handle
        .
        run rul/rum-xmli.p  (
                             input parparentproc
                            ,input p-log-handle
                            ,input file-name
                            ,input p-profile-id
                            ,input p-xsd-file
                            ,input 0 /*p-esys-id*/
                            ,input 0 /*p-pack-num*/
                            ,input-output v_dataseth
                            ,input-output v-xmlh

                            ) no-error.
        if error-status:error then do:
          undo, return error substitute("&1&2&3"
                                          , error-status:get-message(1)
                                          , {&new-line}
                                          , return-value ).
        end.
        v-xmlh = buffer buf_temp-xml-tables:handle.
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/



end procedure. /* load-ruleset-context */


procedure create_clients_:
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define buffer buf_temp-clients_ for temp-clients_.
find first buf_temp-clients_ where
          buf_temp-clients_.obj-type = p-obj-type
      and buf_temp-clients_.obj-code = p-obj-code  no-error .
if not available buf_temp-clients_ then do:
  create buf_temp-clients_.
  assign
  buf_temp-clients_.obj-type = p-obj-type
  buf_temp-clients_.obj-code = p-obj-code
  .
end.
end procedure.

procedure can-find_clients_  :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-find as logical no-undo .
find first temp-clients_ where
          temp-clients_.obj-type = p-obj-type
      and temp-clients_.obj-code = p-obj-code no-error.
p-find = available temp-clients_.
end procedure.


procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-clients_:
        delete temp-clients_.
      end.
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure 00120003_after-import :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define buffer buf_cli-list for cli-list.
/*пока пусто*/
find first buf_cli-list where
          buf_cli-list.obj-type = p-obj-type
     and buf_cli-list.obj-code = p-obj-code
.
delete buf_cli-list.
end procedure.

/*не удалять!!!!*/