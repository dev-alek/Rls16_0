block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsq7.p $
$Archive: ref/findcsq7.p $

Список платежей  - открытие запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

{ ref/findcsqd.i }

  CASE p-mode :
    WHEN 'type-stat-date' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
                        AND X_fin-doc.status_  = p-status_ ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        AND X_fin-doc.fin-doc-type  = &2&3&2  ~
                        AND X_fin-doc.status_  = &2&4&2 ~
          AND (X_fin-doc.doc-date  >= &5  AND ~
          X_fin-doc.doc-date  <= &6)', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-status_, p-start-date, p-end-date ) ~
              "

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
              AND X_fin-doc.status_  = &2&4&2 ~
          AND (X_fin-doc.doc-date  >= &5  AND ~
          X_fin-doc.doc-date  <= &6)  ~
              AND X_fin-doc.cor-acc = &7 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-status_, p-start-date, p-end-date, p-cor-acc)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
              AND X_fin-doc.status_  = &2&4&2 ~
          AND (X_fin-doc.doc-date  >= &5  AND ~
          X_fin-doc.doc-date  <= &6)  ~
              AND X_fin-doc.cor-acc1 = &7 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-status_, p-start-date, p-end-date, p-cor-acc1)"
              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
              AND X_fin-doc.status_  = &2&4&2 ~
          AND (X_fin-doc.doc-date  >= &5  AND ~
          X_fin-doc.doc-date  <= &6)  ~
              AND X_fin-doc.an-uchet-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-status_, p-start-date, p-end-date, p-an-uchet-code)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
              AND X_fin-doc.status_  = &2&4&2 ~
          AND (X_fin-doc.doc-date  >= &5  AND ~
          X_fin-doc.doc-date  <= &6)  ~
              AND X_fin-doc.cel-nazn-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-status_ , p-start-date, p-end-date, p-cel-nazn-code)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN 'type-date' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1 ~
                        AND X_fin-doc.fin-doc-type  = &2&3&2  ~
          AND (X_fin-doc.doc-date  >= &4  AND ~
          X_fin-doc.doc-date  <= &5) ', p-curr-host-code , ~{&double-quote~}, p-fin-doc-type, p-start-date, p-end-date) "

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
          AND (X_fin-doc.doc-date  >= &4  AND ~
          X_fin-doc.doc-date  <= &5)  ~
              AND X_fin-doc.cor-acc = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-start-date, p-end-date, p-cor-acc)"

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
          AND (X_fin-doc.doc-date  >= &4  AND ~
          X_fin-doc.doc-date  <= &5)  ~
              AND X_fin-doc.cor-acc1 = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-start-date, p-end-date, p-cor-acc1) "

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
          AND (X_fin-doc.doc-date  >= &4  AND ~
          X_fin-doc.doc-date  <= &5)  ~
              AND X_fin-doc.an-uchet-code = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-start-date, p-end-date, p-an-uchet-code)"

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
          AND (X_fin-doc.doc-date  >= p-start-date  AND ~
          X_fin-doc.doc-date  <= p-end-date)  ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              AND X_fin-doc.fin-doc-type  = &2&3&2  ~
          AND (X_fin-doc.doc-date  >= &4  AND ~
          X_fin-doc.doc-date  <= &5)  ~
              AND X_fin-doc.cel-nazn-code = &6 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-start-date, p-end-date, p-cel-nazn-code)"

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
      END CASE.
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */