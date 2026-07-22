block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsobjls.p $
$Archive: utl/gdsobjls.p $

Редактирование списка количества товара на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsobjls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gdsobjls.p $":U .
define variable vss-description as character no-undo init "Редактирование списка количества товара на объекте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ cmp/gds-list.i scn-list def "new shared" }

do
on error undo, return error
:

  define variable v-user-select as logical   no-undo .
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer   no-undo .
  { gbl/getcntxt.i get }

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.

  run str/scn-list.w
    (input parparentproc
    ,input v-cntxt-host-code-obj
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ) .

  define variable v-file-name as character no-undo .

  assign
    v-file-name = "imp-out.txt"
  .

  run gbl/d-prompt.w
    (input 'title=Создание файла импорта партий расходной зоны\'
    + 'text1=Введите имя файла импорта\'
    + 'text2=Выбранный файл будет перезаписан\'
    + 'format=x(40)\'
    + 'type=char\'
    + 'boxprog=getfile.p\'
    ,input-output v-file-name
    ).
  if return-value = "false":u then do:
    return . /* --->>>--- */
  end.

  define variable v-ind as integer   no-undo .

  output to value(v-file-name) .
  for each scn-list
    where scn-list.qnty > 0
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .

    export
      v-obj-type
      v-obj-code
      scn-list.artic
      scn-list.prod-type
      scn-list.prod-code
      scn-list.qnty
      .
  end.
  output close .

  message
    "Создание файла импорта успешно" skip
    "Создано строк в файле импорта" v-ind skip
    "Передайте файл ответсвенному за импорт расходной зоны" skip
    view-as alert-box information .

end.