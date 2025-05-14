// sketch.js - Juego Arduino Interactivo
// Autor: Justino Gato Muélledes
// Descripción: Versión con interfaz profesional, salida con retardo de 5 segundos, botones mejorados

let anchoPantalla = 1600;
let altoPantalla = 900;

let fondo, placaImg;
let ledImg, ledRojoImg, ledVerdeImg, buttonImg, resistorImg, sensorImg, servoImg;
let displayImg, motorImg, buzzerImg;

let sonidoOk, sonidoError, musicaSalida;
let componentes = [];
let estado = "MENU";
let instruccion = "";
let mensajeCorrecto = false;
let mensajeError = false;
let botones = {};
let tamComponente = 130;

const componentesCorrectos1 = ["RESISTOR", "RESISTOR", "PULSADOR", "LED", "LED"];
const componentesCorrectos2 = ["LED_VERDE", "LED_ROJO", "PULSADOR", "RESISTOR", "RESISTOR"];
const componentesCorrectos3 = ["SENSOR", "RESISTOR", "RESISTOR", "RESISTOR", "SERVO", "LED_VERDE", "LED_ROJO"];

function preload() {
  fondo = loadImage("fondo.png");
  placaImg = loadImage("placa.png");
  ledImg = loadImage("led.png");
  ledRojoImg = loadImage("led_rojo.jpg");
  ledVerdeImg = loadImage("led_verde.png");
  buttonImg = loadImage("pulsador.png");
  resistorImg = loadImage("resistor.png");
  sensorImg = loadImage("sensor.png");
  servoImg = loadImage("servo.png");
  displayImg = loadImage("display.png");
  motorImg = loadImage("motor.png");
  buzzerImg = loadImage("buzzer.png");

  sonidoOk = loadSound("ok.wav");
  sonidoError = loadSound("error.wav");
  musicaSalida = loadSound("music_fondo.mp3");
}

function setup() {
  createCanvas(anchoPantalla, altoPantalla);
  textFont("Open Sans");
  crearBotones();
}

function draw() {
  background(240);
  if (fondo) image(fondo, 0, 0, width, height);
  mostrarCabecera();

  if (estado === "MENU") {
    mostrarMenu();
  } else if (estado.startsWith("NIVEL")) {
    image(placaImg, 120, 120, 800, 500);
    for (let c of componentes) c.display();
    if (mensajeCorrecto) mostrarMensaje("✓ Montaje correcto. ¡Enhorabuena!", color(0, 200, 0));
    if (mensajeError) mostrarMensaje("✗ Error: Revisa los componentes.", color(200, 0, 0));
  }
}

function mostrarCabecera() {
  fill("#00695c");
  noStroke();
  rect(0, 0, width, 70);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("ESCUELA ARDUINO | Interfaz Interactiva de Montaje", width / 2, 35);
  if (estado.startsWith("NIVEL")) {
    fill("#004d40");
    textAlign(LEFT);
    textSize(18);
    text("Instrucciones: " + instruccion, 30, 80);
  }
}

function mostrarMenu() {
  fill(255, 255, 255, 160);
  stroke("#004d40");
  strokeWeight(2);
  rect(60, 100, 420, 340, 20);
}

function crearBotones() {
  botones.nivel1 = createButton("Montaje 1: LEDs + Pulsador con resistencias");
  botones.nivel1.position(90, 130);
  botones.nivel1.size(380, 50);
  botones.nivel1.mousePressed(() => iniciarNivel("NIVEL1"));

  botones.nivel2 = createButton("Montaje 2: Semáforo Peatonal con LEDs y Pulsador");
  botones.nivel2.position(90, 200);
  botones.nivel2.size(380, 50);
  botones.nivel2.mousePressed(() => iniciarNivel("NIVEL2"));

  botones.nivel3 = createButton("Montaje 3: Parking con Sensor y Servomotor");
  botones.nivel3.position(90, 270);
  botones.nivel3.size(380, 50);
  botones.nivel3.mousePressed(() => iniciarNivel("NIVEL3"));

  botones.verificar = createButton("VERIFICAR MONTAJE");
  botones.verificar.position(width - 240, height - 70);
  botones.verificar.size(200, 50);
  botones.verificar.mousePressed(verificarMontaje);
  botones.verificar.hide();

  botones.salir = createButton("Salir del juego");
  botones.salir.position(90, 340);
  botones.salir.size(380, 50);
  botones.salir.mousePressed(salirDelJuego);
}

function iniciarNivel(nivel) {
  estado = nivel;
  mensajeCorrecto = false;
  mensajeError = false;
  botones.verificar.show();

  if (nivel === "NIVEL1") {
    instruccion = "Enciende dos LEDs mediante un pulsador y resistencias";
    crearComponentesNivel1();
  } else if (nivel === "NIVEL2") {
    instruccion = "Construye un semáforo con LEDs, resistencias y pulsador";
    crearComponentesNivel2();
  } else {
    instruccion = "Simula un parking con sensor, servomotor y LEDs";
    crearComponentesNivel3();
  }
}

function salirDelJuego() {
  musicaSalida.play();
  setTimeout(() => {
    window.location.href = "index1.html";
  }, 5000); // Espera 5 segundos antes de salir
}

function mostrarMensaje(msg, c) {
  fill(c);
  textSize(28);
  textAlign(CENTER);
  text(msg, width / 2, height - 40);
}

function verificarMontaje() {
  let colocados = componentes.filter(c => c.estaEnPlaca()).map(c => c.tipo);
  let referencia = estado === "NIVEL1" ? [...componentesCorrectos1] :
                   estado === "NIVEL2" ? [...componentesCorrectos2] : [...componentesCorrectos3];

  for (let tipo of colocados) {
    const index = referencia.indexOf(tipo);
    if (index !== -1) referencia.splice(index, 1);
    else {
      mensajeCorrecto = false;
      mensajeError = true;
      sonidoError.play();
      return;
    }
  }

  if (referencia.length === 0) {
    mensajeCorrecto = true;
    mensajeError = false;
    sonidoOk.play();
  } else {
    mensajeCorrecto = false;
    mensajeError = true;
    sonidoError.play();
  }
}

function crearComponentesNivel1() {
  componentes = [
    new Componente("LED", ledImg, 950, 100),
    new Componente("LED", ledImg, 1090, 100),
    new Componente("RESISTOR", resistorImg, 950, 260),
    new Componente("RESISTOR", resistorImg, 1090, 260),
    new Componente("PULSADOR", buttonImg, 1020, 420),
    new Componente("DISPLAY", displayImg, 950, 600),
    new Componente("MOTOR", motorImg, 1090, 600)
  ];
}

function crearComponentesNivel2() {
  componentes = [
    new Componente("LED_VERDE", ledVerdeImg, 950, 100),
    new Componente("LED_ROJO", ledRojoImg, 1090, 100),
    new Componente("RESISTOR", resistorImg, 950, 260),
    new Componente("RESISTOR", resistorImg, 1090, 260),
    new Componente("PULSADOR", buttonImg, 1020, 420),
    new Componente("BUZZER", buzzerImg, 950, 600),
    new Componente("DISPLAY", displayImg, 1090, 600)
  ];
}

function crearComponentesNivel3() {
  componentes = [
    new Componente("SENSOR", sensorImg, 950, 100),
    new Componente("RESISTOR", resistorImg, 1090, 100),
    new Componente("RESISTOR", resistorImg, 950, 260),
    new Componente("RESISTOR", resistorImg, 1090, 260),
    new Componente("LED_VERDE", ledVerdeImg, 950, 420),
    new Componente("LED_ROJO", ledRojoImg, 1090, 420),
    new Componente("SERVO", servoImg, 1020, 580),
    new Componente("BUZZER", buzzerImg, 950, 730),
    new Componente("MOTOR", motorImg, 1090, 730)
  ];
}

function mousePressed() {
  if (estado.startsWith("NIVEL")) componentes.forEach(c => c.mousePressed());
}
function mouseDragged() {
  if (estado.startsWith("NIVEL")) componentes.forEach(c => c.mouseDragged());
}
function mouseReleased() {
  if (estado.startsWith("NIVEL")) componentes.forEach(c => c.mouseReleased());
}

class Componente {
  constructor(tipo, img, x, y) {
    this.tipo = tipo;
    this.img = img;
    this.x = x;
    this.y = y;
    this.w = tamComponente;
    this.h = tamComponente;
    this.arrastrando = false;
    this.offsetX = 0;
    this.offsetY = 0;
  }

  display() {
    image(this.img, this.x, this.y, this.w, this.h);
  }

  estaEnPlaca() {
    return this.x > 100 && this.x < 950 && this.y > 120 && this.y < 700;
  }

  mousePressed() {
    if (mouseX > this.x && mouseX < this.x + this.w && mouseY > this.y && mouseY < this.y + this.h) {
      this.arrastrando = true;
      this.offsetX = mouseX - this.x;
      this.offsetY = mouseY - this.y;
    }
  }

  mouseDragged() {
    if (this.arrastrando) {
      this.x = mouseX - this.offsetX;
      this.y = mouseY - this.offsetY;
    }
  }

  mouseReleased() {
    this.arrastrando = false;
  }
}
