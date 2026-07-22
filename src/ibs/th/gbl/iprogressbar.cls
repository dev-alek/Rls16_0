/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: iprogressbar.cls $
$Archive: ibs/th/gbl/iprogressbar.cls $

Интерфейс прогресс бара

Автор: Хныкин Павел Андреевич
Дата создания: 10/09/07
Author: Pavel Khnykin
Creation date: 10/09/07

*/
block-level on error undo, throw.
INTERFACE Ibs.Th.Gbl.IProgressBar:
  METHOD PUBLIC VOID show-bar ( ).
  METHOD PUBLIC VOID hide-bar ( ).
  METHOD PUBLIC VOID increment ( ).
END INTERFACE.
