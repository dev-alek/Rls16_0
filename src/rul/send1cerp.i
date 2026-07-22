
/*------------------------------------------------------------------------
    Description : Экспорт 1C ERP RN

  ----------------------------------------------------------------------*/
/*
Маршрутизация во ВС
*/

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


{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ gbl/gate-clb.i }
{ rul/rum-fn.i }
{ rul/context_f.i get-thobj-es }
{ gbl/key-rec.i }
{ bge/esysattr.i }
{ bge/tmpcxmlh.i }
{ rul/ruleset_.i }
{ cus/str-edi.i }


/*переменные контекста*/
/*это у нас объект 0*/
define variable m-current-doc-code     as character no-undo .
define variable m-newbh                as handle    no-undo .
define variable m-oldbh                as handle    no-undo .
define variable m-has-newbh            as logical   no-undo .
define variable m-has-oldbh            as logical   no-undo .
define variable m-changes-list         as character no-undo .
define variable m-esys-cmd-proc-handle as handle    no-undo .
define variable m-esys-cmd-code        as integer   no-undo .
define variable log-file-name          as character no-undo init "process-edoc.txt".
define variable v-view-log             as logical   no-undo .
define variable m-stop                 as logical   no-undo .
define variable v-last-error-message   as character no-undo .

/*****************************/
/*define variable file-name              as char.
define variable v-sign                 as integer   no-undo .
define variable v-gate-rec             as character no-undo .
define variable num-rec                as integer   no-undo .

define variable l-res                  as integer   no-undo .
define variable v-es                   as logical   no-undo .
define variable v-esm                  as character no-undo .
define variable v-rv                   as character no-undo .

define variable v-err-mess             as character no-undo .
define variable v-action               as character no-undo .
*/
define variable m-es                   as logical   no-undo .
define variable m-esm                  as character no-undo .
define variable m-rv                   as character no-undo .
define variable m-esys-id-list         as character no-undo .
/*define variable mnum-rec-ok             as integer   no-undo .*/
{ str/dia2auto.i }
{ rul/seterror.i }


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

{ rul/context_f.i  begin-esys-command }
{ rul/context_f.i  send-esys-command-ext }
{ rul/context_f.i  set-custom-esys-pck-name }
{ rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure 
  do:
    run garbcoll_clear in this-procedure .
  end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then 
do:
  undo, return error return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Ibs.Th.Rul.Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Ibs.Th.Rul.Route-data_{&constructor_1} .

define variable v-DATA as memptr no-undo.

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then 
do:
    
  run proc-main in this-procedure no-error .
  if error-status:error then 
  do:
    m-esm = error-status :get-message (1).
    m-es = error-status:error .
    m-rv = return-value .
  end.
  { str/cdviewlg.i  "'!!!При маршрутизации произошли ошибки!!!'"   log-file-name not-delete }
  if m-es then 
  do:
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, m-rv, ~{&new-line~}, m-esm)
      {&display-message}.
      run garbcoll_clear in this-procedure .
/*      undo,*/
       return error substitute( "&1. &2&3&4", vss-workfile, m-rv, {&new-line}, m-esm).
  end.
  run garbcoll_clear in this-procedure .
end.
define variable dddd as character no-undo.
dddd = "".

define variable subOBj as class ibs.th.bge.1crn.subjects.iexpsubject no-undo .
procedure proc-main :

  _main:
  do
    on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
    :
    define variable v-custom-pack-name   as character   no-undo .
    define variable v-dump-ord-int64     as int64       no-undo .
    /*define variable v-ii                 as integer     no-undo .
    define variable v-uniq-key-rec       as character   no-undo .
    define variable v-cli-uniq-key-rec   as character   no-undo .
    define variable v-err                as logical     no-undo .
    
    define variable v-success            as logical     no-undo .
    define variable v-datetimechar       as character   no-undo .
    define variable v-dump-ord-int64     as int64       no-undo .


    define variable v-status_            as character   no-undo .
    define variable v-flag               as logical     no-undo .
    define variable v-doc-num            as character   no-undo .
    define variable v-dklink-doc-type    as integer     no-undo .
    define variable v-agentid            as integer     no-undo .
    define variable v-ext-doc-type       as character   no-undo .
    define variable v-price-doc-obj-type as character   no-undo .
    define variable v-price-doc-obj-code as integer     no-undo .
    define variable v-obj-db-num         as integer     no-undo .
    define variable v-obj-uniq-key-rec   as character   no-undo .
    define variable v-b-code             as integer     no-undo .
    define variable v-main-b-code        as integer     no-undo .
    define variable v-gds-name-full      as character   no-undo .
  define variable v-node-name         as character  no-undo .
    define variable v-agnt-id            as integer     no-undo .
    define variable v-obj-type           as character   no-undo .
    define variable v-obj-code           as integer     no-undo .
    define variable v-tot-rubl           as decimal     no-undo .
    define variable v-ext-num            as character   no-undo .
    define variable v-table-name         as character   no-undo .
    define variable v-cli-type           as character   no-undo .
    define variable v-cli-code           as integer     no-undo .
    define variable v-cli-id             as integer     no-undo .
    define variable v-obj-id             as integer     no-undo .
    define variable v-from-store-id      as integer     no-undo .
    define variable v-to-store-id        as integer     no-undo .
    define variable v-p-date             as datetime-tz no-undo .
    define variable v-ext-artic          as character   no-undo .
    define variable v-del                as integer     no-undo .
  
    define buffer buf_clients     for ub.clients.
    define buffer buf_ext-classif for ub.ext-classif.
    define buffer buf_trn-doc     for ub.trn-doc .
    define buffer buf_gds-dtl     for ub.gds-dtl.
    define buffer buf_doc-line    for ub.doc-line.
    define buffer buf_gds-prt     for ub.gds-prt.
    define buffer buf_goods       for ub.goods.
    define buffer buf_ext-artic   for ub.ext-artic.
    define variable v-sht-status     as character no-undo .
define variable v-fld-sht-status as handle no-undo .*/
    
    define buffer buf_ext-system  for ub.ext-system.  
    define variable expObj as class ibs.th.bge.1crn.export.expsubject no-undo .
      
    
  
    /* ------------------------- &end-hn-option& -----------------------------------*/
    /*править здесь*/
    run local-proc-main in this-procedure no-error.
    if error-status:error 
    then
       undo _main, return error substitute("&1 &2", return-value , error-status:get-message(1) ).
  
    if  context_begin-esys-command( input string(m-esys-id-list), input-output m-esys-cmd-proc-handle, output m-esys-cmd-code) = false  
    then 
      undo _main, return error v-last-error-message .
    expObj = new ibs.th.bge.1crn.export.expsubject ().
    expObj:GetContent(subObj) no-error.
    if error-status:error
    then
       undo _main, return error substitute("&1 &2 &3",subObj:msg, return-value , error-status:get-message(1)) .
    
    if ExpData1:esys-add-dump-data ( input expObj:Data, 
                                     input m-esys-cmd-proc-handle, 
                                     input m-esys-cmd-code, 
                                     ('+update' + {&delim-par} + expObj:InitSecTag)) = false  
    then 
      undo _main, return error v-last-error-message .
    
    /*      v-custom-pack-name = "rvs-doc_&pack-num.xml".*/
    if  context_set-custom-esys-pck-name(  input m-esys-cmd-proc-handle, input m-esys-cmd-code, input v-custom-pack-name) = false  
    then 
      undo _main, return error v-last-error-message .
    
    v-dump-ord-int64 = context_send-esys-command( input m-esys-id-list
      , input m-esys-cmd-proc-handle
      , input m-esys-cmd-code
      , input g#userid).
    if v-dump-ord-int64 = 0 
    then 
      undo _main, return error v-last-error-message .
    
     

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/

/*    mnum-rec-ok = mnum-rec-ok + 1.*/
/*      run write-counter in p-log-handle ( input substitute("Обработано документов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).*/
/*      run get-stop-state in p-log-handle ( output v-stop) no-error .*/
/*      if v-stop then do:                                            */
/*        &scop my-message substitute("Процесс прерван пользователем")*/
/*        {&display-message}.                                         */
/*        leave _stroka.                                              */
/*      end. /*if v-stop*/*/
/*    end. /*else if retry*/*/
  
    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
  
  /*  &scop my-message substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)*/
  /*  {&display-message}.*/
  
  end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
  define input parameter p-ruleset-id as integer    no-undo .

 /* define variable v-flag              as logical   no-undo .
  define variable v-ii                as integer   no-undo .
  define variable v-changes-list2     as character no-undo .
  define variable v-obj-db-num        as integer   no-undo .
  define variable v-is-waiting-status as logical   no-undo .
  define variable v-direction         as character no-undo .
  define variable v-direction-2       as character no-undo .
  define variable v-waiting-status    as character no-undo .
  define variable v-ext-doc-type      as character no-undo .

  
  
  define buffer buf_clients         for ub.clients.
*/
 define buffer buf_rule-call-param for ub.rule-call-param.
 define buffer buf_ext-system      for ub.ext-system.
  do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :

    assign
      m-oldbh        = widget-handle (entry(2, p-doc-code, {&delim-par})).
      m-newbh        = widget-handle (entry(3, p-doc-code, {&delim-par})).
      m-changes-list = entry(4, p-doc-code, {&delim-par}).
/*      file-name      = p-process-file-name.*/
      m-has-oldbh    = valid-handle(m-oldbh) and m-oldbh:available.
      m-has-newbh    = valid-handle(m-newbh) and m-newbh:available.

      .
    if not m-has-newbh
      and not m-has-oldbh then 
    do:
      undo, return error substitute("Не определено ни одного буфера - ни старый, ни новый").
    end.
    if not m-has-oldbh
      and m-changes-list  = '' then 
    do:
      undo, return error substitute("Не определен старый буфер и список изменений").
    end.
    run local-load-ruleset-context in this-procedure no-error.
    if error-status:error 
    then
       undo, return error substitute("&1 &2",return-value,error-status:get-message(1) ).

    for each buf_rule-call-param no-lock where
      buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id
      and buf_rule-call-param.rule_id = p-rule-id
      and buf_rule-call-param.param-name = "p-esys-id",
      first buf_ext-system no-lock where
      buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
      and buf_Ext-system.db-num = 0
      and buf_Ext-system.esys-have-export = yes
      and buf_Ext-system.esys-db-num-exp = g#db-num:
      m-esys-id-list = m-esys-id-list + (if m-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
    end.
    if m-esys-id-list = '' then return "return".

    /*---------------------------&start-process-rule-call-param&-------------------------------*/
    find first buf_rule-call-param no-lock where
      buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id
      and buf_rule-call-param.rule_id = p-rule-id
      and buf_rule-call-param.param-name = "p-xsd-file"
      no-error.
    if available buf_rule-call-param then 
    do:
      assign 
        p-xsd-file = buf_rule-call-param.param-value-character.
    end.

  /*---------------------------&end-process-rule-call-param&-------------------------------*/

  end. /*doe*/

end procedure. /* load-ruleset-context */