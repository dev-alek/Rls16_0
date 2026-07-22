block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: num-rus.p $
$Archive: gbl/num-rus.p $

сумма прописью без указания валюты

Автор: Булгаков Андрей Николаевич
Дата создания: 09/20/94
Author: Andrew Bulgakoff
Creation date: 09/20/94

*/

/* добавлены пробелы для интернализации */
define  input parameter  InSum as decimal   no-undo .
define output parameter OutSum as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: num-rus.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/num-rus.p $":U .
define variable vss-description as character no-undo initial "сумма прописью без указания валюты":U .

{ cmp/vssrevis.i }

define variable Formatted as character no-undo .
define variable Word      as character no-undo .
define variable II        as integer   no-undo .

/*                                 123456789012345678 */
assign
  Formatted = string( abs( InSum ), "999999999999999.99":U )
  II        = length( Formatted ) - 3
.
L1:
do while ( II >= 3 ) :
  if substring( Formatted, II - 2, 3 ) = "000"
  then do:
    assign
      II = II - 3
    .
    next L1 .
  end.
  if II = 12
  then do:
    assign
      Word =  "тысяч          "
    .
  end.
  if II =  9
  then do:
    assign
      Word =  "миллион        "
    .
  end.
  if II =  6
  then do:
    assign
      Word =  "миллиард       "
    .
  end.
  if II =  3
  then do:
    assign
      Word =  "триллион       "
    .
  end.
  if II < 15 then do:
    if substring( Formatted, II,     1 )  = "1" and
       substring( Formatted, II - 1, 1 ) <> "1" and II = 12
    then do:
      assign
        Word = trim( Word ) + "а"
      .
    end.
    if substring( Formatted, II, 1 ) = "2" or
       substring( Formatted, II, 1 ) = "3" or
       substring( Formatted, II, 1 ) = "4"
    then do:
      if II = 12
      then do:
        if substring( Formatted, II - 1, 1 ) <> "1"
        then do:
          assign
            Word = trim( Word ) + "и"
          .
        end.
      end.
      else do:
        if substring( Formatted, II - 1, 1 ) <> "1"
        then do:
          assign
            Word = trim( Word ) + "а"
          .
        end.
      end.
    end.
    if ( substring( Formatted, II,     1 ) <> "1" and
         substring( Formatted, II,     1 ) <> "2" and
         substring( Formatted, II,     1 ) <> "3" and
         substring( Formatted, II,     1 ) <> "4" and II <> 12 ) or
       ( substring( Formatted, II - 1, 1 )  = "1" and II <  12 )
    then do:
      assign
        Word = trim( Word ) + "ов"
      .
    end.
    if Word <> "":U
    then do:
      assign
        OutSum = trim( Word ) + " ":U + trim( OutSum )
      .
    end.
  end. /* II < 15 */
  if substring( Formatted, II - 1, 1 ) <> "1"
  then do:
    { rep/assword.i
        " "
        "один   "
        "два   "
        "три   "
        "четыре   "
        "пять   "
        "шесть   "
        "семь   "
        "восемь   "
        "девять   "
    }
    if II                            = 12  and
       substring( Formatted, II, 1 ) = "1"
    then do:
      assign
        Word = "одна   "
      .
    end.
    if II                            = 12  and
       substring( Formatted, II, 1 ) = "2"
    then do:
      assign
        Word = "две    "
      .
    end.
    if Word <> "":U
    then do:
      assign
        OutSum = trim( Word ) + " ":U + trim( OutSum )
      .
    end.
    assign
      II = II - 1
    .
    { rep/assword.i
        " "
        " "
        "двадцать   "
        "тридцать    "
        "сорок   "
        "пятьдесят   "
        "шестьдесят   "
        "семьдесят   "
        "восемьдесят   "
        "девяносто   "
    }
  end.
  else do:
    { rep/assword.i
        "десять   "
        "одиннадцать   "
        "двенадцать   "
        "тринадцать   "
        "четырнадцать   "
        "пятнадцать   "
        "шестнадцать   "
        "семнадцать   "
        "восемнадцать   "
        "девятнадцать   "
    }
    assign
      II = II - 1
    .
  end.
  if Word <> "":U
  then do:
    assign
      OutSum = trim( Word ) + " ":U + trim( OutSum )
    .
  end.
  assign
    II = II - 1
  .
  { rep/assword.i
      " "
      "сто         "
      "двести         "
      "триста         "
      "четыреста          "
      "пятьсот          "
      "шестьсот         "
      "семьсот         "
      "восемьсот          "
      "девятьсот          "
  }
  if Word <> "":U
  then do:
    assign
      OutSum = trim( Word ) + " ":U + trim( OutSum )
    .
  end.
  assign
    II = II - 1
  .
end. /* L1 */

