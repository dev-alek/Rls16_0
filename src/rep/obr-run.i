/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

старый кусок обороток

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
PROCEDURE Run1 :
 if RetSortType = "sort-code":U    then  RUN Run1Sort1.   else  RUN Run1Sort2.
  END PROCEDURE.
PROCEDURE Run2 :
     if NOT xTog-lavel Then DO:  if RetSortType = "sort-code":U   then  Run Run2Sort1.    Else  Run Run2Sort2.   End.
       Else DO:   if RetSortType = "sort-code":U   then  Run lavel1.    Else  Run lavel2.    End.
   END PROCEDURE.
PROCEDURE Run3 :
  if RetSortType = "sort-code":U   then  Run Run3Sort1.  Else  Run Run3Sort2.
  END PROCEDURE.
PROCEDURE Run4 :
  if RetSortType = "sort-code":U  then  RUN Run4Sort1.   else  RUN Run4Sort2.
  END PROCEDURE.
PROCEDURE Run5 :
  if RetSortType = "sort-code":U      then  Run Run5Sort1.     Else  Run Run5Sort2.
  END PROCEDURE.
PROCEDURE Run7 :
  if RetSortType = "sort-code":U      then  RUN Run7Sort1.     Else  RUN Run7Sort2.
 END PROCEDURE.

&IF "{1}" <> "no"  &then
PROCEDURE lavel1 :
    Case Select-Good :
        when {&g-all}   then DO:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel gds-OBJ.gds-code }  End.
        when {&g-grp}   then DO:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel gds-OBJ.gds-code }  End.
        when {&g-prod}  then DO:  { rep/o-l3.i {&break-lavel} str 3 GOODS  lavel gds-OBJ.gds-code }  End.
        otherwise do:
            { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.gds-code }
        end.
    end case.
END PROCEDURE.

PROCEDURE lavel2 :
      Case Select-Good :
          when {&g-all}   then DO:  { rep/o-l1.i {&break-lavel} str 3 goods             lavel   gds-OBJ.artic }  End.
          when {&g-grp}   then DO:  { rep/o-l2.i {&break-lavel} str 3 goods             lavel   gds-OBJ.artic }  End.
          when {&g-prod}  then DO:  { rep/o-l3.i {&break-lavel} str 3 goods             lavel   gds-OBJ.artic }  End.
          otherwise do:
            { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.artic }
          end.
      end case.
 END PROCEDURE.
PROCEDURE Run2Sort1 :
              CAse Select-Good :
                  when  {&g-all}  then DO:  { rep/o-run1.i "1" gds-OBJ.grp-name 3 goods gds-OBJ.gds-code}  End.
                  when  {&g-grp}  then DO:  { rep/o-run2.i "1" gds-OBJ.grp-name 3 goods gds-OBJ.gds-code}  End.
                  when  {&g-prod} then DO:  { rep/o-run3.i "1" gds-OBJ.grp-name 3 goods gds-OBJ.gds-code}  End.
                  otherwise do:
                    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.gds-code}
                  end.
              end case.
END PROCEDURE.
PROCEDURE Run2Sort2 :
              CAse Select-Good :
                  when  {&g-all}  then DO:  { rep/o-run1.i "1" gds-OBJ.grp-name 3 goods gds-OBJ.artic}  End.
                  when  {&g-grp}  then DO:  { rep/o-run2.i "1" gds-OBJ.grp-name 3 goods gds-OBJ.artic}  End.
                  when  {&g-prod} then DO:  { rep/o-run3.i "1" gds-OBJ.grp-name 3 goods gds-OBJ.artic}  End.
                  otherwise do:
                    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.artic }
                  end.
              end case.
END PROCEDURE.
PROCEDURE Run1Sort1 :
      CAse Select-Good :
        when  {&g-all}  then DO: { rep/o-run1.i "1" "1" 1 goods gds-OBJ.gds-code} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" "1" 1 goods gds-OBJ.gds-code} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" "1" 1 goods gds-OBJ.gds-code} End.
        otherwise do:
          { rep/o-run1.i "1" "1" 1 gds-list gds-list.gds-code }
        end.
       End case.
END PROCEDURE.
PROCEDURE Run1Sort2 :
       CAse Select-Good :
        when  {&g-all}  then DO: { rep/o-run1.i "1" "1" 1 goods gds-OBJ.artic} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" "1" 1 goods gds-OBJ.artic} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" "1" 1 goods gds-OBJ.artic} End.
        otherwise do:
          { rep/o-run1.i "1" "1" 1 gds-list gds-list.artic }
        end.
       End case.
END PROCEDURE.
PROCEDURE Run3Sort1 :
      CASE Select-Good :
        when  {&g-all}  then DO: { rep/o-run1.i "1" gds-OBJ.prod-code 2 goods gds-OBJ.gds-code} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" gds-OBJ.prod-code 2 goods gds-OBJ.gds-code} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" gds-OBJ.prod-code 2 goods gds-OBJ.gds-code} End.
        otherwise do:
           { rep/o-run1.i "1" gds-list.prod-code 2 gds-list gds-list.gds-code}
        end.
     End case.
END PROCEDURE.
PROCEDURE Run3Sort2 :
      CASE Select-Good :
        when  {&g-all}   then DO: { rep/o-run1.i "1" gds-OBJ.prod-code 2 goods gds-OBJ.artic} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" gds-OBJ.prod-code 2 goods gds-OBJ.artic} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" gds-OBJ.prod-code 2 goods gds-OBJ.artic} End.
        otherwise do:
          { rep/o-run1.i "1" gds-list.prod-code 2 gds-list gds-list.artic}
        end.
     End case.
END PROCEDURE.
PROCEDURE Run4Sort1 :
      CASE Select-Good :
         when  {&g-all}  then DO: { rep/o-run1.i gds-OBJ.prod-code gds-OBJ.grp-name 4 goods           gds-OBJ.gds-code } End.
         when  {&g-grp}  then DO: { rep/o-run2.i gds-OBJ.prod-code gds-OBJ.grp-name 4 goods           gds-OBJ.gds-code } End.
         when  {&g-prod} then DO: { rep/o-run3.i gds-OBJ.prod-code gds-OBJ.grp-name 4 goods            gds-OBJ.gds-code} End.
         otherwise do:
           { rep/o-run1.i gds-list.prod-code gds-list.grp-name 4 gds-list  gds-list.gds-code}
         end.
      End case.
END PROCEDURE.
PROCEDURE Run4Sort2 :
      CASE Select-Good :
         when  {&g-all}  then DO: { rep/o-run1.i gds-OBJ.prod-code gds-OBJ.grp-name 4 goods           gds-OBJ.artic} End.
         when  {&g-grp}  then DO: { rep/o-run2.i gds-OBJ.prod-code gds-OBJ.grp-name 4 goods           gds-OBJ.artic} End.
         when  {&g-prod} then DO: { rep/o-run3.i gds-OBJ.prod-code gds-OBJ.grp-name 4 goods           gds-OBJ.artic} End.
         otherwise do:
           { rep/o-run1.i gds-list.prod-code gds-list.grp-name 4 gds-list gds-list.artic }
         end.
      End case.
END PROCEDURE.
PROCEDURE Run5Sort1 :
      case Select-Good:
         when {&g-all}   then DO: { rep/o-run1.i gds-OBJ.grp-name gds-OBJ.prod-code 5 goods           gds-OBJ.gds-code} End.
         when {&g-grp}   then DO: { rep/o-run2.i gds-OBJ.grp-name gds-OBJ.prod-code 5 goods           gds-OBJ.gds-code} End.
         when {&g-prod}  then DO: { rep/o-run3.i gds-OBJ.grp-name gds-OBJ.prod-code 5 goods           gds-OBJ.gds-code} End.
         otherwise do:
           { rep/o-run1.i gds-list.grp-name gds-list.prod-code 5 gds-list gds-list.gds-code }
         end.
      End case.
END PROCEDURE.
PROCEDURE Run5Sort2 :
       case Select-Good:
         when  {&g-all}  then DO: { rep/o-run1.i gds-OBJ.grp-name gds-OBJ.prod-code 5 goods           gds-OBJ.artic} End.
         when  {&g-grp}  then DO: { rep/o-run2.i gds-OBJ.grp-name gds-OBJ.prod-code 5 goods           gds-OBJ.artic} End.
         when  {&g-prod} then DO: { rep/o-run3.i gds-OBJ.grp-name gds-OBJ.prod-code 5 goods           gds-OBJ.artic} End.
         otherwise do:
           { rep/o-run1.i gds-list.grp-name gds-list.prod-code 5 gds-list gds-list.artic}
         end.
      End case.
END PROCEDURE.
PROCEDURE Run7Sort1 :
      case Select-Good:
        when  {&g-all}  then DO: { rep/o-run1.i "1" goods.vat-pc 6 goods     goods.gds-code} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" goods.vat-pc 6 goods     goods.gds-code} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" goods.vat-pc 6 goods     goods.gds-code} End.
        otherwise do:
          { rep/o-run1.i "1" gds-list.vat-pc 6 gds-list gds-list.gds-code }
        end.
      End case.
END PROCEDURE.
PROCEDURE Run7Sort2 :
      case Select-Good:
        when {&g-all}   then DO: { rep/o-run1.i "1" goods.vat-pc 6 goods      goods.artic} End.
        when {&g-grp}   then DO: { rep/o-run2.i "1" goods.vat-pc 6 goods      goods.artic} End.
        when {&g-prod}  then DO: { rep/o-run3.i "1" goods.vat-pc 6 goods      goods.artic} End.
        otherwise do:
          { rep/o-run1.i "1" gds-list.vat-pc 6 gds-list gds-list.artic }
        end.
      End case.
END PROCEDURE.
&else
PROCEDURE lavel1 :
    Case Select-Good :
        when  {&g-all}  then DO:  { rep/o-l1.i {&break-lavel} str 3 goods  lavel goods.gds-code }  End.
        when  {&g-grp}  then DO:  { rep/o-l2.i {&break-lavel} str 3 goods  lavel goods.gds-code }  End.
        when  {&g-prod} then DO:  { rep/o-l3.i {&break-lavel} str 3 GOODS  lavel goods.gds-code }  End.
        otherwise do:
          { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.gds-code }
        end.
    end case.
END PROCEDURE.

PROCEDURE lavel2 :
      Case Select-Good :
          when  {&g-all}  then DO:  { rep/o-l1.i {&break-lavel} str 3 goods             lavel   goods.artic }  End.
          when  {&g-grp}  then DO:  { rep/o-l2.i {&break-lavel} str 3 goods             lavel   goods.artic }  End.
          when  {&g-prod} then DO:  { rep/o-l3.i {&break-lavel} str 3 goods             lavel   goods.artic }  End.
          otherwise do:
            { rep/o-l1.i {&break-lavel-gds-list} str 3 gds-list lavel gds-list.artic }
          end.
      end case.
 END PROCEDURE.
PROCEDURE Run2Sort1 :
              CAse Select-Good :
                  when  {&g-all}  then DO:  { rep/o-run1.i "1" goods.grp-name 3 goods goods.gds-code}  End.
                  when  {&g-grp}  then DO:  { rep/o-run2.i "1" goods.grp-name 3 goods goods.gds-code}  End.
                  when  {&g-prod} then DO:  { rep/o-run3.i "1" goods.grp-name 3 goods goods.gds-code}  End.
                  otherwise do:
                    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.gds-code}
                  end.
              end case.
END PROCEDURE.
PROCEDURE Run2Sort2 :
              CAse Select-Good :
                  when  {&g-all}  then DO:  { rep/o-run1.i "1" goods.grp-name 3 goods goods.artic}  End.
                  when  {&g-grp}  then DO:  { rep/o-run2.i "1" goods.grp-name 3 goods goods.artic}  End.
                  when  {&g-prod} then DO:  { rep/o-run3.i "1" goods.grp-name 3 goods goods.artic}  End.
                  otherwise do:
                    { rep/o-run1.i "1" gds-list.grp-name 3 gds-list gds-list.artic}
                  end.
              end case.
END PROCEDURE.
PROCEDURE Run1Sort1 :
      CAse Select-Good :
        when {&g-all}   then DO: { rep/o-run1.i "1" "1" 1 goods goods.gds-code} End.
        when {&g-grp}   then DO: { rep/o-run2.i "1" "1" 1 goods goods.gds-code} End.
        when {&g-prod}  then DO: { rep/o-run3.i "1" "1" 1 goods goods.gds-code} End.
         otherwise do:
           { rep/o-run1.i "1" "1" 1 gds-list gds-list.gds-code}
         end.
       End case.
END PROCEDURE.
PROCEDURE Run1Sort2 :
       CAse Select-Good :
        when  {&g-all}  then DO: { rep/o-run1.i "1" "1" 1 goods goods.artic } End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" "1" 1 goods goods.artic } End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" "1" 1 goods goods.artic } End.
        otherwise do:
          { rep/o-run1.i "1" "1" 1 gds-list gds-list.artic }
        end.
       End case.
END PROCEDURE.
PROCEDURE Run3Sort1 :
      CASE Select-Good :
        when  {&g-all}  then DO: { rep/o-run1.i "1" goods.prod-code 2 goods goods.gds-code} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" goods.prod-code 2 goods goods.gds-code} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" goods.prod-code 2 goods goods.gds-code} End.
        otherwise do:
          { rep/o-run1.i "1" gds-list.prod-code 2 gds-list gds-list.gds-code }
        end.
     End case.
END PROCEDURE.
PROCEDURE Run3Sort2 :
      CASE Select-Good :
        when  {&g-all}  then DO: { rep/o-run1.i "1" goods.prod-code 2 goods goods.artic} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" goods.prod-code 2 goods goods.artic} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" goods.prod-code 2 goods goods.artic} End.
        otherwise do:
          { rep/o-run1.i "1" gds-list.prod-code 2 gds-list gds-list.artic}
        end.
     End case.
END PROCEDURE.
PROCEDURE Run4Sort1 :
      CASE Select-Good :
         when {&g-all}   then DO: { rep/o-run1.i goods.prod-code goods.grp-name 4 goods           goods.gds-code } End.
         when {&g-grp}   then DO: { rep/o-run2.i goods.prod-code goods.grp-name 4 goods           goods.gds-code } End.
         when {&g-prod}  then DO: { rep/o-run3.i goods.prod-code goods.grp-name 4 goods            goods.gds-code} End.
         otherwise do:
           { rep/o-run1.i gds-list.prod-code gds-list.grp-name 4 gds-list  gds-list.gds-code}
         end.
      End case.
END PROCEDURE.
PROCEDURE Run4Sort2 :
      CASE Select-Good :
         when  {&g-all}  then DO: { rep/o-run1.i goods.prod-code goods.grp-name 4 goods           goods.artic} End.
         when  {&g-grp}  then DO: { rep/o-run2.i goods.prod-code goods.grp-name 4 goods           goods.artic} End.
         when  {&g-prod} then DO: { rep/o-run3.i goods.prod-code goods.grp-name 4 goods           goods.artic} End.
         otherwise do:
           { rep/o-run1.i gds-list.prod-code gds-list.grp-name 4 gds-list gds-list.artic}
         end.
      End case.
END PROCEDURE.
PROCEDURE Run5Sort1 :
      case Select-Good:
         when  {&g-all}  then DO: { rep/o-run1.i goods.grp-name goods.prod-code 5 goods           goods.gds-code} End.
         when  {&g-grp}  then DO: { rep/o-run2.i goods.grp-name goods.prod-code 5 goods           goods.gds-code} End.
         when  {&g-prod} then DO: { rep/o-run3.i goods.grp-name goods.prod-code 5 goods           goods.gds-code} End.
         otherwise do:
           { rep/o-run1.i gds-list.grp-name gds-list.prod-code 5 gds-list gds-list.gds-code}
         end.
      End case.
END PROCEDURE.
PROCEDURE Run5Sort2 :
  case Select-Good:
    when  {&g-all}  then DO: { rep/o-run1.i goods.grp-name goods.prod-code 5 goods           goods.artic} End.
    when  {&g-grp}  then DO: { rep/o-run2.i goods.grp-name goods.prod-code 5 goods           goods.artic} End.
    when  {&g-prod} then DO: { rep/o-run3.i goods.grp-name goods.prod-code 5 goods           goods.artic} End.
    otherwise do:
      { rep/o-run1.i gds-list.grp-name gds-list.prod-code 5 gds-list gds-list.artic }
    end.
  End case.
END PROCEDURE.
PROCEDURE Run7Sort1 :
      case Select-Good:
        when {&g-all}   then DO: { rep/o-run1.i "1" goods.vat-pc 6 goods     goods.gds-code} End.
        when {&g-grp}   then DO: { rep/o-run2.i "1" goods.vat-pc 6 goods     goods.gds-code} End.
        when {&g-prod}  then DO: { rep/o-run3.i "1" goods.vat-pc 6 goods     goods.gds-code} End.
        otherwise do:
          { rep/o-run1.i "1" gds-list.vat-pc 6 gds-list gds-list.gds-code}
        end.

      End case.
END PROCEDURE.
PROCEDURE Run7Sort2 :
      case Select-Good:
        when  {&g-all}  then DO: { rep/o-run1.i "1" goods.vat-pc 6 goods      goods.artic} End.
        when  {&g-grp}  then DO: { rep/o-run2.i "1" goods.vat-pc 6 goods      goods.artic} End.
        when  {&g-prod} then DO: { rep/o-run3.i "1" goods.vat-pc 6 goods      goods.artic} End.
        otherwise do:
           { rep/o-run1.i "1" gds-list.vat-pc 6 gds-list gds-list.artic}
        end.
      End case.
END PROCEDURE.
&endif