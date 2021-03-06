SQLite format 3   @        4                           
    QM2                         -�   � q�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ��{tabletextstextsCREATE TABLE texts(id INTEGER PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE ON UPDATE CASCADE,date BLOB,text TEXT)��wtableitemsitemsCREATE TABLE items(id INTEGER PRIMARY KEY,pid INT,ord BLOB,flags INT,name TEXT,[trigger] TEXT,icon TEXT,td,guid BLOB)   � ��                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               0
 -   ,   Popexe 1.02 Beta��{U���I��^^7r9! 
     ,  file                   � ��                                                                                                                                                                                                                                                                                                                                                                                       ��# ��7��L�); Popexe Pop Email Execution
; Copyright 2016 Manuel Salguero
; Software Simple
; http://softwaresimple.es
; 1.02 Beta Version
; MIT License

; ---------------------------
; GLOBAL APP DEFINITIONS
; ---------------------------
def NameApp "PopExe"
def WinRegisterPopExe "PopExe"
def ExecutableName "PopExe.exe"
def INIFilename "popexe.ini"
def INIFileDevelopname "popexe_develop.ini"

#if EXE=1
	SetCurDir "$qm$"
	str directoryname=GetCurDir
	out F"Execution Directory:{directoryname}"
#else
	SetCurDir "$myqm$"
	str DebugDirectory =GetCurDir
	out F"DebugDirectory:{DebugDirecto                ry}"

; Encryption Key for Email Password: 56 characters max
; ----------------------------------------------------
def EncryptionKeyBase64 "Your own Encryption Key. Please change!!"

; -----------------
; GLOBAL VARIABLES
; -----------------

; NumRows is +1
int NumRowsEmailServer = 16
int NumRowsSettings=17

str email_from_command_auth
str ip_from_command_auth
str email_subject_command
double NumSecondsWait
str reply_email_cmd_messages
str delete_emails_after_read
str show_msgbox_read_emails
str debug_log_mode
int max_log_file_size_in_MB
str database_sqlite_name
str log_filename

str popexe_admin_email
str send_mail_cc_to_email_admin
str send_mail_bcc_to_email_admin
str file_email_response_attach

str POPEncryptedPassword
str SMTPEncryptedPassword

int POPUseSSL
int SMTPUseSSL

str POPMailServer
int POPPortServer
str POPUsername
str POPSecureSSL
str POPEmail

str POPPassword
str SMTPPassword


str SMTPMailServer
int SMTPPortServer
str SMTPUsername
str SM   TPSecureSSL
int EmailTimeOut
str SMTPEmail

str POP_imap_mode

str CCEmail=""
str BCCEmail=""
str ReplyEmail=""
str RawBody

int has_error =0
str err_text

int r

str TextLog
str LineLog

str FileAttach=""

; ---------------------------
; CHILKATSOFT COM+ INITIALIZE
; ---------------------------

; *****************
// Chilkatsoft Code -> Delete before share!! Change before use !!
def ChilkatCode "30-day trial"
; *****************

; COM+ Create Chilkat components
typelib Chilkat {004CB902-F437-4D01-BD85-9E18836DA5C2} 1.0

Chilkat.ChilkatMailMan mailman._create
Chilkat.ChilkatEmailBundle bundle._create
Chilkat.ChilkatEmail email._create
Chilkat.ChilkatImap imap._create

//Unlock Chilkat
//  Any string argument automatically begins the 30-day trial.
int success = mailman.UnlockComponent(ChilkatCode)
if !success 
	mes mailman.LastErrorText NameApp
	end
if !mailman.IsUnlocked
	TextLog= F"Error. ChilkatSoft Locked. "
	TextLog.from(TextLog mailman.LastErrorText)
	   mes TextLog NameApp
	end
else
	out "Chilkat Unlock code satisfactory."

str ChilVer=mailman.Version
out F"Chilkat Version:{ChilVer}"

; ----------
; RESOURCES
; ----------
Tray t.AddIcon("resource:<Popexe>50394 mailbox12.ico" "Popexe" 0 &sub.TrayCallback)

; ---------------------------------------
; Read Default Directory and INI Filename
; ---------------------------------------

#if EXE=1
	str s1
	int lendir
	if find(directoryname "System32") ;; Run on Start Up
		if(rget(directoryname WinRegisterPopExe "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" HKEY_LOCAL_MACHINE|HKEY_64BIT))
			out s1
			lendir=len(directoryname)-len(ExecutableName)
			s1.left(directoryname lendir)
			out s1
			directoryname=s1
	lpstr Filename=F"{directoryname}\{INIFilename}"
#else	 
	str directoryname=DebugDirectory
	lpstr Filename=F"{directoryname}\{INIFileDevelopname}"
#endif

out F"INI Filename:{Filename}"

; -------------------------------------------------
; READ INI FILE
; --------------   -----------------------------------
	
//EmailServer

ARRAY(str) var_name.create(NumRowsEmailServer)
ARRAY(str) var_result.create(NumRowsEmailServer)

ARRAY(str) var_settings.create(NumRowsSettings)
ARRAY(str) var_resulset.create(NumRowsSettings)

int i

var_name[0]="smtp_server"
var_name[1]="smtp_port"
var_name[2]="smtp_user"
var_name[3]="smtp_password"
var_name[4]="smtp_auth"
var_name[5]="smtp_secure"
var_name[6]="email_timeout"
var_name[7]="smtp_email"
var_name[8]="smtp_displayname"
var_name[9]="smtp_replyto"
var_name[10]="pop_server"
var_name[11]="pop_port"
var_name[12]="pop_user"
var_name[13]="pop_password"
var_name[14]="pop_auth"
var_name[15]="pop_secure"
;var_name[16]="pop_imap_mode" -> Not implemented

str EmailServer=""

//Settings
var_settings[1]="email_from_command_auth"
var_settings[2]="ip_from_command_auth"
var_settings[3]="email_subject_command"
var_settings[4]="read_email_seconds"
var_settings[5]="num_commands_defined"
var_settings[6]="reply_email_cmd_me   	ssages"
var_settings[7]="delete_emails_after_read"
var_settings[8]="show_msgbox_read_emails"
var_settings[9]="debug_log_mode"
var_settings[10]="max_log_file_size_in_MB"
var_settings[11]="database_sqlite_name"
var_settings[12]="log_filename"
var_settings[13]="popexe_admin_email"
var_settings[14]="send_mail_cc_to_email_admin"
var_settings[15]="send_mail_bcc_to_email_admin"
var_settings[16]="file_email_response_attach"

; ----------------------------
; Read INI File - Email Server
; ----------------------------

//Check if INI exists

has_error=0
for i 0 NumRowsEmailServer
	if(rget(var_result[i] var_name[i] "EMAIL SERVER" Filename))
		err ;;handles the error
			err_text = F"INI File Error: {_error.description} in Line: {_error.place} Iid: {_error.iid} Place: {_error.place} Code: {_error.code} Source: {_error.source} Command: {_error.line}. The value or the Key: {var_name[i]}, Section: [EMAIL SERVER] File: {Filename} does not exist"
			out err_text
			mes err_text NameApp
			end
	
	   
	
		out F";{var_name[i]} {var_result[i]}"
		
		if var_name[i]="smtp_password" or var_name[i]="pop_password"
			EmailServer=F"{EmailServer}[]{var_name[i]} {var_result[i]}"
		else
			EmailServer=F"{EmailServer}[]{var_name[i]} {var_result[i]}"
			
	else
		if var_result[i]
			TextLog=F"INI File Error. The value or the Key: {var_name[i]}, Section: [EMAIL SERVER] File: {Filename} does not exist"
			out TextLog
			mes TextLog NameApp
			end


EmailServer=
F
 smtp_server {var_result[0]}
 smtp_port {var_result[1]}
 smtp_user {var_result[2]}
 smtp_password !{var_result[3]}
 smtp_auth {var_result[4]}
 smtp_secure {var_result[5]}
 email_timeout {var_result[6]}
 smtp_email {var_result[7]}
 smtp_displayname {var_result[8]}
 smtp_replyto {var_result[9]}
 pop_server {var_result[10]}
 pop_port {var_result[11]}
 pop_user {var_result[12]}
 pop_password !{var_result[13]}
 pop_auth {var_result[14]}
 pop_secure {var_result[15]}

out F"EmailServer[]{EmailServer}"

; ------------------------   
; Read INI File - Settings
; ------------------------

for i 0 NumRowsSettings
	if(rget(var_resulset[i] var_settings[i] "SETTINGS" Filename))
		out F";{var_settings[i]} {var_resulset[i]}"
		out F"Setting:{var_settings[i]} Result:{var_resulset[i]}"
		
	else
		TextLog=F"INI File Error. The value or the Key: {var_settings[i]}, Section: [SETTINGS] File: {Filename} does not exist"
		out TextLog
		mes TextLog NameApp
		end

//Asign to variables Settings
email_from_command_auth=var_resulset[1]
ip_from_command_auth=var_resulset[2]
email_subject_command = var_resulset[3]
NumSecondsWait=val(var_resulset[4])
int NumCommands=val(var_resulset[5])
reply_email_cmd_messages = var_resulset[6]
delete_emails_after_read = var_resulset[7]
show_msgbox_read_emails=var_resulset[8]
debug_log_mode=var_resulset[9]
max_log_file_size_in_MB=val(var_resulset[10])
database_sqlite_name=var_resulset[11]
log_filename=var_resulset[12]
popexe_admin_email=var_resulset[13]
send_mail_cc_to_email_admin=var_resulset[1   4]
send_mail_bcc_to_email_admin=var_resulset[15]
file_email_response_attach=var_resulset[16]

reply_email_cmd_messages.trim(" ")
send_mail_cc_to_email_admin.trim(" ")
send_mail_bcc_to_email_admin.trim(" ")
popexe_admin_email.trim(" ")
file_email_response_attach.trim(" ")

//Assign to EmailServer Settings (Chilkat Method)
POPEncryptedPassword=var_result[13]
SMTPEncryptedPassword=var_result[3]

POPMailServer=var_result[10]
POPPortServer=val(var_result[11])
POPSecureSSL=var_result[15]
POPUsername=var_result[12]

SMTPMailServer=var_result[0]
SMTPPortServer=val(var_result[1])
SMTPUsername=var_result[2]
SMTPSecureSSL=var_result[5]
SMTPEncryptedPassword=var_result[3]
SMTPEmail=var_result[7]

EmailTimeOut=var_result[6]

;POP_imap_mode=var_result[16] -> Not implemented

//Verify Max Log File Size
debug_log_mode.ucase

if max_log_file_size_in_MB<=0
	TextLog=F"Error. INI File. The value or the Key: {var_settings[10]}, Section: [SETTINGS] File: {Filename} does not exist or equal to z   ero"
	out TextLog
	mes TextLog NameApp
	end

if NumSecondsWait=0
	TextLog=F"Error. INI File. The value or the Key: {var_settings[4]}, Section: [SETTINGS] File: {Filename} does not exist or equal to zero"
	out TextLog
	mes TextLog NameApp
	end

//Database SQLite Name
lpstr MySqLitefile=F"{directoryname}\{database_sqlite_name}"

//Log FileName
if len(log_filename.trim(" "))<1
	TextLog=F"Error. INI File. The value or the Key: log_filename, Section: [SETTINGS], INI File: {Filename} does not exist or equal to zero"
	out TextLog
	mes TextLog NameApp
	end
str FileLog =F"{directoryname}\{log_filename}"

//Change Log File Size
if max_log_file_size_in_MB<1
	TextLog=F"Error. INI File. The value or the Key: max_log_file_size_in_MB, Section: [SETTINGS], INI File: {Filename} does not exist or equal to zero"
	out TextLog
	mes TextLog NameApp
	end
int FileLogSize=max_log_file_size_in_MB*1024*1024

//Read INI File - Commands
str SectionNameCommand="COMMANDS"
ARRAY(str) Command.create(NumCom   mands)
ARRAY(str) CommandExecute.create(NumCommands)
ARRAY(str) CommandUsage.create(NumCommands)

for i 0 NumCommands
	
	if(rget(Command[i] F"cmd{i}" "COMMANDS" Filename))
		TextLog=F"Command {i}:{Command[i]}"
		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0210"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	else
		TextLog=F"the value or the Key: cmd{i}, Section: [COMMANDS] File: {Filename} does not exist"
		out TextLog
		LineLog="0210"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	
	if(rget(CommandExecute[i] F"cmd_exe{i}" "COMMANDS" Filename))
		TextLog=F"Command Execute {i}:{CommandExecute[i]}"
		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0223"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	else
		TextLog=F"the value or the Key: cmd_exe{i}, Section: [COMMANDS] File: {Filename} does not exist"
		out TextLog
		LineLog="0227"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

	if(rget(CommandUsage[i   ] F"cmd_usage{i}" "COMMANDS" Filename))
		TextLog=F"Command Usage {i}:{CommandUsage[i]}"
		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0234"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	else
		TextLog=F"the value or the Key: cmd_usage{i}, Section: [COMMANDS] File: {Filename} does not exist"
		out TextLog
		LineLog="0240"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		
; -------------------------------------------------
; BEGIN

if debug_log_mode.ucase="YES"
	TextLog="Inicialization INI File OK...";LineLog="0246"
	sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

; INIT

rep	 
	; ----------------------
	; CHECK SQLITE FILE
	; ----------------------
	Sqlite MySQLiteDB
	if !FileExists(MySqLitefile) ;;create database for testing
		MySQLiteDB.Open(MySqLitefile)
		str sql="CREATE TABLE [Emails]([Id] INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, [EmailDate] TEXT,[FromEmail] TEXT, [Subject] TEXT, [Body] TEXT, [Command] TEXT, [DateTimeE   xec] TIMESTAMP, [CommandExec] TEXT, [ResultExec] TEXT);"
		MySQLiteDB.Exec(sql)
		err
			TextLog=F"Error Open SQLite DB: {_error.description} SQL: {sql}"
			out TextLog
			mes TextLog NameApp
			LineLog="0269"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
			end
	else
		MySQLiteDB.Open(MySqLitefile)
		err
			TextLog=F"Error Open SQLite DB: {_error.description} SQL: {sql}"
			out TextLog
			mes TextLog NameApp
			LineLog="0278"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
			end
			
	MySQLiteDB.Close
	
    ; -------------
	; Check_Email
	; -------------
	ARRAY(str) a
	str s
	str EmailSubject, EmailBody, FromEmail, Log, EmailDate, EmailHeader	
	
	has_error=0
	Pop3Mail p; MailBee.Message m
	
	;----- ASK FOR DELETE ALL EMAILS ---------------
	
	int Flags1
	if delete_emails_after_read.ucase="YES"
		if show_msgbox_read_emails.ucase="YES"
			Flags1=2|0x100
			TextLog="delete_emails_after_read=YES, show_msgbox_read_emails=YES"
		else
			Flags1=   2
			TextLog="delete_emails_after_read=YES, show_msgbox_read_emails=NO"
	else
		if show_msgbox_read_emails.ucase="YES"
			Flags1=0x100
			TextLog="delete_emails_after_read=NO, show_msgbox_read_emails=YES"
		else
			Flags1=0
			TextLog="delete_emails_after_read=NO, show_msgbox_read_emails=NO"
		
	out TextLog
	if debug_log_mode.ucase="YES"
		LineLog="0314"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
			
	; Chilkat Email Method
	; ---------------------
	
	//Set the ImmediateDelete property = 0
	//When the DeleteEmail method is called, the POP3 session
	//will remain open and the emails will be deleted all at once
	//when the session closes.
	
	mailman.ImmediateDelete = 0
	
	POPPassword.decrypt(1|4 POPEncryptedPassword EncryptionKeyBase64)
	err
		TextLog="Error to try decrypt Password: {_error.description}"
		LineLog="0491"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		mes TextLog NameApp
		end
		
	if POPSecureSSL="1"
		POPUseSSL=-1
	else
		P   OPUseSSL=0
	
	SMTPPassword.decrypt(1|4 POPEncryptedPassword EncryptionKeyBase64)
	
	if SMTPSecureSSL="1"
		SMTPUseSSL=-1
	else
		SMTPUseSSL=0
	
	mailman.MailHost = POPMailServer
	mailman.PopUsername = POPUsername
	mailman.PopPassword = POPPassword
	mailman.PopSsl = POPUseSSL
	mailman.MailPort = POPPortServer

	//  Set the SMTP server's hostname and login/password.
	mailman.SmtpHost=SMTPMailServer
	mailman.SmtpUsername=SMTPUsername
	mailman.SmtpPassword=SMTPPassword
	mailman.SmtpSsl=SMTPUseSSL
	mailman.SmtpPort=SMTPPortServer
	
	; Verbose Log for error email Chilkat messages -> Only Debug mode
	;------------------------------
	;if debug_log_mode.ucase="YES"
		;mailman.VerboseLogging=-1 -> Is too much information ;-)
	;else
		;mailman.VerboseLogging=0

	//Define Timeout for Read/Send Emails (POP/SMTP)
	int EmailTimeOutMs=EmailTimeOut * 1000	;;In miliseconds
	mailman.ConnectTimeout=EmailTimeOutMs
	
	//  Get the number of messages in the mailbox.
	int numMessages
	
	//POP3    Connect session
	success=mailman.Pop3Connect
	if !success
		TextLog=mailman.LastErrorText
		LineLog="0591"
		out TextLog
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		if debug_log_mode.ucase="YES"
			mes TextLog NameApp
			end
	else
		TextLog="POP3 Connected."
		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0602"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	
	//Count Email Messages and Continue if contains email messages
	numMessages = mailman.GetMailboxCount
	err
		TextLog=F"Error to try Count Emails:{_error.description}[]"
		TextLog.from(TextLog mailman.LastErrorText)
		LineLog="0555"
		out TextLog
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	if numMessages=-1
		TextLog=F"Error to try Count Emails:{_error.description}[]"
		TextLog.from(TextLog mailman.LastErrorText)
		LineLog="0561"
		out TextLog
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		if debug_log_mode.ucase="YES"
			mes TextLog NameApp
			   end
	
	TextLog=F"Number Email Messages Read:{numMessages}"	
	out TextLog
	if debug_log_mode.ucase="YES"
		LineLog="0485"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

	if numMessages>0
		has_error=0
	else
		has_error=-1
		out mailman.LastErrorText
		if debug_log_mode.ucase="YES"
			TextLog=mailman.LastErrorText
			LineLog="0495"
			out TextLog
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		
	if has_error=-1; goto CONTINUE_AFTER_FOREACH
	
		//  Copy the all email from the user's POP3 mailbox
		//  into a bundle object.  The email remains on the server.
		

	; ------------------------------------------------
	; Find Email From Command (For each Email message)

	//Read all Headers (for index Emails with i...)
	bundle = mailman.GetAllHeaders(1)

	for i 1 (numMessages)
		
		email=bundle.GetEmail(i)
		EmailDate=email.EmailDate
		EmailSubject=email.subject
		EmailSubject.ucase
		EmailHeader=email.header
		EmailBody=email.GetPlainTextBody ;;With   out HTML...
		FromEmail=email.fromAddress
		
		Log.from("---------------[]Email id: " i "[]---------------[]DateTime: " EmailDate "[]Subject: " EmailSubject "[]From: " FromEmail "[]---------------[]Header:[]" EmailHeader "[]---------------[]Body/Command:[]" EmailBody)
		TextLog=Log
		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0382"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
			;OnScreenDisplay Log 3 0 -1 "Comic Sans MS" 0 0xff0000 2
		
		email_subject_command.trim(" ")
		int long_email_subject_command = len(email_subject_command)
		
		FromEmail.trim(' ')
		email_subject_command.trim(" ")
		email_subject_command.ucase
		int long_email_from = len(email_from_command_auth)
		
		if long_email_from >0 ;; If has limitations of Domain-Email Auth
			str At
			At.get(email_from_command_auth 0 1)
			if At="@" ;; Check if restrict from All Email Domain
				int find_domain=find(FromEmail.ucase email_from_command_auth.ucase 0 1)
				err find_domain=0
				if find_d   omain>0	
					TextLog=F"Email Domain Auth found OK. Email: {FromEmail.ucase} Domain: {email_from_command_auth.ucase}."
					out TextLog
					if debug_log_mode.ucase="YES"
						LineLog="0381"
						sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				else
					TextLog=F"Email Domain Auth NOT found. Email: {FromEmail.ucase} Domain: {email_from_command_auth.ucase}. Next read email..."
					out TextLog
					if debug_log_mode.ucase="YES"
						LineLog="0381"
						sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
					goto CONTINUE_NEXT_FOREACH
			else
				if !find(FromEmail email_from_command_auth 0 1)
					TextLog=F"Not 'From Email' Auth valid: {FromEmail}. Valid Email: {email_from_command_auth}"
					out TextLog
					if debug_log_mode.ucase="YES"
						LineLog="0354"
						sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
						goto CONTINUE_NEXT_FOREACH
						
		TextLog=F"[].....[]From email valid:{FromEmail}"
		out TextLog
		if debug_log_mode.ucase="YES"
   			LineLog="0717"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

		; ----------------------------
		; Check IP Server if necessary

		ip_from_command_auth.trim(" ")
		
		if len(ip_from_command_auth)>0
			
			str TextIP=ip_from_command_auth
			TextIP.trim(" ")
			
			RawBody=email.header
			
			; Chilkat Method
			; --------------
			int find_ip=find(RawBody TextIP 0 1)
			
			if find_ip>0 ;;IP Encountered
				TextLog=F"IP auth Valid: {ip_from_command_auth}. TextIP:{TextIP}. Continue..."
				out TextLog
				if debug_log_mode.ucase="YES"
					LineLog="0410"
					sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				goto CONTINUE_EMAIL_VALID
			else
				TextLog=F"IP auth NOT Valid: {ip_from_command_auth}. TextIP:{TextIP}. Read next email..."
				out TextLog
				if debug_log_mode.ucase="YES"
					LineLog="0393"
					sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				goto CONTINUE_NEXT_FOREACH
		
		; ----------------------
		; CONTINUE_EMAIL_   VALID
		TextLog=F"Ok. Email Auth valid: {FromEmail}. Find Commands on Email..."
		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0362"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		
		
		; ***********************************
		; If is necessary filter from Subject Command
		if long_email_subject_command>0
			
			//Find Subject Command and compare
			int find_subject_cmd=find(EmailSubject.trim(" ") email_subject_command.trim(" ") 0 1)
			err
				TextLog=F"Error: Email Subject: {EmailSubject} Command: {email_subject_command}"
				out TextLog
				LineLog="0401"
				sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				end
				
			if find_subject_cmd>=0
				TextLog=F"Continue with Subject Command: {EmailSubject}..."
				out TextLog
				if debug_log_mode.ucase="YES"
					LineLog="0410"
					sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				
				TextLog=F"---------------- Command Found ----------------------------[]{EmailBody}[]----------   -------------------------------------------------"
				out TextLog
				if debug_log_mode.ucase="YES"
					LineLog="0420"
					sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				
				int LongEmailBody=EmailBody.len
				
				//Check if Email Body is Fill
				if LongEmailBody>0
					; ------------------------------------------
					; FIND IF EMAIL IS ALREADY SAVE ON SQLITE DB
					; ------------------------------------------
					
					EmailDate.trim(" ")
					
					ARRAY(str) ar
					sql=F"SELECT [Id], [EmailDate], [FromEmail], [Subject], [Body] FROM Emails where [EmailDate]='{EmailDate}'"
					out sql
					MySQLiteDB.Open(MySqLitefile)
					MySQLiteDB.Exec(sql ar)
					MySQLiteDB.Close
					int FindEmailonSQLiteDB =0
					for r 0 ar.len ;;for each row
						out F"{ar[0 r]} {ar[1 r]} {ar[2 r]} {ar[3 r]} {ar[4 r]}"

						TextLog=F"EmailDate:{ar[1 r].ucase} - {EmailDate.ucase} - Len: {len(ar[1 r])} - {len(EmailDate)}"
						TextLog=F"{TextLog}[]FromEmail:{ar[2 r].ucase}    - {FromEmail.ucase} - Len: {len(ar[2 r])} - {len(FromEmail)}"
						TextLog=F"{TextLog}[]EmailSubject:{ar[3 r].ucase} - {EmailSubject.ucase} - [] Len: {len(ar[3 r])} - {len(EmailSubject)}"
						TextLog=F"{TextLog}[]EmailBody:[]{ar[4 r].ucase} - []{EmailBody.ucase} - [] Len: {len(ar[4 r])} - {len(EmailBody)}"
						out TextLog
						if debug_log_mode.ucase="YES"
							LineLog="0521"
							sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

						if ar[1 r]=EmailDate and ar[2 r].ucase=FromEmail.ucase and ar[3 r].ucase=EmailSubject.ucase and ar[4 r].ucase=EmailBody.ucase
							TextLog="Email found on SQLite Database. No mail processing, read next..."
							out TextLog
							if debug_log_mode.ucase="YES"
								LineLog="0450"
								sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
							FindEmailonSQLiteDB=1
							break
							
					
					if FindEmailonSQLiteDB=0
						TextLog="Email not found on SQLite Database. Find Command..."
						out TextLog
						if debug_   log_mode.ucase="YES"
							LineLog="0459"
							sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
							
						; -----------------------------------------
						; FIND COMMANDS
						; run EmailBody
						; -----------------------------------------
						// Per line...
						
						s=EmailBody
						int li
						int pos1
						int len1
						int j
						int NumLines
						str tmps
						TextLog=F"EmailBody: {s}"
						out TextLog
						if debug_log_mode.ucase="YES"
							LineLog="0477"
							sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
							
						ARRAY(int) Lines.create(1000)
						ARRAY(str) linetext.create(1000)
						j=0
						for li 0 1000
							i=findl(s -li)
							out F"Li:{li} i:{i}"
							out F"Words in line i:{i}"
							if(i<0) break
															
							Lines[j]=i
							j=j+1
							out F"Line {j}:{i}"
								
						NumLines=j
								
						for i 1 j+1
							tmps=s
							pos1=Lines[i-1]
							len1=Lines[i]-Lines[i-   1]
							if NumLines=1
								linetext[i]=tmps
							else
								linetext[i]=tmps.get(tmps pos1 len1)
							TextLog=F"Linetext[{i}]:{linetext[i]}"
							out TextLog
							if debug_log_mode.ucase="YES"
								LineLog="0511"
								sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
								
						; -------------------------------------------
						; OTHER LINETEXT Capture x Line...
						
						str s2
						ARRAY(int) pos_ini.create(1000)
						int pos_ini1
						ARRAY(int) pos_fin.create(1000)						
						int pos_fin1
						int pos
						int y
						int v
						int w
						int Continue1=0
						ARRAY(str) Linetext2.create(1000)
						s2=s			
						
						for j 0 500
							s2.trim(10)
							s2.trim(13)
							s2.trim(" ")
							
						NumLines=0
						for y 0 1000000000
							if(s2.getl(s -y)<0) break ;;no more
							if(s2.len=0) continue ;;skip empty
							out s2
							Linetext2[NumLines]=s2
							out F"Linetext2(NumLines):{NumLines}:{Linetext2[   NumLines]}"
							NumLines=NumLines+1
						out F": NumLines: {NumLines}"
						
						int f=0
						
						//Recursive_Find_Lines
						
						Continue1=0
						for y 0 NumLines
							int Found
							int LongLine
							
							//New_Find
							for v 0 NumCommands
							
								Found=0
								pos=find(Linetext2[y] Command[v] 0 1) ;;Case insensitive
								err
									out F"Error:{_error.description} Index y:{y}"
									
								out F"Linetext2({y}):{Linetext2[y]} [] Command({v}): {Command[v]}"
								
								if pos=0 ;; The first not recount
									pos_ini1=len(Command[v])+1
									Continue1=1
									Found=0
									
									for w 0 NumCommands
										
										pos=find(Linetext2[y] Command[w] pos_ini1 1) ;;Case insensitive
										
										if pos>0																			
											Found=1
											linetext[f]=linetext[f].left(Linetext2[y] pos)
											LongLine=len(Linetext2[y])-len(linetext[f])
											out F"New Line: linetext({f}):{l   inetext[f]}[]Line Origin: Linetext2({y}):{Linetext2[y]}"
											Linetext2[y]=Linetext2[y].right(Linetext2[y] LongLine)									
											out F"Line To Review:Linetext2({y}):{Linetext2[y]}"
											f=f+1
											break
										else
											Found=0
									
							if Found=0
								linetext[f]=Linetext2[y]
								Continue1=0
								out F"New Line (complete): linetext({f}):{linetext[f]}"
								f=f+1
							else
								goto New_Find ;;Recursive until no more than one Command x Line
						
						out F"NumLines:{f}"
						
						if f>0
							NumLines=f-1
						else
							NumLines=f
						
						out F"Total NumLines: {NumLines}"
						for f 0 NumLines
							out F"linetext(f):{f}:{linetext[f]}"
						
						str RunCMD
						int Findcmd
						str LinesBody
												
						; Check if exists file attach to response reply email
						; ----------------------------------------------------
						if len(file_email_response_attach)>0 and !len(FileAttach)>0
		   					FileAttach=F"{directoryname}\{file_email_response_attach}"
							del FileAttach ;; Delete before Execution...
							err
								TextLog=F"Error to delete File Email Attach:{FileAttach}. Error:{_error.description}"
								out TextLog
								LineLog="0660"
								sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
								 
						
						;*************************** EXECUTE PER LINE **************************
						
						for i 0 NumLines
							 'Per line...
							Findcmd=0
							
							for j 0 NumCommands
								if  Findcmd=0
									int lenCommand1
									lenCommand1=len(Command[j])
									
									str line2=linetext[i]
									str linetext1.left(line2 lenCommand1)
									for f 0 500
										linetext1.trim(" ")
									str command2=Command[j]
									str Command1.left(command2 lenCommand1)
									Command1.trim
									
									if linetext1.ucase=Command1.ucase
										//Find
									
										Findcmd=1
										RunCMD=linetext[i]			    							
										str RunResponse=""
										int longcommand=len(RunCMD)-len(Command[j])
										
										;------------ CASE SELECT SYSTEM COMMAND OR STANDARD COMMAND -------------
										
										int initposcommand
										str Param1
										out F"Find Command(j):{j}:{Command[j]}"
										sel Command[j]
											
											case "LIST"
											int b
											LinesBody=F"LIST OF COMMANDS[]---------------[]"
											for b 0 NumCommands
												LinesBody=F"{LinesBody}[]{CommandUsage[b]}"
												RunResponse=""
												
											;*************
											case "RUNCMD"
											;*************
											
											int pos_space=0
											initposcommand=len(Command[j])
											longcommand=len(RunCMD)
											pos_space= find(RunCMD F"[34] " (initposcommand+1))
											if pos_space=0
												pos_space=longcommand
											
											Param1.get(RunCMD pos_space+1 (longcommand))
											for y 0 500
												Param1.t   !rim(" ")
											RunCMD.get(RunCMD (initposcommand+1) (pos_space-(initposcommand)))
											for y 0 500
												RunCMD.trim(" ")
												
											TextLog=F"RunCMD: {RunCMD} Param:{Param1}"
											if debug_log_mode.ucase="YES"
												LineLog="0561"
												sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
											if len(Param1)>0
												run RunCMD Param1 "" directoryname
											else
												run RunCMD "" "" directoryname
											//Run and wait untill its process ends:
											err
												TextLog=F"Response=Command RUN Error: {_error.description}. COMMAND: {RunCMD}"
												RunResponse=TextLog
												out TextLog
												LineLog="0571"
												sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
											
											case else
											
											//Params
											initposcommand=len(Command[j])
											longcommand=len(linetext[i])

											Param1=Param1.right(linetext[i] (longcommand-i   "nitposcommand))
											err
												Param1=""

											int x
											for x 0 500
												Param1.trim(" ")
												Param1.trim("[10]")
												Param1.trim("[13]")
											//Check if Param is a Command
											int z
											for z 0 NumCommands
												if Command[z].ucase=Param1.ucase
													Param1=""
													break
											
											RunCMD=CommandExecute[j]
											TextLog=F"RUN: [34]{RunCMD}[34]. DIRECTORY NAME: {directoryname}"
											out TextLog
											if debug_log_mode.ucase="YES"
												LineLog="0574"
												sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

											TextLog=F"RunCMD: {RunCMD} [34]{Param1}[34] [34][34] {directoryname} 0x400"
											out TextLog
											if debug_log_mode.ucase="YES"
												LineLog="0739"
												sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
											
											; ********************
											; RUNCMD USER COMMANDS
											   #; ********************
											
											if len(Param1)>0
												str quote=quote.left(Param1 1)
												if quote=F"[34]"
													quote=quote.left(RunCMD 1)
													if quote=F"[34]"
														run RunCMD Param1 "" directoryname 0x400
													else
														run F"[34]{RunCMD}[34]" Param1 "" directoryname 0x400
												else
													quote=quote.left(RunCMD 1)
													if quote=F"[34]"
														run F"[34]{RunCMD}[34]" F"[34]{Param1}[34]" "" directoryname 0x400
													else
														run RunCMD F"[34]{Param1}[34]" "" directoryname 0x400
											else
												run RunCMD "" "" directoryname 0x400
											err
												TextLog=F"Response=Command RUNCONSOLE Error: {_error.description}. COMMAND: [34]{RunCMD}[34]"
												RunResponse=TextLog
												out TextLog
												LineLog="0592"
												sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
										
										; INSERT INTO A SQLITE DATABASE
		   $								; -----------------------------										 
										str MaxId2
										ARRAY(str) ar2
										sql="SELECT MAX([Id]) AS max_id FROM [Emails];"
										MySQLiteDB.Open(MySqLitefile)
										MySQLiteDB.Exec(sql ar2)
										err
											TextLog=F"Error to execute Select MAX on SQLite DB: {_error.description} SQL: {sql}"
											out TextLog
											LineLog="0643"
											sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
											mes TextLog NameApp
											end
											
										MySQLiteDB.Close
										
										MaxId2=ar2[0 0]
										
										int MaxId=val(MaxId2)
										MaxId=MaxId+1
										
										DateTime TimeStamp1
										str TimeStamp_str
										TimeStamp1.FromComputerTime
										TimeStamp_str=TimeStamp1.ToStr(8)
										
										EmailBody= email.body
										 
										sql=F"INSERT INTO [Emails] VALUES ({MaxId},'{EmailDate}','{FromEmail}','{EmailSubject}','{EmailBody}','{linetext[i]}','{TimeStamp   %_str}','{CommandExecute[j]}',' ')"
										MySQLiteDB.Open(MySqLitefile)
										MySQLiteDB.Exec(sql)
										err
											TextLog=F"Error Insert on SQLite DB: {_error.description} SQL: {sql}"
											out TextLog
											LineLog="0672"
											sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
											mes TextLog NameApp
											end
										MySQLiteDB.Close
										
							 
						;*********** EXECUTE x LINE BODY *************************
						 
						; -------------------
						; SEND EMAIL RESPONSE
						; -------------------
						reply_email_cmd_messages.trim(" ")
						send_mail_cc_to_email_admin.trim(" ")
						send_mail_bcc_to_email_admin.trim(" ")
						
						if reply_email_cmd_messages.ucase="YES" or send_mail_cc_to_email_admin.ucase="YES" or send_mail_bcc_to_email_admin.ucase="YES"
							
							int TestEmail=0
							//Restore original Email Texts
							
							//Check From, CC and CCO to send Emails
							if send_mail_cc_to_ema   &il_admin.ucase="YES" and len(popexe_admin_email.trim(" "))>0 and reply_email_cmd_messages.ucase="YES"
								FromEmail=email.FromAddress
								CCEmail=popexe_admin_email
							else
								if send_mail_cc_to_email_admin.ucase="YES" and len(popexe_admin_email.trim(" "))>0 and reply_email_cmd_messages.ucase="NO"
									FromEmail=popexe_admin_email
								else
									if send_mail_bcc_to_email_admin.ucase="YES" and len(popexe_admin_email.trim(" "))>0 and reply_email_cmd_messages.ucase="YES"
										FromEmail=email.FromAddress
										BCCEmail=popexe_admin_email
									else
										if send_mail_bcc_to_email_admin.ucase="YES" and len(popexe_admin_email.trim(" "))>0 and reply_email_cmd_messages.ucase="NO"
											FromEmail=popexe_admin_email
										else
											FromEmail=email.FromAddress
							
							EmailSubject=email.subject
							EmailBody= email.body

							//Fill Lines Body Execution
							LinesBody=""
							for x 0 NumLines
								LinesBody=F"{LinesBo   'dy}[]{linetext[x]}"
								
							str RawHeader=email.header							 
							
							str EmailBody2=F"[]COMMANDS EXECUTED:[][]{LinesBody}[][]---------------------------------------------------[][]{RawHeader}"
							 
							TextLog=TextLog=F"SEND MAIL []{FromEmail} Rv: {EmailSubject} Body:{EmailBody2} Test:{TestEmail} File Attach{FileAttach} CC:{CCEmail} BCC:{BCCEmail} EmailServer:{EmailServer}[]---------------------"
							out TextLog
							if debug_log_mode.ucase="YES"
								LineLog="0969"
								sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
							
							//Check if FileAttach Exists after execution
							int attr=FileGetAttributes(FileAttach) ;;err out _error.description; ret
							err
								FileAttach="" ;;File Not Exists
								TextLog=F"FileAttach Not Exists:{FileAttach}"
								out TextLog
								if debug_log_mode.ucase="YES"
									LineLog="0769"
									sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
							
							; SendMail Chilkat M   (ethod
							; -----------------------
							Chilkat.ChilkatEmail Emailsend._create
							
							//Prepare Email
							Emailsend.Subject = EmailSubject
							Emailsend.Body = EmailBody2
							Emailsend.From = FromEmail
							if len(CCEmail)>0
								Emailsend.AddCC(CCEmail CCEmail)
							if len(BCCEmail)>0
								Emailsend.AddBcc(BCCEmail BCCEmail)
							if len(FileAttach)>0
								Emailsend.AddDataAttachment(FileAttach "File Attached")
								
							//Attach Email
							success = Emailsend.AddTo(FromEmail FromEmail)
							
							//Send Email
							success=mailman.SendEmail(Emailsend)
							
							if !success
								TextLog=mailman.LastErrorText
								LineLog="1348"
								sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
								if debug_log_mode.ucase="YES"
									mes TextLog NameApp
									end
							else
								TextLog=F"Send Email. To: {FromEmail} CC: {CCEmail} BCC: {BCCEmail} Subject: {EmailSubject}"
								out TextLog
								if d   )ebug_log_mode.ucase="YES"
									LineLog="1355"
									sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

						; If - From Send Email						
						; --------------------
						
				else
					TextLog=F"Command Body incorrect: {EmailBody}"
					out TextLog
					if debug_log_mode.ucase="YES"
						LineLog="0682"
						sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		
		; ---------------------------
		; Delete Email (if necessary)
		; ---------------------------
		if delete_emails_after_read.ucase="YES"
			success = mailman.DeleteEmail(email)
			if !success
				TextLog= mailman.LastErrorText
				out TextLog
				LineLog="1316"
				sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
				if debug_log_mode.ucase="YES"
					end
			else
				TextLog.from("Email Deleted (delete_emails_after_read=Yes). Subject: " email.subject)
				out TextLog
				LineLog="1362"
				sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		
		TextLog="Read Next Email..."
   *		out TextLog
		if debug_log_mode.ucase="YES"
			LineLog="0814"
			sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	
	
	TextLog="Read All Emails Finished."
	out TextLog
	if debug_log_mode.ucase="YES"
		LineLog="0822"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	
	TextLog="Close POP3 Session..."
	out TextLog
	if debug_log_mode.ucase="YES"
		LineLog="1335"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
		
	success = mailman.Pop3EndSession
	if !success
		TextLog=mailman.LastErrorText
		out TextLog
		LineLog="1341"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	
	TextLog="Close SQLite database..."
	out TextLog
	if debug_log_mode.ucase="YES"
		LineLog="0700"
		sub.WriteFileLog(&TextLog &LineLog &FileLog &FileLogSize)
	
	MySQLiteDB.Close
	err
		out "Error to try Close SQLite DB. Already closed."
		continue

	TextLog=F"WAIT...Seconds: {NumSecondsWait}"
	out TextLog
	if debug_log_mode.ucase="YES"
		LineLog="0712"
		sub.Wr   +iteFileLog(&TextLog &LineLog &FileLog &FileLogSize)

	wait NumSecondsWait


#sub WriteFileLog v
function str&TextLog str&LineLog str&logfile int&logfilesize

//str NameApp="PopExe" -> With v attribute is not necessary

_logfile=logfile
_logfilesize=logfilesize

DateTime TimeStamp1
str TimeStamp_str

TimeStamp1.FromComputerTime
TimeStamp_str=TimeStamp1.ToStr(8)

TextLog=F"{TimeStamp_str} - Line: {LineLog} - {TextLog}"

LogFile TextLog

err
	TextLog=F"Error output File Log:{_logfile}"
	out TextLog
	mes TextLog NameApp
	end

ret


#sub TrayCallback
function Tray&x message

//Callback function for Tray.AddIcon.
//Called for each received message - when tray icon clicked, or mouse moved.
 
//x - reference to this object.
//message - mouse message (WM_MOUSEMOVE, WM_LBUTTONDOWN, etc).


//OutWinMsg message 0 0 ;;uncomment to see received messages

sel message
	case WM_LBUTTONUP
		out "left click"
	sub.OnTrayIconRightClick x.param
	case WM_RBUTTONUP
		out "right cl   ,ick"
	sub.OnTrayIconRightClick x.param
	
	case WM_MBUTTONUP
		out "middle click"
	sub.OnTrayIconRightClick x.param


#sub OnTrayIconRightClick
function param

//created and can be edited with the Menu Editor

//Variables Register and constants
str WinStart="No"
str WinRegisterPopExe="PopExe"
str NameApp="PopExe"
str ExecutableName="PopExe.exe"
str EmailSupport="helpdesksoftwaresimple@gmail.com"

;Read INI Filename
;------------------------
#if EXE=1
	str directoryname=GetCurDir
	str s1
	int lendir
	if find(directoryname "System32") ;; Run on Start Up
		if(rget(directoryname WinRegisterPopExe "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" HKEY_LOCAL_MACHINE|HKEY_64BIT))
			out s1
			lendir=len(directoryname)-len(ExecutableName)
			s1.left(directoryname lendir)
			out s1
			directoryname=s1
#else
	str directoryname="C:\Users\Manuel\Documents\My QM"
#endif

ExecutableName=F"{directoryname}\{ExecutableName}"

//Filenames ->.INI and DB SQLite
lpstr Filename=F"{directory   -name}\popexe.ini"


;Check Windows Register Run for visualize Menu
;---------------------------------------------

//http://es.ccm.net/forum/affich-126457-como-agregar-programas-de-inicio-de-windows
str s
str md

str md_check=
 BEGIN MENU
 &Exit :2
 &About :3
 >&Feedback :4
 	&Send a Bug :5
 	&Send me an Idea or a New Command :6
 	&Contact me or Support :7
 	<
 &Start on Windows User Logon :8 0x0 0x8
 END MENU

str md_no_check=
	 BEGIN MENU
	 &Exit :2
	 &About :3
	 >&Feedback :4
	 	&Send a Bug :5
	 	&Send me an Idea or a New Command :6
	 	&Contact me or Support :7
	 	<
	 &Start on Windows User Logon :8
	 END MENU


if(rget(s WinRegisterPopExe "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" HKEY_LOCAL_MACHINE|HKEY_64BIT))
	out s
	WinStart="Yes"
	md=md_check
	 
else
	out "the value or the key does not exist"
	WinStart="No"
	md=md_no_check
	 
str TextLog
str LineLog

int i=ShowMenu(md); out i

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
if i>3 ;; For send a bug or a E   .mail message -> Prepare to get information needs

	 ' Capture TimeStamp
	DateTime TimeStamp1
	str TimeStamp_str
	TimeStamp1.FromComputerTime
	TimeStamp_str=TimeStamp1.ToStr(8)
		
	; Read Log File
	; --------------------------------
	str LogFile LogFile1
	if(rget(LogFile1 "log_filename" "SETTINGS" Filename))
		err
			TextLog=F"Error: {_error.description} []Error to try read log_filename variable. Please, send Bug description to: {EmailSupport}"
			out TextLog
			mes TextLog NameApp
		
		LogFile=F"{directoryname}\{LogFile1}"
		TextLog=F"LogFile: {LogFile}"
		out TextLog
		LogFile.trim(" ")
	
	; Read SMTP Email
	; ----------------------------
	str FromEmail
	if(rget(FromEmail "smtp_email" "EMAIL SERVER" Filename))
		err
			TextLog=F"Error: {_error.description} []Error to try read log_filename variable. Please, send Bug description to: {EmailSupport}"
			out TextLog
			mes TextLog NameApp
		out F"From Email: {FromEmail}"
		FromEmail.trim(" ")
	 
	; ----------------------------   /---
	; Read INI File - Email Server
	str EmailServer=""
	int j
	ARRAY(str) var_name.create(17)
	ARRAY(str) var_result.create(17)
	ARRAY(str) var_settings.create(17)
	ARRAY(str) var_resulset.create(17)
	
	var_name[0]="smtp_server"
	var_name[1]="smtp_port"
	var_name[2]="smtp_user"
	var_name[3]="smtp_password"
	var_name[4]="smtp_auth"
	var_name[5]="smtp_secure"
	var_name[6]="smtp_timeout"
	var_name[7]="smtp_email"
	var_name[8]="smtp_displayname"
	var_name[9]="smtp_replyto"
	var_name[10]="pop_server"
	var_name[11]="pop_port"
	var_name[12]="pop_user"
	var_name[13]="pop_password"
	var_name[14]="pop_auth"
	var_name[15]="pop_secure"
	var_name[16]="pop_timeout"
	
	for j 0 17
		if(rget(var_result[j] var_name[j] "EMAIL SERVER" Filename))
			err ;;handles the error
			out F";{var_name[j]} {var_result[j]}"
			EmailServer=F"{EmailServer}[]{var_name[j]} {var_result[j]}"
		 
	TextLog=F"EmailServer to send Bug: {EmailServer}"
	out TextLog
	 
	//Read Email Admin to send errors or email m   0essages
	str ReplyEmail
	if(rget(ReplyEmail "popexe_admin_email" "SETTINGS" Filename))
		err
			TextLog=F"Error: {_error.description} []Error to try read popexe_admin_email variable. Please, send Bug description to: {EmailSupport}"
			mes TextLog NameApp
	 ---------------------
	if len(ReplyEmail.trim(" "))<1
		if(rget(ReplyEmail "smtp_email" "SETTINGS" Filename))
			err
				TextLog=F"Error: {_error.description} []Error to try read smtp_email variable. Please, send Bug description to: {EmailSupport}"
				mes TextLog NameApp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

sel i
	case 2
	;**************** 	END *******************
	out "Shutdown - Ends Popexe."
	shutdown -7
	
	; -----------------
	; DIALOG WINDOW
	
	case 3
	
	; ***************** CREDITS *************************************
	 
	str credits=
 	;PopExe - Pop Email Execution
	;Copyright 2016 Manuel Salguero
	;Freeware License
	
	str dd=
	;BEGIN DIALOG
	;0 "" 0x90C80AC8 0x0 0 0 224 136 "PopExe"
	;3 Static 0x54000000 0x0   1 16 16 200 92 "PopExe Pop Email Execution[]Version 1.0 Beta[]Copyright 2016 Manuel Salguero[]Freeware License[]www.softwaresimple.es"
	;1 Button 0x54030001 0x4 168 116 48 14 "OK"
	;END DIALOG
	;DIALOG EDITOR: "" 0x2040308 "*" "" "" ""
	
	if(!ShowDialog(dd 0 0)) ret
		
	case 5
	; *************** SEND A BUG **************************

	str TextEmail ;;string variable. If need numeric, replace str with int or double.
	if inp(TextEmail F"Please, describe the bug. You can also send an email to the following address: {EmailSupport}. Thank you." F"{NameApp} - Send a Bug" "[]")

		if len(EmailServer)>0 ;;and len(LogFile)>0
			TextLog=F"SendMail helpdesksoftwaresimple@gmail.com <POPEXE Bug> {TimeStamp_str} {TextEmail} Reply-To: {ReplyEmail}[]X-Mailer: {NameApp} {EmailServer}"
			out TextLog
			SendMail "helpdesksoftwaresimple@gmail.com" F"<POPEXE Bug> {TimeStamp_str}" F"{TextEmail}" 0 "" "" "" F"Reply-To: {ReplyEmail}[]X-Mailer: {NameApp}" "" EmailServer
			err
				TextLog=F"Error: {_error.descri   2ption} []Error to try send email. Please, send Bug description to: {EmailSupport}"
				out TextLog
				mes TextLog NameApp
				goto EndCase
				
			TextLog="Information sent. Thank you."
			out TextLog
			mes TextLog
		else
			TextLog=F"Error to read Email Server. Please, send Bug description to: {EmailSupport}"
			out TextLog
			mes TextLog NameApp
			goto EndCase
	
	;************************************************************
	
	case 6
	
	;*************** SEND A IDEA OR A NEW COMMAND **************************
	if inp(TextEmail F"Please, describe the new Idea, or send a new command. You can also send an email to the following address: {EmailSupport}. Thank you." F"{NameApp} - Send an Idea or a New Command" "[]")
		
		if len(EmailServer)>0 ;;and len(LogFile)>0
			TextLog=F"SendMail helpdesksoftwaresimple@gmail.com <POPEXE Idea> {TimeStamp_str} {TextEmail} Reply-To: {ReplyEmail}[]X-Mailer: {NameApp} {EmailServer}"
			out TextLog
			SendMail "helpdesksoftwaresimple@gmail.com" F"<PO   3PEXE Idea> {TimeStamp_str}" F"{TextEmail}" 0 "" "" "" F"Reply-To: {ReplyEmail}[]X-Mailer: {NameApp}" "" EmailServer
			err
				TextLog=F"Error: {_error.description} []Error to try send email. Please, send Idea or New Command description to: {EmailSupport}"
				out TextLog
				mes TextLog NameApp
				goto EndCase
				
			TextLog="Information sent. Thank you."
			out TextLog
			mes TextLog NameApp
		else
			TextLog=F"Error to try read Email SMTP Server configuration. Please, send Idea or New Command description to: {EmailSupport}"
			out TextLog
			mes TextLog NameApp
			goto EndCase
	
	;***********************************************************************
	case 7
	
	;************* CONTACT OR SUPPORT **********************
	
	if inp(TextEmail F"Please, fill Contact Information or request me Premium Support. You can also send an email to the following address: {EmailSupport}. Thank you." F"{NameApp} - Contact or Support" "[]")
	
		if len(EmailServer)>0 ;;and len(LogFile)>0
			TextLo   4g=F"SendMail helpdesksoftwaresimple@gmail.com <POPEXE Support> {TimeStamp_str} {TextEmail} Reply-To: {ReplyEmail}[]X-Mailer: {NameApp} {EmailServer}"
			out TextLog
			SendMail "helpdesksoftwaresimple@gmail.com" F"<POPEXE Support> {TimeStamp_str}" F"{TextEmail}" 0 "" "" "" F"Reply-To: {ReplyEmail}[]X-Mailer: {NameApp}" "" EmailServer
			err
				TextLog=F"Error: {_error.description} []Error to try send email. Please, send Contact Information, or request Premium Support to: {EmailSupport}"
				out TextLog
				mes TextLog NameApp
				goto EndCase
				
			TextLog="Information sent. Thank you."
			out TextLog
			mes TextLog NameApp
		else
			TextLog=F"Error to try read Email SMTP Server configuration. Please, send Contact Information, or request Premium Support to: {EmailSupport}"
			out TextLog
			mes TextLog NameApp
			goto EndCase
	
	;*******************************************************
	
	case 8
	
	;*********** START WITH WINDOWS STARTUP ********************
	if WinStart="No"
		i    f(rset(ExecutableName WinRegisterPopExe "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" HKEY_LOCAL_MACHINE|HKEY_64BIT))
			err
				TextLog="Error to try register PopExe App on Windows Register (HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run)"
				mes TextLog NameApp
			out "Ok"
		out "ok 2"
		WinStart="Yes"
		md=md_check
	else ;;WinStart="Yes" -> Uncheck
		if(rset(ExecutableName WinRegisterPopExe "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" HKEY_LOCAL_MACHINE|HKEY_64BIT -1))
			err
				TextLog="Error to try delete PopExe App on Windows Register (HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run)"
				mes TextLog NameApp
		WinStart="No"
		md=md_no_check

	;***********************************************************
	
;EndCase

 -------------------

 BEGIN PROJECT
 main_function  PopExe
 exe_file  $my qm$\PopExe.exe
 icon  <default>
 manifest  $qm$\default.exe.manifest
 flags  22
 guid  {47431540-1D23-44B8-9E81-1CEB46943321}
 END PROJECT


