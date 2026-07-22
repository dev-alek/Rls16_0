/*

$Revision: c05e0a69ef9d, 3077, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:16 2022 +0300 $
$Workfile: 000002098.p $
$Archive: rul/000002098.p $

Вспомогательный файл для кодекса правил 20 набор правил 4

Автор: Морозов Александр Сергеевич
Дата создания: 04/14/13
Author: Morozov Alexandr
Creation date: 04/14/13

Импорт справочников 1С (РОСНЕФТЬ).

---------------------------&start-codex_id=18;ruleset_id=12;-----------------
Импорт справочников 1С (РОСНЕФТЬ).

---------------------------&end-codex_id=18;ruleset_id=12;-----------------

*/

/*---------------------------&start-using-class&-------------------------------*/
using ibs.th.bge.*.
using ibs.th.bge.1crn.import.*.
using ibs.th.bge.1crn.import.*.

/*---------------------------&end-using-class&---------------------------------*/
block-level on error undo, throw.

define variable parseSubObj as class parsesub no-undo.
define variable impSubObj as class impsubject no-undo.

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

define variable vss-revision    as character no-undo init "$Revision: c05e0a69ef9d, 3077, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:16 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 000002098.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rul/000002098.p $":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 20 набор правил 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ cmp/ini-lib.i  }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ rul/ruleset_.i }
{ gbl/db-attr.i  }
{ bge/esysattr.i } // ext-system-attr-value для проверки сертификатов
{ str/imp2cd.i &imp2cd_parparentproc = parparentproc }

define temp-table temp-asmg no-undo
field gds-code as integer
field asmg-des as character
field obj-type  as character
field gdop-igt as character
field gdop-assort-min as logical
field obj-code as integer
field mode as character
index pi obj-code obj-type
.

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
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-ds-read-order as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-err-message as character no-undo .
define variable v-pack-num as character no-undo .
define new shared variable g#LogStr as character no-undo.
define variable v-oxml-log-name as character no-undo .

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo init "imp-1crn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .


function 00200004_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to error-status:num-messages:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,error-status:get-message(v-ii)).
end.
end function.

function notnull returns character (input str as character):
if str = ? then return "" . else return str .
end function.

function get-time returns character(p-time as integer):
    return string(p-time, "HH:MM:SS").
end.

function get-date returns character(p-date as date):
    return subst("&1.&2.&3", string(day(p-date), "99"), string(month(p-date), "99"), string(year(p-date), "9999")).
end.

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~) .           ~
          if v-oxml-log-name > ''                  ~
          then do :                                ~
            run writelog in p-log-handle (         ~
                input v-oxml-log-name              ~
              , input 1                            ~
              , input ~{&my-message}~) .           ~
          end  




/*---------------------------&start-rule-call-param&-------------------------------*/
  define variable p-esys-id     as integer   no-undo .
  define variable p-sub-type    as character no-undo.
  define variable p-reciever-id as character no-undo .
  define variable p-sender-id   as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/
define variable v-attr-type        as character no-undo . // для чтения значений из ext-system-attr
define variable v-cert-enstr       as character no-undo . // чтение v-cert-enabled строкой
define variable v-cert-enabled     as logical no-undo . // true - добавить цифровую подпись
define variable v-cert-issuer-name as character no-undo .
define variable v-cert-subj-name   as character no-undo .
define variable v-sign-fileext     as character no-undo .
define variable v-cert-repository  as integer no-undo .
define variable v-pkcs             as class ibs.th.gbl.pkcs no-undo .

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
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
      v-err-message = return-value.  /*  на тот случай когда следующая процедура сделает return */
      run delete-procedure in this-procedure .
      undo, return error v-err-message.
  end.
  run delete-procedure in this-procedure .
end.

define variable mySeqUtd as int64 no-undo init ?.
define variable myStopGroucRec as logical no-undo init yes .
procedure startStop:
   myStopGroucRec = not myStopGroucRec.
   if not myStopGroucRec
   then
      mySeqUtd = ?.
end.
procedure MySeqTable:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if myStopGroucRec
   then
      Oseq = ?.
   else if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then 
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?. 
   return.
end.

define stream sReadfile.
procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-current-b-code as integer no-undo .
define buffer buf_ext-system for ub.ext-system.

define variable v-sender-id as character no-undo .
define variable v-type as character no-undo .

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4&3&5", vss-workfile, return-value, {&new-line}, error-status :get-message (1),v-err-message)
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/* ------------------------- &start-hn-option& -----------------------------------*/
/* ------------------------- &end-hn-option -----------------------------------*/

run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по пакету 1С (РОСНФЕТЬ) из ВС")
  {&display-message}.
  &scop my-message substitute("Импорт данных по пакету 1С (РОСНФЕТЬ) из файла &1", file-name)
  {&display-message}.

    find first buf_ext-system no-lock where
              buf_ext-system.esys-id = v-esys-id
          and buf_ext-system.db-num = 0 no-error.
    if not available buf_ext-system
    or not (buf_ext-system.esys-type  > integer({&openxml-type-ordinal})) then do:
    &scop my-message  substitute("Не найдена ВС &1 или она не имеет типа СПЕЦИАЛЬНАЯ", v-esys-id)
       {&display-message}.
       undo _main, return error ''.
    end.
    
    run db-attr-value in this-procedure 
           (input ibs.th.gbl.gbl-var:g#db-num
           ,input {&attr-int-point}
           ,output v-sender-id
           ,output v-type
           ) no-error .
  run str/imp2cdseth.p(this-procedure).  

  ibs.th.bge.1crn.import.impmsgs:clearMsg().
  do transaction:
    v-err-message = "" .
    subscribe "getNextseq" anywhere run-procedure "MySeqTable".
    subscribe "startStopGroupRec" anywhere run-procedure "startStop".
    MySeqUtd = ?.
    output to "oxmerrprogres.log".
    parseSubObj = new parsesub ().
    parseSubObj:setParent(parparentproc, p-parent-handle, p-log-handle) .

    impSubObj = new impsubject (parseSubObj).
    parseSubObj:Parse1CRNSub(file-name).
    unsubscribe "startStopGroupRec".
    unsubscribe "getNextseq" .

     
       &scop my-message substitute("пакет из файла &1 обработан без ошибок", file-name)
       {&display-message}.
    // ack_ со статусом Ok отправится только если всё выполнилось без ошибок 
    run rul/send-ack_1c.p ( input v-sender-id
                          , input v-pack-num
                           ,input 0
                           ,input ""
                           ,input buf_ext-system.esys-id
                           ,input v-cert-subj-name
                           ,input v-cert-issuer-name
                           ,input v-sign-fileext
                           ,input v-cert-repository
                           ,input v-pkcs
                          ) .
    &scop my-message substitute("создан ack_ со статусом Ok в exch &1 - ES &2 по пакету N&3", g#db-num, buf_ext-system.esys-id, v-pack-num)
    {&display-message}.

    v-err-message = "" .
    catch exAppErrors as class Progress.Lang.AppError :
      /* 09/VIII-2019 - исключаем дублирование вывода сообщений об ошибке
      &scop my-message substitute("Ошибка при сохранении данных по пакету &4 файл &5 1С (РОСНФЕТЬ) из ВС:&1&2&1&3", {&new-line}, parseSubObj:Msg , error-status:get-message(1), v-pack-num, file-name  )
      v-err-message = {&my-message} .
      {&display-message}.
      */
      v-err-message = trim(parseSubObj:Msg, ";") .
      v-err-message = trim(v-err-message) .
      v-err-message = trim(v-err-message, ";") .
      put skip.
      output close.
      define variable vStr as character no-undo.
      input STREAM sReadfile FROM  "oxmerrprogres.log".
      repeat:
         import stream sReadfile unformatted vStr.
         &scop my-message vStr
         {&display-message}.
      end. 
      run rul/send-ack_1c.p ( input v-sender-id
                            , input v-pack-num
                              ,input 4
                              ,input v-err-message 
                              ,input buf_ext-system.esys-id
                              ,input v-cert-subj-name
                              ,input v-cert-issuer-name
                              ,input v-sign-fileext
                              ,input v-cert-repository
                              ,input v-pkcs
                              ) no-error .
      if error-status:error then do :
      &scop my-message substitute("Ошибка при отправке ack_ на ошибку сохранения данных по пакету 1С (РОСНФЕТЬ) из ВС")
      v-err-message = {&my-message} .
      {&display-message}.
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
/*      Msg = "Unexpected error occurred..." .*/
      undo, throw exAnyErrors .
    end catch .
    finally :
      delete object parseSubObj no-error.
      
      put skip.
      output close.
      delete object impSubObj no-error.
      if valid-object(v-pkcs) then delete object v-pkcs .
      if v-err-message > "" then return error v-err-message .
    end finally .
  end.
  run send-to-cash in this-procedure no-error.
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-itop as integer   no-undo .
define variable v-ichild as integer   no-undo .
define variable v-pck-num as integer no-undo .
define variable v-my-message as character no-undo .
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
and buf_rule-call-param.param-name = "p-sub-type"
 no-error.
if available buf_rule-call-param then do:
assign p-sub-type = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-sender-id"
 no-error.
if available buf_rule-call-param then do:
assign p-sender-id = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-reciever-id"
 no-error.
if available buf_rule-call-param then do:
assign p-reciever-id = buf_rule-call-param.param-value-character.
end.

    case p-ruleset-id:
      when {&thref-proc_20_xml-esys-import} then do:
          
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(2, p-process-file-name, {&delim-par})
        v-esys-id = integer(trim(p-doc-code))
        no-error
       .
       v-pack-num = entry(3, entry(num-entries(file-name, "\"), file-name, "\") ,"_") no-error.
       
       v-oxml-log-name = entry(4, p-process-file-name, {&delim-par}) no-error .
       
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system
        or buf_ext-system.esys-type <> integer({&openxml-type-special})
        then do:
          &scop my-message substitute("Не найдена ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.

        /* параметры настройки ЭЦП для подписания ack_'ов */
        run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign}
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
        if not error-status:error then v-cert-enabled = logical (v-cert-enstr) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка чтения параметра &1 настроек ВС &2&3&4&3&5&3пропускаем ..."
                                        , {&attr-esys-cert-sign}
                                        , v-esys-id
                                        , {&new-line}
                                        ,error-status:get-message(error-status:num-messages)
                                        ,return-value
                                   ) .
          &scop my-message v-my-message
          {&display-message}.
          undo, return error {&my-message}.
        end.
        if v-cert-enabled then do :
        run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign-issuer}
                                     ,output v-cert-issuer-name
                                     ,output v-attr-type) no-error .
        if not error-status:error then
        run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign-subject}
                                     ,output v-cert-subj-name
                                     ,output v-attr-type) no-error .
        if not error-status:error then
        run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-file-ext}
                                     ,output v-sign-fileext
                                     ,output v-attr-type) no-error .
        if error-status:error then do:
          &scop my-message substitute("Ошибка чтения настроек ЭЦП для ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        v-cert-repository = ? .
        run ext-system-attr-value in this-procedure (
                                  input  buf_ext-system.esys-id
                                 ,input  buf_ext-system.db-num
                                 ,input  {&attr-esys-cert-repository}
                                 ,output v-cert-enstr
                                 ,output v-attr-type) no-error .
        if v-cert-enstr > ""
        then
          v-cert-repository = integer(v-cert-enstr) no-error .    
        if v-cert-repository = ?
        then
          v-cert-repository = 0 .
        if v-cert-subj-name > "" then . else do :
          &scop my-message substitute("Отсутствует имя Владельца сертификата в параметрах настройки внешней системы ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end .
        if v-cert-issuer-name > "" then . else do :
          &scop my-message substitute("Отсутствует имя Издателя сертификата в параметрах настройки внешней системы ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end .
        v-pkcs = new ibs.th.gbl.pkcs().
      end .
      else assign
        v-cert-issuer-name = ""
        v-cert-subj-name   = ""
        v-sign-fileext     = ""
      .
      end. // end_of &thref-proc_20_xml-esys-import
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

/*---------------------------&end-process-rule-call-param&-------------------------------*/
end procedure. /* load-ruleset-context */


procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */


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

procedure cre-status :

  define variable hSAXWriter as handle no-undo.
  define variable v-str as character no-undo.
  define variable v-dt-1c as character no-undo.
  define variable dir_crt as logical no-undo.



end.
