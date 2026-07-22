block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsq5.p $
$Archive: ref/findcsq5.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN "receiver-host":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code AND X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 AND X_fin-doc.receiver-type = &2&3&2 AND X_fin-doc.receiver-code = &4 ' ~
                                 ,p-curr-host-code, ~{&double-quote~}, p-receiver-type, p-receiver-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code ~
              AND X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 ~
              AND X_fin-doc.receiver-type = &2&3&2 AND X_fin-doc.receiver-code = &4 ~
              AND X_fin-doc.cor-acc = &5 ', p-curr-host-code, ~{&double-quote~}, p-receiver-type, p-receiver-code, p-cor-acc)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code ~
              AND X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 ~
              AND X_fin-doc.receiver-type = &2&3&2 AND X_fin-doc.receiver-code = &4 ~
              AND X_fin-doc.cor-acc1 = &5 ', p-curr-host-code, ~{&double-quote~}, p-receiver-type, p-receiver-code, p-cor-acc1)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code ~
              AND X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 ~
              AND X_fin-doc.receiver-type = &2&3&2 AND X_fin-doc.receiver-code = &4 ~
              AND X_fin-doc.an-uchet-code = &5 ', p-curr-host-code, ~{&double-quote~}, p-receiver-type, p-receiver-code, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code ~
              AND X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 ~
              AND X_fin-doc.receiver-type = &2&3&2 AND X_fin-doc.receiver-code = &4 ~
              AND X_fin-doc.cel-nazn-code = &5 ', p-curr-host-code, ~{&double-quote~}, p-receiver-type, p-receiver-code, p-cel-nazn-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN "receiver":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ', ~{&double-quote~}, p-receiver-type, p-receiver-code)"
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.host-code = &4 AND X_fin-doc.cor-acc = &5 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-curr-host-code, p-cor-acc)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.host-code = &4 AND X_fin-doc.cor-acc1 = &5 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-curr-host-code, p-cor-acc1)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.host-code = &4 AND X_fin-doc.an-uchet-code = &5 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-curr-host-code, p-an-uchet-code )"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.receiver-type = p-receiver-type AND X_fin-doc.receiver-code = p-receiver-code ~
              AND X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.receiver-type = &1&2&1 AND X_fin-doc.receiver-code = &3 ~
              AND X_fin-doc.host-code = &4 AND X_fin-doc.cel-nazn-code = &5 ', ~{&double-quote~}, p-receiver-type, p-receiver-code, p-curr-host-code, p-cel-nazn-code)"

              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
      END CASE.
    END.
  END CASE.


  end. /*doe*/

end procedure. /* proc-main */