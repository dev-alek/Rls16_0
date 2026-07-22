/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать в текс и в EXCEL истории формаирования списка {1}

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

PrnLibStream должен быть открыт

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }
{ gbl/prn-lib.i }

procedure lhistprex-print-{1}-excel :
define input parameter p-text  as logical no-undo .
define input parameter p-excel as logical no-undo .
define input parameter p-sheet-num as integer no-undo .

define buffer buf_lh-sheetf for sheetf.
define buffer buf_{1} for {1}.


  do
  on error undo, return error
  :
    find first buf_{1} no-lock where buf_{1}.id = 0 no-error .
    if p-excel then do:
      {&pageExcel}
      FInd first buf_lh-Sheetf where
                buf_lh-Sheetf.sheet-num = p-sheet-num No-ERROR.
      if not avail buf_lh-sheetf then
      create buf_lh-sheetf.
      assign
      buf_lh-Sheetf.Sheet-num = 2
      buf_lh-sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
      buf_lh-sheetf.sizes = "9,9,9,12,155"
      .
      run rep/extitlee.p (input p-sheet-num
                    , input  substitute("История создания списка &1 &2"
                                ,
&if "{2}" = "" &then '' &else  {2} &endif
                                ,(if available buf_{1}
                                then buf_{1}.des
                                else "БЕЗЫМЯННЫЙ"))
                    ) .
    end.
    if p-text then do:
      Page stream PrnLibStream.
      PUT  STREAM PrnLibStream unformatted
      SPACE(25) substitute("История создания списка &1 &2"
                          , &if "{2}" = "" &then '' &else  {2} &endif
                          ,(if available buf_{1}
                          then buf_{1}.des
                          else "БЕЗЫМЯННЫЙ")) skip(0)
      space(25) cur-time-print() skip(1)
      .
      put stream PrnLibStream unformatted
      string("№", "X(9)") {&space-char}
      string("Действие", "X(9)") {&space-char}
      string("записей", "X(9)") {&space-char}
      string(" = итого", "X(12)") {&space-char}
      (if page-size(PrnLibStream) > {&LS_PS_A4}
      then string("Множество", "X(" + string({&A4_CW0} - 43) + ")")
      else string("Множество", "X(" + string({&A4_LS} - 43) + ")")
      )
      skip(0)
      fill('-':U, 9) {&space-char}
      fill('-':U, 9) {&space-char}
      fill('-':U, 9) {&space-char}
      fill('-':U, 12) {&space-char}
      (if page-size(PrnLibStream) > {&LS_PS_A4}
      then fill('-':U, {&A4_CW0} - 43)
      else fill('-':U, {&A4_LS} - 43))
      skip(0)
      .
    end.
    for each buf_{1} where buf_{1}.id > 0
    by buf_{1}.id
    :
      if p-text then do:
        put stream PrnLibStream unformatted
        (if buf_{1}.line = 0
        then string(buf_{1}.id, ">>>>>>>>9")
        else fill({&space-char} , 9)
        )  {&space-char}
        (if buf_{1}.item_ <> '':U
        then string(buf_{1}.hist-mode, "X(8)")
        else fill( {&space-char}, 8)) {&space-char}
        string(buf_{1}.num-add, ">>>>>>>>9") {&space-char} {&space-char} {&space-char} {&space-char}
        string(buf_{1}.num-recs, ">>>>>>>>9")  {&space-char}
        (if page-size(PrnLibStream) > {&LS_PS_A4}
        then string(buf_{1}.des, "X(" + string({&A4_CW0} - 43) + ")")
        else string(buf_{1}.des, "X(" + string({&A4_LS} - 43) + ")"))
        skip.
      end.
      if p-excel then do:
        {&PutExcel}
        (if buf_{1}.line = 0
        then string(buf_{1}.id, ">>>>>>>>9")
        else '':U)
        {&tabulation}
        (if buf_{1}.item_ <> '':U
        then buf_{1}.hist-mode
        else '':U)  {&tabulation}
        (if buf_{1}.item_ <> '':U
        then string(buf_{1}.num-add, "->>>>>>>>9")
        else '':U)  {&tabulation}
        (if buf_{1}.item_ <> '':U
        then string(buf_{1}.num-recs, ">>>>>>>>9")
        else '':U)  {&tabulation}
        buf_{1}.des
        skip.
      end. /*if p-excel*/
    end. /*
    for each buf_{1} where buf_{1}.id > 0
    by buf_{1}.id
    : */

  end. /*doe*/

end procedure. /* lhistprex-print-list-hist-excel */


/* $Workfile$ */