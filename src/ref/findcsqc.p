block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findcsqc.p $
$Archive: ref/findcsqc.p $

Список платежей  - открытие запроса объектыне моды

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/10
Author: Bakhtadze Natalya
Creation date: 03/24/10

*/

{ ref/findcsqd.i }
define variable v-mode as character no-undo .
v-mode = p-mode.
if p-fin-doc-type = "cash" then do:
  case p-mode:
    when 'type-object' then do:
      v-mode = 'type-object-cash'.
    end.
  end case.
end.

  CASE v-mode :
    WHEN 'type-object' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
                        AND X_fin-doc.obj-type  = p-obj-type  ~
                        AND X_fin-doc.obj-code  = p-obj-code  ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        and X_fin-doc.obj-type =  &2&3&2 ~
                        and X_fin-doc.obj-code =  &4    ~
                        AND X_fin-doc.fin-doc-type  = &2&5&2  ' ~
                        , p-curr-host-code,  ~{&double-quote~}, p-obj-type, p-obj-code,  p-fin-doc-type )"
              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.cor-acc = &6 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-fin-doc-type, p-cor-acc)"

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.cor-acc1 = &6 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-fin-doc-type, p-cor-acc1)"

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.an-uchet-code = &6 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-fin-doc-type, p-an-uchet-code)"

              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.cel-nazn-code = &6 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code,  p-fin-doc-type, p-cel-nazn-code)"
              &use-ind    = " use-index itype "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN 'type-object-cash' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.obj-type  = p-obj-type  ~
                        AND X_fin-doc.obj-code  = p-obj-code  ~
                        AND (X_fin-doc.fin-doc-type = {&income-cash} or X_fin-doc.fin-doc-type = {&expense-cash}) ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        and X_fin-doc.obj-type =  &2&3&2 ~
                        and X_fin-doc.obj-code =  &4    ~
                        AND (X_fin-doc.fin-doc-type = &2&5&2 or X_fin-doc.fin-doc-type = &2&6&2) ' ~
                        , p-curr-host-code,  ~{&double-quote~}, p-obj-type, p-obj-code, ~{&income-cash~}, ~{&expense-cash~} )"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND (X_fin-doc.fin-doc-type = {&income-cash} or X_fin-doc.fin-doc-type = {&expense-cash}) ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND (X_fin-doc.fin-doc-type = &2&5&2 or X_fin-doc.fin-doc-type = &2&6&2)  ~
              AND X_fin-doc.cor-acc = &6 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, ~{&income-cash~}, ~{&expense-cash~},  p-cor-acc )"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND (X_fin-doc.fin-doc-type = {&income-cash} or X_fin-doc.fin-doc-type = {&expense-cash}) ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND (X_fin-doc.fin-doc-type = &2&5&2 or X_fin-doc.fin-doc-type = &2&6&2)  ~
              AND X_fin-doc.cor-acc1 = &7 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, ~{&income-cash~}, ~{&expense-cash~}, p-cor-acc1)"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND (X_fin-doc.fin-doc-type = {&income-cash} or X_fin-doc.fin-doc-type = {&expense-cash}) ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND (X_fin-doc.fin-doc-type = &2&5&2 or X_fin-doc.fin-doc-type = &2&6&2)  ~
              AND X_fin-doc.an-uchet-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, ~{&income-cash~}, ~{&expense-cash~}, p-an-uchet-code)"

              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND (X_fin-doc.fin-doc-type = {&income-cash} or X_fin-doc.fin-doc-type = {&expense-cash}) ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND (X_fin-doc.fin-doc-type = &2&5&2 or X_fin-doc.fin-doc-type = &2&6&2)  ~
              AND X_fin-doc.cel-nazn-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, ~{&income-cash~}, ~{&expense-cash~}, p-cel-nazn-code)"
              &use-ind    = " use-index idoc-date "
              &by         = "  " }
        end.
      END CASE.
    END.
    WHEN 'type-stat-object' THEN DO:
      CASE p-list:
        when {&all} then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code  = p-curr-host-code  ~
                        AND X_fin-doc.obj-type  = p-obj-type  ~
                        AND X_fin-doc.obj-code  = p-obj-code  ~
                        AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
                        AND X_fin-doc.status_  = p-status_ ~
              "
              &dyn_where-cond = " substitute('X_fin-doc.host-code  = &1  ~
                        and X_fin-doc.obj-type =  &2&3&2 ~
                        and X_fin-doc.obj-code =  &4    ~
                        AND X_fin-doc.fin-doc-type  = &2&5&2  ~
                        AND X_fin-doc.status_  = &6 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-fin-doc-type, p-status_) "

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'cor-acc':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
              AND X_fin-doc.cor-acc = p-cor-acc "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.status_  = &2&6&2 ~
              AND X_fin-doc.cor-acc = &7 ', p-curr-host-code, ~{&double-quote~}, p-fin-doc-type, p-obj-type, p-obj-code, p-status_, p-cor-acc)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'cor-acc1':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
              AND X_fin-doc.cor-acc1 = p-cor-acc1 "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.status_  = &2&6&2 ~
              AND X_fin-doc.cor-acc1 = &7 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-fin-doc-type, p-status_, p-cor-acc1)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'an-uchet-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
              AND X_fin-doc.an-uchet-code = p-an-uchet-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.status_  = &2&6&2 ~
              AND X_fin-doc.an-uchet-code = &7 ', p-curr-host-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-fin-doc-type, p-status_, p-an-uchet-code)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
        when 'cel-nazn-code':U then do:
          { gbl/fltopend.i
              &where-cond = " X_fin-doc.host-code = p-curr-host-code ~
              AND X_fin-doc.obj-type  = p-obj-type  ~
              AND X_fin-doc.obj-code  = p-obj-code  ~
              AND X_fin-doc.fin-doc-type  = p-fin-doc-type  ~
              AND X_fin-doc.status_  = p-status_ ~
              AND X_fin-doc.cel-nazn-code = p-cel-nazn-code "
              &dyn_where-cond = " substitute('X_fin-doc.host-code = &1 ~
              and X_fin-doc.obj-type =  &2&3&2 ~
              and X_fin-doc.obj-code =  &4    ~
              AND X_fin-doc.fin-doc-type  = &2&5&2  ~
              AND X_fin-doc.status_  = &2&6&2 ~
              AND X_fin-doc.cel-nazn-code = &7 ', p-curr-host-code, p-fin-doc-type, p-obj-type, p-obj-code, p-status_, p-cel-nazn-code)"

              &use-ind    = " use-index itype-stat "
              &by         = "  " }
        end.
      END CASE.
    END.
END CASE.


  end. /*doe*/

end procedure. /* proc-main */