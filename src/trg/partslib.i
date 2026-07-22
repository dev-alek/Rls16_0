/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Стандантные процедуры связанные с обработкой партий на объекте

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop def-temp-parts define temp-table temp-parts no-undo ~
  like ub.parts ~
  field free-qnty as decimal ~
  field free-cli-qnty as decimal ~
.


{&def-temp-parts}


procedure partslib-clear-temp-parts :

  define buffer buf_temp-parts for temp-parts .

  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.

end procedure. /* partslib-clear-temp-parts */


procedure partslib-create-temp-parts :

  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .

  define variable v-base-part-code as character no-undo .

  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.

    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = {&free-code}
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = {&free-code}
        buf_temp-parts.part-code = v-base-part-code

        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no

        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.

end procedure. /* partslib-create-temp-parts */



procedure partslib-init-temp-parts :

  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .

  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .

  define variable v-goods-twounit    as logical   no-undo .

  do
  on error undo, return error
  :
    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'twounit=request':u"
      v-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run partslib-clear-temp-parts in this-procedure .

    /* по всем партиям свободной зоны */
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .

      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .

      if buf_parts.out-code = {&free-code}
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.

      /* здесь необходимо брать количество по документу */
      /* так как мы учитываем партии, зарезервированные за документами */
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.

end procedure. /* partslib-init-temp-parts */


procedure partslib-init-temp-parts-by-factord :

  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .

  /*

  Если в качестве параметра указывается p-fact-order документа, то

  если p-include-fact-order = false - то в результате получитс
  остаток который был непосредственно после закрытия документа
  до статуса {&fact}

  если p-include-fact-order = true - то в результате получитс
  остаток, который был

  Если в качестве p-fact-order указывается конец дня или конец смены,
  то должно быть p-include-fact-order = false

  */

  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".

  define buffer buf_gds-obj  for ub.gds-obj .

  do
  on error undo, return error
  :

    /* блокируется товар на объекте в соответствии с общими правилами */
    /* 1. открывается транзакция */
    /* 2. накладывается exclusive блокировка на товар */
    /* 3. затем блокировка по выходу из блока автоматически снижается */
    /*    до уровня share-lock */
    do transaction
    on error undo, return error
    :
      { gbl/gdsobjcr.i
        p-obj-type
        p-obj-code
        p-artic
        p-prod-type
        p-prod-code
        buf_gds-obj
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      find current buf_gds-obj exclusive-lock .
    end.

    /* инициализация текущего остатка по партиям свободной зоны */
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type  /* p-obj-type  */
      ,input p-obj-code  /* p-obj-code  */
      ,input p-artic     /* p-artic     */
      ,input p-prod-type /* p-prod-type */
      ,input p-prod-code /* p-prod-code */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    /* требуется получить информацию о состоянии */
    /* непосредственно перед закрытием документа */
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - {&arh-delta}
      .
    end.

    define variable v-max-fact-order as character no-undo .

    run factord-max-fact-order in this-procedure
      (output v-max-fact-order /* p-max-fact-order */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    /* просматриваем все операции, прошедшие с товаром с указанного момента p-fact-order */
    /* до текущего момента */
    /* новые документы во время нашего прохода появится не могут, так как товар мы заблокировали */
    run partslib-update-by-factord in this-procedure
      (input p-obj-type       /* p-obj-type         */
      ,input p-obj-code       /* p-obj-code         */
      ,input p-artic          /* p-artic            */
      ,input p-prod-type      /* p-prod-type        */
      ,input p-prod-code      /* p-prod-code        */
      ,input p-fact-order     /* p-start-fact-order */
      ,input v-max-fact-order /* p-end-fact-order   */
      ,input false            /* p-lock-gds-obj     */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* partslib-init-temp-parts-by-factord */


procedure partslib-update-by-factord :

  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .

  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".

  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .

  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .

  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.


    if p-lock-gds-obj = true
    then do:
      /* блокируется товар на объекте в соответствии с общими правилами */
      /* 1. открывается транзакция */
      /* 2. накладывается exclusive блокировка на товар */
      /* 3. затем блокировка по выходу из блока автоматически снижается */
      /*    до уровня share-lock */
      do transaction
      on error undo, return error
      :
        { gbl/gdsobjcr.i
          p-obj-type
          p-obj-code
          p-artic
          p-prod-type
          p-prod-code
          buf_gds-obj
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info{&vssseq} skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        find current buf_gds-obj exclusive-lock .
      end.
    end.

    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'gds-goods=request':u"
      v-goods-gds-goods
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'twounit=request':u"
      v-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* просматриваем все операции, прошедшие с товаром с указанного момента p-fact-order */
    /* до текущего момента */
    /* новые документы во время нашего прохода появится не могут, так как товар мы заблокировали */
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = {&fact}
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code /* p-doc-code         */
        ,input  p-obj-type            /* p-obj-type         */
        ,input  p-obj-code            /* p-obj-code         */
        ,input  p-artic               /* p-artic            */
        ,input  p-prod-type           /* p-prod-type        */
        ,input  p-prod-code           /* p-prod-code        */
        ,input  v-goods-gds-goods     /* p-goods-gds-goods  */
        ,input  v-goods-twounit       /* p-goods-twounit    */
        ,output v-total-parts-qnty    /* p-total-parts-qnty */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* partslib-update-by-factord */


procedure partslib-process-document :

  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .

  define variable v-parts-sign as integer   no-undo .

  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.

    /* все действия производим с обратным знаком */
    case buf_trn-doc.doc-type
    :
      when {&income} or
      when {&return} or
      when {&inventory}
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when {&expense} or
      when {&write-off}
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.


    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.

    assign
      p-total-parts-qnty = 0
    .

    /* применяем архивные партии документа к временной таблице с обратным знаком */
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts       /* buf_parts       */
          ,buffer buf_temp-parts  /* buf_temp-parts  */
          ,input  p-goods-twounit /* p-goods-twounit */
          ) .
        /* здесь необходимо брать фактическое количество */
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .

        /* удаляем нулевые партии */
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.

end procedure. /* partslib-process-document */


procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .

  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".

  do
  on error undo, return error
  :

    /* определяем fact-order конца дня, на который нам требуются партии свободной зоны */
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .

    run factord in this-procedure
      (input  p-fact-date             /* p-fact-date            */
      ,input  1                       /* p-fact-time            */
      ,input  1                       /* p-fact-num             */
      ,input  ?                       /* p-shift-date           */
      ,input  0                       /* p-shift-num            */
      ,input  false                   /* p-shift-on             */
      ,output v-fact-order            /* p-fact-order           */
      ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
      ,output v-day-end-fact-order    /* p-day-end-fact-order   */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.

    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type           /* p-obj-type           */
      ,input p-obj-code           /* p-obj-code           */
      ,input p-artic              /* p-artic              */
      ,input p-prod-type          /* p-prod-type          */
      ,input p-prod-code          /* p-prod-code          */
      ,input v-day-end-fact-order /* p-fact-order         */
      ,input false                /* p-include-fact-order */
      ) no-error .

    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* partslib-init-temp-parts-by-date */


procedure partslib-calc-cost :

  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .

  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".

  do
  on error undo, return error return-value
  :

    define buffer buf_temp-parts for temp-parts .

    { str/in-vatp.i def }

    /* вычисляем остаток в учетных ценах */
    /* с разбивками по НДС, НП */
    /* с разбивками по виду поставки */
    /* идем по всем партиям свободной зоны */
    /* во временной таблице уже находятся только те партии, которые нужны */
    for each buf_temp-parts
    on error undo, return error
    :

      { str/in-vatp.i calc-parts buf_temp-parts. " " loc}

      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.

    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* partslib-calc-cost */


/* $Workfile$ */