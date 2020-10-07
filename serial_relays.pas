Unit Serial_Relays;

(*
The board uses a baud rate of 9600 bps (8 data bits, 1 stop bit, no parity) for the virtual serial port and
the following communication protocol:

A start byte: 0xA0
A byte to indicate the relay address: 0x01
A byte to indicate the state of the relay: 0x00 (off) or 0x01 (on)
A check code (0xA2 for on or 0xA1 for off)


*)

Interface

uses
  Serial,Crt;
Type
   Relaytype = Record
      State    : Boolean;
   end;

   Ser_RLY_Record = record
      Port             :String;
      Handle           :LongInt;
      Relay            :Array [1..16] of Relaytype;
      Status           :Word;
   End;

   Ser_Relay_Manager = Record
      Device           : Array [1..16] of Ser_RLY_Record;
      Count            : Byte;
   End;

Var
   Serial_Relay_Element: Ser_Relay_Manager;

Function Serial_Relay_Device_Status(Device:String):Word;
Function Serial_Relay_Device_Status_String(Device:String):String;
Function Serial_Relay_State(Device:String;Relay_Number:Byte):Boolean;
Function Read_Serial_Relay(Device:String;Relay_Number:Byte):Byte;
Function Clear_All_Serial_Relays:integer;
Function Set_All_Serial_Relays:integer;
Function Clear_Serial_Relays(Device:String):integer;
Function Set_Serial_Relays(Device:String):integer;
Function Write_Serial_Relay(Device:String;Relay_Number:Byte;State:Boolean):integer;
Function Serial_Relay_Status(Device:String):integer;
Function Serial_Relay_List:integer;
Function Serial_Device_Add(Port:String):Boolean;

implementation

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function BinStringCustom(BS:QWord;BL:Byte):String;
Var
   Bittest         :QWord;
   looptest        :Byte;
   Stringtemp      : String;
Begin
   //Writeln('BSC',BS);
   Bittest:=1;
   Bittest:=Bittest SHL (BL-1);
   StringTemp:='';
   For  Looptest := 1 to bl do
      Begin
         //write(binstring(bs),' ',binstring(bittest),' ',binstring(BS AND Bittest),' ');
         //write((bs),' ',(bittest),' ',(BS AND Bittest),' ');
         If BS AND Bittest = Bittest then
            Begin
               //Writeln('1');
               Stringtemp:=Stringtemp+'1';
            end
         else
            Begin
               //Writeln('0');
               Stringtemp:=Stringtemp+'0';
            End;
         Bittest:= Bittest SHR 1;
      End;
   BinStringCustom:= Stringtemp;
End;

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Serial_Relay_Initialize(Address:Byte);
Var
  Parity       : TParityType; { TParityType = (NoneParity, OddParity, EvenParity); }
  Flags        : TSerialFlags; { TSerialFlags = set of (RtsCtsFlowControl); }
Begin
    Serial_Relay_Element.Device[Address].Handle := SerOpen(Serial_Relay_Element.Device[Address].Port);
    Flags:= [ ]; // None
    SerSetParams(Serial_Relay_Element.Device[Address].Handle,9600,8,NoneParity,1,Flags);
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Serial_Relay_Finalize;
Var
   Serial_Relay_i:Byte;
Begin
   If Serial_Relay_Element.Count > 0 Then
      Begin
         For Serial_Relay_i := 1 to Serial_Relay_Element.Count do
            Begin
               SerSync(Serial_Relay_Element.Device[Serial_Relay_i].Handle); { flush out any remaining before closure }
               SerFlushOutput(Serial_Relay_Element.Device[Serial_Relay_i].Handle); { discard any remaining output }
               SerClose(Serial_Relay_Element.Device[Serial_Relay_i].Handle);
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Serial_Relay_Device_Status(Device:String):Word;
Var
   Serial_Relay_j,Device_Number:Byte;
Begin
   Serial_Relay_Device_Status:=0 ;
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
      end
   Else
      Begin
         Serial_Relay_Device_Status:=Serial_Relay_Element.Device[Device_Number].Status;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Serial_Relay_Device_Status_String(Device:String):String;
Var
   Serial_Relay_j,Device_Number:Byte;
Begin
   Serial_Relay_Device_Status_String:='';
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
      end
   Else
      Begin
         Serial_Relay_Device_Status_String := BinStringCustom(Serial_Relay_Element.Device[Device_Number].Status,16);
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Serial_Relay_State(Device:String;Relay_Number:Byte):Boolean;
Var
   Serial_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
      end
   Else
    if (Relay_Number>16) or (Relay_Number<1) then
      begin
         writeln('Error: Relay number out of range ("',Relay_Number,'")  Must be between 1 and 16');
      End
   Else
      Begin
         Serial_Relay_State:=Serial_Relay_Element.Device[Device_Number].Relay[Relay_Number].State;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Read_Serial_Relay(Device:String;Relay_Number:Byte):Byte;
Var
   Serial_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
      end
   Else
    if (Relay_Number>16) or (Relay_Number<1) then
      begin
         writeln('Error: Relay number out of range ("',Relay_Number,'")  Must be between 1 and 16');
      End
   Else
      Begin
         If Serial_Relay_Element.Device[Device_Number].Relay[Relay_Number].State Then
            Read_Serial_Relay:=1
         Else
            Read_Serial_Relay:=0;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Clear_All_Serial_Relays:integer;
Var
   Device_Number,Serial_Relay_i:Byte;
Begin
   If Serial_Relay_Element.Count >=1 then
      Begin
         For Device_Number := 1 to Serial_Relay_Element.Count do
            Begin
               For Serial_Relay_i:= 1 to 16 do
                  Write_Serial_Relay(Serial_Relay_Element.Device[Device_Number].Port,Serial_Relay_i,False);
            End;
         Clear_All_Serial_Relays:= 1;
      End
   Else
      begin
         writeln('Error: Device not found');
         Clear_All_Serial_Relays := 2;
      end
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Set_All_Serial_Relays:integer;
Var
   Device_Number,Serial_Relay_i:Byte;
Begin
   If Serial_Relay_Element.Count >=1 then
      Begin
         For Device_Number := 1 to Serial_Relay_Element.Count do
            Begin
               For Serial_Relay_i:= 1 to 16 do
                  Write_Serial_Relay(Serial_Relay_Element.Device[Device_Number].Port,Serial_Relay_i,True);
            End;
         Set_All_Serial_Relays:= 1;
      End
   Else
      begin
         writeln('Error: Device not found');
         Set_All_Serial_Relays := 2;
      end;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Clear_Serial_Relays(Device:String):integer;
Var
   Serial_Relay_i,Serial_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
         Clear_Serial_Relays := 2;
      end
   Else
      Begin
         For Serial_Relay_i:= 1 to 16 do
            Write_Serial_Relay(Serial_Relay_Element.Device[Device_Number].Port,Serial_Relay_i,False);
         Clear_Serial_Relays:= 1;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Set_Serial_Relays(Device:String):integer;
Var
   Serial_Relay_i,Serial_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
         Set_Serial_Relays := 2;
      end
   Else
      Begin
         For Serial_Relay_i:= 1 to 16 do
            Write_Serial_Relay(Serial_Relay_Element.Device[Device_Number].Port,Serial_Relay_i,True);
         Set_Serial_Relays := 1;
      End;
End;

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Write_Serial_Relay(Device:String;Relay_Number:Byte;State:Boolean):integer;
Var
   Outputbytes : Array [0..3] of byte;
   Serial_Relay_j,Device_Number,Ser_Result:Byte;
Begin
   Device_Number:=0;
   for Serial_Relay_j := 1 to Serial_Relay_Element.Count do
      begin
         if Serial_Relay_Element.Device[Serial_Relay_j].Port=Device then
            begin
              Device_Number:=Serial_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found (',Device,')');
         Write_Serial_Relay := -1;
      end
   Else
      Begin
         OutputBytes[0]:=$A0;
         OutputBytes[1]:=Relay_Number;
         If State Then
            Begin
               OutputBytes[2]:=$01;
               OutputBytes[3]:=$A2;
               Serial_Relay_Element.Device[Device_Number].Status:=Serial_Relay_Element.Device[Device_Number].Status OR ($1 shl (Relay_Number-1));
            End
         Else
            Begin
               OutputBytes[2]:=$00;
               OutputBytes[3]:=$A1;
               Serial_Relay_Element.Device[Device_Number].Status:= Serial_Relay_Element.Device[Device_Number].Status and (($1 shl (Relay_Number-1)) xor High(QWord));
            End;
         Ser_Result := SerWrite(Serial_Relay_Element.Device[Device_Number].Handle,OutputBytes[0],length(OutputBytes));
         //Writeln(Serial_Relay_Element.Device[Device_Number].Handle,'  $',HexStr(OutputBytes[0],2),' $',HexStr(OutputBytes[1],2),' $',HexStr(OutputBytes[2],2),' $',HexStr(OutputBytes[3],2),'    :',Ser_Result);
         Serial_Relay_Element.Device[Device_Number].Relay[Relay_Number].State:=State;
         Write_Serial_Relay := Ser_Result;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Writeln_Relay_Device(Device_Number:Byte);
Begin
   Writeln('Serial Relay #',Device_Number,':   ',Serial_Relay_Element.Device[Device_Number].Port,'   16 Relays   ',
           BinStringCustom(Serial_Relay_Element.Device[Device_Number].Status,16));
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Serial_Relay_Status(Device:String):integer;
Var
   Serial_Relay_i,Serial_Relay_j,Device_Number:Byte;
Begin
   If Upcase(Device) = 'ALL' Then
      Begin
         For Serial_Relay_i := 1 to Serial_Relay_Element.Count Do
            Begin
               Writeln_Relay_Device(Serial_Relay_i);
               //For Serial_Relay_j := 1 to Serial_Relay_Element.Device[Serial_Relay_i].Count Do
               //   Writeln ('    ',Serial_Relay_j,' ',Serial_Relay_Element.Device[Serial_Relay_i].Relay[Serial_Relay_j].State);
            End;
         Write (Serial_Relay_Element.Count,' Device');
         If Serial_Relay_Element.Count <> 1 then
            Writeln ('s')
         Else
            Writeln;
      End
   Else
      Begin
         Device_Number:=0;
         for Serial_Relay_i := 1 to Serial_Relay_Element.Count do
            begin
               if Serial_Relay_Element.Device[Serial_Relay_i].Port=Device then
                  begin
                  Device_Number:=Serial_Relay_i;
                  break;
                  end;
            end;
         if Device_Number = 0 Then
            begin
               writeln('Error: Device not found (',Device,')');
               Serial_Relay_Status := 2;
            end
         Else
            Begin
               Writeln_Relay_Device(Device_Number);
               //For Serial_Relay_j := 1 to Serial_Relay_Element.Device[Device_Number].Count Do
               //   Writeln ('    ',Serial_Relay_j,' ',Serial_Relay_Element.Device[Device_Number].Relay[Serial_Relay_j].State);
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Serial_Relay_List:integer;
Begin
   Serial_Relay_Status('All');
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Serial_Device_Add(Port:String):Boolean;
Var
   Device_Number,Serial_Relay_i,Init_Result : Byte;
   Write_Status:Integer;
Begin
   Device_Number:=0;
   If Serial_Relay_Element.Count >= 1 Then
      Begin
         for Serial_Relay_i := 1 to Serial_Relay_Element.Count do
            begin
               if Serial_Relay_Element.Device[Serial_Relay_i].Port=Port then
                  begin
                  Device_Number:=Serial_Relay_i;
                  break;
                  end;
            end;
      End;
   if Device_Number = 0 Then
      Begin
         Inc (Serial_Relay_Element.Count);
         Serial_Relay_Element.Device[Serial_Relay_Element.Count].Port := Port;
         Serial_Relay_Initialize(Serial_Relay_Element.Count);
         Write_Status:=0;
         For Serial_Relay_i:=1 to 16 do
            Begin
               Write_Status:=Write_Status+Write_Serial_Relay(Port,Serial_Relay_i,False);
            End;
         //Writeln(Write_Status);
         If Write_Status =64 Then
            Begin
               Write('Added: ');
               Writeln_Relay_Device(Serial_Relay_Element.Count);
               Serial_Device_Add:=True;
            End
         Else
            Begin
               Serial_Relay_Element.Device[Serial_Relay_Element.Count].Port := '';
               Dec (Serial_Relay_Element.Count);
               Writeln('Serial Device ',Port,' Not Added');
               Serial_Device_Add:=False;
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Initialization
   Serial_Relay_Element.Count:=0
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Finalization
   Serial_Relay_Finalize;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
End.
