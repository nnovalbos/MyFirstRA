//
//  ViewController.swift
//  MyFristRA
//
//  Created by Nicolas Novalbos on 10/6/18.
//  Copyright © 2018 Nicolás Novalbos. All rights reserved.
//



import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    /*
     ARSCNView es una subclase de RA personalizada que implementa toda la renderización o la mayor parte por nosotros.
     Así soportará actualizaciones de la cámara virtual basadas en ARFrames que son devueltas como propiedad del ARSCNView, o mi sceneView-
     
     Establecemos una scena que va a  ser un 'ship' que se traduce delante sobre el eje Z del mundo original. Luego tenemos que acceder a la sesión
     y llamando al método Run, con una configuración del 'mundo real' y con esto automáticamente la vista soportará una actualización de mi cámara virtual
     
     
     */
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
 
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handlerTap(gestureReconigze:)))
        view.addGestureRecognizer(tapGesture);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

       // let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    /*
     Este método hará que cada vez que toquemos un la pantalla se añadirá una nueva imagen ( de lo q haya en la pantalla)
     Pero siemopre estará en la posición 0000, por lo que no la veremos. Hay que hacer que se mueva negativamente
     en el eje Z ( hacía fuera de nosotros)
     
     Me diante el frameActual ( ARFrame), disponemos de un objeto ARCamara.
     Con esta ARCamera yo podría usar la transformación de la cámara para actualizar la transformación del nodo del avión
     de este modo el nodo del avión está dónde mi cámara actualmente.
     
     , a la cual se le
     puede aplicar la transformación dque nos permitirá saber su posición
     relativa en la escena y posicionar el avión a una distancia, de ella,  en el eje Z que nos
     */
    
    @objc
    func handlerTap( gestureReconigze: UITapGestureRecognizer){
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        
        //se crea un SCNPlane, para poder representar la captura de pantalla.
        let imagePlane = SCNPlane(width: sceneView.bounds.width/6000, height: sceneView.bounds.height/6000)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        //modo de luz constante. Asi la luz es proporcinada por airkit
        imagePlane.firstMaterial?.lightingModel = .constant
        
        //para añadir esta imagen a la escena, hay que crear un nuevo nodo Plano
        //la geometía ( plano snapshot anteriormente capturado) se encapsula dentro del nodo
        
        let node =  SCNNode(geometry: imagePlane)
        
        //creamos transform y le damos 10cmt alejado de la cámara ( eje Z)
        //primero creamos la matriz de translación, pq no quiero poner la imagen del avión donde está la cámara
        //y obstruir mi vista, queremos situarla delante de la cámara. Para eso se usa la parte negativa del eje Z
        var translation = matrix_identity_float4x4 //ver que es esta constante!!
        translation.columns.3.z = -0.1 //las unidades son metros; 0.1 = 10 ctms
        //hacemos la transformación de la cámara
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        sceneView.scene.rootNode.addChildNode(node)
        
        
    }
    
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
