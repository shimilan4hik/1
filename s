<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>Затерянная Долина — Пляж</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 100%; height: 100%; overflow: hidden; font-family: 'Segoe UI', sans-serif; background: #000; color: #fff; }
  #canvas-container { width: 100%; height: 100%; position: relative; }
  canvas { display: block; }

  #ui {
    position: absolute; top: 0; left: 0; width: 100%; height: 100%;
    pointer-events: none; z-index: 10;
  }
  #hint {
    position: absolute; top: 30px; left: 50%; transform: translateX(-50%);
    background: rgba(10, 20, 30, 0.85); border: 1px solid #4fd1c5;
    padding: 14px 28px; border-radius: 10px; font-size: 16px;
    max-width: 600px; text-align: center; opacity: 0;
    transition: opacity 0.6s ease; backdrop-filter: blur(6px);
    box-shadow: 0 0 30px rgba(79, 209, 197, 0.3);
  }
  #hint.show { opacity: 1; }
  #hint b { color: #4fd1c5; }

  #error {
    position: absolute; top: 30px; left: 50%; transform: translateX(-50%);
    background: rgba(180, 20, 30, 0.95); border: 2px solid #ff4d4d;
    padding: 14px 28px; border-radius: 10px; font-size: 16px;
    font-weight: bold; opacity: 0; transition: opacity 0.4s;
    box-shadow: 0 0 40px rgba(255, 77, 77, 0.6);
  }
  #error.show { opacity: 1; }

  #step-indicator {
    position: absolute; top: 30px; left: 30px;
    background: rgba(10, 20, 30, 0.75); padding: 10px 18px;
    border-radius: 8px; font-size: 14px; border-left: 3px solid #4fd1c5;
  }
  #step-indicator .step-dot {
    display: inline-block; width: 10px; height: 10px;
    border-radius: 50%; background: #334; margin: 0 3px;
    vertical-align: middle; transition: background 0.3s;
  }
  #step-indicator .step-dot.done { background: #4fd1c5; box-shadow: 0 0 8px #4fd1c5; }
  #step-indicator .step-dot.active { background: #ffd166; box-shadow: 0 0 10px #ffd166; }

  #inventory {
    position: absolute; bottom: 30px; left: 30px;
    background: rgba(10, 20, 30, 0.75); padding: 12px 18px;
    border-radius: 8px; font-size: 14px; min-width: 180px;
    border-left: 3px solid #ffd166;
  }
  #inventory .item { margin: 4px 0; opacity: 0.4; transition: opacity 0.3s; }
  #inventory .item.has { opacity: 1; color: #ffd166; }

  #code-modal {
    position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
    background: rgba(15, 25, 40, 0.97); border: 2px solid #4fd1c5;
    padding: 30px 40px; border-radius: 14px; text-align: center;
    opacity: 0; pointer-events: none; transition: opacity 0.4s;
    box-shadow: 0 0 60px rgba(79, 209, 197, 0.4);
    backdrop-filter: blur(10px);
  }
  #code-modal.show { opacity: 1; pointer-events: auto; }
  #code-modal h3 { margin-bottom: 18px; color: #4fd1c5; letter-spacing: 2px; }
  #code-input {
    background: #0a1520; border: 1px solid #4fd1c5; color: #fff;
    padding: 10px 14px; font-size: 22px; letter-spacing: 8px;
    text-align: center; width: 180px; border-radius: 6px;
    font-family: 'Courier New', monospace;
  }
  #code-input:focus { outline: none; box-shadow: 0 0 15px rgba(79, 209, 197, 0.5); }
  #code-submit {
    margin-top: 16px; background: #4fd1c5; color: #0a1520;
    border: none; padding: 10px 28px; font-size: 15px;
    font-weight: bold; border-radius: 6px; cursor: pointer;
    letter-spacing: 1px; transition: all 0.2s;
  }
  #code-submit:hover { background: #6fe0d5; transform: translateY(-2px); }
  #code-error { color: #ff6b6b; margin-top: 10px; min-height: 20px; font-size: 14px; }

  #final-screen {
    position: absolute; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0); transition: background 3s;
    display: flex; align-items: center; justify-content: center;
    flex-direction: column; opacity: 0; pointer-events: none;
  }
  #final-screen.show { opacity: 1; background: rgba(0, 0, 0, 0.3); }
  #final-screen h1 {
    font-size: 60px; color: #ffd166; letter-spacing: 6px;
    text-shadow: 0 0 30px rgba(255, 209, 102, 0.8);
    animation: glow 2s ease-in-out infinite alternate;
  }
  #final-screen p { font-size: 20px; margin-top: 20px; color: #fff; letter-spacing: 3px; }
  @keyframes glow {
    from { text-shadow: 0 0 20px rgba(255, 209, 102, 0.6); }
    to { text-shadow: 0 0 50px rgba(255, 209, 102, 1), 0 0 80px rgba(255, 100, 100, 0.5); }
  }

  #intro {
    position: absolute; top: 0; left: 0; width: 100%; height: 100%;
    background: #000; z-index: 100; display: flex;
    align-items: center; justify-content: center; flex-direction: column;
    transition: opacity 2s;
  }
  #intro.hide { opacity: 0; pointer-events: none; }
  #intro h1 { font-size: 48px; color: #4fd1c5; letter-spacing: 8px; margin-bottom: 20px; }
  #intro p { font-size: 18px; color: #aaa; letter-spacing: 2px; }
</style>
</head>
<body>
<div id="canvas-container"></div>

<div id="ui">
  <div id="intro">
    <h1>ЗАТЕРЯННАЯ ДОЛИНА</h1>
    <p>Пляж • Загрузка...</p>
  </div>

  <div id="step-indicator">
    <span style="opacity:0.7">Этап:</span>
    <span class="step-dot" data-step="1"></span>
    <span class="step-dot" data-step="2"></span>
    <span class="step-dot" data-step="3"></span>
    <span class="step-dot" data-step="4"></span>
    <span class="step-dot" data-step="5"></span>
  </div>

  <div id="hint"></div>
  <div id="error"></div>

  <div id="inventory">
    <div style="color:#4fd1c5; font-weight:bold; margin-bottom:6px;">🎒 ИНВЕНТАРЬ</div>
    <div class="item" id="inv-note">📜 Записка</div>
    <div class="item" id="inv-code">🔢 Код: 7-3-9</div>
    <div class="item" id="inv-fuel">⛽ Топливо</div>
  </div>

  <div id="code-modal">
    <h3>🔐 КОДОВЫЙ ЗАМОК</h3>
    <div style="font-size:13px; color:#aaa; margin-bottom:14px;">Введите код с балки</div>
    <input id="code-input" type="text" maxlength="5" placeholder="— — —">
    <br>
    <button id="code-submit">ОТКРЫТЬ</button>
    <div id="code-error"></div>
  </div>

  <div id="final-screen">
    <h1>СВОБОДА</h1>
    <p>Вы покинули затерянную долину</p>
  </div>
</div>

<script type="importmap">
{
  "imports": {
    "three": "https://unpkg.com/three@0.160.0/build/three.module.js",
    "three/addons/": "https://unpkg.com/three@0.160.0/examples/jsm/"
  }
}
</script>

<script type="module">
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const container = document.getElementById('canvas-container');
const scene = new THREE.Scene();
scene.fog = new THREE.Fog(0x88aacc, 30, 120);

const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 500);
camera.position.set(0, 25, 60);
camera.lookAt(0, 0, 0);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.1;
container.appendChild(renderer.domElement);

// ГРАДИЕНТНОЕ НЕБО
const skyGeo = new THREE.SphereGeometry(200, 32, 32);
const skyMat = new THREE.ShaderMaterial({
  side: THREE.BackSide,
  uniforms: {
    topColor: { value: new THREE.Color(0x4a90c2) },
    bottomColor: { value: new THREE.Color(0xf5d7a1) },
    offset: { value: 20 },
    exponent: { value: 0.6 }
  },
  vertexShader: `
    varying vec3 vWorldPosition;
    void main() {
      vec4 worldPosition = modelMatrix * vec4(position, 1.0);
      vWorldPosition = worldPosition.xyz;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform vec3 topColor;
    uniform vec3 bottomColor;
    uniform float offset;
    uniform float exponent;
    varying vec3 vWorldPosition;
    void main() {
      float h = normalize(vWorldPosition + offset).y;
      gl_FragColor = vec4(mix(bottomColor, topColor, max(pow(max(h, 0.0), exponent), 0.0)), 1.0);
    }
  `
});
const sky = new THREE.Mesh(skyGeo, skyMat);
scene.add(sky);

// ОСВЕЩЕНИЕ
const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambientLight);

const sunLight = new THREE.DirectionalLight(0xfff0d0, 1.2);
sunLight.position.set(30, 50, 20);
sunLight.castShadow = true;
sunLight.shadow.mapSize.set(2048, 2048);
sunLight.shadow.camera.left = -60;
sunLight.shadow.camera.right = 60;
sunLight.shadow.camera.top = 60;
sunLight.shadow.camera.bottom = -60;
sunLight.shadow.camera.near = 0.5;
sunLight.shadow.camera.far = 150;
sunLight.shadow.bias = -0.001;
scene.add(sunLight);

const hemiLight = new THREE.HemisphereLight(0x88aacc, 0xc2956e, 0.4);
scene.add(hemiLight);

// ПЛЯЖ (песок) - только на берегу
const beachGeo = new THREE.PlaneGeometry(80, 40, 64, 64);
const beachPos = beachGeo.attributes.position;
for (let i = 0; i < beachPos.count; i++) {
  const x = beachPos.getX(i);
  const y = beachPos.getY(i);
  const h = Math.sin(x * 0.1) * 0.3 + Math.cos(y * 0.15) * 0.2 + Math.random() * 0.1;
  beachPos.setZ(i, h);
}
beachGeo.computeVertexNormals();
const beachMat = new THREE.MeshStandardMaterial({
  color: 0xe8c896, roughness: 0.95, metalness: 0.0
});
const beach = new THREE.Mesh(beachGeo, beachMat);
beach.rotation.x = -Math.PI / 2;
beach.position.set(0, 0, 10);
beach.receiveShadow = true;
scene.add(beach);

// ВОДА (море) - ниже пляжа
const waterGeo = new THREE.PlaneGeometry(300, 150, 40, 40);
const waterMat = new THREE.MeshStandardMaterial({
  color: 0x2a6f9e, roughness: 0.2, metalness: 0.6,
  transparent: true, opacity: 0.85
});
const water = new THREE.Mesh(waterGeo, waterMat);
water.rotation.x = -Math.PI / 2;
water.position.set(0, -0.8, -30);
water.receiveShadow = true;
scene.add(water);

// ЛОДКА - на границе воды и песка
const boatGroup = new THREE.Group();
const hullGeo = new THREE.BoxGeometry(4, 1.2, 8);
const hullMat = new THREE.MeshStandardMaterial({ color: 0x8b4513, roughness: 0.7 });
const hull = new THREE.Mesh(hullGeo, hullMat);
hull.position.y = 0.6;
hull.castShadow = true;
hull.receiveShadow = true;
boatGroup.add(hull);

const bowGeo = new THREE.ConeGeometry(2, 3, 4);
const bow = new THREE.Mesh(bowGeo, hullMat);
bow.rotation.x = Math.PI / 2;
bow.rotation.y = Math.PI / 4;
bow.position.set(0, 0.6, 5);
bow.castShadow = true;
boatGroup.add(bow);

const seatGeo = new THREE.BoxGeometry(3.5, 0.2, 1.5);
const seatMat = new THREE.MeshStandardMaterial({ color: 0x5a3a1a });
const seat = new THREE.Mesh(seatGeo, seatMat);
seat.position.set(0, 1.3, 0);
boatGroup.add(seat);

const tankGeo = new THREE.CylinderGeometry(0.4, 0.4, 0.8, 12);
const tankMat = new THREE.MeshStandardMaterial({ color: 0x333333, roughness: 0.5, metalness: 0.6 });
const tank = new THREE.Mesh(tankGeo, tankMat);
tank.position.set(0, 1.5, -2.5);
tank.castShadow = true;
boatGroup.add(tank);

// Лодка на границе воды и песка
boatGroup.position.set(-15, -0.3, -5);
boatGroup.rotation.y = 0.5;
scene.add(boatGroup);

// ВЫШКА
const towerGroup = new THREE.Group();
const towerBaseGeo = new THREE.CylinderGeometry(1.5, 2, 1, 8);
const towerBaseMat = new THREE.MeshStandardMaterial({ color: 0x555555, roughness: 0.8 });
const towerBase = new THREE.Mesh(towerBaseGeo, towerBaseMat);
towerBase.position.y = 0.5;
towerBase.castShadow = true;
towerBase.receiveShadow = true;
towerGroup.add(towerBase);

for (let i = 0; i < 4; i++) {
  const angle = (i / 4) * Math.PI * 2;
  const poleGeo = new THREE.CylinderGeometry(0.15, 0.15, 14, 8);
  const poleMat = new THREE.MeshStandardMaterial({ color: 0x8b2020, roughness: 0.6, metalness: 0.4 });
  const pole = new THREE.Mesh(poleGeo, poleMat);
  pole.position.set(Math.cos(angle) * 1.2, 8, Math.sin(angle) * 1.2);
  pole.castShadow = true;
  towerGroup.add(pole);
}

for (let h = 3; h <= 13; h += 2.5) {
  const crossGeo = new THREE.BoxGeometry(3, 0.1, 0.1);
  const crossMat = new THREE.MeshStandardMaterial({ color: 0x8b2020 });
  const cross1 = new THREE.Mesh(crossGeo, crossMat);
  cross1.position.y = h;
  towerGroup.add(cross1);
  const cross2 = cross1.clone();
  cross2.rotation.y = Math.PI / 2;
  towerGroup.add(cross2);
}

const beamGeo = new THREE.BoxGeometry(3, 0.4, 0.4);
const beamMat = new THREE.MeshStandardMaterial({ color: 0x6b4423, roughness: 0.8 });
const beam = new THREE.Mesh(beamGeo, beamMat);
beam.position.set(0, 5, 1.5);
beam.castShadow = true;
towerGroup.add(beam);

const antennaGeo = new THREE.CylinderGeometry(0.05, 0.05, 3, 8);
const antennaMat = new THREE.MeshStandardMaterial({ color: 0xaaaaaa, metalness: 0.8 });
const antenna = new THREE.Mesh(antennaGeo, antennaMat);
antenna.position.y = 16.5;
towerGroup.add(antenna);

const dishGeo = new THREE.SphereGeometry(0.8, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2);
const dishMat = new THREE.MeshStandardMaterial({ color: 0xcccccc, metalness: 0.7, side: THREE.DoubleSide });
const dish = new THREE.Mesh(dishGeo, dishMat);
dish.position.set(0, 14, 0);
dish.rotation.x = Math.PI;
towerGroup.add(dish);

towerGroup.position.set(18, 0, 15);
scene.add(towerGroup);

// ЛЕС
const forestGroup = new THREE.Group();
function createTree(x, z, scale = 1) {
  const tree = new THREE.Group();
  const trunkGeo = new THREE.CylinderGeometry(0.3 * scale, 0.5 * scale, 3 * scale, 8);
  const trunkMat = new THREE.MeshStandardMaterial({ color: 0x4a2f1a, roughness: 0.9 });
  const trunk = new THREE.Mesh(trunkGeo, trunkMat);
  trunk.position.y = 1.5 * scale;
  trunk.castShadow = true;
  tree.add(trunk);
  for (let i = 0; i < 3; i++) {
    const leavesGeo = new THREE.ConeGeometry((1.8 - i * 0.4) * scale, (2.5 - i * 0.3) * scale, 8);
    const leavesMat = new THREE.MeshStandardMaterial({
      color: new THREE.Color().setHSL(0.28 + Math.random() * 0.05, 0.5, 0.25 + Math.random() * 0.1),
      roughness: 0.9
    });
    const leaves = new THREE.Mesh(leavesGeo, leavesMat);
    leaves.position.y = (3 + i * 1.5) * scale;
    leaves.castShadow = true;
    tree.add(leaves);
  }
  tree.position.set(x, 0, z);
  return tree;
}
for (let i = 0; i < 60; i++) {
  const x = (Math.random() - 0.5) * 100;
  const z = 25 + Math.random() * 30;
  const scale = 0.8 + Math.random() * 0.7;
  forestGroup.add(createTree(x, z, scale));
}
for (let i = 0; i < 30; i++) {
  const side = Math.random() > 0.5 ? 1 : -1;
  const x = side * (35 + Math.random() * 20);
  const z = (Math.random() - 0.5) * 60;
  const scale = 0.8 + Math.random() * 0.7;
  forestGroup.add(createTree(x, z, scale));
}
scene.add(forestGroup);

// ИНТЕРАКТИВНЫЕ ОБЪЕКТЫ
const interactiveObjects = [];

// Записка №1 ВНУТРИ лодки (на сиденье)
const note1Geo = new THREE.PlaneGeometry(1.2, 0.9);
const note1Mat = new THREE.MeshStandardMaterial({
  color: 0xf5e6c8, roughness: 0.9, side: THREE.DoubleSide,
  emissive: 0x000000
});
const note1 = new THREE.Mesh(note1Geo, note1Mat);
note1.position.set(0, 1.45, 0);
note1.rotation.x = -Math.PI / 2;
note1.rotation.z = 0.2;
note1.castShadow = true;
note1.userData = { type: 'note1', originalEmissive: 0x000000 };
boatGroup.add(note1);
interactiveObjects.push(note1);

// Коробка с запиской №2 у вышки
const crateGeo = new THREE.BoxGeometry(1.5, 1.2, 1.5);
const crateMat = new THREE.MeshStandardMaterial({
  color: 0x8b5a2b, roughness: 0.85, emissive: 0x000000
});
const crate = new THREE.Mesh(crateGeo, crateMat);
crate.position.set(18, 0.6, 13);
crate.castShadow = true;
crate.receiveShadow = true;
crate.userData = { type: 'note2', originalEmissive: 0x000000 };
scene.add(crate);
interactiveObjects.push(crate);

// Сундук с кодовым замком
const chestGroup = new THREE.Group();
const chestBaseGeo = new THREE.BoxGeometry(1.8, 1, 1.2);
const chestMat = new THREE.MeshStandardMaterial({
  color: 0x6b3410, roughness: 0.7, emissive: 0x000000
});
const chestBase = new THREE.Mesh(chestBaseGeo, chestMat);
chestBase.position.y = 0.5;
chestBase.castShadow = true;
chestGroup.add(chestBase);

const chestLidGeo = new THREE.BoxGeometry(1.8, 0.4, 1.2);
const chestLid = new THREE.Mesh(chestLidGeo, chestMat);
chestLid.position.set(0, 1.2, 0);
chestLid.castShadow = true;
chestGroup.add(chestLid);

const bandMat = new THREE.MeshStandardMaterial({ color: 0x3a3a3a, metalness: 0.8, roughness: 0.4 });
for (let i = -1; i <= 1; i++) {
  const bandGeo = new THREE.BoxGeometry(0.1, 1.05, 1.25);
  const band = new THREE.Mesh(bandGeo, bandMat);
  band.position.set(i * 0.7, 0.5, 0);
  chestGroup.add(band);
}

const lockGeo = new THREE.BoxGeometry(0.3, 0.4, 0.1);
const lockMat = new THREE.MeshStandardMaterial({ color: 0xffd700, metalness: 0.9, roughness: 0.2 });
const lock = new THREE.Mesh(lockGeo, lockMat);
lock.position.set(0, 1, 0.65);
chestGroup.add(lock);

chestGroup.position.set(20, 0, 17);
scene.add(chestGroup);
chestGroup.userData = { type: 'chest', originalEmissive: 0x000000 };
interactiveObjects.push(chestGroup);

// Канистра с топливом
const canisterGeo = new THREE.CylinderGeometry(0.3, 0.3, 0.8, 12);
const canisterMat = new THREE.MeshStandardMaterial({
  color: 0xcc2222, roughness: 0.5, metalness: 0.3, emissive: 0x000000
});
const canister = new THREE.Mesh(canisterGeo, canisterMat);
canister.position.set(20, 1.4, 17);
canister.visible = false;
canister.userData = { type: 'canister', originalEmissive: 0x000000 };
scene.add(canister);
interactiveObjects.push(canister);

// Лодка как интерактивный объект
boatGroup.userData = { type: 'boat', originalEmissive: 0x000000 };
interactiveObjects.push(boatGroup);

// RAYCASTER
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();
let hoveredObject = null;

const allInteractiveMeshes = [];
interactiveObjects.forEach(obj => {
  if (obj.isMesh) allInteractiveMeshes.push(obj);
  else obj.traverse(child => { if (child.isMesh) allInteractiveMeshes.push(child); });
});

function findInteractiveParent(mesh) {
  let current = mesh;
  while (current) {
    if (interactiveObjects.includes(current)) return current;
    current = current.parent;
  }
  return null;
}

window.addEventListener('mousemove', (e) => {
  mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
  mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;
});

// СОСТОЯНИЕ ИГРЫ
const gameState = {
  currentStep: 0,
  note1Read: false,
  note2Read: false,
  chestOpened: false,
  fuelCollected: false,
  escaped: false,
  stormActive: false
};

// UI
const hintEl = document.getElementById('hint');
const errorEl = document.getElementById('error');
const codeModal = document.getElementById('code-modal');
const codeInput = document.getElementById('code-input');
const codeSubmit = document.getElementById('code-submit');
const codeError = document.getElementById('code-error');
const finalScreen = document.getElementById('final-screen');
const introEl = document.getElementById('intro');

function showHint(text, duration = 5000) {
  hintEl.innerHTML = text;
  hintEl.classList.add('show');
  setTimeout(() => hintEl.classList.remove('show'), duration);
}

function showError(text, duration = 3000) {
  errorEl.textContent = '⚠ ' + text;
  errorEl.classList.add('show');
  setTimeout(() => errorEl.classList.remove('show'), duration);
}

function updateStepIndicator() {
  document.querySelectorAll('.step-dot').forEach(dot => {
    const step = parseInt(dot.dataset.step);
    dot.classList.remove('done', 'active');
    if (step < gameState.currentStep) dot.classList.add('done');
    else if (step === gameState.currentStep) dot.classList.add('active');
  });
}

function updateInventory() {
  document.getElementById('inv-note').classList.toggle('has', gameState.note1Read);
  document.getElementById('inv-code').classList.toggle('has', gameState.note2Read);
  document.getElementById('inv-fuel').classList.toggle('has', gameState.fuelCollected);
}

// ГРОЗА
const rainParticles = [];
const rainGeo = new THREE.BufferGeometry();
const rainCount = 2000;
const rainPositions = new Float32Array(rainCount * 3);
for (let i = 0; i < rainCount; i++) {
  rainPositions[i * 3] = (Math.random() - 0.5) * 100;
  rainPositions[i * 3 + 1] = Math.random() * 40;
  rainPositions[i * 3 + 2] = (Math.random() - 0.5) * 100;
}
rainGeo.setAttribute('position', new THREE.BufferAttribute(rainPositions, 3));
const rainMat = new THREE.PointsMaterial({
  color: 0xaaccff, size: 0.15, transparent: true, opacity: 0
});
const rain = new THREE.Points(rainGeo, rainMat);
scene.add(rain);

let lightningLight = null;
let nextLightning = 0;

function activateStorm() {
  gameState.stormActive = true;
  skyMat.uniforms.topColor.value.set(0x1a1a2e);
  skyMat.uniforms.bottomColor.value.set(0x2d2d3f);
  scene.fog.color.set(0x1a1a2e);
  scene.fog.near = 15;
  scene.fog.far = 60;
  sunLight.intensity = 0.3;
  sunLight.color.set(0x6677aa);
  ambientLight.intensity = 0.25;
  hemiLight.intensity = 0.15;
  lightningLight = new THREE.PointLight(0xffffff, 0, 100);
  lightningLight.position.set(0, 30, 0);
  scene.add(lightningLight);
  rainMat.opacity = 0.6;
}

// САЛЮТ
const fireworks = [];
function createFirework() {
  const particleCount = 80;
  const geo = new THREE.BufferGeometry();
  const positions = new Float32Array(particleCount * 3);
  const velocities = [];
  const colors = new Float32Array(particleCount * 3);
  const color = new THREE.Color().setHSL(Math.random(), 1, 0.6);
  for (let i = 0; i < particleCount; i++) {
    positions[i * 3] = 0;
    positions[i * 3 + 1] = 0;
    positions[i * 3 + 2] = 0;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.random() * Math.PI;
    const speed = 0.3 + Math.random() * 0.4;
    velocities.push(new THREE.Vector3(
      Math.sin(phi) * Math.cos(theta) * speed,
      Math.sin(phi) * Math.sin(theta) * speed,
      Math.cos(phi) * speed
    ));
    colors[i * 3] = color.r;
    colors[i * 3 + 1] = color.g;
    colors[i * 3 + 2] = color.b;
  }
  geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  geo.setAttribute('color', new THREE.BufferAttribute(colors, 3));
  const mat = new THREE.PointsMaterial({
    size: 0.3, vertexColors: true, transparent: true, opacity: 1,
    blending: THREE.AdditiveBlending, depthWrite: false
  });
  const points = new THREE.Points(geo, mat);
  const startX = (Math.random() - 0.5) * 40;
  const startY = 15 + Math.random() * 10;
  const startZ = (Math.random() - 0.5) * 40;
  points.position.set(startX, startY, startZ);
  scene.add(points);
  fireworks.push({ points, velocities, life: 0, maxLife: 120 });
}

// ЛОГИКА ДЕЙСТВИЙ
function handleAction(object) {
  const type = object.userData.type;

  if (type === 'note1') {
    if (gameState.currentStep > 1) {
      showHint('📜 Вы уже прочитали эту записку.');
      return;
    }
    if (gameState.currentStep !== 0) {
      showError('Сначала выполните предыдущее действие');
      return;
    }
    gameState.currentStep = 1;
    gameState.note1Read = true;
    updateStepIndicator();
    updateInventory();
    showHint('📜 <b>ЗАПИСКА:</b> "Топливо на вышке связи. Ищи у основания."', 6000);
    setTimeout(() => {
      showHint('➡ Идите к <b>вышке связи</b> на холме', 5000);
    }, 6500);
    return;
  }

  if (type === 'note2') {
    if (gameState.currentStep < 1) {
      showError('Ошибка: Сначала прочитайте записку в лодке');
      return;
    }
    if (gameState.currentStep > 2) {
      showHint('📜 Вы уже нашли эту подсказку.');
      return;
    }
    gameState.currentStep = 2;
    gameState.note2Read = true;
    updateStepIndicator();
    updateInventory();
    showHint('📜 <b>ЗАПИСКА №2:</b> "Сундук под настилом. Код выбит на балке сверху."', 6000);
    setTimeout(() => {
      showHint('🔍 Найдите <b>балку</b> на вышке — там код. Затем откройте <b>сундук</b>.', 6000);
    }, 6500);
    return;
  }

  if (type === 'chest') {
    if (gameState.currentStep < 2) {
      showError('Ошибка: Сначала найдите подсказку в коробке');
      return;
    }
    if (gameState.chestOpened) {
      showHint('📦 Сундук уже открыт.');
      return;
    }
    codeModal.classList.add('show');
    codeInput.value = '';
    codeError.textContent = '';
    setTimeout(() => codeInput.focus(), 100);
    return;
  }

  if (type === 'canister') {
    if (!gameState.chestOpened) {
      showError('Сначала откройте сундук');
      return;
    }
    if (gameState.fuelCollected) {
      showHint('⛽ Топливо уже в инвентаре. Возвращайтесь к лодке.');
      return;
    }
    gameState.currentStep = 4;
    gameState.fuelCollected = true;
    updateStepIndicator();
    updateInventory();
    canister.visible = false;
    showHint('⛽ <b>Топливо получено!</b> Возвращайтесь к лодке и заправьте её.', 6000);
    return;
  }

  if (type === 'boat') {
    if (!gameState.fuelCollected) {
      showError('Ошибка: Сначала найдите топливо');
      return;
    }
    if (gameState.escaped) return;
    gameState.currentStep = 5;
    gameState.escaped = true;
    updateStepIndicator();
    triggerEscape();
    return;
  }
}

// ВВОД КОДА
codeSubmit.addEventListener('click', () => {
  const code = codeInput.value.trim().replace(/\s+/g, '');
  if (code === '739' || code === '7-3-9') {
    codeModal.classList.remove('show');
    gameState.chestOpened = true;
    gameState.currentStep = 3;
    updateStepIndicator();
    animateChestOpen();
    setTimeout(() => {
      canister.visible = true;
      showHint('💥 <b>ГРОЗА!</b> Небо потемнело. Заберите топливо из сундука.', 6000);
    }, 1500);
  } else {
    codeError.textContent = '❌ Неверный код. Попробуйте снова.';
    codeInput.value = '';
    codeInput.focus();
  }
});

codeInput.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') codeSubmit.click();
});

function animateChestOpen() {
  const startTime = performance.now();
  const duration = 1200;
  function anim(time) {
    const t = Math.min((time - startTime) / duration, 1);
    const ease = 1 - Math.pow(1 - t, 3);
    chestLid.rotation.x = -ease * 1.5;
    chestLid.position.y = 1.2 + ease * 0.3;
    chestLid.position.z = -ease * 0.5;
    if (t < 1) requestAnimationFrame(anim);
    else {
      activateStorm();
    }
  }
  requestAnimationFrame(anim);
}

// ФИНАЛ
let escapePhase = 0;
let escapeStartTime = 0;
const boatStartPos = boatGroup.position.clone();

function triggerEscape() {
  showHint('⛽ Заправка... Мотор заведён! Вы уплываете!', 4000);
  escapePhase = 1;
  escapeStartTime = performance.now();
}

// КИНЕМАТОГРАФИЧНЫЙ ПОДЛЁТ
let introPhase = true;
let introStartTime = performance.now();
const cameraStart = new THREE.Vector3(0, 40, 80);
const cameraEnd = new THREE.Vector3(-10, 8, 10);
const lookTarget = new THREE.Vector3(0, 2, 0);

// ORBIT CONTROLS
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.08;
controls.minDistance = 8;
controls.maxDistance = 80;
controls.maxPolarAngle = Math.PI / 2.1;
controls.target.set(0, 2, 0);
controls.enabled = false;

// КЛИК
window.addEventListener('click', (e) => {
  if (codeModal.classList.contains('show')) return;
  if (hoveredObject) {
    handleAction(hoveredObject);
  }
});

// РЕСАЙЗ
window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

// АНИМАЦИЯ
const clock = new THREE.Clock();

function animate() {
  requestAnimationFrame(animate);
  const delta = clock.getDelta();
  const elapsed = clock.getElapsedTime();

  if (introPhase) {
    const t = Math.min((performance.now() - introStartTime) / 4000, 1);
    const ease = t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
    camera.position.lerpVectors(cameraStart, cameraEnd, ease);
    camera.lookAt(lookTarget);
    if (t >= 1) {
      introPhase = false;
      controls.enabled = true;
      introEl.classList.add('hide');
      setTimeout(() => {
        showHint('👋 Подойдите к <b>лодке</b> и кликните по <b>записке</b> внутри неё.', 6000);
        gameState.currentStep = 0;
        updateStepIndicator();
      }, 1500);
    }
  } else {
    controls.update();
  }

  const waterPos = waterGeo.attributes.position;
  for (let i = 0; i < waterPos.count; i++) {
    const x = waterPos.getX(i);
    const y = waterPos.getY(i);
    const wave = Math.sin(x * 0.3 + elapsed * 1.5) * 0.3 + Math.cos(y * 0.2 + elapsed) * 0.2;
    waterPos.setZ(i, wave);
  }
  waterPos.needsUpdate = true;
  waterGeo.computeVertexNormals();

  if (!introPhase) {
    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(allInteractiveMeshes, false);
    let newHovered = null;
    if (intersects.length > 0) {
      const parent = findInteractiveParent(intersects[0].object);
      if (parent && parent.visible !== false) {
        if (parent.userData.type === 'canister' && !parent.visible) {
          newHovered = null;
        } else {
          newHovered = parent;
        }
      }
    }

    if (newHovered !== hoveredObject) {
      if (hoveredObject) {
        setEmissive(hoveredObject, hoveredObject.userData.originalEmissive || 0x000000);
      }
      hoveredObject = newHovered;
      if (hoveredObject) {
        setEmissive(hoveredObject, 0xffaa33);
        document.body.style.cursor = 'pointer';
      } else {
        document.body.style.cursor = 'default';
      }
    }
  }

  if (gameState.stormActive) {
    const positions = rainGeo.attributes.position;
    for (let i = 0; i < rainCount; i++) {
      let y = positions.getY(i);
      y -= 0.8;
      if (y < 0) {
        y = 40;
        positions.setX(i, (Math.random() - 0.5) * 100);
        positions.setZ(i, (Math.random() - 0.5) * 100);
      }
      positions.setY(i, y);
    }
    positions.needsUpdate = true;

    if (lightningLight && elapsed > nextLightning) {
      lightningLight.intensity = 3;
      lightningLight.position.set((Math.random() - 0.5) * 60, 30, (Math.random() - 0.5) * 60);
      nextLightning = elapsed + 3 + Math.random() * 5;
      setTimeout(() => { if (lightningLight) lightningLight.intensity = 0; }, 120);
    }
  }

  if (escapePhase === 3) {
    if (Math.random() < 0.08) createFirework();
    for (let i = fireworks.length - 1; i >= 0; i--) {
      const fw = fireworks[i];
      fw.life++;
      const pos = fw.points.geometry.attributes.position;
      for (let j = 0; j < fw.velocities.length; j++) {
        pos.array[j * 3] += fw.velocities[j].x;
        pos.array[j * 3 + 1] += fw.velocities[j].y - 0.01;
        pos.array[j * 3 + 2] += fw.velocities[j].z;
        fw.velocities[j].y -= 0.008;
      }
      pos.needsUpdate = true;
      fw.points.material.opacity = Math.max(0, 1 - fw.life / fw.maxLife);
      if (fw.life > fw.maxLife) {
        scene.remove(fw.points);
        fw.points.geometry.dispose();
        fw.points.material.dispose();
        fireworks.splice(i, 1);
      }
    }
  }

  if (escapePhase === 1) {
    const t = Math.min((performance.now() - escapeStartTime) / 3000, 1);
    const targetCamPos = new THREE.Vector3(boatGroup.position.x + 5, 4, boatGroup.position.z + 8);
    camera.position.lerp(targetCamPos, 0.02);
    controls.target.lerp(boatGroup.position, 0.02);
    if (t >= 1) {
      escapePhase = 2;
      escapeStartTime = performance.now();
    }
  } else if (escapePhase === 2) {
    const t = Math.min((performance.now() - escapeStartTime) / 6000, 1);
    boatGroup.position.z = boatStartPos.z - t * 80;
    boatGroup.position.x = boatStartPos.x - t * 20;
    boatGroup.rotation.y += 0.002;
    camera.position.lerp(new THREE.Vector3(boatGroup.position.x + 5, 6, boatGroup.position.z + 10), 0.03);
    controls.target.lerp(boatGroup.position, 0.05);
    if (t >= 1) {
      escapePhase = 3;
      finalScreen.classList.add('show');
      skyMat.uniforms.topColor.value.set(0x2a1a4a);
      skyMat.uniforms.bottomColor.value.set(0xff8855);
      sunLight.color.set(0xff9966);
      sunLight.intensity = 0.8;
      ambientLight.color.set(0xffaa88);
      scene.fog.color.set(0x443355);
    }
  }

  if (!gameState.escaped) {
    boatGroup.rotation.z = Math.sin(elapsed * 0.8) * 0.03;
    boatGroup.position.y = -0.3 + Math.sin(elapsed * 1.2) * 0.05;
  }

  note1.rotation.z = 0.2 + Math.sin(elapsed * 0.5) * 0.05;

  renderer.render(scene, camera);
}

function setEmissive(obj, color) {
  obj.traverse(child => {
    if (child.isMesh && child.material && child.material.emissive) {
      child.material.emissive.set(color);
    }
  });
}

animate();
</script>
</body>
</html>
