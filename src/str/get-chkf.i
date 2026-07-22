/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определения  для касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable path as char no-undo.
define variable atr as char no-undo.
define variable file as char no-undo.
define variable adr as char no-undo.
def stream DirStream .

define variable in_ as char no-undo.
define variable spl as char no-undo.
define variable sav as char no-undo.
define variable out as char no-undo.
define variable out2 as character no-undo .
define variable v-remote as char no-undo.
define variable v-dir-remote as character no-undo .
define variable v-dir-remote-tmp as character no-undo .
define variable yestr as character no-undo .
define variable kass-list as char no-undo.
define variable cycle as logical no-undo.
def buffer for-cash-desk for ub.cash-desk.
define variable jj as int no-undo.
define variable v-lock-global as logical no-undo.

def frame a
path format "x(30)"
with view-as dialog-box side-labels
size 50 by 4.17 three-d title "Обработка файла ...".

/* $Workfile$ e n d */