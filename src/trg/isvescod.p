block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка наличия у товара весовых кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter p-b-code like ub.bar-code.b-code no-undo.
define input parameter p-question-weight as logical no-undo .
define input parameter p-question-global as logical no-undo .
define input parameter p-question-on     as logical no-undo .
/*что хотим узнать  есть ли просто весовые или весовые глобальные или включенные */
define input parameter p-current-b-str like ub.prod-bc.b-str no-undo.
/*если хотим узнать есть ли кроме этого заданного*/

define output parameter p-answer as logical no-undo .
/*весовой есть*/

define output parameter p-on as logical no-undo .
/*есть статус вкл выкл*/

define output parameter p-b-str like ub.prod-bc.b-str no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка наличия у товара весовых кодов".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable l-prod-bc-global as logical no-undo .
define variable l-prod-bc-weight as logical no-undo .
DEFINE VARIABLE v-answer-global as logical no-undo init yes.
DEFINE VARIABLE v-answer-weight as logical no-undo init yes.
DEFINE VARIABLE v-answer-on     as logical no-undo init yes.
DEFINE VARIABLE v-found         as logical no-undo .
DEFINE VARIABLE v-found-b-str   like ub.prod-bc.b-str no-undo .
define buffer b-prod-bc for ub.prod-bc .

do
on error undo, return error
:
  _b-prod-bc:
  FOR EACH b-prod-bc where
          b-prod-bc.b-code = p-b-code no-LOCK:
    if p-current-b-str = b-prod-bc.b-str then NEXT _b-prod-bc.
    assign
    v-answer-global = yes
    v-answer-weight = yes
    v-answer-on     = yes
    .
    if p-question-global then do:
      { gbl/prodbcat.i
        b-prod-bc
        "'global=request':u"
        l-prod-bc-global
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" b-prod-bc.b-code skip
          "Дополнительный бар-код" b-prod-bc.b-str skip
          "Действие global=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end. /*p-question-global*/
    if p-question-weight then do:
      { gbl/prodbcat.i
        b-prod-bc
        "'weight=request':u"
        l-prod-bc-weight
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" b-prod-bc.b-code skip
          "Дополнительный бар-код" b-prod-bc.b-str skip
          "Действие weight=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end.
    if p-question-global and (NOT l-prod-bc-global) then do:
      v-answer-global = no.
    end.
    if p-question-weight and (NOT l-prod-bc-weight) then do:
      v-answer-weight = no.
    end.
    assign
    p-on = b-prod-bc.bc-on
    p-b-str = b-prod-bc.b-str
    .
    if p-question-on then do:
      assign
      v-answer-on = p-on
      .
    end.
    assign
    v-found = (if v-found = no then
              v-answer-global AND v-answer-weight
              else v-found)
    v-found-b-str = (if v-found-b-str = "":U
                     then b-prod-bc.b-str
                     else v-found-b-str
                     )
    p-answer = v-answer-global AND v-answer-weight AND v-answer-on.
    if p-answer then LEAVE. /*нашли удовл всем критериям*/
  END. /*for each b-prod-bc`*/
  /*хотели все-таки найти включенный но не нашли*/
  if (p-question-on and not p-answer)
  /*зато нашли тот который удовлетворял двум другим критериям*/
  AND v-found then do:
    assign
    p-answer = yes
    p-on = no
    p-b-str = v-found-b-str
    .
  end.
 end. /*doe*/