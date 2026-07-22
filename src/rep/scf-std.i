/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие функции для счетов-фактур

Автор: Булгаков Андрей Николаевич
Дата создания: 09/15/04
Author: Andrew Bulgakoff
Creation date: 09/15/04

*/

&GLOB CodeDelim "-"

FUNCTION GetFormNum RETURNS INTEGER ( INPUT fi-doc-code AS CHARACTER ) :
  DEFINE VARIABLE v_form-num AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_form-num AS INTEGER   NO-UNDO.

  ASSIGN v_form-num = SUBSTRING( fi-doc-code, R-INDEX( fi-doc-code, {&CodeDelim} ) - 1 ) NO-ERROR.
  IF NOT ERROR-STATUS :ERROR THEN DO:
    ASSIGN j_form-num = INTEGER( v_form-num ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
       ERROR-STATUS :ERROR = NO.
       ASSIGN j_form-num = 0.
    END.
  END.                       ELSE DO:
    ERROR-STATUS :ERROR = NO.
    ASSIGN j_form-num = 0.
  END.
  RETURN ( j_form-num ).
END FUNCTION. /* GetFormNum */

FUNCTION GetFormType RETURNS CHARACTER ( INPUT fi-doc-code AS CHARACTER ) :
  DEFINE VARIABLE v_form-type AS CHARACTER NO-UNDO.
  DEFINE VARIABLE j_form-num  AS INTEGER   NO-UNDO.

  ASSIGN v_form-type = ENTRY( NUM-ENTRIES( fi-doc-code, {&CodeDelim} ), fi-doc-code, {&CodeDelim} ) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO:
     ERROR-STATUS :ERROR = NO.
     ASSIGN v_form-type = "":U.
  END.
  RETURN ( v_form-type ).
END FUNCTION. /* GetFormNum */

FUNCTION GetDocCode RETURNS CHARACTER ( INPUT fi-form-type AS CHARACTER, INPUT fi-form-num AS INTEGER ) :
  DEFINE VARIABLE v_doc-code AS CHARACTER NO-UNDO.

  ASSIGN v_doc-code = ( IF fi-form-type = ? THEN "?" ELSE fi-form-type ) + {&CodeDelim} +
                      ( IF fi-form-num  = ? THEN "?" ELSE TRIM( STRING( fi-form-num, ">>>>>>>>>9":U ) ) ) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO:
     ERROR-STATUS :ERROR = NO.
     ASSIGN v_doc-code = "":U.
  END.
  RETURN ( v_doc-code ).
END FUNCTION. /* GetFormNum */

/* $Workfile$   E n d */

