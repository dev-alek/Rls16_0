/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&if {1} = 'oborot-doc' &then
if  not (
   ({3}ostatok-start[1] = 0  and
    {3}Prih         [1] = 0  AND
    {3}RAsh         [1] = 0  AND
    {3}KAssa        [1] = 0  AND
    {3}Inv          [1] = 0  AND
    {3}vzvr         [1] = 0  AND
    {3}spis         [1] = 0  AND
    {3}vzvr-post    [1] = 0  AND
    {3}Ostatok-end  [1] = 0)) then DO:
    &if {2} = 'nex' &then
             DISPLAY stream  OutStream {&ALL-Sym} sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                {3}ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                {3}Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                {3}RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                {3}KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                {3}Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                {3}spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                {3}vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                {3}vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                {3}Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               {&WFz} .
               {&FRAME-d}.
    &endif
    &if {2} = 'ex' &then
    {&PutExcel} p3 {&tabulation}
                p4 {&tabulation}
                p5 {&tabulation}
                p6 {&tabulation}
                   ( excel-qnty({3}ostatok-start[1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}ostatok-start[2]) +  {&tabulation})   else ("")
if Show-sale  then  ( "" +                              {&tabulation})   else ("")
if xShowgoods then  ( excel-qnty({3}ostatok-start[7]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}Prih         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}Prih         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}Prih         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}RAsh         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}RAsh         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}RAsh         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}KAssa        [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}KAssa        [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}KAssa        [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}Inv          [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}Inv          [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}Inv          [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}spis         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}spis         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}spis         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}vzvr         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}vzvr         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}vzvr         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}vzvr-post    [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}vzvr-post    [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}vzvr-post    [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}Ostatok-end  [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}Ostatok-end  [2]) +  {&tabulation})   else ("")
if Show-sale  then  (  "" +                             {&tabulation})   else ("")
if xShowgoods then  ( excel-qnty({3}ostatok-end[7]) +  {&tabulation})   else ("")
   {&new-line}.
   &endif
end.
&endif
&if {1} = 'oborot' &then
    &if {2} = 'nex' &then
             DISPLAY stream  OutStream {&ALL-Sym} sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                {3}ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                {3}Prih         [p2]  @  F-Prih
                {3}RAsh         [p2]  @  F-RAsh
                {3}KAssa        [p2]  @  F-KAssa
                {3}Inv          [p2]  @  F-Inv
                {3}spis         [p2]  @  F-spis
                {3}vzvr         [p2]  @  F-vzvr
                {3}vzvr-post    [p2]  @  F-vzvr-post
                {3}Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               {&WFz} .
    &endif
    &if {2} = 'ex' &then
    {&PutExcel} p3 {&tabulation}
                p4 {&tabulation}
                p5 {&tabulation}
                p6 {&tabulation}
                   ( excel-qnty({3}ostatok-start[1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}ostatok-start[2]) +  {&tabulation})   else ("")
if Show-sale  then  ( "" +                              {&tabulation})   else ("")
                   ( excel-qnty({3}Prih         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}Prih         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}Prih         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}RAsh         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}RAsh         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}RAsh         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}KAssa        [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}KAssa        [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}KAssa        [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}Inv          [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}Inv          [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}Inv          [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}spis         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}spis         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}spis         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}vzvr         [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}vzvr         [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}vzvr         [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}vzvr-post    [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}vzvr-post    [2]) +  {&tabulation})   else ("")
if Show-sale  then  ( excel-sum({3}vzvr-post    [8]) +  {&tabulation})   else ("")
                   ( excel-qnty({3}Ostatok-end  [1]) +  {&tabulation})
if Show-cost  then  ( excel-sum({3}Ostatok-end  [2]) +  {&tabulation})   else ("")
if Show-sale  then  (  "" +                             {&tabulation})   else ("")
   {&new-line}.
   &endif
&endif


&if {1} = 'oborot-pri' &then
    {&PutExcel} p3 {&tabulation}
                p4 {&tabulation}
                p5 {&tabulation}
                p6 {&tabulation}
                gds-zap-type {&tabulation}
                {3}Prih[1]  {&tabulation}

if Showcost       then (     excel-sum({3}Prih [2]) + {&tabulation}   ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}Prih [3]) + {&tabulation}   ) else ("")
if Showsale       then (     excel-sum  (   {3}Prih [5]) + {&tabulation}   ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}Prih [6]) + {&tabulation}   ) else ("")

                  {3}RAsh         [1] FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}RAsh[2] )  + {&tabulation}   ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}RAsh[3] )  + {&tabulation}   ) else ("")
if Showsale       then (     excel-sum  (   {3}RAsh[5] )  + {&tabulation}   ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}RAsh[6] )  + {&tabulation}   ) else ("")

                 {3}KAssa        [1] FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}KAssa[2])  + {&tabulation}    ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}KAssa[3])  + {&tabulation}    ) else ("")
if Showsale       then (     excel-sum  (   {3}KAssa[5])  + {&tabulation}    ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}KAssa[6])  + {&tabulation}    ) else ("")
.


{&PutExcel}     {3}Inv            [1] FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}Inv [2] ) + {&tabulation}    ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}Inv [3] ) + {&tabulation}    ) else ("")
if Showsale       then (     excel-sum  (   {3}Inv [5] ) + {&tabulation}    ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}Inv [6] ) + {&tabulation}    ) else ("")

                 {3}vzvr         [1] FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}vzvr [2] ) + {&tabulation}    ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}vzvr [3] ) + {&tabulation}    ) else ("")
if Showsale       then (     excel-sum  (   {3}vzvr [5] ) + {&tabulation}    ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}vzvr [6] ) + {&tabulation}    ) else ("")

                {3}vzvr-post    [1] FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}vzvr-post[2] ) + {&tabulation}     ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}vzvr-post[3] ) + {&tabulation}     ) else ("")
if Showsale       then (     excel-sum  (   {3}vzvr-post[5] ) + {&tabulation}     ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}vzvr-post[6] ) + {&tabulation}     ) else ("")
         {&new-line}.

&endif
&if {1} = 'oborot-ras' &then
    {&PutExcel} p3 {&tabulation}
                p4 {&tabulation}
                p5 {&tabulation}
                p6 {&tabulation}
                gds-zap-type {&tabulation}
                 excel-qnty({3}RAsh         [1]  ) FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}RAsh[2] )  + {&tabulation}   ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}RAsh[3] )  + {&tabulation}   ) else ("")
if Showsale       then (     excel-sum  (   {3}RAsh[5] )  + {&tabulation}   ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}RAsh[6] )  + {&tabulation}   ) else ("")

                 excel-qnty({3}KAssa        [1]) FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}KAssa[2])  + {&tabulation}    ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}KAssa[3])  + {&tabulation}    ) else ("")
if Showsale       then (     excel-sum  (   {3}KAssa[5])  + {&tabulation}    ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}KAssa[6])  + {&tabulation}    ) else ("")
.

{&PutExcel}     excel-qnty( {3}Inv            [1] ) FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}Inv [2] ) + {&tabulation}    ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}Inv [3] ) + {&tabulation}    ) else ("")
if Showsale       then (     excel-sum  (   {3}Inv [5] ) + {&tabulation}    ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}Inv [6] ) + {&tabulation}    ) else ("")

                 excel-qnty({3}vzvr         [1]) FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}vzvr [2] ) + {&tabulation}    ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}vzvr [3] ) + {&tabulation}    ) else ("")
if Showsale       then (     excel-sum  (   {3}vzvr [5] ) + {&tabulation}    ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}vzvr [6] ) + {&tabulation}    ) else ("")

                excel-qnty({3}vzvr-post    [1]) FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}vzvr-post[2] ) + {&tabulation}     ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}vzvr-post[3] ) + {&tabulation}     ) else ("")
if Showsale       then (     excel-sum  (   {3}vzvr-post[5] ) + {&tabulation}     ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}vzvr-post[6] ) + {&tabulation}     ) else ("")

                excel-qnty({3}spis    [1] ) FORMAT "->>>>>>>>>>>9.<<<"  {&tabulation}
if Showcost       then (     excel-sum  (   {3}spis[2] ) + {&tabulation}     ) else ("")
if Show-cost-vat  then (     excel-sum  (   {3}spis[3] ) + {&tabulation}     ) else ("")
if Showsale       then (     excel-sum  (   {3}spis[5] ) + {&tabulation}     ) else ("")
if Show-sale-vat  then (     excel-sum  (   {3}spis[6] ) + {&tabulation}     ) else ("")
         {&new-line}.

&endif
&if {1} = 'bonus' &then
    &if {2} = 'nex' &then
              DISPLAY stream  OutStream  {&ALL-Sym9}
                p3               @ gds-zap-b-code
                p4               @ gds-zap-artic
                p5               @ gds-zap-gds-name
                v-bonus[1]       @  F-bonus
                v-price-sale[1]  @  F-price-sale
                v-kassa[1]       @  F-kassa
                v-bonus-dohod[1] @  F-bonus-dohod
                v-nacenka[1]     @  F-nacenka
                {&WFz} .
    &endif
    &if {2} = 'ex' &then
    {&PutExcel} p3 {&tabulation}
                p4 {&tabulation}
                p5 {&tabulation}
                v-bonus       [1] FORMAT ">>9.99"        +  {&tabulation}
                v-price-sale  [1] FORMAT ">>>>>>>>9.99"  +  {&tabulation}
                v-kassa       [1] FORMAT "->>>>>>>>9.99" +  {&tabulation}
                v-bonus-dohod [1] FORMAT "->>>>>>>>9.99"  +  {&tabulation}
                v-nacenka     [1] FORMAT "->>9.99"
                {&new-line}.
   &endif
&endif