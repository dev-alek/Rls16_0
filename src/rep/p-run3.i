/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок оборотки по поставщикам слитно

Автор: Чернова Светлана Александровна
Дата создания: 05/07/08
Author: Svetlana Chernova
Creation date: 05/07/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.

For each obj-list no-lock
  , each post-stk-line  no-lock where
                                  post-stk-line.obj-type = obj-list.obj-type and
                                  post-stk-line.obj-code = obj-list.obj-code and
                                  post-stk-line.fact-order >= null-fact-order   and
                                  post-stk-line.fact-order <= fact-order-2   and
                                  post-stk-line.sum-type    = {&arh-cost}    and
                                  post-stk-line.cat-id      = {&single-cat-id}
                                  {&f3}
                                  {&p1}
                                  &if not ( "{&f2}" = "" and  "{&f45}" = "")  &then
                                  ,
        each ub.goods no-lock where
                                  ub.goods.artic     = post-stk-line.artic     and
                                  ub.goods.prod-type = post-stk-line.prod-type and
                                  ub.goods.prod-code = post-stk-line.prod-code {&f2} {&f45}
                                  &endif
                                  :

        find first  temp-t-post-stk-line where
          temp-t-post-stk-line.obj-type  = obj-list.obj-type       and
          temp-t-post-stk-line.obj-code  = obj-list.obj-code       and
          temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
          temp-t-post-stk-line.cli-code  = post-stk-line.cli-code  and
          temp-t-post-stk-line.artic     = post-stk-line.artic     and
          temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
          temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
          if not available temp-t-post-stk-line then do:
        &if  ( "{&f2}" = "" and  "{&f45}" = "")  &then
            find first  ub.goods no-lock where
                                  ub.goods.artic     = post-stk-line.artic     and
                                  ub.goods.prod-type = post-stk-line.prod-type and
                                  ub.goods.prod-code = post-stk-line.prod-code no-error .   &endif

            find first  prod-cli no-lock  where
                                      prod-cli.obj-type = post-stk-line.prod-type and
                                      prod-cli.obj-code = post-stk-line.prod-code
                                      no-error .
            find first  ub.clients  no-lock  where
                                      ub.clients.obj-type = post-stk-line.cli-type and
                                      ub.clients.obj-code = post-stk-line.cli-code no-error .

              Run create-temp-t-post-stk-line .
              if xLavel <> 0 THEN  DO:
                 temp-t-post-stk-line.goods-grp-name = n-lavel (temp-t-post-stk-line.goods-grp-name , xLavel ) .
              end.
        end.
        else do:
                assign
                  temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                .
        end.
end.
/* подтягивание остатков и сумм и печать */
CASE RetClassify :
when "grp-goods":U  then   DO:
for each temp-t-post-stk-line break
         by temp-t-post-stk-line.goods-grp-name
         by ( temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code) )
         &if  "{&b3}" <> ""   &then BY {&b3} &endif
         by  temp-t-post-stk-line.gds-code
         :
    if first-of( temp-t-post-stk-line.goods-grp-name) then do:
      Run Print-Header(1 , temp-t-post-stk-line.goods-grp-name ).
    end.
    if first-of(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) then do:
      Run Print-Header(3 , temp-t-post-stk-line.clients-obj-name).
    end.

    IF last-of(temp-t-post-stk-line.GDS-CODE) THEN DO:
    Assign
      Ostatok-end[1] = 0
      Ostatok-end[2] = 0
      Ostatok-end[8] = 0
      Ostatok-start[1] = 0
      Ostatok-start[2] = 0
      Ostatok-start[8] = 0

      .

    assign
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
      .

        for each OBJ-LIST :
        RUN Goods-start-O .
        RUN Goods-end-O .
        RUN ob-line (
                OBJ-LIST.obj-code    ,
                OBJ-LIST.obj-type    ,
                temp-t-post-stk-line.cli-code    ,
                temp-t-post-stk-line.cli-type    ,
                temp-t-post-stk-line.artic       ,
                temp-t-post-stk-line.prod-code   ,
                temp-t-post-stk-line.prod-type   ,
                Fact-order-1     ,
                Fact-order-2     ,
                t#sum-type       ,
                t#cat-id         ,
                ""               ,
                yes) .
      if Show-Sale Then  RUN ob-line (
                OBJ-LIST.obj-code    ,
                OBJ-LIST.obj-type    ,
            temp-t-post-stk-line.cli-code    ,
            temp-t-post-stk-line.cli-type    ,
            temp-t-post-stk-line.artic       ,
            temp-t-post-stk-line.prod-code   ,
            temp-t-post-stk-line.prod-type   ,
            Fact-order-1   ,
            Fact-order-2   ,
            {&arh-Sale}    ,
            {&single-cat-id} ,
            ""             ,
            yes) .
        end.
        RUN Calc-Sub-itog(0).
        if Show-Sale Then RUN Calc-Sub-itog(6).
        IF  NOT ( (ostatok-start[1] = 0  AND /* это нулевые строки */
                  Prih         [1] = 0  AND
                  RAsh         [1] = 0  AND
                  KAssa        [1] = 0  AND
                  Inv          [1] = 0  AND
                  vzvr         [1] = 0  AND
                  vzvr-post    [1] = 0  AND
                  ostatok-end  [1] = 0 )) then do:
            if not sums-only then do:
              run display-str1.
              run clear-item.
            end.
        End.
    run clear-item.
    End.

    if last-of(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) then do:
       Run Print-Footer(1 , temp-t-post-stk-line.clients-obj-name).
    end.

    if last-of( temp-t-post-stk-line.goods-grp-name) then do:
       Run Print-Footer(2 , temp-t-post-stk-line.goods-grp-name ).
       run clear-item.
    end.
end.
end.

/* без класс*/
when "no-classify":U  then   DO:
for each temp-t-post-stk-line break
         by ( temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code) )
         &if  "{&b3}" <> ""   &then BY {&b3} &endif
         by  temp-t-post-stk-line.gds-code
         :
    if not sums-only then do:
        if first-of(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) then do:
          Run Print-Header(3 , temp-t-post-stk-line.clients-obj-name).
        end.
    end.

    IF last-of(temp-t-post-stk-line.GDS-CODE) THEN DO:
    Assign
      Ostatok-end[1] = 0
      Ostatok-end[2] = 0
      Ostatok-end[8] = 0
      Ostatok-start[1] = 0
      Ostatok-start[2] = 0
      Ostatok-start[8] = 0

      .

    assign
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
      .

        for each OBJ-LIST :
        RUN Goods-start-O .
        RUN Goods-end-O .
        RUN ob-line (
                OBJ-LIST.obj-code    ,
                OBJ-LIST.obj-type    ,
                temp-t-post-stk-line.cli-code    ,
                temp-t-post-stk-line.cli-type    ,
                temp-t-post-stk-line.artic       ,
                temp-t-post-stk-line.prod-code   ,
                temp-t-post-stk-line.prod-type   ,
                Fact-order-1     ,
                Fact-order-2     ,
                t#sum-type       ,
                t#cat-id         ,
                ""               ,
                yes) .
      if Show-Sale Then  RUN ob-line (
                OBJ-LIST.obj-code    ,
                OBJ-LIST.obj-type    ,
            temp-t-post-stk-line.cli-code    ,
            temp-t-post-stk-line.cli-type    ,
            temp-t-post-stk-line.artic       ,
            temp-t-post-stk-line.prod-code   ,
            temp-t-post-stk-line.prod-type   ,
            Fact-order-1   ,
            Fact-order-2   ,
            {&arh-Sale}    ,
            {&single-cat-id} ,
            ""             ,
            yes) .
        end.
        RUN Calc-Sub-itog(0).
        if Show-Sale Then RUN Calc-Sub-itog(6).
        IF  NOT ( (ostatok-start[1] = 0  AND /* это нулевые строки */
                  Prih         [1] = 0  AND
                  RAsh         [1] = 0  AND
                  KAssa        [1] = 0  AND
                  Inv          [1] = 0  AND
                  vzvr         [1] = 0  AND
                  vzvr-post    [1] = 0  AND
                  ostatok-end  [1] = 0 )) then do:
            if not sums-only then do:
              run display-str1.
              run clear-item.
            end.
        End.
    run clear-item.
    End.

    if last-of(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) then do:
       Run Print-Footer(1 , temp-t-post-stk-line.clients-obj-name).
    end.
end.
end.
end case.
/* $Workfile$ e n d */