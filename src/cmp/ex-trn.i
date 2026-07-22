/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка документа для списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ex-doc :
DEFINE INPUT PARAMETER loc-is-trn-doc as integer no-undo.
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .

  if line-mode = {&deletion} or line-mode = {&leave} then do:
    CASE loc-is-trn-doc:
      when 1 then do:
        if ub.trn-doc.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.trn-doc.doc-code
             and  {1}.doc-type = ub.trn-doc.doc-type
                  no-error.
      end.
      when 101 then do:
        if ub.c-trn-doc.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.c-trn-doc.doc-code
             and  {1}.doc-type = "-" + ub.c-trn-doc.doc-type
                  no-error.
      end.
      when 0 then do:
        if ub.price-doc.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.price-doc.doc-num
             and  {1}.doc-type = {&overvalue}
                  no-error.
      end.
      when 2 then do:
        if ub.inkas.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.inkas.inkas-code
             and  {1}.doc-type = {&cash-desk}
                  no-error.
      end.
      when 102 then do:
        if ub.c-inkas.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.c-inkas.inkas-code
             and  {1}.doc-type = "-" + {&cash-desk}
                  no-error.
      end.
      when 3 then do:
        if ub.fbr-doc.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.fbr-doc.doc-code
             and  {1}.doc-type = {&manufacturing}
                  no-error.
      end.
      when 4 then do:
        message
        ub.ord-doc.host-code <> p-curr-host-code
        view-as alert-box .
        if ub.ord-doc.host-code <> p-curr-host-code then return.
        find first {1} where
                  {1}.doc-code = ub.ord-doc.doc-code
             and  {1}.doc-type = ub.ord-doc.doc-type
                  no-error.

      end.
    end CASE.
    if available {1} then do:
      if line-mode = {&deletion} then do:
         lns-cnt = lns-cnt + 1.
         delete {1}.
      end.
      if line-mode = {&leave} then do:
        if {1}.to-del = ? then .
        else do:
          lns-cnt = lns-cnt + 1.
          {1}.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = {&add-def}
    then do:
      /* новые элементы всегда добавляем в конец */
      define variable v-sel-order as integer   no-undo .
      define buffer buf_sel_order_{1} for {1} .
      find last buf_sel_order_{1}
        use-index sel-order
        no-error .
      if available buf_sel_order_{1}
      then do:
        assign
          v-sel-order = buf_sel_order_{1}.sel-order + 1
        .
      end.
      else do:
        assign
          v-sel-order = 1
        .
      end.
      CASE loc-is-trn-doc:
        when 1 then do:
          { cmp/doc-list.i {1} assign-trn ub.trn-doc v-sel-order one-host }
        end.
        when 101 then do:
          { cmp/doc-list.i {1} assign-c-trn ub.c-trn-doc v-sel-order one-host }
        end.
        when 0 then do:
          { cmp/doc-list.i {1} assign-price-doc ub.price-doc v-sel-order one-host }
        end.
        when 2 then do:
          { cmp/doc-list.i {1} assign-inkas ub.inkas v-sel-order one-host }
        end.
        when 102 then do:
          { cmp/doc-list.i {1} assign-c-inkas ub.c-inkas v-sel-order one-host }
        end.
        when 3 then do:
          { cmp/doc-list.i {1} assign-fbr-doc ub.fbr-doc v-sel-order one-host }
        end.
        when 4 then do:
          { cmp/doc-list.i {1} assign-ord-doc ub.ord-doc v-sel-order one-host }
        end.
      END CASE.
    end.
  &if "{2}" <> "abc" &then
  if lns-cnt modulo 25 = 0 then
  &endif
  display
   "Ждите..." + string (lns-cnt) @ dsp-rs
   with frame {2}.

end PROCEDURE.


/* $Workfile$ e n d */