/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки с признаками

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&If "{1}" = "fe1" &then  /* по Производитель */
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .     /* вывод данных            */
        if NullStr < 2 then run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"  .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif


&If "{1}" = "fe2" &then  /* по группам  */
      if tog-tree = no then do: /* без дерева */
        if first-of(gds-prop.grp-name) then do:
          if tog-lavel = yes then do:
            assign
/*              lvel = num-entries( gds-prop.grp-name, {&delim-grp} ) - 1*/
              lvel = num-entries( right-trim(gds-prop.grp-name, {&delim-grp}), {&delim-grp} )
            .
            if var-lavel < lvel then do:
              assign CurrGrpName = "" .
              do ii = 1 to var-lavel :
                assign CurrGrpName = CurrGrpName + entry ( ii, gds-prop.grp-name, {&delim-grp} )  + {&delim-grp} .
              end.
              if LastGroup <> CurrGrpName then do: /* новая подгруппа, надо показать и обнулить */
                if LastGroup <> "" then do:
                  assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .  /* вывод сумм */
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .  /* вывод сумм */
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
          end .
        End .
        run PrintLine in this-procedure .     /* вывод данных            */
        if NullStr < 2 then run CalculSum in this-procedure (3) .  /* суммирование  по группам */
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign ItogStr = "Итог по гр. " + gds-prop.grp-name + ":" .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
      End.
      else do: /* дерево */
        if first-of(gds-prop.grp-name) then do:
          assign
/*            lvel = num-entries( gds-prop.grp-name, {&delim-grp} ) - 1*/
            lvel = num-entries( right-trim(gds-prop.grp-name, {&delim-grp}), {&delim-grp} )
            CurrGrpName = ""
          .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, {&delim-grp} )  + {&delim-grp}  .
            find first tt-grp-tree where tt-grp-tree.full = CurrGrpName  no-error .
            if not available tt-grp-tree then LEAVE.
          end.

/*          do ij = ind to old-lvel : /* удаляем старые заголовки из списка */*/
          do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then run PutItogSum in this-procedure (tt-grp-tree.num) .  /* вывод сумм */
            delete tt-grp-tree .
          end.

          assign old-lvel = lvel .
          /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, {&delim-grp} )  + {&delim-grp}  .
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, {&delim-grp} )
              var-client = "Группа " + tt-grp-tree.name
            .
            for each temp-sum where temp-sum.level = tt-grp-tree.num : assign temp-sum.sum = 0 . end.
          end.
        end.
        run PrintLine in this-procedure .     /* вывод данных            */
        if NullStr < 2 then do:    /* проверка на не 0        */
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .  /* суммирование  по группам */
          end.
        end.
      End.
&endif


&If "{1}" = "fe3" &then  /* Производитель + по группам  */
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .     /* вывод данных            */
        if NullStr < 2 then do:    /* проверка на не 0        */
          run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
          run CalculSum in this-procedure (4) .  /* суммирование  по произв-лю */
        end.
        if last-of(gds-prop.grp-code) then do:
          assign ItogStr = "Итого по группе " + gds-prop.grp-name + ":"  .
          run PutItogSum in this-procedure (4) .  /* вывод сумм */
        End.
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":" .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif

&If "{1}" = "fe4" &then  /*  по группам + Производитель */
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .     /* вывод данных            */
        if NullStr < 2 then do:    /* проверка на не 0        */
          run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
          run CalculSum in this-procedure (4) .  /* суммирование  по произв-лю */
        end.
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":" .
          run PutItogSum in this-procedure (4) .  /* вывод сумм */
        End.
        if last-of(gds-prop.grp-code) then do:
          assign ItogStr = "Итого по группе " + gds-prop.grp-name + ":" .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif

&If "{1}" = "fe5" &then  /*  НДС */
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .     /* вывод данных            */
        if NullStr < 2 then run CalculSum in this-procedure (3) .  /* суммирование  по произв-лю */
        if last-of(gds-prop.vat-pc) then do:
          assign ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"  .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        End.
&endif

/* $Workfile$   E n d */