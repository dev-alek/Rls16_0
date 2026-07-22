block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docpartn.p $
$Archive: utl/docpartn.p $

Проверить и скорректировать неопределенные учетные цены в партиях

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical no-undo init no .

define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts    for ub.parts .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: docpartn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/docpartn.p $":U .
define variable vss-description as character no-undo initial "Проверить и скорректировать неопределенные учетные цены в партиях".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }


define stream sout .


do
on error undo, return error return-value
:

  define variable v-ok as logical   no-undo .
  message
    "Утилита проверки и коррекции учетных цен в партии" skip
    "Сейчас откроется список товаров" skip
    "Выберите товары, которые необходимо проверить и исправить" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .

  if v-ok <> true
  then do:
    return .
  end.
  { gbl/getcntxt.i get }
  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .

  for each gds-list
  on error undo, return error return-value
  :
    for each buf_parts exclusive-lock
      where buf_parts.artic     = gds-list.artic
        and buf_parts.prod-type = gds-list.prod-type
        and buf_parts.prod-code = gds-list.prod-code
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Проверка партий. Товар &1 &2 &3"
                          ,gds-list.artic
                          ,gds-list.prod-type
                          ,gds-list.prod-code
                         )
        ) .

      if buf_parts.road-tax-base = ?
      then do:
        output stream sout to docpartn.txt append .
        export stream sout gds-list.artic gds-list.prod-type gds-list.prod-code
          "fix road-tax-base" .
        export stream sout buf_parts .
        output stream sout close .

        assign
          buf_parts.road-tax-base = 0
        .
      end.

      if buf_parts.road-tax-rubl = ?
      then do:
        output stream sout to docpartn.txt append .
        export stream sout gds-list.artic gds-list.prod-type gds-list.prod-code
          "fix road-tax-rubl" .
        export stream sout buf_parts .
        output stream sout close .

        assign
          buf_parts.road-tax-rubl = 0
        .
      end.

      if buf_parts.transport-base = ?
      then do:
        output stream sout to docpartn.txt append .
        export stream sout gds-list.artic gds-list.prod-type gds-list.prod-code
          "fix transport-base" .
        export stream sout buf_parts .
        output stream sout close .

        assign
          buf_parts.transport-base = 0
        .
      end.

      if buf_parts.transport-rubl = ?
      then do:
        output stream sout to docpartn.txt append .
        export stream sout gds-list.artic gds-list.prod-type gds-list.prod-code
          "fix transport-rubl" .
        export stream sout buf_parts .
        output stream sout close .

        assign
          buf_parts.transport-rubl = 0
        .
      end.

      if buf_parts.other-base = ?
      then do:
        output stream sout to docpartn.txt append .
        export stream sout gds-list.artic gds-list.prod-type gds-list.prod-code
          "fix other-base" .
        export stream sout buf_parts .
        output stream sout close .

        assign
          buf_parts.other-base = 0
        .
      end.

      if buf_parts.other-rubl = ?
      then do:
        output stream sout to docpartn.txt append .
        export stream sout gds-list.artic gds-list.prod-type gds-list.prod-code
          "fix other-rubl" .
        export stream sout buf_parts .
        output stream sout close .

        assign
          buf_parts.other-rubl = 0
        .
      end.
    end.
  end.

end.