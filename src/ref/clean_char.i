{def\funcmet.i clean_char  char }
(INPUT in_str AS CHARACTER):
    DEFINE VARIABLE out_str  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE new_str  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ch_code  AS INTEGER   NO-UNDO.
    out_str = "".
    DO i = 1 TO LENGTH (in_str):
        new_str = SUBSTRING(in_str, i, 1).
        ch_code = ASC(new_str).
        IF  ch_code >= 32 
        and ch_code < 1104 
        and ch_code <> 166  
        and ch_code <> 127
        and new_str <> "?"  
        THEN out_str = out_str + new_str.
    END.
    RETURN out_str.
END.

