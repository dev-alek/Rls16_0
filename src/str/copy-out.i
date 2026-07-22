/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тело создания РН и ВН

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

&if "{1}" = "cr-doc-line" &then
      def var l-inv-on as logical no-undo .
      define variable v-clcdoc-host-code                  like sysconf.host-code         no-undo.
      define variable v-clcdoc-vat-pc                     like doc-line.vat-pc           no-undo.
      define variable v-clcdoc-slt-pc                     like doc-line.slt-pc           no-undo.
      { gbl/gdsobjat.i
         t-doc.obj-type
         t-doc.obj-code
         goods.artic
         goods.prod-type
         goods.prod-code
         "'inv-on=request'"
         l-inv-on
         no-error}
      if error-status:error then do:
        message
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return no-apply .
      end.
  if l-inv-on then do:
    &if "{2}" = "goods" &then
      { gbl/stopwork.i }
    &endif
    g#log = yes.
    message "Артикул :" goods.artic goods.gds-name "- товар в инвентаризации."
                    skip (2) "Добавление невозможно." skip (2)
                    "OK - пропустить товар, Cancel - отменить копирование"
                    view-as alert-box question buttons OK-Cancel update g#log.
    if g#log = true then next.
    else undo c-l, return error.
  end.
  find doc-line where doc-line.doc-code  =  t-doc.doc-code
                  and doc-line.artic     =  goods.artic
                  and doc-line.prod-code =  goods.prod-code
                  and doc-line.prod-type =  goods.prod-type no-error.
  if not available doc-line then do:
    create doc-line.
    assign
      doc-line.doc-code   = t-doc.doc-code
      doc-line.artic      = goods.artic
      doc-line.prod-code  = goods.prod-code
      doc-line.prod-type  = goods.prod-type
      doc-line.obj-code   = t-doc.obj-code
      doc-line.obj-type   = t-doc.obj-type
      doc-line.prt-OK     = yes
      doc-line.prt-root   = goods.prt-root.
      doc-line.doc-qnty   = 0.  /* инициализация партий */
      &if "{2}" = "ret-line" &then
      /*В случае копирования из внутреннего прихода, следует скопировать НДС
        из товара, так как его нет в накладной*/
      if {4}.doc-type = {&income} and {4}.internal then do:
         find ret-goods where ret-goods.artic     = ret-line.artic     and
                              ret-goods.prod-type = ret-line.prod-type and
                              ret-goods.prod-code = ret-line.prod-code no-lock.
         { gbl/hostcode.i ret-line.obj-type ret-line.obj-code v-clcdoc-host-code }
         { gbl/pftxvalg.i ret-goods.gds-code {&vat-tax-code} ? v-clcdoc-host-code ret-line.obj-type ret-line.obj-code v-clcdoc-vat-pc no-error }
         assign doc-line.vat-pc = v-clcdoc-vat-pc.
      end.
      else doc-line.VAT-pc  = ret-line.VAT-pc.
      &else
      { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-clcdoc-host-code }
      { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-clcdoc-host-code t-doc.obj-type t-doc.obj-code v-clcdoc-vat-pc no-error }
      assign doc-line.VAT-pc = v-clcdoc-vat-pc.
      &endif
      { str/st-sltpc.i
        recid(goods)
        recid(t-doc)
        g#cash-pay
        v-clcdoc-slt-pc
      }
      assign doc-line.slt-pc = v-clcdoc-slt-pc.
  end.
&endif