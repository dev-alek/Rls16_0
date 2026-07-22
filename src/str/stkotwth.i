/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет остатков мат. ценностей на объектах и местах хранения.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

{1} - буффер куда пишем
{2} - откуда берем прошлые остатки
{3} - буфер линии документа
{4} - суффикс полей

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*Определяем приход это или инкассация*/
if lookup (bf_wth-doc.ext-doc-type, {&WDEDT_List-Income}) > 0   OR
   (bf_wth-doc.ext-doc-type = {&WDEDT_Inv} AND {3}fact-sum > 0) or
   lookup (bf_wth-doc.ext-doc-type, {&WDEDT_List-Return}) > 0   or
   (bf_wth-doc.ext-doc-type = {&WDEDT_Exch} ) then do:
       if bf_wth-doc.ext-doc-type = {&WDEDT_Inv} and bf_wth-doc.doc-code begins '1-' then do:
            assign 
              {1}income{4}       = {2}income{4} +  {3}aft-sum
              {1}income-other{4} = {2}income-other{4} + {3}aft-sum
              {1}income-cassa{4} = 0.
             
              end.
       else do:
           assign
           {1}income{4}       = {2}income{4} + {3}fact-sum.
           if bf_wth-doc.ext-doc-type = {&WDEDT_Cas_Inc} then
           assign
              {1}income-cassa{4} = {2}income-cassa{4} + {3}fact-sum
              {1}income-other{4} = {2}income-other{4}.
           else
           assign
              {1}income-other{4} = {2}income-other{4} + {3}fact-sum
              {1}income-cassa{4} = {2}income-cassa{4}.
      end.
   assign {1}incass{4}       = {2}incass{4}
          {1}incass-bank{4}  = {2}incass-bank{4}
          {1}incass-other{4} = {2}incass-other{4}
          {1}incass-cassa{4} = {2}incass-cassa{4}.
end.
else do:
    if lookup (bf_wth-doc.ext-doc-type, {&WDEDT_List-expense}) > 0 OR  lookup (bf_wth-doc.ext-doc-type,{&WDEDT_List-Write-Off}) > 0
        or (bf_wth-doc.ext-doc-type = {&WDEDT_Inv} AND {3}fact-sum <= 0)
        and bf_wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli} then do:
        if bf_wth-doc.ext-doc-type = {&WDEDT_Inv} then do:

            if bf_wth-doc.doc-code begins '1-' then do:
            assign 
              {1}incass{4}       = {2}incass{4}       - {3}aft-sum
              {1}incass-other{4} = {2}incass-other{4} - {3}aft-sum
              {1}incass-cassa{4} = 0
              {1}incass-bank{4}  = 0.
          
              end.
         else 
             assign
              {1}incass{4}       = {2}incass{4}       - {3}fact-sum
              {1}incass-other{4} = {2}incass-other{4} - {3}fact-sum
              {1}incass-cassa{4} = {2}incass-cassa{4}
              {1}incass-bank{4}  = {2}incass-bank{4}.
        end.
        else do:
           assign
              {1}incass{4}       = {2}incass{4} + {3}fact-sum.
           if bf_wth-doc.ext-doc-type = {&WDEDT_Cas_Exp} then do:
              assign {1}incass-other{4} = {2}incass-other{4}
                     {1}incass-bank{4}  = {2}incass-bank{4}
                     {1}incass-cassa{4} = {2}incass-cassa{4} + {3}fact-sum
                     .
           end. /*возвраты по кассе*/
           else do:
            find first bf_clients where bf_clients.obj-type = bf_wth-doc.cli-type and
                                        bf_clients.obj-code = bf_wth-doc.cli-code no-lock.
            run  clntattr-value(input bf_clients.obj-type,
                                input bf_clients.obj-code,
                                input {&attr-is-inkassator},
                                output varattr-value,
                                output varattr-type) no-error.
            if varattr-value = "yes":U then do:
                assign {1}incass-bank{4}  = {2}incass-bank{4} + {3}fact-sum
                      {1}incass-other{4} = {2}incass-other{4}
                      {1}incass-cassa{4} = {2}incass-cassa{4}
                      .
            end.
            else do:
                assign {1}incass-other{4} = {2}incass-other{4} + {3}fact-sum
                      {1}incass-bank{4}  = {2}incass-bank{4}
                      {1}incass-cassa{4}  = {2}incass-cassa{4}
                      .
            end.
          end. /*не возврат по кассе*/
        end. /*не инвентаризация*/
        assign {1}income{4}       = {2}income{4}
               {1}income-cassa{4} = {2}income-cassa{4}
               {1}income-other{4} = {2}income-other{4}
               .
    end.
    else if bf_wth-doc.ext-doc-type = {&WDEDT_Dst_Cli} then.
    else return error "Неверный расширенный тип "  + bf_wth-doc.ext-doc-type + " у документа с номером " + bf_wth-doc.doc-code.
end.
/* $Workfile$ e n d */
