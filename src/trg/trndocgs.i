/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновление информации о товаре при закрытии складского документа до статуса {&fact}

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Параметры:

  p-news          - true - признак того, что программа выполняется при работе новостей
  p-trn-doc-close - true - закрытие документа
                    false - удаление документа
  p-update-host   - true - признак того, что необходимо выполнять вычислени
                         связанные с расчетома по фирме


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure trndocgs :

  define input  parameter p-doc-code      like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic         like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type     like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code     like ub.doc-line.prod-code no-undo .
  define input  parameter p-root-node     like ub.prt-obj.prt-code  no-undo .
  define input  parameter p-news          as logical no-undo .
  define input  parameter p-trn-doc-close as logical   no-undo .
  define input  parameter p-update-host   as logical no-undo .

  define buffer buf_db       for ub.db .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl .
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_prt-obj  for ub.prt-obj .
  define buffer buf_goods    for ub.goods .
  define buffer buf_gds-prt  for ub.gds-prt .
  define buffer buf_pl-gds   for ub.pl-gds .
  define buffer buf_doc-pl   for ub.doc-pl .

  define variable v-obj-type      like ub.gds-obj.obj-type  no-undo .
  define variable v-obj-code      like ub.gds-obj.obj-code  no-undo .
  define variable curr-node       like ub.gds-prt.node-code no-undo .
  define variable l-need-rsrv     as logical                no-undo .
  define variable l-goods-twounit as logical                no-undo .
  define variable v-cmd           as character              no-undo .
  define variable v-curr-db-num   like ub.db.db-num         no-undo .
  define variable v-update-sign   as decimal   no-undo .
  define variable v-doc-sign      as decimal   no-undo .


  do
  on error undo, return error return-value
  :

    if p-trn-doc-close = true
    then do:
      assign
        v-update-sign = 1.0
      .
    end.
    else do:
      assign
        v-update-sign = -1.0
      .
    end.

    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Товар" p-artic p-prod-code p-prod-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_doc-line.fact-order = ?
    or buf_doc-line.fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задан логический номер строки документа" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Логический номер документа" buf_doc-line.fact-order skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .

    assign
      v-obj-type  = buf_doc-line.obj-type
      v-obj-code  = buf_doc-line.obj-code
    .

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
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
      p-root-node
      buf_gds-obj
      buf_prt-obj
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании информации о товаре на фирме" skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find current buf_gds-obj exclusive-lock .

    /* обновляем дату начала движения по товару */
    /* и конца движения по товару */
    { trg/gdsobjdt.i buf_gds-obj. buf_trn-doc. }

    if p-trn-doc-close = true
    then do:
      run trndocrs-need-rsrv in this-procedure
        (input  buf_trn-doc.doc-type   /* p-doc-type     */
        ,input  buf_doc-line.artic     /* p-artic        */
        ,input  buf_doc-line.prod-type /* p-prod-type    */
        ,input  buf_doc-line.prod-code /* p-prod-code    */
        ,output l-need-rsrv            /* p-need-rsrv    */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры trndocrs-need-rsrv" skip
          "Документ" buf_trn-doc.doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      assign
        l-need-rsrv = false
      .
    end.

    { gbl/gdsat.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      "'twounit=request':u"
      l-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* инициализируем библиотеку зарезервированных количеств */
    run trndocrs-clear in this-procedure
      .

    if buf_goods.gds-type = {&gds-goods}
    then do:
      /* работа с партиями только для товаров */
      define variable v-change-qnty        as decimal no-undo .
      define variable v-change-base-total  as decimal no-undo .
      define variable v-change-rubl-total  as decimal no-undo .
      define variable v-total-qnty         as decimal no-undo .
      define variable v-total-cli-qnty     as decimal no-undo .
      define variable v-total-base-total   as decimal no-undo .
      define variable v-total-rubl-total   as decimal no-undo .
      define variable v-return-qnty        as decimal no-undo .
      define variable v-return-base-total  as decimal no-undo .
      define variable v-return-rubl-total  as decimal no-undo .
      define variable v-expense-qnty       as decimal no-undo .
      define variable v-expense-base-total as decimal no-undo .
      define variable v-expense-rubl-total as decimal no-undo .
      define variable v-total-rsrv-qnty    as decimal no-undo .

      /* при вызове этой процедуры вычисляются временные таблицы */
      /* temp-pl-gds  */
      /* также заполняются таблица, необходимая для trndocrs */
      run tdparts in this-procedure
        (input  buf_trn-doc.host-code   /* p-trn-doc-host-code   */
        ,input  buf_trn-doc.doc-type    /* p-trn-doc-doc-type    */
        ,input  buf_trn-doc.internal    /* p-trn-doc-internal    */
        ,input  buf_trn-doc.discnt-type /* p-trn-doc-discnt-type */
        ,input  buf_trn-doc.doc-code    /* p-trn-doc-doc-code    */
        ,input  buf_doc-line.obj-type   /* p-obj-type            */
        ,input  buf_doc-line.obj-code   /* p-obj-code            */
        ,input  buf_doc-line.artic      /* p-artic               */
        ,input  buf_doc-line.prod-type  /* p-prod-type           */
        ,input  buf_doc-line.prod-code  /* p-prod-code           */
        ,input  l-need-rsrv             /* p-need-rsrv           */
        ,input  buf_gds-obj.place-rsrv  /* p-place-rsrv          */
        ,input  l-goods-twounit         /* p-goods-twounit       */
        ,output v-change-qnty           /* p-change-qnty         */
        ,output v-change-base-total     /* p-change-base-total   */
        ,output v-change-rubl-total     /* p-change-rubl-total   */
        ,output v-total-qnty            /* p-total-qnty          */
        ,output v-total-cli-qnty        /* p-total-cli-qnty      */
        ,output v-total-base-total      /* p-total-base-total    */
        ,output v-total-rubl-total      /* p-total-rubl-total    */
        ,output v-return-qnty           /* p-return-qnty         */
        ,output v-return-base-total     /* p-return-base-total   */
        ,output v-return-rubl-total     /* p-return-rubl-total   */
        ,output v-expense-qnty          /* p-expense-qnty        */
        ,output v-expense-base-total    /* p-expense-base-total  */
        ,output v-expense-rubl-total    /* p-expense-rubl-total  */
        ,output v-total-rsrv-qnty       /* p-total-rsrv-qnty     */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивных партий" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end. /* if buf_goods.gds-type = {&gds-goods}  */
    else do:
      /* если товар не имеет партий, то вычисляем оборот по строке документа */
      assign
        v-total-qnty       = (if buf_trn-doc.doc-type = {&expense}
                              or buf_trn-doc.doc-type = {&write-off}
                              then - buf_doc-line.fact-qnty
                              else   buf_doc-line.fact-qnty
                             )
        /* todo - для товара без партий резервирование не производится */
        v-total-rsrv-qnty  = 0
        v-total-base-total = buf_doc-line.price-base * v-total-qnty
        v-total-rubl-total = buf_doc-line.price-rubl * v-total-qnty
      .
      if l-goods-twounit
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Услуга не может учитываться по двум единицам измерения" skip
          "Документ" buf_trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    define variable v-gds-dtl-qnty        as decimal no-undo .
    define variable v-gds-dtl-rsrv-qnty   as decimal no-undo .

    for each buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      case buf_trn-doc.doc-type :
        when {&income} or
        when {&return}
        then do:
          assign
            v-gds-dtl-qnty      = buf_gds-dtl.fact-qnty
            v-gds-dtl-rsrv-qnty = buf_gds-dtl.doc-qnty
          .
        end.
        when {&expense} or
        when {&write-off}
        then do:
          assign
            v-gds-dtl-qnty      = - buf_gds-dtl.fact-qnty
            v-gds-dtl-rsrv-qnty = - buf_gds-dtl.doc-qnty
          .
        end.
        when {&inventory}
        then do:
          assign
            v-gds-dtl-qnty = buf_gds-dtl.doc-qnty
            /* todo - инвентаризация по признакам не резервируется */
            v-gds-dtl-rsrv-qnty = 0
          .
        end.
      end.

      if l-need-rsrv
      then do:
        run trndocrs-gds-dtl-accum in this-procedure
          (input buf_gds-dtl.prt-code
          ,input v-gds-dtl-rsrv-qnty
                * v-update-sign
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.

      /* проход вниз по дереву на первый терминальный узел */
      { gbl/termnode.i
        buf_gds-dtl.prt-code
        curr-node
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно найти терминальный признак" skip
          "prt-code" buf_gds-dtl.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* проход вверх по дереву - просто корректируем обороты и остатки по всем узлам */
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = curr-node
        .
      do while available buf_gds-prt:
        /* обработка текущего узла */

        { gbl/prtobjcr.i
          buf_gds-dtl.obj-type
          buf_gds-dtl.obj-code
          buf_gds-dtl.artic
          buf_gds-dtl.prod-type
          buf_gds-dtl.prod-code
          buf_gds-prt.node-code
          buf_prt-obj
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании признака на объекте" skip
            "obj-type"  buf_gds-dtl.obj-type skip
            "obj-code"  buf_gds-dtl.obj-code skip
            "artic"     buf_gds-dtl.artic skip
            "prod-type" buf_gds-dtl.prod-type skip
            "prod-code" buf_gds-dtl.prod-code skip
            "node-code" buf_gds-prt.node-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        find current buf_prt-obj exclusive-lock .

        if buf_goods.gds-type = {&gds-goods}
        then do:
          find first doc-fbr-gds no-lock where (doc-fbr-gds.out-code = buf_doc-line.doc-code or
                                                doc-fbr-gds.out-code = replace(buf_doc-line.doc-code, "=", "-") ) 
                                           and doc-fbr-gds.gds-code = buf_goods.gds-code
                                           no-error .
          if available doc-fbr-gds
          then do : 
            assign
              buf_prt-obj.fact-qnty = buf_prt-obj.fact-qnty + v-gds-dtl-rsrv-qnty
                                                            * v-update-sign
              buf_prt-obj.free-qnty = buf_prt-obj.free-qnty + v-gds-dtl-rsrv-qnty
                                                            * v-update-sign
            .                                                
          end.
          else do :                               
            assign
              buf_prt-obj.fact-qnty = buf_prt-obj.fact-qnty + v-gds-dtl-qnty
                                                            * v-update-sign
              buf_prt-obj.free-qnty = buf_prt-obj.free-qnty + v-gds-dtl-qnty
                                                            * v-update-sign
            .
          end.
        end.

        assign
          curr-node = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = curr-node
          no-error.
      end.
    end.

    if l-need-rsrv
    then do:
      run trndocrs in this-procedure
        (input p-doc-code
        ,input v-obj-type
        ,input v-obj-code
        ,input p-artic
        ,input p-prod-type
        ,input p-prod-code
        ,input v-total-rsrv-qnty
              * v-update-sign
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при изменении зарезервированных количеств trndocrs" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    if buf_goods.gds-type = {&gds-goods}
    then do:

      define variable v-old-fact-qnty            as decimal   no-undo .
      define variable v-old-fact-cli-qnty        as decimal   no-undo .
      define variable v-old-pl-gds-fact-qnty     as decimal   no-undo .
      define variable v-old-pl-gds-free-qnty     as decimal   no-undo .
      define variable v-old-pl-gds-cli-qnty      as decimal   no-undo .
      define variable v-old-pl-gds-cli-fact-qnty as decimal   no-undo .
      define variable v-old-pl-gds-cli-free-qnty as decimal   no-undo .
      define variable v-old-fact-base            as decimal   no-undo .
      define variable v-old-fact-rubl            as decimal   no-undo .
      define variable v-old-fact-sale            as decimal   no-undo .


      assign
        v-old-fact-qnty     = buf_gds-obj.fact-qnty
        v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
        v-old-fact-base     = buf_gds-obj.fact-base
        v-old-fact-rubl     = buf_gds-obj.fact-rubl
        v-old-fact-sale     = buf_gds-obj.fact-sale
      .

      assign
        buf_gds-obj.fact-qnty     = buf_gds-obj.fact-qnty     + v-total-qnty
                                                              * v-update-sign
        buf_gds-obj.free-qnty     = buf_gds-obj.free-qnty     + v-total-qnty
                                                              * v-update-sign
        buf_gds-obj.fact-base     = buf_gds-obj.fact-base     + v-total-base-total
                                                              * v-update-sign
        buf_gds-obj.fact-rubl     = buf_gds-obj.fact-rubl     + v-total-rubl-total
                                                              * v-update-sign
        buf_gds-obj.on-line-rest  = buf_gds-obj.free-qnty
        /*Дима и Света разрешили*/
      .
      { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
        " {&goods-proc_rest-update} "
        ?
        " buffer buf_gds-obj:handle "
        'fact-qnty,free-qnty'
        ''
        no-error
        }


      { gbl/curdbnum.i
        v-curr-db-num
      }
      find first buf_db no-lock
        where buf_db.db-num = v-curr-db-num
        .
      if buf_db.db-num <> 0
        and buf_db.on-line-rest = true
      then do:
        assign
          v-cmd = "command":U + {&delim-nws}
                  + "create":U + {&delim-nws}
                  + "on-line-rest":U + {&delim-nws}
                  + substitute( "&1", buf_gds-obj.obj-type ) + {&delim-nws}
                  + substitute( "&1", buf_gds-obj.obj-code ) + {&delim-nws}
                  + substitute( "&1", buf_gds-obj.artic ) + {&delim-nws}
                  + substitute( "&1", buf_gds-obj.prod-type ) + {&delim-nws}
                  + substitute( "&1", buf_gds-obj.prod-code ) + {&delim-nws}
                  + substitute( "&1", buf_gds-obj.free-qnty ) + {&delim-nws}
        .
        run nws/cr-route.p
          ( input {&send-cmd}
           ,input v-cmd
           ,input ?
           ,input "0":U
          ).
      end.

      if l-goods-twounit
      then do:
        assign
          buf_gds-obj.fact-cli-qnty = buf_gds-obj.fact-cli-qnty + v-total-cli-qnty
                                                                * v-update-sign
        .
      end.

      /* вычисляем сумму в учетных и продажных ценах по объекту */
      run gdsobjcl in this-procedure
        (input recid(buf_gds-obj)  /* p-gds-obj-recid    */
        ,input false               /* p-update-fact-qnty */
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете суммы остатка в учетных и продажных ценах по объекту" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
          "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box.
        undo, return error return-value .
      end.
      define variable p-action-type as character no-undo .
      if p-trn-doc-close = true
      then do:
        assign
          p-action-type = {&c-gds-obj_close}
        .
      end.
      else do:
        assign
          p-action-type = {&c-gds-obj_delete}
        .
      end.


      if buf_gds-obj.place-rsrv = true then do:

        for each buf_doc-pl no-lock
          where buf_doc-pl.obj-type = v-obj-type
            and buf_doc-pl.obj-code = v-obj-code
            and buf_doc-pl.out-code = p-doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          find first buf_pl-gds exclusive-lock
            where buf_pl-gds.obj-type = buf_doc-pl.obj-type
              and buf_pl-gds.obj-code = buf_doc-pl.obj-code
              and buf_pl-gds.gds-code = buf_doc-pl.gds-code
              and buf_pl-gds.pl-code  = buf_doc-pl.pl-code
            no-error .
          if not available buf_pl-gds  then do:
            if p-news = true then do:
              /* записи pl-gds не ходят через новости */
              /* создаем привязку товара к складскому месту */
              create buf_pl-gds .
              assign
                buf_pl-gds.obj-type = buf_doc-pl.obj-type
                buf_pl-gds.obj-code = buf_doc-pl.obj-code
                buf_pl-gds.gds-code = buf_doc-pl.gds-code
                buf_pl-gds.pl-code  = buf_doc-pl.pl-code
              .
            end.
            else do:
              message
                vss-workfile vss-revision vss-description skip
                "Не найдена привязка товара к складскому месту" skip
                "Документ" buf_doc-pl.out-code skip
                "Объект" buf_doc-pl.obj-type buf_doc-pl.obj-code skip
                "Складское место" buf_doc-pl.pl-code skip
                "Код товара" buf_doc-pl.gds-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          if buf_trn-doc.doc-type = {&expense}
            or buf_trn-doc.doc-type = {&write-off}
          then do:
            assign
              v-doc-sign = -1.0
            .
          end.
          else do:
            assign
              v-doc-sign = 1.0
            .
          end.

          assign
            v-old-pl-gds-fact-qnty     = buf_pl-gds.fact-qnty
            v-old-pl-gds-free-qnty     = buf_pl-gds.free-qnty
            v-old-pl-gds-cli-qnty      = buf_pl-gds.cli-qnty
            v-old-pl-gds-cli-fact-qnty = buf_pl-gds.cli-fact-qnty
            v-old-pl-gds-cli-free-qnty = buf_pl-gds.cli-free-qnty
            buf_pl-gds.fact-qnty       = buf_pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-update-sign * v-doc-sign
            buf_pl-gds.free-qnty       = buf_pl-gds.free-qnty     + buf_doc-pl.fact-qnty     * v-update-sign * v-doc-sign
            buf_pl-gds.cli-qnty        = buf_pl-gds.cli-qnty      + buf_doc-pl.cli-qnty      * v-update-sign * v-doc-sign
            buf_pl-gds.cli-fact-qnty   = buf_pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-update-sign * v-doc-sign
            buf_pl-gds.cli-free-qnty   = buf_pl-gds.cli-free-qnty + buf_doc-pl.cli-fact-qnty * v-update-sign * v-doc-sign
          .
          if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
            and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
          then do:
            /* корректируем т.к. из-за плотности у нас кол-во может гулять до +-0.001 */
            /* но при этом в базовой ед.изм. все должно быть точно                    */
            assign
              buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
            .
          end.
          if buf_pl-gds.fact-qnty < 0.0 then do:
              message
                vss-workfile vss-revision vss-description skip
                "Фактическое количество в резервуаре после закрытия станет меньше нуля: " buf_pl-gds.fact-qnty skip
                "Документ" p-doc-code skip
                "Объект" v-obj-type v-obj-code skip
                "Место хранения" buf_doc-pl.pl-code skip
                "Код товара" buf_goods.gds-code skip
                view-as alert-box error .
              undo, return error return-value .
          end.

          /* удаляем запись только если с удаленки придет соответствующая команда по новостям
          if  p-news
          and buf_pl-gds.fact-qnty = 0
          and buf_pl-gds.free-qnty = 0
          then do:
            delete buf_pl-gds .
          end.
          */

          { gbl/plgohist.i
            buf_pl-gds.obj-type
            buf_pl-gds.obj-code
            buf_pl-gds.pl-code
            buf_pl-gds.gds-code
            p-action-type
            buf_pl-gds.fact-qnty
            buf_pl-gds.cli-qnty
            buf_pl-gds.free-qnty
            buf_pl-gds.cli-fact-qnty
            buf_pl-gds.cli-free-qnty
            v-old-pl-gds-fact-qnty
            v-old-pl-gds-cli-qnty
            v-old-pl-gds-free-qnty
            v-old-pl-gds-cli-fact-qnty
            v-old-pl-gds-cli-free-qnty
            {&table_trn-doc}
            buf_trn-doc.doc-code
            buf_trn-doc.fact-date
            buf_trn-doc.user-db-num
            buf_trn-doc.user-name
            buf_trn-doc.sys-date
            buf_trn-doc.sys-time-int
            buf_trn-doc.sys-time
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании истории по товару на складском месте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      /* создаем историю изменения товара на объекте */
      define variable v-corr-date   as date      no-undo .
      define variable v-corr-time   as integer   no-undo .

      run cur-time in this-procedure
        (output v-corr-date
        ,output v-corr-time
        ) .

      { gbl/gohist.i
        buf_gds-obj.obj-type
        buf_gds-obj.obj-code
        buf_gds-obj.gds-code
        p-action-type
        buf_gds-obj.fact-qnty
        buf_gds-obj.fact-cli-qnty
        buf_gds-obj.fact-base
        buf_gds-obj.fact-rubl
        buf_gds-obj.fact-sale
        v-old-fact-qnty
        v-old-fact-cli-qnty
        v-old-fact-base
        v-old-fact-rubl
        v-old-fact-sale
        {&table_trn-doc}
        buf_trn-doc.doc-code
        buf_trn-doc.fact-date
        buf_trn-doc.user-db-num
        buf_trn-doc.user-name
        buf_trn-doc.sys-date
        buf_trn-doc.sys-time-int
        buf_trn-doc.sys-time
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании истории по товару на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    if buf_goods.gds-type = {&gds-goods}
    then do:
      /* обновляем информацию о последнем приходе по объекту */
      if buf_trn-doc.doc-type = {&income}
      and buf_doc-line.fact-qnty <> 0
      then do:
        if p-trn-doc-close = true
        then do:
          if buf_gds-obj.in-date = ?
          or buf_gds-obj.in-date <= buf_trn-doc.fact-date
          then do:
            assign
              buf_gds-obj.last-base = buf_doc-line.price-base
              buf_gds-obj.last-rubl = buf_doc-line.price-rubl
              buf_gds-obj.in-code   = buf_trn-doc.doc-code
              buf_gds-obj.in-date   = buf_trn-doc.fact-date
            .
          end.
        end.
        else do:
          /* обновляем информацию о последнем приходе */
          /* просматриваем все строки приходных накладных */
          /* от последнего документа к первому */
          /* исключаем из рассмотрения номер удаляемой накладной */
          define buffer income_buf_doc-line for ub.doc-line .
          define buffer income_buf_trn-doc for ub.trn-doc .
          for each income_buf_doc-line no-lock
            where income_buf_doc-line.obj-type     = buf_doc-line.obj-type
              and income_buf_doc-line.obj-code     = buf_doc-line.obj-code
              and income_buf_doc-line.artic        = buf_doc-line.artic
              and income_buf_doc-line.prod-type    = buf_doc-line.prod-type
              and income_buf_doc-line.prod-code    = buf_doc-line.prod-code
              and income_buf_doc-line.status_      = {&fact}
              and income_buf_doc-line.doc-code    <> buf_doc-line.doc-code
          ,first income_buf_trn-doc no-lock
             where income_buf_trn-doc.doc-code = income_buf_doc-line.doc-code
               and income_buf_trn-doc.doc-type = {&income}
          by income_buf_doc-line.fact-order descending
          on error undo, return error return-value
          :
            assign
              buf_gds-obj.last-base = income_buf_doc-line.price-base
              buf_gds-obj.last-rubl = income_buf_doc-line.price-rubl
              buf_gds-obj.in-code   = income_buf_trn-doc.doc-code
              buf_gds-obj.in-date   = income_buf_trn-doc.fact-date
            .
            leave . /* --->>>--- */
          end.
        end.
      end.
    end. /* if buf_goods.gds-type = {&gds-goods}  */
  end. /* do on error ... */
end procedure. /* trndocgs */

/* $Workfile$ */