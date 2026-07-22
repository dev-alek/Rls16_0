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
&if {1} = 'oborot-pri' &then
             DISPLAY stream  OutStream {&ALL-Sym} sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
               {3}vzvr      [p2]    @  F-vzvr
               {3}vzvr-post [p2]    @  F-vzvr-post
               {3}Prih      [p2]    @  F-Prih
               {3}RAsh      [p2]    @  F-RAsh
               {3}KAssa     [p2]    @  F-KAssa
               {3}Inv       [p2]    @  F-Inv
               {3}spis      [p2]    @  F-spis
               {3}sm        [p2]    @  F-sm
               {&WFz} .
&endif
&if {1} = 'oborot-ras' &then
             DISPLAY stream  OutStream {&ALL-Sym}
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
               {3}vzvr      [p2]    @  F-vzvr
               {3}vzvr-post [p2]    @  F-vzvr-post
               {3}RAsh      [p2]    @  F-RAsh
               {3}KAssa     [p2]    @  F-KAssa
               {3}Inv       [p2]    @  F-Inv
               {3}spis      [p2]    @  F-spis
               {&WFz} .
&endif