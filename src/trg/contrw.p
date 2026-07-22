block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись договора

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.contract .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись договора".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.contract.contract-code, ub.contract.host-code, ub.contract.status_) " }
{ cmp/trg-def.i }
{ trg/new-bcod.i }
/*  */
&SCOPED-DEFINE ERROR_UNDO_RETURN                          ~
   IF ERROR-STATUS:ERROR THEN DO:                         ~
      MESSAGE                                             ~
         vss-workfile vss-revision vss-description SKIP   ~
         ERROR-STATUS:GET-MESSAGE(1) SKIP                 ~
         RETURN-VALUE SKIP                                ~
         ""                                               ~
         VIEW-AS ALERT-BOX ERROR                          ~
       .                                                  ~
       UNDO main-block, RETURN ERROR                      ~
           substitute( "&1. &2&3&4",                      ~
                        vss-workfile,                     ~
                        return-value,                     ~
                        {&new-line},                      ~
                        ERROR-STATUS :GET-MESSAGE(1)      ~
                       ).                                 ~
   END.                                                   ~


DEFINE BUFFER   buf_C-contract FOR c-Contract.
/*  */
DEFINE VARIABLE v-iUser-Db-Num AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE v-cUser-Name   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-Sys-Date     AS DATE      NO-UNDO INITIAL ?.
DEFINE VARIABLE v-Sys-Time     AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-Sys-Time-Int AS INTEGER   NO-UNDO INITIAL 0.


main-block :
do transaction
on error undo main-block, return error
:

  if new(ub.contract) then do:
    define variable v-db-num as integer   no-undo .
    if g#news then assign v-db-num = g#news-source-db .
    else           assign v-db-num = g#db-num .

    run gen-new-code-range-if-neces( input v-db-num,
                                     input {&gbl-ct-code},
                                     input ub.contract.contract-code,
                                     input g#news,
                                     input g#db-num,
                                     input g#news-source-db
                                   ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
    end.
  end. ELSE DO:
     /* Пишем историю  */
     /* Снимаем переменные  */
     { gbl/curdburt.i
       v-iUser-Db-Num
       v-cUser-Name
       v-Sys-Date
       v-Sys-Time
       v-Sys-Time-Int 
     }
     /*  */
     CREATE buf_C-contract NO-ERROR.
     {&ERROR_UNDO_RETURN}
     BUFFER-COPY ub.Contract TO buf_C-contract NO-ERROR.
     {&ERROR_UNDO_RETURN}
     ASSIGN
        buf_C-contract.chip-num          = NEXT-VALUE(s-corr-chip, {&db-name_schema})
        buf_c-contract.corr-user-db-num  = ub.contract.user-db-num
        buf_c-contract.corr-user-name    = ub.Contract.user-name
        buf_c-contract.corr-date         = v-Sys-date
        buf_c-contract.corr-time         = v-Sys-time-int
        NO-ERROR.
     {&ERROR_UNDO_RETURN}
  END.
  /*  */
  run str/callnews.p (input "contract", input (buffer ub.contract:handle) ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip   "Ошибка при передаче в новости договора" skip
      error-status :get-message(1) skip    return-value skip     view-as alert-box error .
    undo, return error.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_contract}
        , input ( buffer ub.contract:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.

&UNDEFINE ERROR_UNDO_RETURN
