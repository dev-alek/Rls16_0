/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/27/01

*/

  &if  "{2}" <>  "1"   &then  /* промежуточные итоги */
        If Last-of({2}) Then Do:
        If String(Entry(2,"{2}",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      &if {3} = 2 Or {3} = 3 Or {3} = 6
                                      &then B1-name
                                      &else B2-name &endif
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      &if {3} = 2 Or {3} = 3 Or {3} = 6
                                      &then B1-name
                                      &else B2-name &endif
                                      ,17,40)
                                .

          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  &if {3} = 2 Or {3} = 3 Or {3} = 6
                                      &then B1-name
                                      &else B2-name &endif
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    &if "{1}" <>  "1" &then
        If Last-of({1}) Then Do:
        If String(Entry(2,"{1}",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                  &if {3} = 2 Or {3} = 3 Or {3} = 6
                                  &then B2-name
                                  &else B1-name &endif
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                  &if {3} = 2 Or {3} = 3 Or {3} = 6
                                  &then B2-name
                                  &else B1-name &endif
                                  ,17,40)
                            .

          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("{3}" = "4"  Or  "{3}" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =  &if {3} = 2 Or {3} = 3  Or {3} = 6  &then B2-name  &else B1-name &endif
              .

          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    &endif
&endif
/* $Workfile$ e n d */