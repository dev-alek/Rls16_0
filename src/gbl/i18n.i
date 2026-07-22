/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

The Win32 API contains many constants.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* ====================================================================
   file      i18n.i  - internationalisation
   by        Jurjen Dijkstra, 1998
             mailto:jurjen.dijkstra@wxs.nl
             http://www.pugcentral.org/api
   language  Progress 8.2A
   ==================================================================== */

&IF DEFINED(I18N_I)=0 &THEN
&GLOBAL-DEFINE I18N_I

/*
The Win32 API contains many constants. winconst.zip contains a list of more than 14000 P4GL preprocessor definitions and a utility that helps to find dependencies. For example, the constant WVR_REDRAW is defined as (WVR_HREDRAW | WVR_VREDRAW). When you search for WVR_REDRAW in winconst.exe it will return


&GLOBAL-DEFINE WVR_VREDRAW 512
&GLOBAL-DEFINE WVR_HREDRAW 256
&GLOBAL-DEFINE WVR_REDRAW  ({&WVR_HREDRAW} + {&WVR_VREDRAW})

winconst.zip is freeware. Download now!

You have to be careful when you combine constants. In 3GL programming environments you would use the OR operator to combine constants, but in Progress we only have + to work with. This can make a difference. Also, we have no unsigned long integer. As a result, some values are converted to negative signed integers. Using these values together with the + operator instead of OR may give unexpected results.

*/

{ gbl/windows.i }

/* "locale" is one of these constants: */
&GLOB LOCALE_USER_DEFAULT   1024
&GLOB LOCALE_SYSTEM_DEFAULT 2048
/* or any Language ID, defined by Windows.
   a couple of examples: */


&GLOB LANGID_DUTCH 1043
&GLOB LANGID_FRENCH 1036
&GLOB LANGID_GERMAN 1031
&GLOB LANGID_SPANISH 3082
&GLOB LANGID_ENGLISH 1033
&GLOB LANGID_ITALIAN 1040

/* those LANGID_ constants are not actually defined
   by Windows. Instead they are calculated
   using the MAKELANGID macro:
   LANGID = MAKELANGID(PRIMARYLANGID,SUBLANGID).
   The macro is roughly:
     (1024 * SUBLANGID) + PRIMARYLANGID
   For example: LANG_SPANISH = 10
                SUBLANG_SPANISH_MODERN = 3
   so LANGID_SPANISH = 3082
*/

&GLOB LOCALE_NOUSEROVERRIDE -2147483648

/* In GetDateFormatA, "dwFlags" is a combination of these constants: */
&GLOB DATE_SHORTDATE 1
&GLOB DATE_LONGDATE 2

/* In GetTimeFormatA, "dwFlags" is a combination of these constants: */
&GLOB TIME_NOMINUTESORSECONDS 1
&GLOB TIME_NOSECONDS 2
&GLOB TIME_NOTIMEMARKER 4
&GLOB TIME_FORCE24HOURFORMAT 8

&GLOBAL-DEFINE LOCALE_FONTSIGNATURE 88


&GLOBAL-DEFINE LOCALE_ICALENDARTYPE 4105
/*
The type of calendar currently in use.
        1       Gregorian (as in U.S.)
        2       Gregorian (always English strings)
        3       Era: Year of the Emperor (Japan)
        4       Era: Year of the Republic of China
        5       Tangun Era (Korea)
*/

&GLOBAL-DEFINE LOCALE_ICENTURY 36
/*Whether to use full 4-digit century.
        0       Two digit.
        1       Full century.
*/



&GLOBAL-DEFINE LOCALE_ICOUNTRY 5
/*
The country code, which is based on international phone codes.
*/

&GLOBAL-DEFINE LOCALE_ICURRDIGITS 25
/*
Number of fractional digits for the local monetary format.
*/

&GLOBAL-DEFINE LOCALE_ICURRENCY 27
/*
Positive currency mode.
        0       Prefix, no separation.
        1       Suffix, no separation.
        2       Prefix, 1-character separation.
        3       Suffix, 1-character separation.
*/

&GLOBAL-DEFINE LOCALE_IDATE 33
/*
Short Date format-ordering specifier.
        0       Month - Day - Year
        1       Day - Month - Year
        2       Year - Month - Day
*/

&GLOBAL-DEFINE LOCALE_IDAYLZERO 38
/*
Whether to use leading zeros in day fields. Values as for LOCALE_ITLZERO.
*/

&GLOBAL-DEFINE LOCALE_IDEFAULTANSICODEPAGE 4100
/*
The ANSI code page associated with this locale. Format: 4 Unicode decimal digits plus a Unicode null terminator.
XXX This should be translated by GetLocaleInfo. XXX
*/

&GLOBAL-DEFINE LOCALE_IDEFAULTCODEPAGE 11
/*
The OEM code page associated with the country.
*/

&GLOBAL-DEFINE LOCALE_IDEFAULTCOUNTRY 10
/*
Country code for the principal country in this locale.
*/

&GLOBAL-DEFINE LOCALE_IDEFAULTLANGUAGE 9
/*
Language identifier for the principal language spoken in this locale.
*/

&GLOBAL-DEFINE LOCALE_IDEFAULTMACCODEPAGE 4113
&GLOBAL-DEFINE LOCALE_IDIGITS 17
/*
The number of fractional digits.
*/

&GLOBAL-DEFINE LOCALE_IFIRSTDAYOFWEEK 4108
/*
Specifies the day considered first in the week. Value ``0'' means SDAYNAME1 and value ``6'' means SDAYNAME7.
*/


&GLOBAL-DEFINE LOCALE_IFIRSTWEEKOFYEAR 4109
/*
Specifies which week of the year is considered first.
        0       Week containing 1/1 is the first week of the year.
        1       First full week following 1/1is the first week of the year.
        2       First week with at least 4 days is the first week of the year.
*/

&GLOBAL-DEFINE LOCALE_IINTLCURRDIGITS 26
/*
Number of fractional digits for the international monetary format.
*/

&GLOBAL-DEFINE LOCALE_ILANGUAGE 1
/*
The language identifier (in hex).
*/

&GLOBAL-DEFINE LOCALE_ILDATE 34
/*
Long Date format ordering specifier. Value can be any of the valid LOCALE_IDATE settings.
*/

&GLOBAL-DEFINE LOCALE_ILZERO 18
/*
Whether to use leading zeros in decimal fields.
A setting of 0 means use no leading zeros;
1 means use leading zeros.
*/

&GLOBAL-DEFINE LOCALE_IMEASURE 13
/*
Default measurement system:
        0       metric system (S.I.)
        1       U.S. system
*/

&GLOBAL-DEFINE LOCALE_IMONLZERO 39
/*
Whether to use leading zeros in month fields. Values as for LOCALE_ITLZERO.
*/


&GLOBAL-DEFINE LOCALE_INEGCURR 28
/*
Negative currency mode.
        0       ($1.1)
        1       -$1.1
        2       $-1.1
        3       $1.1-
        4       $(1.1$)
        5       -1.1$
        6       1.1-$
        7       1.1$-
        8       -1.1 $ (space before $)
        9       -$ 1.1 (space after $)
        10      1.1 $- (space before $)
*/

&GLOBAL-DEFINE LOCALE_INEGNUMBER 4112
/*
Negative number mode.
        0       (1.1)
        1       -1.1
        2       -1.1
        3       1.1
        4       1.1
*/

&GLOBAL-DEFINE LOCALE_INEGSEPBYSPACE 87
/*
If the monetary symbol is separated by a space from a positive amount, 1. Otherwise, 0.
*/

&GLOBAL-DEFINE LOCALE_INEGSIGNPOSN 83
/*
Formatting index for negative values. Values as for LOCALE_IPOSSIGNPOSN.
*/

&GLOBAL-DEFINE LOCALE_INEGSYMPRECEDES 86
/*
If the monetary symbol precedes, 1. If it succeeds a negative amount, 0.
*/

&GLOBAL-DEFINE LOCALE_IOPTIONALCALENDAR 4107
/*
The additional calendar types available for this LCID.
Can be a null-separated list of all valid optional calendars.
Value is 0 for ``None available'' or any of the LOCALE_ICALENDARTYPE settings.
XXX null separated list should be translated by GetLocaleInfo XXX
*/

&GLOBAL-DEFINE LOCALE_IPOSSEPBYSPACE 85
&GLOBAL-DEFINE LOCALE_IPOSSIGNPOSN 82
/*
Formatting index for positive values.
        0 Parentheses surround the amount and the monetary symbol.
        1 The sign string precedes the amount and the monetary symbol.
        2 The sign string precedes the amount and the monetary symbol.
        3 The sign string precedes the amount and the monetary symbol.
        4 The sign string precedes the amount and the monetary symbol.
*/


&GLOBAL-DEFINE LOCALE_IPOSSYMPRECEDES 84

&GLOBAL-DEFINE LOCALE_ITIME 35
/*
Time format specifier.
        0       AM/PM 12-hour format.
        1       24-hour format.
*/

&GLOBAL-DEFINE LOCALE_ITIMEMARKPOSN 4101
/*
Whether the time marker string (AM|PM) precedes or follows the time string.
0 Suffix (9:15 AM). 1 Prefix (AM 9:15).
*/

&GLOBAL-DEFINE LOCALE_ITLZERO 37
/*
Whether to use leading zeros in time fields.
        0       No leading zeros.
        1       Leading zeros for hours.
*/

&GLOBAL-DEFINE LOCALE_S1159 40
/*
String for the AM designator.
*/

&GLOBAL-DEFINE LOCALE_S2359 41
/*
String for the PM designator.
*/

&GLOBAL-DEFINE LOCALE_SABBREVCTRYNAME 7
/*
The ISO Standard 3166 abbreviated name of the country.
*/

/* abbreviated names for days*/
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME1 49
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME2 50
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME3 51
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME4 52
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME5 53
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME6 54
&GLOBAL-DEFINE LOCALE_SABBREVDAYNAME7 55
&GLOBAL-DEFINE LOCALE_SABBREVLANGNAME 3
/*
The three-letter abbreviated name of the language.
The first two letters are from the ISO Standard 639 language name abbreviation.
The third letter indicates the sublanguage type.
*/


/*Abbreviated name for January .. December. */
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME1 68
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME10 77
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME11 78
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME12 79

/*Native abbreviated name for 13th month, if it exists.*/
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME13 4111
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME2 69
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME3 70
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME4 71
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME5 72
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME6 73
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME7 74
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME8 75
&GLOBAL-DEFINE LOCALE_SABBREVMONTHNAME9 76
&GLOBAL-DEFINE LOCALE_SCOUNTRY 6
/*
The localized name of the country.
*/

&GLOBAL-DEFINE LOCALE_SCURRENCY 20
/*
The string used as the local monetary symbol.
*/

&GLOBAL-DEFINE LOCALE_SDATE 29
/*
Characters used for the date separator.
*/

/* long names for days */
&GLOBAL-DEFINE LOCALE_SDAYNAME1 42
&GLOBAL-DEFINE LOCALE_SDAYNAME2 43
&GLOBAL-DEFINE LOCALE_SDAYNAME3 44
&GLOBAL-DEFINE LOCALE_SDAYNAME4 45
&GLOBAL-DEFINE LOCALE_SDAYNAME5 46
&GLOBAL-DEFINE LOCALE_SDAYNAME6 47
&GLOBAL-DEFINE LOCALE_SDAYNAME7 48

&GLOBAL-DEFINE LOCALE_SDECIMAL 14
/*
Characters used for the decimal separator (often a dot).
*/

&GLOBAL-DEFINE LOCALE_SENGCOUNTRY 4098
/*
The English name of the country.
*/

&GLOBAL-DEFINE LOCALE_SENGLANGUAGE 4097
/*
The ISO Standard 639 English name of the language.
*/

&GLOBAL-DEFINE LOCALE_SGROUPING 16
/*
Sizes for each group of digits to the left of the decimal.
An explicit size is required for each group.
Sizes are separated by semicolons.
If the last value is 0, the preceding value is repeated. To group thousands, specify 3;0.
*/

&GLOBAL-DEFINE LOCALE_SINTLSYMBOL 21
/*
Three characters of the International monetary symbol specified in ISO 4217,
Codes for the Representation of Currencies and Funds, followed by the character separating this string from the amount.
*/

&GLOBAL-DEFINE LOCALE_SISO3166CTRYNAME 90
&GLOBAL-DEFINE LOCALE_SISO639LANGNAME 89
&GLOBAL-DEFINE LOCALE_SLANGUAGE 2
/*
The localized name of the language.
*/

&GLOBAL-DEFINE LOCALE_SLIST 12
/*
Characters used to separate list items (often a comma).
*/

&GLOBAL-DEFINE LOCALE_SLONGDATE 32
/*
Long Date_Time formatting strings for this locale.
*/

&GLOBAL-DEFINE LOCALE_SMONDECIMALSEP 22
/*
Characters used for the monetary decimal separators.
*/

&GLOBAL-DEFINE LOCALE_SMONGROUPING 24
/*
Sizes for each group of monetary digits to the left of the decimal.
An explicit size is needed for each group. Sizes are separated by semicolons.
If the last value is 0, the preceding value is repeated. To group thousands, specify 3;0.
*/

/*Long name for January .. December. */
&GLOBAL-DEFINE LOCALE_SMONTHNAME1 56
&GLOBAL-DEFINE LOCALE_SMONTHNAME10 65
&GLOBAL-DEFINE LOCALE_SMONTHNAME11 66
&GLOBAL-DEFINE LOCALE_SMONTHNAME12 67

/*Native name for 13th month, if it exists.*/
&GLOBAL-DEFINE LOCALE_SMONTHNAME13 4110
&GLOBAL-DEFINE LOCALE_SMONTHNAME2 57
&GLOBAL-DEFINE LOCALE_SMONTHNAME3 58
&GLOBAL-DEFINE LOCALE_SMONTHNAME4 59
&GLOBAL-DEFINE LOCALE_SMONTHNAME5 60
&GLOBAL-DEFINE LOCALE_SMONTHNAME6 61
&GLOBAL-DEFINE LOCALE_SMONTHNAME7 62
&GLOBAL-DEFINE LOCALE_SMONTHNAME8 63
&GLOBAL-DEFINE LOCALE_SMONTHNAME9 64

&GLOBAL-DEFINE LOCALE_SMONTHOUSANDSEP 23
/*
Characters used as monetary separator between groups of digits left of the decimal.
*/

&GLOBAL-DEFINE LOCALE_SNATIVECTRYNAME 8
/*
The native name of the country.
*/

&GLOBAL-DEFINE LOCALE_SNATIVEDIGITS 19
/*
The ten characters that are the native equivalent of the ASCII 0-9.
*/

&GLOBAL-DEFINE LOCALE_SNATIVELANGNAME 4
/*
The native name of the language.
*/

&GLOBAL-DEFINE LOCALE_SNEGATIVESIGN 81
/*String value for the negative sign. */

&GLOBAL-DEFINE LOCALE_SPOSITIVESIGN 80
/*String value for the positive sign. */

&GLOBAL-DEFINE LOCALE_SSHORTDATE 31
/*
Short Date_Time formatting strings for this locale.
*/

&GLOBAL-DEFINE LOCALE_STHOUSAND 15
/*
Characters used as the separator between groups of digits left of the decimal.
*/

&GLOBAL-DEFINE LOCALE_STIME 30
/*
Characters used for the time separator.
*/

&GLOBAL-DEFINE LOCALE_STIMEFORMAT 4099
/*
Time-formatting string.
*/

&GLOBAL-DEFINE LOCALE_SYSTEM_DEFAULT 2048
&GLOBAL-DEFINE LOCALE_USER_DEFAULT 1024
&GLOBAL-DEFINE LOCALE_USE_CP_ACP 1073741824


PROCEDURE GetDateFormatA EXTERNAL "KERNEL32" :
   DEFINE INPUT PARAMETER        Locale      AS LONG.
   DEFINE INPUT PARAMETER        dwFlags     AS LONG.
   DEFINE INPUT PARAMETER        lpTime      AS LONG.
   DEFINE INPUT PARAMETER        lpFormat    AS LONG.
   DEFINE INPUT-OUTPUT PARAMETER lpDateStr   AS CHAR.
   DEFINE INPUT PARAMETER        cchDate     AS LONG.
   DEFINE RETURN PARAMETER       cchReturned AS LONG.
END PROCEDURE.

PROCEDURE GetTimeFormatA EXTERNAL "KERNEL32" :
   DEFINE INPUT PARAMETER        Locale    AS LONG.
   DEFINE INPUT PARAMETER        dwFlags   AS LONG.
   DEFINE INPUT PARAMETER        lpTime    AS LONG.
   DEFINE INPUT PARAMETER        lpFormat  AS LONG.
   DEFINE INPUT-OUTPUT PARAMETER lpTimeStr AS CHAR.
   DEFINE INPUT PARAMETER        cchTime   AS LONG.
   DEFINE RETURN PARAMETER       cchReturned AS LONG.
END PROCEDURE.


&ENDIF