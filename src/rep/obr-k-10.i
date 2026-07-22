/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

&If "{1}" = "fe1" &then  /* по Производитель */
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
            run PutTitul in this-procedure .  /* вывод шапок */
            run PrintLine in this-procedure .     /* вывод данных            */
          run CalculSum in this-procedure (1) .  /* суммирование всего */
          if tog-obj = true then run CalculSum in this-procedure (2) .  /* суммирование по объекту */
          run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif


&If "{1}" = "fe2" &then  /* по группам  */
      if tog-tree = no then do: /* без дерева */
        if first-of(gds-prop.grp-name) then do:
          if tog-lavel = yes then do:
            assign
              lvel = num-entries( right-trim(gds-prop.grp-name, {&delim-grp}), {&delim-grp} )
            .
            if var-lavel < lvel then do:
              assign CurrGrpName = "" .
              do ii = 1 to var-lavel :
                assign CurrGrpName = CurrGrpName + entry ( ii, gds-prop.grp-name, {&delim-grp} )  + {&delim-grp} .
              end.
              if LastGroup <> CurrGrpName then do: /* новая подгруппа, надо показать и обнулить */
                if LastGroup <> "" then do:
                  assign ItogStr = "Итого по " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .  /* вывод сумм */
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                run Create-gds-sum in this-procedure (3) .
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итого по " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .  /* вывод сумм */
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              run Create-gds-sum in this-procedure (3) .
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            run Create-gds-sum in this-procedure (3) .
          end .
        End .
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
            run PutTitul in this-procedure .  /* вывод шапок */
            run PrintLine in this-procedure .     /* вывод данных            */
          run CalculSum in this-procedure (1) .  /* суммирование всего */
          if tog-obj = true then run CalculSum in this-procedure (2) .  /* суммирование по объекту */
          run CalculSum in this-procedure (3) .  /* суммирование  по группам */
        end.
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign
            ItogStr = "Итого по " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
      End.
      else do: /* дерево */
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, {&delim-grp}), {&delim-grp} )
          .
          assign CurrGrpName = "" .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, {&delim-grp} )  + {&delim-grp} .
            find first tt-grp-tree
              where tt-grp-tree.full = CurrGrpName
            no-error .
            if not available tt-grp-tree then LEAVE.
          end.

          do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.

          assign old-lvel = lvel .
          /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then do:
              assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, {&delim-grp} )  + {&delim-grp} .
            end.
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, {&delim-grp} )
              var-client = "Группа " + tt-grp-tree.name
            .
            run Create-gds-sum in this-procedure (tt-grp-tree.num) .
          end.
        end.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
            run PutTitul in this-procedure .  /* вывод шапок */
            run PrintLine in this-procedure .     /* вывод данных            */
          run CalculSum in this-procedure (1) .  /* суммирование всего */
          if tog-obj = true then run CalculSum in this-procedure (2) .  /* суммирование по объекту */
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .  /* суммирование  по группам */
          end.
        end.
      End.
&endif


&If "{1}" = "fe3" &then  /* Производитель + по группам  */
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
            run PutTitul in this-procedure .  /* вывод шапок */
            run PrintLine in this-procedure .     /* вывод данных            */
          run CalculSum in this-procedure (1) .  /* суммирование всего */
          if tog-obj = true then run CalculSum in this-procedure (2) .  /* суммирование по объекту */
          run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
          run CalculSum in this-procedure (4) .  /* суммирование  по произв-лю */
        end.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (4) .  /* вывод сумм */
        End.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif

&If "{1}" = "fe4" &then  /*  по группам + Производитель */
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
  
            run PutTitul in this-procedure .  /* вывод шапок */
            run PrintLine in this-procedure .     /* вывод данных            */

          run CalculSum in this-procedure (1) .  /* суммирование всего */
          if tog-obj = true then run CalculSum in this-procedure (2) .  /* суммирование по объекту */
          run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
          run CalculSum in this-procedure (4) .  /* суммирование  по произв-лю */
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (4) .  /* вывод сумм */
        End.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif

&If "{1}" = "fe5" &then  /*  НДС */
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */

            run PutTitul in this-procedure .  /* вывод шапок */
            run PrintLine in this-procedure .     /* вывод данных            */

          run CalculSum in this-procedure (1) .  /* суммирование всего */
          if tog-obj = true then run CalculSum in this-procedure (2) .  /* суммирование по объекту */
          run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
        end.
        if last-of(gds-prop.vat-pc) then do:
          assign
            ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"
          .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.

&endif

/* $Workfile$ e n d */