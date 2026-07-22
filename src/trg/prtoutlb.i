/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с партиями расходной зоны

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/09/03

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop def-temp-output-parts define temp-table temp-output-parts no-undo ~
  like ub.parts ~
  field free-qnty as decimal ~
  field free-cli-qnty as decimal ~
.


{&def-temp-output-parts}

procedure prtoutlb_clear-temp-output-parts :

  define buffer buf_temp-output-parts for temp-output-parts .

  do
  on error undo, return error
  :
    for each buf_temp-output-parts
    on error undo, return error
    :
      delete buf_temp-output-parts .
    end.
  end.

end procedure. /* prtoutlb_clear-temp-output-parts */


procedure prtoutlb_create-temp-output-parts :

  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-output-parts  for temp-output-parts .

  do
  on error undo, return error
  :
    find first buf_temp-output-parts exclusive-lock
      where buf_temp-output-parts.obj-type  = buf_parts.obj-type
        and buf_temp-output-parts.obj-code  = buf_parts.obj-code
        and buf_temp-output-parts.artic     = buf_parts.artic
        and buf_temp-output-parts.prod-type = buf_parts.prod-type
        and buf_temp-output-parts.prod-code = buf_parts.prod-code
        and buf_temp-output-parts.in-code   = buf_parts.in-code
        and buf_temp-output-parts.out-code  = {&free-code}
        and buf_temp-output-parts.part-code = buf_parts.part-code
      no-error.
    if not available buf_temp-output-parts then do:
      create buf_temp-output-parts .
      buffer-copy buf_parts to buf_temp-output-parts
      assign
        buf_temp-output-parts.out-code  = {&free-code}

        buf_temp-output-parts.rsrv-free = yes
        buf_temp-output-parts.status_   = no

        buf_temp-output-parts.qnty      = 0
        buf_temp-output-parts.fact-qnty = 0
        buf_temp-output-parts.real-qnty = 0
        buf_temp-output-parts.cli-qnty  = 0
      .
    end.
  end.

end procedure. /* prtoutlb_create-temp-output-parts */


procedure prtoutlb_init-output-temp-output-parts :

  /* процедура строит расходную зону или по всем партиям */
  /* или только по партиям приходного документа */

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .
  define input  parameter p-in-code   as character no-undo .

  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-output-parts for temp-output-parts .

  do
  on error undo, return error
  :
    run prtoutlb_clear-temp-output-parts in this-procedure .

    /* по всем партиям свободной зоны */
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = false
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
        and (p-in-code = ""
             or buf_parts.in-code = p-in-code
            )
    on error undo, return error
    :
      run prtoutlb_create-temp-output-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-output-parts
        ) .

      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .

      if buf_parts.out-code = {&output-code} then do:
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
        buf_temp-output-parts.qnty          = buf_temp-output-parts.qnty          + v-parts-qnty
        buf_temp-output-parts.fact-qnty     = buf_temp-output-parts.fact-qnty     + v-parts-qnty
        buf_temp-output-parts.real-qnty     = 0
        buf_temp-output-parts.cli-qnty      = buf_temp-output-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-output-parts.free-qnty     = buf_temp-output-parts.free-qnty     + v-parts-free-qnty
        buf_temp-output-parts.free-cli-qnty = buf_temp-output-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.

end procedure. /* prtoutlb_init-output-temp-output-parts */


procedure prtoutlb_update-output-by-doc :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .
  define input  parameter p-in-code   as character no-undo .
  define input  parameter p-doc-code  as character no-undo .

  define variable vss-description as character no-undo init "prtoutlb_update-output-by-doc-01: обновляет расходную зону на основании партий документа".

  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_parts    for ub.parts .

  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    /* применяем архивные партии документа к временной таблице с обратным знаком */
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and (p-in-code = ""
              or buf_parts.in-code = p-in-code
            )
    on error undo, return error
    :
      define buffer buf_temp-output-parts for temp-output-parts .

      run prtoutlb_create-temp-output-parts in this-procedure
        (buffer buf_parts      /* buf_parts      */
        ,buffer buf_temp-output-parts /* buf_temp-output-parts */
        ) .

      define variable v-create-part as logical   no-undo .
      define variable v-old-return  as logical   no-undo .
      define variable v-create-obj  as logical   no-undo .

      { gbl/partparm.i
        recid(buf_parts)
        v-create-part
        v-old-return
        v-create-obj
      }

      define variable v-is-hold as logical   no-undo .
      { gbl/hold-doc.i
        buf_trn-doc.doc-code
        v-is-hold
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq}
          "Ошибка при определении типа документа hold-doc.i" skip
          "Документ" p-doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable v-rsrv-code as character no-undo .
      define variable v-unrv-code as character no-undo .
      define variable v-need-rsrv as logical   no-undo .
      define variable v-need-unrv as logical   no-undo .
      define variable v-rsrv-sign as integer   no-undo .
      define variable v-unrv-sign as integer   no-undo .

      { gbl/partcond.i
        buf_trn-doc.ext-doc-type
        v-is-hold
        buf_parts.fact-qnty
        v-create-part
        v-old-return
        v-rsrv-code
        v-unrv-code
        v-need-rsrv
        v-need-unrv
        v-rsrv-sign
        v-unrv-sign
        no-error
      }

      define variable v-update-sign as integer   no-undo .

      assign
        v-update-sign = 0
      .

      if v-rsrv-code  = {&output-code}
      and v-need-rsrv = true
      then do:
        assign
          v-update-sign = v-rsrv-sign
        .
      end.

      if v-unrv-code  = {&output-code}
      and v-need-unrv = true
      then do:
        assign
          v-update-sign = v-unrv-sign
        .
      end.

      if v-update-sign <> 0
      then do:
        /* здесь необходимо брать фактическое количество */
        assign
          buf_temp-output-parts.qnty      = buf_temp-output-parts.qnty
                                    + v-update-sign * buf_parts.fact-qnty
          buf_temp-output-parts.fact-qnty = buf_temp-output-parts.fact-qnty
                                    + v-update-sign * buf_parts.fact-qnty
          buf_temp-output-parts.cli-qnty  = buf_temp-output-parts.cli-qnty
                                    + v-update-sign * buf_parts.cli-qnty
        .
      end.

      /* удаляем нулевые партии */
      if buf_temp-output-parts.qnty = 0 then do:
        delete buf_temp-output-parts .
      end.
    end.
  end.

end procedure. /* prtoutlb_update-output-by-doc */


procedure prtoutlb_process-output :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define input  parameter p-in-code            as character no-undo .
  define input  parameter p-fact-order         as decimal   no-undo .
  define input  parameter p-include-fact-order as logical   no-undo .
  define input  parameter p-callback-name      as character no-undo .
  define input  parameter p-callback-handle    as handle    no-undo .

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

  define variable vss-description as character no-undo init "prtoutlb_process-output-01: обработка партий расходной зоны с вызовом процедуры обработки".

  define buffer buf_gds-obj  for ub.gds-obj .

  do
  on error undo, return error return-value
  :
    if p-callback-name = ""
    or p-callback-name = ?
    or not valid-handle(p-callback-handle)
    or p-callback-handle :get-signature(p-callback-name) = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Некорректное значение название или указателя процедуры" skip
        "Указатель процедуры" p-callback-handle skip
        "Имя процедуры" p-callback-name   skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Логический номер" p-fact-order skip
        view-as alert-box error .
      undo, return error return-value .
    end.

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
      if error-status :error then do:
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
    run prtoutlb_init-output-temp-output-parts in this-procedure
      (input p-obj-type  /* p-obj-type  */
      ,input p-obj-code  /* p-obj-code  */
      ,input p-artic     /* p-artic     */
      ,input p-prod-type /* p-prod-type */
      ,input p-prod-code /* p-prod-code */
      ,input p-in-code   /* p-in-code   */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Логический номер" p-fact-order skip
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

    define variable v-max-fact-order as integer   no-undo .

    run factord-max-fact-order in this-procedure
      (output v-max-fact-order /* p-max-fact-order */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Логический номер" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    define buffer buf_doc-line for ub.doc-line .

    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = {&fact}
        and buf_doc-line.fact-order > p-fact-order
        and buf_doc-line.fact-order <= v-max-fact-order
      by buf_doc-line.fact-order descending
    on error undo, return error
    :
      run value(p-callback-name) in p-callback-handle
        (input buf_doc-line.doc-code )
        no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Ошибка при вызове процедуры" p-callback-name skip
          "Указатель процедуры" p-callback-handle skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Логический номер" p-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run prtoutlb_update-output-by-doc in this-procedure
        (input  p-obj-type            /* p-obj-type  */
        ,input  p-obj-code            /* p-obj-code  */
        ,input  p-artic               /* p-artic     */
        ,input  p-prod-type           /* p-prod-type */
        ,input  p-prod-code           /* p-prod-code */
        ,input  p-in-code             /* p-in-code   */
        ,input  buf_doc-line.doc-code /* p-doc-code  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Ошибка при вызове процедуры prtoutlb_update-output-by-doc"
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Логический номер" p-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* prtoutlb_process-output */

/* $Workfile$ e n d */