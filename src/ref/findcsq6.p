block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsq6.p $
$Archive: ref/findcsq6.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN "payer":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ', ~{&double-quote~}, p-payer-type, p-payer-code) "
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
              AND X_fin-doc.host-code  = p-curr-host-code  ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
              AND X_fin-doc.host-code  = &4  ~
              AND X_fin-doc.cor-acc = &5 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-curr-host-code, p-cor-acc)"
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
              AND X_fin-doc.host-code  = p-curr-host-code  ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
              AND X_fin-doc.host-code  = &4  ~
              AND X_fin-doc.cor-acc1 = &5 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-curr-host-code, p-cor-acc1)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
                            AND X_fin-doc.host-code  = p-curr-host-code  ~
                            AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
                            AND X_fin-doc.host-code  = &4  ~
                            AND X_fin-doc.an-uchet-code = &5 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-curr-host-code, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
                            AND X_fin-doc.host-code  = p-curr-host-code  ~
                            AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
                            AND X_fin-doc.host-code  = &4  ~
                            AND X_fin-doc.cel-nazn-code = &5 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-curr-host-code, p-cel-nazn-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN "payer-schet":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code and X_fin-doc.payer-code-schet = p-payer-code-schet  "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 and X_fin-doc.payer-code-schet = &2 ', p-curr-host-code, p-payer-code-schet )"
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.payer-code-schet = p-payer-code-schet ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.payer-code-schet = &2 ~
              AND X_fin-doc.cor-acc = &3 ', p-curr-host-code, p-payer-code-schet, p-cor-acc)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.payer-code-schet = p-payer-code-schet ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.payer-code-schet = &2 ~
              AND X_fin-doc.cor-acc1 = &3 ', p-curr-host-code, p-payer-code-schet, p-cor-acc1)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.payer-code-schet = p-payer-code-schet ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.payer-code-schet = &2 ~
              AND X_fin-doc.an-uchet-code = &3 ', p-curr-host-code, p-payer-code-schet, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.payer-code-schet = p-payer-code-schet ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.payer-code-schet = &2 ~
              AND X_fin-doc.cel-nazn-code = &3 ', p-curr-host-code, p-payer-code-schet, p-cel-nazn-code )"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
  END CASE.


  end. /*doe*/

end procedure. /* proc-main */