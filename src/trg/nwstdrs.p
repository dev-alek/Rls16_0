block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирование и снятие резервов по документу

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

p-rsrv-direction   false - производится снятие разервов
                   true  - производится резервирование по партиям и признакам

*/
using ibs.th.str.alcohol.*.

define input  parameter p-doc-code       like ub.trn-doc.doc-code no-undo .
define input  parameter p-rsrv-direction as logical   no-undo .

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Резервирование и снятие резервов по документу".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-rsrv-direction)" }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ trg/trndocrs.i }
{ trg/partrqst.i }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ trg/partrsrv.i }

do
on error undo, return error return-value
:

  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_goods    for ub.goods .
  define buffer buf_parts    for ub.parts .
  define buffer buf_gds-dtl  for ub.gds-dtl .
  define buffer buf_doc-pl   for ub.doc-pl .
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_prt-obj  for ub.prt-obj .

  define variable v-place-rsrv        as logical   no-undo .
  define variable v-need-rsrv         as logical   no-undo .
  define variable v-root-node         as integer   no-undo .
  define variable v-goods-serial      as logical   no-undo .
  define variable v-goods-twounit     as logical   no-undo .
  define variable v-parts-rsrv-qnty   as decimal   no-undo .
  define variable v-total-rsrv-qnty   as decimal   no-undo .
  define variable v-gds-dtl-rsrv-qnty as decimal   no-undo .
  define variable v-real-chg-qnty     as decimal   no-undo .
  define variable v-parts-recid       as integer   no-undo .
  define variable v-is-hold           as integer   no-undo .

  find first buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if buf_trn-doc.status_ = {&inquiry}
  or buf_trn-doc.status_ = {&ready}
  or buf_trn-doc.status_ = {&rejected}
    then do:
    /* для запросов не нужно производить резервирование */
    return .
  end.

  { gbl/hold-doc.i
    buf_trn-doc.doc-code
    v-is-hold
  }

  for each buf_doc-line exclusive-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
    no-error  .
    
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при посике товара" skip
        "Документ" buf_doc-line.doc-code skip
        "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    
    { gbl/rootnode.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Документ" buf_doc-line.doc-code skip
        "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    /* создаются записи:
          товар на объекте
          корневой признак на объекте
    */
    { gbl/gdscr.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
      buf_gds-obj
      buf_prt-obj
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании информации о товаре на объекте" skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdscheck.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
      "''"
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "ДО резервирования" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Проверка целостности товара до резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box .
      undo, return error .
    end.

    run trndocrs-need-rsrv in this-procedure
      (input  buf_trn-doc.doc-type   /* p-doc-type     */
      ,input  buf_doc-line.artic     /* p-artic        */
      ,input  buf_doc-line.prod-type /* p-prod-type    */
      ,input  buf_doc-line.prod-code /* p-prod-code    */
      ,output v-need-rsrv            /* p-need-rsrv    */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении необходимости резервирования товара" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsat.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      'serial=request':u
      v-goods-serial
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Товар серийный" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsat.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      'twounit=request':u
      v-goods-twounit
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Двойная единица измерения" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsobjat.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      "'place-rsrv=request'"
      v-place-rsrv
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута на объекта" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run trndocrs-clear in this-procedure
      .

    define query partcopy-select-parts for buf_parts .

    open query partcopy-select-parts preselect each buf_parts
      where buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.out-code  = buf_doc-line.doc-code
      .

    get first partcopy-select-parts .


    assign
      v-total-rsrv-qnty = 0
    .

    /* производим резервирование по партиям */
    /* это необходимо делать для всех документов для всех непорожденных партий */
    do while available buf_parts
    on error undo, return error
    :
      assign
        v-parts-rsrv-qnty = buf_parts.qnty
                  * ( if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) > 0
                      then -1
                      else 1
                    )
      .

      /* обновляем статус партий, чтобы товар был целостный */
      if p-rsrv-direction = true then do:
        assign
          buf_parts.status_   = no
          buf_parts.rsrv-free = { trg/partsprm.i "part-rsrv-free" buf_trn-doc. buf_parts.qnty }
        .
      end.
      else do:
        assign
          buf_parts.status_   = yes
          buf_parts.rsrv-free = ?
        .
      end.

      if p-rsrv-direction = true
      then do:
        assign
          v-parts-rsrv-qnty = - v-parts-rsrv-qnty
        .
      end.
      assign
        v-total-rsrv-qnty = v-total-rsrv-qnty + v-parts-rsrv-qnty
      .

      /* обработка партий */
      run partcopy-rsrv-parts in this-procedure
        (input rowid(buf_trn-doc) /* p-doc-code-rowid */
        ,input rowid(buf_parts)   /* p-parts-rowid    */
        ,input p-rsrv-direction   /* p-rsrv-direction */
        ,input v-goods-twounit    /* p-goods-twounit  */
        ,input v-is-hold          /* p-is-hold        */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке партий" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Логический номер документа" buf_doc-line.fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if  v-need-rsrv = true
      and v-place-rsrv = true
      then do:
        run trndocrs-pl-gds-accum in this-procedure
          (input buf_parts.pl-code
          ,input v-parts-rsrv-qnty
          ,input 0.0
          ,input 0.0
          ,input 0.0
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-code-accum" skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Документ" buf_doc-line.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.

      get next partcopy-select-parts .
    end.

    if v-need-rsrv = true then do:
      for each buf_gds-dtl
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :

        case buf_trn-doc.doc-type :
          when {&income} or
          when {&return} then do:
            assign
              v-gds-dtl-rsrv-qnty = buf_gds-dtl.doc-qnty
            .
          end.
          when {&expense} or
          when {&write-off} then do:
            assign
              v-gds-dtl-rsrv-qnty = - buf_gds-dtl.doc-qnty
            .
          end.
          when {&inventory} then do:
            assign
              /* todo  - я не знаю, как здесь резервировать
                 todo2 - я тем более не знаю, как это привести к расширенному типу (Суслов)*/
              v-gds-dtl-rsrv-qnty = 0
            .
          end.
        end.

        if p-rsrv-direction = true
        then do:
          assign
            v-gds-dtl-rsrv-qnty = - v-gds-dtl-rsrv-qnty
          .
        end.

        run trndocrs-gds-dtl-accum in this-procedure
          (input buf_gds-dtl.prt-code
          ,input v-gds-dtl-rsrv-qnty
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Документ" buf_doc-line.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.

      if v-place-rsrv = true then do:
        for each buf_doc-pl no-lock
          where buf_doc-pl.out-code = buf_doc-line.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
            and buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
        on error undo, return error return-value
        :
          run trndocrs-pl-gds-accum in this-procedure
            (input buf_doc-pl.pl-code
            ,input 0.0
            ,input buf_doc-pl.cli-doc-qnty
                   * (if p-rsrv-direction = true then - 1.0 else 1.0)
                   * (if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) <> 0 then -1.0 else 1.0)
            ,input 0.0
            ,input 0.0
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении зарезервированных количеств trndocrs-pl-code-accum" skip
              "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
              "Документ" buf_doc-line.doc-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.

      run trndocrs in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.obj-type
        ,input buf_doc-line.obj-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ,input v-total-rsrv-qnty
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при изменении зарезервированных количеств trndocrs" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    { gbl/gdscheck.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
      "''"
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "ПОСЛЕ резервирования" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Проверка целостности товара после резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box .
      undo, return error .
    end.
  end.
end.