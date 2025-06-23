
import processing.sound.*;
import java.security.*;
import g4p_controls.*;
import controlP5.*;

ControlP5 cp5;
GTextField txt1, txt2;
CheckBox cboxFull;
GTabManager tt;
Button b1, b2, b3;

String pathFile;
Boolean imgOk;
PImage img;
int next, sec;
Pulse pulse, pulse2, pulse3;
JSONObject val, valFull, listado;
JSONArray limpieza, limpiezaFull;
int repi, repii, time;
boolean playNext, limpiando, enEjecucionSonido, eFull;
int level;
String imgHash;
Persona p;

void setup() {
  size(500, 200);
  background(0);
  G4P.setGlobalColorScheme(GCScheme.ORANGE_SCHEME);
  cp5 = new ControlP5(this);
  
  valFull = loadJSONObject("limpiezaFull.json");
  val = loadJSONObject("limpieza.json");
  listado = loadJSONObject("NombresPrueba.json");
 // val = loadJSONObject("limpiezaPrueba.json");
  
  limpieza = val.getJSONArray("limpieza");
  limpiezaFull = valFull.getJSONArray("limpieza");


  pulse = new Pulse(this);
  pulse2 = new Pulse(this);
  pulse3 = new Pulse(this);
  pulse.amp(0.3);
  pulse2.amp(0.3);
  pulse3.amp(0.3);

  txt1 = new GTextField(this, 20, 60, 200, 20);
  txt1.tag = "txt1";
  txt1.setPromptText("Nombre / Dirección");
  txt1.setFocus(true);
  tt = new GTabManager();
  tt.addControls(txt1);

  b1 = cp5.addButton("Armonizar")
    .setValue(0)
    .setPosition(330, 60)
    .setSize(150, 40)
    ;
  b2 = cp5.addButton("Imagen")
    .setValue(0)
    .setPosition(20, 85)
    .setSize(200, 16)
    ;
    
  cboxFull = cp5.addCheckBox("cboxFull")
                .setPosition(250, 60)
                .setSize(40, 40)
                .addItem("Full", 1);

  IniciarValoresPorLimpieza();
}

void IniciarValoresPorLimpieza() {
  playNext = false;
  limpiando = false;
  repi = 0;
  repii = 0;
  level = 0;
  LimpiezaActualNombre = "";
  pathFile = ""; 
  imgOk = false;
  if (p!= null) p.nombre = "";
  LimpiezaActualNombre = "";
  txt1.setText( "");
}

void draw() {
  if (playNext) {
    p = TraerProximaPersona();
  }
  
  String nombreMostrar = "";
  if (p != null && p.nombre != ""){
    LimpiezaPersona(p.nombre, p.previousIMGByte);
    nombreMostrar = p.nombre;
  }
  
  TextoEnPantalla(nombreMostrar);
}

Persona TraerProximaPersona(){
      String tt = txt1.getText();
      
     // si no hay mas personas devuelvo Null
      Persona p = new Persona(tt, pathFile);
      playNext = false;
      
      return p;
}

void TextoEnPantalla(String pNombre) {
  background(0);
  fill(255);
  textAlign(CENTER);
  
  if (imgOk)
  {
    image(img, 20, 105, 50, 50);
  }
  
  textSize(15);
    text(pNombre, width/2, 125);
  
  textSize(20);
  text(LimpiezaActualNombre, width/2, 150);
}

void LimpiezaPersona(String pNombre, byte[] pImgByte){
  imgHash = "";
  
  String txtFechaNacimiento = "1980/10/29"; //NO
  switch(level) {
  case 0:
  println("INIT: ", hour(),minute());
    if (ejecutarSonido(Texto2Hz(pNombre),0,0,3.5*1000)){
      level = 2;
    }
    break;
  case 1: // lo salteo por ahora
    if (ejecutarSonido(Texto2Hz(txtFechaNacimiento),0,0,3.5*1000)){
      level = 2;
    }
    break;
  case 2:
    if (imgHash != ""){
      if (ejecutarSonido(Byte2Hz(pImgByte),0,0,3.5*1000)){
        level = 3;
      }
    } else {
      println("Sin Imagen");
      level = 3;
    }
    break;
  case 3:
    if (playTonesDraw()){
      level = 4;
    }
    break;
  case 4:
  println("FIN: ",hour(),minute());
    if (ejecutarSonido(Texto2Hz(pNombre),0,0,3.5*1000)){
      // pasa a otra persona
      IniciarValoresPorLimpieza();
      
      //playNext = true;
    }
    break;
  }
}

float Texto2Hz(String pTexto) {
  // frencuencias de 1 a 10000hz
  int cant = pTexto.length();
  int p1 = 0;
  for (int i=0; i<cant; i++) {
    p1 += float(pTexto.charAt(i));
  }

  return map(p1, 0, 255*cant, 1, 10000);
}

float Byte2Hz(byte[] pData) {
  // frencuencias de 1 a 10000hz
  int cant = pData.length;
  int p1 = 0;
  for (int i=0; i<cant; i++) {
    p1 += Byte.toUnsignedInt(pData[i]);
  }
 
  return map(p1, 0, 255*cant, 1, 10000);
}


String LimpiezaActualNombre = "";
Boolean playTonesDraw() {
  JSONObject una, listado;
  float f1, f2 = 0, f3 = 0, tiempo;
  float size;
  if (eFull) size = limpiezaFull.size(); else size = limpieza.size();
  if (repi < size) {
    if (eFull)
      una = limpiezaFull.getJSONObject(repi);
    else 
      una = limpieza.getJSONObject(repi);
    LimpiezaActualNombre = una.getString("name");

    JSONArray frec = una.getJSONArray("frec");

    if (repii < frec.size()) {

      listado = frec.getJSONObject(repii);
      // listado de frencuencias
      f1 = listado.getFloat("hz");
      if (listado.isNull("hz2") == false) {
        f2 = listado.getFloat("hz2");
        if (listado.isNull("hz3") == false) {
            f3 = listado.getFloat("hz3");
        } else {
          f3  = 0;
        }
      } else {
        f2 = 0;
        f3  = 0;
      }
      tiempo = listado.getFloat("time");
      if (ejecutarSonido(f1, f2, f3, tiempo*1000)){
        repii++;
      }
    } else {
      repi++;
      repii = 0;
    }
  } else {
    return true;
  }
  return false;
}

Boolean ejecutarSonido(float pHz1, float pHz2, float pHz3, float pTiempo) {
  //println(pHz1, pHz2, pTiempo);

  pulse.freq(pHz1);

  if (!limpiando) {
    limpiando = true;
    
    if (pHz2 != 0) {
      pulse2.freq(pHz2);  
      pulse2.play();
    }
    
    if (pHz3 != 0) {
      pulse3.freq(pHz3);  
      pulse3.play();
    }

    pulse.play();
    time = millis();
  }

  if (millis() > time + pTiempo) {
    if (pHz2 != 0) {
      pulse2.stop();
    }
    if (pHz3 != 0) {
      pulse3.stop();
    }
    pulse.stop();
    limpiando = false;

    return true; //termino de limpiar -> repii++;
  }
  
  return false;
}

void keyPressed() {
}

String getHash(String originalpw) {
  try {
    MessageDigest md = MessageDigest.getInstance("MD5");
    md.update(originalpw.getBytes());
    byte[] digest = md.digest();
    StringBuilder sb = new StringBuilder(32);
    for (byte b : digest)   sb.append(String.format("%02x", b & 0xff));
    return sb.toString();
  } 
  catch (java.security.NoSuchAlgorithmException e) {
    return null;
  }
}

String file2String(String pUrl){
  byte b[] = loadBytes(pUrl);
  return new String(b);
}

String File2Hash(String pUrl){
  return getHash(file2String(pUrl));
}

void controlEvent(CallbackEvent theEvent) {
  if (theEvent.getController().equals(b1)) {
    if (theEvent.getAction()== 1){ // pressed
      if (cboxFull.getArrayValue()[0]==1.0) eFull=true; else eFull=false;
      if (imgOk){
        playNext = true;
      } else {
        println("falta img");
      }
    }
  } else if (theEvent.getController().equals(b2)) {
    if (theEvent.getAction()== 1){ // pressed
      selectInput("Select a file to process:", "fileSelected");
    }
  }
}

void fileSelected(File selection) {
  if (selection != null) {
    pathFile = selection.getAbsolutePath();
    txt1.setText(selection.getName().substring(0, selection.getName().lastIndexOf(".")));
    img = loadImage(pathFile);
    imgOk = true;
  }
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) { 
/* code */ 
}
