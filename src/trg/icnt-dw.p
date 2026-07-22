block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись документа счетчиков ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.icnt-doc old buffer old-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }

define variable v-host-code like ub.icnt-doc.host-code no-undo .

define buffer buf_icnt-doc for ub.icnt-doc .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first ub.clients no-lock
    where ub.clients.obj-type = ub.icnt-doc.obj-type
      and ub.clients.obj-code = ub.icnt-doc.obj-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Не найден объект" ub.icnt-doc.obj-type ub.icnt-doc.obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* проверяем уникальность кода документа */
  run trg/chkdocnm.p
    (input ub.icnt-doc.doc-code /* p-doc-code   */
    ,input {&table_icnt-doc}    /* p-table-name */
    ,input recid(ub.icnt-doc)   /* p-recid      */
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке уникальности кода документа" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if  ub.icnt-doc.status_ <> {&g___new}
  and ub.icnt-doc.status_ <> {&fact} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный статус документа счетчиков ТРК" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Статус" ub.icnt-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if  ub.icnt-doc.doc-type <> {&icnt-doc}
  and ub.icnt-doc.doc-type <> {&icnt-err} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный тип документа счетчиков ТРК" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Тип" ub.icnt-doc.doc-type skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if  ub.icnt-doc.ext-doc-type <> {&TDEICNT_inv}
  and ub.icnt-doc.ext-doc-type <> {&TDEICNT_err-meas} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный расш.тип документа счетчиков ТРК" skip
      "Документ счетчиков ТРК" ub.icnt-doc.doc-code skip
      "Расш.Тип" ub.icnt-doc.ext-doc-type skip
      view-as alert-box error .
    undo main-block, return error .
  end.



  /* обновляем пользователя, дату и время последнего обновления */
  if not g#news
  then do:
    { gbl/curdburt.i
      ub.icnt-doc.user-db-num
      ub.icnt-doc.user-name
      ub.icnt-doc.sys-date
      ub.icnt-doc.sys-time
      ub.icnt-doc.sys-time-int
    }
  end.

  if old-doc.status_ = ub.icnt-doc.status_ then do:
    return . /* --->>>--- */
  end.

  run str/chk-icnt.p (input recid(ub.icnt-doc)) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке документа счетчиков ТРК" skip
      "Документ " ub.icnt-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if not g#news then do:
    /* здесь должна была бы быть запись истории */
  end.
  if not new ub.icnt-doc
  and old-doc.status_     = {&fact}
  and ub.icnt-doc.status_ <> {&fact} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Документ " ub.icnt-doc.doc-code skip
      "Документ закрыт до статуса" {&fact} skip
      "Нельзя изменить статус на " ub.icnt-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* проверяем, что фирма правильно заполнена */
  { gbl/hostcode.i
    ub.icnt-doc.obj-type
    ub.icnt-doc.obj-code
    v-host-code
    no-error
  }
  if error-status :error then do:
    message
     vss-workfile vss-revision vss-description skip
     "Ошика при определении кода фирмы для объекта" skip
     "Документ сверки" ub.icnt-doc.doc-code skip
     "Тип объекта"     ub.icnt-doc.obj-type skip
     "Код объекта"     ub.icnt-doc.obj-code skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.icnt-doc.host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Документ сверки" ub.icnt-doc.doc-code skip
      "Объект"  ub.icnt-doc.obj-type " " ub.icnt-doc.obj-code skip
      "Фирма"   ub.icnt-doc.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* закрытие до статуса факт */
  if ub.icnt-doc.status_ = {&fact} then do:
    run change-status-fact in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выполнении программы change-status-fact" skip
        "Документ счетчиков ТРК " ub.icnt-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if  not g#news
  and ub.icnt-doc.creid = "" then do:
    assign
      ub.icnt-doc.creid = g#userid
    .
  end.

  /* передача документа сверки через СПН (Система Передачи Новостей) */
  if not g#news then do:
    if ub.icnt-doc.status_ <> {&g___new} then do:
      run str/callnews.p
         (input {&TABLE_icnt-doc}
         ,input (buffer ub.icnt-doc:handle)
         ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать icnt-doc для отправки в новости" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_icnt-doc}
        , input ( buffer ub.icnt-doc:handle )
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
  if ub.icnt-doc.status_ = {&fact} then 
  do:
  { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_icnt-doc}
      " buffer old-doc:handle "
      " buffer ub.icnt-doc:handle "
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
end.


procedure change-status-fact :

  do
  on error undo, return error
  :
    if g#news then do:
      if ub.icnt-doc.fact-order = ?
      or ub.icnt-doc.fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан фактический номер документа счетчиков ТРК" skip
          "Документ  счетчиков ТРК" ub.icnt-doc.doc-code skip
          "fact-order" ub.icnt-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    if not g#news then do:
    /* проверяем факт дату, время */
      run gbl/chk-date.p
        (input ub.icnt-doc.obj-type
        ,input ub.icnt-doc.obj-code
        ,input ub.icnt-doc.fact-date
        ,input ub.icnt-doc.fact-time
        ,input ub.icnt-doc.shift-date
        ,input ub.icnt-doc.shift-num
        ,input yes
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при установке дат, времен, смен в документе счетчиков ТРК." skip
          "Документ"          ub.icnt-doc.doc-code skip
          "Дата"              ub.icnt-doc.fact-date skip
          "Время"             ub.icnt-doc.fact-time skip
          "Дата начала смены" ub.icnt-doc.shift-date skip
          "Порядок смены"       ub.icnt-doc.shift-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    if not g#news then do:
      if ub.icnt-doc.fact-order > 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер документа счетчиков ТРК " skip
          "Документ счетчиков ТРК " ub.icnt-doc.doc-code skip
          "fact-order" ub.icnt-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.

      /* определяем порядковый номер */
      define variable v-fact-num as integer no-undo .
      assign
        v-fact-num = next-value (s-trn-fact, {&db-name_schema})
      .

      /* определяем fact-order */
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .

      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        ub.icnt-doc.obj-type
        ub.icnt-doc.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при запуске процедуры objat" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      run factord in this-procedure
        (input  ub.icnt-doc.fact-date   /* p-fact-date            */
        ,input  ub.icnt-doc.fact-time   /* p-fact-time            */
        ,input  v-fact-num              /* p-fact-num             */
        ,input  ub.icnt-doc.shift-date  /* p-shift-date           */
        ,input  ub.icnt-doc.shift-num   /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера документа счетчиков ТРК" skip
          "doc-num"                 ub.icnt-doc.doc-code    skip
          "fact-date"               ub.icnt-doc.fact-date   skip
          "fact-time"               ub.icnt-doc.fact-time   skip
          "fact-num"                v-fact-num             skip
          "shift-date"              ub.icnt-doc.shift-date  skip
          "shift-num"               ub.icnt-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        ub.icnt-doc.fact-order = v-fact-order
      .

    end.
    if ub.icnt-doc.doc-type = {&icnt-doc} then do:
      /* проверяем, что не нарушается порядок закрытия сверок */
      find first buf_icnt-doc no-lock
        where buf_icnt-doc.obj-type   =  ub.icnt-doc.obj-type
          and buf_icnt-doc.obj-code   =  ub.icnt-doc.obj-code
          and buf_icnt-doc.status_    =  ub.icnt-doc.status_
          and buf_icnt-doc.fact-order >= ub.icnt-doc.fact-order
          and recid(buf_icnt-doc)     <> recid(ub.icnt-doc)
        no-error .
      if available buf_icnt-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Имеется документ счетчиков ТРК с более высоким порядковым номером, чем текущий." skip
          "Закрываемый документ" skip
          {&tabulation} "Номер"                      ub.icnt-doc.doc-code    skip
          {&tabulation} "Факт-Номер"                 ub.icnt-doc.fact-order  skip
          {&tabulation} "Дата фактического закрытия" ub.icnt-doc.fact-date   skip
          {&tabulation} "Дата начала смены"          ub.icnt-doc.shift-date  skip
          {&tabulation} "Номер смены"                ub.icnt-doc.shift-num   skip
          {&tabulation} "Порядок смены"              ub.icnt-doc.shift-num   skip
          "Существует документ счетчиков ТРК " skip
          {&tabulation} "Номер"                      buf_icnt-doc.doc-code   skip
          {&tabulation} "Факт-Номер"                 buf_icnt-doc.fact-order skip
          {&tabulation} "Дата фактического закрытия" buf_icnt-doc.fact-date  skip
          {&tabulation} "Дата начала смены"          buf_icnt-doc.shift-date skip
          {&tabulation} "Номер смены"                buf_icnt-doc.shift-name skip
          {&tabulation} "Порядок смены"              buf_icnt-doc.shift-num skip
          view-as alert-box error .
        undo , return error .
      end.
    end.
  end.

end procedure. /* change-status-act */