block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: factofil.p $
$Archive: utl/factofil.p $

Заполнение поля fact-order для всех документов, закрытых до статуса факт

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Обрабатываются складские документы, переоценки, сверки

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: factofil.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/factofil.p $":U .
define variable vss-description as character no-undo init "Заполнение поля fact-order".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/userobjs.i }

/* todo - разобраться со скоростью записи в базу данных при включенных триггерах */
on write of trn-doc   override do: end.
on write of price-doc override do: end.
on write of rvs-doc   override do: end.
on write of icnt-doc  override do: end.
on write of wth-doc   override do: end.

define stream slog .

define variable v-fix-count   as integer no-undo .
define variable v-error-count as integer   no-undo .

define variable v-num as integer no-undo .

{ gbl/getcntxt.i get }
if p-install then do:
  assign
    v-num = 1
  .
end.
else do:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Простановка фактического номера для всех документов системы." + {&new-line}
    ,input "|^"
    ,input "Все объекты^confirm|Все сменные объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + "|"
        + ""
    ,input 1
    ,input 4
    ,output v-num
    ).
end.

if p-install = false then do:
  run waitfram-show in this-procedure (input "Простановка фактического номера"
    ).
end.

case v-num :
  when 1 then do:
    for each ub.db no-lock
    ,each ub.clients no-lock
      where ub.clients.db-num = ub.db.db-num
    on error undo, return error
    :
      run process-object in this-procedure
        (input ub.clients.obj-type
        ,input ub.clients.obj-code
        ).
    end.
  end.
  when 2 then do:
    for each ub.db no-lock
    ,each ub.clients no-lock
      where ub.clients.db-num = ub.db.db-num
    on error undo, return error
    :
      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        ub.clients.obj-type
        ub.clients.obj-code
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
      if l-shift-on = true then do:
        run process-object in this-procedure
          (input ub.clients.obj-type
          ,input ub.clients.obj-code
          ).
      end.
    end.
  end.
  when 3 then do:

    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return .
    end.

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run process-object in this-procedure
        (input buf_userobjs_temp-user-obj.obj-type
        ,input buf_userobjs_temp-user-obj.obj-code
        ).
    end.
  end.
  when 4 then do:
    /* отмена */
    return .
  end.
end case .

if p-install = false then do:
  run waitfram-hide in this-procedure .
end.

if p-install = false then do:
  message
    "Закончена утилита инициализации поля fact-order" skip
    "Исправлено документов" v-fix-count skip
    view-as alert-box information .
end.

if v-error-count > 0 then do:
  return
    "При заполнении поля было обнаружено " + string(v-error-count) + {&new-line}
    + "Информация об ошибочных документах находится в файле factofil.err. " + {&new-line}
    .
end.

return .


procedure process-object :

  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .

  do
  on error undo, return error
  :

    define variable l-shift-on as logical no-undo .
    { gbl/objat.i
      p-obj-type
      p-obj-code
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

/* process-trn-doc */
/*ADD FIELD "fact-order" OF "trn-doc" AS decimal*/
/*ADD FIELD "fact-order" OF "doc-line" AS decimal*/

/* process-price-doc */
/*ADD FIELD "fact-order" OF "price-doc" AS decimal*/
/*ADD FIELD "fact-order" OF "price-list" AS decimal*/

/* process-ot-archive */
/*ADD FIELD "fact-order" OF "ot-tot" AS decimal*/
/*ADD FIELD "fact-order" OF "ot-line" AS decimal*/
/*ADD FIELD "fact-order" OF "ot-supp-tot" AS decimal*/
/*ADD FIELD "fact-order" OF "ot-supp-line" AS decimal*/

/* process-wth-doc */
/*ADD FIELD "fact-order" OF "wth-doc" AS decimal*/
/*ADD FIELD "fact-order" OF "wth-line" AS decimal*/

/* process-rvs-doc */
/*ADD FIELD "fact-order" OF "rvs-doc" AS decimal*/

/* process-icnt-doc */
/*ADD FIELD "fact-order" OF "icnt-doc" AS decimal*/

/* process-stk-archive */
/*ADD FIELD "fact-order" OF "stk-tot" AS decimal*/
/*ADD FIELD "fact-order" OF "stk-line" AS decimal*/
/*ADD FIELD "fact-order" OF "stk-supp-tot" AS decimal*/
/*ADD FIELD "fact-order" OF "stk-supp-line" AS decimal*/

/* process-shift-obj */
/*ADD FIELD "fact-order" OF "shift-obj" AS decimal*/

/* в этих таблицах храниться fact-order конца дня - ничего не надо трогать */
/*ADD FIELD "fact-order" OF "obj-date" AS decimal*/
/*ADD FIELD "fact-order" OF "tax-rate-gds" AS decimal*/
/*ADD FIELD "fact-order" OF "tax-rate-value" AS decimal*/

    run process-trn-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .

    run process-price-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .

    run process-wth-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .

    run process-rvs-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .

    run process-icnt-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .

    run process-stk-archive in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .

    run process-shift-obj in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input l-shift-on /* p-shift-on */
      ) .
  end.
end.

procedure process-trn-doc :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error
  :

    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка складских документов. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    for each buf_trn-doc exclusive-lock
      where buf_trn-doc.obj-type = p-obj-type
        and buf_trn-doc.obj-code = p-obj-code
        and buf_trn-doc.status_  = {&fact}
    on error undo, return error
    :

      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_trn-doc.fact-date  /* p-fact-date            */
        ,input  buf_trn-doc.fact-time  /* p-fact-time            */
        ,input  buf_trn-doc.fact-num   /* p-fact-num             */
        ,input  buf_trn-doc.shift-date /* p-shift-date           */
        ,input  buf_trn-doc.shift-num  /* p-shift-num            */
        ,input  p-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-trn-doc"
          buf_trn-doc.obj-type buf_trn-doc.obj-code
          buf_trn-doc.doc-code buf_trn-doc.fact-date buf_trn-doc.fact-time
          buf_trn-doc.fact-num buf_trn-doc.shift-date buf_trn-doc.shift-num
          buf_trn-doc.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_trn-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-trn-doc"
            buf_trn-doc.doc-code buf_trn-doc.fact-date buf_trn-doc.fact-time
            buf_trn-doc.fact-num buf_trn-doc.shift-date buf_trn-doc.shift-num
            buf_trn-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_trn-doc.fact-order = v-fact-order
          .
        end.
      end.

      define buffer buf_doc-line for ub.doc-line .
      for each buf_doc-line exclusive-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_doc-line.fact-order <> buf_trn-doc.fact-order
      on error undo, return error
      :
        assign
          buf_doc-line.fact-order = buf_trn-doc.fact-order
        .
      end.

      run process-ot-archive in this-procedure
        (input buf_trn-doc.doc-code
        ,input buf_trn-doc.fact-order
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивов по документу" skip
          "Документ" buf_trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* process-trn-doc */


procedure process-price-doc :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .

  define buffer buf_price-doc for ub.price-doc .
  define buffer update_price-doc for ub.price-doc .

  do
  on error undo, return error
  :

    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка переоценок. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    for each buf_price-doc exclusive-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
        and buf_price-doc.status_  = {&act-overvalue}
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_price-doc.fact-date   /* p-fact-date            */
        ,input  buf_price-doc.fact-time   /* p-fact-time            */
        ,input  buf_price-doc.fact-num    /* p-fact-num             */
        ,input  buf_price-doc.shift-date  /* p-shift-date           */
        ,input  buf_price-doc.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-price-doc"
          buf_price-doc.obj-type buf_price-doc.obj-code
          buf_price-doc.doc-num buf_price-doc.fact-date buf_price-doc.fact-time
          buf_price-doc.fact-num buf_price-doc.shift-date buf_price-doc.shift-num
          buf_price-doc.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_price-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-price-doc"
            buf_price-doc.doc-num buf_price-doc.fact-date buf_price-doc.fact-time
            buf_price-doc.fact-num buf_price-doc.shift-date buf_price-doc.shift-num
            buf_price-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_price-doc.fact-order = v-fact-order
          .
        end.
      end.

      define buffer buf_price-list for ub.price-list .
      for each buf_price-list exclusive-lock
        where buf_price-list.doc-num = buf_price-doc.doc-num
          and buf_price-list.fact-order <> buf_price-doc.fact-order
      on error undo, return error return-value
      :
        assign
          buf_price-list.fact-order = buf_price-doc.fact-order
        .
      end.

      run process-ot-archive in this-procedure
        (input buf_price-doc.doc-num
        ,input buf_price-doc.fact-order
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивов по документу" skip
          "Документ" buf_price-doc.doc-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* wth-lineprice-doc */


procedure process-ot-archive :

  do
  on error undo, return error
  :
    define input  parameter p-doc-code   as character no-undo .
    define input  parameter p-fact-order as decimal   no-undo .


    define buffer buf_ot-tot for ub.ot-tot .
    define buffer buf_ot-line for ub.ot-line .
    define buffer buf_ot-supp-tot for ub.ot-supp-tot .
    define buffer buf_ot-supp-line for ub.ot-supp-line .


    for each buf_ot-tot exclusive-lock
      where buf_ot-tot.doc-code = p-doc-code
        and buf_ot-tot.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-tot.fact-order = p-fact-order
      .
    end.

    for each buf_ot-line exclusive-lock
      where buf_ot-line.doc-code = p-doc-code
        and buf_ot-line.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-line.fact-order = p-fact-order
      .
    end.


    for each buf_ot-supp-tot exclusive-lock
      where buf_ot-supp-tot.doc-code = p-doc-code
        and buf_ot-supp-tot.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-supp-tot.fact-order = p-fact-order
      .
    end.

    for each buf_ot-supp-line exclusive-lock
      where buf_ot-supp-line.doc-code = p-doc-code
        and buf_ot-supp-line.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-supp-line.fact-order = p-fact-order
      .
    end.

  end.

end procedure. /* process-ot-archive */


procedure process-wth-doc :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .

  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка документов мат.ценностей. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    define buffer buf_wth-doc for ub.wth-doc .

    for each buf_wth-doc exclusive-lock
      where buf_wth-doc.obj-type = p-obj-type
        and buf_wth-doc.obj-code = p-obj-code
        and buf_wth-doc.status_  = {&fact}
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_wth-doc.fact-date   /* p-fact-date            */
        ,input  buf_wth-doc.fact-time   /* p-fact-time            */
        ,input  buf_wth-doc.fact-num    /* p-fact-num             */
        ,input  buf_wth-doc.shift-date  /* p-shift-date           */
        ,input  buf_wth-doc.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-wth-doc"
          buf_wth-doc.obj-type buf_wth-doc.obj-code
          buf_wth-doc.doc-code buf_wth-doc.fact-date buf_wth-doc.fact-time
          buf_wth-doc.fact-num buf_wth-doc.shift-date buf_wth-doc.shift-num
          buf_wth-doc.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_wth-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-wth-doc"
            buf_wth-doc.doc-code buf_wth-doc.fact-date buf_wth-doc.fact-time
            buf_wth-doc.fact-num buf_wth-doc.shift-date buf_wth-doc.shift-num
            buf_wth-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_wth-doc.fact-order = v-fact-order
          .
        end.
      end.

      define buffer buf_wth-line for ub.wth-line .
      for each buf_wth-line exclusive-lock
        where buf_wth-line.doc-code = buf_wth-doc.doc-code
          and buf_wth-line.fact-order <> buf_wth-doc.fact-order
      on error undo, return error return-value
      :
        assign
          buf_wth-line.fact-order = buf_wth-doc.fact-order
        .
      end.
    end.
  end.

end procedure. /* process-wth-doc */


procedure process-rvs-doc :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .

  do
  on error undo, return error
  :

    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка документов сверки. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    define buffer buf_rvs-doc for ub.rvs-doc .

    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.obj-type = p-obj-type
        and buf_rvs-doc.obj-code = p-obj-code
        and buf_rvs-doc.status_  = {&fact}
    on error undo, return error
    :
      define variable v-fact-num as integer   no-undo .

      assign
        v-fact-num = (buf_rvs-doc.fact-order * 100
                      - truncate(buf_rvs-doc.fact-order * 100, 0) )
                      * 100000000
      .

      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_rvs-doc.fact-date   /* p-fact-date            */
        ,input  buf_rvs-doc.fact-time   /* p-fact-time            */
        ,input  v-fact-num              /* p-fact-num             */
        ,input  buf_rvs-doc.shift-date  /* p-shift-date           */
        ,input  buf_rvs-doc.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-rvs-doc"
          buf_rvs-doc.obj-type buf_rvs-doc.obj-code
          buf_rvs-doc.rvs-code buf_rvs-doc.fact-date buf_rvs-doc.fact-time
          v-fact-num buf_rvs-doc.shift-date buf_rvs-doc.shift-num
          buf_rvs-doc.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_rvs-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-rvs-doc"
            buf_rvs-doc.rvs-code buf_rvs-doc.fact-date buf_rvs-doc.fact-time
            v-fact-num buf_rvs-doc.shift-date buf_rvs-doc.shift-num
            buf_rvs-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_rvs-doc.fact-order = v-fact-order
          .
        end.
      end.
    end.
  end.

end procedure. /* process-rvs-doc */


procedure process-icnt-doc :

  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .
  define input parameter p-shift-on as logical no-undo .

  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка документов счетчиков ТРК. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    define buffer buf_icnt-doc for ub.icnt-doc .

    for each buf_icnt-doc exclusive-lock
      where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
        and buf_icnt-doc.status_  = {&fact}
    on error undo, return error
    :
      define variable v-fact-num as integer   no-undo .

      assign
        v-fact-num = (buf_icnt-doc.fact-order * 100
                      - truncate(buf_icnt-doc.fact-order * 100, 0) )
                      * 100000000
      .

      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_icnt-doc.fact-date  /* p-fact-date            */
        ,input  buf_icnt-doc.fact-time  /* p-fact-time            */
        ,input  v-fact-num              /* p-fact-num             */
        ,input  buf_icnt-doc.shift-date /* p-shift-date           */
        ,input  buf_icnt-doc.shift-num  /* p-shift-num            */
        ,input  p-shift-on              /* p-shift-on             */
        ,output v-fact-order            /* p-fact-order           */
        ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
        ,output v-day-end-fact-order    /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-icnt-doc"
          buf_icnt-doc.obj-type buf_icnt-doc.obj-code
          buf_icnt-doc.doc-code buf_icnt-doc.fact-date buf_icnt-doc.fact-time
          buf_icnt-doc.fact-num buf_icnt-doc.shift-date buf_icnt-doc.shift-num
          buf_icnt-doc.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_icnt-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-icnt-doc"
            buf_icnt-doc.doc-code buf_icnt-doc.fact-date buf_icnt-doc.fact-time
            buf_icnt-doc.fact-num buf_icnt-doc.shift-date buf_icnt-doc.shift-num
            buf_icnt-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_icnt-doc.fact-order = v-fact-order
          .
        end.
      end.
    end.

  end.

end procedure. /* process-icnt-doc */


procedure process-stk-archive :

  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .
  define input parameter p-shift-on as logical no-undo .

  do
  on error undo, return error
  :

    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка архивов по товарам. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    define buffer buf_stk-tot for ub.stk-tot .

    for each buf_stk-tot exclusive-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.shift-date <> ?
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_stk-tot.fact-date   /* p-fact-date            */
        ,input  0                       /* p-fact-time            */
        ,input  1                       /* p-fact-num             */
        ,input  buf_stk-tot.shift-date  /* p-shift-date           */
        ,input  buf_stk-tot.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-tot"
          buf_stk-tot.obj-type buf_stk-tot.obj-code
          buf_stk-tot.fact-date
          buf_stk-tot.shift-date buf_stk-tot.shift-num
          buf_stk-tot.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-tot.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-tot"
            buf_stk-tot.obj-type buf_stk-tot.obj-code buf_stk-tot.fact-date
            buf_stk-tot.shift-date buf_stk-tot.shift-num
            buf_stk-tot.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-tot.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.

    define buffer buf_stk-line for ub.stk-line .
    for each buf_stk-line exclusive-lock
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.shift-date <> ?
    on error undo, return error
    :
      run factord in this-procedure
        (input  buf_stk-line.fact-date  /* p-fact-date            */
        ,input  0                       /* p-fact-time            */
        ,input  1                       /* p-fact-num             */
        ,input  buf_stk-line.shift-date /* p-shift-date           */
        ,input  buf_stk-line.shift-num  /* p-shift-num            */
        ,input  p-shift-on              /* p-shift-on             */
        ,output v-fact-order            /* p-fact-order           */
        ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
        ,output v-day-end-fact-order    /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-line"
          buf_stk-line.obj-type buf_stk-line.obj-code buf_stk-line.fact-date
          buf_stk-line.shift-date buf_stk-line.shift-num
          buf_stk-line.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-line.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-line"
            buf_stk-line.obj-type buf_stk-line.obj-code buf_stk-line.fact-date
            buf_stk-line.shift-date buf_stk-line.shift-num
            buf_stk-line.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-line.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.

    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка архивов по поставщикам. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.

    define buffer buf_stk-supp-tot for ub.stk-supp-tot .
    for each buf_stk-supp-tot exclusive-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.shift-date <> ?
    on error undo, return error
    :
      run factord in this-procedure
        (input  buf_stk-supp-tot.fact-date   /* p-fact-date            */
        ,input  0                       /* p-fact-time            */
        ,input  1                       /* p-fact-num             */
        ,input  buf_stk-supp-tot.shift-date  /* p-shift-date           */
        ,input  buf_stk-supp-tot.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-supp-tot"
          buf_stk-supp-tot.obj-type buf_stk-supp-tot.obj-code buf_stk-supp-tot.fact-date
          buf_stk-supp-tot.shift-date buf_stk-supp-tot.shift-num
          buf_stk-supp-tot.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-supp-tot.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-supp-tot"
            buf_stk-supp-tot.obj-type buf_stk-supp-tot.obj-code buf_stk-supp-tot.fact-date
            buf_stk-supp-tot.shift-date buf_stk-supp-tot.shift-num
            buf_stk-supp-tot.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-supp-tot.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.

    define buffer buf_stk-supp-line for ub.stk-supp-line .
    for each buf_stk-supp-line exclusive-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.shift-date <> ?
    on error undo, return error
    :
      run factord in this-procedure
        (input  buf_stk-supp-line.fact-date   /* p-fact-date            */
        ,input  0                       /* p-fact-time            */
        ,input  1                       /* p-fact-num             */
        ,input  buf_stk-supp-line.shift-date  /* p-shift-date           */
        ,input  buf_stk-supp-line.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-supp-line"
          buf_stk-supp-line.obj-type buf_stk-supp-line.obj-code buf_stk-supp-line.fact-date
          buf_stk-supp-line.shift-date buf_stk-supp-line.shift-num
          buf_stk-supp-line.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-supp-line.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-supp-line"
            buf_stk-supp-line.obj-type buf_stk-supp-line.obj-code buf_stk-supp-line.fact-date
            buf_stk-supp-line.shift-date buf_stk-supp-line.shift-num
            buf_stk-supp-line.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-supp-line.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.
  end.

end procedure. /* process-stk-archive */


procedure process-shift-obj :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .

  do
  on error undo, return error
  :

    define buffer buf_shift-obj for ub.shift-obj .

    for each buf_shift-obj exclusive-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_  = {&fact}
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_shift-obj.close-date  /* p-fact-date            */
        ,input  buf_shift-obj.close-time  /* p-fact-time            */
        ,input  1                         /* p-fact-num             */
        ,input  buf_shift-obj.shift-date  /* p-shift-date           */
        ,input  buf_shift-obj.shift-num   /* p-shift-num            */
        ,input  p-shift-on                /* p-shift-on             */
        ,output v-fact-order              /* p-fact-order           */
        ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-shift-obj"
          buf_shift-obj.obj-type buf_shift-obj.obj-code
          buf_shift-obj.close-date buf_shift-obj.close-time
          buf_shift-obj.shift-date buf_shift-obj.shift-num
          buf_shift-obj.fact-order
          return-value .
        output stream slog close .

        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_shift-obj.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-shift-obj"
            buf_shift-obj.obj-type buf_shift-obj.obj-code
            buf_shift-obj.close-date buf_shift-obj.close-time
            buf_shift-obj.shift-date buf_shift-obj.shift-num
            buf_shift-obj.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_shift-obj.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.

  end.

end procedure. /* process-shift-obj */