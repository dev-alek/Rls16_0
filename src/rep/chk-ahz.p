block-level on error undo, throw.
/*

$Revision: 61c78e167033, 1728, rls $
$Author: ASMorozov $
$Date: Wed Dec 26 18:20:46 2018 +0300 $
$Workfile: chk-ahz.p $
$Archive: rep/chk-ahz.p $

Проверка состояния складских архивов и возвращение правильных дат

Автор: Чернова Светлана Александровна
Дата создания: 11/19/07
Author: Svetlana Chernova
Creation date: 11/19/07

p-verify-detail = true  - проверить наличие подробных архивов
                = false - проверить наличие сжатых архивов
p-verify-arh    - проверить складской архив по товарам
p-verify-ahsp   - проверить складской архив по поставщикам
p-verify-aht    - проверить складской архив по типам приобретения.

*/

define input        parameter p-obj-type          as character no-undo .
define input        parameter p-obj-code          as integer   no-undo .
define input        parameter p-verify-detail     as logical   no-undo .
define input        parameter p-verify-arh        as logical   no-undo .
define input        parameter p-verify-ahsp       as logical   no-undo .
define input        parameter p-verify-aht        as logical   no-undo .
define input        parameter p-check-act         as logical   no-undo .
define input        parameter p-check-act-db-num  as integer   no-undo .
define input        parameter p-check-act-user-id as character no-undo .
define input-output parameter p-date-start        as date      no-undo .
define input-output parameter p-date-end          as date      no-undo .
define output       parameter p-archive-ok        as logical   no-undo .
define output       parameter p-comment           as character no-undo .
define output       parameter p-can-print         as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 61c78e167033, 1728, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 26 18:20:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-ahz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/chk-ahz.p $":U .
define variable vss-description as character no-undo init "Проверка состояния складских архивов и возвращение правильных дат".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7',p-obj-type,p-obj-code,p-verify-arh,p-verify-ahsp,p-verify-aht,p-date-start,p-date-end)" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ trg/factord.i  }

define buffer buf_ot-tot      for ub.ot-tot .
define buffer buf_ot-supp-tot for ub.ot-supp-tot .
define buffer buf_aht-ot-tot  for ub.aht-ot-tot .
define buffer buf_trn-doc     for ub.trn-doc .

do
on error undo, return error return-value
:

  /* проверка параметров */
  if  p-verify-arh    = false
  and p-verify-ahsp   = false
  and p-verify-aht    = false
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указан складской архив, который необходимо проверить" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if p-date-start = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указана дата начала периода" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-date-end = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указана дата завершения периода" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    return .
  end.

  if p-date-start > p-date-end
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Дата начала периода не может быть больше даты завершения периода" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    return .
  end.

  define variable v-obj-exist as logical   no-undo .
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'check-exist':u"
    v-obj-exist
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Не найден объект" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата начала периода" string(p-date-start, '99/99/9999':u) skip
      "Дата завершения периода" string(p-date-end, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  /* не понятно для чего это проверка нужна, и почему ругается на не откртыю смену, хотя при проверки ищет наличие именно закрытой смены
  соответвенно когда одна открытая смена на объекте и других нету, то расчет архивов не производился*/

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define variable v-shift-new as logical    no-undo .

  /*if p-verify-arh or
     p-verify-ahsp or
     p-verify-aht  then do:

  v-shift-new = false .
  run ver-new-shiftobj (
    input p-obj-type ,
    input p-obj-code ,
    output v-shift-new
    ) no-error .
      if v-shift-new then do:
          assign
            p-archive-ok = false
            p-comment    = 'Не открыта смена'
            p-can-print  = true
          .
          return .
      end.
  end.*/


  if p-verify-arh = true
  then do:
    define variable v-arh-calc          as logical   no-undo .
    define variable v-arh-del           as logical   no-undo .
    define variable v-arh-disable       as logical   no-undo .
    define variable v-arh-start-date    as date      no-undo .
    define variable v-arh-detail-date   as date      no-undo .
    define variable v-arh-recalc-date   as date      no-undo .
    define variable v-arh-last-stk-date as date      no-undo .
    define variable v-arh-last-stk-time as integer   no-undo .


    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-arh-calc}        /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-calc = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-arh-del}         /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-arh-disable}     /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-disable = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-arh-start-date}  /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-start-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-arh-detail-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-detail-date = date(v-attr-value)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-arh-recalc-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-arh-recalc-date = date(v-attr-value)
    .

    assign
      v-arh-last-stk-date = ?
      v-arh-last-stk-time = 0
    .

    find last buf_ot-tot no-lock
      where buf_ot-tot.obj-code = p-obj-code
        and buf_ot-tot.obj-type = p-obj-type
      use-index obj-ot
      no-error .
    if available buf_ot-tot
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_ot-tot.doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-arh-last-stk-date = buf_trn-doc.fact-date
          v-arh-last-stk-time = buf_trn-doc.fact-time
        .
      end.
    end.
    run check-date in this-procedure
      (input        v-arh-calc          /* p-calc          */
      ,input        v-arh-del           /* p-del           */
      ,input        v-arh-disable       /* p-disable       */
      ,input        v-arh-start-date    /* p-start-date    */
      ,input        v-arh-detail-date   /* p-detail-date   */
      ,input        v-arh-recalc-date   /* p-recalc-date   */
      ,input        v-arh-last-stk-date /* p-last-stk-date */
      ,input        v-arh-last-stk-time /* p-last-stk-time */
      ,input        "Складской архив по товарам" /* p-name          */
      ,input        'arh':u             /* p-ahz-type      */
      ,input        p-verify-detail     /* p-verify-detail */
      ,input-output p-date-start        /* p-date-start    */
      ,input-output p-date-end          /* p-date-end      */
      ,output       p-archive-ok        /* p-archive-ok    */
      ,output       p-comment           /* p-comment       */
      ,output       p-can-print         /* p-can-print     */
      ) .
    if p-archive-ok = false
    then do:
      return .
    end.
  end.

  if p-verify-ahsp = true
  then do:
    define variable v-ahsp-calc          as logical   no-undo .
    define variable v-ahsp-del           as logical   no-undo .
    define variable v-ahsp-disable       as logical   no-undo .
    define variable v-ahsp-start-date    as date      no-undo .
    define variable v-ahsp-detail-date   as date      no-undo .
    define variable v-ahsp-recalc-date   as date      no-undo .
    define variable v-ahsp-last-stk-date as date      no-undo .
    define variable v-ahsp-last-stk-time as integer   no-undo .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-ahsp-calc}        /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-ahsp-calc = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-ahsp-del}         /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-ahsp-disable}    /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-ahsp-disable = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-ahsp-start-date}  /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-ahsp-start-date = date(v-attr-value)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-ahsp-detail-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-ahsp-detail-date = date(v-attr-value)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-ahsp-recalc-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-ahsp-recalc-date = date(v-attr-value)
    .

    assign
      v-ahsp-last-stk-date = ?
      v-ahsp-last-stk-time = 0
    .
    find last buf_ot-supp-tot no-lock
      where buf_ot-supp-tot.obj-code = p-obj-code
        and buf_ot-supp-tot.obj-type = p-obj-type
      use-index fact-order
      no-error .
    if available buf_ot-supp-tot
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_ot-supp-tot.doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-ahsp-last-stk-date = buf_trn-doc.fact-date
          v-ahsp-last-stk-time = buf_trn-doc.fact-time
        .
      end.
    end.

    run check-date in this-procedure
      (input        v-ahsp-calc          /* p-calc          */
      ,input        v-ahsp-del           /* p-del           */
      ,input        v-ahsp-disable       /* p-disable       */
      ,input        v-ahsp-start-date    /* p-start-date    */
      ,input        v-ahsp-detail-date   /* p-detail-date   */
      ,input        v-ahsp-recalc-date   /* p-recalc-date   */
      ,input        v-ahsp-last-stk-date /* p-last-stk-date */
      ,input        v-ahsp-last-stk-time /* p-last-stk-time */
      ,input        "Складской архив по поставщикам" /* p-name          */
      ,input        'ahsp':u             /* p-ahz-type      */
      ,input        p-verify-detail      /* p-verify-detail */
      ,input-output p-date-start         /* p-date-start    */
      ,input-output p-date-end           /* p-date-end      */
      ,output       p-archive-ok         /* p-archive-ok    */
      ,output       p-comment            /* p-comment       */
      ,output       p-can-print          /* p-can-print     */
      ) .
    if p-archive-ok = false
    then do:
      return .
    end.
  end.

  if p-verify-aht = true
  then do:
    define variable v-aht-calc          as logical   no-undo .
    define variable v-aht-del           as logical   no-undo .
    define variable v-aht-disable       as logical   no-undo .
    define variable v-aht-start-date    as date      no-undo .
    define variable v-aht-detail-date   as date      no-undo .
    define variable v-aht-recalc-date   as date      no-undo .
    define variable v-aht-last-stk-date as date      no-undo .
    define variable v-aht-last-stk-time as integer   no-undo .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-calc}        /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-calc = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-del}         /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-del = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-disable}     /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-disable = (lookup(v-attr-value, 'yes,true') > 0)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-start-date}  /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-start-date = date(v-attr-value)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-detail-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-detail-date = date(v-attr-value)
    .

    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-recalc-date} /* p-code     */
      ,output v-attr-value            /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-recalc-date = date(v-attr-value)
    .

    assign
      v-aht-last-stk-date = ?
      v-aht-last-stk-time = 0
    .
    find last buf_aht-ot-tot no-lock
      where buf_aht-ot-tot.obj-code = p-obj-code
        and buf_aht-ot-tot.obj-type = p-obj-type
      use-index fact-order
      no-error .
    if available buf_aht-ot-tot
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_aht-ot-tot.doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-aht-last-stk-date = buf_trn-doc.fact-date
          v-aht-last-stk-time = buf_trn-doc.fact-time
        .
      end.
    end.

    run check-date in this-procedure
      (input        v-aht-calc          /* p-calc          */
      ,input        v-aht-del           /* p-del           */
      ,input        v-aht-disable       /* p-disable       */
      ,input        v-aht-start-date    /* p-start-date    */
      ,input        v-aht-detail-date   /* p-detail-date   */
      ,input        v-aht-recalc-date   /* p-recalc-date   */
      ,input        v-aht-last-stk-date /* p-last-stk-date */
      ,input        v-aht-last-stk-time /* p-last-stk-time */
      ,input        "Складской архив по типам приобретения" /* p-name          */
      ,input        'aht':u             /* p-ahz-type      */
      ,input        p-verify-detail     /* p-verify-detail */
      ,input-output p-date-start        /* p-date-start    */
      ,input-output p-date-end          /* p-date-end      */
      ,output       p-archive-ok        /* p-archive-ok    */
      ,output       p-comment           /* p-comment       */
      ,output       p-can-print         /* p-can-print     */
      ) .
    if p-archive-ok = false
    then do:
      return .
    end.
  end.

  assign
    p-archive-ok = true
    p-comment    = ""
    p-can-print  = true
  .
  return .

end.


procedure check-date :


  define input        parameter p-calc          as logical   no-undo .
  define input        parameter p-del           as logical   no-undo .
  define input        parameter p-disable       as logical   no-undo .
  define input        parameter p-start-date    as date      no-undo .
  define input        parameter p-detail-date   as date      no-undo .
  define input        parameter p-recalc-date   as date      no-undo .
  define input        parameter p-last-stk-date as date      no-undo .
  define input        parameter p-last-stk-time as integer   no-undo .
  define input        parameter p-name          as character no-undo .
  define input        parameter p-ahz-type      as character no-undo .
  define input        parameter p-verify-detail as logical   no-undo .
  define input-output parameter p-date-start    as date      no-undo .
  define input-output parameter p-date-end      as date      no-undo .
  define output       parameter p-archive-ok    as logical   no-undo .
  define output       parameter p-comment       as character no-undo .
  define output       parameter p-can-print     as logical   no-undo .

  do
  on error undo, return error return-value
  :
    if  (p-calc = true
         or p-del  = true
        )
    and p-disable = true
    then do:
      assign
        p-archive-ok = false
        p-comment    = p-name + {&new-line}
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                     + "Расчет складского архива запрещен" + {&new-line}
        p-can-print  = false
      .
      run ver-del-obj (
          input p-obj-type ,
          input p-obj-code ,
          input-output p-can-print
          ) no-error .
      return .
    end.

    if p-calc = true
    then do:
      assign
        p-archive-ok = false
        p-comment    = p-name + {&new-line}
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                     + p-name + " не рассчитан" + {&new-line}
        p-can-print  = false
      .
      run ver-del-obj (
          input p-obj-type ,
          input p-obj-code ,
          input-output p-can-print )
          no-error .

      return .
    end.

    if p-del = true
    then do:
      assign
        p-archive-ok = false
        p-comment    = p-name + {&new-line}
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                     + "Начальные остатки по складскому архиву не рассчитаны" + {&new-line}
        p-can-print  = false
      .
      run ver-del-obj (
          input p-obj-type ,
          input p-obj-code ,
          input-output p-can-print )
          no-error .

      return .
    end.

    /* проверка непротивочивости задания первоначальной даты */
    /* и даты начала подробных складских архивов */
    /* либо обе даты должны быть заданы, либо обе даты должны быть пустыми */
    if (p-start-date  = ?
       and p-detail-date <> ?
       )
    or
       (p-start-date  <> ?
       and p-detail-date = ?
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при анализе дат складского архива" skip
        "Задана только одна дата" skip
        "" p-start-date skip
        "" p-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.


    if p-date-start < p-start-date
    then do:
      assign
        p-date-start = p-start-date
      .
      if p-date-end < p-start-date
      then do:
        assign
          p-date-end = p-start-date
        .
      end.
      assign
        p-archive-ok = false
        p-comment    = p-name + {&new-line}
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                     + "Дата начала периода не может быть раньше начала рассчитанного складского архива"
        p-can-print  = false
      .
      return .
    end.

    if  p-verify-detail = true
    and p-date-start < p-detail-date
    then do:
      assign
        p-date-start = p-detail-date
      .
      if p-date-end < p-date-start
      then do:
        assign
          p-date-end = p-date-start
        .
      end.
      assign
        p-archive-ok = false
        p-comment    = p-name + {&new-line}
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                     + "Для подробного архива дата начала периода должна быть больше или равна началу подробного архива"
        p-can-print  = false
      .
      return .
    end.


    define variable v-new-date-start as date      no-undo .

    if  p-date-start > p-start-date
    and p-date-start < p-detail-date
    and day(p-date-start) <> 1
    and p-date-end <> p-date-start
    then do:
      /* если дата попадает в период сжатых архивов и не совпадает с началом месяца */
      /* переместить ее на начало текущего месяца, если это возможно */
      /* иначе на начало следующего месяца */
      assign
        v-new-date-start = date(month(p-date-start),1,year(p-date-start))
      .
      if v-new-date-start < p-start-date
      then do:
        run gbl/lastdate.p
          (input  p-date-start
          ,output v-new-date-start
          ) .
        assign
          v-new-date-start = v-new-date-start + 1
        .
      end.
      assign
        p-date-start = v-new-date-start
      .
      if p-date-end < p-date-start
      then do:
        run gbl/lastdate.p
          (input  p-date-start
          ,output p-date-end
          ) .
      end.

      assign
        p-archive-ok = false
        p-comment    = p-name + {&new-line}
                     + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                     + "Для сжатого складского архива дата начала периода должна быть началом месяца"
        p-can-print  = false
      .
      return .
    end.

    define variable v-new-date-end as date      no-undo .

    if  p-date-end > p-start-date
    and p-date-end < p-detail-date
    then do:
      /* для сжатого складского архива дата должна быть датой конца месяца */
      run gbl/lastdate.p
        (input  p-date-end
        ,output v-new-date-end
        ) .
      if p-date-end <> v-new-date-end
      then do:
        assign
          p-date-end = v-new-date-end
        .
        assign
          p-archive-ok = false
          p-comment    = p-name + {&new-line}
                       + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                       + "Для сжатого складского архива дата завершения периода должна быть последним днем месяца " + string(v-new-date-end,"99/99/9999")
          p-can-print  = false
        .
        return .
      end.
    end.

    define variable v-date-shift as date      no-undo .
    run ver-shift in this-procedure (
        input   p-date-end ,
        input   p-obj-type ,
        input   p-obj-code ,
        output  v-date-shift ) no-error .
    /* даты правильные - проверяем наличие новых документов */
    /* при необходимости производим дорасчет */
    if p-last-stk-date = ?
    or (p-last-stk-date <> ?
        and p-date-end >= p-last-stk-date) or v-date-shift <= p-last-stk-date
        
    or (p-recalc-date <> ?
        and p-date-end >= p-recalc-date
       )
    then do:
    /* Уточнение календарной даты до даты окончания смены */


      case p-ahz-type
      :
        when 'arh':u
        then do:
          run trg/bt_arh.p
            (input p-obj-type          /* p-obj-type          */
            ,input p-obj-code          /* p-obj-code          */
            ,input v-date-shift          /* p-last-date         */
            ,input p-check-act         /* p-check-act         */
            ,input p-check-act-db-num  /* p-check-act-db-num  */
            ,input p-check-act-user-id /* p-check-act-user-id */
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры bt_arh.p" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            assign
              p-archive-ok = false
              p-comment    = p-name + {&new-line}
                           + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                           + substitute("&1", return-value) + {&new-line}
                           + (if p-last-stk-date = ?
                              then p-name + " не рассчитан"
                              else substitute("&1 рассчитан до &2   &3"
                                              ,p-name
                                              ,string(p-last-stk-date, '99/99/9999':u)
                                              ,string(p-last-stk-time, 'HH:MM':u)
                                    )
                              ) + {&new-line}
              p-can-print  = true
            .
            run ver-del-obj (
                input p-obj-type ,
                input p-obj-code ,
                input-output p-can-print )
                no-error .

            return .
          end.
        end.
        when 'ahsp':u
        then do:
          run trg/bt_ahsp.p
            (input p-obj-type          /* p-obj-type          */
            ,input p-obj-code          /* p-obj-code          */
            ,input v-date-shift          /* p-last-date         */
            ,input p-check-act         /* p-check-act         */
            ,input p-check-act-db-num  /* p-check-act-db-num  */
            ,input p-check-act-user-id /* p-check-act-user-id */
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры bt_ahsp.p" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            assign
              p-archive-ok = false
              p-comment    = p-name + {&new-line}
                           + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                           + substitute("&1", return-value) + {&new-line}
                           + (if p-last-stk-date = ?
                              then p-name + " не рассчитан"
                              else substitute("&1 рассчитан до &2   &3"
                                              ,p-name
                                              ,string(p-last-stk-date, '99/99/9999':u)
                                              ,string(p-last-stk-time, 'HH:MM':u)
                                    )
                              ) + {&new-line}
              p-can-print  = true
            .
            run ver-del-obj (
                input p-obj-type ,
                input p-obj-code ,
                input-output p-can-print )
                no-error .

            return .
          end.
        end.
        when 'aht':u
        then do:
          run trg/bt_aht.p
            (input p-obj-type          /* p-obj-type          */
            ,input p-obj-code          /* p-obj-code          */
            ,input v-date-shift         /* p-last-date         */
            ,input p-check-act         /* p-check-act         */
            ,input p-check-act-db-num  /* p-check-act-db-num  */
            ,input p-check-act-user-id /* p-check-act-user-id */
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры bt_aht.p" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            assign
              p-archive-ok = false
              p-comment    = p-name + {&new-line}
                           + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
                           + substitute("&1", return-value) + {&new-line}
                           + (if p-last-stk-date = ?
                              then p-name + " не рассчитан"
                              else substitute("&1 рассчитан до &2   &3"
                                              ,p-name
                                              ,string(p-last-stk-date, '99/99/9999':u)
                                              ,string(p-last-stk-time, 'HH:MM':u)
                                    )
                              ) + {&new-line}
              p-can-print  = true
            .
              run ver-del-obj (
                  input p-obj-type ,
                  input p-obj-code ,
                  input-output p-can-print )
                  no-error .

            return .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение параметра p-ahz-type" skip
            "Значение параметра" p-ahz-type skip
            view-as alert-box error .
          assign
            p-archive-ok = false
            p-comment    = ""
            p-can-print  = false
          .
          return .
        end.
      end.
    end.

    assign
      p-archive-ok = true
      p-comment    = ""
      p-can-print  = true
    .
    return .

  end.
end procedure. /* check-date */


procedure ver-shift :
define input  parameter p-date     as date      no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define output parameter p-date-shift   as date      no-undo .

define variable  l-shift-on as logical no-undo .
define buffer buf_shift-obj for ub.shift-obj  .

  do
  on error undo, return error return-value
  :
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
    no-error
  }
  if l-shift-on = false then do:
     p-date-shift = p-date.
     return .
  end.

  for each  buf_shift-obj no-lock where
            buf_shift-obj.obj-type = p-obj-type and
            buf_shift-obj.obj-code = p-obj-code and
            buf_shift-obj.shift-date = p-date   by
            buf_shift-obj.close-date
            :
       p-date-shift = buf_shift-obj.close-date .
   end.

  if p-date-shift = ? or p-date-shift < p-date then p-date-shift = p-date .

end.
end procedure. /* ver-shift */


procedure ver-del-obj :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input-output parameter p-is-del as logical   no-undo .

define buffer buf_clients for ub.clients  .

/* Проверим , что объект удаленный, считать не надо, но информацию с него можно получать */
  do
  on error undo, return error return-value
  :
 /* p-is-del = false .   */
    find first buf_clients no-lock where
               buf_clients.obj-type = p-obj-type and
               buf_clients.obj-code = p-obj-code no-error .

     if buf_clients.stts <> 0 then do:
        p-is-del = true .
     end.

  end.

end procedure. /* ver-del-obj */


procedure ver-new-shiftobj :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-is-new   as logical   no-undo .
define buffer buf_shift-obj for ub.shift-obj  .

  do
  on error undo, return error return-value
  :
      p-is-new = false .
    /* Для сменного объекта */
      run factord-lock-shift (
          input p-obj-type ,
          input p-obj-code ,
          input date('01/01/1900')  ,
          buffer buf_shift-obj
      ) no-error .
      if error-status :error then do:
        p-is-new = true  .
      end.
  end.

end procedure. /* ver-new-shiftobj */