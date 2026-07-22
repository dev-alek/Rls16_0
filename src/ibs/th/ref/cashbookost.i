define temp-table tt-cashBookOst no-undo
field chang      as logical
field cashbookid as int64
field cashbookname as character 
field ost        as decimal
field ostrasch   as decimal 
field osnpko     as decimal
field osnrko     as decimal 
index pi cashbookid.