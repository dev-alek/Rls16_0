define temp-table tt-coins no-undo XML-NODE-NAME "coins" serialize-name  "coins"
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi is primary unique id desc.

define temp-table tt-banknots no-undo XML-NODE-NAME "banknots" serialize-name  "banknots"
  field id       as integer 
  field qnty     as integer 
  field sum-qnty as integer 
  index pi is primary unique id desc.
        
define temp-table tt-cover-sheet no-undo
  field num-bag      as character
  field depos-code   as integer
  field depos-bank   as character
  field repos-code   as integer
  field repos-bank   as character
  field pin02        as character
  field source_      as character
  field total-sum    as decimal  
  index pi num-bag 
.

define dataset ds-banknots XML-NODE-NAME "money" serialize-name  "money" for tt-banknots,
  tt-coins .
  
define         variable hQueryCoins                           as handle                                         no-undo .
define         variable hQueryBanknot                         as handle                                         no-undo .

method private handle add_Coints():
   define variable v-list-coints as character no-undo .
   define variable ii            as integer   no-undo .
   v-list-coints = "10;5;2;1;0.5;0.1;0.05" .
    /*Посмотреть, есть ли данные в атрибуте*/
    /*если нет заполняем пустую таблицу*/
    define variable ddd as decimal no-undo.
    do ii = 1 to num-entries (v-list-coints,";"):
       
      find first tt-coins where tt-coins.id       = decimal (entry(ii,v-list-coints,";"))
       
      no-error.
      if not available tt-coins
      then do:
         create tt-coins .
         assign
           tt-coins.id       = decimal(entry(ii,v-list-coints,";"))
           tt-coins.qnty     = 0
           tt-coins.sum-qnty = 0 
           .
       end.
    end.  
end.

method private handle getq_Coints():
if valid-handle(hQueryCoins)  then delete object hQueryCoins.
    create query hQueryCoins. 
    hQueryCoins:set-buffers(buffer tt-coins:HANDLE).
    hQueryCoins:query-prepare("FOR EACH tt-coins by tt-coins.id desc").
    hQueryCoins:query-open.
    return hQueryCoins.
end.

method private handle add_Banknot():
   define variable v-list-banknot as character no-undo .
   define variable ii             as integer   no-undo .
   v-list-banknot = "5000;2000;1000;500;200;100;50;10" .
    /*Посмотреть, есть ли данные в атрибуте*/
    /*если нет заполняем пустую таблицу*/
    do ii = 1 to num-entries (v-list-banknot,";"):
      find first tt-banknots where tt-banknots.id       = integer(entry(ii,v-list-banknot,";"))
      no-error.
      if not available tt-banknots
      then do:
         create tt-banknots .
         assign
           tt-banknots.id       = integer(entry(ii,v-list-banknot,";"))
           tt-banknots.qnty     = 0
           tt-banknots.sum-qnty = 0 
           .
       end.
    end.
end.
method private handle getq_Banknot():
   if valid-handle(hQueryBanknot)  then delete object hQueryBanknot.
    create query hQueryBanknot. 
    hQueryBanknot:set-buffers(buffer tt-banknots:HANDLE).
    hQueryBanknot:query-prepare("FOR EACH tt-banknots by tt-banknots.id desc").
    hQueryBanknot:query-open.
    return hQueryBanknot.
end.