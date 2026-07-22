/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/21/06
Author: Svetlana Chernova
Creation date: 03/21/06

*/
  RUN get-attribute IN THIS-PROCEDURE ('UIB-MODE').
  IF RETURN-VALUE NE "DESIGN" THEN DO:
    RUN get-link-handle IN adm-broker-hdl ( THIS-PROCEDURE, {1} , OUTPUT source-str ).
    State-source = WIDGET-HANDLE ( source-str ).
    IF not VALID-HANDLE ( State-source ) THEN
      Message "Не определен линк " {1} view-as alert-box error.
  END.