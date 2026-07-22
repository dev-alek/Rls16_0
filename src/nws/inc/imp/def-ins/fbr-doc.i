/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях строк документа производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/
define buffer buf_fbr-line for ub.fbr-line.
define buffer buf_fbr-recipe     for ub.fbr-recipe.
define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.


def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.