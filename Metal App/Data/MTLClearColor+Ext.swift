import Metal

extension MTLClearColor {
    subscript(index: Int) -> Double {
        get {
            switch index {
            case 0: return red
            case 1: return green
            case 2: return blue
            case 3: return alpha
            default: return .nan
            }
        }
        set {
            switch index {
            case 0: red   = newValue
            case 1: green = newValue
            case 2: blue  = newValue
            case 3: alpha = newValue
            default: ()
            }
        }
    }
}

struct PhasedColor {
    private var growing = false
    private var channel = 0
    private var color: MTLClearColor = .init()
    
    mutating func update(rate: Double = 0.005) -> MTLClearColor {
        if growing {
            let index = (channel + 1) % 3
            color[index] += rate
            if color[index] >= 1.0 {
                growing.toggle()
                channel = index
            }
        } else {
            let index = (channel + 2) % 3
            color[index] -= rate
            if color[index] <= 0.0 {
                growing.toggle()
            }
        }
        
        return color
    }
}
