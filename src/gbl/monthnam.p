block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: monthnam.p $
$Archive: gbl/monthnam.p $

Имя месяца

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input  parameter p-month      as integer no-undo .
define output parameter p-month-name as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: monthnam.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/monthnam.p $":U .
def var vss-description as character no-undo init "Имя месяца".
{ cmp/vssrevis.i }

do
on error undo, return error return-value
:
  case p-month :
    when 1  then do:
      assign
        p-month-name = "ЯНВАРЬ"
      .
    end.
    when 2  then do:
      assign
        p-month-name = "ФЕВРАЛЬ"
      .
    end.
    when 3  then do:
      assign
        p-month-name = "МАРТ"
      .
    end.
    when 4  then do:
      assign
        p-month-name = "АПРЕЛЬ"
      .
    end.
    when 5  then do:
      assign
        p-month-name = "МАЙ"
      .
    end.
    when 6  then do:
      assign
        p-month-name = "ИЮНЬ"
      .
    end.
    when 7  then do:
      assign
        p-month-name = "ИЮЛЬ"
      .
    end.
    when 8  then do:
      assign
        p-month-name = "АВГУСТ"
      .
    end.
    when 9  then do:
      assign
        p-month-name = "СЕНТЯБРЬ"
      .
    end.
    when 10 then do:
      assign
        p-month-name = "ОКТЯБРЬ"
      .
    end.
    when 11 then do:
      assign
        p-month-name = "НОЯБРЬ"
      .
    end.
    when 12 then do:
      assign
        p-month-name = "ДЕКАБРЬ"
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение параметра p-month" skip
        "p-month" p-month skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .
end.