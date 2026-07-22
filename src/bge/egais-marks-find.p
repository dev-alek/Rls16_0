block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : egais-marks-find.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Wed Feb 01 13:24:50 MSK 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 461ee4ccdf1b, 1897, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:46 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: egais-marks-find.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/egais-marks-find.p $":U .
define variable vss-description as character no-undo init "Библиотека для работы с марками".
{ str/marks.i    }
{ gbl/key-rec.i  }
{ cmp/str-glbl.i }

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

define output parameter this-proc-hndl as handle no-undo.

do:
  
  this-proc-hndl = this-procedure.
  
end.

procedure find-mark :
    define input parameter p-mark as character no-undo .
    define output parameter p-parts-key-rec as character no-undo .
    define output parameter p-rezerv as integer no-undo .
    
    define buffer buf_gen-attr for ub.gen-attr.
    
    find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                      and buf_gen-attr.attr-code  = p-mark no-error.
    if not available buf_gen-attr
    then do :
        p-parts-key-rec = ? .
        p-rezerv = ? .
    end.
    else do :
        p-parts-key-rec = buf_gen-attr.p-key .
        p-rezerv        = buf_gen-attr.whole-send-news .
    end.
end procedure.

procedure find-marks-part :
    define input  parameter p-parts-key-rec as character no-undo .
    define output parameter p-mark as character no-undo .
    define output parameter p-rezerv as integer no-undo .
    
    define buffer buf_gen-attr for ub.gen-attr.
    
    for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                      and buf_gen-attr.p-key  = p-parts-key-rec :

        p-mark = p-mark + "," + buf_gen-attr.attr-code .
        p-rezerv        = buf_gen-attr.whole-send-news .
    end.
    p-mark = TRIM (p-mark, ",") .
    
end procedure.

procedure create-mark :
    define input parameter p-mark as character no-undo .
    define parameter buffer buf_parts for ub.parts .  
    define output parameter p-ok as logical no-undo .
    define output parameter p-mes as character no-undo .  
    
    define variable v-parts-uniq-key-rec as character no-undo .
    define buffer cr_gen-attr for ub.gen-attr.
    
    run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output v-parts-uniq-key-rec).
    find first cr_gen-attr no-lock where cr_gen-attr.table-name = {&excise-mark}
                                     and cr_gen-attr.p-key begins "parts"
                                     and num-entries (cr_gen-attr.p-key, {&delim-key}) >= 8
                                     and entry(8, cr_gen-attr.p-key, {&delim-key}) <> {&free-code}
                                     and cr_gen-attr.attr-code = p-mark no-error .
    if available cr_gen-attr
    then do :
        p-ok = false .
        p-mes = substitute ("Уже есть запись с маркой &1&2&3", p-mark, {&new-line}, cr_gen-attr.p-key)  .
        return .
    end.
    else do :
        find first cr_gen-attr no-lock where cr_gen-attr.table-name = {&excise-mark}
                                         and cr_gen-attr.p-key begins "parts"
                                         and num-entries (cr_gen-attr.p-key, {&delim-key}) >= 8
                                         and entry(8, cr_gen-attr.p-key, {&delim-key}) = {&free-code}
                                         and cr_gen-attr.attr-code = p-mark no-error .
        if available cr_gen-attr
        then do :
            p-ok = false .
            p-mes = substitute ("Уже есть запись с маркой &1&2&3", p-mark, {&new-line}, cr_gen-attr.p-key).
            return .
        end.
        else do :                                 
            create cr_gen-attr .
            assign
                cr_gen-attr.table-name = {&excise-mark}
                cr_gen-attr.p-key = v-parts-uniq-key-rec
                cr_gen-attr.attr-code = p-mark
                cr_gen-attr.whole-send-news = 0
            no-error.
            if error-status:error
            then do :
                p-ok = false .
                p-mes = "Ошибка! " + {&new-line} + error-status:get-message (1)  .
                return .
            end.
            else do :
                p-ok = true .
            end.
        end.
    end.                                                                    
end procedure.