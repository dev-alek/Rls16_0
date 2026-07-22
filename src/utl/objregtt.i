define temp-table tt-objth no-undo
    field iNum       as integer
    field objhndl    as class Progress.Lang.Object
    field propname   as character
    field label_     as character
    field objname    as character
    field objparent  as character
    field procparent as character
index pparent objparent propname
index objname objname
.
/*
tt-objth.iNum tt-objth.propname tt-objth.objname tt-objth.objparent tt-objth.procparent 
*/