block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ah-clin.p $
$Archive: utl/ah-clin.p $

Пометить складские архивы, как нерассчитанные

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/13/01

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ah-clin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ah-clin.p $":U .
define variable vss-description as character no-undo init "Пометить складские архивы, как нерассчитанные".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-all-object    as logical   no-undo .
define variable v-total-process as integer   no-undo .

do
on error undo, return error
:
  define variable v-num as integer   no-undo .

  { gbl/getcntxt.i get }


  run gbl/d-askw.w
    (input "Вопрос 1/3"
    ,input "Пометить складские архивы, как нерассчитанные" + {&new-line}
    ,input "|^"
    ,input "Все объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).



  case v-num :
    when 1
    then do:
      assign
        v-all-object = true
      .
    end.
    when 2
    then do:
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

      assign
        v-all-object = false
      .
    end.
    otherwise do:
      return . /* --->>>--- */
    end.
  end.


  run gbl/d-askw.w
    (input "Вопрос 2/3" /* Заголовок окна */
    ,input "Пометить складские архивы как требующие первоначального расчета" /* Общее сообщение */
    ,input "|^"
    ,input "Складской архив по товарам" + '|':u
      + "Складской архив по поставщикам" + '|':u
      + "Складской архив по типам приобретения" + '|':u
      + "Отказ"
    ,input '|':u /* список описаний кнопок */
      + '|':u
      + '|':u
      + ''
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 4 /* значение возвращаемое при нажатии escape */
    ,output v-num /* выбор пользователя */
    ).

  define variable v-calc-arh  as logical   no-undo .
  define variable v-calc-ahsp as logical   no-undo .
  define variable v-calc-aht as logical   no-undo .

  assign
    v-calc-arh  = false
    v-calc-ahsp = false
    v-calc-aht  = false
  .


  case v-num :
    when 1
    then do:
      assign
        v-calc-arh = true
      .
    end.
    when 2
    then do:
      assign
        v-calc-ahsp = true
      .
    end.
    when 3
    then do:
      assign
        v-calc-aht = true
      .
    end.
    when 4
    then do:
      return . /* --->>>--- */
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выборе" skip
        "Неизвестная опция" v-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .


  run gbl/d-askw.w
    (input "Вопрос 3/3" /* Заголовок окна */
    ,input "Пометить складские архивы" /* Общее сообщение */
    ,input "|^"
    ,input "Как требующие инициализации и первоначального расчета" + '|':u
      + "Как требующие первоначального расчета" + '|':u
      + "Отказ"
    ,input '|':u /* список описаний кнопок */
      + '|':u
      + ''
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 3 /* значение возвращаемое при нажатии escape */
    ,output v-num /* выбор пользователя */
    ).

  define variable v-mark-del  as logical   no-undo .
  define variable v-mark-calc as logical   no-undo .

  assign
    v-mark-del  = false
    v-mark-calc = false
  .


  case v-num :
    when 1
    then do:
      assign
        v-mark-del  = true
        v-mark-calc = true
      .
    end.
    when 2
    then do:
      assign
        v-mark-calc = true
      .
    end.
    when 3
    then do:
      return . /* --->>>--- */
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выборе" skip
        "Неизвестная опция" v-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .




  define variable v-ok as logical   no-undo .
  assign
    v-ok = false
  .
  message
    "ВНИМАНИЕ!" skip
    "Это последний вопрос перед выполнением операции." skip
    "Складские архивы будут помечены, как нерассчитанные." skip
    "Если у вас уже были рассчитанные складские архивы, то после выполнения данной" skip
    "операции вы не сможете собирать отчеты." skip
    "" skip
    "Объекты" skip
    "" ( if v-all-object  = true then "ВСЕ" else "Выбранные" ) skip
    "" skip
    "Складские архивы" skip
    "" ( if v-calc-arh  = true then "Складской архив по товарам"            else "" ) skip
    "" ( if v-calc-ahsp = true then "Складской архив по поставщикам"        else "" ) skip
    "" ( if v-calc-aht  = true then "Складской архив по типам приобретения" else "" ) skip
    "" skip
    "Будут установлены следующие атрибуты:" skip
    "" ( if v-mark-del  = true then "Необходима инициализации"             else "" ) skip
    "" ( if v-mark-calc = true then "Необходим расчет"                     else "" ) skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return . /* --->>>--- */
  end.

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .
  define buffer buf_clients  for ub.clients .

  find first buf_sys-ctrl .


  if v-all-object = true
  then do:
    for each buf_db
      where (buf_sys-ctrl.db-num = 0
            or
            buf_db.db-num = buf_sys-ctrl.db-num
            )
    ,each buf_clients no-lock
      where buf_clients.db-num = buf_db.db-num
    on error undo, return error
    :
      run process-object in this-procedure
        (input buf_clients.obj-type /* p-obj-type  */
        ,input buf_clients.obj-code /* p-obj-code  */
        ,input v-calc-arh           /* p-calc-arh  */
        ,input v-calc-ahsp          /* p-calc-ahsp */
        ,input v-calc-aht           /* p-calc-aht  */
        ,input v-mark-calc          /* p-mark-calc */
        ,input v-mark-del           /* p-mark-del  */
        ) .
    end.
  end.
  else do:
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      find first buf_clients no-lock
        where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
          and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
        .
      if buf_sys-ctrl.db-num = 0
      or buf_clients.db-num = buf_sys-ctrl.db-num
      then do:
        run process-object in this-procedure
          (input buf_clients.obj-type /* p-obj-type  */
          ,input buf_clients.obj-code /* p-obj-code  */
          ,input v-calc-arh           /* p-calc-arh  */
          ,input v-calc-ahsp          /* p-calc-ahsp */
          ,input v-calc-aht           /* p-calc-aht  */
          ,input v-mark-calc          /* p-mark-calc */
          ,input v-mark-del           /* p-mark-del  */
          ) .
      end.
    end.
  end.

  run waitfram-hide in this-procedure
    .

  message
    "Простановка атрибутов завершена" skip
    "" skip
    "Обработано объектов" v-total-process skip
    "" skip
    "Объекты" skip
    "" ( if v-all-object  = true then "ВСЕ" else "Выбранные" ) skip
    "" skip
    "Складские архивы" skip
    "" ( if v-calc-arh  = true then "Складской архив по товарам"            else "" ) skip
    "" ( if v-calc-ahsp = true then "Складской архив по поставщикам"        else "" ) skip
    "" ( if v-calc-aht  = true then "Складской архив по типам приобретения" else "" ) skip
    "" skip
    "Были установлены следующие атрибуты:" skip
    "" ( if v-mark-del  = true then "Необходима инициализации"             else "" ) skip
    "" ( if v-mark-calc = true then "Необходим расчет"                     else "" ) skip
    view-as alert-box information .

end.



procedure process-object :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-calc-arh  as logical   no-undo .
  define input  parameter p-calc-ahsp as logical   no-undo .
  define input  parameter p-calc-aht  as logical   no-undo .
  define input  parameter p-mark-calc as logical   no-undo .
  define input  parameter p-mark-del  as logical   no-undo .

  define variable v-create-chip-num as integer   no-undo .

  do
  on error undo, return error return-value
  :

    run waitfram-show in this-procedure
      (input substitute("Объект &1 &2", p-obj-type, p-obj-code)
      ) .

    if p-calc-arh = true
    then do:
      /* признак того, что требуется расчет складского архива по товарам */
      if p-mark-calc = true
      then do:
        run utl/arhiscr.p
          (input  p-obj-type                  /* p-obj-type              */
          ,input  p-obj-code                  /* p-obj-code              */
          ,input  {&btpr-type-arh}            /* p-archive-type          */
          ,input  {&archive-history-set-calc} /* p-action-type           */
          ,input  ""                          /* p-file-name             */
          ,input  ""                          /* p-file-md5              */
          ,input  0                           /* p-file-invalid-chip-num */
          ,input  ""                          /* p-source-type           */
          ,input  ""                          /* p-source-ref            */
          ,input  ?                           /* p-source-date           */
          ,output v-create-chip-num           /* p-create-chip-num       */
          ) .

        run clntattr-write in this-procedure
          (input buf_clients.obj-type /* p-obj-type */
          ,input buf_clients.obj-code /* p-obj-code */
          ,input {&attr-arh-calc}     /* p-code     */
          ,input true                 /* p-value    */
          ) .
      end.

      /* признак того, что требуется инициализация складского архива по товарам */
      if p-mark-del = true
      then do:
        run utl/arhiscr.p
          (input  p-obj-type                 /* p-obj-type              */
          ,input  p-obj-code                 /* p-obj-code              */
          ,input  {&btpr-type-arh}           /* p-archive-type          */
          ,input  {&archive-history-set-del} /* p-action-type           */
          ,input  ""                         /* p-file-name             */
          ,input  ""                         /* p-file-md5              */
          ,input  0                          /* p-file-invalid-chip-num */
          ,input  ""                         /* p-source-type           */
          ,input  ""                         /* p-source-ref            */
          ,input  ?                          /* p-source-date           */
          ,output v-create-chip-num          /* p-create-chip-num       */
          ) .

        run invalidate-md5-signature in this-procedure
          (input  p-obj-type        /* p-obj-type     */
          ,input  p-obj-code        /* p-obj-code     */
          ,input  {&btpr-type-arh}  /* p-archive-type */
          ,input  v-create-chip-num /* p-chip-num     */
          ) .

        run clntattr-write in this-procedure
          (input buf_clients.obj-type /* p-obj-type */
          ,input buf_clients.obj-code /* p-obj-code */
          ,input {&attr-arh-del}      /* p-code     */
          ,input true                 /* p-value    */
          ) .
      end.
    end.

    if p-calc-ahsp = true
    then do:
      /* признак того, что требуется расчет складского архива по поставщикам */
      if p-mark-calc = true
      then do:
        run utl/arhiscr.p
          (input  p-obj-type                  /* p-obj-type              */
          ,input  p-obj-code                  /* p-obj-code              */
          ,input  {&btpr-type-ahsp}           /* p-archive-type          */
          ,input  {&archive-history-set-calc} /* p-action-type           */
          ,input  ""                          /* p-file-name             */
          ,input  ""                          /* p-file-md5              */
          ,input  0                           /* p-file-invalid-chip-num */
          ,input  ""                          /* p-source-type           */
          ,input  ""                          /* p-source-ref            */
          ,input  ?                           /* p-source-date           */
          ,output v-create-chip-num           /* p-create-chip-num       */
          ) .

        run clntattr-write in this-procedure
          (input buf_clients.obj-type /* p-obj-type */
          ,input buf_clients.obj-code /* p-obj-code */
          ,input {&attr-ahsp-calc}    /* p-code     */
          ,input true                 /* p-value    */
          ) .
      end.

      /* признак того, что требуется инициализация складского архива по поставщикам */
      if p-mark-del = true
      then do:
        run utl/arhiscr.p
          (input  p-obj-type                 /* p-obj-type              */
          ,input  p-obj-code                 /* p-obj-code              */
          ,input  {&btpr-type-ahsp}          /* p-archive-type          */
          ,input  {&archive-history-set-del} /* p-action-type           */
          ,input  ""                         /* p-file-name             */
          ,input  ""                         /* p-file-md5              */
          ,input  0                          /* p-file-invalid-chip-num */
          ,input  ""                         /* p-source-type           */
          ,input  ""                         /* p-source-ref            */
          ,input  ?                          /* p-source-date           */
          ,output v-create-chip-num          /* p-create-chip-num       */
          ) .

        run invalidate-md5-signature in this-procedure
          (input  p-obj-type        /* p-obj-type     */
          ,input  p-obj-code        /* p-obj-code     */
          ,input  {&btpr-type-ahsp} /* p-archive-type */
          ,input  v-create-chip-num /* p-chip-num     */
          ) .

        run clntattr-write in this-procedure
          (input buf_clients.obj-type /* p-obj-type */
          ,input buf_clients.obj-code /* p-obj-code */
          ,input {&attr-ahsp-del}     /* p-code     */
          ,input true                 /* p-value    */
          ) .
      end.
    end.

    if p-calc-aht = true
    then do:
      /* признак того, что требуется расчет складского архива по типам приобретения */
      if p-mark-calc = true
      then do:
        run utl/arhiscr.p
          (input  p-obj-type                  /* p-obj-type              */
          ,input  p-obj-code                  /* p-obj-code              */
          ,input  {&btpr-type-aht}            /* p-archive-type          */
          ,input  {&archive-history-set-calc} /* p-action-type           */
          ,input  ""                          /* p-file-name             */
          ,input  ""                          /* p-file-md5              */
          ,input  0                           /* p-file-invalid-chip-num */
          ,input  ""                          /* p-source-type           */
          ,input  ""                          /* p-source-ref            */
          ,input  ?                           /* p-source-date           */
          ,output v-create-chip-num           /* p-create-chip-num       */
          ) .

        run clntattr-write in this-procedure
          (input buf_clients.obj-type /* p-obj-type */
          ,input buf_clients.obj-code /* p-obj-code */
          ,input {&attr-aht-calc}      /* p-code     */
          ,input true                 /* p-value    */
          ) .
      end.

      /* признак того, что требуется инициализация складского архива по типам приобретения */
      if p-mark-del = true
      then do:
        run utl/arhiscr.p
          (input  p-obj-type                 /* p-obj-type              */
          ,input  p-obj-code                 /* p-obj-code              */
          ,input  {&btpr-type-aht}           /* p-archive-type          */
          ,input  {&archive-history-set-del} /* p-action-type           */
          ,input  ""                         /* p-file-name             */
          ,input  ""                         /* p-file-md5              */
          ,input  0                          /* p-file-invalid-chip-num */
          ,input  ""                         /* p-source-type           */
          ,input  ""                         /* p-source-ref            */
          ,input  ?                          /* p-source-date           */
          ,output v-create-chip-num          /* p-create-chip-num       */
          ) .

        run invalidate-md5-signature in this-procedure
          (input  p-obj-type        /* p-obj-type     */
          ,input  p-obj-code        /* p-obj-code     */
          ,input  {&btpr-type-aht}  /* p-archive-type */
          ,input  v-create-chip-num /* p-chip-num     */
          ) .

        run clntattr-write in this-procedure
          (input buf_clients.obj-type /* p-obj-type */
          ,input buf_clients.obj-code /* p-obj-code */
          ,input {&attr-aht-del}      /* p-code     */
          ,input true                 /* p-value    */
          ) .
      end.
    end.

    assign
      v-total-process = v-total-process + 1
    .

  end.

end procedure. /* process-object */



procedure invalidate-md5-signature :

  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  define input  parameter p-chip-num     as integer   no-undo .

  define buffer buf_archive-history for ub.archive-history .

  do
  on error undo, return error return-value
  :
    for each buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
    on error undo, return error return-value
    :
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = p-chip-num
      .
    end.
  end.

end procedure. /* invalidate-md5-signature */