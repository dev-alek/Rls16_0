block-level on error undo, throw.
define output parameter odbList as character no-undo.
for each  db where db.db-key ne "" no-lock:
      odbList =  odbList + "," + string(db.db-num).
end.
odbList = substring (odbList,3).
