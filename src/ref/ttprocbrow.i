define temp-table procAsunc no-undo  
    field procid            as character 
    field procval           as character 
    field procname          as character 
    field proctyperun       as character 
    
    index pi is primary unique
        procid
.

define temp-table procParam no-undo 
    field procid                as character  
    field paramName             as character
    field numparam              as integer 
    field ParamValue            as character
    field ParamType             as character
    field ParamHiden            as logical    
    index pi is primary unique
        procid numparam 
.

define temp-table SesParam no-undo
    field parCheck          as logical  
    field parCode           as character
    field parname           as character 
    field parvalue          as character
    field parWaitFile       as character
    index pi is primary unique
        parCode
.


define dataset ds-asuncProc xml-node-name "root" for procAsunc, procParam  , SesParam
data-relation  relver  for procAsunc, procParam relation-fields (procid,procid) nested.
