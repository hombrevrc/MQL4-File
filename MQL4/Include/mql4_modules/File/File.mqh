//+------------------------------------------------------------------+
//|                                                         File.mqh |
//|                                 Copyright 2017, Keisuke Iwabuchi |
//|                                         http://order-button.com/ |
//+------------------------------------------------------------------+
#property strict


/** muduleの2重読み込み防止用 */
#ifndef _LOAD_MODULE_FILE
#define _LOAD_MODULE_FILE


/**
 * FileOpenする際の方式
 */
enum FILE_OPEN
{
   READ  = 0,
   WRITE = 1
};


/**
 * ファイル操作をおこなうクラス
 * パラメータpathは全て、
 * データフォルダ\MQL\Files\
 * 以降のファイル名へのパス。
 */
class File
{
   //--- methods
   public:
      static bool   Copy(const string path, const string destination);
      static bool   Delete(const string path);
      static bool   Move(const string path, const string destination);
      static string Read(const string path);
      static bool   Write(const string path, const string text);
      
   private:
      static int  openHandle(const string path, 
                             const FILE_OPEN type = WRITE);
      static void closeHandle(const int handle);
};


/**
 * 指定したファイルをコピーする。
 * コピー先のファイルが既に存在する場合は上書きする。
 *
 * @param const string path コピー元のパス
 * @param const string destination コピー先のパス
 *
 * @return bool true:成功, false:失敗
 */
static bool File::Copy(const string path, const string destination)
{
   bool result = false;
   int  handle = File::openHandle(path, READ);
   
   if(handle != INVALID_HANDLE) {
      /** the copy file already exists. */
      File::closeHandle(handle);
      result = FileCopy(path, 0, destination, FILE_REWRITE);
   }
   
   return(result);
}


/**
 * 指定したファイルを削除する。
 *
 * @param const string path 削除するファイルのパス。
 *
 * @return bool true:削除成功, false:削除失敗
 */
static bool File::Delete(const string path)
{
   return(FileDelete(path));
}


/**
 * 指定したファイルを開き、本文を取得する。
 * ファイルを開けなかった場合は空文字が返る。
 *
 * @param const string path 開くファイルのパス。
 *
 * @return string 開いたファイルの文字列。改行は\nで区切る。
 */
static string File::Read(const string path)
{
   int    str_size;
   string result = "";
   int    handle = File::openHandle(path, READ);
   int    count  = 0;

   if(handle == INVALID_HANDLE) return("");
      
   while(!FileIsEnding(handle)) {
      if(count > 0) result   += "\n";
      
      str_size  = FileReadInteger(handle, INT_VALUE);
      result   += FileReadString(handle, str_size);
      count++;
   }
   
   File::closeHandle(handle);
   
   return(result);
}


/**
 * 指定したファイルを移動する。
 * 移動先のファイルが既に存在する場合は上書きする。
 *
 * @param const string path 移動元のパス
 * @param const string destination 移動先のパス
 *
 * @return bool true:成功, false:失敗
 */
static bool File::Move(const string path, const string destination)
{
   bool result = false;
   int  handle = File::openHandle(path, READ);
   
   if(handle != INVALID_HANDLE) {
      /** the copy file already exists. */
      File::closeHandle(handle);
      result = FileMove(path, 0, destination, FILE_REWRITE);
   }
   
   return(result);
}


/**
 * 指定したファイルを開き、本文を取得する。
 * ファイルを開けなかった場合は空文字が返る。
 *
 * @param const string path 開くファイルのパス。
 * @param const string text 書き込む文字列。
 *
 * @return string 開いたファイルの文字列。改行は\nで区切る。
 */
static bool File::Write(const string path, const string text)
{
   int  handle = File::openHandle(path);
   uint write  = 0;
   
   if(handle == INVALID_HANDLE) return(false);
   
   write = FileWriteString(handle, text);
   
   File::closeHandle(handle);
   
   return(write > 0);
}


/**
 * 指定されたファイルを開き、ファイルハンドルを返す。
 * 失敗した場合はINVALID=HANDLE定数（値は-1）を返す。
 *
 * @param const string path ファイル名
 * @param const FILE_OPEN type ファイルの開き方。
 *  WRITE: FILE_WRITE|FILE_CSV
 *  READ:  FILE_READ|FILE_CSV
 *
 * @return int ファイルハンドル
 */
static int File::openHandle(const string path, 
                            const FILE_OPEN type = WRITE)
{
   int handle = INVALID_HANDLE;
   
   switch(type) {
      case READ:
         handle = FileOpen(path, FILE_READ|FILE_CSV);
         break;
      case WRITE:
         handle = FileOpen(path, FILE_WRITE|FILE_CSV);
         break;
   }
   
   return(handle);
}


/**
 * 指定されたファイルを閉じる。
 *
 * @param const int handle ファイルハンドル
 */
static void File::closeHandle(const int handle)
{
   if(handle != INVALID_HANDLE) FileClose(handle);
}

#endif
