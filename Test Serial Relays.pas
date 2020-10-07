Program Test_Serial_Relays;

Uses Serial_Relays,sysutils;

Var
   I: byte;
   Serial_Relay_Port:String;

Begin
   Serial_Relay_Port:='Com7';
   Writeln ('Serial Relay Test Program');
   Writeln ('Functions:');
   Writeln ('     Serial_Device_Add(''',Serial_Relay_Port,''');');
   Serial_Device_Add(Serial_Relay_Port);
   writeln('Press enter to test Set_Serial_Relays(''',Serial_Relay_Port,''');');
   readln;
   Set_Serial_Relays(Serial_Relay_Port);
   Serial_Relay_Status(Serial_Relay_Port);
   writeln('Press enter to test Clear_Serial_Relays(''',Serial_Relay_Port,''');');
   readln;
   Clear_Serial_Relays(Serial_Relay_Port);
   Serial_Relay_Status(Serial_Relay_Port);
   writeln('Press enter to write to all Serial Relays');
   readln;
   For I:= 1 to 16 do
      Begin
         Writeln('Write_Serial_Relay(''',Serial_Relay_Port,''',',I,',True);');
         Write_Serial_Relay(Serial_Relay_Port,I,True);
         Sleep(250);
      End;
   For I:= 1 to 16 do
      Begin
         Writeln('Write_Serial_Relay(''',Serial_Relay_Port,''',',I,',False);');
         Write_Serial_Relay(Serial_Relay_Port,I,False);
         Sleep(250);
      End;
   Writeln ('     Serial_Relay_Status(''',Serial_Relay_Port,''');');
   Serial_Relay_Status(Serial_Relay_Port);
   Writeln ('     Serial_Relay_Device_Status(''',Serial_Relay_Port,'''); ',Serial_Relay_Device_Status(Serial_Relay_Port));
   Writeln ('     Serial_Relay_Device_Status_String(''',Serial_Relay_Port,'''); ',Serial_Relay_Device_Status_String(Serial_Relay_Port));
   Writeln ('     Serial_Relay_State(''',Serial_Relay_Port,''',4); ',Serial_Relay_State(Serial_Relay_Port,4));
   Writeln ('     Read_Serial_Relay(''',Serial_Relay_Port,''',4); ',Read_Serial_Relay(Serial_Relay_Port,4));
   writeln('Press enter to test Set_Serial_Relays(''',Serial_Relay_Port,''');');
   readln;
   Set_Serial_Relays(Serial_Relay_Port);
   Writeln('Serial_Relay_Status(''all'');');
   Serial_Relay_Status('all');

   writeln('Press enter to test Clear_All_Serial_Relays;');
   readln;
   Clear_All_Serial_Relays;
   writeln('Press enter to test Set_All_Serial_Relays);');
   readln;
   Set_All_Serial_Relays;
   Serial_Relay_List;

   Writeln ('Variables:   (must know device index)');
   Writeln('Serial_Relay_Element.Count                      ',Serial_Relay_Element.Count);
   Writeln('Serial_Relay_Element.Device[1].Port          ',Serial_Relay_Element.Device[1].Port);
   Writeln('Serial_Relay_Element.Device[1].Status           ',Serial_Relay_Element.Device[1].Status);
   Writeln('Serial_Relay_Element.Device[1].Relay[1].State   ',Serial_Relay_Element.Device[1].Relay[1].State);
   Readln;
End.
