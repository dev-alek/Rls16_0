/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура компенсации отрицательных партий

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

Примерная схема алгоритма:

Изменение производится в одной транзакции. В случае возникновения ошибки
производится откат всей транзакции

1.  Идем по отрицательным партиям свободной зоны
    Резервируем любое доступное количество из соответствующей партии расходной зоны
    (но не больше, чем необходимо для ликвидации отрицательной партии)

    Накапливаем зарезервированное количество

2.  Идем по отрицательным партиям расходной зоны
    Резервируем любое доступное количество из соответствующей партии свободной зоны
    (но не больше, чем необходимо для ликвидации отрицательной партии)

    Накапливаем зарезервированное количество

3.  Производим обычное до резервирование
    (резервирование без снятия уже зарезервированного количества)
    возможно с созданием порожденной партии

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure rsrvincr :
  define input  parameter parparentproc          AS WIDGET-HANDLE          NO-UNDO.
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define input  parameter p-trn-doc-recid        as recid                   no-undo .
  define input  parameter p-doc-line-recid       as recid                   no-undo .
  define input  parameter p-reserv-base          as decimal                 no-undo .
  define input  parameter p-reserv-rubl          as decimal                 no-undo .
  define input  parameter p-partscr-prompt-price as character               no-undo .
  define input  parameter p-extended-doc-type    as character               no-undo .
  define input  parameter p-reserv-single-part   as logical                 no-undo .
  define input  parameter p-in-code              like ub.parts.in-code      no-undo .
  define input  parameter p-part-code            like ub.parts.part-code    no-undo .
  define input  parameter p-reserv-pl-code       as logical                 no-undo .
  define input  parameter p-pl-code              as character               no-undo .
  define input  parameter p-goods-serial         as logical                 no-undo .
  define input  parameter p-goods-twounit        as logical                 no-undo .
  define output parameter p-abs-rsrv-qnty        as decimal                 no-undo .

  define variable vss-description as character no-undo init "rsrvincr: Процедура компенсации отрицательных партий".

  define buffer buf_trn-doc    for ub.trn-doc .

  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      p-abs-rsrv-qnty = 0
    .

    if p-reserv-pl-code = true
    then do:
      /* Нельзя вызывать пересортицу по партиям для товаров, которые */
      /* резервируются по местам хранения */
      return . /* --->>>--- */
    end.

    if p-goods-twounit = true
    then do:
      /* Нельзя вызывать пересортицу по партиям для ювелирных изделий */
      return . /* --->>>--- */
    end.

    define variable v-total-rsrv-qnty as decimal no-undo .

    assign
      v-total-rsrv-qnty = 0
    .

    define variable v-neg-beg-date as date no-undo .
    define variable v-neg-end-date as date no-undo .

    assign
      v-neg-beg-date = ?
      v-neg-end-date = ?
    .

    define variable v-parameter-beg-name as character no-undo .
    define variable v-parameter-end-name as character no-undo .

    { gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code  {&attr-rezerv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invngbeg'  then v-neg-beg-date = thbjattr_thbj-attr.property-value-date.
        if thbjattr_thbj-attr.prop-code = 'invngend'  then v-neg-end-date = thbjattr_thbj-attr.property-value-date.
    end.
    empty temp-table thbjattr_thbj-attr.
    assign
      v-parameter-beg-name = "invngbeg"
      v-parameter-end-name = "invngend"
    .

    if (v-neg-beg-date = ? ) <> (v-neg-end-date = ?)
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Противоречивое задание параметров ограничения по резервированию порожденных партий" skip
        "Параметры" v-parameter-beg-name v-parameter-end-name skip
        "должны быть или одновременно заданы" skip
        "или одновременно не заданы" skip
        view-as alert-box error .
      undo, return error .
    end.

    if  v-neg-beg-date <> ?
    and v-neg-end-date <> ?
    and v-neg-beg-date > v-neg-end-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Противоречивое задание параметров ограничения по резервированию порожденных партий" skip
        "Первый день интервала резервирования(" v-parameter-beg-name ")" v-neg-beg-date skip
        "Последний день интервала резервирования(" v-parameter-end-name ")" v-neg-end-date skip
        "Дата" v-parameter-beg-name "должна быть меьшне равна даты" v-parameter-end-name skip
        view-as alert-box error .
      undo, return error .
    end.

    run rsrv-inv-create-supp in this-procedure
      (input        p-trn-doc-recid       /* p-trn-doc-recid   */
      ,input        p-doc-line-recid      /* p-doc-line-recid  */
      ,input        p-goods-serial        /* p-goods-serial    */
      ,input        p-goods-twounit       /* p-goods-twounit   */
      ,input        {&output-code}        /* p-negative-code   */
      ,input        v-neg-beg-date        /* p-neg-beg-date    */
      ,input        v-neg-end-date        /* p-neg-end-date    */
      ,input-output v-total-rsrv-qnty     /* p-total-rsrv-qnty */
      ,input-output p-abs-rsrv-qnty       /* p-abs-rsrv-qnty   */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры резервирования отрицательных партий расходной зоны" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run rsrv-inv-create-supp in this-procedure
      (input        p-trn-doc-recid       /* p-trn-doc-recid   */
      ,input        p-doc-line-recid      /* p-doc-line-recid  */
      ,input        p-goods-serial        /* p-goods-serial    */
      ,input        p-goods-twounit       /* p-goods-twounit   */
      ,input        {&free-code}          /* p-negative-code   */
      ,input        v-neg-beg-date        /* p-neg-beg-date    */
      ,input        v-neg-end-date        /* p-neg-end-date    */
      ,input-output v-total-rsrv-qnty     /* p-total-rsrv-qnty */
      ,input-output p-abs-rsrv-qnty       /* p-abs-rsrv-qnty   */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры резервирования отрицательных партий свободной зоны" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-total-rsrv-qnty <> 0
    then do:
      define variable v-real-chg-qnty as decimal   no-undo .
      run rsrv-doc in this-procedure
        (input  parparentproc
        ,input  p-db-num
        ,input  p-user-id
        ,input  p-trn-doc-recid        /* p-trn-doc-recid        */
        ,input  p-doc-line-recid       /* p-doc-line-recid       */
        ,input  p-reserv-base          /* p-reserv-base          */
        ,input  p-reserv-rubl          /* p-reserv-rubl          */
        ,input  p-partscr-prompt-price /* p-partscr-prompt-price */
        ,input  p-extended-doc-type    /* p-extended-doc-type    */
        ,input  p-reserv-single-part   /* p-reserv-single-part   */
        ,input  p-in-code              /* p-in-code              */
        ,input  p-part-code            /* p-part-code            */
        ,input  p-reserv-pl-code       /* p-reserv-pl-code       */
        ,input  p-pl-code              /* p-pl-code              */
        ,input  p-goods-serial         /* p-goods-serial         */
        ,input  p-goods-twounit        /* p-goods-twounit        */
        ,input  '':u                   /* p-purch-code-list      */
        ,input  - v-total-rsrv-qnty    /* p-chg-qnty             */
        ,input  false                  /* p-unreserv-other-sign  */
        ,output v-real-chg-qnty        /* p-real-chg-qnty        */
        ) no-error .
      if error-status :error
      or v-real-chg-qnty <> - v-total-rsrv-qnty
      then do:
        undo, return error .
      end.
      assign
        p-abs-rsrv-qnty = p-abs-rsrv-qnty + abs(v-real-chg-qnty)
      .
    end.

    /* сообщаем пользователю только количество уничтоженных отрицательных партий */
    assign
      p-abs-rsrv-qnty = p-abs-rsrv-qnty / 2
    .
  end.

end procedure. /* rsrv-inv-create */


procedure rsrv-inv-create-supp :

  define input        parameter p-trn-doc-recid   as recid     no-undo .
  define input        parameter p-doc-line-recid  as recid     no-undo .
  define input        parameter p-goods-serial    as logical   no-undo .
  define input        parameter p-goods-twounit   as logical   no-undo .
  define input        parameter p-negative-code   as character no-undo .
  define input        parameter p-neg-beg-date    as date      no-undo .
  define input        parameter p-neg-end-date    as date      no-undo .
  define input-output parameter p-total-rsrv-qnty as decimal   no-undo .
  define input-output parameter p-abs-rsrv-qnty   as decimal   no-undo .

  define variable vss-description as character no-undo init "rsrv-inv-create-supp: компенсация партий свободной/расходной зоны".

  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer negative_parts for ub.parts .
  define buffer buf_parts      for ub.parts .

  define variable v-rsrv-qnty       as decimal   no-undo .
  define variable v-real-rsrv-qnty  as decimal   no-undo .
  define variable v-parts-recid     as decimal   no-undo .

  do
  on error undo, return error
  :

    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Указатель" p-doc-line-recid skip
        view-as alert-box error .
      undo, return error .
    end.


    for each negative_parts
      where negative_parts.obj-type  = buf_doc-line.obj-type
        and negative_parts.obj-code  = buf_doc-line.obj-code
        and negative_parts.artic     = buf_doc-line.artic
        and negative_parts.prod-type = buf_doc-line.prod-type
        and negative_parts.prod-code = buf_doc-line.prod-code
        and negative_parts.out-code  = p-negative-code
        and negative_parts.qnty      < 0
    on error undo, return error
    :
      /* если указан временной диапазон,                       */
      /* то просматриваем партии только внутри этого диапазона */
      if p-neg-beg-date <> ?
      then do:
        if negative_parts.fact-date < p-neg-beg-date
        or negative_parts.fact-date > p-neg-end-date
        then do:
          next . /* --->>>--- */
        end.
      end.

      /* ищем зарезервированную партию */
      find buf_parts exclusive-lock
        where buf_parts.obj-type  = negative_parts.obj-type
          and buf_parts.obj-code  = negative_parts.obj-code
          and buf_parts.artic     = negative_parts.artic
          and buf_parts.prod-type = negative_parts.prod-type
          and buf_parts.prod-code = negative_parts.prod-code
          and buf_parts.in-code   = negative_parts.in-code
          and buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.part-code = negative_parts.part-code
        no-error.
      define variable v-already-rsrv-qnty as decimal no-undo .
      assign
        v-already-rsrv-qnty = 0
      .
      if available buf_parts
      then do:
        assign
          v-already-rsrv-qnty = buf_parts.qnty
        .
      end.

      /* Постараемся зарезервировать не больше,
        чем нужно, чтобы скомпенсировать отрицательную партию
      */
      assign
        v-rsrv-qnty = negative_parts.qnty
                    * ( if p-negative-code = {&free-code}
                        then -1
                        else 1
                      )
                    - v-already-rsrv-qnty
      .

      define variable v-real-chg-qnty as decimal   no-undo .

      run partrsrv in this-procedure
        (input  v-rsrv-qnty     /* p-chg-qnty      */
        ,input  p-goods-serial  /* p-goods-serial  */
        ,input  p-goods-twounit /* p-goods-twounit */
        ,input  false           /* p-unreserv-only */
        ,buffer negative_parts  /* buf_orig_parts  */
        ,buffer buf_trn-doc     /* buf_trn-doc     */
        ,output v-real-chg-qnty /* p-real-chg-qnty */
        ,output v-parts-recid   /* p-parts-recid   */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове partrsrv" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return return-value .
      end.

      assign
        p-total-rsrv-qnty = p-total-rsrv-qnty + v-real-chg-qnty
        p-abs-rsrv-qnty   = p-abs-rsrv-qnty   + abs(v-real-chg-qnty)
      .
    end.
  end.

end procedure. /* rsrv-inv-create-supp */


/* $Workfile$ e n d */