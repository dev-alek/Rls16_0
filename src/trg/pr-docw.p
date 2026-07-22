block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ub.price-doc

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/26/01

*/

TRIGGER PROCEDURE FOR WRITE OF ub.price-doc old buffer old-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ub.price-doc".
{ cmp/vssrevis.i "substitute('&1|&2',ub.price-doc.doc-num,ub.price-doc.status_)" }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ trg/prdoclib.i }
{ gbl/cur-time.i }
{ gbl/clntattr.i }

define temp-table temp-goods no-undo
  field gds-code         like ub.goods.gds-code
  field root-b-code      like ub.bar-code.b-code
  field main-price-exist as logical

  index xpk is primary unique gds-code
  index xie1 main-price-exist
.


define variable num_rec        as integer   no-undo .
define variable num_gds        as integer   no-undo .
define variable start-time     as integer   no-undo .
define variable current-time   as character no-undo .
define variable current-action as character no-undo .
define buffer last_price-all         for ub.price-all  .
define variable l-check-price-parts  as logical   no-undo .
define variable par-is-pharm         as character no-undo .
define variable par-type             as character no-undo .

def frame a
  ub.price-doc.doc-num label "Переоценка"  skip
  current-action       format "x(40)"      no-label skip
  num_rec              format ">>>>>>>9"   label "Обработано артикулов" skip
  ub.price-list.artic                      label "Текущий артикул" skip
  num_gds              format ">>>>>>>9"   label "Обработано строк" skip
  current-time         format "x(8)" label "Время" skip

  with view-as dialog-box side-labels three-d
  title "Обработка переоценки"
  .

Main-block:
do transaction
on error undo main-block, return error
on end-key undo main-block, return error
:

{ gbl/conf-rd.i "'is-pharm'" ub.price-doc.host-code ub.price-doc.obj-type ub.price-doc.obj-code "''" "''" "''" no par-is-pharm par-type no-error } .
  l-check-price-parts = true .

if par-is-pharm = "yes"  then do:
   { str/opharm.i ub.price-doc.obj-type ub.price-doc.obj-code par-is-pharm }
end.

if par-is-pharm = "yes"  then do:
   l-check-price-parts = false .
end.

  /* проверяем уникальность кода документа */
  run trg/chkdocnm.p
    ( input ub.price-doc.doc-num /* p-doc-code   */
    , input {&table_price-doc}   /* p-table-name */
    , input recid (ub.price-doc)  /* p-recid      */
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке уникальности кода документа" skip
      "Переоценка" ub.price-doc.doc-num skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if ub.price-doc.creid = "" then do:
    assign
      ub.price-doc.creid = g#userid
    .
  end.

  /* определяем фирму для объекта */
  { gbl/hostcode.i
    ub.price-doc.obj-type
    ub.price-doc.obj-code
    ub.price-doc.host-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти фирму для объекта " ub.price-doc.obj-type ub.price-doc.obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if old-doc.status_ = ub.price-doc.status_ then do:
    /* статус не изменился - ничего не делаем */
    return. /* --->>>--- */
  end.

  if  not new ub.price-doc
  and old-doc.status_ = {&act-overvalue}
  and ub.price-doc.status_ <> {&act-overvalue} then do:
    /* нельзя открывать переоценки, закрытые до статуса {&act-overvalue} */
    message
      vss-workfile vss-revision vss-description skip
      "Изменение статуса переоценки невозможно" skip
      "Переоценка" ub.price-doc.doc-num skip
      "Переоценка закрыта до статуса" old-doc.status_ skip
      "Нельзя изменить на статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* обновляем дату и время последнего обновления */
  if not g#news
  then do:
    { gbl/curdburt.i
      ub.price-doc.user-db-num
      ub.price-doc.user-name
      ub.price-doc.sys-date
      ub.price-doc.sys-time
      ub.price-doc.sys-time-int
    }
  end.

  if ub.price-doc.status_ = {&order} then do:
    run change-status-prikaz in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выполнении программы change-status-prikaz" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if ub.price-doc.status_ = {&permitted} then do:
    run change-status-permitted in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выполнении программы change-status-permitted" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if ub.price-doc.status_ = {&act-overvalue} then do:
    run change-status-act in this-procedure
      (input old-doc.status_ = {&permitted}
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выполнении программы change-status-act" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

/*  История */
  if not g#news and ub.price-doc.status_ <> {&g___new} then do:
    run trg/pr-doch.p
      (buffer old-doc
      ,buffer ub.price-doc
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи истории изменений переоценки" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_price-doc}
        , input ( buffer ub.price-doc:handle )
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


procedure change-status-act :

  define input parameter l-need-clear-ov-on as logical no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  define buffer buf_price-list for ub.price-list .

  do
  on error undo, return error
  :

    /* накладываем блокировку на все используемые товары */
    run trg/lockprdc.p
      (input ub.price-doc.doc-num
      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не удается заблокировать товары для переоценки" skip
        "Переоценка" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if g#news then do:
      if ub.price-doc.fact-num = ?
      or ub.price-doc.fact-num = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан фактический номер переоценки" skip
          "Документ переоценки" ub.price-doc.doc-num skip
          "fact-num" ub.price-doc.fact-num skip
          view-as alert-box error .
        undo, return error .
      end.

      if ub.price-doc.fact-order = ?
      or ub.price-doc.fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан фактический номер переоценки" skip
          "Документ переоценки" ub.price-doc.doc-num skip
          "fact-order" ub.price-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    if not g#news then do:
    /* проверяем факт дату, время */
      run gbl/chk-date.p
        (input ub.price-doc.obj-type
        ,input ub.price-doc.obj-code
        ,input ub.price-doc.fact-date
        ,input ub.price-doc.fact-time
        ,input ub.price-doc.shift-date
        ,input ub.price-doc.shift-num
        ,input yes
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при установке дат, времен, смен в переоценке(price-doc)." skip
          "fact-num" ub.price-doc.fact-num skip
          "fact-date" ub.price-doc.fact-date skip
          "fact-time" ub.price-doc.fact-time skip
          "shift-date" ub.price-doc.shift-date skip
          "shift-num" ub.price-doc.shift-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    /* определяем порядковый номер переоценки */
    if not g#news then do:
      if ub.price-doc.fact-num > 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер переоценки" skip
          "Документ переоценки" ub.price-doc.doc-num skip
          "fact-num" ub.price-doc.fact-num skip
          view-as alert-box error .
        undo, return error .
      end.

      if ub.price-doc.fact-order > 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер переоценки" skip
          "Документ переоценки" ub.price-doc.doc-num skip
          "fact-order" ub.price-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.

      /* определяем порядковый номер */
      assign
        ub.price-doc.fact-num = next-value (s-trn-fact, {&db-name_schema})
      .

      /* определяем fact-order */
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .

      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        ub.price-doc.obj-type
        ub.price-doc.obj-code
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
        (input  ub.price-doc.fact-date  /* p-fact-date            */
        ,input  ub.price-doc.fact-time  /* p-fact-time            */
        ,input  ub.price-doc.fact-num   /* p-fact-num             */
        ,input  ub.price-doc.shift-date /* p-shift-date           */
        ,input  ub.price-doc.shift-num  /* p-shift-num            */
        ,input  l-shift-on              /* p-shift-on             */
        ,output v-fact-order            /* p-fact-order           */
        ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
        ,output v-day-end-fact-order    /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера переоценки" skip
          "doc-num"                 ub.price-doc.doc-num    skip
          "fact-date"               ub.price-doc.fact-date  skip
          "fact-time"               ub.price-doc.fact-time  skip
          "fact-num"                ub.price-doc.fact-num   skip
          "shift-date"              ub.price-doc.shift-date skip
          "shift-num"               ub.price-doc.shift-num  skip
          "v-fact-order"            v-fact-order            skip
          "v-shift-end-fact-order"  v-shift-end-fact-order  skip
          "v-day-end-fact-order"    v-day-end-fact-order    skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        ub.price-doc.fact-order = v-fact-order
      .
      for each ub.price-all exclusive-lock where
           ub.price-all.out-code   = ub.price-doc.doc-num
           :
           assign
             ub.price-all.fact-order = v-fact-order
           .
      find first ub.price-list-type no-lock where
                 ub.price-list-type.plt-id      = ub.price-all.plt-id      and
                 ub.price-list-type.plt-db-num  = ub.price-all.plt-db-num  no-error .
      /*  отметка на старых ценах */
      if ub.price-list-type.main = true then do:
          for each  last_price-all exclusive-lock where
            last_price-all.main-indication = ub.price-all.main-indication  and
            last_price-all.type-price      = ub.price-all.type-price       and
            last_price-all.b-code          = ub.price-all.b-code           and
            last_price-all.gds-code        = ub.price-all.gds-code         and
            last_price-all.obj-code        = ub.price-all.obj-code         and
            last_price-all.obj-type        = ub.price-all.obj-type         and
            last_price-all.plt-priority    = 0                             and
            last_price-all.last-pr         = true
            and
            not (
                  last_price-all.pdf-id          = ub.price-all.pdf-id             and
                  last_price-all.pdf-db          = ub.price-all.pdf-db        )
              :
            assign
              last_price-all.last-pr           = false
              last_price-all.end-date          = ub.price-doc.fact-date
              last_price-all.fact-order-sys-to = v-fact-order
             .
          end.
      end.

      end.
    end.

    /* проверяем, что не нарушается порядок закрытия переоценок */
    if not g#news then do:
      define buffer buf_price-doc for ub.price-doc .
      find last buf_price-doc no-lock
        where buf_price-doc.obj-type = ub.price-doc.obj-type
          and buf_price-doc.obj-code = ub.price-doc.obj-code
        use-index fact-close
        no-error .
      if available buf_price-doc
      and buf_price-doc.fact-num > ub.price-doc.fact-num then do:
        message
          vss-workfile vss-revision vss-description skip
          "Имеется переоценка с более высоким порядковым номером, чем текущая." skip
          "Порядковый номер закрываемой переоценки: " ub.price-doc.fact-num "." skip
          "Порядковый номер переоценки" buf_price-doc.doc-num ": " buf_price-doc.fact-num skip
          view-as alert-box error .
        undo, return error .
      end.

      find last buf_price-doc no-lock
        where buf_price-doc.obj-type = ub.price-doc.obj-type
          and buf_price-doc.obj-code = ub.price-doc.obj-code
          and buf_price-doc.status_  = ub.price-doc.status_
        use-index fact-order
        no-error .
      if available buf_price-doc
      and buf_price-doc.fact-order > ub.price-doc.fact-order then do:
        message
          vss-workfile vss-revision vss-description skip
          "Имеется переоценка с более высоким порядковым номером, чем текущая" skip
          "Переоценка" ub.price-doc.doc-num skip
          "Порядковый номер закрываемой переоценки" ub.price-doc.fact-order skip
          "Найдена переоценка" buf_price-doc.doc-num skip
          "с порядковым номером" buf_price-doc.fact-order skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    run cur-time in this-procedure ( output v-today
                                   , output start-time
                                   ).
    view frame a.
    display
      ub.price-doc.doc-num
      with frame a.

    run show-action in this-procedure
      (input "Объявление новых цен на объекте"
      ).

    /* цена на объекте становится действующей */
    for each buf_price-list
      where buf_price-list.doc-num = ub.price-doc.doc-num
    on error undo, return error
    :
      assign
        num_rec      = num_rec + 1
      .
      if num_rec mod 10 = 0 then do:
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
          current-time = string(v-time - start-time, "HH:MM:SS")
        .
        display
          num_rec buf_price-list.artic num_gds current-time current-action
          with frame a.
        process events .
      end.

      define buffer buf_bar-code for ub.bar-code .
      find first buf_bar-code no-lock
        where buf_bar-code.b-code = buf_price-list.b-code
        .
      define buffer buf_goods for ub.goods .
      find first buf_goods no-lock
        where buf_goods.artic     = buf_price-list.artic
          and buf_goods.prod-type = buf_price-list.prod-type
          and buf_goods.prod-code = buf_price-list.prod-code
        .
      if buf_goods.gds-code <> buf_bar-code.gds-code then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке целостности переоценки" skip
          "Товар бар-кода не соответствует товару строки переоценки" skip
          "Переоценка" ub.price-doc.doc-num skip
          "Артикул строки переоценки" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
          "Код товара строки переоценки" buf_goods.gds-code skip
          "Бар-код" buf_price-list.b-code skip
          "Код товара бар-кода" buf_bar-code.gds-code skip
          view-as alert-box error .
        undo, return error .
      end.

      define buffer buf_temp-goods for temp-goods .
      find first buf_temp-goods no-lock
        where buf_temp-goods.gds-code = buf_goods.gds-code
        no-error .
      if not available buf_temp-goods then do:
        create buf_temp-goods .
        assign
          buf_temp-goods.gds-code = buf_goods.gds-code
        .

        { gbl/gdsbcode.i
          buf_temp-goods.gds-code
          ?
          buf_temp-goods.root-b-code
        }
      end.

      if  ( buf_price-list.b-code = buf_temp-goods.root-b-code )
          <>
          ( buf_price-list.main-price = true )
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке целостности переоценки" skip
          "У строки переоценки признак main-price не соответствует типу бар-кода" skip
          "Переоценка" ub.price-doc.doc-num skip
          "Артикул строки переоценки" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
          "Код товара строки переоценки" buf_goods.gds-code skip
          "Бар-код" buf_price-list.b-code skip
          "main-price" buf_price-list.main-price skip
          view-as alert-box error .
        undo, return error .
      end.

      if buf_price-list.main-price = true then do:
        assign
          buf_temp-goods.main-price-exist = true
        .
      end.


      assign
        buf_price-list.fact-order = ub.price-doc.fact-order
      .
    end.

    find first buf_temp-goods
      where buf_temp-goods.main-price-exist = false
      no-error .
    if available buf_temp-goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка проверки целостности переоценки" skip
        "В переоценке существуют строки" skip
        "для которых отсутствуют строки с корневым бар-кодом" skip
        "Переоценка" ub.price-doc.doc-num skip
        "Код товара" buf_temp-goods.gds-code skip
        view-as alert-box error .
      undo, return error .
    end.


    run show-action in this-procedure
      (input "Обработка товаров"
      ).
    assign
      num_rec = 0
    .

    /* определяем текущие продажные цены */
    /* и текущий остаток товара в продажных ценах */
    for each ub.price-list
      where ub.price-list.doc-num    = ub.price-doc.doc-num
        and ub.price-list.main-price = true
    on error undo, return error
    :
      /* обновляем информацию для пользователя о текущей закрываемой строке */
      assign
        num_rec      = num_rec + 1
      .
      if num_rec mod 10 = 0 then do:
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
          current-time = string(v-time - start-time, "HH:MM:SS")
        .
        display
          num_rec ub.price-list.artic num_gds current-time current-action
          with frame a.
        process events .
      end.

      /* отмечается товар для отправки на кассу */
      find first ub.goods no-lock
        where ub.goods.artic     = ub.price-list.artic
          and ub.goods.prod-type = ub.price-list.prod-type
          and ub.goods.prod-code = ub.price-list.prod-code
        .
      define variable v-gds-obj-fact-qnty as decimal   no-undo .

      run prdoclib-process-goods in this-procedure
        (input  ub.price-list.obj-type    /* p-obj-type               */
        ,input  ub.price-list.obj-code    /* p-obj-code               */
        ,input  ub.price-list.artic       /* p-artic                  */
        ,input  ub.price-list.prod-type   /* p-prod-type              */
        ,input  ub.price-list.prod-code   /* p-prod-code              */
        ,input  true                      /* l-check-price-list       */
        ,input  l-check-price-parts       /* l-check-price-parts  нет = аптека  */
        ,input  ub.price-doc.doc-num      /* p-doc-num                */
        ,input  ub.price-doc.fact-date    /* p-fact-date              */
        ,input  ub.price-doc.user-db-num  /* p-corr-user-db-num       */
        ,input  ub.price-doc.user-name    /* p-corr-user-name         */
        ,input  ub.price-doc.sys-date     /* p-corr-date              */
        ,input  ub.price-doc.sys-time-int /* p-corr-time              */
        ,input  ub.price-doc.sys-time     /* p-corr-time-str          */
        ,output v-gds-obj-fact-qnty       /* p-gds-obj-fact-qnty      */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке товара в переоценке" skip
          "Переоценка" ub.price-list.doc-num skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      /* обнуляется признак того, что товар необходимо переоценить
         обнуляется признак того, что товар находится в переоценке
      */
      define variable l-return-attribute as logical no-undo .
      define variable v-set-attribute as character no-undo .



      assign
        v-set-attribute =  ( if not g#news
                    and l-need-clear-ov-on
                    then 'ov-on=false':u
                    else ''
                  )
      .
       if v-set-attribute <> '' then do:
          { gbl/gdsobjat.i
            ub.price-list.obj-type
            ub.price-list.obj-code
            ub.price-list.artic
            ub.price-list.prod-type
            ub.price-list.prod-code
            v-set-attribute
            l-return-attribute
            no-error
          }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно изменить признаки товара на объекте ТОВАР В ПЕРЕОЦЕНКЕ" skip
              "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
              "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
              "action" v-set-attribute skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.

      assign
        v-set-attribute = 'in-ov=false':u
      .

      { gbl/gdsobjat.i
        ub.price-list.obj-type
        ub.price-list.obj-code
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        v-set-attribute
        l-return-attribute
        no-error
      }

      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно изменить признаки товара на объекте ТОВАР НУЖНО ПЕРЕОЦЕНИТЬ" skip
          "Объект"  ub.price-list.obj-type ub.price-list.obj-code skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          "action"  v-set-attribute skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      /* привязка партий к переоценке
        * происходит независимо в удаленной базе данных и в офисной базе данных
        */
      define variable v-total-parts-qnty like ub.parts.qnty no-undo .
      run copy-parts
        (input  ub.price-doc.doc-num    /* p-out-code         */
        ,input  ub.price-doc.obj-type   /* p-obj-type         */
        ,input  ub.price-doc.obj-code   /* p-obj-code         */
        ,input  ub.price-list.artic     /* p-artic            */
        ,input  ub.price-list.prod-type /* p-prod-type        */
        ,input  ub.price-list.prod-code /* p-prod-code        */
        ,output v-total-parts-qnty      /* p-total-parts-qnty */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при привязывании архивных партий к переоценке" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if v-total-parts-qnty <> v-gds-obj-fact-qnty then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке количества привязанных партий по переоценке" skip
          "Переоценка" ub.price-doc.doc-num skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          "Общее количество по товару"    v-gds-obj-fact-qnty skip
          "Количество привязанных партий" v-total-parts-qnty  skip
          view-as alert-box error .
        undo, return error .
      end.

      /* проверяем целостность товара
        gds-obj совпадает с корневым prt-obj  и
        с партиями свободной зоны и зарезервированными из свободной зоны
      */
      { gbl/gdscheck.i
        ub.price-list.obj-type
        ub.price-list.obj-code
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        ?
        "''"
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке целостности товара после закрытия переоценки" skip
          "Переоценка" ub.price-list.doc-num skip
          "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
          "Товар"  ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          "Закрытие документа невозможно" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    /* обновление информации в складских архивах */
    run trg/nu_arh.p
      (input ub.price-doc.doc-num  /* p-doc-code   */
      ,input {&table_price-doc}    /* p-table-name */
      ,input ub.price-doc.obj-type /* p-obj-type   */
      ,input ub.price-doc.obj-code /* p-obj-code   */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры nu_arh.p" skip
        "Переоценка" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run trg/nu_aht.p
      (input ub.price-doc.doc-num  /* p-doc-code   */
      ,input {&table_price-doc}    /* p-table-name */
      ,input ub.price-doc.obj-type /* p-obj-type   */
      ,input ub.price-doc.obj-code /* p-obj-code   */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры nu_aht.p" skip
        "Переоценка" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run show-action in this-procedure
      (input "Передача остатков товара через новости"
      ).
    run trg/prtobrem.p
      (input false                /* p-trn-doc    */
      ,input ub.price-doc.doc-num /* p-doc-code   */
      ,input false                /* p-delete-doc */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче остатков товара через новости" skip
        "Переоценка" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    /************ вызов СПН *************/
    if not g#news then do:
      /* номер БД, куда посылать новости находится в ub.clients.db-num */
      define buffer price-doc_clients for ub.clients .
      find price-doc_clients no-lock
        where price-doc_clients.obj-code = ub.price-doc.obj-code
          and price-doc_clients.obj-type = ub.price-doc.obj-type
        .
      if (ub.price-doc.status_ = {&order}
          and g#db-num = 0
          and ub.clients.db-num <> 0
         )
      or (ub.price-doc.status_ = {&act-overvalue}
          and g#db-num <> 0
         )
      then do:
        run show-action in this-procedure
          (input "Отправка документа в новости "  + ub.price-doc.status_
          ).
        run str/callnews.p
          (input {&table_price-doc}
          ,input (buffer ub.price-doc:handle)
          ) no-error.
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка маршрутизации документа переоценки в новости" skip
            error-status:get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end. /*if not g#news then do:*/
    
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_price-doc}
      " buffer old-doc:handle "
      " buffer ub.price-doc:handle "
      ''
      ''
      no-error
    }
    if error-status:error
    then do:
      define variable v-message as character no-undo .
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
      undo,  return error v-message.
    end.
  end.

end procedure. /* change-status-act */


procedure change-status-prikaz :

  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_prt-obj  for ub.prt-obj .

  define variable v-root-node   like ub.prt-obj.prt-code no-undo .
  define variable v-gds-code    like ub.goods.gds-code   no-undo .
  define variable v-root-b-code like ub.bar-code.b-code  no-undo .

  do
  on error undo, return error
  :
    for each ub.price-list
      where ub.price-list.doc-num    = ub.price-doc.doc-num
        and ub.price-list.main-price = true
    on error undo, return error
    :
      find first ub.goods no-lock
        where ub.goods.artic     = ub.price-list.artic
          and ub.goods.prod-type = ub.price-list.prod-type
          and ub.goods.prod-code = ub.price-list.prod-code
        no-error .
      if not available ub.goods then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Переоценка" ub.price-list.doc-num skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          "" (if g#db-num = 0
              then "Если товар был переименован," + {&new-line} + "необходимо принять новости в УБД и переформировать пакеты"
              else ""
            ) skip
          view-as alert-box error .
        undo, return error .
      end.

      { gbl/gds-code.i
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        v-gds-code
      }

      { gbl/gdsbcode.i
        v-gds-code
        ?
        v-root-b-code
      }

      if ub.price-list.b-code <> v-root-b-code then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка установки признака main-price" skip
          "Переоценка" ub.price-list.doc-num skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          "Бар-код" ub.price-list.b-code skip
          "Корневой бар-код" v-root-b-code skip
          "Признак main-price" ub.price-list.main-price skip
          view-as alert-box error .
        undo, return error .
      end.

      /* определяется ссылка на gds-prt.node-code корня */
      { gbl/rootnode.i
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        v-root-node
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака" skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.

      /* создаются записи:
            товар на фирме
            товар на объекте
            корневой признак на объекте
      */
      { gbl/gdscr.i
        ub.price-list.obj-type
        ub.price-list.obj-code
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        v-root-node
        buf_gds-obj
        buf_prt-obj
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании информации о товаре на фирме" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      find current buf_gds-obj  exclusive-lock .
      find current buf_prt-obj  exclusive-lock .

      /* отмечается товар для отправки на кассу */
      /* по требованию технологов товары отправляются на кассу */
      /* только при закрытии переоценки до статуса {&act-overvalue} */
      /* { ref/scgdsupd.i ub.goods ub.price-list.obj-type ub.price-list.obj-code } */
    end.

    /* вызов СПН */
    if not g#news then do:
      run str/callnews.p
        (input {&table_price-doc}
        ,input (buffer ub.price-doc:handle)
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка маршрутизации документа переоценки в новости:" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if ub.price-doc.doc-num-es <> ? and ub.price-doc.doc-num-es <> ""
    then do :
        { gbl/rum-runa.i
          ?
          this-procedure:handle
          ?
          {&edoc-proc_event_price-doc}
          " buffer old-doc:handle "
          " buffer ub.price-doc:handle "
          ''
          ''
          no-error
        }
        if error-status:error
        then do:
          define variable v-message as character no-undo .
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
          undo,  return error v-message.
        end.
    end.
  end.

end procedure. /* change-status-prikaz */


procedure change-status-permitted :

  define variable l-ov-on       as logical no-undo .
  define variable v-gds-code    like ub.goods.gds-code  no-undo .
  define variable v-root-b-code like ub.bar-code.b-code no-undo .

  do
  on error undo, return error
  :
    if not g#news then do:
      for each ub.price-list
        where ub.price-list.doc-num    = ub.price-doc.doc-num
          and ub.price-list.main-price = true
      on error undo, return error
      :

        { gbl/gds-code.i
          ub.price-list.artic
          ub.price-list.prod-type
          ub.price-list.prod-code
          v-gds-code
        }

        { gbl/gdsbcode.i
          v-gds-code
          ?
          v-root-b-code
        }

        if ub.price-list.b-code <> v-root-b-code then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка установки признака main-price" skip
            "Переоценка" ub.price-list.doc-num skip
            "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
            "Бар-код" ub.price-list.b-code skip
            "Корневой бар-код" v-root-b-code skip
            "Признак main-price" ub.price-list.main-price skip
            view-as alert-box error .
          undo, return error .
        end.

        { gbl/gdsobjat.i
          ub.price-list.obj-type
          ub.price-list.obj-code
          ub.price-list.artic
          ub.price-list.prod-type
          ub.price-list.prod-code
          "'ov-on=true'"
          l-ov-on
          no-error
        }
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания признака товара на объекте" skip
            "Объект"  ub.price-list.obj-type ub.price-list.obj-code skip
            "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
            "action"  "ov-on=true" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

end procedure. /* change-status-permitted */



procedure copy-parts :

  define input parameter  p-out-code         like ub.parts.out-code  no-undo .
  define input parameter  p-obj-type         like ub.parts.obj-type  no-undo .
  define input parameter  p-obj-code         like ub.parts.obj-code  no-undo .
  define input parameter  p-artic            like ub.parts.artic     no-undo .
  define input parameter  p-prod-type        like ub.parts.prod-type no-undo .
  define input parameter  p-prod-code        like ub.parts.prod-code no-undo .
  define output parameter p-total-parts-qnty like ub.parts.qnty      no-undo .

  def buffer buf_parts for ub.parts .

  do
  on error undo, return error
  :
    assign
      p-total-parts-qnty = 0
    .

    /* привязка партий к переоценке */
    /* идем по всем партиям, но пропуская порожденные партии, */
    /* зарезервированные за документами */
    for each ub.parts
      where ub.parts.obj-type  = p-obj-type
        and ub.parts.obj-code  = p-obj-code
        and ub.parts.artic     = p-artic
        and ub.parts.prod-type = p-prod-type
        and ub.parts.prod-code = p-prod-code
        and ub.parts.rsrv-free = yes
        and ub.parts.status_   = no
        and ub.parts.in-code   <> ub.parts.out-code
    on error undo, return error
    :
      run partcopy_pr-docw in this-procedure
        (input  p-out-code /* p-out-code         */
        ,buffer ub.parts   /* buf_orig_parts     */
        ,buffer buf_parts  /* buf_parts          */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании партии" skip
          "Объект" ub.parts.obj-type ub.parts.obj-code skip
          "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
          "Партия" ub.parts.in-code ub.parts.part-code skip
          "Резерв" p-out-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable v-parts-qnty     like ub.parts.qnty no-undo .
      define variable v-parts-cli-qnty like ub.parts.cli-qnty no-undo .

      if ub.parts.out-code = {&free-code} then do:
        assign
          v-parts-qnty     = ub.parts.qnty
          v-parts-cli-qnty = ub.parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty     = abs(ub.parts.qnty)
          v-parts-cli-qnty = abs(ub.parts.cli-qnty)
        .
      end.

      assign
        buf_parts.qnty      = buf_parts.qnty     + v-parts-qnty
        buf_parts.fact-qnty = buf_parts.qnty
        buf_parts.cli-qnty  = buf_parts.cli-qnty + v-parts-cli-qnty
      .

      assign
        p-total-parts-qnty  = p-total-parts-qnty + v-parts-qnty
      .
    end.
  end.

end procedure. /* copy-parts */


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
    process events .
  end.
end procedure. /* show-action */



procedure partcopy_pr-docw :

  /* привязывание архивных партий к переоценке */
  /* см. partcopy.i                            */


  define input parameter  p-out-code         like ub.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf_parts          for ub.parts .

  do transaction
  on error undo, return error
  :
    /* ищем партию и создаем партию, если ее нет */
    find first buf_parts exclusive-lock
      where buf_parts.obj-type  = buf_orig_parts.obj-type
        and buf_parts.obj-code  = buf_orig_parts.obj-code
        and buf_parts.artic     = buf_orig_parts.artic
        and buf_parts.prod-type = buf_orig_parts.prod-type
        and buf_parts.prod-code = buf_orig_parts.prod-code
        and buf_parts.in-code   = buf_orig_parts.in-code
        and buf_parts.out-code  = p-out-code
        and buf_parts.part-code = buf_orig_parts.part-code
      no-error.
    if not available buf_parts then do:
      create buf_parts .
      buffer-copy buf_orig_parts to buf_parts
      assign
        buf_parts.out-code  = p-out-code

        buf_parts.status_   = yes
        buf_parts.rsrv-free = ?
        buf_parts.doc-type  = {&act-overvalue}
        buf_parts.PS        = 'архив переоценки ' + p-out-code

        buf_parts.qnty      = 0
        buf_parts.fact-qnty = 0
        buf_parts.real-qnty = 0
        buf_parts.cli-qnty  = 0
      .

      /* сделаем партию доступной для поиска через первичный индекс */
      /* todo - возможно это не нужно, так как блок выделен в отдельную процедуру */
      validate buf_parts .
    end.
    else do:
      if buf_parts.status_   <> yes
      or buf_parts.rsrv-free <> ?
      or buf_parts.doc-type  <> {&act-overvalue}
      or buf_parts.PS        <> 'архив переоценки ' + p-out-code then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске архивной партии, привязанной к переоценке" skip
          "Переоценка" p-out-code skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "status_" buf_parts.status_ skip
          "rsrv-free" buf_parts.rsrv-free skip
          "doc-type" buf_parts.doc-type skip
          "PS" buf_parts.PS skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* partcopy */