block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsqa.p $
$Archive: ref/findcsqa.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN "payer-r-schet":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
                            AND X_fin-doc.payer-r-schet = p-payer-r-schet ~
                            "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
                            AND X_fin-doc.payer-r-schet = &1&4&1 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-payer-r-schet) "

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
              AND X_fin-doc.payer-r-schet = p-payer-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
              AND X_fin-doc.payer-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.cor-acc = &6 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-payer-r-schet, p-curr-host-code, p-cor-acc)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
              AND X_fin-doc.payer-r-schet = p-payer-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
              AND X_fin-doc.payer-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.an-uchet-code = &6 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-payer-r-schet, p-curr-host-code, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
              AND X_fin-doc.payer-r-schet = p-payer-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
              AND X_fin-doc.payer-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.cel-nazn-code = &6 ', ~{&double-quote~}, p-payer-type, p-payer-code, p-payer-r-schet, p-curr-host-code, p-cel-nazn-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN "payer-host":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.payer-type = p-payer-type AND X_fin-doc.payer-code = p-payer-code ~
              AND X_fin-doc.host-code  = p-curr-host-code  ~
                                          "
              &dyn_where-cond = " substitute('X_fin-doc.payer-type = &1&2&1 AND X_fin-doc.payer-code = &3 ~
              AND X_fin-doc.host-code  = &4  ', ~{&double-quote~}, p-payer-type, p-payer-code, p-curr-host-code)  "

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
              AND X_fin-doc.cor-acc = &5', ~{&double-quote~}, p-payer-type, p-payer-code, p-curr-host-code, p-cor-acc )"

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
  END CASE.


  end. /*doe*/

end procedure. /* proc-main */