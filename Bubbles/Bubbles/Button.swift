import SpriteKit

class ButtonNode: SKNode {
    enum ButtonState {
        case normal, highlighted
    }
    
    var state = ButtonState.normal {
        didSet { updateGraphics() }
    }
    let defaultSprite: SKSpriteNode
    let activeSprite: SKSpriteNode
    var action: (() -> Void)?
    
    init(defaultImageName: String, activeButtonImage: String) {
        defaultSprite = SKSpriteNode(imageNamed: defaultImageName)
        activeSprite = SKSpriteNode(imageNamed: activeButtonImage)
        
        super.init()
        updateGraphics()
        isUserInteractionEnabled = true
        addChild(defaultSprite)
        addChild(activeSprite)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGraphics() {
        defaultSprite.isHidden = state != .normal
        activeSprite.isHidden = state == .normal
    }
    
    weak var currentTouch: UITouch?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .highlighted
        currentTouch = touches.first
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = currentTouch, touches.contains(touch) else { return }
        let location: CGPoint = touch.location(in: self)
        
        state = defaultSprite.contains(location) ? .highlighted : .normal
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = currentTouch, touches.contains(touch) else { return }
        state = .normal
        currentTouch = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = currentTouch, touches.contains(touch) else { return }
        
        let location: CGPoint = touch.location(in: self)
        
        if defaultSprite.contains(location) { action?() }
        state = .normal
        currentTouch = nil
    }
    
}
