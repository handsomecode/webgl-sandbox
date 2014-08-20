class window.Intro
  SCREEN_WIDTH: window.innerWidth
  SCREEN_HEIGHT: window.innerHeight
  FAR: 20000
  speed: 50
  text: "HANDSOME"
  clock: new THREE.Clock()
  keyboard: new THREEx.KeyboardState()
  targetRotation: 0
  controls: undefined
  renderer: undefined
  scene: undefined
  camera: undefined
  directionalLight: undefined
  pointLight: undefined
  material: undefined
  text3d: undefined
#  logoPointsArray: [
#    [0,0]
#    [49,38]
#    [98,0]
#    [98,89]
#    [49,50]
#    [0,89]
#  ]
  logoPointsArray: [
    [0,0]
    [49,38]
    [98,0]
    [98,89]
    [49,50]
    [0,89]
  ]
  _createAxis: -> #ok
    axis = new THREE.AxisHelper(100);
    @scene.add(axis);
  #end _createAxes

  _createControls: -> #ok
    self = @
    # CONTROLS
    self.controls = new THREE.OrbitControls(self.camera, self.renderer.domElement)
  #end _createControls

  _createRenderer: ->
    self = @
    if Modernizr.webgl
      self.renderer = new THREE.WebGLRenderer(antialias: true)
    else
      self.renderer = new THREE.CanvasRenderer()
    self.renderer.setSize self.SCREEN_WIDTH, self.SCREEN_HEIGHT
    self.renderer.setClearColor(0x000000)
    container = document.getElementById("ThreeJS")
    container.appendChild(self.renderer.domElement)

    # EVENTS
    THREEx.WindowResize(self.renderer, self.camera)
    THREEx.FullScreen.bindKey(charCode: "m".charCodeAt(0))
    self = @
  #end _createRenderer

  _createScene: ->
    self = @
    self.scene = new THREE.Scene()
  #end _createScene

  _createCamera: ->
    self = @
    ASPECT = self.SCREEN_WIDTH / self.SCREEN_HEIGHT
    SCREEN_WIDTH = self.SCREEN_WIDTH
    SCREEN_HEIGHT = self.SCREEN_HEIGHT
    self.camera = new THREE.PerspectiveCamera( 70, ASPECT, 1, 2000 )
    #self.camera = new THREE.OrthographicCamera( 0.5 * SCREEN_WIDTH / - 2, 0.5 * SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, SCREEN_HEIGHT / - 2, 150, 1000 );
    self.camera.position.set( 0, 150, 400 )
  #end _createCamera

  _createLight: ->
    self = @
    self.directionalLight = new THREE.DirectionalLight( 0xffffff, 0.5 )
    self.directionalLight.position.set( 0, -1, 1 )
    self.directionalLight.position.normalize()
    self.scene.add( self.directionalLight )

    self.pointLight = new THREE.PointLight( 0xffffff, 2, 300 )
    self.pointLight.position.set( 0, 0, 0 )
    self.scene.add( self.pointLight )
  #end _createLight


  _createLogo: -> #ok
    self = this
    logoPoints = []

    $.each(self.logoPointsArray,->
      logoPoints.push new THREE.Vector2(@[0], @[1])
    )
#    logoPoints.push new THREE.Vector2(0, 0)
#    logoPoints.push new THREE.Vector2(49, 38)
#    logoPoints.push new THREE.Vector2(98, 0)
#    logoPoints.push new THREE.Vector2(98, 89)
#    logoPoints.push new THREE.Vector2(49, 50)
#    logoPoints.push new THREE.Vector2(0, 89)


    logoShape = new THREE.Shape(logoPoints)
    extrusionSettings =
      amount: 60
      curveSegments: 3
      bevelThickness: 1
      bevelSize: 2
      bevelEnabled: false
      material: 0
      extrudeMaterial: 1

    logoGeometry = new THREE.ExtrudeGeometry(logoShape, extrusionSettings)
    materialFront = new THREE.MeshPhongMaterial(color: 0xffff00)
    materialSide = new THREE.MeshBasicMaterial(color: 0xff8800)
    materialArray = [materialFront, materialSide]
    logoMaterial = new THREE.MeshFaceMaterial(materialArray)
    logoMesh = new THREE.Mesh(logoGeometry, logoMaterial)


    #add inner part 1
    logoInnerPoints = []
    logoInnerPoints.push new THREE.Vector2(9, 16)
    logoInnerPoints.push new THREE.Vector2(43, 44)
    logoInnerPoints.push new THREE.Vector2(8, 73)

    logoInnerShape = new THREE.Shape(logoInnerPoints)
    logoInnerGeometry = new THREE.ExtrudeGeometry(logoInnerShape, extrusionSettings)


    logoInnerMesh = new THREE.Mesh(logoInnerGeometry, logoMaterial)

    #add inner part 2
    logoInnerPoints = []
    logoInnerPoints.push new THREE.Vector2(89, 16)
    logoInnerPoints.push new THREE.Vector2(89, 73)
    logoInnerPoints.push new THREE.Vector2(55, 44)

    logoInnerShape = new THREE.Shape(logoInnerPoints)
    logoInnerGeometry = new THREE.ExtrudeGeometry(logoInnerShape, extrusionSettings)


    logoInnerMesh2 = new THREE.Mesh(logoInnerGeometry, logoMaterial)


    #cutting off inner parts from logoMesh
    logoBSP = new ThreeBSP(logoMesh)
    innerBSP = new ThreeBSP(logoInnerMesh)
    innerBSP2 = new ThreeBSP(logoInnerMesh2)


    materialFront = new THREE.MeshPhongMaterial(color: 0x595959)
    materialSide = new THREE.MeshPhongMaterial(color: 0x333333)
    materialArray = [materialFront, materialSide]
    finalLogoMaterial = new THREE.MeshFaceMaterial(materialArray)

    texture = new THREE.ImageUtils.loadTexture("images/textures/lensflare0.png")
    texture.wrapS = texture.wrapT = THREE.RepeatWrapping
    texture.repeat.set 0.05, 0.05

    newBSP = logoBSP.subtract(innerBSP).subtract(innerBSP2)
    self.logoMesh = newBSP.toMesh(finalLogoMaterial)
    #self.logoMesh.scale.set(0.38, 0.38, 1)
    self.logoMesh.position.set(0,0,0)
    self.scene.add(self.logoMesh)
  #end _createLogo

  _createLogoShape: ->
    self = @
    logoPathPoints = []

    $.each(self.logoPointsArray,(i,point)->
      logoPathPoints.push new THREE.Vector2( point[0], point[1] )
    )
    self.logoPathShape = new THREE.Shape(logoPathPoints)
    extrusionSettings =
      amount: 60
      curveSegments: 3
      bevelThickness: 1
      bevelSize: 2
      bevelEnabled: false
      material: 0
      extrudeMaterial: 1

    logoInnerGeometry = new THREE.ExtrudeGeometry(self.logoPathShape, extrusionSettings)


    logoMaterial = new THREE.MeshPhongMaterial(color: 0xff0000)
    self.logoPathMesh = new THREE.Mesh(logoInnerGeometry, logoMaterial)
    self.scene.add(self.logoPathMesh)

  _createPointLight: ->
    self = @

    self.pointLight = new THREE.PointLight( 0xff0000, 2, 300 );
    self.pointLight.position.set( -100, 100, 0 );
    self.scene.add( self.pointLight )



  _centerObjects: ->
    self = @
    self.logoMesh.position.y = 110
    self.logoMesh.rotation.y = -0.15


  init: ->
    self = @
    @_createScene()
    @_createCamera()
    @_createRenderer()
    @_createLight()
    @_createControls()
    @_createAxis()
    @_createLogo()

    @_createLogoShape()
    @_createPointLight()


    @_centerObjects()

    cameraRotation =
      x: -0.044290619305723665
      y: 0.11441668992823127
      z: 0.005059802268417281

    if typeof self.controls != "undefined"
      #@controls.rotateRight(0.15)
      @controls.rotateDown(0.3)

    render = ->
      self.renderer.render(self.scene, self.camera)

    update = ->
      self.keyboard.pressed("z")
      if typeof self.controls != "undefined"
        self.controls.update()
      #x = 0.1 + self.camera.rotation.x
      #self.controls.rotateRight(x)

    animate = ->
      requestAnimationFrame animate
      render()
      update()

    animate()

  constructor: ->
    @init()


$(->
  window.intro = new Intro()
)