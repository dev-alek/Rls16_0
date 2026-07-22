block-level on error undo, throw.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define output parameter gLib  as handle no-undo.
define output parameter gLib2 as handle no-undo.
gLib  = g#library .
gLib2 = g#library2.
