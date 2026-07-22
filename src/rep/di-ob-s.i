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
    DISPLAY stream  OutStream {&ALL-Sym}
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      {2}ostatok-start [p2] format "{1}" @  F-ostatok-start
      {2}Prih          [p2] format "{1}" @  F-Prih
      {2}RAsh          [p2] format "{1}" @  F-RAsh
      {2}KAssa         [p2] format "{1}" @  F-KAssa
      {2}Inv           [p2] format "{1}" @  F-Inv
      {2}Overturn      [p2] format "{1}" @  F-Overturn
      {2}Ostatok-end   [p2] format "{1}" @  F-Ostatok-end
      {2}gds-zap-other      format "{1}" when (p2 = 1) @  gds-zap-other
      {&WFz} .