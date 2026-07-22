block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: objatrcr.p $
$Archive: utl/objatrcr.p $

Создание атрибутов партий по всем документам объекта

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: objatrcr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/objatrcr.p $":U .
define variable vss-description as character no-undo initial "Создание атрибутов партий по всем документам объекта".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }

define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_doc-line   for ub.doc-line .
define buffer buf_parts      for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .
define buffer new_parts-attr for ub.parts-attr .

do
on error undo, return error return-value
:
  /* обрабатываем закрытые документы */
  for each buf_trn-doc share-lock
    where buf_trn-doc.obj-type = p-obj-type
      and buf_trn-doc.obj-code = p-obj-code
      and buf_trn-doc.status_  = {&fact}
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Создание атрибутов партий. Объект &1 &2. Документ &3."
             ,buf_trn-doc.obj-type
             ,buf_trn-doc.obj-code
             ,buf_trn-doc.doc-code
             )
      ) .
    run trg/prtatrcr.p
      (input buf_trn-doc.doc-code /* p-doc-code   */
      ,input true                 /* p-create-all */
      ) no-error .
    if error-status :error
    then do:
      { gbl/file-wr.i
        "'objatrcr.err':u"
        "buf_trn-doc.doc-code + {&new-line} "
      }
    end.

    /* отдельно обрабатываем ювелирные изделия */
    for each buf_doc-line
      where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      define variable v-gds-code as integer   no-undo .
      { gbl/doclicod.i
        recid(buf_doc-line)
        v-gds-code
      }

      define variable v-goods-twounit as logical   no-undo .
      { gbl/gdscdat.i
        v-gds-code
        "'twounit=request':u"
        v-goods-twounit
        no-error
      }
      if error-status :error then do:
        message
          "Ошибка при определении атрибута товара" skip
          "Код товара" v-gds-code skip
          'twounit=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if v-goods-twounit = true
      then do:

        for each buf_parts
          where buf_parts.out-code = buf_doc-line.doc-code
            and buf_parts.obj-type = buf_doc-line.obj-type
            and buf_parts.obj-code = buf_doc-line.obj-code
            and buf_parts.artic    = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
        on error undo, return error return-value
        :
          define variable v-orig-part-code as character no-undo .

          if v-goods-twounit = true
          then do:
            assign
              v-orig-part-code = entry(1, buf_parts.part-code, {&part-split})
            .
          end.

          find first new_parts-attr
            where new_parts-attr.in-code   = buf_parts.in-code
              and new_parts-attr.gds-code  = v-gds-code
              and new_parts-attr.part-code = buf_parts.part-code
            no-error .
          if not available new_parts-attr
          then do:
            find first buf_parts-attr
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = v-orig-part-code
              no-error .
            if available buf_parts-attr
            then do:
              create new_parts-attr .
              buffer-copy buf_parts-attr to new_parts-attr
              assign
                new_parts-attr.in-code        = buf_parts.in-code
                new_parts-attr.gds-code       = v-gds-code
                new_parts-attr.part-code      = buf_parts.part-code
                new_parts-attr.orig-in-code   = buf_parts-attr.in-code
                new_parts-attr.orig-gds-code  = buf_parts-attr.gds-code
                new_parts-attr.orig-part-code = buf_parts-attr.part-code
              .
            end.
          end.
        end.
      end.
    end.
  end.


  /* обрабатываем партии свободной зоны */
  for each buf_parts
    where buf_parts.obj-type = p-obj-type
      and buf_parts.obj-code = p-obj-code
      and buf_parts.out-code = {&free-code}
  on error undo, return error return-value
  :
    { gbl/pargocod.i
      recid(buf_parts)
      v-gds-code
    }

    { gbl/gdscdat.i
      v-gds-code
      "'twounit=request':u"
      v-goods-twounit
      no-error
    }
    if error-status :error then do:
      message
        "Ошибка при определении атрибута товара" skip
        "Код товара" v-gds-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-goods-twounit = true
    then do:
      assign
        v-orig-part-code = entry(1, buf_parts.part-code, {&part-split})
      .

      find first new_parts-attr
        where new_parts-attr.in-code   = buf_parts.in-code
          and new_parts-attr.gds-code  = v-gds-code
          and new_parts-attr.part-code = buf_parts.part-code
        no-error .
      if not available new_parts-attr
      then do:
        find first buf_parts-attr
          where buf_parts-attr.in-code   = buf_parts.in-code
            and buf_parts-attr.gds-code  = v-gds-code
            and buf_parts-attr.part-code = v-orig-part-code
          no-error .
        if available buf_parts-attr
        then do:
          create new_parts-attr .
          buffer-copy buf_parts-attr to new_parts-attr
          assign
            new_parts-attr.in-code        = buf_parts.in-code
            new_parts-attr.gds-code       = v-gds-code
            new_parts-attr.part-code      = buf_parts.part-code
            new_parts-attr.orig-in-code   = buf_parts-attr.in-code
            new_parts-attr.orig-gds-code  = buf_parts-attr.gds-code
            new_parts-attr.orig-part-code = buf_parts-attr.part-code
          .
        end.
      end.
    end.
  end.
end.