particleCloud = undefined
attributes = undefined
group = undefined
renderer = undefined
composer = undefined
init = ->

  newpos = (x, y, z) ->
    new THREE.Vector3(x, y, z)


  generateSprite = ->
    canvas = document.createElement("canvas")
    canvas.width = 128
    canvas.height = 128
    context = canvas.getContext("2d")

    context.beginPath()
    context.arc 64, 64, 60, 0, Math.PI * 2, false
    context.lineWidth = 0.5 #0.05
    context.stroke()
    context.restore()
    gradient = context.createRadialGradient(canvas.width / 2, canvas.height / 2, 0, canvas.width / 2, canvas.height / 2, canvas.width / 2)
    gradient.addColorStop 0, "rgba(255,255,255,1)"
    gradient.addColorStop 0.2, "rgba(255,255,255,1)"
    gradient.addColorStop 0.4, "rgba(200,200,200,1)"
    gradient.addColorStop 1, "rgba(0,0,0,1)"
    context.fillStyle = gradient
    context.fill()
    canvas
  container = document.createElement("div")
  document.body.appendChild container
  camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 1, 2000)
  camera.position.set 0, 150, 400
  scene = new THREE.Scene()
  directionalLight = new THREE.DirectionalLight(0xffffff, 0.5)
  directionalLight.position.set 0, -1, 1
  directionalLight.position.normalize()
  scene.add directionalLight
  pointLight = new THREE.PointLight(0xffffff, 2, 300)
  pointLight.position.set 0, 0, 0
  scene.add pointLight
  theText = "HANDSOME"
  hash = document.location.hash.substr(1)
  theText = hash  if hash.length isnt 0
  material = new THREE.MeshFaceMaterial([new THREE.MeshLambertMaterial(
    color: 0xffffff
    shading: THREE.FlatShading
    opacity: 0.95
  ), new THREE.MeshLambertMaterial(color: 0xffffff)])
  text3d = new THREE.TextGeometry(theText,
    size: 70
    height: 25
    curveSegments: 4
    font: "helvetiker"
    bevelEnabled: true
    bevelThickness: 2
    bevelSize: 2
    material: 0
    extrudeMaterial: 1
  )
  text3d.computeVertexNormals()
  text3d.computeBoundingBox()
  centerOffset = -0.5 * (text3d.boundingBox.max.x - text3d.boundingBox.min.x)
  text = new THREE.Mesh(text3d, material)
  text.position.x = centerOffset
  text.position.y = 130
  text.position.z = -50
  text.rotation.x = 0
  text.rotation.y = Math.PI * 2
  group = new THREE.Object3D()
  scene.add group
  particlesLength = 70000
  particles = new THREE.Geometry()
  Pool =
    __pools: []
    get: ->
      return @__pools.pop()  if @__pools.length > 0
      console.log "pool ran out!"
      null

    add: (v) ->
      @__pools.push v

  i = 0
  while i < particlesLength
    particles.vertices.push newpos(Math.random() * 200 - 100, Math.random() * 100 + 150, Math.random() * 50)
    Pool.add i
    i++
  attributes =
    size:
      type: "f"
      value: []

    pcolor:
      type: "c"
      value: []

  sprite = generateSprite()
  texture = new THREE.Texture(sprite)
  texture.needsUpdate = true
  uniforms = texture:
    type: "t"
    value: texture

  shaderMaterial = new THREE.ShaderMaterial(
    uniforms: uniforms
    attributes: attributes
    vertexShader: document.getElementById("vertexshader").textContent
    fragmentShader: document.getElementById("fragmentshader").textContent
    blending: THREE.AdditiveBlending
    depthWrite: false
    transparent: true
  )
  particleCloud = new THREE.ParticleSystem(particles, shaderMaterial)
  particleCloud.dynamic = true

  # particleCloud.sortParticles = true;
  vertices = particleCloud.geometry.vertices
  values_size = attributes.size.value
  values_color = attributes.pcolor.value
  v = 0

  while v < vertices.length
    values_size[v] = 50
    values_color[v] = new THREE.Color(0x000000)
    particles.vertices[v].set Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY
    v++
  group.add particleCloud
  particleCloud.y = 800

  # Create Particle Systems

  # EMITTER STUFF

  # Heart
  x = 0
  y = 0
  shapePoints = []
  logoPointsArray = [[0, 0], [98, 89], [98, 0], [0, 89], [0, 0]]

  #  heartShape.moveTo( x + 25, y + 25 );
  #  heartShape.bezierCurveTo( x + 25, y + 25, x + 20, y, x, y );
  #  heartShape.bezierCurveTo( x - 30, y, x - 30, y + 35,x - 30,y + 35 );
  #  heartShape.bezierCurveTo( x - 30, y + 55, x - 10, y + 77, x + 25, y + 95 );
  #  heartShape.bezierCurveTo( x + 60, y + 77, x + 80, y + 55, x + 80, y + 35 );
  #  heartShape.bezierCurveTo( x + 80, y + 35, x + 80, y, x + 50, y );
  #  heartShape.bezierCurveTo( x + 35, y, x + 25, y + 25, x + 25, y + 25 );
  $.each logoPointsArray, ->
    shapePoints.push new THREE.Vector2(this[0], this[1])

  heartShape = new THREE.Shape(shapePoints)
  hue = 0
  setTargetParticle = ->
    target = Pool.get()
    values_size[target] = Math.random() * 200 + 100
    target

  onParticleCreated = (p) ->
    position = p.position
    p.target.position = position
    target = p.target
    if target

      # console.log(target,particles.vertices[target]);
      # values_size[target]
      # values_color[target]
      hue += 0.0003 * delta
      hue -= 1  if hue > 1

      # TODO Create a PointOnShape Action/Zone in the particle engine
      timeOnShapePath += 0.00035 * delta
      timeOnShapePath -= 1  if timeOnShapePath > 1
      pointOnShape = heartShape.getPointAt(timeOnShapePath)
      emitterpos.x = pointOnShape.x * 5 - 250
      emitterpos.y = -pointOnShape.y * 5 + 400

      # pointLight.position.copy( emitterpos );
      pointLight.position.x = emitterpos.x
      pointLight.position.y = emitterpos.y
      pointLight.position.z = 100
      particles.vertices[target] = p.position
      values_color[target].setHSL hue, 0.6, 0.1
      pointLight.color.setHSL hue, 0.8, 0.5

  i = 0
  onParticleDead = (particle) ->
    target = particle.target
    if target
      if i is 0
        console.log particles
        i++

      # Hide the particle
      values_color[target].setRGB 0, 0, 0
      particles.vertices[target].set Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY

      # Mark particle system as available by returning to pool
      Pool.add particle.target

  engineLoopUpdate = ->

  sparksEmitter = new SPARKS.Emitter(new SPARKS.SteadyCounter(500))
  emitterpos = new THREE.Vector3(0, 0, 0)
  sparksEmitter.addInitializer new SPARKS.Position(new SPARKS.PointZone(emitterpos))
  sparksEmitter.addInitializer new SPARKS.Lifetime(1, 15)
  sparksEmitter.addInitializer new SPARKS.Target(null, setTargetParticle)
  sparksEmitter.addInitializer new SPARKS.Velocity(new SPARKS.PointZone(new THREE.Vector3(0, -5, 1)))

  # TOTRY Set velocity to move away from centroid
  sparksEmitter.addAction new SPARKS.Age()
  sparksEmitter.addAction new SPARKS.Accelerate(0, 0, -50)
  sparksEmitter.addAction new SPARKS.Move()
  sparksEmitter.addAction new SPARKS.RandomDrift(90, 100, 2000)
  sparksEmitter.addCallback "created", onParticleCreated
  sparksEmitter.addCallback "dead", onParticleDead
  sparksEmitter.start()

  # End Particles
  renderer = new THREE.WebGLRenderer()
  renderer.setSize window.innerWidth, window.innerHeight
  container.appendChild renderer.domElement

  # POST PROCESSING
  effectFocus = new THREE.ShaderPass(THREE.FocusShader)
  effectCopy = new THREE.ShaderPass(THREE.CopyShader)
  effectFilm = new THREE.FilmPass(0.5, 0.25, 2048, false)
  shaderBlur = THREE.TriangleBlurShader
  effectBlurX = new THREE.ShaderPass(shaderBlur, "texture")
  effectBlurY = new THREE.ShaderPass(shaderBlur, "texture")
  radius = 15
  blurAmountX = radius / window.innerWidth
  blurAmountY = radius / window.innerHeight
  hblur = new THREE.ShaderPass(THREE.HorizontalBlurShader)
  vblur = new THREE.ShaderPass(THREE.VerticalBlurShader)
  hblur.uniforms["h"].value = 1 / window.innerWidth
  vblur.uniforms["v"].value = 1 / window.innerHeight
  effectBlurX.uniforms["delta"].value = new THREE.Vector2(blurAmountX, 0)
  effectBlurY.uniforms["delta"].value = new THREE.Vector2(0, blurAmountY)
  effectFocus.uniforms["sampleDistance"].value = 0.99 #0.94
  effectFocus.uniforms["waveFactor"].value = 0.003 #0.00125
  renderScene = new THREE.RenderPass(scene, camera)
  composer = new THREE.EffectComposer(renderer)
  composer.addPass renderScene
  composer.addPass hblur
  composer.addPass vblur

  # composer.addPass( effectBlurX );
  # composer.addPass( effectBlurY );
  # composer.addPass( effectCopy );
  # composer.addPass( effectFocus );
  # composer.addPass( effectFilm );
  vblur.renderToScreen = true
  effectBlurY.renderToScreen = true
  effectFocus.renderToScreen = true
  effectCopy.renderToScreen = true
  effectFilm.renderToScreen = true
  document.addEventListener "mousedown", onDocumentMouseDown, false
  document.addEventListener "touchstart", onDocumentTouchStart, false
  document.addEventListener "touchmove", onDocumentTouchMove, false

  #
  window.addEventListener "resize", onWindowResize, false
onWindowResize = ->
  windowHalfX = window.innerWidth / 2
  windowHalfY = window.innerHeight / 2
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize window.innerWidth, window.innerHeight

  #
  hblur.uniforms["h"].value = 1 / window.innerWidth
  vblur.uniforms["v"].value = 1 / window.innerHeight
  radius = 15
  blurAmountX = radius / window.innerWidth
  blurAmountY = radius / window.innerHeight
  effectBlurX.uniforms["delta"].value = new THREE.Vector2(blurAmountX, 0)
  effectBlurY.uniforms["delta"].value = new THREE.Vector2(0, blurAmountY)
  composer.reset()

#

#document.addEventListener( 'mousemove', onDocumentMouseMove, false );
onDocumentMouseDown = (event) ->
  event.preventDefault()
  mouseXOnMouseDown = event.clientX - windowHalfX
  targetRotationOnMouseDown = targetRotation
  if sparksEmitter.isRunning()
    sparksEmitter.stop()
  else
    sparksEmitter.start()
onDocumentMouseMove = (event) ->
  mouseX = event.clientX - windowHalfX
  targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.02
onDocumentTouchStart = (event) ->
  if event.touches.length is 1
    event.preventDefault()
    mouseXOnMouseDown = event.touches[0].pageX - windowHalfX
    targetRotationOnMouseDown = targetRotation
onDocumentTouchMove = (event) ->
  if event.touches.length is 1
    event.preventDefault()
    mouseX = event.touches[0].pageX - windowHalfX
    targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.05
animate = ->
  requestAnimationFrame animate
  render()
render = ->
  delta = speed * clock.getDelta()
  particleCloud.geometry.verticesNeedUpdate = true
  attributes.size.needsUpdate = true
  attributes.pcolor.needsUpdate = true

  # Pretty cool effect if you enable this
  # particleCloud.rotation.y += 0.05;
  group.rotation.y += (targetRotation - group.rotation.y) * 0.05
  renderer.clear()

  # renderer.render( scene, camera );
  composer.render 0.1
container = undefined
camera = undefined
scene = undefined
renderer = undefined
group = undefined
text = undefined
plane = undefined
speed = 50
pointLight = undefined
targetRotation = 0
targetRotationOnMouseDown = 0
mouseX = 0
mouseXOnMouseDown = 0
windowHalfX = window.innerWidth / 2
windowHalfY = window.innerHeight / 2
delta = 1
clock = new THREE.Clock()
heartShape = undefined
particleCloud = undefined
sparksEmitter = undefined
emitterPos = undefined
_rotation = 0
timeOnShapePath = 0
composer = undefined
effectBlurX = undefined
effectBlurY = undefined
hblur = undefined
vblur = undefined
init()
animate()