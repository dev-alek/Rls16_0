/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях удалённых строк документа производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/
define buffer buf_c-fbr-line for ub.c-fbr-line.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.