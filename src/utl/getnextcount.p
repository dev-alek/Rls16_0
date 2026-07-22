block-level on error undo, throw.
define input  parameter iFileName as character no-undo.
define input  parameter ikey      as character no-undo.
define input  parameter icode     as character no-undo.
define input  parameter iParam    as character no-undo.
define output parameter oCount    as int64 no-undo.
 { cmp/str-glbl.i }
 { utl/counter.i  }
 run GetAsuncNextcount(iFileName, ikey, icode,iParam, output oCount ).
 