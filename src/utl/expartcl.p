block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: expartcl.p $
$Archive: utl/expartcl.p $

Описание программы
Экспорт  артикул поставщика в файл
Автор: Румянцев Юрий Александрович
Дата создания: 03/17/08
Author: Yuri Rumyantsev
Creation date: 03/17/08

*/
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: expartcl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/expartcl.p $":U .
define variable vss-description as character no-undo initial "Экспорт  артикул поставщика в файл":U .

{ cmp/vssrevis.i " " }

define buffer buf_cli-gds for ub.cli-gds.

DEF VAR g-log AS LOG NO-UNDO.

def stream txt.


g-log = no.
message "Экспорт артикул поставщика в файл." skip (2)
        "Продолжать ?"
        view-as alert-box question buttons OK-Cancel update g-log.

if not g-log then return.

output stream txt to value ("Artic-Client.txt") no-echo.


for each buf_cli-gds no-lock :

    display
        buf_cli-gds.artic
        with frame ff view-as dialog-box
    title ": Экспорт ".
    pause 0.

    IF trim(buf_cli-gds.cli-art) = "" THEN NEXT.

    put stream txt  unformatted
      buf_cli-gds.cli-type + ";" +
      trim(string(buf_cli-gds.cli-code)) + ";" +
      trim(string(buf_cli-gds.host-code)) + ";" +
      buf_cli-gds.artic + ";" +
      buf_cli-gds.prod-type + ";" +
      trim(string(buf_cli-gds.prod-code)) + ";" +
      buf_cli-gds.cli-art
    SKIP.


END.
output close.
message "Экспорт закончен."  view-as alert-box information buttons ok.