/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка установки налога с продаж в строках документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
*/

procedure chksltpc :
  do
  on error undo, return error
  :
    define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

    define variable loc#cash-pay like ub.sysconf.cash-pay no-undo.

    define buffer buf_trn-doc  for ub.trn-doc.
    define buffer buf_sysconf  for ub.sysconf.
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_parts    for ub.parts.
    define buffer buf_store    for ub.store.
    define buffer buf_shop     for ub.shop.

    def var v-have-slt-pc   as logical                  no-undo.
    def var v-host-code     like ub.sysconf.host-code   no-undo .

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = pardoc-code
      no-error
      .

    if not available buf_trn-doc then do:
      return error "Ошибка задания входных параметров" + {&new-line}
        + "Не найден документ с номером " + pardoc-code
        .
    end.

    { gbl/hostcode.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      v-host-code
    }
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      .
    assign
      loc#cash-pay  = buf_sysconf.cash-pay
    .
    { str/st-sltyn.i
      recid(buf_trn-doc)
      loc#cash-pay
      v-have-slt-pc
    }
    if v-have-slt-pc = no then do:
        /*При возврате поставщику, если в партиях установлен этот же налог продаж,
          то это допустимо*/
       if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
          for each buf_doc-line no-lock
           where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          on error undo, return error
          :

            for each buf_parts where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                     buf_parts.obj-type  = buf_doc-line.obj-type  and
                                     buf_parts.obj-code  = buf_doc-line.obj-code  and
                                     buf_parts.artic     = buf_doc-line.artic     and
                                     buf_parts.prod-type = buf_doc-line.prod-type and
                                     buf_parts.prod-code = buf_doc-line.prod-code:
               if buf_parts.slt-pc <> buf_doc-line.slt-pc then do:
                  return error
                  "В строке документа возврата поставщику " + buf_trn-doc.doc-code +
                  " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
                  " установлен налог с продаж " + string(buf_doc-line.slt-pc) + ", отличный от налога с продаж " + string(buf_parts.slt-pc) + " в партии с кодом " + (buf_parts.part-code) + " .".
               end.
            end.
          end.
       end.
       else do:
         for each buf_doc-line no-lock
           where buf_doc-line.doc-code =  buf_trn-doc.doc-code
             and buf_doc-line.slt-pc   <> 0
         on error undo, return error
         :
            return error
             "В строке документа " + buf_trn-doc.doc-code +
             " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
             " установлен налог с продаж " + string(buf_doc-line.slt-pc) + ", отличный от 0." +
             " Установка налога с продаж в данном документе недопустима.".
         end.
      end.
    end.
  end.

end procedure. /* chksltpc */
/* $Workfile$ e n d */