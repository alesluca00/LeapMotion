import java.lang.reflect.Field;
import java.awt.AWTException;
import java.awt.Robot; 
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.Dimension;
import java.io.*; 
import de.voidplus.leapmotion.*;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.PointerInfo;
import controlP5.*;


//global variables

LeapMotion leap;
Robot robot;
ControlP5 cp5;

//coordinate componenti grafici
int x=20, y=100; //coordinate di base

int a = 0; //distanza coordinata x tra textfield diversi
int b = 90; //distanza coordinata y tra textfield diversi
int c = 30; //distanza coordinata y tra textfield e label
int d = 270; //distanza coordinata x tra textfield e clear button
int e = 500; //distanza coordinata x degli slider


//elenco gestures
String[] gestures = {"SWIPE RIGHT", "SWIPE LEFT", "SWIPE UP", "SWIPE DOWN", "CIRCLE CLOCKWISE", "CIRCLE ANTICLOCKWISE", "KEY TAP", "SCREEN TAP", "FIST POSE", "VICTORY POSE"};
String[] settings = {"SENSITIVITY X", "SENSITIVITY Y", "HAND", "SWIPE DELAY", "SCREEN DELAY", "CIRCLE RADIUS MAX", "CIRCLE RADIUS MIN", "DISPLAY WIDTH", "DISPLAY HEIGHT", "FILE NAME"};

//UI components
Textfield textField;
Slider slider;
RadioButton r1, r2;
Button b1, b2, b3;
Icon icon1, icon2, icon3;

//gesture/pose keycode array

//gestures
int[] swipeRightGestureKeyCode = new int[3];
int[] swipeLeftGestureKeyCode = new int[3];
int[] swipeUpGestureKeyCode = new int[3];
int[] swipeDownGestureKeyCode = new int[3];
int[] circleClockwiseGestureKeyCode = new int[3];
int[] circleAnticlockwiseGestureKeyCode = new int[3];
int[] screenTapGestureKeyCode = new int[3];
int[] keyTapGestureKeyCode = new int[3];

//poses
int[] fistPoseKeyCode = new int[3];
int[] victoryPoseKeyCode = new int[3];


//sensitivity
int sensitivity_x;
int sensitivity_y;


//count
int count=0;

//array mouse buttons
int[] mouseButtons = {LEFT, CENTER, RIGHT};

//values of radio buttons
int mousePointerValue;
int hand_value;

//text of textfields
String text;

//time variable
int previousTime;


String saveButtonName = "SAVE";
String loadButtonName = "LOAD";
String browseButtonName = "BROWSE";

PImage img1, img2, img3, img4;

String previousGesture=null;

String setupPath = "setup/";
String defaultSetupFile = "default.json";
String setupExtensionFile = ".json";

//advanced settings
int swipe_delay, screen_delay, circle_radius_max, circle_radius_min, display_width, display_height;

int temp = 0;
boolean firstTime = true;

boolean altKeyPressed=false;
boolean shiftKeyPressed=false;
boolean ctrlKeyPressed=false;

boolean altFirst = false;
boolean shiftFirst = false;
boolean ctrlFirst = false;


void setup() {

  size(970, 980);
  previousTime = millis();
  leap = new LeapMotion(this);//.allowGestures();  // All gestures
  img1 = loadImage("img/save.png");
  img2 = loadImage("img/load.png");
  img3 = loadImage("img/browse.png");
  img4 = loadImage("img/clear.png");


  try
  {
    robot = new Robot();
  }
  catch(AWTException e)
  {
    e.printStackTrace();
  }


  PFont font = createFont("arial", 20);
  PFont defaultPFont = createFont("arial", 15);
  ControlFont defaultControlFont = new ControlFont(defaultPFont);


  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  cp5.setFont(defaultControlFont);

  cp5.addLabel("KEY MAPPING", x, 20)
    .setFont(font)
    .setColor(color(255, 0, 0))
    ;

  for (int i = 0; i< gestures.length; i++) {

    //labels
    cp5.addLabel(gestures[i], x, y+b*i-c)
      .setFont(font)
      .setColor(color(255, 0, 0))
      ;
    //textFields
    cp5.addTextfield(gestures[i].toLowerCase())   
      .setPosition(x, y+b*i)
      .setSize(250, 41)
      .setFont(font)
      .setLabel("")
      .setId(i)
      .setAutoClear(false)
      ;



    cp5.addIcon("clear"+i, 0)
      .setPosition(x+d, y+b*i)
      .setColorBackground(color(255))
      .setSize(41, 41)
      .setFont(createFont("Verdana", 1))
      .showBackground()
      .setRoundedCorners(10) 
      ;
  }
  for (int i = 0; i< settings.length; i++) {
    if (i==0 || i==1)
    {

      //labels
      cp5.addLabel(i==0 ? settings[i] : settings[i], x+e, y+b*i-c)
        .setFont(font)
        .setColor(color(255, 0, 0))
        ;
      //sensitivity sliders
      cp5.addSlider(settings[i].toLowerCase())
        .setPosition(x+e, y+b*i)
        .setSize(250, 41)
        .setRange(1, 10)
        .setValue(1)
        .setLabel("")
        .setDecimalPrecision(0)
        ;
    } else if (i==2)
    {
      cp5.addLabel(settings[i], x+e, y+b*i-c)
        .setFont(font)
        .setColor(color(255, 0, 0))
        ;

      //radio button hand choice

      r1 = cp5.addRadioButton("r1")
        .setPosition(x+e, y+b*i)
        .setSize(41, 41)
        .setColorForeground(color(120))
        .setColorActive(color(0, 170, 255))
        .setColorLabel(color(255, 0, 0))
        .setItemsPerRow(2)
        .setSpacingRow(51)
        .setSpacingColumn(100)
        .addItem("right", 0)
        .addItem("left", 1)
        ;
    } else
    {
      //labels
      cp5.addLabel(settings[i], x+e, y+b*i-c)
        .setFont(font)
        .setColor(color(255, 0, 0))
        ;
      //textFields
      cp5.addTextfield(settings[i].toLowerCase())   
        .setPosition(x+e, y+b*i)
        .setSize(250, 41)
        .setFont(font)
        .setLabel("")
        .setId(i)
        .setAutoClear(false)
        ;

      if (settings[i].equals("FILE NAME"))
      {
        icon1 = cp5.addIcon("icon1", 0)
          .setPosition(x+d+e, y+b*i)
          .setColorBackground(color(255))
          .setSize(41, 41)
          .setFont(createFont("Verdana", 1))
          .showBackground()
          .setRoundedCorners(10) 
          ; 

        icon1.addCallback(new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {
            if (theEvent.getAction() == cp5.ACTION_PRESSED)
            {
              saveJson();
            }
          }
        }
        );

        icon2= cp5.addIcon("icon2", 10)
          .setPosition(x+d+e+60, y+b*i)
          .setColorBackground(color(255))
          .setSize(41, 41)
          .setFont(createFont("Verdana", 1))
          .showBackground()
          .setRoundedCorners(10) 
          ;


        icon2.addCallback(new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {
            if (theEvent.getAction() == cp5.ACTION_PRESSED)
            {
              loadJson(cp5.get(Textfield.class, "file name").getText().trim());
            }
          }
        }
        );


        icon3= cp5.addIcon("icon3", 10)
          .setPosition(x+d+e+120, y+b*i)
          .setColorBackground(color(255))
          .setSize(41, 41)
          .setFont(createFont("Verdana", 1))
          .showBackground()
          .setRoundedCorners(10) 
          ;

        icon3.addCallback(new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {
            if (theEvent.getAction() == cp5.ACTION_RELEASED)
            {
              selectInput("Select a folder to process:", "folderSelected");
            }
          }
        }
        );
      }
    }
  }


  File f = new File(defaultSetupFile);


  String[] fileName = splitTokens(f.getName(), ".");

  String path = setupPath + f.getName();

  if (loadStrings(path) != null)
  {
    loadJson(fileName[0]);
    cp5.get(Textfield.class, "file name").setText(" " + fileName[0]);
  }
}

void draw() {

  //impostato il colore del background
  background(0);
  cp5.draw();
  //impostate le immagini di salvataggio, caricamento, sfoglia cartelle
  image(img1, x+d+e+2, y+b*9+4, 37, 35);
  image(img2, x+d+e+65, y+b*9+4, 30, 30);
  image(img3, x+d+e+122, y+b*9+4, 37, 37);



  //impostate le immagini del cestino
  for (int i = 0; i< gestures.length; i++) {
    image(img4, x+d+5, y+b*i+6, 30, 30);
  }

  //per ogni mano che leap motion controller trova
  for (Hand hand : leap.getHands ()) {

    //restituisce l'indice
    /*Finger  fingerIndex        = hand.getIndexFinger();
     
     
     //controlla se il valore del radio button per scegliere quale mano utilizzare combacia con la mano che il leap motion 
     
     if (hand_value == 0 && hand.isRight() || hand_value == 1 && hand.isLeft())
     {
     //using mouse cursor with hand
     if (mousePointerValue==0)
     {     
     //restituisce la posizione stabilizzata della mano
     PVector handStabilized     = hand.getStabilizedPosition();
     //muove il mouse nella posizione stabilizzata indicata dalla mano con una velocita influenzata dalla sensibilità x e y
     robot.mouseMove(MouseInfo.getPointerInfo().getLocation().x +(int)handStabilized.x*(int)sensitivity_x, MouseInfo.getPointerInfo().getLocation().y + (int)handStabilized.y*(int)sensitivity_y);
     } 
     //using mouse cursor with index finger
     else if (mousePointerValue==1)
     {
     //restituisce la posizione stabilizzata della mano
     PVector pos = fingerIndex.getStabilizedPosition();
     //muove il mouse nella posizione stabilizzata indicata dall'indice con una velocita influenzata dalla sensibilità x e y
     robot.mouseMove((int)pos.x*(int)sensitivity_x, (int)pos.y*(int)sensitivity_y);
     }
     
     //funzione che controlla se viene fatto il pugno
     fistPose(hand);
     //funzione che controlla se viene fatto il segno della vittoria
     victoryPose(hand);
     
     }
     */
  }
}

//funzione per la selezione di una cartella
void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {

    //restituisce il nome del file senza estensione
    String[] fileName = splitTokens(selection.getName(), "."); //setup.json

    //setta il nome del file senza estensione nel textfield corrispondente
    cp5.get(Textfield.class, "file name").setText(" " + fileName[0]);

    //println(fileName[0]);

    //println("User selected " + selection.getAbsolutePath());
  }
}


// ======================================================
// Callbacks

//void leapOnInit() {
//  println("Leap Motion Init");
//}
//void leapOnConnect() {
//  println("Leap Motion Connect");
//}
//void leapOnFrame() {
//  //println("Leap Motion Frame");
//}
//void leapOnDisconnect() {
//  println("Leap Motion Disconnect");
//}
//void leapOnExit() {
//  println("Leap Motion Exit");
//}

//controlla che il keyCode non sia uno di quelli indicati
boolean checkVK()
{
  if (!(
    keyCode >= KeyEvent.VK_0 && keyCode <= KeyEvent.VK_9 ||
    keyCode >= KeyEvent.VK_A && keyCode <= KeyEvent.VK_Z ||
    keyCode >= KeyEvent.VK_NUMPAD0 && keyCode <= KeyEvent.VK_NUMPAD9 ||
    keyCode == KeyEvent.VK_BACK_SLASH ||
    keyCode == 222 ||
    keyCode == 46 ||
    keyCode == 45 ||
    keyCode == 521 ||
    keyCode == 44 
    ))
  {
    return true;
  } else
    return false;
}
String checkText(String text)
{
  //if per evitare che nel textfield si visualizzi backspac
  if (text == "Backspace")
    return "Backspace "; 
  //if per evitare che scrivi keycode sconosciuto
  else if (text.startsWith("Sconosciuto"))
    return "";
  //if per evitare che nel textfield si visualizzi elimin
  else if (text == "Elimina")
    return "Elimina ";

  return text;
}
String setTextMouseButton(String text)
{
  switch(text)
  {
    //switch per visualizzare nel textfield m1, m2, m3 per evitare che vada in conflitto con le freccette destra e sinistra
  case "Sinistra":
    return "M1";
  case "Annulla":
    return "M2";
  case "Destra":
    return "M3";
  default:
    return "Error";
  }
}


//funzione per convertire mouseButton nell'inputEvent corrispondente
int getKeyEventByMouseButton(int mouseButton1)
{
  if (mouseButton1 == LEFT)
  {
    return 1;
  } 
  else if (mouseButton1 == RIGHT)
  {
    return 2;
  }
  else
  {
    return 4;
  }
}
//funzione che converte uha stringa nel keyCode corrispondente
int getKeyCodeByText(String text) {
  int keyEvent=0;
  //converte la stringa in upperCase
  String upperCase = text.toUpperCase();
  for (int i = 0; i < upperCase.length(); i++) {
    try
    {
      //aggiunge lettera per lettera al codice che inizia per VK_
      String letter = Character.toString(upperCase.charAt(i));
      String code = "VK_" + letter;

      //mappa con il keyCode generato nel corrispondente keyEvent
      Field f = KeyEvent.class.getField(code);
      keyEvent = f.getInt(null);
    }
    catch(Exception ex)
    {
      println(ex);
    }
  }
  return keyEvent;
}
//funzione per controllare che mouseButton corrisponda a uno dei tasti del mouse
void mouseReleased()
{
  for (int i=0; i<gestures.length; i++) {
    if (cp5.get(Textfield.class, gestures[i].toLowerCase()).isFocus())
    {
      //controllo se uno specifico textfield è stato cliccato due volte
      switch(count)
      {
      case 0:
        //variabile temporanea che salva il nome del gesto del textfield corrispondente che è stato cliccato
        previousGesture = gestures[i].toLowerCase();
        count++;
        break;

      case 1:
        //controllo per vedere se il textfield del gesto corrispondente è stato cliccato due volte consecutive
        if (previousGesture.equals(gestures[i].toLowerCase()))
          count++;
        else
          //se non è stato cliccato due volte consecutivamente resetta count
          count=0;

        break;
      }

      //se è stato cliccato due volte consecutivamente viene visualizzato il tasto del mouse corrispondente
      if (count == 2)
      {
        count=0;
        for (int j=0; j < mouseButtons.length; j++)
        {
          //se il bottone del mouse corrisponde a uno dei bottoni
          if (mouseButton == mouseButtons[j])
          {
            //convertito il mouseButton nella stringa del bottone del mouse corrispondente
            text = KeyEvent.getKeyText(mouseButton);

            //viene settato nel textfield il nome del tasto premuto
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + setTextMouseButton(text));
            //viene mappato il tasto premuto
            mapKey(gestures[i].toLowerCase(), getKeyEventByMouseButton(mouseButton), 0, 0);
          }
        }
      }
    }
  }
}
void keyPressed()
{
  for (int i=0; i<gestures.length; i++) {
    text = KeyEvent.getKeyText(keyCode);

    text = checkText(text);
    if (cp5.get(Textfield.class, gestures[i].toLowerCase()).isFocus())
    {
      if (keyCode == ALT)
      {
        altKeyPressed= true;

        if (ctrlFirst==false && shiftFirst==false)
        {
          altFirst=true;
          //println("alt first");
        }
      } else if (keyCode == SHIFT)
      {
        shiftKeyPressed= true;

        if (ctrlFirst == false && altFirst== false)
        {
          shiftFirst=true;
          //println("shift first");
        }
      } else if (keyCode == CONTROL)
      {
        ctrlKeyPressed= true;
        if (altFirst == false && shiftFirst == false)
        {
          ctrlFirst=true;
          //println("ctrl first");
        }
      }
      else if (checkVK())
      {
        cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + text);
        mapKey(gestures[i].toLowerCase(), keyCode, 0, 0);
      } else
      {
        //altrimenti non visualizza il nome corrisponde e visualizza il carattere premuto con la tastiera
        cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" ");
        mapKey(gestures[i].toLowerCase(), keyCode, 0, 0);
      }
    }
  }
}


void keyReleased()
{

  for (int i=0; i<gestures.length; i++) {
    if (cp5.get(Textfield.class, gestures[i].toLowerCase()).isFocus())
    {

      if (altKeyPressed && ctrlKeyPressed)
      {
        if (keyCode != ALT && keyCode != CONTROL && keyCode != SHIFT)
        {
          if (altFirst)
          {
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(ALT) + "+" + KeyEvent.getKeyText(CONTROL) + "+" + KeyEvent.getKeyText(keyCode));
            altKeyPressed = false;
            ctrlKeyPressed = false;
            altFirst=false;
            mapKey(gestures[i].toLowerCase(), ALT, CONTROL, keyCode);
          } else if (ctrlFirst)
          {
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(CONTROL)  + "+" + KeyEvent.getKeyText(ALT) + "+" + KeyEvent.getKeyText(keyCode));
            altKeyPressed = false;
            ctrlKeyPressed = false;
            ctrlFirst=false;
            mapKey(gestures[i].toLowerCase(), CONTROL, ALT, keyCode);
          }
        }
      } else if (altKeyPressed && shiftKeyPressed)
      {
        if (keyCode != ALT && keyCode != CONTROL && keyCode != SHIFT)
        {
          if (altFirst)
          {
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(ALT) + "+" + KeyEvent.getKeyText(SHIFT) + "+" + KeyEvent.getKeyText(keyCode));
            altKeyPressed = false;
            shiftKeyPressed = false;
            altFirst=false;
            mapKey(gestures[i].toLowerCase(), ALT, SHIFT, keyCode);
          } else if (shiftFirst)
          {
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(SHIFT) + "+" + KeyEvent.getKeyText(ALT) + "+" + KeyEvent.getKeyText(keyCode));
            shiftKeyPressed = false;
            altKeyPressed = false;
            shiftFirst=false;
            mapKey(gestures[i].toLowerCase(), SHIFT, ALT, keyCode);
          }
        }
      } else if (ctrlKeyPressed && shiftKeyPressed)
      {
        if (keyCode != ALT && keyCode != CONTROL && keyCode != SHIFT)
        {
          if (ctrlFirst)
          {
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(CONTROL) + "+" + KeyEvent.getKeyText(SHIFT) + "+" + KeyEvent.getKeyText(keyCode));
            ctrlKeyPressed = false;
            shiftKeyPressed = false;
            ctrlFirst=false;
            mapKey(gestures[i].toLowerCase(), CONTROL, SHIFT, keyCode);
          } else if (shiftFirst)
          {
            cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(SHIFT) + "+" + KeyEvent.getKeyText(CONTROL) + "+" + KeyEvent.getKeyText(keyCode));
            shiftKeyPressed = false;
            ctrlKeyPressed = false;
            shiftFirst = false;
            mapKey(gestures[i].toLowerCase(), SHIFT, CONTROL, keyCode);
          }
        }
      } else if (altKeyPressed && keyCode != CONTROL && keyCode != SHIFT)
      {

        cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(ALT) + "+" + KeyEvent.getKeyText(keyCode));
        altKeyPressed = false;
        altFirst = false;
        mapKey(gestures[i].toLowerCase(), ALT, keyCode, 0);
        if (keyCode == ALT)
        {
          cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(ALT));
        }
      } else if (ctrlKeyPressed && keyCode != ALT && keyCode != SHIFT)
      {
        cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(CONTROL) + "+" + KeyEvent.getKeyText(keyCode));
        ctrlKeyPressed = false;
        ctrlFirst = false;
        mapKey(gestures[i].toLowerCase(), CONTROL, keyCode, 0);
        if (keyCode == CONTROL)
        {
          cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(CONTROL));
          mapKey(gestures[i].toLowerCase(), keyCode, 0, 0);
        }
      } else if (shiftKeyPressed && keyCode != ALT && keyCode != CONTROL)
      {
        cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(SHIFT) + "+" + KeyEvent.getKeyText(keyCode));
        shiftKeyPressed = false;
        shiftFirst = false;
        mapKey(gestures[i].toLowerCase(), SHIFT, keyCode, 0);
        if (keyCode == SHIFT)
        {
          cp5.get(Textfield.class, gestures[i].toLowerCase()).setText(" " + KeyEvent.getKeyText(SHIFT));
          mapKey(gestures[i].toLowerCase(), keyCode, 0, 0);
        }
      }
    }
  }
}

int[] getArrayByName(String gesture)
{
  switch(gesture)
  {

  case "swipe right": 
    return swipeRightGestureKeyCode;

  case "swipe left": 
    return swipeLeftGestureKeyCode;

  case "swipe up": 
    return swipeUpGestureKeyCode;

  case "swipe down": 
    return swipeDownGestureKeyCode;

  case "circle clockwise": 
    return circleClockwiseGestureKeyCode;

  case "circle anticlockwise": 
    return circleAnticlockwiseGestureKeyCode;

  case "screen tap": 
    return screenTapGestureKeyCode;

  case "key tap": 
    return keyTapGestureKeyCode;

  case "fist pose": 
    return fistPoseKeyCode;

  case "victory pose": 
    return victoryPoseKeyCode;

  default:
    throw new IllegalArgumentException("Gesture invalid: " + gesture);
  }
}

//SAVE JSON
void saveJson() {

  int[] keys = new int[3];

  JSONObject json = new JSONObject();

  for (int i=0; i < settings.length-1; i++)
  {
    json.setInt(settings[i].toLowerCase(), i==0 ? sensitivity_x : i==1 ? sensitivity_y : i==2 ? hand_value : i==3 ? swipe_delay : i==4 ? screen_delay : i==5 ? circle_radius_max : i==5 ? circle_radius_max : i==6 ? circle_radius_min : i==7 ? display_width : display_height);
  }
  //JSONObject lion = new JSONObject();

  JSONArray values = new JSONArray();

  for (int i = 0; i < gestures.length; i++) {

    JSONObject gesture = new JSONObject();
    keys = getArrayByName(gestures[i].toLowerCase());
    gesture.setString("gesture", gestures[i].toLowerCase()); 
    gesture.setInt("keyCode1", keys[0]);
    gesture.setInt("keyCode2", keys[1]);
    gesture.setInt("keyCode3", keys[2]);

    values.setJSONObject(i, gesture);
  }
  json.setJSONArray("gestures", values);
  println(json);


  //restituisce il nome del file preso dal textfield setup
  String fileName = cp5.get(Textfield.class, "file name").getText().trim();
  //percorso del file
  String path = setupPath + fileName + setupExtensionFile;

  String[] lines = loadStrings(path);

  //se il percorso non esiste crea il file
  if (lines == null)
  {
    createWriter(path);
  }
  //salva/sovrascrive il file json corrispondente
  saveJSONObject(json, path);
}

//LOAD JSON

void loadJson(String fileName) {

  //percorso del file
  String path = setupPath + fileName + setupExtensionFile;

  //se il percorso non esiste crea il file
  String[] lines = loadStrings(path);
  if (lines == null)
  {
    createWriter(path);
  }

  //carica il file json corrispondente
  JSONObject json = loadJSONObject(path);

  for (int i=0; i < settings.length; i++)
  {
    switch(settings[i].toLowerCase())
    {
    case "swipe delay":
      swipe_delay = json.getInt(settings[i].toLowerCase());
      cp5.get(Textfield.class, settings[i].toLowerCase()).setText(" " + str(swipe_delay));

      break;
    case "screen delay":
      screen_delay = json.getInt(settings[i].toLowerCase());
      cp5.get(Textfield.class, settings[i].toLowerCase()).setText(" " + str(screen_delay));

      break;
    case "circle radius max":
      circle_radius_max = json.getInt(settings[i].toLowerCase());
      cp5.get(Textfield.class, settings[i].toLowerCase()).setText(" " + str(circle_radius_max));

      break;

    case "circle radius min":
      circle_radius_min = json.getInt(settings[i].toLowerCase());
      cp5.get(Textfield.class, settings[i].toLowerCase()).setText(" " + str(circle_radius_min));

      break;
    case "sensitivity x":
      sensitivity_x = json.getInt(settings[i].toLowerCase());
      cp5.getController(settings[i].toLowerCase()).setValue(sensitivity_x);

      break;

    case "sensitivity y":
      sensitivity_y = json.getInt(settings[i].toLowerCase());
      cp5.getController(settings[i].toLowerCase()).setValue(sensitivity_y);
      break;

    case "hand":
      hand_value = json.getInt(settings[i].toLowerCase());
      r1.activate(hand_value);

      break;
    case "display width":
      display_width = json.getInt(settings[i].toLowerCase());
      cp5.get(Textfield.class, settings[i].toLowerCase()).setText(" " + str(display_width));

      break;
    case "display height":
      display_height = json.getInt(settings[i].toLowerCase());
      cp5.get(Textfield.class, settings[i].toLowerCase()).setText(" " + str(display_height));
      break;
    }
  }


  String text1 = null;
  String text2 = null;
  String text3 = null;

  JSONArray values = json.getJSONArray("gestures");
  for (int i=0; i < values.size(); i++)
  {

    JSONObject gesture = values.getJSONObject(i);

    String gestureName = gesture.getString("gesture");
    int keyCode1 = gesture.getInt("keyCode1");
    int keyCode2 = gesture.getInt("keyCode2");
    int keyCode3 = gesture.getInt("keyCode3");

    println("\ngesto: " + gestureName);
    println("key code 1: " + keyCode1);
    println("key code 2: " + keyCode2);
    println("key code 3: " + keyCode3);

    //restituisce il nome del tasto in base al codice
    text1 = KeyEvent.getKeyText(keyCode1);
    text1 = checkText(text1);

    //imposta il testo per i tasti del mouse
    switch(keyCode1)
    {
    case 1:
      text1 = "M1";
      break;
    case 4:
      text1 = "M3";
      break;
    case 2:
      text1 = "M2";
      break;
    }
    //controllo per vedere se c'è una combo
    if (keyCode3 != 0)
    {
      //restituisce il nome del tasto in base al codice
      text2 = KeyEvent.getKeyText(keyCode2);
      text2 = checkText(text2); 

      text3 = KeyEvent.getKeyText(keyCode3);
      text3 = checkText(text3); 

      cp5.get(Textfield.class, gestureName).setText(" " + text1 + "+" + text2 + "+" + text3);
    } else if (keyCode2 != 0)
    {
      //restituisce il nome del tasto in base al codice
      text2 = KeyEvent.getKeyText(keyCode2);
      text2 = checkText(text2); 

      cp5.get(Textfield.class, gestureName).setText(" " + text1 + "+" + text2);
    } else
    {
      cp5.get(Textfield.class, gestureName).setText(" " + text1);
    }

    //vengono mappati i tasti con i codici
    mapKey(gestureName, keyCode1, keyCode2, keyCode3);
  }
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup() && theEvent.getName().equals("r1")) {
    hand_value = (int) r1.getValue();
  } else {
    if (theEvent.isAssignableFrom(Textfield.class)) {

      switch(theEvent.getController().getName())
      {
      case "swipe delay":
        String swipeString = cp5.get(Textfield.class, theEvent.getController().getName()).getStringValue().trim();
        swipe_delay =  Integer.valueOf(swipeString);
        break;
      case "screen delay":
        String screenString = cp5.get(Textfield.class, theEvent.getController().getName()).getStringValue().trim();
        screen_delay =  Integer.valueOf(screenString);
        break;

      case "circle radius max":
        String circleMaxString = cp5.get(Textfield.class, theEvent.getController().getName()).getStringValue().trim();
        circle_radius_max =  Integer.valueOf(circleMaxString);
        break;    
      case "circle radius min":
        String circleMinString = cp5.get(Textfield.class, theEvent.getController().getName()).getStringValue().trim();
        circle_radius_min =  Integer.valueOf(circleMinString);
        break;

      case "display width":
        String displayXString = cp5.get(Textfield.class, theEvent.getController().getName()).getStringValue().trim();
        display_width=  Integer.valueOf(displayXString);

        break;
      case "display height":
        String displayYString = cp5.get(Textfield.class, theEvent.getController().getName()).getStringValue().trim();
        display_height =  Integer.valueOf(displayYString);
        break;
      }
    }
  }
  //for che scorre tutti i textfield
  for (int i=0; i<gestures.length; i++) {

    //se viene premuto un  bottone clear corrispondenete a un textfield
    if (theEvent.getName().equals("clear"+i)) {
      count=0;
      //pulisce il textfield corrispondente
      cp5.get(Textfield.class, gestures[i].toLowerCase()).clear();  
      //rimuove il tasto abbinato al gesto corrispondente
      mapKey(gestures[i].toLowerCase(), 0, 0, 0);
    }
  }
  //se viene modificato uno slider della sensibilità
  if (theEvent.getName().equals("sensitivity x"))
  {
    sensitivity_x = (int)theEvent.getController().getValue();
    println("sensitivity x: " + sensitivity_x);
  }
  if (theEvent.getName().equals("sensitivity y"))
  {
    //se corrisponde a 0 è relativo alla sensibilità Y
    sensitivity_y = (int)theEvent.getController().getValue();
    println("sensitivity y: " + sensitivity_y);
  }
}




//  GESTURES
// ======================================================
// 1. Swipe Gesture

void leapOnSwipeGesture(SwipeGesture g, int state) {


  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector position         = g.getPosition();
  PVector positionStart    = g.getStartPosition();
  PVector direction        = g.getDirection();
  float   speed            = g.getSpeed();
  long    duration         = g.getDuration();
  float   durationSeconds  = g.getDurationInSeconds();

  float start=0, end=0, distance=0;
  int currentTime = millis();
  boolean flagDuplicate = false;


  println(swipe_delay);
  for (Hand hand : leap.getHands ()) {

    //controlla se il valore del radio button per scegliere quale mano utilizzare combacia con la mano che il leap motion 
    if (hand_value == 0 && hand.isRight() || hand_value == 1 && hand.isLeft())
    {
      //switch che controlla lo stato del gesto se è iniziato se è in corso o se è terminato
      switch(state) {
      case 1: // Start

        //println("\nSwipeGesture: " + id);

        //restituisce la coordinata X di partenza della mano/indice
        start = direction.x;
        //println("start: " + start);

        break;
      case 2: // Update

        break;
      case 3: // Stop
        //controlla che ci sia un delay preimpostato in modo tale da non eseguire più gesti quando se ne esegue uno

        if ( (currentTime - previousTime) < swipe_delay) {
          flagDuplicate = true;
        }

        //individua se è uno swipe veloce o uno swipe lento  
        /*
        if (durationSeconds < 0.1) {
         println( (flagDuplicateSwipe ? "IGNORE " : "") + "Quick Swipe Gesture: " + id + " [duration = " + durationSeconds + "]");
         } else {
         println( (flagDuplicateSwipe ? "IGNORE " : "") + "Slow Swipe Gesture: " + id + " [duration = " + durationSeconds + "]");
         }
         */
        //resetta il tempo
        previousTime = currentTime; 
        //controlla che non sia un gesto duplicato
        if (!flagDuplicate)
        {
          //restituisce la coordinata x nel momento in cui finisce il gesto
          end = direction.x;
          //println("end: " + end);

          //calcola la distanza che ha percorso la mano durante il gesto
          distance = end - start;

          //controllo per vedere se è uno swipe a destra
          if (start < end)
          {
            //se la distanza supera la distanza minima allora viene contato il gesto
            //if (distance >= swipeDistance)
            //{
            println("\nSwipeGesture: " + id);
            println("swipe right");
            println(distance);
            //esegue il gesto
            doGesture(swipeRightGestureKeyCode);
            //}
          } 
          //controllo per vedere se è uno swipe a sinistra
          else if (start > end)
          {
            //se la distanza supera la distanza minima allora viene contato il gesto
            //if (distance <= -swipeDistance)
            //{
            println("\nSwipeGesture: " + id);
            println("swipe left");
            println(distance);
            //esegue il gesto
            doGesture(swipeLeftGestureKeyCode);
            //}
          }
        }
        break;
      }
    }
  }
}


// ======================================================
// 2. Circle Gesture

void leapOnCircleGesture(CircleGesture g, int state) {
  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector positionCenter   = g.getCenter();
  float   radius           = g.getRadius();
  float   progress         = g.getProgress();
  long    duration         = g.getDuration();
  float   durationSeconds  = g.getDurationInSeconds();
  int     direction        = g.getDirection();

  int currentTime = millis();
  boolean flagDuplicate = false;

  for (Hand hand : leap.getHands ()) {
    //controlla se il valore del radio button per scegliere quale mano utilizzare combacia con la mano che il leap motion 
    if (hand_value == 0 && hand.isRight() || hand_value == 1 && hand.isLeft())
    {
      switch(state) {
        //switch che controlla lo stato del gesto se è iniziato se è in corso o se è terminato
      case 1: // Start
        break;
      case 2: // Update
        break;
      case 3: // Stop
        //controlla che ci sia un delay preimpostato in modo tale da non eseguire più gesti quando se ne esegue uno
        //if ( (currentTime - previousTime) < circleDelayMillis) {
        flagDuplicate = true;
        //}
        //controlla che non sia un gesto duplicato
        if (!flagDuplicate)
        {


          //println("progress: " + progress);

          //println("duration: " + durationSeconds);
          //controlla che il raggio del cerchio non sia maggiore di un determinato valore
          /*
          if (radius < circle_radius)
          {
            switch(direction) {

              //in base alla direzione se è antiorario
            case 0: // Anticlockwise/Left gesture
              println("CircleGesture: " + id);
              println("Anticlockwise");    
              println("radius: " + radius);

              //esegue gesto
              doGesture(circleAnticlockwiseGestureKeyCode);
              break;
              //in base alla direzione se è orario
            case 1: // Clockwise/Right gesture
              println("CircleGesture: " + id);
              println("Clockwise");
              println("radius: " + radius);       
              //esegue gesto
              doGesture(circleClockwiseGestureKeyCode);
              break;
            }
          }
          */
        }
        //resetta il tempo
        previousTime = currentTime; 
        break;
      }
    }
  }
}


// ======================================================
// 3. Screen Tap Gesture

void leapOnScreenTapGesture(ScreenTapGesture g) {


  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector position         = g.getPosition();
  PVector direction        = g.getDirection();
  long    duration         = g.getDuration();
  float   durationSeconds  = g.getDurationInSeconds();


  for (Hand hand : leap.getHands ()) {
    //controlla se il valore del radio button per scegliere quale mano utilizzare combacia con la mano che il leap motion 
    if (hand_value == 0 && hand.isRight() || hand_value == 1 && hand.isLeft())
    {
      //println("profondità: " +  direction.z);
      //println("durata: " +  durationSeconds);

      println("ScreenTapGesture: " + id);
      //esegue gesto
      doGesture(screenTapGestureKeyCode);
    }
  }
}


// ======================================================
// 4. Key Tap Gesture

void leapOnKeyTapGesture(KeyTapGesture g) {


  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector position         = g.getPosition();
  PVector direction        = g.getDirection();
  long    duration         = g.getDuration();
  float   durationSeconds  = g.getDurationInSeconds();

  for (Hand hand : leap.getHands ()) {
    //controlla se il valore del radio button per scegliere quale mano utilizzare combacia con la mano che il leap motion
    if (hand_value == 0 && hand.isRight() || hand_value == 1 && hand.isLeft())
    {
      //esegue gesto
      println("KeyTapGesture: " + id);
      doGesture(keyTapGestureKeyCode);
    }
  }
}
//  POSES
// ======================================================
// 1. Fist Pose
void fistPose(Hand hand)
{

  //restituisce un valore float da 0 a 1 che indica la forza della presa della mano corrispondente
  float handGrab = hand.getGrabStrength();
  //int handStretchedSize = hand.getOutstretchedFingers().size();
  //float   sphereRadius       = hand.getSphereRadius();

  PVector thumbTip = hand.getThumb().getRawPositionOfJointTip();
  PVector indexTip = hand.getIndexFinger().getRawPositionOfJointTip();

  PVector thumbMcp = hand.getThumb().getRawPositionOfJointMcp();
  PVector indexMcp = hand.getIndexFinger().getRawPositionOfJointMcp();

  PVector thumbDir = PVector.sub(thumbTip, thumbMcp);
  PVector indexDir = PVector.sub(indexTip, indexMcp);

  //angolo in base alla posizione del pollice e dell'indice

  int a = (int) degrees(PVector.angleBetween(thumbDir, indexDir));

  //controlla se l'angolo e il valore della forza della presa corrispondono a una fist pose
  if (handGrab >= 0.99 && a>=90) {

    println("fist pose");
    doGesture(fistPoseKeyCode);
  }
}

// ======================================================
// 2. Victory Pose

void victoryPose(Hand hand)
{  
  //restituisce  il numero di dita tese 
  int handStretchedSize = hand.getOutstretchedFingers().size();
  //tip
  PVector thumbTip = hand.getThumb().getRawPositionOfJointTip();
  PVector indexTip = hand.getIndexFinger().getRawPositionOfJointTip();
  PVector middleTip = hand.getMiddleFinger().getRawPositionOfJointTip();
  PVector ringTip = hand.getRingFinger().getRawPositionOfJointTip();
  PVector pinkTip = hand.getPinkyFinger().getRawPositionOfJointTip();

  //mcp
  PVector thumbMcp = hand.getThumb().getRawPositionOfJointMcp();
  PVector indexMcp = hand.getIndexFinger().getRawPositionOfJointMcp();
  PVector middleMcp = hand.getMiddleFinger().getRawPositionOfJointMcp();
  PVector ringMcp =  hand.getRingFinger().getRawPositionOfJointMcp();
  PVector pinkMcp = hand.getPinkyFinger().getRawPositionOfJointMcp();

  //dir
  PVector thumbDir = PVector.sub(thumbTip, thumbMcp);
  PVector indexDir = PVector.sub(indexTip, indexMcp);
  PVector middleDir = PVector.sub(middleTip, middleMcp);
  PVector ringDir = PVector.sub(ringTip, ringMcp);
  PVector pinkDir = PVector.sub(pinkTip, pinkMcp);

  //angolo in base alla posizione dell'indice e del medio
  int a = (int) degrees(PVector.angleBetween(indexDir, middleDir));
  //angolo in base alla posizione del pollice e dell'anulare
  int b = (int) degrees(PVector.angleBetween(thumbDir, ringDir));
  //angolo in base alla posizione del pollice e del mignolo
  int c = (int) degrees(PVector.angleBetween(thumbDir, pinkDir));

  //println("a: " + a + "°\tb: " + b + "°\tc: " + c + "°");

  //controlla se l'angolo e il numero di dita tese corrispondo a una victory pose
  if (a <= 20 && a >= 10 && b <= 110 && b >= 80 && c <= 110 && c >= 80 && handStretchedSize==2)
  {
    println("victory pose");
    doGesture(victoryPoseKeyCode);
  }
}

//funzione che mappa array del gesto o posa corrispondente
int[] mapArray(int[] gesture, int keyCode1, int keyCode2, int keyCode3)
{

  gesture[0] = keyCode1;
  gesture[1] = keyCode2;
  gesture[2] = keyCode3;

  return gesture;
}
//funzione che mappa le gesture con i keyCode corrispondenti
void mapKey( String name, int keyCode1, int keyCode2, int keyCode3) {

  switch(name)
  {

  case "swipe right": 
    mapArray(swipeRightGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + swipeRightGestureKeyCode[0] + "  " + swipeRightGestureKeyCode[1], swipeRightGestureKeyCode[2]);
    break;

  case "swipe left": 
    mapArray(swipeLeftGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + swipeLeftGestureKeyCode[0] + "  " + swipeLeftGestureKeyCode[1], swipeLeftGestureKeyCode[2]);
    break;
  case "swipe up": 
    mapArray(swipeUpGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + swipeUpGestureKeyCode[0] + "  " + swipeUpGestureKeyCode[1], swipeUpGestureKeyCode[2]);
    break;
  case "swipe down": 
    mapArray(swipeDownGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + swipeDownGestureKeyCode[0] + "  " + swipeDownGestureKeyCode[1], swipeDownGestureKeyCode[2]);
    break;

  case "circle clockwise": 
    mapArray(circleClockwiseGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + circleClockwiseGestureKeyCode[0] + "  " + circleClockwiseGestureKeyCode[1], circleClockwiseGestureKeyCode[2]);
    break;

  case "circle anticlockwise": 
    mapArray(circleAnticlockwiseGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + circleAnticlockwiseGestureKeyCode[0] + "  " + circleAnticlockwiseGestureKeyCode[1], circleAnticlockwiseGestureKeyCode[2]);
    break;

  case "screen tap": 
    mapArray(screenTapGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + screenTapGestureKeyCode[0] + "  " + screenTapGestureKeyCode[1], screenTapGestureKeyCode[2]);
    break;

  case "key tap": 
    mapArray(keyTapGestureKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + keyTapGestureKeyCode[0] + "  " + keyTapGestureKeyCode[1], keyTapGestureKeyCode[2]);
    break;

  case "fist pose": 
    mapArray(fistPoseKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + fistPoseKeyCode[0] + "  " + fistPoseKeyCode[1], fistPoseKeyCode[2]);
    break;

  case "victory pose": 
    mapArray(victoryPoseKeyCode, keyCode1, keyCode2, keyCode3);
    println(name.toUpperCase() + ": " + victoryPoseKeyCode[0] + "  " + victoryPoseKeyCode[1], victoryPoseKeyCode[2]);
    break;

  default:
    throw new IllegalArgumentException("Gesture invalid: " + name);
  }
}
//funzione che esegue il gesto o la posa
void doGesture(int[] gesture)
{

  //controllo per vedere se è una combo
  if (gesture[0] != 0 && gesture[1] != 0)
  {
    robot.keyPress(gesture[0]);
    robot.keyPress(gesture[1]);

    robot.keyRelease(gesture[0]);
    robot.keyRelease(gesture[1]);
  } 
  //controllo per vedere se è una pressione normale
  else if (gesture[0] != 0)
  {
    //controllo per vedere se è una pressione con il mouse
    if (gesture[0] == 1 || gesture[0] == 4 || gesture[0] == 2)
    {

      robot.mousePress(gesture[0]);
      robot.mouseRelease(gesture[0]);
    } else
    {
      robot.keyPress(gesture[0]);
      robot.keyRelease(gesture[0]);
    }
  }
}
