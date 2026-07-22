block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись заказа СЗФП

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


Creation date: 04/27/02 1:49

*/
TRIGGER PROCEDURE FOR WRITE OF ub.ord-cons /*  old old_ord-cons  */.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись заказа СЗФП".
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

assign
  v-description-ord-type = ub.ORD-cons.status_
.

/* для показа процесса закрытия документа */

def frame a
  ub.ORD-cons.cons-code                      label "СЗФП" skip
  v-description-ord-type                     label "Статус" skip
  current-action         format "x(40)"      no-label skip
  num_rec                format ">>>>>>>9"   label "Обработано артикулов" skip
  ub.ord-gds-cons.artic                      label "Текущий артикул"      skip
  num_gds                format ">>>>>>>9"   label "Обработано признаков" skip
  current-time           format "x(8)"       label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Обработка заказа"
  .


main-block :
do transaction
on error undo main-block, return error
:

  /* обновляем пользователя, дату и время последнего обновления */
  if not g#news
  then do:
    { gbl/curdburt.i
      ub.ord-cons.user-db-num
      ub.ord-cons.user-name
      ub.ord-cons.sys-date
      ub.ord-cons.sys-time
      ub.ord-cons.sys-time-int
    }
  end.

  if ub.ORD-cons.status_ = {&g___new}
  then do:
    if ub.ORD-cons.creid = ""
    then do:
      assign
        ub.ord-cons.creid = g#userid
      .
    end.

    assign
      ub.ORD-cons.fact-num = next-value (s-ORD-fact, {&db-name_schema})
    .
  end.

    /* определяем пользователя */
    if ub.ORD-cons.status_ = {&ord-alloc} then do:
      assign
        ub.ORD-cons.creid = g#userid
      .
    end.


if g#db-num = 0 then do:

  if ub.ORD-cons.status_ = {&fact} then do:
    define var l-date as date      no-undo .
    define var l-time as integer   no-undo .
    define variable s-date as date      no-undo . /* дата начала смены для документа */
    define variable s-num  as integer   no-undo . /* порядок смены для документа */
    define variable s-name as character no-undo . /* номер смены для документа */

    /* фактическое время закрытия */
    run cur-time in this-procedure ( output l-date , output l-time ) no-error .

    ub.ORD-cons.fact-time  = l-time .


    run gbl/factdate.p
                ( input ub.ORD-cons.input-obj-type  ,
                  input ub.ORD-cons.input-obj-code   ,
                  input-output ub.ORD-cons.fact-date ,
                  input-output ub.ORD-cons.fact-time ,
                  input-output s-date  ,
                  input-output s-num ,
                  input-output s-name,
                  input        yes     ) no-error .
    assign
      ub.ORD-cons.shift-date = s-date
      ub.ORD-cons.shift-num  = s-num
      ub.ord-cons.shift-name = s-name.
end.
      /* определяем фактический номер документа */
    if g#news then do:
      if ub.ORD-cons.fact-num = ?
      or ub.ORD-cons.fact-num = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "fact-num не задан в складском документе" skip
          "СЗФП" ub.ORD-cons.cons-code skip
          view-as alert-box error .
        undo main-block, return error.
      end.

    end.
    current-action = "определяем порядковый номер".
    if not g#news then do:
      if ub.ORD-cons.fact-order > 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер складского документа" skip
          "СЗФП" ub.ORD-cons.cons-code skip
          "fact-order" ub.ORD-cons.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.

      if ub.ORD-cons.fact-num = ? or ub.ORD-cons.fact-num = 0 then do:
      /* определяем порядковый номер */
      assign
        ub.ORD-cons.fact-num = next-value (s-ORD-fact, {&db-name_schema})
      .
      end.
      if ub.ORD-cons.status_ = {&fact} then do:
      /* определяем fact-order */
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .

      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        ub.ORD-cons.input-obj-type
        ub.ORD-cons.input-obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "СЗФП" ub.ORD-cons.cons-code skip
          "Объект" ub.ORD-cons.input-obj-type ub.ORD-cons.input-obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.

      run factord in this-procedure
        (input  ub.ORD-cons.fact-date   /* p-fact-date            */
        ,input  ub.ORD-cons.fact-time   /* p-fact-time            */
        ,input  ub.ORD-cons.fact-num    /* p-fact-num             */
        ,input  ub.ORD-cons.shift-date  /* p-shift-date           */
        ,input  ub.ORD-cons.shift-num   /* p-shift-num            */
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
          "СЗФП" ub.ORD-cons.cons-code skip
          "fact-date"               ub.ORD-cons.fact-date   skip
          "fact-time"               ub.ORD-cons.fact-time   skip
          "fact-num"                ub.ORD-cons.fact-num    skip
          "shift-date"              ub.ORD-cons.shift-date  skip
          "shift-num"               ub.ORD-cons.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        ub.ORD-cons.fact-order = v-fact-order
      .
    end.
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
    ub.ORD-cons.cons-code
    v-description-ord-type
    with frame a.

  for each ub.ord-gds-cons exclusive-lock
    where ub.ord-gds-cons.cons-code = ub.ORD-cons.cons-code
  on error undo main-block, return error
  on end-key undo main-block, return error
  :
    run process-line in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара" skip
        "СЗФП" ub.ORD-cons.cons-code skip
        "Артикул" ub.ord-gds-cons.artic ub.ord-gds-cons.prod-type ub.ord-gds-cons.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo main-block, return error .
    end.
  end.  /* for each ub.ord-gds-cons */



    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ord-cons}
        , input ( buffer ub.ord-cons:handle )
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
        num_rec ub.ord-gds-cons.artic num_gds current-time current-action
        with frame a.
    end.
    current-action = "проверка товара".
    find first ub.goods no-lock
      where ub.goods.artic     = ub.ord-gds-cons.artic
        and ub.goods.prod-type = ub.ord-gds-cons.prod-type
        and ub.goods.prod-code = ub.ord-gds-cons.prod-code
      no-error .
    if not available ub.goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "СЗФП" ub.ORD-cons.cons-code skip
        "Артикул" ub.ord-gds-cons.artic ub.ord-gds-cons.prod-type ub.ord-gds-cons.prod-code skip
        "" (if g#db-num = 0
            then "Если товар был переименован," + {&new-line}
               + "необходимо принять новости в УБД и переформировать пакеты"
            else ""
          ) skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure . /* process-line */

/* $Workfile$ e n d */