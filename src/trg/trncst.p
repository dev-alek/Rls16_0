block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Простановка кода ГТД во все партии приходной накладной

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Суслов Алексей Юрьевич
Дата создания: 04/04/06


TODO
передавать информацию в удаленную базу данных
что-то надо делать с информацией в пакетах новостей

*/

define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Простановка кода ГТД во все партии приходной накладной".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define variable v-is-hold       as logical   no-undo .
define variable v-orig-is-hold  as logical   no-undo .
define variable v-process-parts as logical   no-undo .
define variable v-cst-code      as character no-undo .
define variable v-in-code       as character no-undo .
define variable v-part-code     as character no-undo .

define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_parts      for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_parts-supp for ub.parts-supp .


main-block:
do
on error undo main-block, return error return-value
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.

  { gbl/hold-doc.i
    buf_trn-doc.doc-code
    v-is-hold
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении типа документа" skip
      "Документ" buf_trn-doc.doc-code skip
      "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  for each buf_parts no-lock
    where buf_parts.out-code = p-doc-code
  on error undo main-block, return error return-value
  :
    assign
      v-process-parts = false
    .

    if v-is-hold = false
    then do:
      /* для обычных внешний приходов берем ГТД из приходного документа */
      assign
        v-process-parts = true
        v-cst-code      = buf_trn-doc.cst-code
      .
    end.
    else do:
      /* для межфирменных приходов необходимо пройти по всем внешним приходам */
      /* до самого первого внешнего прихода */

      assign
        v-in-code   = buf_parts.in-code
        v-part-code = buf_parts.part-code
      .

      scan_cycle:
      do while true
      :
        find first buf_parts-supp share-lock
          where buf_parts-supp.in-code   = v-in-code
            and buf_parts-supp.artic     = buf_parts.artic
            and buf_parts-supp.prod-type = buf_parts.prod-type
            and buf_parts-supp.prod-code = buf_parts.prod-code
            and buf_parts-supp.part-code = v-part-code
          no-error .
        if available buf_parts-supp
        then do:
          assign
            v-in-code   = buf_parts-supp.orig-in-code
            v-part-code = buf_parts-supp.orig-part-code
          .

          { gbl/hold-doc.i
            v-in-code
            v-orig-is-hold
            no-error
          }
          if v-orig-is-hold = true
          then do:
            next scan_cycle . /* --->>>--- */
          end.
          else do:
            define variable v-gds-code as integer   no-undo .
            { gbl/gds-code.i
              buf_parts.artic
              buf_parts.prod-type
              buf_parts.prod-code
              v-gds-code
            }

            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = v-in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = v-part-code
              no-error .
            if available buf_parts-attr
            then do:
              assign
                v-process-parts = true
                v-cst-code      = buf_parts-attr.cst-code
              .
              leave scan_cycle .  /* --->>>--- */
            end.
          end.
        end.
        else do:
          leave scan_cycle .  /* --->>>--- */
        end.
      end.
    end.

    if v-process-parts = true
    then do:
      run trg/partcst.p
        (input v-cst-code           /* p-cst-code  */
        ,input buf_parts.in-code    /* p-in-code   */
        ,input buf_parts.artic      /* p-artic     */
        ,input buf_parts.prod-type  /* p-prod-type */
        ,input buf_parts.prod-code  /* p-prod-code */
        ,input buf_parts.part-code  /* p-part-code */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partcst.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end.