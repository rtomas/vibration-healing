class Persona{
  String nombre;
  byte[] previousIMGByte;
  String imgURL;
  Boolean imageLoad;
  
  Persona (String n, String i) {  
    nombre = n; 
    imgURL = i; 
    // load Byte
    imageLoad = loadByteImg(imgURL);
  } 
  
  Boolean loadByteImg(String _Url){
    previousIMGByte = loadBytes(_Url);
    if (previousIMGByte == null) return false; 
    else if (previousIMGByte.length == 0) return false;
    else return true;
  }
}
