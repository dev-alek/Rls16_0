block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=5;ruleset_id=1;-----------------
Экспорт данных по ДК

---------------------------&end-codex_id=5;ruleset_id=1;-----------------

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
/*если вызывается персистентно то эти два параметра не играют значения*/
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .

{ str/saledcdf.i " " }
define INPUT parameter table for temp-d-card.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 4".
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
{ gbl/key-rec.i }
{ gbl/gate-clb.i }
{ bge/fillxpck.i }

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
define variable hSAXWriter as handle no-undo .
define variable v-context-gate as character no-undo .

{ rul/seterror.i }
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.


define stream Outstream.
define variable log-file-name                as character      no-undo init "shd-free.log".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-seek                       as int64          no-undo .

function 00050000_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
return v-mess.
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
  define variable p-esys-id as integer no-undo.
  define variable p-xsd-file as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


&scop sign v-sign *

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
define buffer buf_rule-call-param for tt0-rule-call-param.
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/
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
    , input substitute("Экспорт данных в файл &1", file-name)).

  if p-ruleset-id = 1 then do:
    output stream Outstream to value(file-name).
  end.


      /* ------------------------- &start-rule& -----------------------------------*/
/* Экспорт данных по продажам по ДК в систему ЛАНТАБ
 */

_1806:
do:

      run export-data-dc in this-procedure  no-error .
  /*doe*/
      /* ------------------------- &end-rule -------------------------------------*/
   if p-ruleset-id = 1 then do:
     output stream Outstream close.
   end.


&scop my-message substitute("Данные экспортированы в файл &1",  file-name)
   {&display-message}.

end. /*of rule 1806*/
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
      when 1 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = no-lock
        v-current-date = p-doc-date
        file-name  = p-process-file-name
        .
        if NOT g#db-num = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Экспорт данных по ДК только в ГБД")).
          assign
          v-view-log = yes.
          {&view-log}.
          return "return".
        end.
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

procedure xmldata:
define input parameter xmlnode as character.
define input parameter chardata as character.
hsaxwriter:start-element(xmlnode).
hsaxwriter:write-characters(chardata).
hsaxwriter:end-element(xmlnode).
end procedure.

&scop delimiter ";":U

procedure export-data-dc :
define variable v-last-esr-tbl-ord as int64 no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-longchar as longchar no-undo .
define variable v_dataseth as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v_qh as handle no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-xmlh as handle no-undo .
define variable v-gate-file-name as character no-undo .
define variable v-num-rec as integer no-undo .
define buffer buf_esys-route for ub.esys-route.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_temp-xml-tables for temp-xml-tables.


  do
  on error undo, return error return-value
  :
    v-xmlh = buffer buf_temp-xml-tables:handle.
    find last buf_esys-route where
            buf_esys-route.esys-id = p-esys-id
        and buf_esys-route.db-num = 0
        and buf_esys-route.esr-cr-db-num = 0
        and buf_esys-route.esr-last-pack = - 1 no-error.
   if available buf_esys-route then do:
      assign
      v-last-esr-tbl-ord = buf_esys-route.esr-tbl-ord.
    end.
    else do:
    end.
    _dc-trn-doc:
    for each buf_esys-route share-lock
        where buf_esys-route.esys-id     = p-esys-id
          and buf_esys-route.db-num      = 0
          and buf_esys-route.esr-status  = 0
          and buf_esys-route.esr-cr-db-num = 0
          and buf_esys-route.esr-tbl-ord <= v-last-esr-tbl-ord
    on error undo _dc-trn-doc, return:
      if buf_esys-route.esr-action = {&nwsdochs_action_command-bush} then do:
        run get-gate-file-name in this-procedure ( input buf_esys-route.uniq-gate-rec
                                               ,output v-gate-file-name
                                               ) no-error.
        if v-gate-file-name <> p-xsd-file then do:
          run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
          next _dc-trn-doc.
        end.
        run  fillxpck in this-procedure (
                                          buffer buf_esys-route
                                         ,output v_dataseth
                                         ,input-output v-xmlh
                                         ,output v-num-rec
                                         ) no-error.
        if error-status:error then do:
          undo, return error substitute("&1 Ошибка при заполнении пакета &6 через gate &2&3&4&3&5"
                                                  , vss-workfile
                                                  ,buf_esys-route.uniq-gate-rec
                                                  ,{&new-line}
                                                  ,error-status:get-message(1)
                                                  ,return-value
                                                  ,buf_esys-route.esr-name-rec
                                                  ).
        end.
        for each buf_temp-xml-tables:
          create query v_qh.
          v_qh:set-buffers(buf_temp-xml-tables.tbl-handle_).
          v_qh:query-prepare( substitute("for each &1", buf_temp-xml-tables.tbl-name)).
          v_qh:query-open().
          repeat:
            glog = v_qh:get-next.
            if v_qh:query-off-end then leave.
            case buf_temp-xml-tables.tbl-name:
              when "lantab-export-chk":U then do:
                put stream OutStream unformatted
                buf_temp-xml-tables.tbl-handle_::obj-code {&delimiter}
                (if buf_temp-xml-tables.tbl-handle_::action = -1
                then "-1"
                else "")
                buf_temp-xml-tables.tbl-handle_::doc-code {&delimiter}
                buf_temp-xml-tables.tbl-handle_::chk-date {&delimiter}
                buf_temp-xml-tables.tbl-handle_::d-card {&delimiter}
                buf_temp-xml-tables.tbl-handle_::netto  {&delimiter}
                buf_temp-xml-tables.tbl-handle_::discnt {&delimiter}
                buf_temp-xml-tables.tbl-handle_::out-code
                skip.
              end.
              when "lantab-export-trn":U then do:
                put stream OutStream unformatted
                buf_temp-xml-tables.tbl-handle_::obj-code {&delimiter}
                (if buf_temp-xml-tables.tbl-handle_::action = -1
                then "-1"
                else "")
                buf_temp-xml-tables.tbl-handle_::sale-doc {&delimiter}
                buf_temp-xml-tables.tbl-handle_::doc-date {&delimiter}
                buf_temp-xml-tables.tbl-handle_::d-card {&delimiter}
                buf_temp-xml-tables.tbl-handle_::gds-tot-r-b {&delimiter}
                buf_temp-xml-tables.tbl-handle_::gds-dis-r-b {&delimiter}
                buf_temp-xml-tables.tbl-handle_::sale-doc
                skip.
              end.
            end case.
          end. /*repeat*/
          if valid-handle(v_qh) then delete object v_qh.
        end. /*for each buf_temp-xml-tables:*/
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      end. /*if buf_esys-route.esr-name-rec begins ("command" + {&delim-nws} + "bush" + {&delim-nws} + {&cmd-esys-general}) then do:*/
      DEFINE VARIABLE v-today as date no-undo .
      DEFINE VARIABLE v-time as integer no-undo .
      run cur-time in this-procedure (
            output v-today
          , output v-time
      ).
      assign
          buf_esys-route.esr-status            = 1
          buf_esys-route.esr-sys-date          = v-today
          buf_esys-route.esr-sys-time-int      = v-time
          buf_esys-route.esr-sys-time          = string( v-time, "hh:mm:ss" )
      .
    end. /*for each buf_esys-route where*/
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
  end.

end procedure. /* export-data-dc */