block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории документа

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-rvs-doc OLD BUFFER old-c-doc.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись истории документа":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.c-rvs-doc.rvs-code,ub.c-rvs-doc.chip-num,ub.c-rvs-doc.status_)" }
{ cmp/trg-def.i  }






define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
define variable v-host-code like ub.c-rvs-doc.host-code no-undo.
main-block :
do on error   undo main-block, return error
   on end-key undo main-block, return error
   on stop    undo main-block, return error :
  find first ub.clients no-lock where
             ub.clients.obj-type = ub.c-rvs-doc.obj-type and
             ub.clients.obj-code = ub.c-rvs-doc.obj-code no-error.
  if not available ub.clients then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильная ссылка на объект" skip
            "Документ " ub.c-rvs-doc.rvs-code skip
            "Не найден объект" ub.c-rvs-doc.obj-type ub.c-rvs-doc.obj-code skip
    view-as alert-box error.
    undo main-block, return error.
  end.

  /* проверяем уникальность кода документа */
  run trg/chkchpnm.p ( input ub.c-rvs-doc.rvs-code /* p-doc-code   */
                 , input ub.c-rvs-doc.chip-num /* p-chip-num   */
                 , input "c-rvs-doc":U         /* p-table-name */
                 , input recid( ub.c-rvs-doc ) /* p-recid      */ ) no-error.
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при проверке уникальности кода документа" skip
            "Документ " ub.c-rvs-doc.rvs-code skip
            error-status :get-message( 1 ) skip
            return-value skip
    view-as alert-box error.
    undo main-block, return error.
  end.

  /* if ub.c-rvs-doc.status_ <> {&fact} then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильный статус документа " skip
            "Документ сверки" ub.c-rvs-doc.rvs-code skip
            "Статус" ub.c-rvs-doc.status_ skip
    view-as alert-box error.
    undo main-block, return error.
  end. */

  /* проверяем, что фирма правильно заполнена */
  { gbl/hostcode.i ub.c-rvs-doc.obj-type
               ub.c-rvs-doc.obj-code
               v-host-code           no-error }
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошика при определении кода фирмы для объекта" skip
            "Документ " ub.c-rvs-doc.rvs-code skip
            "obj-type" ub.c-rvs-doc.obj-type skip
            "obj-code" ub.c-rvs-doc.obj-code skip
            error-status :get-message( 1 ) skip
            return-value skip
    view-as alert-box error.
    undo main-block, return error.
  end.
  if ub.c-rvs-doc.host-code <> v-host-code then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильно заполнено поле фирма" skip
            "Документ " ub.c-rvs-doc.rvs-code skip
            "Объект"  ub.c-rvs-doc.obj-type ub.c-rvs-doc.obj-code skip
            "Фирма"   ub.c-rvs-doc.host-code skip
            "Должна быть фирма" v-host-code skip
    view-as alert-box error.
    undo main-block, return error.
  end.
/*
    define buffer old_c-rvs-doc for c-rvs-doc .
    define variable v-person as character no-undo.
    for last  old_c-rvs-doc no-lock where
        old_c-rvs-doc.rvs-code = c-rvs-doc.rvs-code and
        old_c-rvs-doc.corr-user-db-num = g#db-num and
        old_c-rvs-doc.chip-num < c-rvs-doc.chip-num  :
    
        if old_c-rvs-doc.status_ <> ub.c-rvs-doc.status_ then 
        do:
            for first  ub.clients where ub.clients.obj-type = {&prs} and  ub.clients.obj-code = ub.c-rvs-doc.boss no-lock : 
                v-person = clients.obj-name.
            end.
                { str/initiator.i }
                v-vid-action = 58 .
                v-vid-param =
                    "Initiator=" + v-initiator + {&delim-par} +
                    "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + {&delim-par} + 
                    "SHOP_NUM=" + string(ub.c-rvs-doc.obj-code) + {&delim-par} +
                     "DocType=" + string(ub.c-rvs-doc.rvs-type) + {&delim-par} +
                    
                    "DocNum=" + string(ub.c-rvs-doc.rvs-code) + {&delim-par} +
                    "FactDate=" + (if ub.c-rvs-doc.status_ = {&fact} then string(old_c-rvs-doc.fact-date) else "") + {&delim-par} +
                    "ShiftNum=" + string(ub.c-rvs-doc.shift-num) + {&delim-par} +
                    "ShiftDate=" + string(ub.c-rvs-doc.shift-date) + {&delim-par} +
                    /*              "ShiftNumCurr=" + string(ub.c-rvs-doc.shift-num) + {&delim-par} +  */
                    /*              "ShiftDateCurr=" + string(ub.c-rvs-doc.shift-date) + {&delim-par} +*/
                    "StatusOld=" + string(old_c-rvs-doc.status_) + {&delim-par} +
                    "StatusNew=" + string(ub.c-rvs-doc.status_) + {&delim-par} +
                    "RESULT=0" + {&delim-par} +
                    "Description=".

                run trg/userlog.p (
                    input {&nwsdochs_action_update}
                    , input {&table_c-rvs-doc}
                    , input ( buffer ub.c-rvs-doc :handle )
                    , input v-vid-action
                    , input v-vid-param
                    ) no-error.
                if error-status :error
                    then 
                do:
                   return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , {&new-line}
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                end.
            end.
        end.
*/

  if g#news <> yes then do:
    if ub.c-rvs-doc.corr-user-name = "":U then do: assign ub.c-rvs-doc.corr-user-name = g#userid. end.

    /* передача документа сверки через СПН (Система Передачи Новостей) */
    run str/callnews.p ( input "c-rvs-doc", input ( buffer ub.c-rvs-doc :handle ) ) no-error.
    if error-status :error then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Невозможно маршрутизировать c-rvs-doc для отправки в новости" skip
              error-status :get-message( 1 ) skip
              return-value skip
      view-as alert-box error.
      undo main-block, return error.
    end.
  end. /* if not g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-rvs-doc}
        , input ( buffer ub.c-rvs-doc:handle )
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
end. /* main-block */