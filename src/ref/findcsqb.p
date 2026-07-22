block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsqb.p $
$Archive: ref/findcsqb.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN {&g___object} THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code AND X_fin-doc.obj-type = p-obj-type AND X_fin-doc.obj-code = p-obj-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 AND X_fin-doc.obj-type = &2&3&2 AND X_fin-doc.obj-code = &4 ' ~
                                 ,p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc = p-cor-acc  AND X_fin-doc.obj-type = p-obj-type AND X_fin-doc.obj-code = p-obj-code"
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cor-acc = &2  AND X_fin-doc.obj-type = &3&4&3 AND X_fin-doc.obj-code = &5' ~
                                    , p-curr-host-code, p-cor-acc, ~{&double-quote~}, p-obj-type, p-obj-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cor-acc1 = p-cor-acc1  AND X_fin-doc.obj-type = p-obj-type AND X_fin-doc.obj-code = p-obj-code"
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cor-acc1 = &2  AND X_fin-doc.obj-type = &3&4&3 AND X_fin-doc.obj-code = &5' ~
                                   , p-curr-host-code, p-cor-acc1, ~{&double-quote~}, p-obj-type, p-obj-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.an-uchet-code = p-an-uchet-code  AND X_fin-doc.obj-type = p-obj-type AND X_fin-doc.obj-code = p-obj-code"
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.an-uchet-code = &2  AND X_fin-doc.obj-type = &3&4&3 AND X_fin-doc.obj-code = &5' ~
                                    ,p-curr-host-code, p-an-uchet-code, ~{&double-quote~}, p-obj-type, p-obj-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code AND X_fin-doc.cel-nazn-code = p-cel-nazn-code  AND X_fin-doc.obj-type = p-obj-type AND X_fin-doc.obj-code = p-obj-code"
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 AND X_fin-doc.cel-nazn-code = &2  AND X_fin-doc.obj-type = &3&4&3 AND X_fin-doc.obj-code = &5' ~
                                    , p-curr-host-code, p-cel-nazn-code, ~{&double-quote~}, p-obj-type, p-obj-code)"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
      END CASE.
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */