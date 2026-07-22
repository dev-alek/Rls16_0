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
procedure chkvatpc :
do
on error undo, return error return-value
:
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_parts    for ub.parts.
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = pardoc-code
    no-error
    .

  if not available buf_trn-doc then do:
    return error "Ошибка задания входных параметров" + {&new-line}
      + "Не найден документ с номером " + pardoc-code
      .
  end.

  if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
     buf_trn-doc.vat-type     = {&without-vat}     then do:
    for each buf_doc-line no-lock
         where buf_doc-line.doc-code =  buf_trn-doc.doc-code
    on error undo, return error return-value
    :
       if buf_doc-line.vat-pc <> 0 then do:
         return error
          "В строке документа " + buf_trn-doc.doc-code +
          " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
          " установлен НДС " + string(buf_doc-line.vat-pc) + ", отличный от 0." +
          " Установка НДС в данном документе с типом НДС - <без> недопустима.".
       end.
       for each buf_parts where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                buf_parts.obj-type  = buf_doc-line.obj-type  and
                                buf_parts.obj-code  = buf_doc-line.obj-code  and
                                buf_parts.artic     = buf_doc-line.artic     and
                                buf_parts.prod-type = buf_doc-line.prod-type and
                                buf_parts.prod-code = buf_doc-line.prod-code on error undo, return error return-value :
          if buf_parts.vat-pc <> 0 then do:
             return error
             "В строке документа " + buf_trn-doc.doc-code +
             " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
             " установлен НДС отличный от 0 в партии с кодом " + (buf_parts.part-code) + " . Это недопустимо для документа с типом НДС - без.".
          end.
       end.
    end.
  end.
end.
end procedure. /* chksltpc */
/* $Workfile$ e n d */