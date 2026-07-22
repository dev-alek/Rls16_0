/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверяются или устанавливаются веса для таможенных накладных

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 04/12/06

Данная процедура должна вызываться до создания документов
на основании текущего документа внутренних перемещений (до  t r n d o c m v . p )

В таможне
для внутреннего прихода должны быть установлены
  кол-во мест и вес брутто товара в каждой строке
в остальных документах кол-во мест и вес брутто товара
  проставляться из последней линии по данному товару

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cust_prc :

  define parameter buffer buf_trn-doc  for ub.trn-doc  .
  define parameter buffer buf_doc-line for ub.doc-line .
  define input  parameter l-custvalue  as logical no-undo .

  def buffer l-d-l      for ub.doc-line.
  def buffer bf-parts   for ub.parts.
  define variable    lOK        as logical no-undo .

  define variable parnum-place  like ub.doc-line.num-place no-undo.
  define variable parwt-brutto  like ub.doc-line.wt-brutto no-undo.

  if l-custvalue then do:
    if  buf_trn-doc.doc-type = {&income}
    and buf_trn-doc.internal = no
    then do:
      /*Если в какой-нибудь партии по строке указан номер ГТД, то:
        1 - все партии данной строки должны содержать номер ГТД
        2 - необходимо указать число мест и вес товара в строке*/
      find first bf-parts where bf-parts.obj-type  = buf_trn-doc.obj-type   and
                                bf-parts.obj-code  = buf_trn-doc.obj-code   and
                                bf-parts.prod-type = buf_doc-line.prod-type and
                                bf-parts.prod-code = buf_doc-line.prod-code and
                                bf-parts.artic     = buf_doc-line.artic     and
                                bf-parts.out-code  = buf_trn-doc.doc-code   and
                                bf-parts.cst-code <> ?                      and
                                bf-parts.cst-code <> ""                     no-lock no-error.
      if available bf-parts then do:
         find first bf-parts where bf-parts.obj-type  = buf_trn-doc.obj-type   and
                                   bf-parts.obj-code  = buf_trn-doc.obj-code   and
                                   bf-parts.prod-type = buf_doc-line.prod-type and
                                   bf-parts.prod-code = buf_doc-line.prod-code and
                                   bf-parts.artic     = buf_doc-line.artic     and
                                   bf-parts.out-code  = buf_trn-doc.doc-code   and
                                   (bf-parts.cst-code = ? or bf-parts.cst-code = "") no-lock no-error.
         if available bf-parts then do:
            message
             "Не определен номер ГТД в партии товара" skip
             "Документ" buf_trn-doc.doc-code skip
             "Артикул"  buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
             "Код партии" bf-parts.part-code skip
             view-as alert-box error .
           undo, return error return-value .
         end.
         if buf_doc-line.num-place = 0
         or buf_doc-line.num-place = ?
         then do:
           message
             "Не задано количество мест товара" skip
             "Документ" buf_trn-doc.doc-code skip
             "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
             view-as alert-box error .
           undo, return error return-value .
         end.
         if buf_doc-line.wt-brutto = 0
         or buf_doc-line.wt-brutto = ?
         then do:
           message
             "Не заведен вес брутто товара" skip
             "Документ" buf_trn-doc.doc-code skip
             "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
             view-as alert-box error .
           undo, return error return-value .
         end.
      end.
    end.
    else do:
      if  buf_trn-doc.doc-type <> {&inventory}
      and (   buf_doc-line.wt-brutto = 0
          or buf_doc-line.wt-brutto = ?
          or buf_doc-line.num-place = 0
          or buf_doc-line.num-place = ?)
      then do: /*Берем из последней линии*/
        find last l-d-l no-lock
          where l-d-l.artic     = buf_doc-line.artic
            and l-d-l.prod-type = buf_doc-line.prod-type
            and l-d-l.prod-code = buf_doc-line.prod-code
            and l-d-l.obj-type  = buf_doc-line.obj-type
            and l-d-l.obj-code  = buf_doc-line.obj-code
            and l-d-l.status_   = {&fact}
            and l-d-l.num-place <> 0
            and l-d-l.num-place <> ?
            and l-d-l.wt-brutto <> 0
            and l-d-l.wt-brutto <> ?
            and recid(l-d-l)    <> recid(buf_doc-line)
          use-index fact-order
          no-error.
        if not available l-d-l then do:
          assign
            lOK = no
          .
          message
            "Не найдено ни одного веса товара:" buf_doc-line.artic " на объекте." skip
            "Будете задавать вручную?" skip
            view-as alert-box question buttons yes-no update lok.
          if lOK = yes then do:
            run str/set-wt.w
              (input  buf_doc-line.artic
              ,input  buf_doc-line.prod-type
              ,input  buf_doc-line.prod-code
              ,output parnum-place
              ,output parwt-brutto
              ) no-error.
            if error-status :error
            or parnum-place = 0
            or parnum-place = ?
            or parwt-brutto = 0
            or parwt-brutto = ?
            then do:
              message "Без указания веса и кол-ва мест нельзя закрыть накладную."
                view-as alert-box error buttons ok.
              undo, return error return-value .
            end.
            else do:
              do transaction
              on error undo, return error return-value
              :
                assign
                  buf_doc-line.num-place = parnum-place
                  buf_doc-line.wt-brutto = parwt-brutto
                .
              end.
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
        else do:
          do transaction
          on error undo, return error return-value
          :
            assign
              buf_doc-line.num-place = l-d-l.num-place * buf_doc-line.fact-qnty / l-d-l.fact-qnty
              buf_doc-line.wt-brutto = l-d-l.wt-brutto * buf_doc-line.fact-qnty / l-d-l.fact-qnty
            .
          end.
        end.
      end.
    end.
  end.
  else do:
    if buf_doc-line.num-place <> 0
    or buf_doc-line.wt-brutto <> 0
    then do:
      do transaction
      on error undo, return error return-value
      :
        assign
          buf_doc-line.num-place = 0
          buf_doc-line.wt-brutto = 0
        .
      end.
    end.
  end.


end procedure. /* cust_prc */
/* $Workfile$ e n d */