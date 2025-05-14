// ============================================================================
// Juego educativo: Montaje virtual de circuitos Arduino
// Autor: Justino Gato Muélledes
//
// Finalidad: Aplicación interactiva para que los usuarios simulen montajes
// electrónicos con Arduino de forma visual y educativa.
//
// Características:
// - 3 niveles con diferentes objetivos de montaje
// - Drag & Drop de componentes electrónicos
// - Verificación con retroalimentación visual y sonora
// - Sonido ambiente y efectos
// ============================================================================

import controlP5.*;
import java.util.ArrayList;
import ddf.minim.*;  // Librería para manejo de audio

// --------------------- Recursos de Audio ---------------------
Minim minim;
AudioPlayer sonidoOk;
AudioPlayer sonidoError;
AudioPlayer musicaSalida;  // Reproduce música al salir

// --------------------- Recursos Visuales ---------------------
ControlP5 cp5;
PImage fondo, ledImg, ledRojoImg, ledVerdeImg, buttonImg, resistorImg, placaImg, sensorImg, servoImg;
PImage displayImg, motorImg, buzzerImg;

ArrayList<Componente> componentes = new ArrayList<Componente>();

// --------------------- Lógica de Juego ---------------------
String estado = "MENU";
boolean mensajeCorrecto = false;
boolean mensajeError = false;
String instruccion = "";

// Soluciones por nivel
String[] componentesCorrectos1 = {"RESISTOR", "RESISTOR", "PULSADOR", "LED", "LED"};
String[] componentesCorrectos2 = {"LED_VERDE", "LED_ROJO", "PULSADOR", "RESISTOR", "RESISTOR"};
String[] componentesCorrectos3 = {"SENSOR", "RESISTOR", "RESISTOR", "RESISTOR", "SERVO", "LED_VERDE", "LED_ROJO"};

void setup() {
  size(1200, 700);

  // -------------------- Carga de imágenes --------------------
  fondo = loadImage("fondo.png");
  ledImg = loadImage("led.png");
  ledRojoImg = loadImage("led_rojo.jpg");
  ledVerdeImg = loadImage("led_verde.png");
  buttonImg = loadImage("pulsador.png");
  resistorImg = loadImage("resistor.png");
  sensorImg = loadImage("sensor.png");
  servoImg = loadImage("servo.png");
  placaImg = loadImage("placa.png");
  displayImg = loadImage("display.png");
  motorImg = loadImage("motor.png");
  buzzerImg = loadImage("buzzer.png");

  // -------------------- Interfaz de botones --------------------
  cp5 = new ControlP5(this);
  cp5.addButton("jugarNivel1").setLabel("Montaje 1: LEDs + Pulsador").setPosition(30, 100).setSize(300, 40);
  cp5.addButton("jugarNivel2").setLabel("Montaje 2: Semáforo Peatonal").setPosition(30, 160).setSize(300, 40);
  cp5.addButton("jugarNivel3").setLabel("Montaje 3: Parking con sensores").setPosition(30, 220).setSize(300, 40);
  cp5.addButton("salir").setLabel("Salir del juego").setPosition(30, 280).setSize(300, 40);
  cp5.addButton("verificar").setLabel("VERIFICAR").setPosition(1000, 600).setSize(150, 50).hide();

  // -------------------- Sonidos --------------------
  minim = new Minim(this);
  sonidoOk = minim.loadFile("ok.wav");
  sonidoError = minim.loadFile("error.wav");
  musicaSalida = minim.loadFile("music_fondo.mp3");  // Reproduce al salir

  crearComponentesNivel1();
}

void draw() {
  background(255);
  if (fondo != null) image(fondo, 0, 0, width, height);
  mostrarCabecera();

  if (estado.equals("MENU")) {
    mostrarMenu();
  } else if (estado.startsWith("NIVEL")) {
    jugarNivel();
  }
}

// -------------------- Encabezado --------------------
void mostrarCabecera() {
  fill(30, 144, 255);
  noStroke();
  rect(0, 0, width, 60);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("ESCOGE UN MONTAJE PARA REALIZAR EN ARDUINO Y COLOCA LOS COMPONENTES NECESARIOS.", width/2, 30);

  if (estado.startsWith("NIVEL")) {
    fill(255); // Instrucción en blanco
    textAlign(LEFT);
    textSize(20); // Tamaño aumentado
    text("Instrucciones: " + instruccion, 30, 70);
  }
}

void mostrarMenu() {
  fill(30, 144, 255, 100);
  noStroke();
  rect(20, 70, 340, 270, 20);
}

void jugarNivel() {
  image(placaImg, 120, 120);
  for (Componente c : componentes) c.display();

  if (mensajeCorrecto) {
    fill(0, 200, 0);
    textSize(28);
    text("✓ Montaje correcto. ¡Enhorabuena!", 400, 650);
  }

  if (mensajeError) {
    fill(200, 0, 0);
    textSize(28);
    text("✗ Error: Revisa los componentes.", 400, 650);
  }
}

// -------------------- Gestión de niveles --------------------
void jugarNivel1(int val) {
  estado = "NIVEL1";
  instruccion = "Encendido de 2 LEDs con pulsador";
  mensajeCorrecto = mensajeError = false;
  cp5.getController("verificar").show();
  crearComponentesNivel1();
}

void jugarNivel2(int val) {
  estado = "NIVEL2";
  instruccion = "Semáforo peatonal con LEDs y pulsador";
  mensajeCorrecto = mensajeError = false;
  cp5.getController("verificar").show();
  crearComponentesNivel2();
}

void jugarNivel3(int val) {
  estado = "NIVEL3";
  instruccion = "Control de parking con sensor, servomotor y LEDs";
  mensajeCorrecto = mensajeError = false;
  cp5.getController("verificar").show();
  crearComponentesNivel3();
}

void salir(int val) {
  // Reproduce música antes de salir
  musicaSalida.rewind();
  musicaSalida.play();

  // Esperar breve para que suene
  delay(2000);

  // Cierre de recursos
  sonidoOk.close();
  sonidoError.close();
  musicaSalida.close();
  minim.stop();

  exit();
}

// -------------------- Verificación lógica --------------------
void verificar() {
  ArrayList<String> colocados = new ArrayList<String>();
  for (Componente c : componentes) {
    if (c.estaEnPlaca()) colocados.add(c.tipo);
  }

  ArrayList<String> copiaCorrectos = new ArrayList<String>();
  String[] ref;
  if (estado.equals("NIVEL1")) ref = componentesCorrectos1;
  else if (estado.equals("NIVEL2")) ref = componentesCorrectos2;
  else ref = componentesCorrectos3;

  for (String tipo : ref) copiaCorrectos.add(tipo);

  for (String tipo : colocados) {
    if (copiaCorrectos.contains(tipo)) {
      copiaCorrectos.remove(tipo);
    } else {
      mensajeCorrecto = false;
      mensajeError = true;
      sonidoError.rewind();
      sonidoError.play();
      return;
    }
  }

  if (copiaCorrectos.isEmpty()) {
    mensajeCorrecto = true;
    mensajeError = false;
    sonidoOk.rewind();
    sonidoOk.play();
  } else {
    mensajeCorrecto = false;
    mensajeError = true;
    sonidoError.rewind();
    sonidoError.play();
  }
}

// -------------------- Componentes por nivel --------------------
void crearComponentesNivel1() {
  componentes.clear();
  componentes.add(new Componente("LED", ledImg, 950, 100));
  componentes.add(new Componente("LED", ledImg, 1020, 100));
  componentes.add(new Componente("RESISTOR", resistorImg, 950, 180));
  componentes.add(new Componente("RESISTOR", resistorImg, 1020, 180));
  componentes.add(new Componente("PULSADOR", buttonImg, 985, 260));
  componentes.add(new Componente("DISPLAY", displayImg, 950, 340));
  componentes.add(new Componente("MOTOR", motorImg, 1020, 340));
}

void crearComponentesNivel2() {
  componentes.clear();
  componentes.add(new Componente("LED_VERDE", ledVerdeImg, 950, 100));
  componentes.add(new Componente("LED_ROJO", ledRojoImg, 1020, 100));
  componentes.add(new Componente("RESISTOR", resistorImg, 950, 180));
  componentes.add(new Componente("RESISTOR", resistorImg, 1020, 180));
  componentes.add(new Componente("PULSADOR", buttonImg, 985, 260));
  componentes.add(new Componente("BUZZER", buzzerImg, 950, 340));
  componentes.add(new Componente("DISPLAY", displayImg, 1020, 340));
}

void crearComponentesNivel3() {
  componentes.clear();
  componentes.add(new Componente("SENSOR", sensorImg, 950, 100));
  componentes.add(new Componente("RESISTOR", resistorImg, 1020, 100));
  componentes.add(new Componente("RESISTOR", resistorImg, 950, 180));
  componentes.add(new Componente("RESISTOR", resistorImg, 1020, 180));
  componentes.add(new Componente("LED_VERDE", ledVerdeImg, 950, 260));
  componentes.add(new Componente("LED_ROJO", ledRojoImg, 1020, 260));
  componentes.add(new Componente("SERVO", servoImg, 985, 320));
  componentes.add(new Componente("MOTOR", motorImg, 950, 400));
  componentes.add(new Componente("BUZZER", buzzerImg, 1020, 400));
}

// -------------------- Interacción con el usuario --------------------
void mousePressed() {
  if (estado.startsWith("NIVEL")) for (Componente c : componentes) c.mousePressed();
}

void mouseDragged() {
  if (estado.startsWith("NIVEL")) for (Componente c : componentes) c.mouseDragged();
}

void mouseReleased() {
  if (estado.startsWith("NIVEL")) for (Componente c : componentes) c.mouseReleased();
}

// ============================================================================
// Clase Componente: Representa un componente arrastrable
// ============================================================================
class Componente {
  String tipo;
  PImage img;
  float x, y;
  float w = 80, h = 80;  // Aumento de tamaño
  boolean arrastrando = false;
  float offsetX, offsetY;

  Componente(String tipo, PImage img, float x, float y) {
    this.tipo = tipo;
    this.img = img;
    this.x = x;
    this.y = y;
  }

  void display() {
    image(img, x, y, w, h);
  }

  boolean estaEnPlaca() {
    return x > 100 && x < 850 && y > 120 && y < 600;
  }

  void mousePressed() {
    if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
      arrastrando = true;
      offsetX = mouseX - x;
      offsetY = mouseY - y;
    }
  }

  void mouseDragged() {
    if (arrastrando) {
      x = mouseX - offsetX;
      y = mouseY - offsetY;
    }
  }

  void mouseReleased() {
    arrastrando = false;
  }
}
