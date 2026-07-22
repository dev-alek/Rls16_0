/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заголовки в оборотках

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/27/01
*/

{ gbl/gdsbcode.i gds-zap-b-code ? v-bar-code  }
s-bar-code = string (v-bar-code,"999999999").
/*-----------------------------------------------------------------------------------------------------------------------*/
/* ШАПКИ */
/*-----------------------------------------------------------------------------------------------------------------------*/
&if "{&par1}" = "" &Then
    If  break_group = true  and par-3 <> "1"  then DO :
         FIND FIRST clients WHERE clients.obj-type = gds-zap-prod-type AND clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
         gds-zap-prod-name  = clients.obj-name.

          If break_group1 = true  THEN  DO :
            if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.
            if par-3 = "6"  then  dO:
               if xTog-obj = true then do:

                 var-vat-pc = func-vat (input gds-zap-b-code , input x-store-type, input x-store-code)
                  .
                end.
               else do:
                var-vat-pc = temp-gds-list.vat-pc .
                end.

                assign
                    temp-str = string( "СТАВКА НДС : " + string(var-vat-pc) + "%" )
                    b1-name = temp-str.
                end.


            if NOT xSumsOnly or (par-3 = "4" Or par-3 = "5" ) THEN DO :

                fr0 = true .
                tmp#stroka0 = temp-str.
            End.
          End.

            IF (par-3 = "4"  OR  par-3 = "5")  THEN DO:
              if par-3 = "4"
                then Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name .
                else Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name.

              if NOT xSumsOnly THEN DO:
                  fr = true .
              End.

              break_group1 = false.
            END.
       break_group = false.
    End.
&endif
&if "{&par1}" = "1" &Then  /* оборотка в excel */
    If  break_group = true  and par-3 <> "1"  then DO :
         FIND FIRST clients WHERE clients.obj-type = gds-zap-prod-type AND clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
         gds-zap-prod-name  = clients.obj-name.

          If break_group1 = true  THEN  DO :
            if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.
            if par-3 = "6"  then  dO:
               if xTog-obj = true then do:
                var-vat-pc = {&break-vat} .
                end.
               else do:
                var-vat-pc = temp-gds-list.vat-pc  .
                end.

                assign
                    temp-str = string( "СТАВКА НДС : " + string(var-vat-pc) + "%" )
                    b1-name = temp-str .
                end.

            if NOT xSumsOnly or (par-3 = "4" Or par-3 = "5" ) THEN DO :
                fr0 = true .
                tmp#stroka0 = temp-str.
            End .
          End .

          IF (par-3 = "4"  OR  par-3 = "5")  THEN DO :
            if par-3 = "4"
              then Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name  .
              else Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name .

            if NOT xSumsOnly THEN DO :
            fr = true .
            End.
            break_group1 = false.
          END.
       break_group = false.
    End.
&endif
/* $Workfile$ e n d */