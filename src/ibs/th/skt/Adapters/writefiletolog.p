block-level on error undo, throw.
define input  parameter ifile     as character no-undo.
define input  parameter icodepage as character no-undo.
publish "write-to-log-codepage"  (ifile,icodepage) .