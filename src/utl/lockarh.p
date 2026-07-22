block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lockarh.p $
$Archive: utl/lockarh.p $

Программа блокировки ресурса по расчёту архивов для тестировани

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/05/04

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lockarh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/lockarh.p $":U .
define variable vss-description as character no-undo init "Программа блокировки ресурса по расчёту архивов для тестировани ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }


define variable v-host-code   as integer   no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as character no-undo .
define variable v-user-select as logical   no-undo .

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }


  { gbl/hostcode.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-host-code
  }

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-host-code
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран" skip
      view-as alert-box information .
    undo, return error "Объект не выбран" . /* --->>>--- */
  end.

  define variable v-num as integer   no-undo .

  run gbl/d-askw.w
    (input "Выбор типа архива" /* Заголовок окна */
    ,input "Выберите тип архива для блокировки" /* Общее сообщение */
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

  case v-num
  :
    when 1
    then do:
      define buffer calc-arh-lock_batchprocess for ub.batchprocess .

      run gbl/lock-prc.p
        (input  {&lock-prc-calc-arh}       /* p-process-key     */
        ,input  v-obj-code                 /* p-Key#_One        */
        ,input  0                          /* p-Key#_Two        */
        ,input  0                          /* p-Key#_Three      */
        ,input  v-obj-type                 /* p-CharKey_One     */
        ,input  ""                         /* p-CharKey_Two     */
        ,input  ""                         /* p-CharKey_Three   */
        ,input  "Объект,,, ,,,Расчет складского архива по товарам" /* p-key-descr-list  */
        ,input  true                       /* p-message-on      */
        ,buffer calc-arh-lock_batchprocess /* lock_batchprocess */
        ) .

      message
        "Расчет складского архива по товарам заблокирован" skip
        "Объект" v-obj-type v-obj-code skip
        view-as alert-box .
    end.
    when 2
    then do:
      define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

      run gbl/lock-prc.p
        (input  {&lock-prc-calc-supp-arh}       /* p-process-key     */
        ,input  v-obj-code                      /* p-Key#_One        */
        ,input  0                               /* p-Key#_Two        */
        ,input  0                               /* p-Key#_Three      */
        ,input  v-obj-type                      /* p-CharKey_One     */
        ,input  ""                              /* p-CharKey_Two     */
        ,input  ""                              /* p-CharKey_Three   */
        ,input  "Объект,,, ,,,Расчет складского архива по поставщикам" /* p-key-descr-list  */
        ,input  false                           /* p-message-on      */
        ,buffer calc-supp-arh-lock_batchprocess /* lock_batchprocess */
        ) .

      message
        "Расчет складского архива по поставщикам заблокирован" skip
        "Объект" v-obj-type v-obj-code skip
        view-as alert-box .
    end.
    when 3
    then do:
      define buffer calc-aht-lock_batchprocess for ub.batchprocess .

      run gbl/lock-prc.p
        (input  {&lock-prc-calc-aht}       /* p-process-key     */
        ,input  v-obj-code                 /* p-Key#_One        */
        ,input  0                          /* p-Key#_Two        */
        ,input  0                          /* p-Key#_Three      */
        ,input  v-obj-type                 /* p-CharKey_One     */
        ,input  ""                         /* p-CharKey_Two     */
        ,input  ""                         /* p-CharKey_Three   */
        ,input  "Объект,,, ,,,Расчет складского архива по типам приобретения" /* p-key-descr-list  */
        ,input  false                      /* p-message-on      */
        ,buffer calc-aht-lock_batchprocess /* lock_batchprocess */
        ) .

      message
        "Расчет складского архива по типам приобретения заблокирован" skip
        "Объект" v-obj-type v-obj-code skip
        view-as alert-box .
    end.
    when 4
    then do:
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестное значение переменной v-num" skip
        view-as alert-box error .
    end.
  end.
end.