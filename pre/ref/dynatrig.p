block-level on error undo, throw.
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: a35951db4a04, 289, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Tue Dec 01 19:11:22 2015 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: dynatrig.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: ref/dynatrig.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Адаптер динамических триггеров".
DEFINE VARIABLE mHandle AS HANDLE NO-UNDO.
PROCEDURE DynaTrig:
    DEFINE INPUT PARAMETER iTrigger AS CHARACTER NO-UNDO.
    RUN DynaTrig IN (THIS-PROCEDURE:INSTANTIATING-PROCEDURE)
        (mHandle, iTrigger) NO-ERROR.
END PROCEDURE.
PROCEDURE SetHandle:
    DEFINE INPUT PARAMETER iHandle AS HANDLE NO-UNDO.
    mHandle = iHandle.
END.
