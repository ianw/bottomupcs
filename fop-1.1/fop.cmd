@ECHO OFF
REM  Licensed to the Apache Software Foundation (ASF) under one or more
REM  contributor license agreements.  See the NOTICE file distributed with
REM  this work for additional information regarding copyright ownership.
REM  The ASF licenses this file to You under the Apache License, Version 2.0
REM  (the "License"); you may not use this file except in compliance with
REM  the License.  You may obtain a copy of the License at
REM
REM      http://www.apache.org/licenses/LICENSE-2.0
REM
REM  Unless required by applicable law or agreed to in writing, software
REM  distributed under the License is distributed on an "AS IS" BASIS,
REM  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM  See the License for the specific language governing permissions and
REM  limitations under the License.
REM  $Id: fop.cmd 1293736 2012-02-26 02:29:01Z gadams $

set LOCAL_FOP_HOME=%~dp0
set FOP_CMD_LINE_ARGS=%1
if ""%1""=="""" goto doneStart
shift
:setupArgs
if ""%1""=="""" goto doneStart
set FOP_CMD_LINE_ARGS=%FOP_CMD_LINE_ARGS% %1
shift
goto setupArgs
rem This label provides a place for the argument list loop to break out 
:doneStart

call "%LOCAL_FOP_HOME%\fop.bat" %FOP_CMD_LINE_ARGS%

