unit sconsts;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
(***************************************)
(* Copyright (C) 2003, SHIRAISHI Kazuo *)
(***************************************)


interface

{$IFDEF Windows}
const EOL=#13#10;
const EOL1=#13;
      EOL2=#10;
{$ELSE}
const EOL=#10;
const EOL1=#10;
      EOL2=#10;
{$ENDIF}

const
  TextExt= '.txt';
var
  BASExt:string[7]='.bas';
  LibExt:string[7]='.lib';
var  BreakKey:char='B';

const
  AppTitle='BASIC';

ResourceString
  c_language='E';
  s_BASICProgram= 'BASIC program';
  s_OpenFile='Open File';
  s_SaveFile='Save as';
  s_Edit='Edit';
  s_RUN='Run';
  Setup_MSG1='Extension';
  Setup_MSG2='is used another application.'
                               + EOL + 'Associate with BASIC ?';
  s_InitEnv='Options shall be initialized at the next time BASIC starts';
  s_CreateDeskTopIcon='Do you want to create the shortcut icon on the desktop?';
  s_File='File';

 s_CannotQuit='Now program running.'+EOL+'Cannot Quit.';
 s_Tilde='~';
 s_DecimalBASIC= 'BASIC';

 s_Protected= 'Protected';
 s_decimal= 'Decimal';
 s_1000digits='1000 Digits';
 s_binary= 'Binary';
 s_complex= 'Complex';
 s_rational= 'Rational';
 s_Standard='';
 s_Minimal= 'min.';
 s_MS=     'MS ';
 s_Overwrite='';
 s_Insert='';
 s_PrinterFontName= 'Courier New';
 statusBarMems3='Ready'; //'F1:Help   F2:Keywords   F9:Run';
 Contact = 'Mail'+EOL+
           'version number and current program'+EOL+
           'to '+EOL+
           'kazuo.shiraishi@nifty.com';
 s_internalErrorCompiling= 'Internal Error on Compiling';
 s_InternalErrorRunning= 'Internal Error on Running';
 s_SyntaxError= 'Syntax Error';
 S_RToNOverflow='overflow on converting a rational to a decimal';
 s_Extype1000='overflow' ;
 s_Extype1001='numerical constant overflow' ;
 s_Extype1002='numerical operation overflow';
 s_Extype1003='numerical function overflow' ;
 s_Extype1004= 'overflow';
 s_Extype1005='overflow on array expression' ;
 s_EXTYPE1006= 'overflow on READ';
 s_EXTYPE1007= 'overflow on INPUT';
 s_EXTYPE1008= 'overflow on FILE INPUT';
 s_Extype1009= 'overflow on DET or DOT';
 s_EXTYPE1050= 'overflow of a string';
 s_Extype2001= 'index out of range';
 s_Extype3000='Invalid operation (Out of domain, etc.)';
 s_Extype3001='divided by zero';
 s_Extype3002='negative to non-integer power';
 s_Extype3003= 'zero to negative power';
 s_Extype3004='argument out of range';
 s_Extype3005='SQR(negative)';
 s_Extype3006='Zero divisor in MOD or REMAINDER';
 s_Extype3007='Argumrnt out of range in ACOS or ASIN';
 s_Extype3008='ANGLE(0,0)';
 s_Extype3009='argument singular matrix';
 s_Extype3101='uninitialized variable';

 s_extype4000='Argument out of range';

 s_Extype5001='Size of Redim. array too large';
 s_Extype6001='Array size mismatched';
 s_Extype7000='File I/O Error';
 s_Extype7001='Illegal Channel number';
 s_Extype7003='Already active';
 s_Extype7004='inactive channel';
 s_Extype7101='File I/O Error. Could not open';
 s_Extype7102='File I/O Error. '+EOL+
              'Only Existent file can be opened for ACCESS INPUT.';
 s_Extype7103='File I/O Error. Could not make file.'+ EOL +
              'Probably too many files in disk';
 s_EXType7301='file not opend as OUTIN' ;
 s_Extype7302='Output to input file';
 s_Extype7303='Input from output file';
 s_Extype7305='Non-existent record';
 s_Extype7308='attempt to write exisiting file';
 s_Extype7317='PRINT to INTERNAL file';
 s_Extype7318='INPUT from INTERNAL file';
 s_Extype8001='Beyond end of data';
 s_Extype8011='End of file';
 s_Extype8012='too few data';
 s_Extype8013='too many data';
 s_Extype8101='non-numeric datum';
 s_Extype8002='illegal input reply';
 s_Extype8105='syntactically incorrect input ';
 s_Extype8120='Type Mismatch on INTERNAL input';
 s_Extype8201='invalid format string';
 s_Extype8202='No Format item';
 s_Extype8203='Short format string';
 s_Extype8204='Short exrad part in format string';
 s_Extype8401='Timeout';
 s_Extype8402='Negative time';
 s_Extype9000='File I/O Error';
 s_Extype9002='Fail on a device';
 s_Extype9003='Not existence of file';
 s_Extype9004='File already exists';
 s_Extype9102='This function not available for printers';
 s_Extype10002='return without corresponding gosub';
 s_Extype10004='No case-block selected';
 s_Extype11004='set window during picture-def';
 s_Extype11051='boundaries with zero width or height';
 s_Extype12004='Excessive or negative time specified';
 s_OutoOfMemory= 'out of Memory';
 s_VStackOverflow= 'Virtual memory not allocated';
 s_OutputOverflow= 'text output overflow';
 s_StackOverflow= 'system stack overflow';
 s_ArraySizeOverflow='too large array';
 s_OnCompiling= 'Compiling';
 s_OnRuunnig=  ' Running';

 s_program= 'Program';
 s_Library= 'Library';
 s_TextFile= 'Text files';
 s_BitMap= 'Bitmap';
 s_ImageFile='Image files';
 s_AllFile= 'All files';
 CloseMsg = '''%s'' has been modified.'+EOL+'Do you want to save? ';
 s_NotFound= 'is not found.';
 s_Margin= 'margin ';
 s_InitialMargin= 'initial margin';

 TemplateErrMes= 'BASIC.KWS or BASIC.KWF incorrect '+EOL;

 s_IncludesAnError= 'has an error.';
 s_IsExpected=' is expected.';
 s_Restricted=' only';
 s_CantBelongHere=' can not belong here.';
 s_DimmensionError= 'Mismatched array dimension';
 s_QuoteIsExpected='''"'' is expected.';
 s_MultiStatementIsNotAvailable= 'Multi-statements are not allowed. Amend?';
 s_ColonIsAnExtra=''':'' is an extra. Delete it?';
 s_ConvertTailComment= 'Substitute ! for ''?';
 s_IllegalLineNumber= 'Syntactically incorrect line number';
 s_ConfirmInsert=EOL+' Insert it ?';
 s_Identifier= 'Identifier';
 s_Constant= 'Constant';
 s_Integer= 'Integer';
 s_NumericalConstant= 'Numerical constant';
 s_StringConstant= 'String constant';
 s_DEleteLineNumberFailed= 'Line number deletion failed';
 s_SupplementLineNumberFailed= 'Line number provision failed';
 s_CorrespondingParenNotFound= 'Corresponding ) is not found.';

 s_DuplicatedLineNumber= 'Duplicated Line Number';
 s_LineNumberDescent='Line Number Decending';
 s_ConfirmTraceWithLargeArray= 'Large arrays consumes time for tracing.'+EOL
                                       +'Do Trace?';
 s_CanNotBrachLine= 'Can not branch line %s';
 s_LineNumber= 'line number';
 s_LineNotFound= 'Line %0:s not found';
 s_DuplicaltedRoutineName= 'Duplicated Routine identifier';
 s_DuplicatedVariableName= ' is already used for a variable identifier.';
 s_IsDeclaredAsExternalFunction=' is already used for a external function identifier';
 s_DuplicatedParameter= 'duplicated parameter: ';
 s_InternalRoutineCanntotbeInProcedure= 'A Module can not contain internal procedures.';

 s_ConfirmEndToStop= 'END-statement can not belong here.'+EOL+
                         'Substitute STOP for END ?';
 s_ConfirmEndToStop2= 'Only external procedures are written below END-line.'+EOL
                     + 'Substitute STOP for END above ?';
 s_ConfirmMoveDataLIne= 'DATA-statements must be written within a program unit.'
                        +EOL+'Move DATA-lines above END-line？';
 s_ProtectionBlockInsideExceptionHandler=
                          'Exception handlers cannot contain Protection Blocks.';
 s_IFTHENCorrectConfirm=
                       'IF-statements cannot follow THEN or ELSE. Correct?';
 s_ENDCorrectConfirm= 'Substitute STOP for END ?';
 s_NestedSameVarFOR= 'Nested FOR with same variable';
 s_InquireInsert=' Insert it？';
 s_ConfirmWHILE1toDO='Substitute DO for WHILE 1 ';
 s_ConfirmWHILEtoDOWHILE= 'Substitute DO WHILE for WHILE ?';
 s_ConfirmWENDtoLOOP= 'Substitute LOOP for WEND ?';

 s_IMAGEstatement= 'IMAGE-statements must follow a line number.';
 s_IsNotAgreeArithmetic=' The line that invoked %0:s differs in arithmetic option.';
 s_BodyIsNotFound= 'DEf-part of %s not found';
 s_ExpressionIncorrect= 'Syntactically incorrect numerical expression';
 s_or=EOL+'or'+EOL;

 s_CanBeParenthesized=' must be parenthesized. Correct?';
 s_IsReserved=' is a reserved word.';
 s_IsNotExternalDeclared=' is not declared as EXTERNAL.';
 s_DisAgreeArithmetic=' arithmetic option disagree' ;
 s_IsNotDeclared=' is not declared.';
 s_IsFunctionName= ' is a function identifier.';
 s_VarName='variable';
 s_NumVar= 'numerical variable';
 s_SimpleVar= 'simple variable';
 s_IllegalStringVar= 'incorrect string expression';
 s_ConfirmPlusSignToAnpersand= 'Substitute & for + ？';
 s_IsNotArrayName=  ' is not an array．';
 s_NumArrayName= 'numerical array identifier';
 s_StringArrayName= 'string array identifier';
 s_ComparisonExp= 'comparison expression';
 s_FunctionName= 'function identifier';
 s_OnlyStringVar= 'A string variable belongs here.';
 s_StringIdentifier= 'string identifier';
 s_StringVariable= 'string identifier' ;
 s_ArrayShouldBeDeclared= 'Arrays must be declared in DIM-statements.';
 s_ConfirmInsertLET='LET cannot be omitted. Insert？';

 s_IsCorectAskConvert= ' is correct form. Correct ?';
  s_DuplicatedIdetifier= 'Duplicated identifier: ';
  s_SubscriptRange= 'index must be contained in range from -2147483647 to 2147483647.';
  s_DimParameter= 'index must be constant.';
  s_ImperativeDIM=' Internal procedure should not contain an imperative DIM.';
  s_ModifiedIdentifierExpected= 'Modified Identifier expected.';
  s_module='module';
  s_NotPublicDeclaredIn=' %1:s is not Declared PUBLIC in module %0:s .';
  s_ModuleDimemsion=' %1:s is declared %2:s dimensional in module %0:s ．';
  s_IsNotFound=' is not found.';
  s_IsNotHandler=' is not a handler.';
  s_IsNotPublicDeclared=' is not declared PUBLIC.';
  s_OPTION_ARITHMETIC= 'OPTION ARITHMETIC must be written above any numerical expression.';
  s_JISmode='Run this program in JIS mode.';
  s_MSModeOnly=' is avialble only in Microsoft BASIC comatible mode.' ;
  s_OnlyOneOPTION_ANGLE=  ' OPTION ANGLE can occur in a program unit once.';
  s_OnlyOneOPTION_ARITHMETIC= 'OPTION ARITHMETIC can occur in a program unit once.';
  s_OPTION_BASE='OPTION BASE must be written above any DIM-statement.';
  s_ConfirmAngle='Option angle shall be RADIANS in external procedure %s .'+EOL+
         'Y: Go on. never shows this message Hereafter.'+EOL+
         'N: insert OPTION ANGLE DEGREES ';
  s_ConfirmArithmetic=   'Option arithmetic shall be %1:s in external procedure %0:s .'
          +EOL+ 'Y: Go on. never shows this message Hereafter.'
          +EOL+ 'N: insert %2:s ';

  s_GuideOptionBase='(Hint) '+EOL+'Try inserting'+EOL+
                    'OPTION BASE 0'+EOL+
                    'above any DIM-line .';
  s_TDrawOpName= 'Overflow in calculating transform matrix on DRAW-statement';
  s_TooLargeConstant= 'too large numeric constant';

  s_UsedByAnotherApplication=' is now linked by another application.';

  s_PowerIndex= 'power must be an integer of range from -9223372036854775807 to 9223372036854775807.';
  s_RPowerIndex= 'power must be an integer of range from -2147483647 to 2147483647.';
  s_InvalidArgInSQR= 'negative argument in SQR';
  s_InvalidArgInLOG= 'negative argument in logarithm';

  WriteSyntaxErrorMes='; or TAB cannot occur in WRITE-statement.';
  s_ConfirmCorrectPRINT_USING= 'Substitute : for ; ?';
  s_QuestionMark= 'Substitute PRINT for ''?'' ?';
  s_InvalidFunctionOnMode='%0:s function not available in %1:s mode.';
  s_ChannelExp= 'channel expression';
  s_FailedOpen= ' could not be opened.';
  s_TestCtrlBBreak=' Abort?'+EOL+'Y:Abort，N: Debug';
  s_MarginError='margin cannot be smaller than zone width.';
  s_ZoneWidthError= 'zone width cannot be larger than margin';
  s_ConfirmAbort='Abort? ';
  s_ConfirmToBreak='To Break after execution of this statement.';
  s_DataFoundForWrite= 'Attempt to overwrite an existent record.'+EOL+
        'If old records can be erased, use ERASE-statement to delete them beforehand.'+EOL+
        'If new records shall be appended, open the file with ACCESS OUTPUT .';

  s_ConfirmPrintBMPPartially= 'Cannot print the whole. Go on?';
  s_InvalidPrinter=' This printer cannot manage graphics.';

  s_ImaginaryInComparable= 'Imaginary numbers are not comparable';
  s_ImaginaryNotAvailable= 'Imaginary numbers are not available here.' ;
  s_FormatInvalidForImaginary= 'Format is not available for imaginary numbers.';
  s_ImaginaryHasNoSign= 'An Imaginary number has no sign.';

  s_WINDOW='To set the coordinate system, use SET WINDOW as follows:' + EOL+
           'SET WINDOW left, right, bottom, top'+EOL+
           EOL+
           'If you want to use Microsoft WINDOW statement, '+EOL+
           'Select ''Microsoft BASIC Compatible'' in the syntax option menu.' ;
  s_LPRINT='USE PRINT statement, and print after execution.';
  s_to_BREAK='TO BREAK. WAIT a moment';
  s_TestCtrlBreak='Abort?'+EOL+'Y  Abort'+EOL+
             'N  Wait for completing this statement and Shift to debug';

  s_HT_Mes='Control character HT detected.'+EOL
          +'Can every HT be replased with spaces？';
  s_ZenKuu_Mes='Zenkaku space detected'+EOL
          +'Can every zenkaku space be relpaced with hankaku spaces?';
  s_CTRLChar1='Control characters';
  s_Zenkaku='Zenkaku Character';
  s_appears=' appears';

  //s_cannotbeloaded=' could not be loaded.';
  //s_ResultmustbeNumeric='The result type must be nemeric.';

  s_AllowGlobalInternalProc=
    'An internal procedure of mainprogram is to be invoked by an external procedure.'
    +EOL    +'This program is wrong. Do you want to run this?';

  s_RND='RND function has no argumant.';
  s_URL='https://decimalbasic.web.fc2.com/English/index.htm';
  s_Select_Directory='Select a Folder';
  s_Pause_Mes=EOL+EOL+'Ok  Continue'+EOL+'ESC  Debug state';
implementation

end.
