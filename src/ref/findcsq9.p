block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsq9.p $
$Archive: ref/findcsq9.p $

Список платажей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN "receiver-r-schet":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
                            AND X_fin-doc.receiver-r-schet = p-receiver-r-schet ~
                            "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
                            AND X_fin-doc.receiver-r-schet = &1&4&1 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-receiver-r-schet)  "

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.receiver-r-schet = p-receiver-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.receiver-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.cor-acc = &6 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-receiver-r-schet, p-curr-host-code, p-cor-acc)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.receiver-r-schet = p-receiver-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.receiver-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.cor-acc1 = &6 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-receiver-r-schet, p-curr-host-code, p-cor-acc1)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.receiver-r-schet = p-receiver-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.receiver-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.an-uchet-code = &6 ' ~
              , ~{&double-quote~}, p-receiver-type, p-receiver-code, p-curr-host-code, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.receiver-r-schet = p-receiver-r-schet ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.receiver-r-schet = &1&4&1 ~
              AND X_fin-doc.host-code = &5 AND X_fin-doc.cel-nazn-code = &6 ' ~
              ,~{&double-quote~}, p-receiver-type, p-receiver-code, p-receiver-r-schet, p-curr-host-code, p-cel-nazn-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN "receiver-schet":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code and X_fin-doc.receiver-code-schet = p-receiver-code-schet  "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 and X_fin-doc.receiver-code-schet = &2  ', p-curr-host-code, p-receiver-code-schet)"
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.receiver-code-schet = p-receiver-code-schet ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.receiver-code-schet = &2 ~
              AND X_fin-doc.cor-acc = &3 ', p-curr-host-code, p-receiver-code-schet, p-cor-acc)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.receiver-code-schet = p-receiver-code-schet ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.receiver-code-schet = &2 ~
              AND X_fin-doc.cor-acc1 = &3 ', p-curr-host-code, p-receiver-code-schet, p-cor-acc1)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.receiver-code-schet = p-receiver-code-schet ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.receiver-code-schet = &2 ~
              AND X_fin-doc.an-uchet-code = &3 ', p-curr-host-code, p-receiver-code-schet, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              and X_fin-doc.receiver-code-schet = p-receiver-code-schet ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.receiver-code-schet = &2 ~
              AND X_fin-doc.cel-nazn-code = &3 ', p-curr-host-code, p-receiver-code-schet, p-cel-nazn-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
  END CASE.


  end. /*doe*/

end procedure. /* proc-main */