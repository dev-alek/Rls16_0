block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/05
Author: Bakhtadze Natalya
Creation date: 09/21/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wth-doc NEW BUFFER Buf-New OLD BUFFER Buf-Old.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на запись документов МЦ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                          ,Buf-New.doc-code
                          ,Buf-New.ext-doc-type
                          ,Buf-New.status_)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/thbjattr.i }
{ trg/wthdsum.i def }

define variable var-entry              as character no-undo .
define variable varcli-name            as character no-undo .
define variable var-mes                as character no-undo .
define variable v-old-can-edit-inv-on  as character no-undo .
define variable v-new-can-edit-inv-on  as character no-undo .
define variable l-need-check-inv       as logical   no-undo init false .
define variable num_rec                as integer   no-undo .
define variable start-time             as integer   no-undo .
define variable current-time           as character no-undo .
define variable v-today                as date      no-undo .
define variable v-time                 as integer   no-undo .
define variable current-action         as character no-undo .
define variable v-description-doc-type as character no-undo .
define variable varchk-doc-exist     as logical   no-undo .
define variable v-cmp as character no-undo .
define variable par-talk    as logical      no-undo.
define buffer buf-line    for ub.wth-line .
define buffer buf-dtl     for ub.wth-dtl .
define buffer buf_sysconf for ub.sysconf .
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_out-wth-doc for ub.wth-doc.
assign
  v-description-doc-type = buf-new.doc-type
                         + " " + string(buf-new.inter_, "внут/внеш")
.


define frame a
  buf-new.doc-code                           label "Документ" skip
  v-description-doc-type                     label "Тип документа" skip
  current-action         format "x(40)"      no-label skip
  num_rec                format ">>>>>>>9"   label "Обработано МЦ" skip
  buf-line.wth-code                          label "Текущий код МЦ" skip
  current-time           format "x(8)"       label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Обработка документа"
  .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if available buf-old
  then do:
    { gbl/wthdat.i
      buf-old.doc-type
      " (NOT buf-new.exter_) "
      buf-old.status_
      "'can-change-status-inv-on=request'"
      v-old-can-edit-inv-on
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признак документа МЦ (buf-old)" skip
        "Документ" buf-new.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  else do:
    /* если документ не существовал, то считается что мы могли его редактировать */
    assign
      v-old-can-edit-inv-on = "true":u
    .
  end.

  { gbl/wthdat.i
    buf-new.doc-type
    " (NOT buf-new.exter_) "
    buf-new.status_
    "'can-change-status-inv-on=request'"
    v-new-can-edit-inv-on
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно запросить признак документа МЦ (wth-doc)" skip
      "Документ" buf-new.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  if not g#news
  then do:
    if v-new-can-edit-inv-on <> "true":u
    or v-old-can-edit-inv-on <> "true":u
    or buf-new.status_ = {&fact}
    or (buf-new.doc-type    = {&inventory}
        and buf-new.status_ = {&permitted}
        )
    then do:
      assign
        l-need-check-inv = true
      .
    end.

    /* мы переключаемся из статуса разр + */
    /* МЦ помечен, как находящийся в инвентаризации */
    /* поэтому мы отключаем проверку инвентаризации */
    if not new buf-new
    and buf-old.doc-type = {&inventory}
    and buf-old.status_  = {&permitted}
    then do:
      assign
        l-need-check-inv = false
      .
    end.
  end.

  if buf-new.auto-fill
  then do:
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = buf-new.host-code
      no-error .
    if not available buf_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестная фирма для документа МЦ (wth-doc)" skip
        "Документ" buf-new.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  buf-new.cli-type = buf_sysconf.sale-type
    and buf-new.cli-code = buf_sysconf.sale-code
    then do:
      assign
        varchk-doc-exist = no
      .
    end.
    else do:
      assign
        varchk-doc-exist = yes
      .
    end.
  end.
  if buf-new.borned
  then do:
    assign
      varchk-doc-exist = no
    .
  end.

  /* обновляем пользователя, дату и время последнего обновления */
  if not g#news  or buf-new.user-db-num = ?
  then do:
    { gbl/curdburt.i
      buf-new.user-db-num
      buf-new.user-name
      buf-new.sys-date
      buf-new.sys-time
      buf-new.sys-time-int
    }

    if g#news then buf-new.user-name  =  {&nts-user}.
  end.
  if  buf-new.creid = '' and g#news then buf-new.creid = {&nts-user}.
  else if  buf-new.creid = '' then
  buf-new.creid = g#userid .
 if (not g#news and buf-new.status_ = {&fact}) or (g#news and  g#db-num = 0)
  then do:
   /* блокируем МЦ на объекте */
      run trg/lock-wth.p
        (input buf-new.doc-code               /* v-wth-doc-doc-code     */
        ,input l-need-check-inv               /* p-check-inv            */
        ,input buf-new.fact-order             /* p-document-fact-order  */
        ,input (buf-new.status_ = {&fact})    /* p-fact-close           */
        ,input g#news                         /* p-is-news              */
        ) no-error .
      if error-status :error
      then do:
        message
          "Не удалось наложить блокировку на все товары принадлежащие документу" skip
          "Документ" buf-new.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box information .
        undo main-block, return error .
      end.
  end.


  if g#news   and buf-new.status_ = {&fact}
  then do:
       /* Если документ принят по новостям, то установим остатки на объекте-субобъекте,
       сам документ не пересчитываем*/
    run str/stkotwth.p
      (input recid( buf-new )
      ,input no
      ,input yes
      ,input 0) no-error .
    if error-status :error
    then do:
      MESSAGE
      vss-workfile vss-revision SKIP vss-description   SKIP
      "Ошибка при установке остатков МЦ на объекте!"   SKIP
      ERROR-STATUS:GET-MESSAGE( 1 ) SKIP RETURN-VALUE SKIP
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
    if buf-new.is-back-date then do:
          /* пересчет остатков по МЦ */
          run cur-time in this-procedure ( output v-today, output v-time).
          FOR EACH buf-line NO-LOCK WHERE
          buf-line.doc-code = buf-new.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
            run str/reclcwtl.p
              (input buf-new.obj-type
              ,input buf-new.obj-code
              ,input buf-new.fact-ord - 0.0000000001
              ,input buf-line.wth-code
              ,input no
              ,input {&c-wth-obj_close}
              ,input buf-new.doc-code
              ,input buf-new.fact-date
              ,input g#db-num
              ,input g#userid
              ,input v-today
              ,input v-time
              ,input string(v-time, "HH:MM:SS")
              ) no-error .
            if error-status :error then do:
              MESSAGE substitute("&1 &2 &3&4" +
                                    "Ошибка при пересчете остатков при закрытии док-та МЦ &5 задним числом&4"  +
                                    "&6&4&7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,error-status :get-message(1)
                                    , return-value )  VIEW-AS ALERT-BOX ERROR.

              UNDO Main-Block, RETURN ERROR var-mes.
            end.
          end.
    end.

  END.
  ELSE if not g#news and buf-new.status_ = {&fact}
  then DO:

    run cur-time in this-procedure ( output v-today
                                  , output start-time
                                  ).
    assign
      current-action = "Обработка шапки документа."
    .
    run show-action in this-procedure
      (input "Обработка шапки документа."
      ).
          /* проверяем факт дату, время */
      run gbl/chk-date.p
        (input buf-new.obj-type
        ,input buf-new.obj-code
        ,input buf-new.fact-date
        ,input buf-new.fact-time
        ,input buf-new.shift-date
        ,input buf-new.shift-num
        ,input yes
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при установке дат, времен, смен в документе (wth-doc)." skip
          "Документ МЦ" buf-new.doc-code skip
          "fact-date"  buf-new.fact-date  skip
          "fact-time"  buf-new.fact-time  skip
          "shift-date" buf-new.shift-date skip
          "shift-num"  buf-new.shift-num  skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error.
      end.
      /*проверка реляционных связей*/
      CASE buf-new.doc-type:
        when {&inventory}
        then do:
          run trg/wth-inv2.p (
                input no, /*input p-silent*/
                input buf-new.doc-code,
                input buf-new.host-code,
                input buf-new.obj-type,
                input buf-new.obj-code,
                input buf-new.operator,
                input buf-new.deliver,
                input buf-new.receiver,
                input buf-new.inv-prs4,
                input buf-new.inv-prs5,
                input buf-new.auto-fill,
                input yes, /*parline-exist*/
                input yes, /*parstaff-exist*/
                output varcli-name ) no-error.
        end.
        otherwise do:
          run trg/wth-inc2.p (
                input no, /*input p-silent*/
                input buf-new.doc-code,
                input buf-new.host-code,
                input buf-new.obj-type,
                input buf-new.obj-code,
                input buf-new.cli-type,
                input buf-new.cli-code,
                input buf-new.operator,
                input buf-new.deliver,
                input buf-new.receiver,
                input buf-new.doc-type,
                input buf-new.auto-fill,
                input buf-new.exter_,
                input buf-new.inter_,
                input buf-new.source-ref,
                input buf-new.source-type,
                input buf-new.borned,
                input yes,
                input buf-new.ext-doc-type  ,
                output varcli-name) no-error.
        end.
      END CASE.
      if error-status:error
      then do:
         var-entry = return-value.
         UNDO Main-Block, RETURN ERROR var-entry.
      end.

    if  buf-new.doc-type <> {&exchange}
    then do:
      { trg/wthdsum.i check buf-new.doc-code buf-new buf-line buf-dtl varchk-doc-exist " undo main-block, " buf_wth-parts }
    end.

/*    RUN Fill-Ext-Type in this-procedure NO-ERROR .*/
/*    IF ERROR-STATUS:ERROR*/
/*    THEN DO:*/
/*      MESSAGE*/
/*      vss-workfile vss-revision SKIP vss-description SKIP*/
/*      "Не могу присвоить расширенный тип документу МЦ:"*/
/*      Buf-New.doc-code Buf-New.doc-type "!"*/
/*      VIEW-AS ALERT-BOX ERROR.*/
/*      UNDO Main-Block, RETURN ERROR.*/
/*    END.*/

    assign
      current-action = "Обработка строк МЦ."
    .

    view frame a.


    for each buf-line exclusive-lock
      where buf-line.doc-code = buf-new.doc-code
    on error undo main-block, return error
    on end-key undo main-block, return error
    :
      if buf-old.status_ <> buf-new.status_
      then do:
        run process-line in this-procedure no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при обработке строк МЦ" skip
            "Документ" buf-new.doc-code skip
            "Код МЦ" buf-line.wth-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo main-block, return error .
        end.
      end.
    end.  /* for each buf-line */

    assign current-action = "Обработка партий МЦ."    .

    view frame a.

    if buf-old.status_ <> buf-new.status_
    then for each buf_wth-parts exclusive-lock
      where buf_wth-parts.out-code = buf-new.doc-code
    on error undo main-block, return error 'Oшибка обработки партий МЦ'
    on end-key undo main-block, return error 'Oшибка обработки партий МЦ'
    :
      assign buf_wth-parts.fact-date = buf-new.fact-date
             buf_wth-parts.fact-order = buf-new.fact-order
             buf_wth-parts.fact-num = buf-new.fact-num.

      validate buf_wth-parts no-error.
    end.  /* for each buf-line */

  END. /* IF NOT g#news */
     /*Создание связанных документов*/
    if  g#news
    and  g#db-num = 0
    and buf-new.status_ = {&fact}
    and buf-old.status_ <> buf-new.status_
    and ((buf-new.obj-type = buf-new.cli-type and      /*Если внутриобъектный документ*/
        buf-new.obj-code = buf-new.cli-code and
        buf-new.inter_ = yes) or
       lookup(buf-new.ext-doc-type,{&WDEDT_OutDoc}) > 0 )
    then do:
  /*        run show-action in this-procedure
        (input "Создание внутреннего перемещения"
        ).    */

      run str/wth-out.p (buffer buf-new, buffer buf_out-wth-doc) no-error.
      if error-status:error then do:
                message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании связанного документа" skip
            "Документ" buf-new.doc-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        UNDO Main-Block, RETURN ERROR var-mes.
      end.
    end.
    def    variable v-dstnws                as logical init YES no-undo.
    define variable v-value-character       as character no-undo .
    define variable v-value-date            as date      no-undo .
    define variable v-value-decimal         as decimal   no-undo .
    define variable v-value-integer         as integer   no-undo .
    define variable v-value-logical         as logical   no-undo .
    define variable v-param-type            as character no-undo .
 /* Проверяем надо ли передавать по СПН уничтожения и перемещение зоны погашения. Хождение отключается в случае, когда эта избыточная информация на УБД не нужна
 Маршрутизация незакрытого внутренного перемещения осуществляется в call-news */
    if lookup(buf-new.ext-doc-type,{&WDEDT_NwsDoc}) > 0 and g#db-num = 0 and buf-new.status_ = {&fact} then do:
            run adm/shattri.p ( input "get":U
                          , input ""
                          , input 0
                          , input {&attr-wthrep}
                          , input  ""
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , INPUT-OUTPUT TABLE thbjattr_thbj-attr
                          ) no-error .

        for first thbjattr_thbj-attr
              where thbjattr_thbj-attr.obj-code  = 0
                and thbjattr_thbj-attr.obj-type  = ""
                and thbjattr_thbj-attr.prop-code = {&attr-wthrep_docdstnws}
                and thbjattr_thbj-attr.upper-prop-code = {&attr-wthrep}
              no-lock:
            assign
            v-dstnws = not thbjattr_thbj-attr.property-value-logical.
        end.
    end.

    /* передача документа материальных ценностей через СПН (Система Передачи Новостей) */
    if  (buf-new.status_ = {&fact}      /*изменение статуса*/
    or   buf-new.exter_ = no )
    and  (lookup(buf-new.ext-doc-type,{&WDEDT_NwsDoc}) = 0 or ( lookup(buf-new.ext-doc-type,{&WDEDT_NwsDoc}) > 0 and v-dstnws))

    then do:

      run show-action in this-procedure
        (input "Отправка документа в новости"
        ).
      run str/callnews.p
        ( INPUT "wth-doc"
         ,INPUT (buffer Buf-New:handle)
        ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description                    SKIP
        "Невозможно маршрутизировать wth-doc для отправки в новости" SKIP
        ERROR-STATUS:GET-MESSAGE( 1 ) SKIP RETURN-VALUE             SKIP
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
    END.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_wth-doc}
        , input ( buffer ub.wth-doc:handle )
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
END. /* Main-Block */

/* **********************  Internal Procedures  *********************** */
 procedure process-line :

  do
  on error undo, return error
  :
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
        num_rec buf-line.wth-code current-time current-action
        with frame a.
      process events .
    end.
    assign
    buf-line.ext-doc-type = buf-new.ext-doc-type
    buf-line.status_  = buf-new.status_
    buf-line.fact-order = buf-new.fact-order
    buf-line.fact-date  = buf-new.fact-date
    .
  end.

end procedure. /* process-line */


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