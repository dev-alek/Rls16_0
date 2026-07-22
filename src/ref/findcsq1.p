block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsq1.p $
$Archive: ref/findcsq1.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN {&all}        THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " TRUE "
              &use-ind    = "  "
              &by         = " use-index idoc-date " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cor-acc = &2 ', p-curr-host-code, p-cor-acc)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cor-acc1 = &2 ', p-curr-host-code, p-cor-acc1)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.an-uchet-code = &2 ', p-curr-host-code, p-an-uchet-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cel-nazn-code = &2 ', p-curr-host-code, p-cel-nazn-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN {&company} THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1', p-curr-host-code ) "
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cor-acc = &2 ', p-curr-host-code, p-cor-acc)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cor-acc1 = &2 ', p-curr-host-code, p-cor-acc1)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.an-uchet-code = &2 ', p-curr-host-code, p-an-uchet-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cel-nazn-code = &2 ', p-curr-host-code, p-cel-nazn-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN "currency":U THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.curr-code = p-curr-code  "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.curr-code = &2', p-curr-host-code, p-curr-code)"
              &use-ind    = " use-index idoc-date  "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.curr-code = p-curr-code ~
                              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.curr-code = &2 ~
                              AND X_fin-doc.cor-acc = &3', p-curr-host-code, p-curr-code, p-cor-acc) "

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.curr-code = p-curr-code ~
                              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.curr-code = &2 ~
                              AND X_fin-doc.cor-acc1 = &3 ', p-curr-host-code, p-curr-code, p-cor-acc1)"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
                              AND X_fin-doc.curr-code = p-curr-code ~
                              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
                              AND X_fin-doc.curr-code = &2 ~
                              AND X_fin-doc.an-uchet-code = &3 ', p-curr-host-code, p-curr-code, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
                            AND X_fin-doc.curr-code = p-curr-code ~
                            AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
                            AND X_fin-doc.curr-code = &2 ~
                            AND X_fin-doc.cel-nazn-code = &3', p-curr-host-code, p-curr-code, p-cel-nazn-code )"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
      END CASE.
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */