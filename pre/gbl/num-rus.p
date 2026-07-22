block-level on error undo, throw.
define  input parameter  InSum as decimal   no-undo .
define output parameter OutSum as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: num-rus.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/num-rus.p $":U .
define variable vss-description as character no-undo initial "сумма прописью без указания валюты":U .
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable Formatted as character no-undo .
define variable Word      as character no-undo .
define variable II        as integer   no-undo .
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
  end.
  if substring( Formatted, II - 1, 1 ) <> "1"
  then do:
assign
  Word = "":U
.
case substring( Formatted, II, 1 ) :
  when "0" then do:
    assign
      Word = " "
    .
  end.
  when "1" then do:
    assign
      Word = "один   "
    .
  end.
  when "2" then do:
    assign
      Word = "два   "
    .
  end.
  when "3" then do:
    assign
      Word = "три   "
    .
  end.
  when "4" then do:
    assign
      Word = "четыре   "
    .
  end.
  when "5" then do:
    assign
      Word = "пять   "
    .
  end.
  when "6" then do:
    assign
      Word = "шесть   "
    .
  end.
  when "7" then do:
    assign
      Word = "семь   "
    .
  end.
  when "8" then do:
    assign
      Word = "восемь   "
    .
  end.
  when "9" then do:
    assign
      Word = "девять   "
    .
  end.
end case.
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
assign
  Word = "":U
.
case substring( Formatted, II, 1 ) :
  when "0" then do:
    assign
      Word = " "
    .
  end.
  when "1" then do:
    assign
      Word = " "
    .
  end.
  when "2" then do:
    assign
      Word = "двадцать   "
    .
  end.
  when "3" then do:
    assign
      Word = "тридцать    "
    .
  end.
  when "4" then do:
    assign
      Word = "сорок   "
    .
  end.
  when "5" then do:
    assign
      Word = "пятьдесят   "
    .
  end.
  when "6" then do:
    assign
      Word = "шестьдесят   "
    .
  end.
  when "7" then do:
    assign
      Word = "семьдесят   "
    .
  end.
  when "8" then do:
    assign
      Word = "восемьдесят   "
    .
  end.
  when "9" then do:
    assign
      Word = "девяносто   "
    .
  end.
end case.
  end.
  else do:
assign
  Word = "":U
.
case substring( Formatted, II, 1 ) :
  when "0" then do:
    assign
      Word = "десять   "
    .
  end.
  when "1" then do:
    assign
      Word = "одиннадцать   "
    .
  end.
  when "2" then do:
    assign
      Word = "двенадцать   "
    .
  end.
  when "3" then do:
    assign
      Word = "тринадцать   "
    .
  end.
  when "4" then do:
    assign
      Word = "четырнадцать   "
    .
  end.
  when "5" then do:
    assign
      Word = "пятнадцать   "
    .
  end.
  when "6" then do:
    assign
      Word = "шестнадцать   "
    .
  end.
  when "7" then do:
    assign
      Word = "семнадцать   "
    .
  end.
  when "8" then do:
    assign
      Word = "восемнадцать   "
    .
  end.
  when "9" then do:
    assign
      Word = "девятнадцать   "
    .
  end.
end case.
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
assign
  Word = "":U
.
case substring( Formatted, II, 1 ) :
  when "0" then do:
    assign
      Word = " "
    .
  end.
  when "1" then do:
    assign
      Word = "сто         "
    .
  end.
  when "2" then do:
    assign
      Word = "двести         "
    .
  end.
  when "3" then do:
    assign
      Word = "триста         "
    .
  end.
  when "4" then do:
    assign
      Word = "четыреста          "
    .
  end.
  when "5" then do:
    assign
      Word = "пятьсот          "
    .
  end.
  when "6" then do:
    assign
      Word = "шестьсот         "
    .
  end.
  when "7" then do:
    assign
      Word = "семьсот         "
    .
  end.
  when "8" then do:
    assign
      Word = "восемьсот          "
    .
  end.
  when "9" then do:
    assign
      Word = "девятьсот          "
    .
  end.
end case.
  if Word <> "":U
  then do:
    assign
      OutSum = trim( Word ) + " ":U + trim( OutSum )
    .
  end.
  assign
    II = II - 1
  .
end.
