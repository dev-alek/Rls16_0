/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$
Состояние запаса

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/27/01
*/
  assign
      gds-zap-unit-base  = {4}.unit-base
      gds-zap-prt-root   = {4}.prt-root
      gds-zap-prod-type  = {4}.prod-type
      gds-zap-prod-code  = {4}.prod-code
      gds-zap-artic      = {4}.artic
      gds-zap-grp-name   = {4}.grp-name
      gds-zap-b-code     = {4}.gds-code
      gds-zap-prod-name  = b-clients.obj-name
      gds-zap-gds-name   = if g#gds-engl then {4}.engl-name else {4}.gds-name
  .
  
      gds-zap-gds-long-name = substring(
                (if {4}.engl-name <> ? then trim({4}.engl-name) else "" ) +
                (if {4}.label-name <> ? then trim({4}.label-name) else "" ),1,120 ) .

if Parts-Det then do :
  if zap-date < today then do:
    run partslib-init-temp-parts-by-factord in this-procedure( input gds-obj.obj-type, input gds-obj.obj-code, input gds-obj.artic, input gds-obj.prod-type, input gds-obj.prod-code, input v-fact-order-end, input false ) .
  end.
  else do: /* на сегодня */
    run partslib-init-temp-parts in this-procedure( input gds-obj.obj-type, input gds-obj.obj-code, input gds-obj.artic, input gds-obj.prod-type, input gds-obj.prod-code ) .
  end.
end.
     run foreach. /* подсчет */

&if "{1}" <>  "1" &then    /* если есть классиф */
if first-of({1}) then do:
        tmp#stroka = (if string(entry(2,"{1}",".")) <> "grp-name":u then "произв." + gds-zap-prod-name else "группа " + gds-zap-grp-name).
        tmp#stroka0 = tmp#stroka.
        fr0 = true .
end.
&endif
&if "{2}" <>  "1" &then
                 if not sums-only then do:
                    if first-of({2}) then do:
                        tmp#stroka = (if string(entry(2,"{2}",".")) <> "grp-name" then "произв." + gds-zap-prod-name else "группа " + gds-zap-grp-name ).
                        fr = true.
                    end.
                end.

&endif
     run display-line.
       /* промежуточные итоги*/
&if "{2}" <>  "1" &then    /* если есть классиф */
if last-of({2}) then do:
  if  not (not show-negativ  and
            ( tot-1-1 = 0 and
                tot-1-2 = 0 and
                tot-1-4 = 0 and
                tot-1-5 = 0 and
                tot-1-3 = 0 )) then do:

              if not sums-only then run u-line.
              /*шапка для верхней группы */
              if sums-only then do:
                  if fr0 = true then do:
                      run proc-prt-3 .
                      fr0 = false .
                    end.
               end.

              tmp#stroka = "Итого по " + (if string(entry(2,"{2}",".")) <> "grp-name":u then "произв." + gds-zap-prod-name else "группе " + gds-zap-grp-name).
              run proc-prt-1.
        end.
      end.
&if "{1}" <>  "1" &then
    if last-of({1}) then do:
            if  not (not show-negativ  and
            ( tot-2-1 = 0 and
              tot-2-2 = 0 and
              tot-2-4 = 0 and
              tot-2-5 = 0 and
              tot-2-3 = 0 )) then do:

              tmp#stroka = "Итого по " + (if string(entry(2,"{1}",".")) <> "grp-name" then "произв." + gds-zap-prod-name else "группе " + gds-zap-grp-name ).
              run proc-prt-2.

          end.
              assign  break_group1 = true
                            tot-2-1=0
                            tot-2-2=0
                            tot-2-3=0
                            tot-2-4=0
                            tot-2-5=0.
              if not sums-only then run u-line .

    end.
&endif
&endif
/* $Workfile$ e n d */