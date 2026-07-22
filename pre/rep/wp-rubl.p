block-level on error undo, throw.
DEFINE  INPUT PARAMETER p-InSum  AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER p-OutSum AS CHARACTER NO-UNDO.
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: wp-rubl.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/wp-rubl.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Сумма с разбивкой на  р у б л и  и  к о п е й к и":U.
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
FUNCTION Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Rouble AS CHARACTER NO-UNDO.
  RUN get-roubles IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Rouble ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Rouble ).
END FUNCTION.
PROCEDURE get-roubles :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rub AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
           jj     = LENGTH( Word )
           j_last = INTEGER( SUBSTRING( Word, jj - 3, 1 ) )
           l_prev =        ( SUBSTRING( Word, jj - 4, 1 ) = "1" ).
    IF      j_last = 1                THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубль" ).  END.
    ELSE IF j_last > 1 AND j_last < 5 THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубля" ). END.
                                      ELSE DO: ASSIGN p-rub = "рублей". END.
  END.
END PROCEDURE.
FUNCTION Copecks RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Copeck AS CHARACTER NO-UNDO.
  RUN get-copecks IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Copeck ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Copeck ).
END FUNCTION.
PROCEDURE get-copecks :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-kop AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN  Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
            jj     = LENGTH( Word )
            j_last = INTEGER( SUBSTRING( Word, jj,     1 ) )
            l_prev =        ( SUBSTRING( Word, jj - 1, 1 ) = "1" ).
    IF           j_last = 1                THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейка" ).
    END. ELSE IF j_last > 1 AND j_last < 5 THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейки" ).
    END.                                   ELSE DO:
      ASSIGN p-kop = "копеек".
    END.
  END.
END PROCEDURE.
DEFINE VARIABLE Word AS CHARACTER NO-UNDO.
ASSIGN Word     = STRING( ABS( p-InSum ), "999999999999999999999999999999.99":U ).
ASSIGN p-OutSum = ( IF p-InSum < 0 THEN "- " ELSE "":U ) + STRING( TRUNCATE( p-InSum, 0 ) ) + " ":U +
                  Roubles( p-InSum ) + " ":U + SUBSTRING( Word, LENGTH( Word ) - 1 ) + " ":U + Copecks( p-InSum ).
