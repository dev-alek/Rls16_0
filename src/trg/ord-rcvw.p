block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись поставки

Автор: Чернова Светлана Александровна
Дата создания: 04/27/02
Author: Svetlana Chernova
Creation date: 04/27/02

*/
TRIGGER PROCEDURE FOR WRITE OF ub.ord-doc-rcv  old old_ord-doc-rcv  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись поставки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }

define variable num_rec        as integer   no-undo .
define variable num_gds        as integer   no-undo .
define variable start-time     as integer   no-undo .
define variable current-time   as character no-undo .
define variable current-action as character no-undo .
define variable v-description-ord-type as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer o-clients  for clients.
define buffer c-clients  for clients.
define variable f-host as integer no-undo .
assign
  v-description-ord-type = ub.ORD-doc-rcv.doc-type
.

/* для показа процесса закрытия документа */

def frame a
  ub.ORD-doc-rcv.rcv-code                    label "Поставка" skip
  v-description-ord-type                     label "Тип документа" skip
  current-action         format "x(40)"      no-label skip
  num_rec                format ">>>>>>>9"   label "Обработано артикулов" skip
  ub.ord-line-rcv.artic                      label "Текущий артикул"      skip
  num_gds                format ">>>>>>>9"   label "Обработано признаков" skip
  current-time           format "x(8)"       label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Обработка поставки"
  .

main-block :
do transaction
on error undo main-block, return error
:

  /* обновляем пользователя, дату и время последнего обновления */
  if not g#news
  then do:
    { gbl/curdburt.i
      ub.ord-doc-rcv.user-db-num
      ub.ord-doc-rcv.user-name
      ub.ord-doc-rcv.sys-date
      ub.ord-doc-rcv.sys-time
      ub.ord-doc-rcv.sys-time-int
    }
  end.

  if ub.ord-doc-rcv.status_ = {&g___new}
  then do:
      if ub.ord-doc-rcv.creid = "" then do:
        assign
          ub.ord-doc-rcv.creid = g#userid
        .
      end.

    assign
      ub.ord-doc-rcv.fact-num = next-value (s-ord-fact, {&db-name_schema})
    .
  end.

  if ub.ORD-doc-rcv.doc-type = "in":U then do:
     find first o-clients where
                o-clients.obj-code = ub.ORD-doc-rcv.obj-code and
                o-clients.obj-type = ub.ORD-doc-rcv.obj-type no-lock no-error .
                if not available o-clients then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Объект" ub.ORD-doc-rcv.obj-code ub.ORD-doc-rcv.obj-type skip
                      "не найден !" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.
                end.
       if ub.ORD-doc-rcv.obj-type = {&shop} then do:
          find first shop where shop.obj-code = ub.ORD-doc-rcv.obj-code no-lock .
          f-host = shop.host-code.
       end.
       if ub.ORD-doc-rcv.obj-type = {&stock} then do:
          find first store where store.obj-code = ub.ORD-doc-rcv.obj-code no-lock .
          f-host = store.host-code.
       end.


       if ub.ORD-doc-rcv.host-code <> f-host then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Объект" ub.ORD-doc-rcv.obj-code ub.ORD-doc-rcv.obj-type skip
                      "не принадлежит фирме " ub.ORD-doc-rcv.host-code "!" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.

       end.

     find first c-clients where
                c-clients.obj-code = ub.ORD-doc-rcv.cli-code and
                c-clients.obj-type = ub.ORD-doc-rcv.cli-type no-lock no-error .
                if not available c-clients then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Контрагент" ub.ORD-doc-rcv.obj-code ub.ORD-doc-rcv.obj-type skip
                      "не найден !" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.
                end.

       if ub.ORD-doc-rcv.cli-type = {&shop} then do:
          find first shop where shop.obj-code = ub.ORD-doc-rcv.cli-code no-lock .
          f-host = shop.host-code.
       end.
       if ub.ORD-doc-rcv.cli-type = {&stock} then do:
          find first store where store.obj-code = ub.ORD-doc-rcv.cli-code no-lock .
          f-host = store.host-code.
       end.


       if ub.ORD-doc-rcv.host-code <> f-host then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Контрагент" ub.ORD-doc-rcv.cli-code ub.ORD-doc-rcv.cli-type skip
                      "не принадлежит фирме " ub.ORD-doc-rcv.host-code "!" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.

       end.


  end.

  if ub.ORD-doc-rcv.doc-type = "out":U then do:
     find first o-clients where
                o-clients.obj-code = ub.ORD-doc-rcv.obj-code and
                o-clients.obj-type = ub.ORD-doc-rcv.obj-type no-lock no-error .
                if not available o-clients then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Объект" ub.ORD-doc-rcv.obj-code ub.ORD-doc-rcv.obj-type skip
                      "не найден !" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.
                end.
       if ub.ORD-doc-rcv.obj-type = {&shop} then do:
          find first shop where shop.obj-code = ub.ORD-doc-rcv.obj-code no-lock .
          f-host = shop.host-code.
       end.
       if ub.ORD-doc-rcv.obj-type = {&stock} then do:
          find first store where store.obj-code = ub.ORD-doc-rcv.obj-code no-lock .
          f-host = store.host-code.
       end.


       if ub.ORD-doc-rcv.host-code <> f-host then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Объект" ub.ORD-doc-rcv.obj-code ub.ORD-doc-rcv.obj-type skip
                      "не принадлежит фирме " ub.ORD-doc-rcv.host-code "!" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.

       end.

     find first c-clients where
                c-clients.obj-code = ub.ORD-doc-rcv.cli-code and
                c-clients.obj-type = ub.ORD-doc-rcv.cli-type no-lock no-error .
                if not available c-clients then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Контрагент" ub.ORD-doc-rcv.obj-code ub.ORD-doc-rcv.obj-type skip
                      "не найден !" skip
                      "Поставка" ub.ORD-doc-rcv.rcv-code skip
                      view-as alert-box error .
                    undo main-block, return error.
                end.

  end.


  if ub.ORD-doc-rcv.status_ = {&fact} and g#news = false  then do:
    define var l-date as date      no-undo .
    define var l-time as integer   no-undo .
    define variable s-date as date      no-undo . /* дата начала смены для документа */
    define variable s-num  as integer   no-undo . /* порядок смены для документа */
    define variable s-name as character no-undo . /* номер смены для документа */
    /* фактическое время закрытия */
    run cur-time in this-procedure (output l-date ,output  l-time) no-error .

    ub.ORD-doc-rcv.fact-time  = l-time .


    run gbl/factdate.p ( input ub.ORD-doc-rcv.obj-type  ,
                  input ub.ORD-doc-rcv.obj-code   ,
                  input-output ub.ORD-doc-rcv.fact-date ,
                  input-output ub.ORD-doc-rcv.fact-time ,
                  input-output s-date  ,
                  input-output s-num   ,
                  input-output s-name  ,
                  input        yes     ) no-error .
    assign
      ub.ORD-doc-rcv.shift-date = s-date
      ub.ORD-doc-rcv.shift-num  = s-num
      ub.ord-doc-rcv.shift-name = s-name
     .

      /* определяем фактический номер документа */
    if not g#news then do:
      assign
        ub.ORD-doc-rcv.fact-num = next-value (s-ORD-fact, {&db-name_schema})
      .
      /* определяем fact-order */
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .

      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        ub.ORD-doc-rcv.obj-type
        ub.ORD-doc-rcv.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "Поставка" ub.ORD-doc-rcv.rcv-code skip
          "Объект" ub.ORD-doc-rcv.obj-type ub.ORD-doc-rcv.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.

      run factord in this-procedure
        (input  ub.ORD-doc-rcv.fact-date   /* p-fact-date            */
        ,input  ub.ORD-doc-rcv.fact-time   /* p-fact-time            */
        ,input  ub.ORD-doc-rcv.fact-num    /* p-fact-num             */
        ,input  ub.ORD-doc-rcv.shift-date  /* p-shift-date           */
        ,input  ub.ORD-doc-rcv.shift-num   /* p-shift-num            */
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
          "Ошибка при определении фактического номера складского документа" skip
          "Поставка" ub.ORD-doc-rcv.rcv-code skip
          "fact-date"               ub.ORD-doc-rcv.fact-date   skip
          "fact-time"               ub.ORD-doc-rcv.fact-time   skip
          "fact-num"                ub.ORD-doc-rcv.fact-num    skip
          "shift-date"              ub.ORD-doc-rcv.shift-date  skip
          "shift-num"               ub.ORD-doc-rcv.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        ub.ORD-doc-rcv.fact-order = v-fact-order
      .
    end.
  end.



  run cur-time in this-procedure ( output v-today
                                 , output start-time
                                 ).
  assign
    current-action = "Проверка статуса."
  .

  view frame a.
    display
    ub.ORD-doc-rcv.rcv-code
    v-description-ord-type
    with frame a.

  assign
    current-action = "Проверка строк."
    .

  for each ub.ord-line-rcv exclusive-lock
    where ub.ord-line-rcv.doc-code = ub.ORD-doc-rcv.doc-code
      and ub.ord-line-rcv.rcv-code = ub.ORD-doc-rcv.rcv-code
  on error undo main-block, return error
  on end-key undo main-block, return error
  :
    run process-line in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара" skip
        "Поставка" ub.ORD-doc-rcv.rcv-code skip
        "Артикул" ub.ord-line-rcv.artic ub.ord-line-rcv.prod-type ub.ord-line-rcv.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo main-block, return error .
    end.
  end.  /* for each ub.ord-line-rcv */


/* история */
if g#news  = false and ub.ord-doc-rcv.status_  <> {&g___new} then do:
    create ub.c-ord-doc.
    BUFFER-COPY old_ord-doc-rcv  TO ub.c-ord-doc
    assign
      ub.c-ord-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
      ub.c-ord-doc.corr-time          = start-time
      ub.c-ord-doc.corr-user-db-num   = g#db-num
      ub.c-ord-doc.corr-user-name     = g#userid
      ub.c-ord-doc.corr-date          = v-today
   .

end.

/* Статус  */
 if ub.ORD-doc-rcv.status_ = {&fact} or
  ( ub.ORD-doc-rcv.status_ = {&ord-rcv} AND OLD_ORD-doc-rcv.status_ <> {&ord-rcv} ) or
    ub.ORD-doc-rcv.status_ = {&ord-req}
    then do:

     if not g#news  then do:
        run str/callnews.p
          (input {&table_ord-doc-rcv}
          ,input (buffer ub.ORD-doc-rcv:handle)
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "1.Невозможно маршрутизировать ORD-doc-rcv для отправки в новости" skip
            "Поставка" ub.ORD-doc-rcv.rcv-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
     end.
     else do:
     end.
 end.

 /* При создании в статусе поставка накладных надо отправлять не куст, а cmd-bush */
  if  not g#news  and
     ub.ord-doc-rcv.status_  = {&ord-rcv} and
     old_ord-doc-rcv.status_ = {&ord-rcv} and
  (  old_ord-doc-rcv.ship-time <> ub.ord-doc-rcv.ship-time or
     old_ord-doc-rcv.fact-ship-time <> ub.ord-doc-rcv.fact-ship-time or
     old_ord-doc-rcv.trn-code <> ub.ord-doc-rcv.trn-code ) then do:
/* TODO надо отправить ord-chain */
     run trg/cmd-rcvr.p (input ub.ord-doc-rcv.doc-code, input ub.ord-doc-rcv.rcv-code) no-error .
     if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка trg/cmd-rcvr.p"
          view-as alert-box error
        .
         return error return-value .
     end.

  end.

/* Прием новостей */
    if ub.ORD-doc-rcv.doc-type = {&ord-req} and g#db-num = 0 and  g#news then do:
        run str/callnews.p
          (input {&table_ord-doc-rcv}
          ,input (buffer ub.ORD-doc-rcv:handle)
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "2.Невозможно маршрутизировать ORD-doc-rcv для отправки в новости" skip
            "Связка Заказ ОО - Накладная" ub.ORD-doc-rcv.rcv-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

    end.

  assign
    current-action = "Проверка строк."
  .

  for each ub.ord-line-rcv exclusive-lock
    where ub.ord-line-rcv.doc-code = ub.ORD-doc-rcv.doc-code
      and ub.ord-line-rcv.rcv-code = ub.ORD-doc-rcv.rcv-code
  on error undo main-block, return error
  on end-key undo main-block, return error
  :
    run process-line in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара" skip
        "Поставка" ub.ORD-doc-rcv.rcv-code skip
        "Артикул" ub.ord-line-rcv.artic ub.ord-line-rcv.prod-type ub.ord-line-rcv.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo main-block, return error .
    end.
  end.  /* for each ub.ord-line-rcv */

define variable v-message as character no-undo .
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
        {&edoc-proc_event_rcv}
      " buffer old_ord-doc-rcv:handle "
      " buffer ub.ord-doc-rcv:handle "
      ''
      ''
      no-error
      }
    if error-status:error
    then do:
      v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}
                              , error-status:get-message(1)
                              , return-value ).
      if not g#news then do:
        message
        v-message
        view-as alert-box error .
      end.
      undo main-block,  return error v-message.
    end.



    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ord-doc-rcv}
        , input ( buffer ub.ord-doc-rcv:handle )
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
end. /*do*/



procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
      current-time = string(v-time - start-time, "HH:MM:SS")
      current-action = p-action
    .
    display
      current-time current-action
      with frame a.
  end.
end procedure. /* show-action */

procedure process-line :
  do
  on error undo, return error
  :
    define variable v-root-node like ub.gds-prt.node-code no-undo .
    /* ведется независимый учет товара по единице измерения клиента */
    define variable l-goods-twounit as logical no-undo .
    define variable rsrv-code       as character no-undo .

    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.


    def buffer buf_parts for ub.parts .

    /* обновить информацию о текущей закрываемой строке */
    assign
      num_rec   = num_rec + 1
    .

    if num_rec mod 10 = 0 then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      display
        num_rec ub.ord-line-rcv.artic num_gds current-time current-action
        with frame a.

    end.

    find first ub.goods no-lock
      where ub.goods.artic     = ub.ord-line-rcv.artic
        and ub.goods.prod-type = ub.ord-line-rcv.prod-type
        and ub.goods.prod-code = ub.ord-line-rcv.prod-code
      no-error .
    if not available ub.goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Поставка" ub.ORD-doc-rcv.rcv-code skip
        "Артикул" ub.ord-line-rcv.artic ub.ord-line-rcv.prod-type ub.ord-line-rcv.prod-code skip
        "" (if g#db-num = 0
            then "Если товар был переименован," + {&new-line}
               + "необходимо принять новости в УБД и переформировать пакеты"
            else ""
          ) skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.ord-line-rcv.cli-base-rate = ? or  ub.ord-line-rcv.cli-base-rate = 0 then do:
       assign
         ub.ord-line-rcv.cli-base-rate = ub.goods.cli-base-rate
       .
    end.
    if ub.ord-line-rcv.unit-cli = ? or  ub.ord-line-rcv.unit-cli = "" then do:
       assign
         ub.ord-line-rcv.unit-cli = ub.goods.unit-cli
       .
    end.

  end.
end procedure . /* process-line */

/* $Workfile$ e n d */