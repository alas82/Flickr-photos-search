unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, fpjson, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;
      //we add required units

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Label1: TLabel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);

  private

  public

  end;

var
  Form1: TForm1;
  url:string;
  s: ansistring;     // the link of json file
  photosjson:TJSONData;
  photoitem: TJSONArray;

implementation

{$R *.lfm}

{ TForm1 }
uses
  httpsend, ssl_openssl,openssl, windows;     //after download synase (already downloaded)



procedure TForm1.Button1Click(Sender: TObject);
var

   //photoobj:TJSONObject;
   i:Integer;
   s1:TStringList;
   x:string;
   farmId, serverId,id,secret,link: string;   //links items

  begin
     Button2.Enabled:=False;
     Button3.Enabled:=False;
     s1:=TStringList.Create;
    With TFPHttpClient.Create(Nil) do
        try
           ListBox1.Items.BeginUpdate;
      //cat&per_page=500&page=1&format=json&nojsoncallback=1
           try
              ListBox1.Items.Clear;
               s:=Get('https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=ea0054a8ed56c17667df0b5ac9743b1a&text=' + edit1.text + '&per_page=500&page=1&format=json&nojsoncallback=1');
               photosjson:=GetJSON(s);   //get json file
               photoitem:= TJSONArray(photosjson.FindPath('photos.photo'));  //photo is array
               for i:=0 to photoitem.Count-1 do
               begin
                 ListBox1.Items.Add(photoitem[i].Items[5].AsString);   //fill the list with photos titles
                   x:=IntToStr(i); //save the items numbers
                   farmId:=photoitem[i].Items[4].AsString;
                   serverId:=photoitem[i].Items[3].AsString;
                   id:=photoitem[i].Items[0].AsString;
                   secret:=photoitem[i].Items[2].AsString;
                   //x1:=(photoitem[i].Items[4].AsString);
                   //(https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_b.jpg)
                   link:='https://farm' + farmId + '.staticflickr.com/' + serverId + '/' + id + '_' + secret + '_' + 'b.jpg';
                 s1.Add(x+','+link);

               end;

           finally;
              s1.SaveToFile('welcome.csv');   // save all links to csv file
             ListBox1.Items.EndUpdate;
           end;

      finally
        s1.Free;
      end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
Image1.Picture.SaveToFile(ListBox1.GetSelectedText+'.jpg');  //save the photo
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  image1.Picture.SaveToFile('1.jpg');//save temp file to use as desktop background
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0,PChar(Application.Location+ '1.jpg'), SPIF_SENDWININICHANGE); //set a desktop background , from windows USES
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
 response: TMemoryStream;  //to load the photo
 tempBookRec:TStringList;   //   to load csv file
 parts:Array of String;    //to get the link
   begin
   if ListBox1.Items.Count>0 then
   begin
    button2.Enabled:=true;
    button3.Enabled:=true;
   tempBookRec:=TStringList.Create;
   tempBookRec.LoadFromFile(application.Location + 'welcome.csv');
   parts:= tempBookRec[ListBox1.ItemIndex].Split(','); //file link second part of string
   //Form1.Caption:=Form1.Caption + ' '+parts[1];
   //download file
   tempBookRec.Free;

   response := TMemoryStream.Create;     //load the photo
 try
    if HttpGetBinary(parts[1], response) then
    begin
      //Showmessage(pchar(response.Memory));
      response.Seek(0,soFromBeginning);
      Image1.Picture.LoadFromStream(response);  //view the photo
    end;
    finally
   response.Free;

    end;
  end;
end;

end.

