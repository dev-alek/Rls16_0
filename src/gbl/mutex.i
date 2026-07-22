/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции для использования mutex

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/31/09
Author: Dmitry Ukhanov
Creation date: 03/31/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/windows.i  }

define variable hAppRunningMutex as integer no-undo initial 0 .

FUNCTION ValidateProductSuite RETURN LOGICAL (SuitName AS CHARACTER):

   DEFINE VARIABLE key-hdl        AS INTEGER NO-UNDO.
   DEFINE VARIABLE lpBuffer       AS MEMPTR  NO-UNDO.
   DEFINE VARIABLE lth            AS INTEGER NO-UNDO.
   DEFINE VARIABLE datatype       AS INTEGER NO-UNDO.
   DEFINE VARIABLE ReturnValue    AS INTEGER NO-UNDO.
   DEFINE VARIABLE retval         AS LOGICAL NO-UNDO INITIAL FALSE.

   RUN RegOpenKeyA IN hpApi
                  ( {&HKEY_LOCAL_MACHINE},
                    "System\CurrentControlSet\Control\ProductOptions",
                    OUTPUT key-hdl,
                    OUTPUT ReturnValue).

   IF ReturnValue NE {&ERROR_SUCCESS} THEN
      RETURN FALSE.

   /* make buffer large enough
     The maximum size is supposed to be MAX_PATH + 1 */

   ASSIGN lth                = {&MAX_PATH} + 1
          SET-SIZE(lpBuffer) = lth.

   RUN RegQueryValueExA IN hpApi
                       ( key-hdl,
                         "ProductSuite",
                         0, /* reserved, must be 0 */
                         OUTPUT datatype,
                         GET-POINTER-VALUE(lpBuffer),
                         INPUT-OUTPUT lth,
                         OUTPUT ReturnValue).

   IF ReturnValue = {&ERROR_SUCCESS} THEN
       retval =  (GET-STRING(lpBuffer,1)=SuitName).
   SET-SIZE(lpBuffer)=0.
   IF key-hdl NE 0 THEN
      RUN RegCloseKey IN hpApi (key-hdl,OUTPUT ReturnValue).
   RETURN retval.

END FUNCTION.


/*The first parameter, p-OnePerSystem specifies if the application is allowed to run more than once per system. */
/*This is useful when the application is installed on Microsoft Windows Terminal Server hosting multiple users. */
/*If p-OnePerSystem=No, the application can be launched once by each user. */
/*If p-OnePerSystem=Yes the application can run only once on the entire Terminal Server system, in other words: by only one user at a time. */
/*This might be useful for batch processes perhaps?*/

FUNCTION IsAppAlreadyRunning RETURN LOGICAL
   (p-OnePerSystem AS LOGICAL, p-AppName AS CHARACTER):

  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  DEFINE VARIABLE MutexName   AS CHARACTER    NO-UNDO.
  MutexName = ''.

  IF p-OnePerSystem AND ValidateProductSuite("Terminal Server") THEN
     MutexName = MutexName + "Global\".

  MutexName = MutexName + p-AppName + ' is running'.
  RUN CreateMutexA IN hpApi(0,0,MutexName, OUTPUT hAppRunningMutex).
  IF hAppRunningMutex NE 0 THEN DO:

     /* we should check GetLastError = ERROR_ALREADY_EXISTS,
        but unfortunately GetLastError doesn't work with Progress until 9.0B */
     /* Instead we will try to get ownership of the Mutex.
        This will be easy if we created the mutex, but will be impossible if
        another instance created the mutex (and still holds ownership) */
     RUN WaitForSingleObject IN hpApi (hAppRunningMutex,100, OUTPUT ReturnValue).
     IF NOT (ReturnValue={&WAIT_ABANDONED} OR
             ReturnValue={&WAIT_OBJECT_0}) THEN DO:
        RUN CloseHandle IN hpApi(hAppRunningMutex, OUTPUT ReturnValue).
        hAppRunningMutex = 0.
     END.
  END.
  RETURN (hAppRunningMutex = 0).
END.

/*Procedure LetAntotherInstanceRun closes the mutex, making it available to other threads. */
/*This decreases the usage-count of the mutex. If the usage-count decreases to zero (like now) the mutex will be deleted. */
/*It is not very important to run this procedure because the mutex will be closed automatically by Windows when the Progress session quits.*/
PROCEDURE LetAnotherInstanceRun :
  DEFINE INPUT PARAMETER p-AppName AS CHARACTER NO-UNDO.
  DEFINE  VARIABLE ReturnValue AS INTEGER NO-UNDO.
  IF hAppRunningMutex NE 0 THEN DO:
        RUN CloseHandle IN hpApi(hAppRunningMutex, OUTPUT ReturnValue).
        hAppRunningMutex = 0.
  END.
END PROCEDURE.

/* $Workfile$   E n d */