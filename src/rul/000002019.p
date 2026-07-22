/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 12 набор правил 5

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/09
Author: Bakhtadze Natalya
Creation date: 02/13/09


---------------------------&start-codex_id=12;ruleset_id=4;-----------------
Импорт данных по клиентам из XML файла

---------------------------&end-codex_id=12;ruleset_id=4;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12 набор правил 5".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/clntattr.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ ref/cgrplib.i }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ gbl/orapreps.i }
{ utl/tt405.i    }

/*переменные контекста*/
/*это у нас объект 0*/
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
define temp-table temp-clients_ no-undo like ub.clients
field vetoManDoc as character
.
define temp-table temp-firm_ no-undo like ub.firm
field nds-serries as integer
field nds-number as integer
field nds-date as date
.
define temp-table temp-person_ no-undo like ub.person.
define temp-table temp-fin-schet_ no-undo like ub.fin-schet.
define temp-table temp-staff_ no-undo like ub.staff.
{ trg/person1s.i temp-staff_ }
define buffer buf_temp-xml-tables for temp-xml-tables.


function 00120005_get-error-message returns character :
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

function 00120005_after-import_f returns logical ( input p-d-card as character):
  run 00120005_after-import in this-procedure ( input p-d-card) no-error.
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
define variable v-mode as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-present as logical no-undo .
define variable v-current-tbl-name as character no-undo .
define variable v-current-cli-type as character no-undo .
define variable v-current-cli-code as integer no-undo .
define variable v-current-cli-name as character no-undo .
define variable v-current-code-bank as integer no-undo .
define variable v-current-r-schet as character no-undo .
define variable v-current-firm-code as integer no-undo .
define variable v-current-psn-code as integer no-undo .
define variable v-current-fin-cli-type as character no-undo .
define variable v-current-fin-cli-code as integer no-undo .
define variable v-current-staff-psn-code as integer no-undo .
define variable v-current-staff-code as integer no-undo .
define variable v-root-node-code as integer no-undo .
define variable v-schet-ii as integer no-undo .
define variable v_child-qh as handle no-undo .
define buffer buf_temp-clients_ for temp-clients_.
define buffer buf_temp-firm_ for temp-firm_.
define buffer buf_temp-person_ for temp-person_.
define buffer buf_temp-fin-schet_ for temp-fin-schet_.
define buffer buf_temp-staff_ for temp-staff_.
define buffer buf_temp-rel-handle for temp-rel-handle.

define variable v-rid as recid no-undo .

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
&scop my-message substitute(".............Импорт данных по клиентам из ВС")
  {&display-message}.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по клиентам из файла &1", file-name)).

run  cgrplib-get-root-code in this-procedure ( output v-root-node-code).


for each buf_temp-xml-tables where
       buf_temp-xml-tables.order >= 0
   and buf_temp-xml-tables.is-parent = yes
:
  if buf_temp-xml-tables.tbl-name = "Header_" then next.
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
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4"  ~
                                  , buf_temp-xml-tables.tbl-name ~
                                  , ~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value)
    {&diplay-message}.
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
        end. /*if retry*/
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
        if v-retry-action < 1 then do:
          &scop release_2 dump ( )
          ImpData1:Route-data_{&release_2} .
        end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end. /*      do on error undo, retry:*/
      _rule:
       do on error undo _rule, retry _rule:
         if retry then do:
          empty temp-table buf_temp-clients_.
          empty temp-table buf_temp-firm_.
          empty temp-table buf_temp-person_.
          empty temp-table buf_temp-fin-schet_.
          empty temp-table buf_temp-staff_.
           if valid-handle(v_qh) then do:
             delete object v_qh no-error.
           end.
           if valid-handle(v_child-qh) then do:
             delete object v_child-qh no-error.
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
          assign
          v-current-tbl-name = ''
          v-current-tbl-name = ImpData1:current-tbl-name() no-error.
          case v-current-tbl-name:
            when {&table_clients}  THEN do:
              empty temp-table buf_temp-clients_.
              empty temp-table buf_temp-firm_.
              empty temp-table buf_temp-person_.
              empty temp-table buf_temp-fin-schet_.
              empty temp-table buf_temp-staff_.
              _tr:
              do {&single-trans}
              on error undo _rule, retry _rule
              :
                v-line-num = ImpData1:route-data_get-field-integer( input {&table_clients}, input "line-num") .
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
                num-rec = num-rec + 1.
                v-current-cli-type = ImpData1:route-data_get-field-character( input {&table_clients}, input "obj-type") .
                v-current-cli-code = ImpData1:route-data_get-field-integer( input {&table_clients}, input "obj-code") .
                v-current-cli-name = ImpData1:route-data_get-field-character( input {&table_clients}, input "obj-name") .
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
                glog = buffer buf_temp-clients_:handle:buffer-copy(ImpData1:route-data_get-record({&table_clients}), "obj-type,obj-code,obj-name") no-error.
                if not glog
                or error-status:error then do:
                  &scop my-message  substitute("Не удалось получить данные записи clients: &1&2&3" ~
                                              , error-status:get-message(1) ~
                                              , ~{&new-line~} ~
                                              , return-value)
                  {&display-message}.
                  undo _rule, retry _rule.
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
                      when {&table_firm}
                      THEN do:
                        v-current-firm-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input {&table_firm} , input "firm-code") .
                          if v-current-firm-code <> v-current-cli-code then do:
                            /*нарушение протокола которое не можем отследить через схему*/
                            &scop my-message substitute("Запись &1: нарушение схемы")
                            {&display-message}.
                            delete object v_child-qh no-error.
                            undo _rule, retry _rule.
                          end.
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
                                                      , ~{&table_firm~})
                          {&display-message}.
                          undo _rule, retry _rule.
                        end.
                        release buf_temp-firm_ .
                      end. /*when {&table_firm} */
                      when {&table_person}
                      THEN do:
                        v-current-psn-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input {&table_person}, input "psn-code") .
                          if v-current-psn-code <> v-current-cli-code then do:
                            /*нарушение протокола которое не можем отследить через схему*/
                            &scop my-message substitute("Запись &1: нарушение схемы")
                            {&display-message}.
                            delete object v_child-qh no-error.
                            undo _rule, retry _rule.
                          end.
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
                                                      , ~{&table_person~} )
                          {&display-message}.
                          undo _rule, retry _rule.
                        end.
                        release buf_temp-person_ .
                      end. /*when {&table_person}   */
                      when {&table_fin-schet} then do:
                          v-current-fin-cli-type = ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input {&table_fin-schet}, input "cli-type") .
                          v-current-fin-cli-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle , input {&table_fin-schet}, input "cli-code") .
                        v-current-code-bank = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input {&table_fin-schet},  input "code-bank") .
                        v-current-r-schet = ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input {&table_fin-schet},  input "r-schet") .
                          if not (v-current-fin-cli-type = v-current-cli-type
                                  and
                                  v-current-fin-cli-code = v-current-cli-code)
                           then do:
                            /*нарушение протокола которое не можем отследить через схему*/
                            &scop my-message substitute("Запись &1: нарушение схемы")
                            {&display-message}.
                            delete object v_child-qh no-error.
                            undo _rule, retry _rule.
                          end.

                        find first buf_temp-fin-schet_ where
                                    buf_temp-fin-schet_.cli-type = v-current-fin-cli-type
                                and buf_temp-fin-schet_.cli-code = v-current-fin-cli-code
                              and buf_temp-fin-schet_.code-bank = v-current-code-bank
                              and buf_temp-fin-schet_.r-schet = v-current-r-schet  no-error.
                        if not available buf_temp-fin-schet_ then do:
                          create  buf_temp-fin-schet_.
                          assign
                            buf_temp-fin-schet_.cli-type = v-current-fin-cli-type
                            buf_temp-fin-schet_.cli-code = v-current-fin-cli-code
                          buf_temp-fin-schet_.code-bank = v-current-code-bank
                          buf_temp-fin-schet_.r-schet = v-current-r-schet
                            buf_temp-fin-schet_.code-schet = v-schet-ii
                            v-schet-ii = v-schet-ii + 1
                          .
                        end.
                        assign
                        glog = buffer buf_temp-fin-schet_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                            ,"cli-type,cli-code,code-bank,r-schet"
                                                                                                        ) no-error.
                        if not glog
                        or error-status:error then do:
                          &scop my-message substitute("Не удалось получить данные записи <&4>: &1&2&3" ~
                                                      , error-status:get-message(1) ~
                                                      , ~{&new-line~} ~
                                                      , return-value ~
                                                      , ~{&table_fin-schet~} )
                          {&display-message}.
                          undo _rule, retry _rule.
                        end.
                        release buf_temp-fin-schet_ .
                      end. /*when {&table_fin-schet} then do:*/
                      when {&table_staff}
                      THEN do:
                          /*ОСТАВЛЯЕМ CЕКЦИЮ СТАФФ - НА ВСЯКИЙ СЛУЧАЙ - не будет секции в файле импорта и это достаточно!!!*/
                        v-current-staff-psn-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input {&table_staff}, input "psn-code") .
                          if v-current-staff-psn-code <> v-current-cli-code then do:
                            /*нарушение протокола которое не можем отследить через схему*/
                            &scop my-message substitute("Запись &1: нарушение схемы")
                            {&display-message}.
                            delete object v_child-qh no-error.
                            undo _rule, retry _rule.
                          end.
                          /*выгрызваем номер магазина */
                          if v-current-staff-psn-code >= 600000000
                          and v-current-staff-psn-code <= 699999999 then do:
                            if not can-find ( first ub.clients no-lock where
                                            ub.clients.obj-type = {&shop}
                                            and ub.clients.obj-code = integer(substring(string(v-current-staff-psn-code), 2, 4))
                                            and ub.clients.db-num = g#db-num) then do:
                               next _child.
                             end.
                          end.
                        v-current-staff-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input {&table_staff}, input "staff-code") .
                        find first buf_temp-staff_ where
                                  buf_temp-staff_.psn-code = v-current-staff-psn-code
                              and buf_temp-staff_.staff-code = v-current-staff-code
                                    no-error.
                        if not available buf_temp-staff_ then do:
                          create  buf_temp-staff_.
                          assign
                          buf_temp-staff_.psn-code = v-current-staff-psn-code
                          buf_temp-staff_.staff-code = v-current-staff-code
                          .
                        end.
                        release buf_temp-staff_ .
                      end. /*when {&table_firm} */
                    end case. /*                case buf_temp-rel-handle_.child-buffer_:*/
                  end. /*                    repeat:*/
                  delete object v_child-qh no-error.
                end. /*              for each buf_temp-rel-handle where*/
            run proc-save in this-procedure (  input v-line-num
                                                  ,input v-root-node-code
                                              ,buffer buf_temp-clients_) no-error.
            if error-status:error then do:
              run set-err-type in p-cont-handle
                ( input {&ora-err-type-processing}
                ) no-error.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              &scop my-message  substitute("&1&2&3"  ~
                                          , error-status:get-message(1) ~
                                          , ~{&new-line~} ~
                                          , return-value)
              {&display-message}.
              undo _rule, retry _rule .
            end.
                end. /*do transaction*/
              end. /*when {&table_clients}*/
            end case.
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
      when 5 then do:
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
  on error undo, return error
  :
      for each temp-clients_:
        delete temp-clients_.
      end.
      for each temp-firm_:
        delete temp-firm_.
      end.
      for each temp-person_:
        delete temp-person_.
      end.
      for each temp-fin-schet_:
        delete temp-fin-schet_.
      end.
      for each temp-staff_:
        delete temp-staff_.
      end.

      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure proc-save :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-grp-code as integer no-undo .
define parameter buffer buf_temp-clients_ for temp-clients_.
define buffer buf_temp-firm_ for temp-firm_.
define buffer buf_temp-person_ for temp-person_.
define buffer buf_temp-fin-schet_ for temp-fin-schet_.
define buffer buf_temp-staff_ for temp-staff_.
define buffer buf_clients for ub.clients.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_staff for ub.staff.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer buf_temp_contract for temp_contract.

define variable v-rid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-work-place as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-err-mess as character no-undo .
define variable v-is-terminal as logical no-undo .
define variable v-status_ as character no-undo .
define variable v-not-found-fin-schet as logical no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-deleted as logical no-undo .

define buffer buf_cli-grp for ub.cli-grp.
define buffer buf_dis-card for ub.dis-card.


main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table buf_temp-clients_.
    empty temp-table buf_temp-firm_.
    empty temp-table buf_temp-person_.
    empty temp-table buf_temp-fin-schet_.
    empty temp-table buf_temp-staff_.
    empty temp-table buf_temp_contract.
     &scop my-message v-err-mess
     {&display-message}.
     return error ''.
  end.
  else do:
    v-is-terminal = no.
    run cgrplib-is-terminal ( input p-grp-code
                             ,output v-is-terminal) no-error.
    if not v-is-terminal then do:
      for each buf_cli-grp no-lock:
        if buf_cli-grp.is-term = yes then do:
          run cgrplib-is-terminal ( input buf_cli-grp.node-code
                                  ,output v-is-terminal) no-error.
          if v-is-terminal then do:
            p-grp-code = buf_cli-grp.node-code.
            leave.
          end.
        end.
      end.
    end.
    if not v-is-terminal then do:
      v-err-mess = substitute("Не найдено ни одной терминальной группы в справочнике групп клиентов, к которой можно приписать клиента").
      undo main-block, retry main-block.
    end.
    buf_temp-clients_.grp-code = p-grp-code.

    find first buf_clients share-lock where
            buf_clients.obj-type = buf_temp-clients_.obj-type
        and buf_clients.obj-code = buf_temp-clients_.obj-code no-error.
    if not available buf_clients then do:
      v-mode = {&add-def}.
      v-rid = ?.
    end.
    else do:
      v-mode = {&update}.
      v-rid = recid( buf_clients).
    end.
    case buf_temp-clients_.obj-type:
      when {&cmp} then do:
        find first buf_temp-firm_ where
                  buf_temp-firm_.firm-code = buf_temp-clients_.obj-code no-error.
        if not available buf_temp-firm_ then do:
          create buf_temp-firm_.
          assign
          buf_temp-firm_.firm-code = buf_temp-clients_.obj-code
          .
        end.
        if v-mode = {&update} then do:
          find first buf_firm share-lock where
                    buf_firm.firm-code = buf_temp-clients_.obj-code.
          buffer-copy buf_firm except
          firm-code city ind addres1 addres2 inn post-addr1 post-addr2 engl-name
          to buf_temp-firm_.
        end.
        run ref/firm1.p (
            input parparentproc
            ,input-output v-rid
            ,input v-mode
            ,input "cli-all":U
            ,input yes /*p-silent*/
            ,input (if v-mode = {&add-def}
                    then (- abs(buf_temp-clients_.obj-code)) /*генерация уникального номера внутри*/
                    else buf_clients.obj-code)
            ,input 0
            ,input buf_temp-clients_.obj-name
            ,input 0 /*p-lim-kr*/
            ,input buf_temp-clients_.PS
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
            ,input yes /*p-no-check-inn*/
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
        find first buf_temp-person_ no-error.
        if not available buf_temp-person_ then do:
          create buf_temp-person_.
          assign
          buf_temp-person_.psn-code = buf_temp-person_.psn-code
          .
        end.
        if v-mode = {&update} then do:
          find first buf_person share-lock where
                    buf_person.psn-code = buf_temp-clients_.obj-code.
          buffer-copy buf_person except
          name1
          name2
          address
          passp-ser
          passp-num
          given-by
          city
          ind
          inn
          gender
          date-birth
          position
          to buf_temp-person_.
        end.

        run ref/person1.p (
            input parparentproc
          ,input this-procedure:handle
          ,input-output v-rid
          ,input v-mode
          ,input "cli-all":U
          ,input yes  /*p-silent*/
          ,input (if v-mode = {&add-def}
                  then (- abs(buf_temp-clients_.obj-code)) /*генерация уникального номера внутри*/
                  else buf_clients.obj-code)
          ,input 0 /*stts*/
          ,input buf_temp-clients_.obj-name
          ,input 0 /*lim-kr*/
          ,input buf_temp-clients_.PS
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
          ,input yes /*p-no-check-inn*/
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
    if error-status :error then do:
      v-err-mess = substitute("Запись &1: Ошибка при сохранении clients &2&3&4&5&4&6"
                                , p-line-num
                                , buf_temp-clients_.obj-type
                                , buf_temp-clients_.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
      undo main-block, retry main-block.
    end.
    if buf_temp-clients_.obj-type = {&cmp}
    and (buf_temp-firm_.nds-serries <> 0
    or buf_temp-firm_.nds-number <> 0
    or buf_temp-firm_.nds-date <> ?) then do:
      run clntattr-write in this-procedure (
                                              input buf_temp-clients_.obj-type
                                             ,input buf_temp-clients_.obj-code
                                             ,input {&attr-vat-register}
                                             ,input substitute("&2&1&3&1&4"
                                                               , {&delim-par}
                                                               , string(buf_temp-firm_.nds-serries, "99999")
                                                               , string(buf_temp-firm_.nds-number, "9999999")
                                                               , (if buf_temp-firm_.nds-date = ?
                                                                  then {&question-mark}
                                                                  else string(buf_temp-firm_.nds-date, "99/99/9999" )
                                                                 )
                                                                )
                                             ) no-error.
      if error-status:error then do:
      v-err-mess = substitute("Запись &1: Ошибка при сохранении атрибута &7 clients &2&3&4&5&4&6&7"
                                , p-line-num
                                , buf_temp-clients_.obj-type
                                , buf_temp-clients_.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                , {&attr-vat-register}
                                ).
      undo main-block, retry main-block.
    end.
    end.
    /*прочитаем атрибут vato-man-doc*/
    run clntattr-value in this-procedure (
                                             input  buf_temp-clients_.obj-type
                                            ,input  buf_temp-clients_.obj-code
                                            ,input  {&attr-veto-man-doc}
                                            ,output v-veto-man-doc
                                            ,output v-attr-type
                                            ) .
    if v-veto-man-doc <> buf_temp-clients_.vetoManDoc
    and buf_temp-clients_.vetoManDoc <> ''
    then do:
      run clntattr-write in this-procedure (
                                              input buf_temp-clients_.obj-type
                                             ,input buf_temp-clients_.obj-code
                                             ,input {&attr-veto-man-doc}
                                             ,input buf_temp-clients_.vetoManDoc
                                             ) no-error.
      if error-status:error then do:
        v-err-mess = substitute("Запись &1: Ошибка при сохранении атрибута &7 clients &2&3&4&5&4&6&7"
                                  , p-line-num
                                  , buf_temp-clients_.obj-type
                                  , buf_temp-clients_.obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , {&attr-veto-man-doc}
                                  ).
        undo main-block, retry main-block.
      end.
    end.
    if v-veto-man-doc <> ''
    and buf_temp-clients_.vetoManDoc = ''
    then do:
      run clntattr-delete in this-procedure  (
                                                   input   buf_temp-clients_.obj-type
                                                  ,input   buf_temp-clients_.obj-code
                                                  ,input   {&attr-veto-man-doc}
                                                  ,output  v-deleted
                                                  ) no-error.
      if error-status:error then do:
        v-err-mess = substitute("Запись &1: Ошибка при удалении атрибута &7 clients &2&3&4&5&4&6&7"
                                  , p-line-num
                                  , buf_temp-clients_.obj-type
                                  , buf_temp-clients_.obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , {&attr-veto-man-doc}
                                  ).
        undo main-block, retry main-block.
      end.
    end.
    find first buf_clients where
              recid(buf_clients) = v-rid.
    if buf_temp-clients_.stts <>  buf_clients.stts
    then do:
      run ref/clients2.p ( input parparentproc
                          ,input recid(buf_clients)
                          ,input buf_temp-clients_.stts /*p-stts*/
                          ,input yes /*p-silent*/
                          ,input no /*отсюда можно удалить только {&cmp} {&prs}*/
                          ,input '':U /*p-mode2*/
                          ,input '':U /*p-source-type*/
                          ,input '':U /*p-source-ref*/
                          ) no-error .
      if error-status:error then do:
        v-err-mess = substitute("Запись &1: Ошибка при логическом удалении clients &2&3&4&5&4&6"
                                  , p-line-num
                                  , buf_temp-clients_.obj-type
                                  , buf_temp-clients_.obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).
        undo main-block, retry main-block.
      end.
    end.
    v-not-found-fin-schet = yes.
    for each buf_temp-fin-schet_ no-lock where
            buf_temp-fin-schet_.cli-type = buf_temp-clients_.obj-type
        and buf_temp-fin-schet_.cli-code = buf_temp-clients_.obj-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      v-not-found-fin-schet = no.
      for each buf_sysconf no-lock:
        /*сначала надо удалить все имеющиеся ДРУГИЕ счета по этому клиенту*/
        run proc-delete-all-fs in this-procedure (  input p-line-num
                                                  , input buf_sysconf.host-code
                                                  , buffer buf_temp-clients_
                                                  , input buf_temp-fin-schet_.code-bank
                                                  , input buf_temp-fin-schet_.r-schet) no-error.
            if error-status:error then do:
          v-err-mess = return-value .
              undo main-block, retry main-block.
            end.
        find first buf_fin-schet share-lock where
                  buf_fin-schet.host-code = buf_sysconf.host-code
              and buf_fin-schet.cli-type = buf_temp-fin-schet_.cli-type
              and buf_fin-schet.cli-code = buf_temp-fin-schet_.cli-code
              and buf_fin-schet.code-bank = buf_temp-fin-schet_.code-bank
              and buf_fin-schet.r-schet = buf_temp-fin-schet_.r-schet no-error.
        if available buf_fin-schet then do:
          v-mode = {&update}.
          v-rid = recid(buf_fin-schet).
        end.
        else do:
          v-mode = {&add-def}.
          v-rid = ?.
        end.
        run ref/finscht1.p (
         input-output v-rid
        ,input v-mode
        ,input yes
        ,input "" /*p-verify*/
        ,input buf_sysconf.host-code
        ,input (if v-mode = {&add-def} then 0 else buf_fin-schet.code-schet)
        ,input (if v-mode = {&add-def} then '' else buf_fin-schet.c-schet)
        ,input buf_temp-fin-schet_.cli-type
        ,input buf_temp-fin-schet_.cli-code
        ,input buf_temp-fin-schet_.code-bank
        ,input buf_temp-fin-schet_.curr-code
        ,INPUT (if v-mode = {&add-def} then '' else buf_fin-schet.dop1) + (if buf_temp-fin-schet_.cli-code  >= 100000000
                                                                           and buf_temp-fin-schet_.cli-code  < 299999999
                                                                           then ({&delim-par} + string(buf_temp-fin-schet_.cli-code ))
                                                                           else '')
        ,INPUT (if v-mode = {&add-def} then '' else buf_fin-schet.dop2)
        ,input buf_temp-fin-schet_.r-schet
        ,input (if v-mode = {&add-def} then '' else buf_fin-schet.ps)
        )
        no-error.
        if error-status :error then do:
          v-err-mess = substitute("Запись &1: Ошибка при сохранении fin-schet  для фирмы &7&2&3&4&5&4&6"
                                    , p-line-num
                                    , buf_temp-clients_.obj-type
                                    , buf_temp-clients_.obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    , buf_sysconf.host-code
                                    ).
          undo main-block, retry main-block.
        end.
        find first buf_fin-schet share-lock where
                  recid(buf_fin-schet) = v-rid.
        if buf_fin-schet.status_ = {&deleted-status} then do:
          v-status_ = {&current-status}.
          run ref/finscht2.p ( input recid(buf_fin-schet)
                              ,input yes /*p-silent*/
                              ,input (if buf_fin-schet.cli-code >= 100000000
                                      and buf_fin-schet.cli-code < 299999999
                                      then "no-check"
                                      else '')
                              ,input-output v-status_) no-error.
          if error-status:error then do:
            v-err-mess = substitute("Запись &1: Ошибка при восстановлении логически удаленного р/с &8 при получении нового для &7&2&3&4&5&4&6"
                                      , p-line-num
                                      , buf_temp-clients_.obj-type
                                      , buf_temp-clients_.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      , buf_sysconf.host-code
                                      , buf_fin-schet.r-schet
                                      ).
            undo main-block, retry main-block.
          end.
        end.
      end.
    end.
    if v-not-found-fin-schet then do:
      for each buf_sysconf no-lock:
        run proc-delete-all-fs in this-procedure (  input p-line-num
                                                  , input buf_sysconf.host-code
                                                  , buffer buf_temp-clients_
                                                  , input 0
                                                  , input "nnn") no-error.
        if error-status:error then do:
          v-err-mess = return-value .
          undo main-block, retry main-block.
        end.
      end.
    end.
    /*
      staff уже не ходит
    if buf_temp-clients_.obj-type = {&prs} then do:
      for each buf_temp-staff_ no-lock where
              buf_temp-staff_.psn-code = buf_temp-clients_.obj-code
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        find first buf_staff share-lock where
                  buf_staff.psn-code = buf_temp-staff_.psn-code
              and buf_staff.role = {&role-cashier}
              and buf_staff.role-level = {&role-level-db}
              and buf_staff.staff-code = buf_temp-staff_.staff-code
              and buf_staff.db-num = g#db-num no-error.
        if available buf_staff then do:
          v-mode = {&update}.
          v-rid = recid(buf_staff).
          v-work-place = string(g#db-num, '99999').
        end.
        else do:
          v-mode = {&add-def}.
          v-rid = ?.
        end.
        run cur-time in this-procedure(output v-today, output v-time).

        run ref/staff01.p (
                       input-output v-rid
                      ,input v-mode
                      ,input yes /*p-silent*/
                      ,input {&role-cashier}
                      ,input buf_temp-staff_.staff-code
                      ,input buf_temp-staff_.psn-code
                      ,input {&role-level-db}
                      ,input (if v-mode = {&add-def} then v-today else buf_staff.date-start)
                      ,input {&end-of-age}
                      ,input g#db-num
                      ,input 0 /*v-host-code*/
                      ,input '' /*v-obj-type*/
                      ,input 0 /*v-obj-code*/
                      ,input (if v-mode = {&update} then buf_staff.work-place else v-work-place)
                      ,input (if v-mode = {&update} then buf_staff.password else string(buf_temp-staff_.staff-code))
                      ) no-error .
        if error-status :error then do:
          v-err-mess = substitute("Запись &1: Ошибка при сохранении staff &2&3&4&5&4&6"
                                    , p-line-num
                                    , buf_temp-clients_.obj-type
                                    , buf_temp-clients_.obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
          undo main-block, retry main-block.
        end.
      end.
      if buf_temp-clients_.stts = integer({&deleted-status-int}) then do:
        for each buf_staff no-lock where
                buf_staff.psn-code = buf_temp-clients_.obj-code
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          v-rid = recid(buf_staff).
          run ref/staff01.p (
                         input-output v-rid
                        ,input {&deletion}
                        ,input yes /*p-silent*/
                        ,input buf_staff.role
                        ,input buf_staff.staff-code
                        ,input buf_staff.psn-code
                        ,input buf_staff.role-level
                        ,input buf_staff.date-start
                        ,input ? /*для удаления*/
                        ,input buf_staff.db-num
                        ,input buf_staff.host-code
                        ,input buf_staff.obj-type
                        ,input buf_staff.obj-code
                        ,input buf_staff.work-place
                        ,input buf_staff.password) no-error .
          if error-status:error then do:
            v-err-mess = substitute("Запись &1: Ошибка при логическом удалении staff  &2&3&4&5&4&6"
                                      , p-line-num
                                      , buf_temp-clients_.obj-type
                                      , buf_temp-clients_.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
            undo main-block, retry main-block.
          end.
        end.
      end.
    end.
    */
    /*здесь делаем договор*/
    if v-mode = {&add-def}
    and buf_temp-clients_.obj-code >= 100000000
    and buf_temp-clients_.obj-code <= 199999999
    then do:
      define variable v-int-ok as integer no-undo .
      /* здесь сохраняем в БД */
      run cur-time in this-procedure ( output v-today, output v-time).
      create buf_temp_contract.
      assign
      buf_temp_contract.contract-code = buf_temp-clients_.obj-code
      buf_temp_contract.contract-date = v-today
      buf_temp_contract.exch-code     = 0
      .
      run utl/ora-i405.p (
          input parparentproc ,
          input this-procedure ,
          input table temp_contract ,
          input table temp_contract-specif ,
          output v-int-ok
          ) no-error .
      if error-status:error then do:
        v-err-mess = substitute("Запись &1: Ошибка при задании договора по &2&3&4&5&4&6"
                                  , p-line-num
                                  , buf_temp-clients_.obj-type
                                  , buf_temp-clients_.obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
         undo main-block, retry main-block.
      end.
    end.
    if not (buf_temp-clients_.obj-type = {&shop} or buf_temp-clients_.obj-type = {&stock})
    then do:
      for each buf_dis-card where
              buf_dis-card.cli-type = buf_temp-clients_.obj-type
          AND buf_dis-card.cli-code = buf_temp-clients_.obj-code:
        run fill-dc-list in p-cont-handle ( buffer buf_Dis-card) .
      end. /*for each*/
    end.
  end. /*ne retry*/
end.
end procedure. /* proc-save */

procedure proc-delete-all-fs :
define input parameter p-line-num as integer no-undo .
define input parameter p-host-code as integer no-undo .
define parameter buffer buf_temp-clients_ for temp-clients_.
define input parameter p-code-bank as integer no-undo .
define input parameter p-r-schet as character no-undo .
define buffer buf_fin-schet  for ub.fin-schet.
define buffer buf_sysconf for ub.sysconf.
define variable v-status_ as character no-undo .
define variable v-err-mess as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  _fs:
  for each buf_fin-schet share-lock where
            buf_fin-schet.host-code = p-host-code
        and buf_fin-schet.cli-type = buf_temp-clients_.obj-type
        and buf_fin-schet.cli-code = buf_temp-clients_.obj-code
  on error  undo main-block, retry main-block
  on stop   undo main-block, retry main-block
  on endkey undo main-block, retry main-block:
    if buf_fin-schet.r-schet = p-r-schet
    and buf_fin-schet.code-bank = p-code-bank
    then next _fs.
    if buf_fin-schet.status_ = {&current-status} then do:
      v-status_ = {&deleted-status}.
      run ref/finscht2.p ( input recid(buf_fin-schet)
                          ,input yes /*p-silent*/
                          ,input "no-check"
                          ,input-output v-status_) no-error.
      if error-status:error then do:
        v-err-mess = substitute("Запись &1: Ошибка при логическом удалении р/с &8 при получении нового для &7&2&3&4&5&4&6"
                                  , p-line-num
                                  , buf_temp-clients_.obj-type
                                  , buf_temp-clients_.obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , p-host-code
                                  , buf_fin-schet.r-schet
                                  ).
        undo main-block, return error v-err-mess.
      end.
    end.
  end.
end. /*doe*/

end procedure. /* proc-delete-all-fs */

procedure pcall-log-file :
define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input p-message ) .

  end.

end procedure. /* pcall-log-file */

/*не удалять!!!!*/