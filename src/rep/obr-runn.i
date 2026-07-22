/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Œ·ÓÓÚÍË

¿‚ÚÓ: ◊ÂÌÓ‚‡ —‚ÂÚÎ‡Ì‡ ¿ÎÂÍÒ‡Ì‰Ó‚Ì‡
ƒ‡Ú‡ ÒÓÁ‰‡ÌËˇ: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

ƒ‡Ú‡ ÒÓÁ‰‡ÌËˇ: 08/15/01
*/
&if "{&report-sorttype}" = "" &Then
&scop  report-sorttype  artic
&endif

&if {1} = 7 and "{2}" = "yes"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ —“¿¬ ≈ Õƒ— */
procedure run7 :
      case select-good:
        when {&g-all}   then do: { rep/o-run1.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        when {&g-grp}   then do: { rep/o-run2.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        when {&g-prod}  then do: { rep/o-run3.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" {&break-vat} 6 gds-list gds-list.{&report-sorttype}}
        end.
      end case.
end procedure.
&endif
&if {1} = 5 and "{2}" = "yes" &then
 /*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿ “Œ¬¿–Œ¬/œ–Œ»«¬Œƒ»“≈À» */
procedure run5 :
  run run5sort2.
end procedure.
procedure run5sort2 :
       case select-good:
         when {&g-all}  then do: { rep/o-run1.i gds-obj.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))"  5 goods           goods.{&report-sorttype}} end.
         when {&g-grp}  then do: { rep/o-run2.i gds-obj.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))"  5 goods           goods.{&report-sorttype}} end.
         when {&g-prod} then do: { rep/o-run3.i gds-obj.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))"  5 goods           goods.{&report-sorttype}} end.
         otherwise do:
           { rep/o-run1.i gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 5 gds-list gds-list.{&report-sorttype}}
         end.
      end case.
end procedure.
&endif
&if {1} = 4 and "{2}" = "yes"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/* œŒ œ–Œ»«¬Œƒ»“≈À»/√–”œœ¿ “Œ¬¿–Œ¬ */
procedure run4 :
  run run4sort2 .
  end procedure .
procedure run4sort2 :
      case select-good :
         when {&g-all}  then do: { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-obj.grp-name 4 goods           goods.{&report-sorttype}} end.
         when {&g-grp}  then do: { rep/o-run2.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-obj.grp-name 4 goods           goods.{&report-sorttype}} end.
         when {&g-prod} then do: { rep/o-run3.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-obj.grp-name 4 goods           goods.{&report-sorttype}} end.
         otherwise do:
           { rep/o-run1.i  "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))"  gds-list.grp-name 4 gds-list gds-list.{&report-sorttype}}
         end.
      end case.
end procedure.
&endif
&if {1} = 3 and "{2}" = "yes"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ œ–Œ»«¬Œƒ»“≈ÀﬂÃ*/
procedure run3 :
  run run3sort2.
end procedure.
procedure run3sort2 :
  case select-good :
    when {&g-all}  then do: { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 2 goods goods.{&report-sorttype}} end.
    when {&g-grp}  then do: { rep/o-run2.i "1" "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 2 goods goods.{&report-sorttype}} end.
    when {&g-prod} then do: { rep/o-run3.i "1" "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 2 goods goods.{&report-sorttype}} end.
    otherwise do:
      { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 2 gds-list gds-list.{&report-sorttype}}
    end.
  end case.
end procedure.
&endif

&if {1} = 2 and "{2}" = "yes"  and "{3}" = ""  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿Ã*/
procedure run2 :
     if not xtog-lavel then do:   run run2sort1.   end.
       else do:   run lavel1.    end.
   end procedure.

procedure run2sort1 :
    case select-good :
        when {&g-all}  then do:  { rep/o-run1.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
        when {&g-grp}  then do:  { rep/o-run2.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
        when {&g-prod} then do:  { rep/o-run3.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
        otherwise do:
          { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.{&report-sorttype}}
        end.
      end case.
end procedure.

procedure lavel1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3} }  end.
                  when {&g-grp}  then do:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  when {&g-prod} then do:  { rep/o-l3.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  otherwise do:
                    { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.{&report-sorttype} {3}}
                  end.
              end case.
end procedure.

&endif
&if {1} = 2 and "{2}" = "yes"  and "{3}" = "no-lavel" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿Ã*/
procedure run2 :
case select-good :
  when {&g-all}  then do:  { rep/o-run1.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
  when {&g-grp}  then do:  { rep/o-run2.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
  when {&g-prod} then do:  { rep/o-run3.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
  otherwise do:
    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.{&report-sorttype}}
  end.
end case.
end procedure.
&endif
&if {1} = 2 and "{2}" = "yes"  and "{3}" = "lavel" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿Ã*/
procedure run2 :
  case select-good :
      when {&g-all}  then do:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
      when {&g-grp}  then do:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
      when {&g-prod} then do:  { rep/o-l3.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
      otherwise do:
        { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.{&report-sorttype} {3}}
      end.
  end case.
end procedure.
&endif

&if {1} = 1 and "{2}" = "yes"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ “Œ¬¿–”*/
procedure run1 :
 run run1sort2.
end procedure.
procedure run1sort2 :
       case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "1" 1 goods goods.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "1" 1 goods goods.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" "1" 1 goods goods.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" "1" 1 gds-list gds-list.{&report-sorttype}}
        end.
        end case.
end procedure.
&endif
&if {1} = 7 and "{2}" = "no"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ —“¿¬ ≈ Õƒ— */
procedure run7 :
  case select-good:
    when {&g-all}  then do: { rep/o-run1.i "1" temp-gds-list.vat-pc 6 goods       temp-gds-list.{&report-sorttype}} end.
    when {&g-grp}  then do: { rep/o-run2.i "1" temp-gds-list.vat-pc 6 goods       temp-gds-list.{&report-sorttype}} end.
    when {&g-prod} then do: { rep/o-run3.i "1" temp-gds-list.vat-pc 6 goods       temp-gds-list.{&report-sorttype}} end.
    otherwise do:
       { rep/o-run1.i "1" temp-gds-list.vat-pc 6 gds-list gds-list.{&report-sorttype}}
    end.
  end case.
end procedure.
&endif
&if {1} = 5 and "{2}" = "no" &then
 /*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿ “Œ¬¿–Œ¬/œ–Œ»«¬Œƒ»“≈À» */
procedure run5 :
case select-good:
  when {&g-all}  then do: { rep/o-run1.i temp-gds-list.grp-name "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" 5 goods     temp-gds-list.{&report-sorttype}} end.
  when {&g-grp}  then do: { rep/o-run2.i temp-gds-list.grp-name "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" 5 goods     temp-gds-list.{&report-sorttype}} end.
  when {&g-prod} then do: { rep/o-run3.i temp-gds-list.grp-name "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" 5 goods     temp-gds-list.{&report-sorttype}} end.
  otherwise do:
    { rep/o-run1.i temp-gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 5 gds-list gds-list.{&report-sorttype}}
  end.
end case.
end procedure.
&endif
&if {1} = 4 and "{2}" = "no"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/* œŒ œ–Œ»«¬Œƒ»“≈À»/√–”œœ¿ “Œ¬¿–Œ¬ */
procedure run4 :
      case select-good :
         when {&g-all}  then do: { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" temp-gds-list.grp-name 4 goods        temp-gds-list.{&report-sorttype}} end.
         when {&g-grp}  then do: { rep/o-run2.i "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" temp-gds-list.grp-name 4 goods        temp-gds-list.{&report-sorttype}} end.
         when {&g-prod} then do: { rep/o-run3.i "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" temp-gds-list.grp-name 4 goods        temp-gds-list.{&report-sorttype}} end.
         otherwise do:
           { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" temp-gds-list.grp-name 4 gds-list gds-list.{&report-sorttype}}
         end.
      end case.
end procedure.
&endif
&if {1} = 3 and "{2}" = "no"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ œ–Œ»«¬Œƒ»“≈ÀﬂÃ*/
procedure run3 :
      case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" 2 goods temp-gds-list.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" 2 goods temp-gds-list.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" "(substring(clients.obj-name,1,10) + string(temp-gds-list.prod-code))" 2 goods temp-gds-list.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 2 gds-list gds-list.{&report-sorttype}}
        end.
     end case.
end procedure.
&endif

&if {1} = 2 and "{2}" = "no" and "{3}" = ""  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿Ã*/
procedure run2 :
     if not xtog-lavel then do:   run run2sort1.    end.
       else do:   run lavel1.      end.
   end procedure.
procedure run2sort1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-run1.i "1" temp-gds-list.grp-name 3 goods temp-gds-list.{&report-sorttype}}  end.
                  when {&g-grp}  then do:  { rep/o-run2.i "1" temp-gds-list.grp-name 3 goods temp-gds-list.{&report-sorttype}}  end.
                  when {&g-prod} then do:  { rep/o-run3.i "1" temp-gds-list.grp-name 3 goods temp-gds-list.{&report-sorttype}}  end.
                   otherwise do:
                     { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.{&report-sorttype}}
                   end.
              end case.
end procedure.
procedure lavel1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel temp-gds-list.{&report-sorttype} {3} }  end.
                  when {&g-grp}  then do:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel temp-gds-list.{&report-sorttype} {3}}  end.
                  when {&g-prod} then do:  { rep/o-l3.i {&break-lavel} str 3 goods  lavel temp-gds-list.{&report-sorttype} {3}}  end.
                  otherwise do:
                     { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.{&report-sorttype} {3}}
                  end.
              end case.
   end procedure.
&endif
&if {1} = 2 and "{2}" = "no" and "{3}" = "no-lavel"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿Ã*/
procedure run2 :
  case select-good :
      when {&g-all}  then do:  { rep/o-run1.i "1" temp-gds-list.grp-name 3 goods temp-gds-list.{&report-sorttype}}  end.
      when {&g-grp}  then do:  { rep/o-run2.i "1" temp-gds-list.grp-name 3 goods temp-gds-list.{&report-sorttype}}  end.
      when {&g-prod} then do:  { rep/o-run3.i "1" temp-gds-list.grp-name 3 goods temp-gds-list.{&report-sorttype}}  end.
      otherwise do:
        { rep/o-run1.i "1" gds-list.grp-name      3 gds-list gds-list.{&report-sorttype}}
      end.
  end case.
end procedure.
&endif
&if {1} = 2 and "{2}" = "no" and "{3}" = "lavel"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ √–”œœ¿Ã*/
procedure run2 :
    case select-good :
        when {&g-all}  then do:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel temp-gds-list.{&report-sorttype} {3} }  end.
        when {&g-grp}  then do:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel temp-gds-list.{&report-sorttype} {3}}  end.
        when {&g-prod} then do:  { rep/o-l3.i {&break-lavel} str 3 goods  lavel temp-gds-list.{&report-sorttype} {3}}  end.
        otherwise do:
          { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.{&report-sorttype} {3}}
        end.
    end case.
end procedure.
&endif

&if {1} = 1 and "{2}" = "no"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
/*œŒ “Œ¬¿–”*/
procedure run1 :
       case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "1" 1 goods temp-gds-list.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "1" 1 goods temp-gds-list.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" "1" 1 goods temp-gds-list.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" "1" 1 gds-list gds-list.{&report-sorttype}}
        end.
       end case.
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
&endif
/*-----------------------------------------------------------------------------------------------------------------------*/
&if {1} = 123 and "{2}" <> "no"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure run1 :
  run run1sort1.
  end procedure.
procedure run1sort1 :
      case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "1" 1 goods goods.{&report-sorttype} } end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "1" 1 goods goods.{&report-sorttype} } end.
        when {&g-prod} then do: { rep/o-run3.i "1" "1" 1 goods goods.{&report-sorttype} } end.
        otherwise do:
         { rep/o-run1.i "1" "1" 1 gds-list gds-list.{&report-sorttype}}
        end.
       end case.
end procedure.

procedure run2 :
     if not xtog-lavel then do:   run run2sort1.     end.
       else do:    run lavel1.      end.
   end procedure.
procedure run2sort1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-run1.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
                  when {&g-grp}  then do:  { rep/o-run2.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
                  when {&g-prod} then do:  { rep/o-run3.i "1" gds-obj.grp-name 3 goods goods.{&report-sorttype}}  end.
                  otherwise do:
                    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.{&report-sorttype}}
                  end.
              end case.
end procedure.

procedure run3 :
      case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 2 goods goods.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 2 goods goods.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 2 goods goods.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 2 gds-list gds-list.{&report-sorttype}}
        end.
     end case.
end procedure.

procedure lavel1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  when {&g-grp}  then do:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  when {&g-prod} then do:  { rep/o-l3.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  otherwise do:
                    { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.{&report-sorttype} {3}}
                  end.
              end case.
   end procedure.
&endif
/*--------------------------------------------------------------------------------------------------------------------*/
&if {1} = 457 and "{2}" <> "no"  &then
procedure run4 :
  case select-good :
      when {&g-all}  then do: { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-obj.grp-name 4 goods           goods.{&report-sorttype}} end.
      when {&g-grp}  then do: { rep/o-run2.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-obj.grp-name 4 goods           goods.{&report-sorttype}} end.
      when {&g-prod} then do: { rep/o-run3.i "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" gds-obj.grp-name 4 goods           goods.{&report-sorttype}} end.
      otherwise do:
        { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" gds-list.grp-name 4 gds-list gds-list.{&report-sorttype}}
      end.
  end case.
end procedure.

procedure run5 :
       case select-good:
         when {&g-all}  then do: { rep/o-run1.i gds-obj.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods           goods.{&report-sorttype}} end.
         when {&g-grp}  then do: { rep/o-run2.i gds-obj.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods           goods.{&report-sorttype}} end.
         when {&g-prod} then do: { rep/o-run3.i gds-obj.grp-name "(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))" 5 goods           goods.{&report-sorttype}} end.
         otherwise do:
           { rep/o-run1.i gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 5 gds-list gds-list.{&report-sorttype}}
         end.
      end case.
end procedure.

procedure run7 :
      case select-good:
        when {&g-all}  then do: { rep/o-run1.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" {&break-vat} 6 gds-list gds-list.{&report-sorttype}}
        end.
      end case.
end procedure.
&endif

&if {1} = 123 and "{2}" = "no"  &then
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure run1 :
       case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "1" 1 goods  goods.{&report-sorttype} } end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "1" 1 goods  goods.{&report-sorttype} } end.
        when {&g-prod} then do: { rep/o-run3.i "1" "1" 1 goods  goods.{&report-sorttype} } end.
        otherwise do:
           { rep/o-run1.i "1" "1" 1 gds-list gds-list.{&report-sorttype}}
        end.
       end case.
end procedure.

procedure run2 :
     if not xtog-lavel then do:    run run2sort1.       end.
       else do:    run lavel1.      end.
   end procedure.
procedure run2sort1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-run1.i "1" goods.grp-name 3 goods goods.{&report-sorttype}}  end.
                  when {&g-grp}  then do:  { rep/o-run2.i "1" goods.grp-name 3 goods goods.{&report-sorttype}}  end.
                  when {&g-prod} then do:  { rep/o-run3.i "1" goods.grp-name 3 goods goods.{&report-sorttype}}  end.
                  otherwise do:
                    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.{&report-sorttype}}
                  end.
              end case.
end procedure.

procedure run3 :
      case select-good :
        when {&g-all}  then do: { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(goods.prod-code))" 2 goods goods.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" "(substring(clients.obj-name,1,10) + string(goods.prod-code))" 2 goods goods.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" "(substring(clients.obj-name,1,10) + string(goods.prod-code))" 2 goods goods.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 2 gds-list gds-list.{&report-sorttype}}
        end.
     end case.
end procedure.

procedure lavel1 :
              case select-good :
                  when {&g-all}  then do:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  when {&g-grp}  then do:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  when {&g-prod} then do:  { rep/o-l3.i {&break-lavel} str 3 goods  lavel goods.{&report-sorttype} {3}}  end.
                  otherwise do:
                    { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.{&report-sorttype} {3} }
                  end.
              end case.
   end procedure.
&endif
/*--------------------------------------------------------------------------------------------------------------------*/
&if {1} = 457 and "{2}" = "no"  &then
procedure run4 :
      case select-good :
         when {&g-all}  then do: { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(goods.prod-code))" goods.grp-name 4 goods           goods.{&report-sorttype}} end.
         when {&g-grp}  then do: { rep/o-run2.i "(substring(clients.obj-name,1,10) + string(goods.prod-code))" goods.grp-name 4 goods           goods.{&report-sorttype}} end.
         when {&g-prod} then do: { rep/o-run3.i "(substring(clients.obj-name,1,10) + string(goods.prod-code))" goods.grp-name 4 goods           goods.{&report-sorttype}} end.
         otherwise do:
          { rep/o-run1.i "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" gds-list.grp-name 4 gds-list gds-list.{&report-sorttype}}
         end.
      end case.
end procedure.

procedure run5 :
       case select-good:
         when {&g-all}  then do: { rep/o-run1.i goods.grp-name "(substring(clients.obj-name,1,10) + string(goods.prod-code))" 5 goods           goods.{&report-sorttype}} end.
         when {&g-grp}  then do: { rep/o-run2.i goods.grp-name "(substring(clients.obj-name,1,10) + string(goods.prod-code))" 5 goods           goods.{&report-sorttype}} end.
         when {&g-prod} then do: { rep/o-run3.i goods.grp-name "(substring(clients.obj-name,1,10) + string(goods.prod-code))" 5 goods           goods.{&report-sorttype}} end.
         otherwise do:
           { rep/o-run1.i gds-list.grp-name "(substring(clients.obj-name,1,10) + string(gds-list.prod-code))" 5 gds-list gds-list.{&report-sorttype}}
         end.
      end case.
end procedure.

procedure run7 :
      case select-good:
        when {&g-all}  then do: { rep/o-run1.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        when {&g-grp}  then do: { rep/o-run2.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        when {&g-prod} then do: { rep/o-run3.i "1" {&break-vat} 6 goods       goods.{&report-sorttype}} end.
        otherwise do:
          { rep/o-run1.i "1" {&break-vat} 6 gds-list gds-list.{&report-sorttype}}
        end.
      end case.
end procedure.
&endif