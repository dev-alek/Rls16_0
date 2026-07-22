block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pop-up.p $
$Archive: gbl/pop-up.p $

Форсировать вывод на экран поп-ап меню привязанного к виджету

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

/*handle виджета на который хотим напустить поп-ап меню*/
define input parameter wh as widget-handle.
/*если no - то меню привязано к левой кнопке мыши если yes то к правой*/
define input parameter l-r as logical.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pop-up.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/pop-up.p $":U .
def var vss-description as character no-undo init "Форсировать вывод на экран поп-ап меню привязанного к виджету".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/windows.i  }

     run CenterMouseCursor(wh).
     run Apply-mouse-menu-click(wh).

return.

PROCEDURE CenterMouseCursor:
/*------------------------------------------------------------------------------
Purpose:     Move the mouse cursor to the middle of a widget
Parameters:  the widget-handle
------------------------------------------------------------------------------*/
   DEFINE INPUT PARAMETER  p-wh   AS WIDGET-HANDLE  NO-UNDO.

   DEF VAR lppoint     AS MEMPTR  NO-UNDO.  /* POINT FAR*  */
   DEF VAR ReturnValue AS INTEGER NO-UNDO.
   SET-SIZE(lppoint)= 2 * {&INTSIZE}.

   PUT-{&INT}(lppoint,1 + 0 * {&INTSIZE})=INTEGER(p-wh:WIDTH-PIXELS / 2).
   PUT-{&INT}(lppoint,1 + 1 * {&INTSIZE})=INTEGER(p-wh:HEIGHT-PIXELS / 2).
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

   DEF VAR ReturnValue AS INTEGER NO-UNDO.
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