block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/09/07
Author: Dmitry Ukhanov
Creation date: 10/09/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.rvs-doc.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление документа сверки ":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/thbj-def.i }
{ ref/xobjgrp.i  }

{ str/initiator.i }
{ str/lib-rvs.i }

define variable v-person as character no-undo.
define variable v-mess as character no-undo .
define variable v-value-character as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal as decimal   no-undo .
define variable v-value-integer as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable v-value-type as character no-undo .

define variable v-vid-action  as integer  no-undo .
define variable v-vid-param   as longchar no-undo .
define variable varshift-date as date     no-undo.
define variable varshift-num  as integer  no-undo.
define variable varshift-name as char     no-undo.

Main-Block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    
    { gbl/curshift.i
      ub.rvs-doc.obj-type
      ub.rvs-doc.obj-code
      varshift-date
      varshift-num
      varshift-name
      no-error
    }

  /* Проверяем статус документа, в котором мы можем удалять документ */
  if ( ub.rvs-doc.status_ = {&fact}
      and ub.rvs-doc.is-del <> true
     )
    or ( g#news = false
         and ub.rvs-doc.status_ <> {&g___new}
         and ub.rvs-doc.status_ <> {&fact}
        )
  then do:
    assign
      v-mess = substitute( "&1 &2&3"
                           + "Документ сверки может быть удален только в статусе новый или факт&3"
                           + "Сверка &4&3"
                           + "Складской документ &5&3"
                           + "Тип сверки &6&3"
                           + "Статус сверки &7&3"
                           , vss-workfile
                           , vss-revision
                           , {&new-line}
                           , ub.rvs-doc.rvs-code
                           , ub.rvs-doc.out-code
                           , ub.rvs-doc.rvs-type
                           , ub.rvs-doc.status_
                         )
    .
    if g#news = false then do:
      message
        v-mess skip
        view-as alert-box error .
    end.

    undo Main-Block, return error v-mess .
  end.

    if  (ub.rvs-doc.status_ = {&fact}  and ub.rvs-doc.is-del = true)
    
        then 
    do:

        { str/hstc-rvs.i
          "buffer ub.rvs-doc"
          integer({&hn-delete})
          ub.rvs-doc.rvs-code
          "dynamic-next-value('s-corr-chip':U,'{&db-name_schema}':U)"
          no-error
         }
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка записи истории удаления документа сверки &1", ub.rvs-doc.rvs-code ) skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.

  if ub.rvs-doc.status_ = {&fact}
  and ub.rvs-doc.rvs-type <> {&test-asi}
  then do:
    run adm/shattri.p (
         input "get":U
        ,input ub.rvs-doc.obj-type
        ,input ub.rvs-doc.obj-code
        ,input {&attr-nakl_par}
        ,input  "date-close-period"
        ,output v-value-character
        ,output v-date-close-period
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .
    if error-status :error then v-date-close-period = date('').
    if v-date-close-period <> date('') then do:
        if ub.rvs-doc.fact-date < v-date-close-period
        then do:
          message  substitute(
            "Дата закрытия сверки &1 более ранняя, чем дата закрытия периода &2
            Дата закрытия сверки     &3 &2
            Дата закрытия периода    &4 &2
            Объект &5 &6 "
            ,
            ub.rvs-doc.rvs-code  ,
            {&new-line}  ,
            string ( ub.rvs-doc.fact-date , "99/99/9999" ) ,
            string ( v-date-close-period,   "99/99/9999") ,
                      x_obj-group.obj-type ,
                      x_obj-group.obj-code  ) view-as alert-box information .
            return.
        end.
    end.
  end.

  for each ub.doc-attr exclusive-lock
    where ub.doc-attr.doc-code = ub.rvs-doc.rvs-code
  on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    delete ub.doc-attr.
  end.

  /* удаляем связанные таблицы */
  for each ub.rvs-line exclusive-lock
    where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
  on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    delete ub.rvs-line.
  end.

  for each ub.rvs-line-pump exclusive-lock
    where ub.rvs-line-pump.rvs-code = ub.rvs-doc.rvs-code
  on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    delete ub.rvs-line-pump.
  end.
  
  if ub.rvs-doc.rvs-type <> {&test-asi}
  then do :
    define variable v-result as integer no-undo.

    if v-mess = "" then v-result = 0.
    else v-result = 1 .
      
    for first  ub.clients where ub.clients.obj-type = {&prs} and  ub.clients.obj-code = ub.rvs-doc.boss no-lock : 
        v-person = clients.obj-name.
    end.        
    v-vid-action = 60.
    v-vid-param =
        "Initiator=" + v-initiator + {&delim-par} +
        "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + {&delim-par} + 
        "SHOP_NUM=" + string(rvs-doc.obj-code) + {&delim-par} +
        "DocNum=" + string(rvs-doc.rvs-code) + {&delim-par} +
        "FactDate=" + (if string(rvs-doc.fact-date) = ? then '' else string(rvs-doc.fact-date)) + {&delim-par} +
        "DocType=" + string(rvs-doc.rvs-type) + {&delim-par} +
        /*        "ShiftNum=" + string(rvs-doc.shift-num) + {&delim-par} +  */
        /*        "ShiftDate=" + string(rvs-doc.shift-date) + {&delim-par} +*/
        "SHIFT_NUM_DOC=" + (if string(rvs-doc.shift-num) = ? then '' else string(rvs-doc.shift-num)) + (if string(rvs-doc.shift-date) = ? then '' else string(rvs-doc.shift-date , "99999999")) + {&delim-par} +  
        "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
        
        
        /*                "ShiftNumCurr=" + (if string(parshift-num) = ? then '' else string(parshift-num)) + {&delim-par} +   */
        /*                "ShiftDateCurr=" + (if string(parshift-date) = ? then '' else string(parshift-date)) + {&delim-par} +*/
        "Status=" + string(rvs-doc.status_) + {&delim-par} +
        

        "RESULT=" + string( v-result ) + {&delim-par} + 
        "Description=" + v-mess no-error.
     
      
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_rvs-doc}
        , input ( buffer rvs-doc  :handle )
        , input v-vid-action
        , input v-vid-param
        ) no-error.
    if error-status :error
        then 
    do:

        message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ) 
            view-as alert-box.
        return no-apply.
    end.
  end . /* if ub.rvs-doc.rvs-type <> {&test-asi} */

  /* посылаем команду на удаление документа сверки */
  if g#db-num <> 0 then do:
    run nws/cmd-del.p
      ( input "rvs-doc":U
       ,input (buffer ub.rvs-doc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
    end.
  end.

  if g#oxml = yes then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_delete}
       ,input {&table_rvs-doc}
       ,input ( buffer ub.rvs-doc:handle )
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                    ,{&new-line}
                                    ,vss-workfile
                                    ,return-value
                                    ,error-status :get-message ( 1 )
                                   ).
    end.
  end.
  if ub.rvs-doc.status_ = {&fact}
  then do:
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
        {&edoc-proc_event_rvs-doc}
      " buffer ub.rvs-doc:handle "
      ?
      ''
      ''
      no-error
    }
    if error-status :error
      then
    do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
        , {&new-line}
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.   
end. /* Main-Block */