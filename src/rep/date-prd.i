/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

используется в окне выбора месяца для помесячных отчетов

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/
define variable CurrMonth  as       integer    no-undo.
define variable CurrYear   as      integer    no-undo.
define variable DatasBuf   as      character  no-undo.

&if "{1}" = "StartDate" &then
    get-key-value section "REP-SETS" key "StartDate" value LifeStartDate.
&endif
    assign
        CurrMonth = month ( date ( LifeStartDate ) )
        CurrYear = year ( date ( LifeStartDate ) ) .
    do while CurrYear < year ( today ) :
        do while CurrMonth <= 12 :
            DatasBuf = DatasBuf +
                string ( CurrMonth, "99" ) + fill( " ", 5 ) + string ( CurrYear, "9999" ) + "," .
            CurrMonth = CurrMonth + 1 .
        end.
        assign
            CurrMonth = 1
            CurrYear = CurrYear + 1 .
    end.

    do CurrMonth = 1 to month ( today ) :
        DatasBuf = DatasBuf +
                            string ( CurrMonth, "99" ) + fill( " ", 5 ) + string ( CurrYear, "9999" ) + "," .
    end.
    TimePeriod:list-items in frame {&frame-name} = right-trim ( datasbuf, "," ) .
    stat = TimePeriod:scroll-to-item( TimePeriod:num-items in frame {&frame-name} )
        in frame {&frame-name} .