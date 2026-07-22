/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/09
Author: Bakhtadze Natalya
Creation date: 02/13/09


---------------------------&start-codex_id=20;ruleset_id=4;-----------------
Импорт данных по клиентам из XML файла

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12 набор правил 5".
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
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ gbl/orapreps.i }
{ str/pdf-attr.i }


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
define temp-table tt-dis-rule no-undo like ub.dis-rule.
define temp-table tot-dis-rule_ no-undo like ub.dis-rule
field status_ as character
.
define temp-table temp-dis-rule_ no-undo like ub.dis-rule
field pos-type as character
field status_ as character
.
define temp-table temp-dis-gds-rule_ no-undo like ub.dis-gds-rule
field status_ as character
.

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
define variable v-mode as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-present as logical no-undo .
define variable v-current-tbl-name as character no-undo .
define variable v_child-qh as handle no-undo .
define variable v_child2-qh as handle no-undo .
define variable v-status_ as character no-undo .
define variable v-category_id as integer no-undo .
define variable v-discnt-type as character no-undo .
define variable v-category-name as character no-undo .
define variable v-dtl_id as integer no-undo .
define variable v-b-dtl_id as integer no-undo .
define variable v-dtl-category_id as integer no-undo .
define variable v-b-category_id as integer no-undo .
define variable v-discnt as decimal no-undo .
define variable v-dtl-status_ as character no-undo .
define variable v-b-code as integer no-undo .
define variable v-cat-item-status_ as character no-undo .
define variable v-threshold as decimal no-undo .
define variable v-rid as recid no-undo .

define buffer buf_tot-dis-rule_ for tot-dis-rule_.
define buffer term_tot-dis-rule_ for tot-dis-rule_.
define buffer buf_temp-dis-rule_ for temp-dis-rule_.
define buffer buf_temp-dis-gds-rule_ for temp-dis-gds-rule_.
define buffer buf_temp-rel-handle for temp-rel-handle.
define buffer buf2_temp-rel-handle for temp-rel-handle.
define buffer buf_Dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.


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
&scop my-message substitute(".............Импорт данных по скидкам из ВС")
  {&display-message}.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по скидкам из файла &1", file-name)).

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
          empty temp-table buf_tot-dis-rule_.
          empty temp-table buf_temp-dis-rule_.
          empty temp-table buf_temp-dis-gds-rule_.
           if valid-handle(v_qh) then do:
             delete object v_qh no-error.
           end.
           if valid-handle(v_child-qh) then do:
             delete object v_child-qh no-error.
           end.
           if valid-handle(v_child2-qh) then do:
             delete object v_child2-qh no-error.
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
            when "category"  THEN do:
              empty temp-table buf_tot-dis-rule_.
              empty temp-table buf_temp-dis-rule_.
              empty temp-table buf_temp-dis-gds-rule_.
              _tr:
              do {&single-trans}
              on error undo _rule, retry _rule
              :
                v-line-num = ImpData1:route-data_get-field-integer( input "Category", input "line-num") .
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
                v-line-num = ImpData1:route-data_get-field-integer( input "category", input "line-num") .
                v-status_ = ImpData1:route-data_get-field-character( input "category", input "status_") .
                v-category_id = ImpData1:route-data_get-field-integer( input "category", input "category_id") .
                v-discnt-type = ImpData1:route-data_get-field-character( input "category", input "discnt-type") .
                v-category-name = ImpData1:route-data_get-field-character( input "category", input "category_name") .
                case v-discnt-type :
                  when "temp-disc" then do:
                  end.
                  when "pcnt-tot-kateg" then do:
                    find first buf_tot-dis-rule_ where
                              buf_tot-dis-rule_.rule-num = v-category_id no-error.
                    if not available buf_tot-dis-rule_ then do:
                      find first buf_dis-rule no-lock where
                                buf_Dis-rule.rule-num = 20.
                      create  buf_tot-dis-rule_.
                      buffer-copy buf_dis-rule except
                      rule-num
                      time-templ-rl-root
                      root
                      rl-root
                      host-code
                      obj-type
                      obj-code
                      lvl-num
                      is-term
                      sts
                      time-rule-num
                      upper-rule-num
                      to buf_tot-dis-rule_
                      assign
                      buf_tot-dis-rule_.rule-num = v-category_id
                      buf_tot-dis-rule_.templ-rl-root = buf_dis-rule.rule-num
                      buf_tot-dis-rule_.time-templ-rl-root = 0
                      buf_tot-dis-rule_.root = yes
                      buf_tot-dis-rule_.rl-root = buf_tot-dis-rule_.rule-num
                      buf_tot-dis-rule_.host-code = 0
                      buf_tot-dis-rule_.obj-type = ''
                      buf_tot-dis-rule_.obj-code = 0
                      buf_tot-dis-rule_.is-term = no
                      buf_tot-dis-rule_.lvl-num = 1
                      buf_tot-dis-rule_.sts = integer({&used-status-int})
                      buf_tot-dis-rule_.time-rule-num = 0
                      buf_tot-dis-rule_.upper-rule-num = buf_dis-rule.rule-num
                      .
                    end.
                    assign
                    buf_tot-dis-rule_.des = v-category-name
                    buf_tot-dis-rule_.status_ = v-status_
                    .
                  end.
                end case.
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
                      v-dtl_id = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "dtl_id") .
                      v-dtl-category_id = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "category_id") .
                      v-discnt = ImpData1:route-data_get-field-decimal( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "discount") .
                      v-dtl-status_ = ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "status_") .
                      if v-dtl-category_id <> v-category_id then do:
                        /*нарушение протокола которое не можем отследить через схему*/
                        &scop my-message substitute("Запись &1: нарушение схемы")
                        {&display-message}.
                        delete object v_child-qh no-error.
                        undo _rule, retry _rule.
                      end.
                      case buf_temp-rel-handle.child-buffer_:
                        when "cat-dtl" THEN do:
                          case v-discnt-type:
                            when "temp-disc" then do:
                              /*пишем и для 82 и для 85*/
                              define variable v-jj as integer no-undo .
                              define variable v-pos-type as character no-undo .
                              do v-jj = 1 to 2:
                                if v-jj = 1 then do:
                                  find first buf_dis-rule no-lock where
                                            buf_dis-rule.rule-num = 82 .
                                  v-pos-type = {&cd-type-ibm}.
                                end.
                                if v-jj = 2 then do:
                                  find first buf_dis-rule no-lock where
                                            buf_dis-rule.rule-num = 85 .
                                  v-pos-type = {&cd-type-ibs-th}.
                                end.
                                find first buf_temp-dis-rule_ where
                                          buf_temp-dis-rule_.rule-num = v-dtl_id
                                      and buf_temp-dis-rule_.templ-rl-root = buf_dis-rule.rule-num
                                      no-error.
                                if not available buf_temp-dis-rule_ then do:
                                  find first buf_dis-time-rule no-lock where
                                            buf_dis-time-rule.templ-rl-root = 50001 .
                                  create  buf_temp-dis-rule_.
                                  buffer-copy buf_dis-rule
                                  except
                                  rule-num
                                  time-templ-rl-root
                                  root
                                  rl-root
                                  host-code
                                  obj-type
                                  obj-code
                                  lvl-num
                                  is-term
                                  sts
                                  time-rule-num
                                  upper-rule-num
                                  to
                                  buf_temp-dis-rule_
                                  assign
                                  buf_temp-dis-rule_.rule-num = v-dtl_id
                                  buf_temp-dis-rule_.time-templ-rl-root = 50001
                                  buf_temp-dis-rule_.root = yes
                                  buf_temp-dis-rule_.rl-root = v-dtl_id
                                  buf_temp-dis-rule_.host-code = 0
                                  buf_temp-dis-rule_.obj-type = ''
                                  buf_temp-dis-rule_.obj-code = 0
                                  buf_temp-dis-rule_.lvl-num = 1
                                  buf_temp-dis-rule_.is-term = yes
                                  buf_temp-dis-rule_.sts = integer({&used-status-int})
                                  buf_temp-dis-rule_.time-rule-num = buf_dis-time-rule.time-rule-num
                                  buf_temp-dis-rule_.upper-rule-num =  buf_dis-rule.rule-num
                                  buf_temp-dis-rule_.pos-type = v-pos-type
                                  .
                                end. /*if not available buf_temp-dis-rule_ then do:*/
                                buf_temp-dis-rule_.des = v-category-name.
                                buf_temp-dis-rule_.status_ = v-dtl-status_.
                                buf_temp-dis-rule_.discnt-value = v-discnt.
                                release buf_temp-dis-rule_.
                              end.  /*do v-jj*/
                              for each buf_temp-dis-rule_:
                              _rel2:
                              for each buf2_temp-rel-handle where
                                      buf2_temp-rel-handle.parent-buffer_ = "cat-dtl":
                                run tmpreld2_query in this-procedure ( buffer buf2_temp-rel-handle, input-output v_child2-qh) no-error .
                                if error-status:error then do:
                                  &scop my-message return-value
                                  {&display-message}.
                                  undo _rule, retry _rule.
                                end.
                                _child2:
                                repeat:
                                  v_child2-qh:get-next().
                                  IF v_child2-qh:query-off-end then do:
                                    delete object v_child2-qh no-error.
                                    next _rel2.
                                  end.
                                  case buf2_temp-rel-handle.child-buffer_:
                                    when "cat-item" THEN do:
                                      v-b-code = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "b-code") .
                                      v-b-dtl_id = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "dtl_id") .
                                      v-b-category_id = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "category_id") .
                                      v-cat-item-status_ = ImpData1:route-data_get-field-character( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "status_") .
                                      if v-dtl_id <> v-b-dtl_id
                                      or v-b-category_id <> v-category_id
                                      then do:
                                        /*нарушение протокола которое не можем отследить через схему*/
                                        &scop my-message substitute("Запись &1: нарушение схемы")
                                        {&display-message}.
                                        delete object v_child-qh no-error.
                                        delete object v_child2-qh no-error.
                                        undo _rule, retry _rule.
                                      end.
                                      find first buf_temp-dis-gds-rule_ where
                                              buf_temp-dis-gds-rule_.templ-rl-root = buf_temp-dis-rule_.templ-rl-root
                                          and buf_temp-dis-gds-rule_.obj-type = ''
                                          and buf_temp-dis-gds-rule_.obj-code = 0
                                          and buf_temp-dis-gds-rule_.discnt-role = {&dgr-temp-disc}
                                          and buf_temp-dis-gds-rule_.rule-num = buf_temp-dis-rule_.rule-num
                                          and buf_temp-dis-gds-rule_.gds-code = 0
                                          and buf_temp-dis-gds-rule_.pos-type = buf_temp-dis-rule_.pos-type
                                          and buf_temp-dis-gds-rule_.nonunique = string(v-b-code)  no-error.
                                      if not available buf_temp-dis-gds-rule_ then do:
                                        create  buf_temp-dis-gds-rule_.
                                        assign
                                        buf_temp-dis-gds-rule_.obj-type = ''
                                        buf_temp-dis-gds-rule_.obj-code = 0
                                        buf_temp-dis-gds-rule_.templ-rl-root = buf_temp-dis-rule_.templ-rl-root
                                        buf_temp-dis-gds-rule_.discnt-role = {&dgr-temp-disc}
                                        buf_temp-dis-gds-rule_.time-templ-rl-root = buf_temp-dis-rule_.time-templ-rl-root
                                        buf_temp-dis-gds-rule_.gds-code = 0
                                        buf_temp-dis-gds-rule_.pos-type = {&cd-type-ibm}
                                        buf_temp-dis-gds-rule_.nonunique = string(v-b-code)
                                        buf_temp-dis-gds-rule_.rule-num = v-dtl_id
                                        buf_temp-dis-gds-rule_.rl-root = buf_temp-dis-rule_.rule-num
                                        .
                                      end.
                                      buf_temp-dis-gds-rule_.status_ = v-cat-item-status_.
                                      release buf_temp-dis-gds-rule_ .
                                    end. /*when "cat-item" */
                                  end case. /*case buf2_temp-rel-handle.child-buffer_:*/
                                end. /*repeat*/
                                delete object v_child2-qh no-error.
                              end. /*                        for each buf2_temp-rel-handle where*/
                              release buf_temp-dis-rule_.
                              end.  /*dfor each buf_temp-dis-rule*/
                            end. /*  when "temp-disc" then do:*/
                            when "pcnt-tot-kateg" then do:
                              v-threshold = ImpData1:route-data_get-field-decimal( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "threshold") .
                              find first term_tot-dis-rule_ where
                                        term_tot-dis-rule_.rule-num = v-dtl_id no-error.
                            if not available term_tot-dis-rule_ then do:
                                create term_tot-dis-rule_.
                                buffer-copy buf_tot-dis-rule_
                                except rule-num
                                upper-rule-num
                                lvl-num
                                root
                                is-term
                                sts
                                to term_tot-dis-rule_
                                assign
                                term_tot-dis-rule_.upper-rule-num = v-category_id
                                term_tot-dis-rule_.rule-num = v-dtl_id
                                term_tot-dis-rule_.lvl-num = 2
                                term_tot-dis-rule_.root = no
                                term_tot-dis-rule_.is-term = yes
                                  term_tot-dis-rule_.status_ = v-dtl-status_
                                term_tot-dis-rule_.sts = integer({&non-root-status-int})
                                .
                              end.
                              assign
                              term_tot-dis-rule_.tot-sum = v-threshold
                              term_tot-dis-rule_.des = string(term_tot-dis-rule_.tot-sum)
                              term_tot-dis-rule_.discnt-value = v-discnt
                              term_tot-dis-rule_.status_ = v-dtl-status_
                              .
                                release term_tot-dis-rule_.
                            end.
                          end case.
                        end. /*when temp-cat-dtl */
                      end case. /*                case buf_temp-rel-handle_.child-buffer_:*/
                  end. /*                    repeat:*/
                  delete object v_child-qh no-error.
                end. /*              for each buf_temp-rel-handle where*/
                case v-discnt-type:
                  when "temp-disc" then do:
                    run proc-save-temp-disc-rule in this-procedure (  input v-line-num
                                                      ,input v-status_
                                                      ) no-error.
                  end.
                  when "pcnt-tot-kateg" then do:
                     run proc-save-tot-pcnt in this-procedure ( input v-line-num
                                                       ,input v-status_
                                                       ,buffer buf_tot-dis-rule_) no-error.

                  end.
                end case.
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
            end. /*when "CAtegory"*/
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
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
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
        find first buf_dis-time-rule no-lock where
                  buf_Dis-time-rule.templ-rl-root = 50001 no-error.
        if not available buf_Dis-time-rule then do:
          &scop my-message substitute("Не найдено расписание правил скидок с типом ВСЕГДА")
          {&display-message}.
          undo, return error {&my-message}.
        end.
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = 20 no-error.
        if not available buf_Dis-rule then do:
          &scop my-message substitute("Не найден ШАБЛОН правил скидок 20")
          {&display-message}.
          undo, return error {&my-message}.
        end.
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = 82 no-error.
        if not available buf_Dis-rule then do:
          &scop my-message substitute("Не найден ШАБЛОН правил скидок 82 (POS IBM)")
          {&display-message}.
          undo, return error {&my-message}.
        end.
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = 85 no-error.
        if not available buf_Dis-rule then do:
          &scop my-message substitute("Не найден ШАБЛОН правил скидок 85 (POS IBS TH)")
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
      for each temp-dis-rule_:
        delete temp-dis-rule_.
      end.
      for each tot-dis-rule_:
        delete tot-dis-rule_.
      end.
      for each temp-dis-gds-rule_:
        delete temp-dis-gds-rule_.
      end.

      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure proc-save-temp-disc-rule :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-status_ as character no-undo .

define variable v-rid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-work-place as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-err-mess as character no-undo .
define variable v-is-terminal as logical no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable dflt-cd as character no-undo .

define buffer buf_temp-dis-gds-rule_ for temp-dis-gds-rule_.
define buffer buf_clients for ub.clients.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_temp-dis-rule_ for temp-dis-rule_.
define buffer term_tt-dis-rule for tt-dis-rule.
define buffer buf_bar-code for ub.bar-code.


main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table temp-dis-rule_.
    empty temp-table temp-dis-gds-rule_.
    empty temp-table tot-dis-rule_.
    &scop my-message v-err-mess
    {&display-message}.
    return error ''.
  end.
  else do:
    case p-status_:
      when {&ora-line-delete} then do:
        _buf-clients:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = {&shop}
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          dflt-cd = ''.
          { gbl/dflt-cd.i buf_Clients.obj-type buf_clients.obj-code dflt-cd }
          case dflt-cd :
            when {&cd-type-ibm} then do:
              v-templ-rl-root = 82.
            end.
            when {&cd-type-ibs-th} then do:
              v-templ-rl-root = 85.
            end.
            otherwise do:
               next _buf-clients.
            end.
          end.
          for each buf_dis-rule share-lock where
                buf_dis-rule.host-code = buf_clients.host-code
            and buf_dis-rule.obj-type = buf_clients.obj-type
            and buf_dis-rule.obj-code = buf_clients.obj-code
            and buf_dis-rule.templ-rl-root = v-templ-rl-root
          on error  undo main-block, retry main-block
          on stop   undo main-block, retry main-block
          on endkey undo main-block, retry main-block
          :
            for each buf_dis-gds-rule share-lock where
                    buf_dis-gds-rule.obj-type = buf_clients.obj-type
                and buf_dis-gds-rule.obj-type = buf_clients.obj-type
                and buf_dis-gds-rule.templ-rl-root = buf_dis-rule.templ-rl-root
                and buf_dis-gds-rule.discnt-role = {&dgr-temp-disc}
                and buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
            on error  undo main-block, retry main-block
            on stop   undo main-block, retry main-block
            on endkey undo main-block, retry main-block
            :
              run fill-g-list in  p-cont-handle  ( input buf_dis-gds-rule.gds-code
                                                 , input buf_clients.obj-type
                                                 , input buf_clients.obj-code).
              delete buf_Dis-gds-rule no-error.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при удалении привязки к правилу временных скидок &1 (типа &2) по &3&4 товар &8:&5&6&5&7"
                                        , buf_dis-rule.rule-num
                                        , buf_dis-rule.templ-rl-root
                                        , buf_clients.obj-type
                                        , buf_clients.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        , buf_dis-gds-rule.gds-code
                                        ).
                undo main-block, retry main-block .
              end.
            end.
            delete buf_dis-rule no-error.
            if error-status:error then do:
              v-err-mess = substitute("Ошибка при удалении к правила временных скидок &1 (типа &2) по &3&4:&5&6&5&7"
                                      , buf_dis-rule.rule-num
                                      , buf_dis-rule.templ-rl-root
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
              undo main-block, retry main-block .
            end.
          end.  /*for each buf_dis-rule*/
        end. /*for each buf_clients*/
      end. /*when {&ora-line-delete} then do:*/
      when {&ora-line-create}
      or
      when {&ora-line-update}
      then do:
        _buf-clients:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = {&shop}
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          dflt-cd = ''.
          { gbl/dflt-cd.i buf_Clients.obj-type buf_clients.obj-code dflt-cd }
          case dflt-cd :
            when {&cd-type-ibm} then do:
              v-templ-rl-root = 82.
            end.
            when {&cd-type-ibs-th} then do:
              v-templ-rl-root = 85.
            end.
            otherwise do:
               next _buf-clients.
            end.
          end.
          for each buf_temp-dis-rule_
          on error  undo main-block, retry main-block
          on stop   undo main-block, retry main-block
          on endkey undo main-block, retry main-block
          :
            if v-templ-rl-root <> buf_temp-dis-rule_.templ-rl-root then next .
            if buf_temp-dis-rule_.status_ = {&ora-line-delete} then do:
              for each buf_dis-rule share-lock where
                    buf_dis-rule.host-code = buf_clients.host-code
                and buf_dis-rule.obj-type = buf_clients.obj-type
                and buf_dis-rule.obj-code = buf_clients.obj-code
                and buf_dis-rule.templ-rl-root = v-templ-rl-root
              on error  undo main-block, retry main-block
              on stop   undo main-block, retry main-block
              on endkey undo main-block, retry main-block
              :
                if buf_dis-rule.discnt-value = buf_temp-dis-rule_.discnt-value then do:
                  for each buf_dis-gds-rule share-lock where
                          buf_dis-gds-rule.obj-type = buf_clients.obj-type
                      and buf_dis-gds-rule.obj-type = buf_clients.obj-type
                      and buf_dis-gds-rule.templ-rl-root = buf_dis-rule.templ-rl-root
                      and buf_dis-gds-rule.discnt-role = {&dgr-temp-disc}
                      and buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
                  on error  undo main-block, retry main-block
                  on stop   undo main-block, retry main-block
                  on endkey undo main-block, retry main-block
                  :
                    run fill-g-list in  p-cont-handle  ( input buf_dis-gds-rule.gds-code
                                                      , input buf_clients.obj-type
                                                      , input buf_clients.obj-code).
                    delete buf_Dis-gds-rule no-error.
                    if error-status:error then do:
                      v-err-mess = substitute("Ошибка при удалении привязки к правилу временных скидок &1 (типа &2) по &3&4 товар &8:&5&6&5&7"
                                              , buf_dis-rule.rule-num
                                              , buf_dis-rule.templ-rl-root
                                              , buf_clients.obj-type
                                              , buf_clients.obj-code
                                              , {&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                              , buf_dis-gds-rule.gds-code
                                              ).
                      undo main-block, retry main-block .
                    end.
                  end.
                  delete buf_dis-rule no-error.
                  if error-status:error then do:
                    v-err-mess = substitute("Ошибка при удалении к правила временных скидок &1 (типа &2) по &3&4:&5&6&5&7"
                                            , buf_dis-rule.rule-num
                                            , buf_dis-rule.templ-rl-root
                                            , buf_clients.obj-type
                                            , buf_clients.obj-code
                                            , {&new-line}
                                            , error-status:get-message(1)
                                            , return-value
                                            ).
                    undo main-block, retry main-block .
                  end.
                end.
              end.  /*for each buf_dis-rule*/
            end. /*if buf_temp-dis-rule_.status_ = {&ora-line-delete} then do:*/
            else do:
            find first buf_dis-rule share-lock where
                      buf_Dis-rule.host-code = buf_clients.host-code
                  and buf_Dis-rule.obj-type = buf_clients.obj-type
                  and buf_Dis-rule.obj-type = buf_clients.obj-type
                  and buf_Dis-rule.templ-rl-root = v-templ-rl-root
                  and buf_Dis-rule.is-term = yes
                  and buf_Dis-rule.discnt-value = buf_temp-dis-rule_.discnt-value no-error.
            if not available buf_dis-rule
            and buf_temp-dis-rule_.status_ <> {&ora-line-create} then do:
              v-err-mess = substitute("Ошибка при изменении/удалении правила временных скидок с процентом &1 (типа &2)&3нет правила"
                                      , buf_temp-dis-rule_.discnt-value
                                      , buf_temp-dis-rule_.templ-rl-root
                                      , {&new-line}
                                      ).
              run set-err-type in p-cont-handle
                ( input {&ora-err-type-SYNCHRONIZATION}
                ) no-error.
              undo main-block, retry main-block .
            end.
            /*
            ORA НИЧЕГО НЕ МОЖЕТ НОРМАЛЬНО ОТПРАВИТЬ!!!!!!!!!!!!!!!!
            if available buf_dis-rule
            and buf_temp-dis-rule_.status_ = {&ora-line-create} then do:
              v-err-mess = substitute("Ошибка при добавлении правила временных скидок с процентом &1 (типа &2)&3 уже есть такое правило"
                                      , buf_temp-dis-rule_.discnt-value
                                      , buf_temp-dis-rule_.templ-rl-root
                                      , {&new-line}
                                      ).
              run set-err-type in p-cont-handle
                ( input {&ora-err-type-SYNCHRONIZATION}
                ) no-error.
              undo main-block, retry main-block .
            end.
            */
            if not available buf_dis-rule then do:
              v-rid = ?.
              run ref/dis-rul1.p (
              input ? /* p-rule-num */
              ,input dflt-cd
              ,input buf_temp-dis-rule_.templ-rl-root
              ,input buf_temp-dis-rule_.templ-rl-root
              ,input buf_temp-dis-rule_.des
              ,input buf_temp-dis-rule_.dis-kat
              ,input buf_temp-dis-rule_.discnt-type
              ,input buf_temp-dis-rule_.doc-qnty
              ,input buf_temp-dis-rule_.tot-sum
              ,input buf_temp-dis-rule_.charkey_one
              ,input buf_temp-dis-rule_.charkey_two
              ,input buf_temp-dis-rule_.charkey_three
              ,input buf_temp-dis-rule_.deckey_one
              ,input buf_temp-dis-rule_.deckey_two
              ,input buf_temp-dis-rule_.deckey_three
              ,input buf_temp-dis-rule_.key#_one
              ,input buf_temp-dis-rule_.key#_two
              ,input buf_temp-dis-rule_.key#_three
              ,input buf_temp-dis-rule_.subject-type
              ,input buf_temp-dis-rule_.time-templ-rl-root
              ,input buf_temp-dis-rule_.time-rule-num
              ,input buf_temp-dis-rule_.upper-rule-num
              ,input buf_temp-dis-rule_.value-type
              ,input buf_clients.host-code
              ,INPUT buf_clients.obj-type
              ,INPUT buf_clients.obj-code
              ,INPUT buf_temp-dis-rule_.discnt-value
              ,input table term_tt-dis-rule
              ,input-output v-rid
              ,input {&add-def}
              ,input yes /*p-silent */
              ) NO-ERROR.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при создании правила временной скидки с % &6 в &1&2:&3&4&3&5"
                                        , buf_clients.obj-type
                                        , buf_clients.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        , buf_temp-dis-rule_.discnt-value
                                        ).

              end.
              find first buf_dis-rule share-lock where
                      recid(buf_dis-rule) = v-rid .
            end. /*if not available buf_dis-rule then do*/
            else do:
              if buf_temp-dis-rule_.status_ <> {&ora-line-delete} then do:
                v-rid = recid(buf_dis-rule).
                run ref/dis-rul1.p (
                input buf_dis-rule.rule-num /* p-rule-num */
                ,input dflt-cd
                ,input buf_dis-rule.rl-root
                ,input buf_dis-rule.templ-rl-root
                ,input buf_temp-dis-rule_.des
                ,input buf_dis-rule.dis-kat
                ,input buf_dis-rule.discnt-type
                ,input buf_dis-rule.doc-qnty
                ,input buf_dis-rule.tot-sum
                ,input buf_dis-rule.charkey_one
                ,input buf_dis-rule.charkey_two
                ,input buf_dis-rule.charkey_three
                ,input buf_dis-rule.deckey_one
                ,input buf_dis-rule.deckey_two
                ,input buf_dis-rule.deckey_three
                ,input buf_dis-rule.key#_one
                ,input buf_dis-rule.key#_two
                ,input buf_dis-rule.key#_three
                ,input buf_dis-rule.subject-type
                ,input buf_dis-rule.time-templ-rl-root
                ,input buf_dis-rule.time-rule-num
                ,input buf_dis-rule.upper-rule-num
                ,input buf_dis-rule.value-type
                ,input buf_clients.host-code
                ,INPUT buf_clients.obj-type
                ,INPUT buf_clients.obj-code
                ,INPUT buf_temp-dis-rule_.discnt-value
                ,input table term_tt-dis-rule
                ,input-output v-rid
                ,input {&update}
                ,input yes /*p-silent */
                ) NO-ERROR.
                if error-status:error then do:
                  v-err-mess = substitute("Ошибка при изменении правила временной скидки с % &6 в &1&2:&3&4&3&5"
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          , buf_temp-dis-rule_.discnt-value
                                          ).
                end.
              end.
            end.
              for each buf_temp-dis-gds-rule_ where
                      buf_temp-dis-gds-rule_.rule-num = buf_temp-dis-rule_.rule-num
              on error  undo main-block, retry main-block
              on stop   undo main-block, retry main-block
              on endkey undo main-block, retry main-block
              :
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = integer(buf_temp-dis-gds-rule_.nonunique) no-error.
                if not available buf_bar-code then do:
                  v-err-mess = substitute("Ошибка при изменении/добавлении/удалении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6не найден бар-код"
                                          , buf_temp-dis-rule_.discnt-value
                                          , buf_temp-dis-rule_.templ-rl-root
                                          , buf_temp-dis-gds-rule_.nonunique
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , {&new-line}
                                          ).
                  run set-err-type in p-cont-handle
                    ( input {&ora-err-type-SYNCHRONIZATION}
                    ) no-error.
                  undo main-block, retry main-block .
                end.
                assign
                buf_temp-dis-gds-rule_.gds-code = buf_bar-code.gds-code.
                find first buf_dis-gds-rule share-lock where
                        buf_Dis-gds-rule.obj-type = buf_clients.obj-type
                    and buf_Dis-gds-rule.obj-code = buf_clients.obj-code
                    and buf_Dis-gds-rule.pos-type = dflt-cd
                    and buf_Dis-gds-rule.templ-rl-root = buf_temp-Dis-rule_.templ-rl-root
                    and buf_Dis-gds-rule.gds-code = buf_temp-dis-gds-rule_.gds-code
                    and buf_Dis-gds-rule.discnt-role = buf_temp-dis-gds-rule_.discnt-role
                    and buf_Dis-gds-rule.nonunique = buf_temp-dis-gds-rule_.nonunique
                    and buf_Dis-gds-rule.rule-num = buf_dis-rule.rule-num
                    no-error.
                if not available buf_dis-gds-rule
                and buf_temp-dis-gds-rule_.status_ = {&ora-line-delete} then do:
                  v-err-mess = substitute("Ошибка при удалении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6не найдена привязка"
                                          , buf_temp-dis-rule_.discnt-value
                                          , buf_temp-dis-rule_.templ-rl-root
                                          , buf_temp-dis-gds-rule_.nonunique
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , {&new-line}
                                          ).
                  run set-err-type in p-cont-handle
                    ( input {&ora-err-type-SYNCHRONIZATION}
                    ) no-error.
                  undo main-block, retry main-block .
                end.
              /*
                if available buf_dis-gds-rule
                and buf_temp-dis-gds-rule_.status_ <> {&ora-line-delete} then do:
                  v-err-mess = substitute("Ошибка при добавлении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6уже есть привязка"
                                          , buf_temp-dis-rule_.discnt-value
                                          , buf_temp-dis-rule_.templ-rl-root
                                          , buf_temp-dis-gds-rule_.nonunique
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , {&new-line}
                                          ).
                  run set-err-type in p-cont-handle
                    ( input {&ora-err-type-SYNCHRONIZATION}
                    ) no-error.
                  undo main-block, retry main-block .
                end.
              */
                if not available buf_dis-gds-rule then do:
                  find first buf_dis-gds-rule share-lock where
                          buf_Dis-gds-rule.obj-type = buf_clients.obj-type
                      and buf_Dis-gds-rule.obj-code = buf_clients.obj-code
                      and buf_Dis-gds-rule.pos-type = dflt-cd
                      and buf_Dis-gds-rule.templ-rl-root = buf_temp-Dis-rule_.templ-rl-root
                      and buf_Dis-gds-rule.gds-code = buf_temp-dis-gds-rule_.gds-code
                      and buf_Dis-gds-rule.discnt-role = buf_temp-dis-gds-rule_.discnt-role
                    and buf_dis-gds-rule.nonunique  = buf_temp-dis-gds-rule_.nonunique
                      no-error.
                  if available buf_dis-gds-rule
                  and buf_dis-gds-rule.nonunique = ''
                  then do:
                    v-err-mess = substitute("Ошибка при добавлении/изменении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6уже есть привязка К ПРАВИЛУ ДРУГОГО ТИПА"
                                            , buf_temp-dis-rule_.discnt-value
                                            , buf_temp-dis-rule_.templ-rl-root
                                            , buf_temp-dis-gds-rule_.nonunique
                                            , buf_clients.obj-type
                                            , buf_clients.obj-code
                                            , {&new-line}
                                            ).
                    run set-err-type in p-cont-handle
                      ( input {&ora-err-type-SYNCHRONIZATION}
                      ) no-error.
                    undo main-block, retry main-block .
                end. /*if available buf_dis-gds-rule*/
                if not available buf_dis-gds-rule
                and (buf_temp-dis-rule_.status_ = {&ora-line-create}
                      or
                      buf_temp-dis-rule_.status_ = {&ora-line-update}
                      )
                then do:
                  create buf_dis-gds-rule.
                  buffer-copy buf_temp-dis-gds-rule_
                  except
                  rule-num
                  rl-root
                  to buf_dis-gds-rule
                  assign
                  buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
                  buf_dis-gds-rule.rl-root = buf_dis-rule.rule-num
                buf_dis-gds-rule.obj-type = buf_clients.obj-type
                buf_dis-gds-rule.obj-code = buf_clients.obj-code
                buf_dis-gds-rule.nonunique  = buf_temp-dis-gds-rule_.nonunique
                  .
              end.
              run fill-g-list in  p-cont-handle  ( input buf_dis-gds-rule.gds-code
                                                 , input buf_clients.obj-type
                                                 , input buf_clients.obj-code).
                if (buf_temp-dis-rule_.status_ = {&ora-line-create}
                      or
                      buf_temp-dis-rule_.status_ = {&ora-line-update}
                      ) then do:
                    assign
                    buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
                    .
                    release buf_Dis-gds-rule no-error.
                end.
                if buf_temp-dis-rule_.status_ = {&ora-line-delete} then do:
                  delete buf_Dis-gds-rule no-error.
                end.
                if error-status:error then do:
                    v-err-mess = substitute("Ошибка при создании привязки правила временной скидки с % &6 к бар-коду &7 в &1&2:&3&4&3&5"
                                            , buf_clients.obj-type
                                            , buf_clients.obj-code
                                            , {&new-line}
                                            , error-status:get-message(1)
                                            , return-value
                                            , buf_temp-dis-rule_.discnt-value
                                            , buf_temp-dis-gds-rule_.nonunique
                                            ).
                  end.
                end.
              end. /*              for each buf_temp-dis-gds-rule_ where*/
            if buf_temp-dis-rule_.status_ <> {&ora-line-delete} then do:
              for each buf_dis-gds-rule no-lock where
                      buf_Dis-gds-rule.rule-num = buf_dis-rule.rule-num:
                run fill-g-list in p-cont-handle ( input buf_dis-gds-rule.gds-code
                                                ,input buf_dis-gds-rule.obj-type
                                                ,input buf_dis-gds-rule.obj-code
                                                ).
              end.
              end. /*if buf_temp-dis-rule_.status_ <> {&ora-line-delete} then do:*/
            end. /*else if <> {&ora-line-delete} */
          end. /*          for each buf_temp-dis-rule_*/
        end. /*for each buf_clients no-lock where*/
      end. /*when {&ora-line-create}*/
    end case.
  end. /*ne retry*/
end.
end procedure. /* proc-save-temp-disc-rule */

procedure proc-save-tot-pcnt :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-status_ as character no-undo .
define parameter buffer buf_tot-dis-rule_ for tot-dis-rule_.

define variable v-rid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-err-mess as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable ii as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-sts as integer no-undo .

define buffer term_tot-dis-rule_ for tot-dis-rule_.
define buffer buf_term-dis-rule for ub.dis-rule.
define buffer buf_clients for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer term_tt-dis-rule for tt-dis-rule.


main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table tot-dis-rule_.
    &scop my-message v-err-mess
    {&display-message}.
    return error ''.
  end.
  else do:
    case p-status_:
      when {&ora-line-delete}  then do:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = {&shop}
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          dflt-cd = ''.
          { gbl/dflt-cd.i buf_Clients.obj-type buf_clients.obj-code dflt-cd }
          find first buf_dis-thbj-rule share-lock where
                    buf_dis-thbj-rule.obj-type = buf_clients.obj-type
                and buf_dis-thbj-rule.obj-code = buf_clients.obj-code
                and buf_dis-thbj-rule.host-code = buf_clients.host-code
                and buf_dis-thbj-rule.pos-type = dflt-cd
                and buf_dis-thbj-rule.discnt-role = {&dthbjr-pcnt-tot-kateg}
                and buf_dis-thbj-rule.nonunique = '' no-error.
          if available buf_dis-thbj-rule then do:
            v-rule-num = buf_dis-thbj-rule.rule-num.
            v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root.
            find first buf_Dis-rule exclusive-lock where
                     buf_Dis-rule.rule-num = v-rule-num no-error.
            delete buf_dis-thbj-rule no-error.
            if error-status:error then do:
              v-err-mess = substitute("Ошибка при удалении привязки к правилу скидок на итог &1 (типа &2) по &3&4:&5&6&5&7"
                                      , v-rule-num
                                      , v-templ-rl-root
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
              undo main-block, retry main-block .
            end.
            if available buf_dis-rule then do:
              run ref/disrul30.p (
                                buffer buf_dis-rule
                              ) no-error.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при удалении правила скидок на итог &1 (типа &2):&3&4&3&5"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
                undo main-block, retry main-block .
              end.
            end.
          end.
        end. /*        for each buf_clients no-lock where*/
      end. /*{&ora-line-delete} */
      when {&ora-line-update} then do:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = {&shop}
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          empty temp-table term_tt-dis-rule.
          for each term_tot-dis-rule_ where
                 term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num:
            /*удаляем записи которые не изменились и мы сами их создани - в файле их не было*/
            if term_tot-dis-rule_.status_ = '' then delete term_tot-dis-rule_.
          end.
          dflt-cd = ''.
          { gbl/dflt-cd.i buf_Clients.obj-type buf_clients.obj-code dflt-cd }
          find first buf_dis-thbj-rule share-lock where
                    buf_dis-thbj-rule.obj-type = buf_clients.obj-type
                and buf_dis-thbj-rule.obj-code = buf_clients.obj-code
                and buf_dis-thbj-rule.host-code = buf_clients.host-code
                and buf_dis-thbj-rule.pos-type = dflt-cd
                and buf_dis-thbj-rule.discnt-role = {&dthbjr-pcnt-tot-kateg}
                and buf_dis-thbj-rule.nonunique = '' no-error.
          if available buf_dis-thbj-rule then do:
            v-rule-num = buf_dis-thbj-rule.rule-num.
            v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root.
            find first buf_Dis-rule exclusive-lock where
                     buf_Dis-rule.rule-num = v-rule-num no-error.
            if available buf_dis-rule then do:
              /*сравним что изменилось*/
              ii = 0.
              for each term_tot-dis-rule_ where
                     term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
              by term_tot-dis-rule_.tot-sum  descending
              :
                ii = ii + 1.
                find first buf_term-dis-rule no-lock where
                          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
                      and buf_term-dis-rule.tot-sum = term_tot-dis-rule_.tot-sum no-error.
                if not available buf_term-dis-rule
                and term_tot-dis-rule_.status_ <> {&ora-line-create} then do:
                  v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3нет ветки с суммой &4"
                                          , v-rule-num
                                          , v-templ-rl-root
                                          , {&new-line}
                                          , term_tot-dis-rule_.tot-sum
                                          ).
                  run set-err-type in p-cont-handle
                    ( input {&ora-err-type-SYNCHRONIZATION}
                    ) no-error.
                  undo main-block, retry main-block .
                end. /*if not available buf_term-dis-rule*/
                if available buf_term-dis-rule
                and term_tot-dis-rule_.status_ = {&ora-line-create} then do:
                  v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3уже есть ветка с суммой &4"
                                          , v-rule-num
                                          , v-templ-rl-root
                                          , {&new-line}
                                          , term_tot-dis-rule_.tot-sum
                                          ).
                  run set-err-type in p-cont-handle
                    ( input {&ora-err-type-SYNCHRONIZATION}
                    ) no-error.
                  undo main-block, retry main-block .
                end.
                if available buf_term-dis-rule
                and term_tot-dis-rule_.status_ = {&ora-line-update}
                and term_tot-dis-rule_.tot-sum = buf_term-dis-rule.tot-sum
                then do:
                  v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3ветка с суммой &4 уже имеет скидку &5"
                                          , v-rule-num
                                          , v-templ-rl-root
                                          , {&new-line}
                                          , term_tot-dis-rule_.tot-sum
                                          , term_tot-dis-rule_.discnt-value
                                          ).
                  run set-err-type in p-cont-handle
                    ( input {&ora-err-type-SYNCHRONIZATION}
                    ) no-error.
                  undo main-block, retry main-block .
                end.
              end. /*for each term_tot-dis-rule where */
              ii = 0.
              /*точ то есть сейчас в БД скопируем во врем таблицу - для тех записей которые не пришли из ORA*/
              for each buf_term-dis-rule no-lock where
                      buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
                find first term_tot-dis-rule_ where
                          term_tot-dis-rule_.tot-sum = buf_term-dis-rule.tot-sum no-error.
                if not available term_tot-dis-rule_ then do:
                  ii = ii + 1.
                  create term_tot-dis-rule_.
                  buffer-copy buf_term-dis-rule
                  except rule-num upper-rule-num rl-root des
                  to  term_tot-dis-rule_
                  assign
                  term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
                  term_tot-dis-rule_.rl-root = buf_tot-dis-rule_.rule-num
                  term_tot-dis-rule_.rule-num = - ii
                  .
                  release term_tot-dis-rule_.
                end.
              end. /*for each buf_term-dis-rule no-lock where*/
              /*теперь перенесем в другу. таблицу - для сохранения*/
              ii = 0.
              for each term_tot-dis-rule_ where
                     term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
              by term_tot-dis-rule_.tot-sum  descending
              :
                if term_tot-dis-rule_.status_ <> {&ora-line-delete} then do:
                  ii = ii + 1.
                  create term_tt-dis-rule.
                  buffer-copy term_tot-dis-rule_
                  except rule-num upper-rule-num des rl-root host-code obj-type obj-code
                  to
                  term_tt-dis-rule
                  assign
                  term_tt-dis-rule.rule-num = ii
                  term_tt-dis-rule.upper-rule-num = term_tot-dis-rule_.templ-rl-root
                  term_tt-dis-rule.rl-root = term_tot-dis-rule_.templ-rl-root
                  term_tt-dis-rule.host-code = buf_clients.host-code
                  term_tt-dis-rule.obj-type = buf_clients.obj-type
                  term_tt-dis-rule.obj-code = buf_clients.obj-code
                  term_tt-dis-rule.des =  term_tt-dis-rule.des + (IF term_tt-dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                              substitute("&1 &2"
                                                        ,(IF ii = 1
                                                          THEN SUBstitute("свыше &1", term_tot-dis-rule_.tot-sum)
                                                          ELSE SUBSTITUTE("от &1 до &2"
                                                                        , term_tot-dis-rule_.tot-sum
                                                                        , v-tot-sum)
                                                          ))
                  v-tot-sum = term_tt-dis-rule.tot-sum
                  .
                end. /*if term_tot-dis-rule_.status_ <> {&ora-line-delete} then do:*/
              end. /*for each term_tot-dis-rule_ where*/
              v-sts = integer({&deleted-status-int}).
              run ref/dis-rul2.p (
                                buffer buf_dis-rule
                              , input yes /*p-silent*/
                              , input dflt-cd
                              , input-output v-sts
                              ) no-error.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при логическом удалении правила скидок на итог &1 (типа &2):&3&4&3&5"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
                undo main-block, retry main-block .
              end.
              v-rid = ?.
              run ref/dis-rul1.p (
              input ? /* p-rule-num */
              ,input dflt-cd
              ,input buf_tot-dis-rule_.templ-rl-root
              ,input buf_tot-dis-rule_.templ-rl-root
              ,input buf_tot-dis-rule_.des
              ,input buf_tot-dis-rule_.dis-kat
              ,input buf_tot-dis-rule_.discnt-type
              ,input buf_tot-dis-rule_.doc-qnty
              ,input buf_tot-dis-rule_.tot-sum
              ,input buf_tot-dis-rule_.charkey_one
              ,input buf_tot-dis-rule_.charkey_two
              ,input buf_tot-dis-rule_.charkey_three
              ,input buf_tot-dis-rule_.deckey_one
              ,input buf_tot-dis-rule_.deckey_two
              ,input buf_tot-dis-rule_.deckey_three
              ,input buf_tot-dis-rule_.key#_one
              ,input buf_tot-dis-rule_.key#_two
              ,input buf_tot-dis-rule_.key#_three
              ,input buf_tot-dis-rule_.subject-type
              ,input buf_tot-dis-rule_.time-templ-rl-root
              ,input buf_tot-dis-rule_.time-rule-num
              ,input buf_tot-dis-rule_.upper-rule-num
              ,input buf_tot-dis-rule_.value-type
              ,input buf_clients.host-code
              ,INPUT buf_clients.obj-type
              ,INPUT buf_clients.obj-code
              ,INPUT buf_tot-dis-rule_.discnt-value
              ,input table term_tt-dis-rule
              ,input-output v-rid
              ,input {&add-def}
              ,input yes /*p-silent */
              ) NO-ERROR.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2):&3&4&3&5"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
                undo main-block, retry main-block .
              end.
            end.
            else do: /*if available buf_dis-rule then do:*/
              v-err-mess = substitute("Невозможно изменить правило скидок на итог &1 (типа &2) - правило не существует"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , return-value
                                        ).
            end.
          end.
          else do:
            v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3Нет такого правила"
                                    , v-rule-num
                                    , v-templ-rl-root
                                    , {&new-line}
                                    ).
            run set-err-type in p-cont-handle
              ( input {&ora-err-type-SYNCHRONIZATION}
              ) no-error.
            undo main-block, retry main-block .
          end.
        end. /*        for each buf_clients no-lock where*/
      end. /*{&ora-line-update} */
      when {&ora-line-create} then do:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = {&shop}
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          empty temp-table term_tt-dis-rule.
          dflt-cd = ''.
          { gbl/dflt-cd.i buf_Clients.obj-type buf_clients.obj-code dflt-cd }
          find first buf_dis-thbj-rule share-lock where
                    buf_dis-thbj-rule.obj-type = buf_clients.obj-type
                and buf_dis-thbj-rule.obj-code = buf_clients.obj-code
                and buf_dis-thbj-rule.host-code = buf_clients.host-code
                and buf_dis-thbj-rule.pos-type = dflt-cd
                and buf_dis-thbj-rule.discnt-role = {&dthbjr-pcnt-tot-kateg}
                and buf_dis-thbj-rule.nonunique = '' no-error.
          if available buf_dis-thbj-rule then do:
            find first buf_dis-rule share-lock where
                      buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num no-error.
            if available buf_dis-rule then do:
              v-err-mess = substitute("Невозможно создать правило скидки на итог в &1&2 - такое правило уже есть (&3)"
                                      , buf_dis-thbj-rule.obj-type
                                      , buf_dis-thbj-rule.obj-code
                                      , buf_dis-rule.rule-num
                                      ).
              run set-err-type in p-cont-handle
                ( input {&ora-err-type-SYNCHRONIZATION}
                ) no-error.
              undo main-block, retry main-block .
            end.
          end. /*if available buf_dis-thbj-rule then do:*/
          /*создадим правило*/
          ii = 0.
          FOR EACH term_tot-dis-rule_
          where term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
          BY term_tot-dis-rule_.tot-sum DESCENDING:
            if term_tot-dis-rule_.status_ <> {&ora-line-create} then do:
              v-err-mess = substitute("Невозможно создать правило скидки на итог в &1&2 - неверный статус для ветки с суммой &3:&4&5"
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , term_tot-dis-rule_.tot-sum
                                      ).

              run set-err-type in p-cont-handle
                ( input {&ora-err-type-SYNCHRONIZATION}
                ) no-error.
              undo main-block, retry main-block .
            end.
            create term_tt-dis-rule.
            buffer-copy term_tot-dis-rule_
            except rule-num upper-rule-num rl-root obj-type obj-code host-code
            to term_tt-dis-rule
            ASSIGN
            ii = ii + 1
            term_tt-dis-rule.rule-num = ii
            term_tt-dis-rule.upper-rule-num = term_tot-dis-rule_.templ-rl-root
            term_tt-dis-rule.rl-root = term_tot-dis-rule_.templ-rl-root
            term_tt-dis-rule.host-code = buf_clients.host-code
            term_tt-dis-rule.obj-type = buf_clients.obj-type
            term_tt-dis-rule.obj-code = buf_clients.obj-code
            term_tt-dis-rule.des =  term_tt-dis-rule.des + (IF term_tt-dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                        substitute("&1 &2"
                                                  ,(IF ii = 1
                                                    THEN SUBstitute("свыше &1", term_tot-dis-rule_.tot-sum)
                                                    ELSE SUBSTITUTE("от &1 до &2"
                                                                  , term_tot-dis-rule_.tot-sum
                                                                  , v-tot-sum)
                                                    ))
            v-tot-sum = term_tt-dis-rule.tot-sum
            .
          END.
          v-rid = ?.
          run ref/dis-rul1.p (
           input ? /* p-rule-num */
          ,input dflt-cd
          ,input buf_tot-dis-rule_.templ-rl-root
          ,input buf_tot-dis-rule_.templ-rl-root
          ,input buf_tot-dis-rule_.des
          ,input buf_tot-dis-rule_.dis-kat
          ,input buf_tot-dis-rule_.discnt-type
          ,input buf_tot-dis-rule_.doc-qnty
          ,input buf_tot-dis-rule_.tot-sum
          ,input buf_tot-dis-rule_.charkey_one
          ,input buf_tot-dis-rule_.charkey_two
          ,input buf_tot-dis-rule_.charkey_three
          ,input buf_tot-dis-rule_.deckey_one
          ,input buf_tot-dis-rule_.deckey_two
          ,input buf_tot-dis-rule_.deckey_three
          ,input buf_tot-dis-rule_.key#_one
          ,input buf_tot-dis-rule_.key#_two
          ,input buf_tot-dis-rule_.key#_three
          ,input buf_tot-dis-rule_.subject-type
          ,input buf_tot-dis-rule_.time-templ-rl-root
          ,input buf_tot-dis-rule_.time-rule-num
          ,input buf_tot-dis-rule_.upper-rule-num
          ,input buf_tot-dis-rule_.value-type
          ,input buf_clients.host-code
          ,INPUT buf_clients.obj-type
          ,INPUT buf_clients.obj-code
          ,INPUT buf_tot-dis-rule_.discnt-value
          ,input table term_tt-dis-rule
          ,input-output v-rid
          ,input {&add-def}
          ,input yes /*p-silent */
          ) NO-ERROR.
          if error-status:error then do:
            v-err-mess = substitute("Ошибка при создании правила скидки на итог в &1&2:&3&4&3&5"
                                    , buf_clients.obj-type
                                    , buf_clients.obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).

          end.
        end. /*        for each buf_clients no-lock where*/
      end.  /*{&ora-line-create} */
    end case.
  end. /*ne retry*/
end.
end procedure. /*proc-save-tot-pcnt*/


/*не удалять!!!!*/