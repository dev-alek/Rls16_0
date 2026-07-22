block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: partsedt.p $
$Archive: str/partsedt.p $

Просмотр/редактирование партий строки документа

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/12/06


Параметры:
  l-update
     true  - партии можно редактировать
     false - партии можно только просматривать

  l-reserv
     true  - при редактировании партий происходит резервирование
     false - сделано для вызова из программы rsrv-dtl.p
             при редактировании партии не происходит резервирование
             за резервирование товара отвечает вызывающая программа

  p-chg-qnty - пользователь уже где-то ранее ввел необходомое количество
             это количество будет добавлено к количеству по документу
             для определения общего количества, на которое необходимо зарезервировать
             партии
             используется при подстановке правильного значени
             при создании новой партии в расходном документе при
             включенном параметре создание порожденных партий 'manual'

*/
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_doc-line for ub.doc-line .
define input parameter  l-update     as logical no-undo .
define input parameter  l-reserv     as logical no-undo .
define input parameter  p-chg-qnty   as decimal no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: partsedt.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/partsedt.p $":U .
def var vss-description as character no-undo init "Ручное редактирование партий строки документа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

if not available buf_doc-line then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Недоступна запись строка документа" skip
    view-as alert-box error .
  undo, return error .
end.

find first ub.goods no-lock
  where ub.goods.artic     = buf_doc-line.artic
    and ub.goods.prod-type = buf_doc-line.prod-type
    and ub.goods.prod-code = buf_doc-line.prod-code
  no-error .
if not available ub.goods then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Не найден товар" skip
    "Документ" buf_doc-line.doc-code skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    view-as alert-box error .
  undo, return error .
end.

define variable prt-rec as recid no-undo .

run str/parts-l.w
  (input parparentproc
  ,input buf_doc-line.obj-type     /* v-obj-type   */
  ,input buf_doc-line.obj-code     /* v-obj-code   */
  ,input ub.goods.gds-code         /* p-gds-code   */
  ,input buf_doc-line.doc-code     /* p-doc-code   */
  ,input  ( if l-update            /* p-edit-mode  */
            then {&add-def}
            else {&lookup}
          )
  ,input {&parts-l_parts-document} /* p-r-parts    */
    + (if l-reserv then "" else "," + {&parts-l_parts-no-reserv} )
    + (if p-chg-qnty = ? or p-chg-qnty = 0 then "" else "," + {&parts-l_parts-chg-qnty} + "=" + string(p-chg-qnty) )
  ,input {&parts-l_object-current} /* p-one-all    */
  ,input {&parts-l_call-document}  /* p-call-point */
  ,output prt-rec                  /* part-recid   */
  ) no-error .

define variable v-error-status-error as logical   no-undo .
assign
  v-error-status-error = error-status :error
.
if v-error-status-error then do:
  if  l-reserv = false
  and p-chg-qnty <> ?
  and p-chg-qnty <> 0
  then do:
    /* было запрошено создание партии */
    /* партия не была создана */
    undo, return error .
  end.
end.