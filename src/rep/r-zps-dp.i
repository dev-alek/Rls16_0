/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Специфическая часть отчета по поставшикам (Запасы по поставщикам)

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/16/01
*/

procedure Goods-start :
END PROCEDURE.


procedure Goods-end :
  Find last temp2-post-stk-line  no-lock where
                                    temp2-post-stk-line.artic       =  temp-t-post-stk-line.artic        and
                                    temp2-post-stk-line.prod-type   =  temp-t-post-stk-line.prod-type    and
                                    temp2-post-stk-line.prod-code   =  temp-t-post-stk-line.prod-code    and
                                    temp2-post-stk-line.cli-type    =  temp-t-post-stk-line.cli-type     and
                                    temp2-post-stk-line.cli-code    =  temp-t-post-stk-line.cli-code     and
                                    temp2-post-stk-line.obj-type    =  temp-t-post-stk-line.obj-type     and
                                    temp2-post-stk-line.obj-code    =  temp-t-post-stk-line.obj-code     and
                                    temp2-post-stk-line.fact-order <=  fact-order-2               and
                                    temp2-post-stk-line.sum-type    =  {&arh-cost}                and
                                    temp2-post-stk-line.cat-id      =  {&single-cat-id}
                                    use-index category no-error .
  Find Last a-post-stk-line  where
      a-post-stk-line.fact-order =  (if avail temp2-post-stk-line then temp2-post-stk-line.fact-order else 0)  and
      a-post-stk-line.cat-id     =  t#cat-id      and
      a-post-stk-line.Sum-type   =  t#sum-type    and
      a-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
      a-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
      a-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
      a-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
      a-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code  and
      a-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type  and
      a-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code
      no-lock use-index category no-error .

END PROCEDURE.


PROCEDURE display-line :
 def var xx-typeprice as char no-undo.
 def buffer  b-post-stk-line for ub.stk-supp-line .
  ii = ii + 1.
/*  run gbl/inidebug.p.*/
  { rep/r-mess.i ii 10 }
       gds-post-artic     = "" .
       find first ub.ext-artic no-lock where
              ub.ext-artic.gds-code = temp-t-post-stk-line.gds-code and
              ub.ext-artic.cli-type = temp-t-post-stk-line.Cli-type and
              ub.ext-artic.cli-code = temp-t-post-stk-line.Cli-code and
              ub.ext-artic.status_   =  {&current-status} no-error .
       if available ub.ext-artic then do:
            assign
              gds-post-artic     = ub.ext-artic.ext-artic
            .
       end.

      Assign
          gds-zap-gds-name   = temp-t-post-stk-line.gds-name
          gds-zap-unit-base  = temp-t-post-stk-line.unit-base
          gds-zap-prt-root   = temp-t-post-stk-line.prt-root
          gds-zap-prod-type  = temp-t-post-stk-line.prod-type
          gds-zap-prod-code  = temp-t-post-stk-line.prod-code
          gds-zap-artic      = temp-t-post-stk-line.artic
          gds-zap-grp-name   = temp-t-post-stk-line.Goods-grp-name
          gds-zap-b-code     = temp-t-post-stk-line.gds-code
          gds-zap-type       = temp-t-post-stk-line.gds-type
          pos-cli-type       = temp-t-post-stk-line.Cli-type
          pos-cli-code       = temp-t-post-stk-line.Cli-code
          pos-cli-grp-name   = temp-t-post-stk-line.Clients-grp-name
          gds-zap-qnty       = 0
          gds-zap-price-base = 0
          gds-zap-stoim-base = 0
          gds-zap-Nds        = 0
          gds-zap-Np         = 0 .
          /*Найдем суммы по остаткам по товарам из архива по товарам a-stk-line */
          /* cost */
           if NOT avail a-post-stk-line then
                  ASSIGN gds-zap-qnty       = 0
                        gds-zap-stoim-base  = 0
                        gds-zap-Nds         = 0
                        gds-zap-Np          = 0.

           else do:

            IF  tPrintRubl  THEN
                  ASSIGN gds-zap-qnty       = a-post-stk-line.fact-qnty
                        gds-zap-stoim-base  = a-post-stk-line.sum-rubl
                        gds-zap-Nds         = a-post-stk-line.VAT-rubl
                        gds-zap-Np          = a-post-stk-line.SLT-rubl   .
              ELSE
                  ASSIGN gds-zap-qnty       =  a-post-stk-line.fact-qnty
                        gds-zap-stoim-base  =  a-post-stk-line.sum-base
                        gds-zap-Nds         =  a-post-stk-line.VAT-base
                        gds-zap-Np          =  a-post-stk-line.SLT-base .
           end.
          IF PayType = 1 then do: /* crsa */  /* товарный архив */
             find last ub.stk-line where
                                         ub.stk-line.fact-order <= fact-order-2 and
                                         ub.stk-line.cat-id     = {&root-cat-id}             and
                                         ub.stk-line.Sum-type   = {&arh-crsa}                and
                                         ub.stk-line.artic      = temp-t-post-stk-line.artic        and
                                         ub.stk-line.prod-type  = temp-t-post-stk-line.prod-type    and
                                         ub.stk-line.prod-code  = temp-t-post-stk-line.prod-code    and
                                         ub.stk-line.obj-type   = temp-t-post-stk-line.obj-type     and
                                         ub.stk-line.obj-code   = temp-t-post-stk-line.obj-code
                                         no-lock  no-error .
                  if avail ub.stk-line then do:
                      IF  tPrintRubl  THEN 
                           ASSIGN
                                  gds-zap-stoim-base  =  ub.stk-line.sum-rubl * (gds-zap-qnty / ub.stk-line.fact-qnty)
                                  gds-zap-Nds         =  ub.stk-line.VAT-rubl * (gds-zap-qnty / ub.stk-line.fact-qnty)
                                  gds-zap-Np          =  ub.stk-line.SLT-rubl * (gds-zap-qnty / ub.stk-line.fact-qnty)           .
                        ELSE
                           ASSIGN
                                  gds-zap-stoim-base  =  ub.stk-line.sum-base * (gds-zap-qnty / ub.stk-line.fact-qnty)
                                  gds-zap-Nds         =  ub.stk-line.VAT-base * (gds-zap-qnty / ub.stk-line.fact-qnty)
                                  gds-zap-Np          =  ub.stk-line.SLT-base * (gds-zap-qnty / ub.stk-line.fact-qnty) .

                  End.
                  Else
                    ASSIGN
                          gds-zap-stoim-base  = 0
                          gds-zap-Nds         = 0
                          gds-zap-Np          = 0 .

                     Assign gds-zap-stoim-base  = if gds-zap-stoim-base <> ? then gds-zap-stoim-base   else 0
                            gds-zap-Nds         = if gds-zap-Nds        <> ? then gds-zap-Nds          else 0
                            gds-zap-Np          = if gds-zap-Np         <> ? then gds-zap-Np           else 0 .




            End.



        Assign
          gds-zap-price-base = if (gds-zap-qnty <> 0) Then (gds-zap-stoim-base / gds-zap-qnty) Else 0
          tot_tqnty          = gds-zap-stoim-base - gds-zap-Nds.






       IF  NOT (NOT Show-Negativ  AND (gds-zap-qnty = 0 and gds-zap-stoim-base = 0)) then DO:
        IF NOT Sums-Only then DO:
             i = i + 1.
             DISPLAY stream  OutStream {&all-sym12}
                              gds-zap-b-code
                              gds-zap-artic
                              gds-post-artic
                              gds-zap-gds-name
                              gds-zap-unit-base
                              gds-zap-qnty
                              gds-zap-price-base
                              gds-zap-stoim-base
                              gds-zap-Nds
                              gds-zap-Np
                              tot_tqnty
                              with FRAME  zapas    .
            DOWN stream  OutStream 1 with FRAME zapas    .
            {&PutExcel}
              gds-zap-b-code     {&tabulation}
              gds-zap-artic      {&tabulation}
              gds-post-artic      {&tabulation}
              gds-zap-gds-name   {&tabulation}
              gds-zap-unit-base  {&tabulation}
              excel-qnty(gds-zap-qnty)      {&tabulation}
              excel-sum(gds-zap-price-base) {&tabulation}
              excel-sum(gds-zap-stoim-base) {&tabulation}
              excel-sum(gds-zap-Nds)        {&tabulation}
              excel-sum(gds-zap-Np )        {&tabulation}
              excel-sum(tot_tqnty  )         skip.

       End.
       
            Assign TOT-1   = tot-1   + gds-zap-qnty                TOT-3-1 = tot-3-1 + gds-zap-qnty        TOT-0-1 = tot-0-1 + gds-zap-qnty
                   TOT-2   = tot-2   + gds-zap-stoim-base          TOT-3-2 = tot-3-2 + gds-zap-stoim-base  TOT-0-2 = tot-0-2 + gds-zap-stoim-base
                   TOT-3   = tot-3   + tot_tqnty                   TOT-3-3 = tot-3-3 + tot_tqnty           TOT-0-3 = tot-0-3 + tot_tqnty
                   TOT-4   = tot-4   + gds-zap-Nds                 TOT-3-4 = tot-3-4 + gds-zap-Nds         TOT-0-4 = tot-0-4 + gds-zap-Nds
                   TOT-5   = tot-5   + gds-zap-Np                  TOT-3-5 = tot-3-5 + gds-zap-Np          TOT-0-5 = tot-0-5 + gds-zap-Np
                   TOT-1-1 = tot-1-1 + gds-zap-qnty                TOT-2-1 = tot-2-1 + gds-zap-qnty
                   TOT-1-2 = tot-1-2 + gds-zap-stoim-base          TOT-2-2 = tot-2-2 + gds-zap-stoim-base
                   TOT-1-3 = tot-1-3 + tot_tqnty                   TOT-2-3 = tot-2-3 + tot_tqnty
                   TOT-1-4 = tot-1-4 + gds-zap-Nds                 TOT-2-4 = tot-2-4 + gds-zap-Nds
                   TOT-1-5 = tot-1-5 + gds-zap-Np                  TOT-2-5 = tot-2-5 + gds-zap-Np
                   .
      END.
END PROCEDURE.


Procedure Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
if Nx = 1 Then DO:
             DISPLAY stream  OutStream {&all-sym12}
                           "Итого по : "  @ gds-zap-artic
                           trim(Name)  @ gds-zap-gds-name
                           Tot-1-1  @ gds-zap-qnty
                           Tot-1-2  @ gds-zap-stoim-base
                           Tot-1-4  @ gds-zap-Nds
                           Tot-1-5  @ gds-zap-Np
                           Tot-1-3  @ tot_tqnty
                              with FRAME  zapas    .
            DOWN stream  OutStream 1 with FRAME zapas    .

          {&PutExcel}  "Итого по : " + trim(Name)
              {&tabulation} {&tabulation} {&tabulation} {&tabulation}
               {&tabulation}
              excel-qnty(Tot-1-1)         {&tabulation}
                                          {&tabulation}
              excel-qnty(Tot-1-2) {&tabulation}
              excel-sum(Tot-1-4)  {&tabulation}
              excel-sum(Tot-1-5)  {&tabulation}
              excel-sum(Tot-1-3)  skip
                .

            IF NOT Sums-Only THEN Run U-LINE.
                Assign
                  Tot-1-1 = 0
                  Tot-1-2 = 0
                  Tot-1-3 = 0
                  Tot-1-4 = 0
                  Tot-1-5 = 0 .
          End.
if Nx = 2 Then DO:
             DISPLAY stream  OutStream {&all-sym11}
                           "Итого по : " + trim(Name)  @ gds-zap-gds-name
                           Tot-2-1  @ gds-zap-qnty
                           Tot-2-2  @ gds-zap-stoim-base
                           Tot-2-4  @ gds-zap-Nds
                           Tot-2-5  @ gds-zap-Np
                           Tot-2-3  @ tot_tqnty
                              with FRAME  zapas    .
        DOWN stream  OutStream 1 with FRAME zapas    .
        {&PutExcel}  " "  {&tabulation}
              "Итого по : " + trim(Name)
            {&tabulation} {&tabulation} {&tabulation}   {&tabulation}
            excel-qnty(Tot-2-1)  {&tabulation} {&tabulation}
            excel-sum( Tot-2-2)     {&tabulation}
            excel-sum(Tot-2-4)     {&tabulation}
            excel-sum(Tot-2-5)     {&tabulation}
            excel-sum(Tot-2-3)     skip .

          IF NOT Sums-Only THEN Run U-LINE.
              Assign
                Tot-2-1 = 0
                Tot-2-2 = 0
                Tot-2-3 = 0
                Tot-2-4 = 0
                Tot-2-5 = 0 .
        End.
if Nx = 3 Then DO:
     IF  ( Show-Negativ = no  AND ( Tot-3-1  = 0 and  Tot-3-2 = 0)) then next.
             DISPLAY stream  OutStream {&all-sym12}
                           "Итого по пост-ку" @ gds-zap-artic
                           trim(Name)  @ gds-zap-gds-name
                           Tot-3-1  @ gds-zap-qnty
                           Tot-3-2  @ gds-zap-stoim-base
                           Tot-3-4  @ gds-zap-Nds
                           Tot-3-5  @ gds-zap-Np
                           Tot-3-3  @ tot_tqnty
                              with FRAME  zapas    .
        DOWN stream  OutStream 1 with FRAME zapas    .
          {&PutExcel} " "  {&tabulation} "Итого" {&tabulation}
                "по пост-ку " + trim(Name)
               {&tabulation} {&tabulation} {&tabulation}
              excel-qnty(Tot-3-1)  {&tabulation} {&tabulation}
              excel-sum( Tot-3-2)       {&tabulation}
              excel-sum(Tot-3-4 )       {&tabulation}
              excel-sum( Tot-3-5)       {&tabulation}
              excel-sum(Tot-3-3)        skip .

            IF NOT Sums-Only THEN Run U-LINE.
                Assign
                  Tot-3-1 = 0
                  Tot-3-2 = 0
                  Tot-3-3 = 0
                  Tot-3-4 = 0
                  Tot-3-5 = 0 .

          end.
if Nx = 0 Then DO:
             DISPLAY stream  OutStream {&all-sym12}
                           "Итого  объект: "  @ gds-zap-artic
                           trim(Name)  @ gds-zap-gds-name
                           Tot-0-1  @ gds-zap-qnty
                           Tot-0-2  @ gds-zap-stoim-base
                           Tot-0-4  @ gds-zap-Nds
                           Tot-0-5  @ gds-zap-Np
                           Tot-0-3  @ tot_tqnty
                              with FRAME  zapas    .
            DOWN stream  OutStream 1 with FRAME zapas    .

          {&PutExcel}  "Итого по объекту: " + trim(Name)
              {&tabulation} {&tabulation} {&tabulation} {&tabulation}   {&tabulation}
              excel-qnty(Tot-0-1)          {&tabulation}
                                                     {&tabulation}
              excel-sum(Tot-0-2 )    {&tabulation}
              excel-sum(Tot-0-4 )   {&tabulation}
              excel-sum(Tot-0-5 )   {&tabulation}
              excel-sum(Tot-0-3 )   skip
                .

            IF NOT Sums-Only THEN Run U-LINE.
                Assign
                  Tot-0-1 = 0
                  Tot-0-2 = 0
                  Tot-0-3 = 0
                  Tot-0-4 = 0
                  Tot-0-5 = 0 .
          End.

 END PROCEDURE.


PROCEDURE U-LINE :
 UNDERLINE stream OutStream
    sym1
    gds-zap-b-code
    sym2
    gds-zap-artic
    sym3
    gds-post-artic
    sym12
    gds-zap-gds-name
    sym4
    gds-zap-unit-base
    sym5
    gds-zap-qnty
    sym6
    gds-zap-price-base
    sym7
    gds-zap-stoim-base
    sym8
    gds-zap-Nds
    sym9
    gds-zap-NP
    sym10
    tot_tqnty
    sym11
  with FRAME zapas .
  DOWN stream  OutStream 1 with FRAME zapas.
END PROCEDURE.
/*-------------------------------------------------для объекты раздельно-------------------------------------------------*/
Procedure Tmp-create :
define input parameter p1   like ub.clients.obj-code  no-undo .
define input parameter p2   like ub.clients.obj-type  no-undo .
define input parameter Name like ub.clients.obj-name  no-undo .
define input parameter p3   like obj-list.obj-code no-undo .
define input parameter p4   like obj-list.obj-type no-undo .
  Create tmp-cli-gds.
  Assign
      tmp-cli-gds.Tot-3-1  = Tot-3-1
      tmp-cli-gds.Tot-3-2  = Tot-3-2
      tmp-cli-gds.Tot-3-4  = Tot-3-4
      tmp-cli-gds.Tot-3-5  = Tot-3-5
      tmp-cli-gds.Tot-3-3  = Tot-3-3
      tmp-cli-gds.cli-code = p1
      tmp-cli-gds.cli-type = p2
      tmp-cli-gds.Name     = Name
      tmp-cli-gds.obj-code = p3
      tmp-cli-gds.obj-type = p4
      .
 END PROCEDURE.


Procedure Tmp-clear :
 Assign
    Tot-3-1 = 0
    Tot-3-2 = 0
    Tot-3-4 = 0
    Tot-3-5 = 0
    Tot-3-3 = 0
    .
END PROCEDURE.


Procedure Tmp-assign :
 Assign
    Tot-3-1 = Tot-3-1 + tmp-cli-gds.Tot-3-1
    Tot-3-2 = Tot-3-2 + tmp-cli-gds.Tot-3-2
    Tot-3-4 = Tot-3-4 + tmp-cli-gds.Tot-3-4
    Tot-3-5 = Tot-3-5 + tmp-cli-gds.Tot-3-5
    Tot-3-3 = Tot-3-3 + tmp-cli-gds.Tot-3-3
    .
END PROCEDURE.
/* $Workfile$ e n d */