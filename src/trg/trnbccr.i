/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание бар-кодов партий

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure trnbccr :

  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .

  define variable vss-description as character no-undo init "trnbccr: Создание бар-кодов партий" .

  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_parts    for ub.parts .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .

  define variable v-root-node       as integer   no-undo .
  define variable l-create-bar-code as logical   no-undo .

  do
  on error undo, return error
  :

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if buf_trn-doc.status_ <> {&fact} then do:
      message
        vss-workfile vss-revision vss-description skip
        "Документ имеет статус отличный от статуса" {&fact} skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    for each buf_parts
      where buf_parts.out-code = buf_trn-doc.doc-code
        and buf_parts.in-code  = buf_parts.out-code
    on error undo, return error
    :

      { gbl/rootnode.i
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        v-root-node
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака" skip
          view-as alert-box error .
        undo, return error .
      end.

      { gbl/gdsobjat.i
        buf_parts.obj-type
        buf_parts.obj-code
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        "'create-bar-code=request':u"
        l-create-bar-code
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении признака товара на объекте" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Запрашиваемый атрибут" "cash-parts=request":u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if l-create-bar-code then do:
        define variable v-bar-code-is-new as logical no-undo .

        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .

        /* бар-код необходимо создать */
        /* проверяем, что разрешена генерация бар-кодов */
        { gbl/barcodcr.i
          buf_goods.gds-code
          v-root-node
          buf_parts.part-code
          buf_parts.in-code
          buf_goods.unit-base
          ?
          v-bar-code-is-new
          buf_bar-code
          no-error
        }
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании бар-кода партии" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

end procedure. /* trnbccr */


/* $Workfile$ e n d */