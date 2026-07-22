block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcclick.p $
$Archive: gbl/frcclick.p $

Имитировать нажатие мыши

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/


/*handle виджета на который хотим кликнуть*/
define input parameter wh as widget-handle.
define input parameter wh-1 as widget-handle.
/*если no - то меню привязано к левой кнопке мыши если yes то к правой*/
define input parameter l-r as logical.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcclick.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/frcclick.p $":U .
define variable vss-description as character no-undo init "Имитировать нажатие мыши".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/windows.i  }

do
on error undo, return error return-value
:
  run MouseCursor in this-procedure
    (input wh
    ,input WH-1
    ).
  run Apply-mouse-menu-click in this-procedure
    (input wh
    ).
  return.
end.

PROCEDURE MouseCursor:
/*------------------------------------------------------------------------------
Purpose:     Move the mouse cursor to the middle of a widget or corner
Parameters:  the widget-handle
------------------------------------------------------------------------------*/
   DEFINE INPUT PARAMETER  p-wh   AS WIDGET-HANDLE  NO-UNDO.
   DEFINE INPUT PARAMETER  p-wh-1   AS WIDGET-HANDLE  NO-UNDO.

   define variable lppoint     AS MEMPTR  NO-UNDO.  /* POINT FAR*  */
   define variable ReturnValue AS INTEGER NO-UNDO.
   SET-SIZE(lppoint)= 2 * {&INTSIZE}.
 IF P-WH-1 = ? THEN DO:
      PUT-{&INT}(lppoint,1 + 0 * {&INTSIZE})=INTEGER(p-wh:WIDTH-PIXELS / 2).
      PUT-{&INT}(lppoint,1 + 1 * {&INTSIZE})=INTEGER(p-wh:HEIGHT-PIXELS / 2).
  END.
  ELSE DO:
      PUT-{&INT}(lppoint,1 + 0 * {&INTSIZE})=INTEGER(P-WH-1:x + p-wh-1:WIDTH-PIXELS / 2).
      PUT-{&INT}(lppoint,1 + 1 * {&INTSIZE})=INTEGER(P-WH-1:y - p-wh-1:HEIGHT-PIXELS / 2).
  END.

   RUN ClientToScreen in hpApi (INPUT p-wh:HWND,
                                INPUT GET-POINTER-VALUE(lppoint),
                                OUTPUT ReturnValue).
   RUN SetCursorPos in hpApi   (INPUT GET-{&INT}(lppoint,1 + 0 * {&INTSIZE}),
                                INPUT GET-{&INT}(lppoint,1 + 1 * {&INTSIZE}),
                                OUTPUT ReturnValue).
   SET-SIZE(lppoint)= 0.
   END PROCEDURE.

PROCEDURE Apply-mouse-menu-click:
/*------------------------------------------------------------------------------
Purpose:     Programatic click the right mouse button on a widget
Parameters:  Widget-handle on which you want to click
------------------------------------------------------------------------------*/
   DEFINE INPUT PARAMETER  p-wh   AS WIDGET-HANDLE  NO-UNDO.

   define variable ReturnValue AS INTEGER NO-UNDO.
   RUN SendMessage{&A} in hpApi (INPUT p-wh:HWND,

                                 INPUT (if l-r then {&WM_RBUTTONDOWN} else {&WM_LBUTTONDOWN}),
                                 INPUT (if l-r then {&MK_RBUTTON} else {&MK_LBUTTON}),
                                 INPUT 0,
                                 OUTPUT ReturnValue).
   RUN SendMessage{&A} in hpApi (INPUT p-wh:HWND,
                                 INPUT (if l-r then {&WM_RBUTTONUP} else {&WM_LBUTTONUP}),
                                 INPUT 0,
                                 INPUT 0,
                                 OUTPUT ReturnValue).
END PROCEDURE.